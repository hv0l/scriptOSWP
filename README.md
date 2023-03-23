# scriptOSWP



I used this script to simplify my life with the oswp lab

## Features

- Automatically scans and selects target Wi-Fi networks
- Captures WPA/WPA2 handshakes
- Performs deauthentication attacks to obtain handshakes
- Cracks the captured handshakes using a provided wordlist

## Prerequisites

- A Linux-based operating system
- Aircrack-ng suite installed
- A network adapter compatible with monitor mode and packet injection
- A wordlist for password cracking

## Usage

1. Run the script with the required parameters:
`./wifi_crack.sh <interface> <wordlist>`

