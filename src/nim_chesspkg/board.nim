import strutils
import sequtils
import tables

import piece

const STARTING_PIECES_FEM* = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"

const BOARD_WIDTH* = 8
const BOARD_HEIGHT* = 8
type Position* = type(sizeof(board.BOARD_WIDTH * board.BOARD_HEIGHT))
type Board* = array[BOARD_WIDTH * BOARD_HEIGHT, Piece]

proc column *(position: Position): int {.inline.} =
    # NOTE: not the file!
    return (position mod BOARD_WIDTH)

proc row *(position: Position): int {.inline.} =
    # NOTE:not the rank!
    return int(position / BOARD_WIDTH)

const FILES* = toSeq('a'..char(ord('a') + BOARD_WIDTH - 1))
proc repr *(position: Position): string =
    let col = column(position)
    let row = row(position)
    return FILES[col] & $(BOARD_HEIGHT - row)

proc positionFromString *(repr: string): Position =
    assert len(repr) == 2
    assert isLowerAscii(repr[0])
    assert isDigit(repr[1])
    var file = ord(repr[0]) - ord('a') 
    var rank = ord(repr[1]) - ord('0') 
    return Position((BOARD_HEIGHT - rank)*BOARD_WIDTH + file)


proc `$` *(board: Board): string =
    var output = ""
    output.add("   ")
    for file_letter in FILES:
        output.add(file_letter)
    output.add("\n")
    for i, piece in board:
        if i > 0 and i mod BOARD_WIDTH == 0:
            output.add("\n")
        if i mod BOARD_WIDTH == 0:
            output.add($(BOARD_HEIGHT - row(i)))
            output.add("  ")

        let piece_repr = $piece
        output.add(piece_repr)
    return output

proc empty *(): Board =
    var board: Board
    for i in 0..len(board)-1:
        board[i] = ord(PieceType.none)
    return board

proc fromFemPiecePlacement *(piece_placement: string): Board =
    var b = empty()
    let ranks = piece_placement.split("/")
    var i = 0
    for rank in ranks:
        for c in rank:
            if isDigit(c):
                i += int(c) - int('0')
            else:
                const symbol_to_piece_type = {
                    'p': PieceType.pawn,
                    'n': PieceType.knight,
                    'b': PieceType.bishop,
                    'r': PieceType.rook,
                    'q': PieceType.queen,
                    'k': PieceType.king,
                }.toTable
                let piece_type = symbol_to_piece_type[toLowerAscii(c)]
                let piece_color = if isUpperAscii(c): PieceColor.white else: PieceColor.black
                b[i] = piece(piece_type, piece_color)
                i += 1
    return b

type Move* = tuple
    source: Position
    target: Position

proc moveFromString* (repr: string): Move =
    var parts = repr.split("-")
    assert len(parts) == 2
    return (positionFromString(parts[0]), positionFromString(parts[1]))

proc `$` *(move: Move): string =
    return move.source.repr() & "-" & move.target.repr()

proc `$` *(moves: seq[Move]): string = 
    var output = ""
    var attackBoard: array[BOARD_WIDTH * BOARD_HEIGHT, int]
    for move in moves:
        attackBoard[move.target] = 1
    for i in 0..attackBoard.high:
        if i > 0 and i mod BOARD_WIDTH == 0:
            output.add("\n")
        output.add(if attackBoard[i] == 1: 'x' else: '.')
    return output

const pieceValues = {
    PieceType.pawn: 100,
    PieceType.knight: 300,
    PieceType.bishop: 350,
    PieceType.rook: 500,
    PieceType.queen: 900,
    PieceType.king: 30000,
}.toTable

proc evaluate *(board: Board): int =
    result = 0
    for piece in board:
        if type(piece) == PieceType.none:
            continue
        let sign = if color(piece) == PieceColor.white: 1 else: -1
        result += pieceValues.getOrDefault(type(piece), 0) * sign
    return result

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
            var destination = position+singlePawnMovement
            if not (destination in board.low..board.high):
                continue

            if type(board[position+singlePawnMovement]) != PieceType.none:
                continue
            moves.add((position, position+singlePawnMovement))

            # only for pawn on 2nd and 2nd-last row
            if (color(piece) == PieceColor.white and row(position) == BOARD_WIDTH - 2) or (color(piece) == PieceColor.black and row(position) == 1):
                let doublePawnMovement = 2*FRONT*DIRECTION
                var destination = position+doublePawnMovement
                # this will never happen, probably?
                if not (destination in board.low..board.high):
                    continue
                if type(board[position+doublePawnMovement]) != PieceType.none:
                    continue
                moves.add((position, position+doublePawnMovement))
            
            # take moves
            if type(board[position+FRONT*DIRECTION+LEFT]) != PieceType.none and color(board[position+FRONT*DIRECTION+LEFT]) != color(piece):
                moves.add((position, position+FRONT*DIRECTION+LEFT))

            if type(board[position+FRONT*DIRECTION+RIGHT]) != PieceType.none and color(board[position+FRONT*DIRECTION+RIGHT]) != color(piece):
                moves.add((position, position+FRONT*DIRECTION+RIGHT))


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
                    break
                
                if abs(column(position)-column(destination)) > 1:
                    # make sure we don't move up a row based on left/right movement (aka wrap around)
                    # this happens because of the board representation we have chosen
                    break

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

proc playMove *(board: Board, move: Move): Board =
    var new_board: Board
    new_board.shallowCopy(board)
    new_board[move.target] = new_board[move.source]
    new_board[move.source] = 0
    return new_board

proc findKing *(board: Board, color: PieceColor): Position =
    for position, piece in board:
        if type(piece) == PieceType.king and color(piece) == color:
            return position

proc isCapture *(board: Board, move: Move): bool =
    return type(board[move.target]) != PieceType.none

proc isChecked *(board: Board, color: PieceColor): bool

proc generateMoves *(board: Board, color: PieceColor, onlyCaptures: bool = false): seq[Move] =
    let moves = generatePseudolegalMoves(board, color)
    var validMoves: seq[Move] = @[]
    for move in moves:
        if onlyCaptures and not isCapture(board, move):
            continue
        let new_board = playMove(board, move)
        if not isChecked(new_board, color):
          validMoves.add(move)
    return validMoves

proc isChecked *(board: Board, color: PieceColor): bool =
    let attacker = !color
    let kingPosition = findKing(board, color)
    let attackerMoves = generateMoves(board, attacker, onlyCaptures=true)
    # if any valid move targets the king
    return attackerMoves.anyIt(it.target == kingPosition)