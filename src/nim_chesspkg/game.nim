import strutils

import piece
import board
import move

type
    Game* = tuple
        board: Board
        turn: PieceColor
        halfmove_clock: int
        fullmove_number: int

proc fromFen *(fen: string): Game =
    var parts = fen.split(" ")
    if len(parts) != 6:
        raise newException(ValueError, "Invalid FEM")

    # piece placement
    var game_board = board.from_fem_piece_placement(parts[0])

    # active color
    var turn = if parts[1] == "w": PieceColor.white else: PieceColor.black

    # TODO: castling
    # TODO: enpassant

    var halfmove_clock = parseInt(parts[4])
    var fullmove_number = parseInt(parts[5])

    return (game_board, turn, halfmove_clock, fullmove_number)

type Move* = tuple
    piece: Piece
    source: Position
    target: Position

proc `$` *(move: Move): string =
    return $move.piece & "-" & move.source.repr() & "-" & move.target.repr()

const FRONT = -board.BOARD_WIDTH
const BACK = -FRONT
const LEFT = -1
const RIGHT = -LEFT

proc isPinned(board: Board, position: Position): bool =
    return false

proc generate_moves *(game: Game): seq[Move] =
    var moves: seq[Move] = @[]
    for position, piece in game.board:
        if type(piece) == PieceType.none:
            continue
        if color(piece) != game.turn:
            continue

        if isPinned(game.board, position):
            continue

        var DIRECTION = 1
        if color(piece) == PieceColor.black:
            # if black, movement is reversed for pawns
            DIRECTION = -1

        if type(piece) == PieceType.pawn:
            let singlePawnMovement = FRONT*DIRECTION
            # TODO add boundary check

            if type(game.board[position+singlePawnMovement]) != PieceType.none:
                continue
            moves.add((piece, position, position+singlePawnMovement))

            # only for pawn on 2nd and 2nd-last row
            if (color(piece) == PieceColor.white and row(position) ==
                    board.BOARD_WIDTH - 2) or (color(piece) ==
                    PieceColor.black and row(position) == 1):
                let doublePawnMovement = 2*FRONT*DIRECTION
                if type(game.board[position+doublePawnMovement]) != PieceType.none:
                    continue
                moves.add((piece, position, position+doublePawnMovement))

        if type(piece) == PieceType.knight:
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
                if position+knightMovement < 0 or position+knightMovement >= len(game.board):
                    continue

                # take move
                if type(game.board[position+knightMovement]) != PieceType.none:
                    # can only take a different color
                    if color(piece) == color(game.board[position+knightMovement]):
                        continue

                # movement move
                moves.add((piece, position, position+knightMovement))


        if type(piece) == PieceType.rook:
            for movement in [FRONT, BACK, LEFT, RIGHT]:
                var times = 1
                while true:
                    let rookMovement = movement*times
                    if position+rookMovement < 0 or position+rookMovement >= len(game.board):
                        break

                    # take move
                    if type(game.board[position+rookMovement]) != PieceType.none:
                        # can only take a different color
                        if color(piece) == color(game.board[position+rookMovement]):
                            break
                        else:
                            # take and stop
                            moves.add((piece, position, position+rookMovement))
                            break

                    moves.add((piece, position, position+rookMovement))



    return moves
