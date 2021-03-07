import piece
import board

proc perft *(board: var Board, depth: uint, color: PieceColor = PieceColor.white): int =
    if depth == 0:
        return 1

    let availableMoves = generateMoves(board, color)
    var nodes = 0
    for move in availableMoves:
        var captured = playMove(board, move)
        nodes += perft(board, depth-1, !color)
        undoMove(board, move, captured)
    return nodes

proc dperft *(board: var Board, depth: uint, color: PieceColor = PieceColor.white): int =
    let availableMoves = generateMoves(board, color)
    var nodes = 0
    for move in availableMoves:
        var captured = playMove(board, move)
        var part_nodes = perft(board, depth-1, !color)
        undoMove(board, move, captured)
        echo $move & " " & $part_nodes 
        nodes += part_nodes
    echo ""
    echo $nodes
    return nodes