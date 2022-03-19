#!/bin/bash

# Ping a specific port to determine its status and send a notification to slack
# if a problem is detected.

## Using nc
# sudo apt-get install netcat
# nc -vz <host|domain> <port_number>

## Using nmap
# sudo apt-get install nmap
# nmap -p <port_number> <ip_address|domain_name>

# Check whehter port number was passed in
if [ -z $1 ]; then
    echo "!!! Port number required. Usage: ./detect_helium_hostspot_issues <port_number>"
    exit
fi

if [ -z $SLACK_SERVER_KEY ]; then
  echo "!!! Environment variable, SLACK_SERVER_KEY, is not defined"
  exit
fi

# Reassign incomming variable for clarity
port=$1

# Get public ip
current_ip=$(curl ipinfo.io/ip)

# Detect OS and modify commands accordingly
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # Linux and rPi (linux-gnueabihf)
  cmd="nc -vz $current_ip $port"
  echo "*** Executing command:" $cmd

  pattern = "succeeded!"
  ping_result=`$cmd`
elif [[ "$OSTYPE" == "darwin"* ]]; then
  # MacOS
  cmd="nmap -p $port $current_ip"
  echo "*** Executing command:" $cmd

  pattern="open"
  ping_result=`$cmd`
else
  echo "!!!  Unrecognized OS. Not that I'm looking for many of them..."
  exit
fi

# If there is an issue, send a notification via Slack
if ! [[ ${ping_result} =~ ${pattern} ]]; then
  url="https://hooks.slack.com/services/$SLACK_SERVER_KEY"
  channel="servers"
  title="Helium miner alert!"
  message="Helium miner issue detected: $ping_result"

  status_code=$(/usr/local/bin/post_to_slack.sh -c "$channel" -t "$title" -b "$message" -u "$url")

  if [[ ${status_code} -eq 200 ]]; then
      echo "*** Posted successfully"
  else
      echo "!!! Error"
  fi
fi
