import strutils
import sequtils
import tables
import algorithm
import bitops

import ./piece
import ./board
import ./move

type CastlingStatus* = uint8

type CastlingType* {.size: sizeof(uint8), pure.} = enum
  none = 0
  K = 1
  Q = 2
  k = 4
  q = 8

type MoveEffect* = object
  captured*: Piece
  previousTurn*: PieceColor
  previousEnpassant*: int8
  previousCastling*: CastlingStatus
  previousHalfmoveClock*: int
  previousFullmoveNumber*: int

type SearchResult* = object
  bestMove*: Move
  score*: int      # Score in centipawns (UCI: positive = good for side to move)
  nodes*: int      # Total nodes searched

type Game* = object
  # Board state
  board*: Board

  # Position state (what's needed for move generation)
  turn*: PieceColor
  enpassantPosition*: int8  # Use int8 to allow NO_ENPASSANT (-1) sentinel
  castlingStatus*: CastlingStatus

  # Game metadata (for rules/notation)
  halfmoveClock*: int
  fullmoveNumber*: int

  # Performance cache
  whiteKingPosition: Position
  blackKingPosition: Position


const STARTING_FEN* = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

proc fromFen*(fen: string): Game =
  var parts = fen.split(" ")
  if len(parts) != 6:
    raise newException(ValueError, "Invalid FEM")

  # piece placement
  let game_board = board.fromFenPiecePlacement(parts[0])

  # active color
  let turn = if parts[1] == "w": PieceColor.white else: PieceColor.black

  let castling_string = parts[2]
  var castling = CastlingStatus(0)
  if castling_string != "-":
    if 'K' in castling_string:
      castling = castling or CastlingStatus(ord(CastlingType.K))
    if 'k' in castling_string:
      castling = castling or CastlingStatus(ord(CastlingType.k))
    if 'Q' in castling_string:
      castling = castling or CastlingStatus(ord(CastlingType.Q))
    if 'q' in castling_string:
      castling = castling or CastlingStatus(ord(CastlingType.q))

  let enpassant_string = parts[3]
  var enpassant: int8 = NO_ENPASSANT
  if enpassant_string != "-":
    enpassant = int8(positionFromAlgebric(enpassant_string))

  var halfmoveClock = parseInt(parts[4])
  var fullmoveNumber = parseInt(parts[5])

  return Game(
    board: game_board,
    turn: turn,
    enpassantPosition: enpassant,
    castlingStatus: castling,
    halfmoveClock: halfmoveClock,
    fullmoveNumber: fullmoveNumber,
    whiteKingPosition: findKing(game_board, PieceColor.white),
    blackKingPosition: findKing(game_board, PieceColor.black)
  )

proc newGame*(): Game =
  return fromFen(STARTING_FEN)

const FRONT = -board.BOARD_WIDTH
const BACK = -FRONT
const LEFT = -1
const RIGHT = -LEFT

proc playMove*(game: var Game, move: Move): MoveEffect =
  var effect: MoveEffect
  effect.previousTurn = game.turn
  effect.previousEnpassant = game.enpassantPosition
  effect.previousCastling = game.castlingStatus
  effect.previousHalfmoveClock = game.halfmoveClock
  effect.previousFullmoveNumber = game.fullmoveNumber

  let movingPiece = game.board[move.source]
  let movingColor = color(movingPiece)

  # Handle captures - special case for en passant
  if move.kind == EpCapture:
    # En passant: captured pawn is not at the target square
    let capturedPawnPos = if movingColor == PieceColor.white:
                            Position(int(move.target) + BACK)
                          else:
                            Position(int(move.target) + FRONT)
    effect.captured = game.board[capturedPawnPos]
    game.board[capturedPawnPos] = 0
  else:
    effect.captured = game.board[move.target]

  # Execute the move based on kind
  case move.kind:
  of Quiet, Captures, DoublePawnPush:
    # Standard move
    game.board[move.target] = game.board[move.source]
    game.board[move.source] = 0

  of EpCapture:
    # Move attacking pawn (captured pawn already removed above)
    game.board[move.target] = game.board[move.source]
    game.board[move.source] = 0

  of KingCastle:
    # Move king
    game.board[move.target] = game.board[move.source]
    game.board[move.source] = 0
    # Move rook from +3*RIGHT to +RIGHT
    game.board[Position(int(move.source) + RIGHT)] = game.board[Position(int(move.source) + 3 * RIGHT)]
    game.board[Position(int(move.source) + 3 * RIGHT)] = 0

  of QueenCastle:
    # Move king
    game.board[move.target] = game.board[move.source]
    game.board[move.source] = 0
    # Move rook from +4*LEFT to +LEFT
    game.board[Position(int(move.source) + LEFT)] = game.board[Position(int(move.source) + 4 * LEFT)]
    game.board[Position(int(move.source) + 4 * LEFT)] = 0

  of KnightPromotion, BishopPromotion, RookPromotion, QueenPromotion,
     KnightPromoCapture, BishopPromoCapture, RookPromoCapture, QueenPromoCapture:
    # Promotion: replace pawn with promoted piece
    let promotedPieceType = case move.kind:
      of QueenPromotion, QueenPromoCapture: PieceType.queen
      of RookPromotion, RookPromoCapture: PieceType.rook
      of BishopPromotion, BishopPromoCapture: PieceType.bishop
      of KnightPromotion, KnightPromoCapture: PieceType.knight
      else: PieceType.none  # shouldn't happen
    game.board[move.target] = piece(promotedPieceType, movingColor)
    game.board[move.source] = 0

  # Update cache if king moved
  if type(movingPiece) == PieceType.king:
    if movingColor == PieceColor.white:
      game.whiteKingPosition = move.target
    else:
      game.blackKingPosition = move.target

  # Update castling rights
  # Remove castling rights if king moves
  if type(movingPiece) == PieceType.king:
    if movingColor == PieceColor.white:
      game.castlingStatus = game.castlingStatus and not (ord(CastlingType.K) or ord(CastlingType.Q)).uint8
    else:
      game.castlingStatus = game.castlingStatus and not (ord(CastlingType.k) or ord(CastlingType.q)).uint8

  # Remove castling rights if rook moves from starting position
  if type(movingPiece) == PieceType.rook:
    if movingColor == PieceColor.white:
      # White kingside rook (h1 = position 7)
      if move.source == Position(63):
        game.castlingStatus = game.castlingStatus and not ord(CastlingType.K).uint8
      # White queenside rook (a1 = position 0)
      elif move.source == Position(56):
        game.castlingStatus = game.castlingStatus and not ord(CastlingType.Q).uint8
    else:
      # Black kingside rook (h8 = position 63)
      if move.source == Position(7):
        game.castlingStatus = game.castlingStatus and not ord(CastlingType.k).uint8
      # Black queenside rook (a8 = position 56)
      elif move.source == Position(0):
        game.castlingStatus = game.castlingStatus and not ord(CastlingType.q).uint8

  # Remove castling rights if rook is captured
  if type(effect.captured) == PieceType.rook:
    if color(effect.captured) == PieceColor.white:
      if move.target == Position(63):
        game.castlingStatus = game.castlingStatus and not ord(CastlingType.K).uint8
      elif move.target == Position(56):
        game.castlingStatus = game.castlingStatus and not ord(CastlingType.Q).uint8
    else:
      if move.target == Position(7):
        game.castlingStatus = game.castlingStatus and not ord(CastlingType.k).uint8
      elif move.target == Position(0):
        game.castlingStatus = game.castlingStatus and not ord(CastlingType.q).uint8

  # Update en passant position
  if move.kind == DoublePawnPush:
    # Set en passant to the square the pawn jumped over
    game.enpassantPosition = int8((int(move.source) + int(move.target)) div 2)
  else:
    # Clear en passant
    game.enpassantPosition = NO_ENPASSANT

  # Update halfmove clock (50-move rule)
  # Reset to 0 if pawn move or capture, otherwise increment
  if type(movingPiece) == PieceType.pawn or effect.captured != 0:
    game.halfmoveClock = 0
  else:
    game.halfmoveClock += 1

  # Update fullmove number (increments after Black's move)
  if movingColor == PieceColor.black:
    game.fullmoveNumber += 1

  # Flip turn
  game.turn = !game.turn

  return effect

proc undoMove*(game: var Game, move: Move, effect: MoveEffect) =
  let movedPiece = game.board[move.target]
  let movedColor = color(movedPiece)

  # Reverse the move based on kind
  case move.kind:
  of EpCapture:
    # Restore attacking pawn to source
    game.board[move.source] = game.board[move.target]
    # Clear target (it was empty before en passant)
    game.board[move.target] = 0
    # Restore captured pawn at its original position
    let capturedPawnPos = if movedColor == PieceColor.white:
                            Position(int(move.target) + BACK)
                          else:
                            Position(int(move.target) + FRONT)
    game.board[capturedPawnPos] = effect.captured

  of KingCastle:
    # Move king back
    game.board[move.source] = game.board[move.target]
    game.board[move.target] = 0
    # Move rook back from +RIGHT to +3*RIGHT
    game.board[Position(int(move.source) + 3 * RIGHT)] = game.board[Position(int(move.source) + RIGHT)]
    game.board[Position(int(move.source) + RIGHT)] = 0

  of QueenCastle:
    # Move king back
    game.board[move.source] = game.board[move.target]
    game.board[move.target] = 0
    # Move rook back from +LEFT to +4*LEFT
    game.board[Position(int(move.source) + 4 * LEFT)] = game.board[Position(int(move.source) + LEFT)]
    game.board[Position(int(move.source) + LEFT)] = 0

  of KnightPromotion, BishopPromotion, RookPromotion, QueenPromotion,
     KnightPromoCapture, BishopPromoCapture, RookPromoCapture, QueenPromoCapture:
    # Restore pawn (not the promoted piece!)
    game.board[move.source] = piece(PieceType.pawn, movedColor)
    game.board[move.target] = effect.captured

  else:
    # Standard undo (Quiet, Captures, DoublePawnPush)
    game.board[move.source] = game.board[move.target]
    game.board[move.target] = effect.captured

  # Restore cache if king moved
  if type(game.board[move.source]) == PieceType.king:
    if movedColor == PieceColor.white:
      game.whiteKingPosition = move.source
    else:
      game.blackKingPosition = move.source

  # Restore position state (turn, en passant, castling)
  game.turn = effect.previousTurn
  game.enpassantPosition = effect.previousEnpassant
  game.castlingStatus = effect.previousCastling

  # Restore game metadata (clocks)
  game.halfmoveClock = effect.previousHalfmoveClock
  game.fullmoveNumber = effect.previousFullmoveNumber

proc generatePseudolegalMoves*(game: Game): seq[Move] =
  var moves: seq[Move] = newSeqOfCap[Move](1024)
  for position, piece in game.board:
    if type(piece) == PieceType.none:
      continue
    if color(piece) != game.turn:
      continue

    if type(piece) == PieceType.pawn:
      var DIRECTION = 1
      if color(piece) == PieceColor.black:
        # movement is reversed for pawns
        DIRECTION = -1

      let singlePawnMovement = FRONT * DIRECTION
      if not (position + singlePawnMovement in game.board.low .. game.board.high):
        continue

      if type(game.board[position + singlePawnMovement]) == PieceType.none:
        # Check for promotion (pawn reaching last rank)
        let isPromotion = (color(piece) == PieceColor.white and row(position) == 1) or
                          (color(piece) == PieceColor.black and row(position) == 6)
        if isPromotion:
          moves.add(newMove(position, position + singlePawnMovement, QueenPromotion))
          moves.add(newMove(position, position + singlePawnMovement, RookPromotion))
          moves.add(newMove(position, position + singlePawnMovement, BishopPromotion))
          moves.add(newMove(position, position + singlePawnMovement, KnightPromotion))
        else:
          moves.add(newMove(position, position + singlePawnMovement, Quiet))

        # only for pawn on 2nd and 2nd-last row
        if (color(piece) == PieceColor.white and row(position) == BOARD_WIDTH - 2) or
            (color(piece) == PieceColor.black and row(position) == 1):
          let doublePawnMovement = 2 * FRONT * DIRECTION
          # Check if double push is valid (in bounds and both squares empty)
          if (position + doublePawnMovement in game.board.low .. game.board.high) and
              type(game.board[position + doublePawnMovement]) == PieceType.none:
            moves.add(newMove(position, position + doublePawnMovement, DoublePawnPush))

      # take moves
      let front_left_position = position + FRONT * DIRECTION + LEFT
      if front_left_position in game.board.low .. game.board.high and
          abs(column(front_left_position) - column(position)) == 1: # boundary check
        if type(game.board[front_left_position]) != PieceType.none and
            color(game.board[front_left_position]) != color(piece):
          let isPromoCapture = (color(piece) == PieceColor.white and row(position) == 1) or
                               (color(piece) == PieceColor.black and row(position) == 6)
          if isPromoCapture:
            moves.add(newMove(position, front_left_position, QueenPromoCapture))
            moves.add(newMove(position, front_left_position, RookPromoCapture))
            moves.add(newMove(position, front_left_position, BishopPromoCapture))
            moves.add(newMove(position, front_left_position, KnightPromoCapture))
          else:
            moves.add(newMove(position, front_left_position, Captures))
        # En passant left
        elif game.enpassantPosition == int8(front_left_position):
          moves.add(newMove(position, front_left_position, EpCapture))

      let front_right_position = position + FRONT * DIRECTION + RIGHT
      if front_right_position in game.board.low .. game.board.high and
          abs(column(front_right_position) - column(position)) == 1: # boundary check
        if type(game.board[front_right_position]) != PieceType.none and
            color(game.board[front_right_position]) != color(piece):
          let isPromoCapture = (color(piece) == PieceColor.white and row(position) == 1) or
                               (color(piece) == PieceColor.black and row(position) == 6)
          if isPromoCapture:
            moves.add(newMove(position, front_right_position, QueenPromoCapture))
            moves.add(newMove(position, front_right_position, RookPromoCapture))
            moves.add(newMove(position, front_right_position, BishopPromoCapture))
            moves.add(newMove(position, front_right_position, KnightPromoCapture))
          else:
            moves.add(newMove(position, front_right_position, Captures))
        # En passant right
        elif game.enpassantPosition == int8(front_right_position):
          moves.add(newMove(position, front_right_position, EpCapture))
    elif type(piece) == PieceType.knight:
      # . X . X .
      # X . . . X
      # . . N . .
      # X . . . X
      # . X . X .
      const knightMovements = [
        FRONT * 2 + LEFT,
        FRONT * 2 + RIGHT,
        FRONT + LEFT * 2,
        FRONT + RIGHT * 2,
        BACK + LEFT * 2,
        BACK + RIGHT * 2,
        BACK * 2 + LEFT,
        BACK * 2 + RIGHT,
      ]
      for knightMovement in knightMovements:
        # out of bounds
        if not (position + knightMovement in game.board.low .. game.board.high):
          continue

        if abs(column(position) - column(position + knightMovement)) > 2:
          # make sure we don't jump from one side to the other
          # this happens because of the board representation we have chosen
          continue

        # take move
        if type(game.board[position + knightMovement]) != PieceType.none:
          # can only take a different color
          if color(piece) == color(game.board[position + knightMovement]):
            continue
          moves.add(newMove(position, position + knightMovement, Captures))
        else:
          # quiet move
          moves.add(newMove(position, position + knightMovement, Quiet))
    elif type(piece) == PieceType.rook:
      for movement in [FRONT, BACK, LEFT, RIGHT]:
        # simulate sliding
        var slidingPosition = position
        while true:
          var destination = slidingPosition + movement

          if not (destination in game.board.low .. game.board.high):
            break

          if abs(column(slidingPosition) - column(destination)) > 1:
            # make sure we don't move up a row based on left/right movement (aka wrap around)
            # this happens because of the board representation we have chosen
            break

          # capture move?
          if type(game.board[destination]) != PieceType.none:
            # can only take a different color
            if color(piece) == color(game.board[destination]):
              break
            else:
              # take and stop
              moves.add(newMove(position, destination, Captures))
              break

          moves.add(newMove(position, destination, Quiet))
          slidingPosition = destination
    elif type(piece) == PieceType.bishop:
      for movement in [FRONT + LEFT, FRONT + RIGHT, BACK + LEFT, BACK + RIGHT]:
        # simulate sliding
        var slidingPosition = position
        while true:
          var destination = slidingPosition + movement
          if not (destination in game.board.low .. game.board.high):
            break

          if abs(column(slidingPosition) - column(destination)) > 1:
            # make sure we don't move up a row based on left/right movement (aka wrap around)
            # this happens because of the board representation we have chosen
            break

          # capture move?
          if type(game.board[destination]) != PieceType.none:
            # can only take a different color
            if color(piece) == color(game.board[destination]):
              break
            else:
              # take and stop
              moves.add(newMove(position, destination, Captures))
              break

          moves.add(newMove(position, destination, Quiet))
          slidingPosition = destination
    elif type(piece) == PieceType.queen:
      for movement in [
        FRONT, BACK, LEFT, RIGHT, FRONT + LEFT, FRONT + RIGHT, BACK + LEFT, BACK + RIGHT
      ]:
        var slidingPosition = position
        while true:
          var destination = slidingPosition + movement
          if not (destination in game.board.low .. game.board.high):
            break

          if abs(column(slidingPosition) - column(destination)) > 1:
            # make sure we don't move up a row based on left/right movement (aka wrap around)
            # this happens because of the board representation we have chosen
            break

          # capture move?
          if type(game.board[destination]) != PieceType.none:
            # can only take a different color
            if color(piece) == color(game.board[destination]):
              break
            else:
              # take and stop
              moves.add(newMove(position, destination, Captures))
              break

          moves.add(newMove(position, destination, Quiet))
          slidingPosition = destination
    elif type(piece) == PieceType.king:
      for movement in [
        FRONT, BACK, LEFT, RIGHT, FRONT + LEFT, FRONT + RIGHT, BACK + LEFT, BACK + RIGHT
      ]:
        var destination = position + movement
        if not (destination in game.board.low .. game.board.high):
          continue

        if abs(column(position) - column(destination)) > 1:
          # make sure we don't move up a row based on left/right movement (aka wrap around)
          # this happens because of the board representation we have chosen
          continue

        # take move
        if type(game.board[position + movement]) != PieceType.none:
          # can only take a different color
          if color(piece) == color(game.board[position + movement]):
            continue
          else:
            moves.add(newMove(position, position + movement, Captures))
            continue

        moves.add(newMove(position, position + movement, Quiet))
      # Castling
      if color(piece) == PieceColor.white:
        # king side
        if (bitand(game.castlingStatus, ord(CastlingType.K).uint8) != 0):
          if type(game.board[position + RIGHT]) == PieceType.none and
              type(game.board[position + 2 * RIGHT]) == PieceType.none and
              type(game.board[position + 3 * RIGHT]) == PieceType.rook and
              color(game.board[position + 3 * RIGHT]) == PieceColor.white:
            moves.add(newMove(position, position + 2 * RIGHT, KingCastle))
        # queen side
        if (bitand(game.castlingStatus, ord(CastlingType.Q).uint8) != 0):
          if type(game.board[position + LEFT]) == PieceType.none and
              type(game.board[position + 2 * LEFT]) == PieceType.none and
              type(game.board[position + 3 * LEFT]) == PieceType.none and
              type(game.board[position + 4 * LEFT]) == PieceType.rook and
              color(game.board[position + 4 * LEFT]) == PieceColor.white:
            moves.add(newMove(position, position + 2 * LEFT, QueenCastle))
      elif color(piece) == PieceColor.black:
        # king side
        if (bitand(game.castlingStatus, ord(CastlingType.k).uint8) != 0):
          if type(game.board[position + RIGHT]) == PieceType.none and
              type(game.board[position + 2 * RIGHT]) == PieceType.none and
              type(game.board[position + 3 * RIGHT]) == PieceType.rook and
              color(game.board[position + 3 * RIGHT]) == PieceColor.black:
            moves.add(newMove(position, position + 2 * RIGHT, KingCastle))
        # queen side
        if (bitand(game.castlingStatus, ord(CastlingType.q).uint8) != 0):
          if type(game.board[position + LEFT]) == PieceType.none and
              type(game.board[position + 2 * LEFT]) == PieceType.none and
              type(game.board[position + 3 * LEFT]) == PieceType.none and
              type(game.board[position + 4 * LEFT]) == PieceType.rook and
              color(game.board[position + 4 * LEFT]) == PieceColor.black:
            moves.add(newMove(position, position + 2 * LEFT, QueenCastle))
  return moves

proc isAttacked*(board: Board, position: Position, attacker: PieceColor): bool =
  # Check if the square is attacked by a pawn
  # Look "behind" the target square to find attacking pawns
  let pawnCheckDirection = if attacker == PieceColor.white: BACK else: FRONT
  let pawnAttackOffsets = [pawnCheckDirection + LEFT, pawnCheckDirection + RIGHT]
  for offset in pawnAttackOffsets:
    let attackPos = int(position) + offset
    if attackPos in board.low .. board.high and
        abs(column(Position(attackPos)) - column(position)) == 1 and  # Prevent wrap-around
        type(board[attackPos]) == PieceType.pawn and
        color(board[attackPos]) == attacker:
      return true

  # Check if the square is attacked by a knight
  let knightMoves = [
    FRONT * 2 + LEFT, FRONT * 2 + RIGHT, FRONT + LEFT * 2, FRONT + RIGHT * 2,
    BACK + LEFT * 2, BACK + RIGHT * 2, BACK * 2 + LEFT, BACK * 2 + RIGHT
  ]
  for knightMove in knightMoves:
    let attackPos = int(position) + knightMove
    if attackPos in board.low .. board.high and
        abs(column(Position(attackPos)) - column(position)) <= 2 and  # Prevent wrap-around
        type(board[attackPos]) == PieceType.knight and
        color(board[attackPos]) == attacker:
      return true

  # Check if the square is attacked by a sliding piece (rook, bishop, queen)
  let slidingDirections = [
    FRONT, BACK, LEFT, RIGHT, FRONT + LEFT, FRONT + RIGHT, BACK + LEFT, BACK + RIGHT
  ]
  for direction in slidingDirections:
    var slidingPos = int(position)
    while true:
      let prevColumn = column(Position(slidingPos))
      slidingPos += direction

      if not (slidingPos in board.low .. board.high):
        break

      # Check for wrap-around between consecutive positions
      if abs(column(Position(slidingPos)) - prevColumn) > 1:
        break

      if type(board[slidingPos]) != PieceType.none:
        if color(board[slidingPos]) == attacker:
          let pieceType = type(board[slidingPos])
          # Check if piece can attack in this direction
          if (direction in [FRONT, BACK, LEFT, RIGHT] and
              pieceType in [PieceType.rook, PieceType.queen]) or
             (direction in [FRONT + LEFT, FRONT + RIGHT, BACK + LEFT, BACK + RIGHT] and
              pieceType in [PieceType.bishop, PieceType.queen]):
            return true
        break

  # Check if the square is attacked by a king
  let kingMoves = [
    FRONT, BACK, LEFT, RIGHT, FRONT + LEFT, FRONT + RIGHT, BACK + LEFT, BACK + RIGHT
  ]
  for kingMove in kingMoves:
    let attackPos = int(position) + kingMove
    if attackPos in board.low .. board.high and
        abs(column(Position(attackPos)) - column(position)) <= 1 and  # Prevent wrap-around
        type(board[attackPos]) == PieceType.king and
        color(board[attackPos]) == attacker:
      return true
  return false

proc isChecked*(game: Game, color: PieceColor): bool {.inline.} =
  let attacker = !color
  let kingPosition =
    if color == PieceColor.white:
      game.whiteKingPosition
    else:
      game.blackKingPosition
  return isAttacked(game.board, kingPosition, attacker)

proc generateMoves*(game: var Game): seq[Move] =
  # Generate all legal moves for the current player
  let moves = generatePseudolegalMoves(game)
  var validMoves = newSeqOfCap[Move](1024)
  for move in moves:
    if move.kind == KingCastle or move.kind == QueenCastle:
      # Castling moves are only pseudolegal if the king is not in check,
      # but to make them legal we need to check that the squares the king passes through are not attacked
      let kingPath = if move.kind == KingCastle: [move.source, Position(int(move.source) + RIGHT), Position(int(move.source) + 2 * RIGHT)]
                     else: [move.source, Position(int(move.source) + LEFT), Position(int(move.source) + 2 * LEFT)]
      var pathIsAttacked = false
      for pos in kingPath:
        if isAttacked(game.board, pos, !game.turn):
          pathIsAttacked = true
          break
      if pathIsAttacked:
        continue
      validMoves.add(move)
    else:
      let effect = playMove(game, move)
      # After playMove, turn has flipped. Check if our king (opposite of current turn) is safe
      if not isChecked(game, !game.turn):
        validMoves.add(move)
      undoMove(game, move, effect)
  return validMoves

proc isCheckmated*(game: var Game): bool {.inline.} =
  let availableMoves = generateMoves(game)
  return
    isChecked(game, game.turn) and len(availableMoves) == 0

proc isStalemated*(game: var Game): bool {.inline.} =
  let availableMoves = generateMoves(game)
  return
    not isChecked(game, game.turn) and len(availableMoves) == 0

proc score(move: Move, board: Board): int {.inline.} =
  var value = 0
  # prioritize high-value captures
  if type(board[move.target]) != PieceType.none:
    value =
      PIECE_VALUES[type(board[move.target])] - PIECE_VALUES[type(board[move.source])]

  return value

proc sort_moves(moves: var seq[Move], game: Game) =
  # sort the moves in-place according to heuristic score

  type MoveAndScore = tuple[move: Move, score: int]
  var scoredMoves = newSeqOfCap[MoveAndScore](moves.len)
  for move in moves:
    scoredMoves.add((move: move, score: score(move, game.board)))
  # Sort by score descending
  scoredMoves.sort(proc(a, b: MoveAndScore): int =
    return b.score - a.score
  )

  # overwrite moves with sorted order
  for i in 0 ..< moves.len:
    moves[i] = scoredMoves[i].move

const CHECKMATE = abs(int(int16.low))

proc quiescence(game: var Game, alpha: int, beta: int, nodes: var int, ply: int): int =
  ## Quiescence search: continues searching capture moves until position is quiet.
  ## This prevents the horizon effect where the search stops right after a capture.
  nodes += 1

  # Stand-pat: evaluate current position
  # The side to move can choose to not capture if all captures are bad
  let standPat = sign(game.turn) * evaluate(game.board)

  # Beta cutoff - position already too good, opponent won't allow this
  if standPat >= beta:
    return beta

  var currAlpha = max(alpha, standPat)

  # Generate all legal moves and filter to captures only
  let allMoves = generateMoves(game)

  # If no legal moves, check for checkmate/stalemate
  if len(allMoves) == 0:
    if isChecked(game, game.turn):
      return -(CHECKMATE - ply)
    else:
      return 0

  # Search only captures
  for move in allMoves:
    if not move.isCapture():
      continue

    let effect = playMove(game, move)
    let score = -quiescence(game, -beta, -currAlpha, nodes, ply + 1)
    undoMove(game, move, effect)

    if score >= beta:
      return beta
    currAlpha = max(currAlpha, score)

  return currAlpha

proc evaluateAB*(game: var Game, depth: uint, alpha: int, beta: int, nodes: var int, ply: int): int =
  nodes += 1
  var moves = generateMoves(game)
  if len(moves) == 0:
    if isChecked(game, game.turn):
      return -(CHECKMATE - ply)
    else: # draw
      return 0

  if depth == 0:
    return quiescence(game, alpha, beta, nodes, ply)

  # sort the moves according to heuristic score
  sort_moves(moves, game)

  var currAlpha = alpha
  for move in moves:
    let effect = playMove(game, move)
    var evaluation = -1 * evaluateAB(game, depth - 1, -beta, -currAlpha, nodes, ply + 1)
    undoMove(game, move, effect)
    if evaluation >= beta:
      return beta
    currAlpha = max(currAlpha, evaluation)
  return currAlpha

proc searchAB*(game: var Game, depth: uint8): SearchResult =
  var availableMoves = generateMoves(game)

  if availableMoves.len == 0:
    return SearchResult(
      bestMove: Move(0),
      score: if isChecked(game, game.turn): -CHECKMATE else: 0,
      nodes: 0
    )

  sort_moves(availableMoves, game)

  var nodes = 0
  var bestScore = -CHECKMATE
  var bestMove = availableMoves[0]
  # always maximize bestScore
  for move in availableMoves:
    let effect = playMove(game, move)
    var score = -1 * evaluateAB(game, depth - 1, -CHECKMATE, -bestScore, nodes, 1)
    undoMove(game, move, effect)
    # Early exit on mate-in-1 (highest possible score)
    if score == CHECKMATE - 1:
      return SearchResult(
        bestMove: move,
        score: score,
        nodes: nodes
      )
    if score > bestScore:
      bestScore = score
      bestMove = move

  return SearchResult(
    bestMove: bestMove,
    score: bestScore,
    nodes: nodes
  )
