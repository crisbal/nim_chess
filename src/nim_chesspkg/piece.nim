import tables
import bitops
import strutils

type Piece* = uint8

type PieceType* {.size: sizeof(Piece), pure.} = enum
    none=0, pawn=1, knight=2, bishop=3, rook=4, queen=5, king=6

type PieceColor* {.size: sizeof(Piece), pure.} = enum
    none=0, black=8, white=16

proc piece *(piece_type: PieceType, piece_color: PieceColor): Piece {.inline.} =
    Piece(bitor(ord(piece_type), ord(piece_color)))

proc type *(piece: Piece): PieceType {.inline.} =
    PieceType(bitand(piece, 7)) # last 3 bits

proc color *(piece: Piece): PieceColor {.inline.} =
    PieceColor(bitand(piece, 24)) # upper 2 bits

proc sign *(color: PieceColor): int8 {.inline.} =
    return if color == PieceColor.white: 1 else: -1

proc pieceToString *(piece: Piece): string =
    const piece_none_repr = "."
    const type_to_symbol_white = {
        PieceType.pawn: "P",
        PieceType.knight: "N",
        PieceType.bishop: "B",
        PieceType.rook: "R",
        PieceType.queen: "Q",
        PieceType.king: "K",
    }.toTable
    const type_to_symbol_black = {
        PieceType.pawn: "p",
        PieceType.knight: "n",
        PieceType.bishop: "b",
        PieceType.rook: "r",
        PieceType.queen: "q",
        PieceType.king: "k",
    }.toTable
    var piece_type = piece.type()
    if piece_type == PieceType.none:
        return piece_none_repr
    else:
        if piece.color() == PieceColor.white:
            return type_to_symbol_white.getOrDefault(piece.type(), "?")
        else:
            return type_to_symbol_black.getOrDefault(piece.type(), "?")

proc `!` *(pieceColor: PieceColor): PieceColor =
    if pieceColor == PieceColor.white:
        return PieceColor.black
    else:
        return PieceColor.white