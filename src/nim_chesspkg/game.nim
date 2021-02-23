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
