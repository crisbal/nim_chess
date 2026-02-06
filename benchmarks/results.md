# Performance Benchmark Results

This file tracks the performance of the chess engine over time.

## System Information

- **CPU**: (will be populated by benchmark script)
- **OS**: (will be populated by benchmark script)
- **Nim Version**: (will be populated by benchmark script)

## How to Read This File

### Perft Benchmarks

- **Position**: Test position name
- **Depth**: Perft search depth
- **Nodes**: Total positions evaluated
- **Time**: Execution time in seconds
- **NPS**: Nodes per second (higher is better)

### Search Benchmarks

- **Position**: Test position name
- **Depth**: Search depth (fixed at 5)
- **Nodes**: Total nodes searched (including quiescence)
- **Time**: Execution time in seconds
- **NPS**: Nodes per second (higher is better)
- **Best Move**: Move selected by engine
- **Score**: Evaluation in centipawns (positive = white advantage, 32767 = checkmate)


---

## Benchmark History

<!-- Benchmark results will be appended below with timestamps -->

### Benchmark Run: 2026-02-05 23:47:56

**System:** Apple M1 Pro
**OS:** Darwin 24.6.0
**Nim:** Nim Compiler Version 2.2.6 [MacOSX: arm64]

| Position | Depth | Nodes | Time (s) | NPS |
|----------|-------|-------|----------|-----|
| Initial Position | 5 | 4,865,609 | 0.57 | 8.48M |
| Kiwipete | 5 | 193,690,690 | 21.47 | 9.02M |
| Position 3 | 5 | 674,624 | 0.10 | 6.97M |
| Position 4 | 5 | 15,833,292 | 1.77 | 8.94M |
| Position 5 | 5 | 89,941,194 | 10.76 | 8.36M |
| **TOTAL** | | **305,005,409** | **34.67** | **8.80M** |

### Benchmark Run: 2026-02-06 08:39:27

**System:** Apple M1 Pro
**OS:** Darwin 24.6.0
**Nim:** Nim Compiler Version 2.2.6 [MacOSX: arm64]

| Position | Depth | Nodes | Time (s) | NPS |
|----------|-------|-------|----------|-----|
| Initial Position | 5 | 4,865,609 | 0.50 | 9.66M |
| Kiwipete | 5 | 193,690,690 | 19.69 | 9.84M |
| Position 3 | 5 | 674,624 | 0.08 | 8.09M |
| Position 4 | 5 | 15,833,292 | 1.62 | 9.80M |
| Position 5 | 5 | 89,941,194 | 9.90 | 9.09M |
| **TOTAL** | | **305,005,409** | **31.79** | **9.59M** |

### Benchmark Run: 2026-02-06 10:37:17

**System:** Apple M1 Pro
**OS:** Darwin 24.6.0
**Nim:** Nim Compiler Version 2.2.6 [MacOSX: arm64]

#### Perft Results

| Position | Depth | Nodes | Time (s) | NPS |
|----------|-------|-------|----------|-----|
| Initial Position | 5 | 4,865,609 | 0.50 | 9.75M |
| Kiwipete | 5 | 193,690,690 | 19.78 | 9.79M |
| Position 3 | 5 | 674,624 | 0.08 | 8.00M |
| Position 4 | 5 | 15,833,292 | 1.62 | 9.76M |
| Position 5 | 5 | 89,941,194 | 9.92 | 9.07M |
| **TOTAL** | | **305,005,409** | **31.90** | **9.56M** |

### Benchmark Run: 2026-02-06 10:44:40

**System:** Apple M1 Pro
**OS:** Darwin 24.6.0
**Nim:** Nim Compiler Version 2.2.6 [MacOSX: arm64]

#### Perft Results

| Position | Depth | Nodes | Time (s) | NPS |
|----------|-------|-------|----------|-----|
| Initial Position | 5 | 4,865,609 | 0.50 | 9.79M |
| Kiwipete | 5 | 193,690,690 | 19.84 | 9.76M |
| Position 3 | 5 | 674,624 | 0.08 | 8.04M |
| Position 4 | 5 | 15,833,292 | 1.63 | 9.72M |
| Position 5 | 5 | 89,941,194 | 9.89 | 9.09M |
| **TOTAL** | | **305,005,409** | **31.94** | **9.55M** |

#### Search Results

| Position | Depth | Nodes | Time (s) | NPS | Best Move | Score |
|----------|-------|-------|----------|-----|-----------|-------|
| Mate-in-1 | 5 | 47,073 | 0.11 | 423.99K | c6f6 | 32767 |
| Mate-in-2 | 5 | 410,379 | 0.95 | 432.46K | f8c5 | 32763 |
| Initial Position | 5 | 25,288 | 0.03 | 997.95K | a2a3 | 0 |
| Kiwipete (depth 2) | 2 | 21,437,991 | 47.19 | 454.26K | e2a6 | 50 |
| Endgame | 5 | 54,200 | 0.06 | 891.15K | b4f4 | 100 |
| Complex Opening | 5 | 765,039 | 1.62 | 472.86K | e2e3 | 0 |
| **TOTAL** | | **22,739,970** | **49.96** | **455.19K** | | |
