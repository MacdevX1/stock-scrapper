#!/usr/bin/env bash

echo -n "Enter stock symbol (example: AAPL): "
read SYMBOL

API_KEY="YOUR_API_KEY_HERE"
URL="https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=${SYMBOL}&apikey=${API_KEY}"

# Fetch JSON
json=$(curl -s "$URL")

# Extract data using jq
price=$(echo "$json" | jq -r '.["Global Quote"]["05. price"]')
change=$(echo "$json" | jq -r '.["Global Quote"]["09. change"]')
change_pct=$(echo "$json" | jq -r '.["Global Quote"]["10. change percent"]')
local_time=$(date '+%Y-%m-%d %H:%M:%S')

# Check for valid response
if [[ "$price" == "null" || -z "$price" ]]; then
    echo "Failed to fetch data for $SYMBOL"
    exit 1
fi

echo "----------- Stock Info -----------"
echo "Symbol:       $SYMBOL"
echo "Price:        $price USD"
echo "Change:       $change"
echo "Change %:     $change_pct"
echo "Time:         $local_time"
echo "Source:       Alpha Vantage JSON API"
echo "----------------------------------"