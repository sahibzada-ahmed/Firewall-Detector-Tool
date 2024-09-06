#!/bin/bash

# Function to generate random colors
random_color() {
  echo -e "\033[1;$(($RANDOM % 7 + 31))m$1\033[0m"
}

# Banner
clear
random_color "----------------------------------------------------"
random_color "            FIREWALL DETECTOR TOOL                 "
random_color "         Made by Cyber Vigilance PK and Faraz       "
random_color "----------------------------------------------------"

# List of websites/services that are commonly blocked
websites=(
  "www.google.com"
  "www.youtube.com"
  "www.facebook.com"
  "www.twitter.com"
  "www.reddit.com"
  "www.torproject.org"
  "www.whatsapp.com"
  "www.signal.org"
  "www.instagram.com"
  "www.bbc.com"
  "www.wikipedia.org"
)

# Internet Connectivity Check
echo "$(random_color 'Checking internet connectivity...')"
if ping -c 1 8.8.8.8 &> /dev/null
then
  echo "$(random_color 'Internet connection is active.')"
else
  echo "$(random_color 'No internet connection detected. Please check your connection and try again.')"
  exit 1
fi

# Speed Test (Checking for Throttling)
echo "$(random_color 'Checking internet speed (This may take a few seconds)...')"
speed=$(curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python - 2>/dev/null | grep "Download:" | awk '{print $2}')

if [ -z "$(command -v bc)" ]; then
    echo "$(random_color 'bc command not found. Please install bc package for accurate speed comparison.')"
elif (( $(echo "$speed < 2.0" | bc -l) )); then
  echo "$(random_color 'Your internet speed seems to be very low (Less than 2 Mbps). This could indicate throttling by a firewall.')"
else
  echo "$(random_color 'Internet speed is normal: '$speed' Mbps')"
fi

# Check access to listed websites
echo "$(random_color 'Checking access to common websites...')"
blocked_sites=()
for site in "${websites[@]}"
do
  if ! curl -s --head "$site" | head -n 1 | grep "HTTP/[1-2].[0-9] [23].." > /dev/null
  then
    echo "$(random_color 'Unable to access $site - Possible block detected.')"
    blocked_sites+=("$site")
  else
    echo "$(random_color '$site is accessible.')"
  fi
done

# Analyzing results
if [ ${#blocked_sites[@]} -eq 0 ]
then
  echo "$(random_color 'No blocks detected. Your connection seems unrestricted.')"
else
  echo "$(random_color 'Warning: The following sites are inaccessible:')"
  for blocked_site in "${blocked_sites[@]}"
  do
    echo "$(random_color '- $blocked_site')"
  done
  echo "$(random_color 'This may indicate the presence of a government firewall.')"
fi

echo "$(random_color 'Analysis Complete.')"
