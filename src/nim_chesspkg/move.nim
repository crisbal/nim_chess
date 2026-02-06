import ./board
import ./piece
import hashes

type
  MoveKind* = enum
    Quiet = 0
    DoublePawnPush = 1
    KingCastle = 2
    QueenCastle = 3
    Captures = 4
    EpCapture = 5
    KnightPromotion = 8
    BishopPromotion = 9
    RookPromotion = 10
    QueenPromotion = 11
    KnightPromoCapture = 12
    BishopPromoCapture = 13
    RookPromoCapture = 14
    QueenPromoCapture = 15

  Move* = distinct uint16

proc `==`*(a, b: Move): bool {.borrow.}
proc hash*(m: Move): Hash {.borrow.}

const
  SourceMask = 0x3F
  TargetMask = 0xFC0
  FlagMask = 0xF000

template source*(m: Move): Position = Position(uint16(m) and SourceMask)
template target*(m: Move): Position = Position((uint16(m) and TargetMask) shr 6)
template kind*(m: Move): MoveKind = MoveKind((uint16(m) and FlagMask) shr 12)

proc isCapture*(m: Move): bool {.inline.} =
  ## Returns true if this move is a capture (including en passant and promotion captures)
  let k = m.kind
  k == Captures or k == EpCapture or k >= KnightPromoCapture

proc newMove*(source, target: Position, kind: MoveKind = Quiet): Move =
  Move(uint16(source) or (uint16(target) shl 6) or (uint16(kind) shl 12))

proc moveFromLongAlgebric*(repr: string): Move =
  ## Parses a move in Long Algebraic Notation (LAN)
  ## Piece moves: <Piece symbol><from square>['-'|'x']<to square>
  ## Pawn moves:  <from square>['-'|'x']<to square>[<promoted to>]
  ## Piece symbol: 'N' | 'B' | 'R' | 'Q' | 'K'
  ## Examples: "Ne2-f4", "e2xe4", "e7-e8Q", "e2e4"

  var idx = 0
  let s = repr

  # Check for piece symbol (uppercase N, B, R, Q, K)
  if len(s) > 0 and s[idx] in {'N', 'B', 'R', 'Q', 'K'}:
    idx += 1

  # Parse from square (2 chars: file + rank)
  assert idx + 2 <= len(s), "Invalid LAN: missing from square"
  let fromSquare = positionFromAlgebric(s[idx .. idx + 1])
  idx += 2

  # Check for optional separator ('-' or 'x')
  var isCapture = false
  if idx < len(s) and s[idx] in {'-', 'x'}:
    isCapture = s[idx] == 'x'
    idx += 1

  # Parse to square (2 chars: file + rank)
  assert idx + 2 <= len(s), "Invalid LAN: missing to square"
  let toSquare = positionFromAlgebric(s[idx .. idx + 1])
  idx += 2

  # Check for optional promotion piece
  var kind: MoveKind = if isCapture: Captures else: Quiet
  if idx < len(s) and s[idx] in {'N', 'B', 'R', 'Q'}:
    let promoChar = s[idx]
    case promoChar
    of 'N':
      kind = if isCapture: KnightPromoCapture else: KnightPromotion
    of 'B':
      kind = if isCapture: BishopPromoCapture else: BishopPromotion
    of 'R':
      kind = if isCapture: RookPromoCapture else: RookPromotion
    of 'Q':
      kind = if isCapture: QueenPromoCapture else: QueenPromotion
    else:
      discard
    idx += 1

  return newMove(fromSquare, toSquare, kind)

proc `$`*(move: Move): string =
  result = board.toAlgebraic(move.source) & board.toAlgebraic(move.target)
  case move.kind
  of KnightPromotion, KnightPromoCapture:
    result.add('n')
  of BishopPromotion, BishopPromoCapture:
    result.add('b')
  of RookPromotion, RookPromoCapture:
    result.add('r')
  of QueenPromotion, QueenPromoCapture:
    result.add('q')
  else:
    discard

proc `$`*(moves: seq[Move]): string =
  var output = ""
  var attackBoard: array[BOARD_WIDTH * BOARD_HEIGHT, int]
  for move in moves:
    attackBoard[move.target] = 1
  for i in 0 .. attackBoard.high:
    if i > 0 and i mod BOARD_WIDTH == 0:
      output.add("\n")
    output.add(if attackBoard[i] == 1: 'x' else: '.')
  return output

proc isCapture*(board: Board, move: Move): bool {.inline.} =
  return type(board[move.target]) != PieceType.none
