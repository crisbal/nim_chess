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
            # movement is reversed for pawns
            DIRECTION = -1
        if type(piece) == PieceType.pawn:
            let singlePawnMovement = FRONT*DIRECTION
            var destination = position+singlePawnMovement
            if not (destination in game.board.low..game.board.high):
                continue

            if type(game.board[position+singlePawnMovement]) != PieceType.none:
                continue
            moves.add((piece, position, position+singlePawnMovement))

            # only for pawn on 2nd and 2nd-last row
            if (color(piece) == PieceColor.white and row(position) == board.BOARD_WIDTH - 2) or (color(piece) == PieceColor.black and row(position) == 1):
                let doublePawnMovement = 2*FRONT*DIRECTION
                var destination = position+doublePawnMovement
                # this will never happen, probably?
                if not (destination in game.board.low..game.board.high):
                    continue
                if type(game.board[position+doublePawnMovement]) != PieceType.none:
                    continue
                moves.add((piece, position, position+doublePawnMovement))

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
                if not (position+knightMovement in game.board.low..game.board.high):
                    continue
                
                if abs(column(position)-column(position+knightMovement)) > 2:
                    # make sure we don't jump from one side to the other
                    # this happens because of the board representation we have chosen
                    continue

                # take move
                if type(game.board[position+knightMovement]) != PieceType.none:
                    # can only take a different color
                    if color(piece) == color(game.board[position+knightMovement]):
                        continue

                # movement move
                moves.add((piece, position, position+knightMovement))

        elif type(piece) == PieceType.rook:
            for movement in [FRONT, BACK, LEFT, RIGHT]:
                # simulate sliding
                var slidingPosition = position
                while true:
                    var destination =  slidingPosition + movement

                    if not (destination in game.board.low..game.board.high):
                        break

                    if abs(column(slidingPosition)-column(destination)) > 1:
                        # make sure we don't move up a row based on left/right movement (aka wrap around)
                        # this happens because of the board representation we have chosen
                        break

                    # capture move?
                    if type(game.board[destination]) != PieceType.none:
                        # can only take a different color
                        if color(piece) == color(game.board[destination]):
                            break
                        else:
                            # take and stop
                            moves.add((piece, position, destination))
                            break

                    moves.add((piece, position, destination))
                    slidingPosition = destination
        
        elif type(piece) == PieceType.bishop:
            for movement in [FRONT+LEFT, FRONT+RIGHT, BACK+LEFT, BACK+RIGHT]:
                # simulate sliding
                var slidingPosition = position
                while true:
                    var destination =  slidingPosition + movement
                    if not (destination in game.board.low..game.board.high):
                        break
                    
                    if abs(column(slidingPosition)-column(destination)) > 1:
                        # make sure we don't move up a row based on left/right movement (aka wrap around)
                        # this happens because of the board representation we have chosen
                        break

                    # capture move?
                    if type(game.board[destination]) != PieceType.none:
                        # can only take a different color
                        if color(piece) == color(game.board[destination]):
                            break
                        else:
                            # take and stop
                            moves.add((piece, position, destination))
                            break

                    moves.add((piece, position, destination))
                    slidingPosition = destination


        elif type(piece) == PieceType.queen:
            for movement in [FRONT, BACK, LEFT, RIGHT, FRONT+LEFT, FRONT+RIGHT, BACK+LEFT, BACK+RIGHT]:
                var slidingPosition = position
                while true:
                    var destination =  slidingPosition + movement
                    if not (destination in game.board.low..game.board.high):
                        break
                    
                    if abs(column(slidingPosition)-column(destination)) > 1:
                        # make sure we don't move up a row based on left/right movement (aka wrap around)
                        # this happens because of the board representation we have chosen
                        break

                    # capture move?
                    if type(game.board[destination]) != PieceType.none:
                        # can only take a different color
                        if color(piece) == color(game.board[destination]):
                            break
                        else:
                            # take and stop
                            moves.add((piece, position, destination))
                            break

                    moves.add((piece, position, destination))
                    slidingPosition = destination

        elif type(piece) == PieceType.king:
            for movement in [FRONT, BACK, LEFT, RIGHT]:
                var destination = position+movement
                if not (destination in game.board.low..game.board.high):
                    break
                
                if abs(column(position)-column(destination)) > 1:
                    # make sure we don't move up a row based on left/right movement (aka wrap around)
                    # this happens because of the board representation we have chosen
                    break

                # take move
                if type(game.board[position+movement]) != PieceType.none:
                    # can only take a different color
                    if color(piece) == color(game.board[position+movement]):
                        continue
                    else:
                        moves.add((piece, position, position+movement))
                        continue

                moves.add((piece, position, position+movement))

    return moves
