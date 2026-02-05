import piece
import board
import game
import move

proc perft*(game: var Game, depth: uint): int =
  if depth == 0:
    return 1

  let availableMoves = generateMoves(game)
  var nodes = 0
  for move in availableMoves:
    var moveEffect = playMove(game, move)
    nodes += perft(game, depth - 1)
    undoMove(game, move, moveEffect)
  return nodes

proc divide*(game: var Game, depth: uint): int =
  ## Divide command - lists all moves and perft count for each
  ## Output format matches Stockfish's "go perft" command
  ## https://www.chessprogramming.org/Perft#Divide
  let availableMoves = generateMoves(game)
  var nodes = 0
  for move in availableMoves:
    var moveEffect = playMove(game, move)
    var moveNodes = perft(game, depth - 1)
    undoMove(game, move, moveEffect)
    echo $move & ": " & $moveNodes
    nodes += moveNodes
  echo ""
  echo "Nodes searched: " & $nodes
  return nodes
