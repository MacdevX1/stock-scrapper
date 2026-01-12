#!/usr/bin/env bash
# stock_now.sh
# Usage: ./stock_now.sh AAPL
# Defaults to AAPL if no symbol provided.
#
# Requirements:
#  - curl
#  - jq (install with `brew install jq` on macOS or `sudo apt install jq` on Debian/Ubuntu)

set -euo pipefail

SYMBOL="${1:-AAPL}"
# Yahoo Finance (no API key required)
URL="https://query1.finance.yahoo.com/v7/finance/quote?symbols=${SYMBOL}"

# Fetch JSON
json=$(curl -sSf "$URL") || { echo "Failed to fetch data for $SYMBOL"; exit 1; }

# Quick check: ensure jq exists
if ! command -v jq >/dev/null 2>&1; then
  echo "This script requires jq. Install it first (brew install jq or apt install jq)."
  exit 2
fi

# Extract fields (these keys are present in Yahoo's quote response)
price=$(echo "$json" | jq -r '.quoteResponse.result[0].regularMarketPrice')
change=$(echo "$json" | jq -r '.quoteResponse.result[0].regularMarketChange')
change_pct=$(echo "$json" | jq -r '.quoteResponse.result[0].regularMarketChangePercent')
time_epoch=$(echo "$json" | jq -r '.quoteResponse.result[0].regularMarketTime')
currency=$(echo "$json" | jq -r '.quoteResponse.result[0].currency')
longName=$(echo "$json" | jq -r '.quoteResponse.result[0].longName // .quoteResponse.result[0].shortName')

if [[ "$price" == "null" || "$time_epoch" == "null" ]]; then
  echo "No price/time data found for symbol: $SYMBOL"
  # optionally print raw JSON for debugging:
  # echo "$json" | jq
  exit 3
fi

# Convert epoch to human readable time (works on macOS and Linux)
convert_epoch() {
  local epoch="$1"
  if date --version >/dev/null 2>&1; then
    # GNU date (Linux)
    date -d "@${epoch}" '+%Y-%m-%d %H:%M:%S %Z'
  else
    # BSD date (macOS)
    date -r "${epoch}" '+%Y-%m-%d %H:%M:%S %Z'
  fi
}

readable_time=$(convert_epoch "$time_epoch")

# Print nicely
cat <<EOF
Symbol:       $SYMBOL
Name:         $longName
Price:        $price $currency
Change:       ${change} (${change_pct}%)
Quote Time:   $readable_time   (epoch: $time_epoch)
Source:       Yahoo Finance (query1.finance.yahoo.com)
EOF