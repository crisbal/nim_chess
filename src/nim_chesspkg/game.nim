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
    none=0, K=1, Q=2, k=4, q=8

type GameStatus = object
    turn*: PieceColor
    castling*: CastlingStatus
    enpassant*: Position
    halfmoveClock*: int
    fullmoveNumber*: int
    whiteKingPosition: Position
    blackKingPosition: Position

type
    Game* = object
        board*: Board
        status: GameStatus

proc findKing *(board: Board, color: PieceColor): Position =
    for position, piece in board:
        if type(piece) == PieceType.king and color(piece) == color:
            return position

const STARTING_FEN* = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
 
proc fromFen *(fen: string): Game =
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
        if "K" in castling_string:
            castling += CastlingStatus(bitor(ord(CastlingType.K), ord(castling)))
        if "k" in castling_string:
            castling += CastlingStatus(bitor(ord(CastlingType.k), ord(castling)))
        if "Q" in castling_string:
            castling += CastlingStatus(bitor(ord(CastlingType.Q), ord(castling)))
        if "q" in castling_string:
            castling += CastlingStatus(bitor(ord(CastlingType.q), ord(castling)))

    let enpassant_string = parts[3]
    var enpassant: Position
    if enpassant_string != "-":
        enpassant = positionFromString(enpassant_string)

    var halfmoveClock = parseInt(parts[4])
    var fullmoveNumber = parseInt(parts[5])

    return Game(
        board: game_board,
        status: GameStatus(
            turn: turn,
            castling: castling,
            enpassant: enpassant,
            halfmoveClock: halfmoveClock,
            fullmoveNumber: fullmoveNumber,
            blackKingPosition: findKing(game_board, PieceColor.black),
            whiteKingPosition: findKing(game_board, PieceColor.white),
        ),
    )

proc newGame *(): Game =
    return fromFen(STARTING_FEN)


type MoveEffect = object
    captured*: Piece
    previousStatus*: GameStatus

proc playMove *(game: var Game, move: Move): MoveEffect =
    var previousStatus: GameStatus
    deepCopy(previousStatus, game.status)

    let captured = game.board[move.target]

    if type(game.board[move.source]) == PieceType.king:
        if color(game.board[move.source]) == PieceColor.white:
            game.status.whiteKingPosition = move.target
        else:
            game.status.blackKingPosition = move.target

    game.board[move.target] = game.board[move.source]
    game.board[move.source] = 0
    
    if game.status.turn == PieceColor.black:
        game.status.fullmoveNumber += 1
    game.status.turn = !game.status.turn
    
    return MoveEffect(captured: captured, previousStatus: previousStatus)

proc undoMove *(game: var Game, move: Move, effect: MoveEffect) =
    game.board[move.source] = game.board[move.target]
    game.board[move.target] = effect.captured
    game.status = effect.previousStatus

const FRONT = -board.BOARD_WIDTH
const BACK = -FRONT
const LEFT = -1
const RIGHT = -LEFT

proc generatePseudolegalMoves *(board: Board, turnColor: PieceColor): seq[Move] =
    var moves: seq[Move] = @[]
    for position, piece in board:
        if type(piece) == PieceType.none:
            continue
        if color(piece) != turnColor:
            continue

        if type(piece) == PieceType.pawn:
            # TODO Enpassant
            var DIRECTION = 1
            if color(piece) == PieceColor.black:
                # movement is reversed for pawns
                DIRECTION = -1

            let singlePawnMovement = FRONT*DIRECTION
            if not (position+singlePawnMovement in board.low..board.high):
                continue

            if type(board[position+singlePawnMovement]) == PieceType.none:
                moves.add((position, position+singlePawnMovement))

                # only for pawn on 2nd and 2nd-last row
                if (color(piece) == PieceColor.white and row(position) == BOARD_WIDTH - 2) or (color(piece) == PieceColor.black and row(position) == 1):
                    let doublePawnMovement = 2*FRONT*DIRECTION
                    # this will never happen, probably?
                    if not (position+doublePawnMovement in board.low..board.high):
                        continue
                    if type(board[position+doublePawnMovement]) != PieceType.none:
                        continue
                    moves.add((position, position+doublePawnMovement))

            # take moves
            let front_left_position = position+FRONT*DIRECTION+LEFT
            if front_left_position in board.low..board.high and abs(column(front_left_position)-column(position)) == 1: # boundary check
                if type(board[front_left_position]) != PieceType.none and color(board[front_left_position]) != color(piece):
                    moves.add((position, front_left_position))

            let front_right_position = position+FRONT*DIRECTION+RIGHT
            if front_right_position in board.low..board.high and abs(column(front_right_position)-column(position)) == 1: # boundary check
                if type(board[front_right_position]) != PieceType.none and color(board[front_right_position]) != color(piece):
                    moves.add((position, front_right_position))

        elif type(piece) == PieceType.knight:
            # . X . X .
            # X . . . X
            # . . N . .
            # X . . . X
            # . X . X .
            const knightMovements = [
                FRONT*2+LEFT, FRONT*2+RIGHT,
                FRONT+LEFT*2, FRONT+RIGHT*2,
                BACK+LEFT*2, BACK+RIGHT*2,
                BACK*2+LEFT, BACK*2+RIGHT
            ]
            for knightMovement in knightMovements:
                # out of bounds
                if not (position+knightMovement in board.low..board.high):
                    continue

                if abs(column(position)-column(position+knightMovement)) > 2:
                    # make sure we don't jump from one side to the other
                    # this happens because of the board representation we have chosen
                    continue

                # take move
                if type(board[position+knightMovement]) != PieceType.none:
                    # can only take a different color
                    if color(piece) == color(board[position+knightMovement]):
                        continue

                # movement move
                moves.add((position, position+knightMovement))

        elif type(piece) == PieceType.rook:
            for movement in [FRONT, BACK, LEFT, RIGHT]:
                # simulate sliding
                var slidingPosition = position
                while true:
                    var destination =  slidingPosition + movement

                    if not (destination in board.low..board.high):
                        break

                    if abs(column(slidingPosition)-column(destination)) > 1:
                        # make sure we don't move up a row based on left/right movement (aka wrap around)
                        # this happens because of the board representation we have chosen
                        break

                    # capture move?
                    if type(board[destination]) != PieceType.none:
                        # can only take a different color
                        if color(piece) == color(board[destination]):
                            break
                        else:
                            # take and stop
                            moves.add((position, destination))
                            break

                    moves.add((position, destination))
                    slidingPosition = destination

        elif type(piece) == PieceType.bishop:
            for movement in [FRONT+LEFT, FRONT+RIGHT, BACK+LEFT, BACK+RIGHT]:
                # simulate sliding
                var slidingPosition = position
                while true:
                    var destination =  slidingPosition + movement
                    if not (destination in board.low..board.high):
                        break

                    if abs(column(slidingPosition)-column(destination)) > 1:
                        # make sure we don't move up a row based on left/right movement (aka wrap around)
                        # this happens because of the board representation we have chosen
                        break

                    # capture move?
                    if type(board[destination]) != PieceType.none:
                        # can only take a different color
                        if color(piece) == color(board[destination]):
                            break
                        else:
                            # take and stop
                            moves.add((position, destination))
                            break

                    moves.add((position, destination))
                    slidingPosition = destination


        elif type(piece) == PieceType.queen:
            for movement in [FRONT, BACK, LEFT, RIGHT, FRONT+LEFT, FRONT+RIGHT, BACK+LEFT, BACK+RIGHT]:
                var slidingPosition = position
                while true:
                    var destination =  slidingPosition + movement
                    if not (destination in board.low..board.high):
                        break

                    if abs(column(slidingPosition)-column(destination)) > 1:
                        # make sure we don't move up a row based on left/right movement (aka wrap around)
                        # this happens because of the board representation we have chosen
                        break

                    # capture move?
                    if type(board[destination]) != PieceType.none:
                        # can only take a different color
                        if color(piece) == color(board[destination]):
                            break
                        else:
                            # take and stop
                            moves.add((position, destination))
                            break

                    moves.add((position, destination))
                    slidingPosition = destination

        elif type(piece) == PieceType.king:
            # TODO Castling
            for movement in [FRONT, BACK, LEFT, RIGHT, FRONT+LEFT, FRONT+RIGHT, BACK+LEFT, BACK+RIGHT]:
                var destination = position+movement
                if not (destination in board.low..board.high):
                    continue

                if abs(column(position)-column(destination)) > 1:
                    # make sure we don't move up a row based on left/right movement (aka wrap around)
                    # this happens because of the board representation we have chosen
                    continue

                # take move
                if type(board[position+movement]) != PieceType.none:
                    # can only take a different color
                    if color(piece) == color(board[position+movement]):
                        continue
                    else:
                        moves.add((position, position+movement))
                        continue

                moves.add((position, position+movement))
    return moves

proc isChecked *(board: Board, gameStatus: GameStatus, color: PieceColor): bool {.inline.}

proc generateMoves *(game: var Game, onlyCaptures: bool = false): seq[Move] =
    let moves = generatePseudolegalMoves(game.board, game.status.turn)
    var validMoves: seq[Move] = @[]
    for move in moves:
        if onlyCaptures and not isCapture(game.board, move):
            continue
        let moveEffect = playMove(game, move)
        if not isChecked(game.board, game.status, !game.status.turn):
          validMoves.add(move)
        undoMove(game, move, moveEffect)
    return validMoves

proc isChecked *(board: Board, gameStatus: GameStatus, color: PieceColor): bool =
    let attacker = !color
    let kingPosition = if color == PieceColor.white: gameStatus.whiteKingPosition else: gameStatus.blackKingPosition
    var attackerMoves = generatePseudolegalMoves(board, attacker)
    attackerMoves = attackerMoves.filterIt(isCapture(board, it))
    # if any valid move targets the king
    return attackerMoves.anyIt(it.target == kingPosition)

proc isCheckmated *(game: var Game): bool {.inline.} =
    let availableMoves = generateMoves(game)
    return isChecked(game.board, game.status, game.status.turn) and len(availableMoves) == 0

proc isStalemated *(game: var Game): bool {.inline.}  =
    let availableMoves = generateMoves(game)
    return not isChecked(game.board, game.status, game.status.turn) and len(availableMoves) == 0

proc score (move: Move, board: Board): int =
    var value = 0
    # prioritize high-value captures
    if type(board[move.target]) != PieceType.none:
        value = PIECE_VALUES[type(board[move.target])] - PIECE_VALUES[type(board[move.source])]

    return value

proc sort_moves(moves: seq[Move], game: Game): seq[Move] =
    # sort the moves according to heuristic score
    var move_to_score = initTable[Move, int]()
    for move in moves:
        move_to_score[move] = score(move, game.board)
    return moves.sorted(proc (m1, m2: Move): int = move_to_score.getOrDefault(m1, 0) - move_to_score.getOrDefault(m2, 0))

const CHECKMATE = abs(int(int16.low))

proc evaluateAB *(game: var Game, depth: uint, alpha: int, beta: int): int =
    var moves = generateMoves(game)
    if len(moves) == 0:
        if isChecked(game.board, game.status, game.status.turn): # you are checkmated!
            return -CHECKMATE
        else: # draw
            return 0

    if depth == 0:
        return sign(game.status.turn) * evaluate(game.board)
        
    # sort the moves according to heuristic score
    moves = sort_moves(moves, game)
    
    var currAlpha = alpha
    for move in moves:
        let effect = playMove(game, move)
        var evaluation = -1 * evaluateAB(game, depth - 1, -beta, -curr_alpha)
        undoMove(game, move, effect)
        if evaluation >= beta:
            return beta 
        currAlpha = max(currAlpha, evaluation)
    return currAlpha

proc searchAB *(game: var Game, depth: uint8): Move =
    var availableMoves = generateMoves(game)
    availableMoves = sort_moves(availableMoves, game)

    var bestScore = -CHECKMATE
    var bestMove: Move
    # always maximize bestScore
    for move in availableMoves:
        let effect = playMove(game, move)
        var score = -1 * evaluateAB(game, depth - 1, -CHECKMATE, +CHECKMATE)
        if score == CHECKMATE:
            return move
        undoMove(game, move, effect)
        if score > bestScore:
            bestScore = score
            bestMove = move
    return bestMove
