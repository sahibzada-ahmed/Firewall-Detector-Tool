#!/bin/bash

# Function to generate random colors
random_color() {
  echo -e "\033[1;$(($RANDOM % 7 + 31))m$1\033[0m"
}

# Function to install a package if not installed
install_if_missing() {
  if ! command -v $1 &> /dev/null
  then
    echo "$(random_color 'Installing missing package: $1')"
    pkg install -y $1
  fi
}

# Install required packages if missing
install_if_missing bc
install_if_missing curl

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

# Define a reasonable threshold for throttling detection
speed_threshold=2.0

if (( $(echo "$speed < $speed_threshold" | bc -l) )); then
  echo "$(random_color 'Your internet speed seems to be very low (Less than 2 Mbps). This could indicate throttling by a firewall.')"
  echo "$(random_color 'Skipping website access tests due to slow internet speed.')"
  echo "$(random_color 'Firewall may be slowing down your internet speed.')"
else
  echo "$(random_color 'Internet speed is normal: '$speed' Mbps')"

  # Set timeout based on speed
  if (( $(echo "$speed < 5.0" | bc -l) )); then
    timeout=10
  elif (( $(echo "$speed < 10.0" | bc -l) )); then
    timeout=5
  else
    timeout=3
  fi

  echo "$(random_color 'Checking access to common websites...')"
  blocked_sites=()
  for site in "${websites[@]}"
  do
    if ! curl -s --max-time $timeout --head "$site" | head -n 1 | grep "HTTP/[1-2].[0-9] [23].." > /dev/null
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
fi

echo "$(random_color 'Analysis Complete.')"
