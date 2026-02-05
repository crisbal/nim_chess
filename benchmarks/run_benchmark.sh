#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}Chess Engine Performance Benchmark${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""

# Get system information
HOSTNAME=$(hostname)
OS=$(uname -s)
OS_VERSION=$(uname -r)
CPU=$(sysctl -n machdep.cpu.brand_string 2>/dev/null || lscpu | grep "Model name" | sed 's/Model name:\s*//' || echo "Unknown")
NIM_VERSION=$(nim --version | head -1)

echo "System Information:"
echo "  Host: $HOSTNAME"
echo "  OS: $OS $OS_VERSION"
echo "  CPU: $CPU"
echo "  Nim: $NIM_VERSION"
echo ""

# Compile benchmark
echo -e "${GREEN}Compiling benchmark (release mode)...${NC}"
cd "$(dirname "$0")"
nim c -d:release -o:perft_benchmark --hints:off --warnings:off perft_benchmark.nim

echo ""
echo -e "${GREEN}Running benchmarks...${NC}"
echo ""

# Run benchmark and capture output
./perft_benchmark > /tmp/bench_output.txt

# Display results
cat /tmp/bench_output.txt

# Extract markdown table from output
MARKDOWN_START=$(grep -n "MARKDOWN OUTPUT FOR results.md:" /tmp/bench_output.txt | cut -d: -f1)
if [ -n "$MARKDOWN_START" ]; then
  MARKDOWN_START=$((MARKDOWN_START + 2))  # Skip the header and separator line
  MARKDOWN_TABLE=$(tail -n +$MARKDOWN_START /tmp/bench_output.txt)

  # Append to results.md with timestamp
  TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

  echo "" >> results.md
  echo "### Benchmark Run: $TIMESTAMP" >> results.md
  echo "" >> results.md
  echo "**System:** $CPU" >> results.md
  echo "**OS:** $OS $OS_VERSION" >> results.md
  echo "**Nim:** $NIM_VERSION" >> results.md
  echo "" >> results.md
  echo "$MARKDOWN_TABLE" >> results.md

  echo ""
  echo -e "${GREEN}Results appended to benchmarks/results.md${NC}"
else
  echo "Warning: Could not extract markdown table from output"
fi

# Cleanup
rm -f /tmp/bench_output.txt

echo ""
echo -e "${GREEN}Benchmark complete!${NC}"
