import strutils
import sequtils
import tables

import piece


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

proc from_fem_piece_placement *(piece_placement: string): Board =
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
