# Search Benchmark Results

This file tracks the performance of the chess engine's search algorithm over time.

## System Information

- **CPU**: (will be populated by benchmark script)
- **OS**: (will be populated by benchmark script)
- **Nim Version**: (will be populated by benchmark script)

## How to Read This File

- **Position**: Test position name
- **Depth**: Search depth
- **Nodes**: Total nodes searched (including quiescence)
- **Time**: Execution time in seconds
- **NPS**: Nodes per second (higher is better)
- **Best Move**: Move selected by engine
- **Score**: Evaluation in centipawns (positive = white advantage, 32767 = checkmate)

---

## Benchmark History

<!-- Benchmark results will be appended below with timestamps -->

### Benchmark Run: 2026-02-06 10:44:40

**System:** Apple M1 Pro
**OS:** Darwin 24.6.0
**Nim:** Nim Compiler Version 2.2.6 [MacOSX: arm64]

| Position | Depth | Nodes | Time (s) | NPS | Best Move | Score |
|----------|-------|-------|----------|-----|-----------|-------|
| Mate-in-1 | 5 | 47,073 | 0.11 | 423.99K | c6f6 | 32767 |
| Mate-in-2 | 5 | 410,379 | 0.95 | 432.46K | f8c5 | 32763 |
| Initial Position | 5 | 25,288 | 0.03 | 997.95K | a2a3 | 0 |
| Kiwipete (depth 2) | 2 | 21,437,991 | 47.19 | 454.26K | e2a6 | 50 |
| Endgame | 5 | 54,200 | 0.06 | 891.15K | b4f4 | 100 |
| Complex Opening | 5 | 765,039 | 1.62 | 472.86K | e2e3 | 0 |
| **TOTAL** | | **22,739,970** | **49.96** | **455.19K** | | |

### Benchmark Run: 2026-02-06 11:19:18

**System:** Apple M1 Pro
**OS:** Darwin 24.6.0
**Nim:** Nim Compiler Version 2.2.6 [MacOSX: arm64]

| Position | Depth | Nodes | Time (s) | NPS | Best Move | Score |
|----------|-------|-------|----------|-----|-----------|-------|
| Mate-in-1 | 5 | 44,669 | 0.10 | 454.35K | c6f6 | 32767 |
| Mate-in-2 | 5 | 459,627 | 1.12 | 410.72K | f8c5 | 32763 |
| Initial Position | 5 | 15,890 | 0.02 | 985.00K | a2a3 | 0 |
| Kiwipete (depth 2) | 2 | 21,437,991 | 47.72 | 449.22K | e2a6 | 50 |
| Endgame | 5 | 44,055 | 0.05 | 853.83K | b4f4 | 100 |
| Complex Opening | 5 | 568,529 | 1.22 | 464.81K | e2e3 | 0 |
| **TOTAL** | | **22,570,761** | **50.23** | **449.34K** | | |

### Benchmark Run: 2026-02-06 11:22:32

**System:** Apple M1 Pro
**OS:** Darwin 24.6.0
**Nim:** Nim Compiler Version 2.2.6 [MacOSX: arm64]

| Position | Depth | Nodes | Time (s) | NPS | Best Move | Score |
|----------|-------|-------|----------|-----|-----------|-------|
| Mate-in-1 | 5 | 43,229 | 0.08 | 513.75K | c6f6 | 32767 |
| Mate-in-2 | 5 | 403,052 | 0.94 | 428.27K | f8c5 | 32763 |
| Initial Position | 5 | 20,951 | 0.02 | 1.18M | a2a3 | 0 |
| Kiwipete (depth 2) | 2 | 21,437,991 | 47.50 | 451.36K | e2a6 | 50 |
| Endgame | 5 | 40,442 | 0.05 | 862.01K | b4f4 | 100 |
| Complex Opening | 5 | 594,212 | 1.24 | 478.79K | e2e3 | 0 |
| **TOTAL** | | **22,539,877** | **49.83** | **452.36K** | | |

### Benchmark Run: 2026-02-06 11:24:25

**System:** Apple M1 Pro
**OS:** Darwin 24.6.0
**Nim:** Nim Compiler Version 2.2.6 [MacOSX: arm64]

| Position | Depth | Nodes | Time (s) | NPS | Best Move | Score |
|----------|-------|-------|----------|-----|-----------|-------|
| Mate-in-1 | 5 | 39,650 | 0.08 | 491.55K | c6f6 | 32767 |
| Mate-in-2 | 5 | 297,430 | 0.68 | 440.42K | f8c5 | 32763 |
| Initial Position | 5 | 12,510 | 0.01 | 1.16M | a2a3 | 0 |
| Kiwipete (depth 2) | 2 | 21,437,991 | 47.58 | 450.60K | e2a6 | 50 |
| Endgame | 5 | 48,864 | 0.05 | 926.12K | b4f4 | 100 |
| Complex Opening | 5 | 558,047 | 1.20 | 463.49K | e2e3 | 0 |
| **TOTAL** | | **22,394,492** | **49.60** | **451.50K** | | |

### Benchmark Run: 2026-02-06 11:30:21

**System:** Apple M1 Pro
**OS:** Darwin 24.6.0
**Nim:** Nim Compiler Version 2.2.6 [MacOSX: arm64]

| Position | Depth | Nodes | Time (s) | NPS | Best Move | Score |
|----------|-------|-------|----------|-----|-----------|-------|
| Mate-in-1 | 5 | 39,495 | 0.10 | 411.00K | c6f6 | 32767 |
| Mate-in-2 | 5 | 319,300 | 0.72 | 444.43K | f8c5 | 32763 |
| Initial Position | 5 | 12,510 | 0.01 | 1.15M | a2a3 | 0 |
| Kiwipete (depth 2) | 2 | 21,437,991 | 47.20 | 454.20K | e2a6 | 50 |
| Endgame | 5 | 48,886 | 0.05 | 947.48K | b4f4 | 100 |
| Complex Opening | 5 | 557,972 | 1.20 | 464.28K | e2e3 | 0 |
| **TOTAL** | | **22,416,154** | **49.28** | **454.89K** | | |

### Benchmark Run: 2026-02-06 11:36:02

**System:** Apple M1 Pro
**OS:** Darwin 24.6.0
**Nim:** Nim Compiler Version 2.2.6 [MacOSX: arm64]

| Position | Depth | Nodes | Time (s) | NPS | Best Move | Score |
|----------|-------|-------|----------|-----|-----------|-------|
| Mate-in-1 | 5 | 39,495 | 0.17 | 232.73K | c6f6 | 32767 |
| Mate-in-2 | 5 | 319,300 | 3.50 | 91.15K | f8c5 | 32763 |
| Initial Position | 5 | 12,510 | 0.03 | 415.06K | a2a3 | 0 |
| Kiwipete (depth 2) | 2 | 21,437,991 | 47.01 | 456.02K | e2a6 | 50 |
| Endgame | 5 | 48,886 | 0.35 | 137.97K | b4f4 | 100 |
| Complex Opening | 5 | 557,972 | 1.66 | 336.92K | e2e3 | 0 |
| **TOTAL** | | **22,416,154** | **52.72** | **425.16K** | | |
