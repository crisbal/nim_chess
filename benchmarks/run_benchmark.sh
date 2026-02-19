#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

BENCHMARK_TYPE=$1

if [ -z "$BENCHMARK_TYPE" ]; then
  BENCHMARK_TYPE="all"
fi

if [[ "$BENCHMARK_TYPE" != "all" && "$BENCHMARK_TYPE" != "perft" && "$BENCHMARK_TYPE" != "search" ]]; then
  echo "Usage: $0 [perft|search]"
  exit 1
fi

echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}Chess Engine Performance Benchmark${NC}"
echo -e "${BLUE}=====================================${NC}"
echo "Mode: $BENCHMARK_TYPE"
echo ""

# Get system information
HOSTNAME=$(hostname)
OS=$(uname -s)
OS_VERSION=$(uname -r)
CPU=$(sysctl -n machdep.cpu.brand_string 2>/dev/null || lscpu | grep "Model name" | sed 's/Model name:\s*//' || echo "Unknown")
NIM_VERSION=$(nim --version | head -1)

echo "System Information:"
echo "  OS: $OS $OS_VERSION"
echo "  CPU: $CPU"
echo "  Nim: $NIM_VERSION"
echo ""

cd "$(dirname "$0")"

# -----------------------------------------------------------------------------
# PERFT BENCHMARK
# -----------------------------------------------------------------------------
if [[ "$BENCHMARK_TYPE" == "all" || "$BENCHMARK_TYPE" == "perft" ]]; then
  echo -e "${GREEN}Compiling perft benchmark (release mode)...${NC}"
  nim c -d:release --hints:off --warnings:off perft_benchmark.nim

  echo ""
  echo -e "${GREEN}Running perft benchmarks...${NC}"
  echo ""

  # Run perft benchmark and capture output
  ./build/bin/perft_benchmark > /tmp/bench_output.txt

  # Display results
  cat /tmp/bench_output.txt

  # Extract markdown table from output
  MARKDOWN_START=$(grep -n "MARKDOWN OUTPUT FOR results.md:" /tmp/bench_output.txt | cut -d: -f1)
  if [ -n "$MARKDOWN_START" ]; then
    MARKDOWN_START=$((MARKDOWN_START + 2))  # Skip the header and separator line
    MARKDOWN_TABLE=$(tail -n +$MARKDOWN_START /tmp/bench_output.txt)

    # Append to results_perft.md with timestamp
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

    echo "" >> results_perft.md
    echo "### Benchmark Run: $TIMESTAMP" >> results_perft.md
    echo "" >> results_perft.md
    echo "**System:** $CPU" >> results_perft.md
    echo "**OS:** $OS $OS_VERSION" >> results_perft.md
    echo "**Nim:** $NIM_VERSION" >> results_perft.md
    echo "" >> results_perft.md
    echo "$MARKDOWN_TABLE" >> results_perft.md

    echo ""
    echo -e "${GREEN}Perft results appended to benchmarks/results_perft.md${NC}"
  else
    echo "Warning: Could not extract markdown table from perft output"
  fi

  # Cleanup
  rm -f /tmp/bench_output.txt
fi

# -----------------------------------------------------------------------------
# SEARCH BENCHMARK
# -----------------------------------------------------------------------------
if [[ "$BENCHMARK_TYPE" == "all" || "$BENCHMARK_TYPE" == "search" ]]; then
  echo -e "${GREEN}Compiling search benchmark (release mode)...${NC}"
  nim c -d:release --hints:off --warnings:off search_benchmark.nim

  echo ""
  echo -e "${GREEN}Running search benchmarks...${NC}"
  echo ""

  # Run search benchmark and capture output
  ./build/bin/search_benchmark > /tmp/search_bench_output.txt

  # Display results
  cat /tmp/search_bench_output.txt

  # Extract markdown table from output
  MARKDOWN_START=$(grep -n "MARKDOWN OUTPUT FOR results.md:" /tmp/search_bench_output.txt | cut -d: -f1)
  if [ -n "$MARKDOWN_START" ]; then
    MARKDOWN_START=$((MARKDOWN_START + 2))  # Skip the header and separator line
    MARKDOWN_TABLE=$(tail -n +$MARKDOWN_START /tmp/search_bench_output.txt)

    # Append to results_search.md (same timestamp as perft)
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    echo "" >> results_search.md
    echo "### Benchmark Run: $TIMESTAMP" >> results_search.md
    echo "" >> results_search.md
    echo "**System:** $CPU" >> results_search.md
    echo "**OS:** $OS $OS_VERSION" >> results_search.md
    echo "**Nim:** $NIM_VERSION" >> results_search.md
    echo "" >> results_search.md
    echo "$MARKDOWN_TABLE" >> results_search.md

    echo ""
    echo -e "${GREEN}Search results appended to benchmarks/results_search.md${NC}"
  else
    echo "Warning: Could not extract markdown table from search output"
  fi

  # Cleanup
  rm -f /tmp/search_bench_output.txt
fi

echo ""
echo -e "${GREEN}Benchmarks complete!${NC}"
