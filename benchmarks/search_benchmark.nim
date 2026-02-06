import std/times
import std/strformat
import std/strutils
import std/sequtils

import ../src/nim_chesspkg/game
import ../src/nim_chesspkg/move

type
  SearchBenchmarkResult = object
    name: string
    fen: string
    depth: uint8
    nodes: int
    timeMs: float
    nps: float
    bestMove: string
    score: int

proc formatNumber(n: int): string =
  ## Format number with comma separators
  let s = $n
  var result = ""
  var count = 0
  for i in countdown(s.len - 1, 0):
    if count > 0 and count mod 3 == 0:
      result = "," & result
    result = s[i] & result
    count += 1
  return result

proc formatNPS(nps: float): string =
  ## Format NPS with K/M suffix
  if nps >= 1_000_000:
    return fmt"{nps / 1_000_000:.2f}M"
  elif nps >= 1_000:
    return fmt"{nps / 1_000:.2f}K"
  else:
    return fmt"{nps:.0f}"

proc runSearchBenchmark(name: string, fen: string, depth: uint8): SearchBenchmarkResult =
  ## Run a single search benchmark and return results
  echo fmt"Running: {name} (depth {depth})..."

  var g = game.fromFen(fen)
  let startTime = cpuTime()
  let result = searchAB(g, depth)
  let endTime = cpuTime()

  let timeMs = (endTime - startTime) * 1000.0
  let nps = if timeMs > 0: (result.nodes.float / timeMs) * 1000.0 else: 0.0

  let benchResult = SearchBenchmarkResult(
    name: name,
    fen: fen,
    depth: depth,
    nodes: result.nodes,
    timeMs: timeMs,
    nps: nps,
    bestMove: $(result.bestMove),
    score: result.score
  )

  echo fmt"  Nodes: {formatNumber(result.nodes)}, Time: {timeMs:.0f}ms, NPS: {formatNPS(nps)}, Move: {result.bestMove}, Score: {result.score}"
  echo ""

  return benchResult

proc printSummary(results: seq[SearchBenchmarkResult]) =
  ## Print formatted summary table
  echo "=" .repeat(90)
  echo "SEARCH BENCHMARK SUMMARY"
  echo "=" .repeat(90)
  echo ""

  # Print table header
  echo "Position             Depth   Nodes                  Time        NPS      Best Move  Score"
  echo "-" .repeat(90)

  # Print each result
  for r in results:
    echo fmt"{r.name:<20} {r.depth:<7} {formatNumber(r.nodes):>15} {r.timeMs / 1000:>9.2f}s {formatNPS(r.nps):>10} {r.bestMove:>10} {r.score:>6}"

  echo "-" .repeat(90)

  # Calculate totals
  let totalNodes = results.mapIt(it.nodes).foldl(a + b, 0)
  let totalTime = results.mapIt(it.timeMs).foldl(a + b, 0.0)
  let avgNPS = if totalTime > 0: (totalNodes.float / totalTime) * 1000.0 else: 0.0

  let totalName = "TOTAL".alignLeft(20)
  let spaces = " ".repeat(7)
  let nodesStr = formatNumber(totalNodes).align(15)
  let timeStr = fmt"{totalTime / 1000:.2f}s".align(10)
  let npsStr = formatNPS(avgNPS).align(10)
  echo totalName & " " & spaces & " " & nodesStr & " " & timeStr & " " & npsStr
  echo ""

proc generateMarkdownTable(results: seq[SearchBenchmarkResult]): string =
  ## Generate markdown table for results.md
  result = "| Position | Depth | Nodes | Time (s) | NPS | Best Move | Score |" & "\n"
  result &= "|----------|-------|-------|----------|-----|-----------|-------|" & "\n"

  for r in results:
    result &= fmt"| {r.name} | {r.depth} | {formatNumber(r.nodes)} | {r.timeMs / 1000:.2f} | {formatNPS(r.nps)} | {r.bestMove} | {r.score} |" & "\n"

  # Add totals
  let totalNodes = results.mapIt(it.nodes).foldl(a + b, 0)
  let totalTime = results.mapIt(it.timeMs).foldl(a + b, 0.0)
  let avgNPS = if totalTime > 0: (totalNodes.float / totalTime) * 1000.0 else: 0.0

  result &= fmt"| **TOTAL** | | **{formatNumber(totalNodes)}** | **{totalTime / 1000:.2f}** | **{formatNPS(avgNPS)}** | | |" & "\n"

when isMainModule:
  echo "Chess Engine Search Benchmark"
  echo "=============================="
  echo ""

  var results: seq[SearchBenchmarkResult] = @[]

  # Mate-in-1: Fast tactical solve
  results.add(runSearchBenchmark(
    "Mate-in-1",
    "6qn/p5kp/PpQ2rp1/2n1NbP1/1PP2P1P/B1P1P3/8/7K w - - 1 44",
    5
  ))

  # Mate-in-2: Deeper tactical search
  results.add(runSearchBenchmark(
    "Mate-in-2",
    "r1b1kb1r/pppp1ppp/5q2/4n3/3KP3/2N3PN/PPP4P/R1BQ1B1R b kq - 0 1",
    5
  ))

  # Initial Position: High branching opening
  results.add(runSearchBenchmark(
    "Initial Position",
    "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
    5
  ))

  # Kiwipete: Complex middlegame
  results.add(runSearchBenchmark(
    "Kiwipete (depth 2)",
    "r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - 0 1",
    2
  ))

  # Endgame: Simple endgame
  results.add(runSearchBenchmark(
    "Endgame",
    "8/2p5/3p4/KP5r/1R3p1k/8/4P1P1/8 w - - 0 1",
    5
  ))

  # Random opening
  results.add(runSearchBenchmark(
    "Complex Opening",
    "rnbqk2r/1p3ppp/p2b1n2/P1p1p3/2Pp4/1P1P4/4PPPP/RNBQKBNR w KQkq - 1 8",
    5
  ))

  # Print summary
  printSummary(results)

  # Output markdown table for results.md
  echo "MARKDOWN OUTPUT FOR results.md:"
  echo "=" .repeat(90)
  echo generateMarkdownTable(results)
