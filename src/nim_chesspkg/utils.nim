import piece
import board
import game

proc perft *(game: var Game, depth: uint): int =
    if depth == 0:
        return 1

    let availableMoves = generateMoves(game)
    var nodes = 0
    for move in availableMoves:
        var moveEffect = playMove(game, move)
        nodes += perft(game, depth-1)
        undoMove(game, move, moveEffect)
    return nodes

proc dperft *(game: var Game, depth: uint): int =
    let availableMoves = generateMoves(game)
    var nodes = 0
    for move in availableMoves:
        var moveEffect = playMove(game, move)
        var part_nodes = perft(game, depth-1)
        undoMove(game, move, moveEffect)
        echo $move & " " & $part_nodes 
        nodes += part_nodes
    echo ""
    echo $nodes
    return nodes