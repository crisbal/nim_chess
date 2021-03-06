import strutils
import sequtils
import tables
import algorithm

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

        let piece_repr = pieceToString(piece)
        output.add(piece_repr)
    return output

proc empty *(): Board =
    var board: Board
    for i in 0..len(board)-1:
        board[i] = ord(PieceType.none)
    return board

proc fromFenPiecePlacement *(piece_placement: string): Board =
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
    # TODO: castle
    assert len(repr) == 4
    return (positionFromString(repr[0..1]), positionFromString(repr[2..3]))

proc `$` *(move: Move): string =
    return move.source.repr() & move.target.repr()

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
    PieceType.king: 10000,
}.toTable

proc evaluate *(board: Board): int =
    result = 0
    for piece in board:
        if type(piece) == PieceType.none:
            continue
        result += (pieceValues.getOrDefault(type(piece), 0) * sign(color(piece)))
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

proc playMove *(board: var Board, move: Move): Piece =
    let captured = board[move.target]
    board[move.target] = board[move.source]
    board[move.source] = 0
    return captured

proc undoMove *(board: var Board, move: Move, captured: Piece) =
    board[move.source] = board[move.target]
    board[move.target] = captured

proc findKing *(board: Board, color: PieceColor): Position =
    for position, piece in board:
        if type(piece) == PieceType.king and color(piece) == color:
            return position

proc isCapture *(board: Board, move: Move): bool {.inline.} =
    return type(board[move.target]) != PieceType.none

proc isChecked *(board: Board, color: PieceColor): bool {.inline.}

proc generateMoves *(board: var Board, color: PieceColor, onlyCaptures: bool = false): seq[Move] =
    let moves = generatePseudolegalMoves(board, color)
    var validMoves: seq[Move] = @[]
    for move in moves:
        if onlyCaptures and not isCapture(board, move):
            continue
        let captured = playMove(board, move)
        if not isChecked(board, color):
          validMoves.add(move)
        undoMove(board, move, captured)
    return validMoves

proc isChecked *(board: Board, color: PieceColor): bool =
    let attacker = !color
    let kingPosition = findKing(board, color)
    var attackerMoves = generatePseudolegalMoves(board, attacker)
    attackerMoves = attackerMoves.filterIt(isCapture(board, it))
    # if any valid move targets the king
    return attackerMoves.anyIt(it.target == kingPosition)

proc isCheckmated *(board: var Board, color: PieceColor): bool {.inline.} =
    let availableMoves = generateMoves(board, color)
    return isChecked(board, color) and len(availableMoves) == 0

proc isStalemated *(board: var Board, color: PieceColor): bool {.inline.}  =
    let availableMoves = generateMoves(board, color)
    return not isChecked(board, color) and len(availableMoves) == 0

proc evaluateDeep *(board: var Board, color: PieceColor, depth: uint): int =
    if depth == 0:
        return evaluate(board)
    else:
        let availableMoves = generateMoves(board, color)
        if len(availableMoves) == 0:
            if isChecked(board, color): # checkmate
                return sign(color) * int(int16.low)
            else: # draw
                return 0
        var bestScore = int(int16.low)
        for move in availableMoves:
            let captured = playMove(board, move)
            let score = sign(color) * evaluateDeep(board, !color, depth - 1)
            undoMove(board, move, captured)
            if score > bestScore:
                bestScore = score
        return sign(color) * bestScore

proc search *(board: var Board, color: PieceColor, depth: uint8): Move =
    let availableMoves = generateMoves(board, color)
    var bestScore = int(int16.low)
    # always maximize bestScore
    var bestMove: Move
    for move in availableMoves:
        let captured = playMove(board, move)
        var score = sign(color) * evaluateDeep(board, !color, depth)
        undoMove(board, move, captured)
        if score > bestScore:
            bestScore = score
            bestMove = move
    return bestMove

proc score (move: Move, board: Board): int =
    var value = 0
    # prioritize high-value captures
    if type(board[move.target]) != PieceType.none:
        value = pieceValues[type(board[move.target])] - pieceValues[type(board[move.source])]
    return value

proc evaluateAB *(board: var Board, color: PieceColor, depth: uint, alpha: int, beta: int): int =
    if depth == 0:
        return sign(color) * evaluate(board)
    else:
        var moves = generateMoves(board, color)
        if len(moves) == 0:
            if isChecked(board, color): # you are checkmated!
                return int(int16.low)
            else: # draw
                return 0
        
        # sort the moves according to heuristic score
        var move_to_score = initTable[Move, int]()
        for move in moves:
            move_to_score[move] = score(move, board)
        moves.sort(proc (m1, m2: Move): int = move_to_score.getOrDefault(m1, 0) - move_to_score.getOrDefault(m2, 0))
        
        var currAlpha = alpha
        for move in moves:
            let captured = playMove(board, move)
            var evaluation = -1 * evaluateAB(board, !color, depth - 1, -beta, -curr_alpha)
            undoMove(board, move, captured)
            if evaluation >= beta:
                return beta 
            currAlpha = max(currAlpha, evaluation)
        return currAlpha

proc searchAB *(board: var Board, color: PieceColor, depth: uint8): Move =
    let availableMoves = generateMoves(board, color)
    var bestScore = int(int16.low)
    var bestMove: Move
    # always maximize bestScore
    for move in availableMoves:
        let captured = playMove(board, move)
        var score = -1 * evaluateAB(board, !color, depth, int(int16.low), int(int16.high))
        undoMove(board, move, captured)
        if score > bestScore:
            bestScore = score
            bestMove = move
    return bestMove
