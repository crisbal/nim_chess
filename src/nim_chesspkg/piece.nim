import tables
import bitops

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

proc `$` *(piece: Piece): string =
    const piece_none_repr = "."
    const type_to_symbol_white = {
        PieceType.pawn: "♟︎",
        PieceType.knight: "♞",
        PieceType.bishop: "♝",
        PieceType.rook: "♜",
        PieceType.queen: "♛",
        PieceType.king: "♚",
    }.toTable
    const type_to_symbol_black = {
        PieceType.pawn: "♙",
        PieceType.knight: "♘",
        PieceType.bishop: "♗",
        PieceType.rook: "♖",
        PieceType.queen: "♕",
        PieceType.king: "♔",
    }.toTable
    var piece_type = piece.type()
    if piece_type == PieceType.none:
        return piece_none_repr
    else:
        if piece.color() == PieceColor.white:
            return type_to_symbol_white.getOrDefault(piece.type(), "?")
        else:
            return type_to_symbol_black.getOrDefault(piece.type(), "?")