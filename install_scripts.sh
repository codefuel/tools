#!/usr/bin/env bash

directory=$(pwd)

sudo ln -s "$directory/util/preload.sh" /usr/local/bin/preload.sh
sudo ln -s "$directory/util/detect_port_issue.sh" /usr/local/bin/detect_port_issue.sh

