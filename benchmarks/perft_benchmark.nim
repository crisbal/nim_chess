import std/times
import std/strformat
import std/strutils
import std/sequtils

import ../src/nim_chesspkg/game
import ../src/nim_chesspkg/utils

type
  BenchmarkResult = object
    name: string
    fen: string
    depth: uint
    nodes: int
    timeMs: float
    nps: float

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

proc runBenchmark(name: string, fen: string, depth: uint): BenchmarkResult =
  ## Run a single perft benchmark and return results
  echo fmt"Running: {name} (depth {depth})..."

  var g = game.fromFen(fen)
  let startTime = cpuTime()
  let nodes = perft(g, depth)
  let endTime = cpuTime()

  let timeMs = (endTime - startTime) * 1000.0
  let nps = if timeMs > 0: (nodes.float / timeMs) * 1000.0 else: 0.0

  result = BenchmarkResult(
    name: name,
    fen: fen,
    depth: depth,
    nodes: nodes,
    timeMs: timeMs,
    nps: nps
  )

  echo fmt"  Nodes: {formatNumber(nodes)}, Time: {timeMs:.0f}ms, NPS: {formatNPS(nps)}"
  echo ""

proc printSummary(results: seq[BenchmarkResult]) =
  ## Print formatted summary table
  echo "=" .repeat(80)
  echo "BENCHMARK SUMMARY"
  echo "=" .repeat(80)
  echo ""

  # Print table header
  echo "Position             Depth   Nodes                  Time        NPS"
  echo "-" .repeat(80)

  # Print each result
  for r in results:
    echo fmt"{r.name:<20} {r.depth:<7} {formatNumber(r.nodes):>15} {r.timeMs / 1000:>9.2f}s {formatNPS(r.nps):>12}"

  echo "-" .repeat(80)

  # Calculate totals
  let totalNodes = results.mapIt(it.nodes).foldl(a + b, 0)
  let totalTime = results.mapIt(it.timeMs).foldl(a + b, 0.0)
  let avgNPS = if totalTime > 0: (totalNodes.float / totalTime) * 1000.0 else: 0.0

  let totalName = "TOTAL".alignLeft(20)
  let spaces = " ".repeat(7)
  let nodesStr = formatNumber(totalNodes).align(15)
  let timeStr = fmt"{totalTime / 1000:.2f}s".align(10)
  let npsStr = formatNPS(avgNPS).align(12)
  echo totalName & " " & spaces & " " & nodesStr & " " & timeStr & " " & npsStr
  echo ""

proc generateMarkdownTable(results: seq[BenchmarkResult]): string =
  ## Generate markdown table for results.md
  result = "| Position | Depth | Nodes | Time (s) | NPS |" & "\n"
  result &= "|----------|-------|-------|----------|-----|" & "\n"

  for r in results:
    result &= fmt"| {r.name} | {r.depth} | {formatNumber(r.nodes)} | {r.timeMs / 1000:.2f} | {formatNPS(r.nps)} |" & "\n"

  # Add totals
  let totalNodes = results.mapIt(it.nodes).foldl(a + b, 0)
  let totalTime = results.mapIt(it.timeMs).foldl(a + b, 0.0)
  let avgNPS = if totalTime > 0: (totalNodes.float / totalTime) * 1000.0 else: 0.0

  result &= fmt"| **TOTAL** | | **{formatNumber(totalNodes)}** | **{totalTime / 1000:.2f}** | **{formatNPS(avgNPS)}** |" & "\n"

when isMainModule:
  echo "Chess Engine Performance Benchmark"
  echo "===================================="
  echo ""

  var results: seq[BenchmarkResult] = @[]

  # Standard benchmark positions
  results.add(runBenchmark(
    "Initial Position",
    "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
    5
  ))

  results.add(runBenchmark(
    "Kiwipete",
    "r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - 0 1",
    5
  ))

  results.add(runBenchmark(
    "Position 3",
    "8/2p5/3p4/KP5r/1R3p1k/8/4P1P1/8 w - - 0 1",
    5
  ))

  results.add(runBenchmark(
    "Position 4",
    "r3k2r/Pppp1ppp/1b3nbN/nP6/BBP1P3/q4N2/Pp1P2PP/R2Q1RK1 w kq - 0 1",
    5
  ))

  results.add(runBenchmark(
    "Position 5",
    "rnbq1k1r/pp1Pbppp/2p5/8/2B5/8/PPP1NnPP/RNBQK2R w KQ - 1 8",
    5
  ))

  # Print summary
  printSummary(results)

  # Output markdown table for results.md
  echo "MARKDOWN OUTPUT FOR results.md:"
  echo "=" .repeat(80)
  echo generateMarkdownTable(results)
