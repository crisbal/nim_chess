import ./board 
import ./piece 

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

proc isCapture *(board: Board, move: Move): bool {.inline.} =
    return type(board[move.target]) != PieceType.none