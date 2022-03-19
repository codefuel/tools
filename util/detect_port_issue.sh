#!/bin/bash

# detect_port_issue.sh
# Usage: ./detect_port_issue <port_number>

# Ping a specific port to determine its status and send a notification to slack
# if a problem is detected.

## Using nc
# sudo apt-get install netcat
# nc -vz <host|domain> <port_number>

## Using nmap
# sudo apt-get install nmap
# nmap -p <port_number> <ip_address|domain_name>

function usage {
    programName=$0
    echo "Description: use this program to post messages to Slack channel"
    echo "Usage: $programName [-t \"sample title\"] [-b \"message body\"] [-c \"mychannel\"] [-u \"slack url\"]"
    echo "    -t    the title of the message you are posting"
    echo "    -m    The message body"
    echo "    -c    The channel you are posting to"
    echo "    -p    Port number"
    exit 1
}

while getopts ":t:m:c:p:h" opt; do
  case ${opt} in
    t) title="$OPTARG"
    ;;
    m) message="$OPTARG"
    ;;
    c) channel="$OPTARG"
    ;;
    p) port="$OPTARG"
    ;;
    h) usage
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

# Check whehter port number was passed in
if [[ -z $port || -z $message || -z $channel || -z $title ]]; then
    echo "!!! Port, message, channel, and title are required. Usage: ./detect_port_issue <port_number>"
    exit
fi

if [ -z $SLACK_SERVER_KEY ]; then
  echo "!!! Environment variable, SLACK_SERVER_KEY, is not defined"
  exit
fi

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
  channel=$channel
  title=$title
  message="$message: $ping_result"

  status_code=$(/usr/local/bin/post_to_slack.sh -c "$channel" -t "$title" -b "$message" -u "$url")

  if [[ ${status_code} -eq 200 ]]; then
      echo "*** Posted successfully"
  else
      echo "!!! Error"
  fi
fi
