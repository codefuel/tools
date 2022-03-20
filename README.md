# tools

A set of tools and utility scripts.

## Install crons

Run ./install_cron.sh to install all crons in /cront to /etc/cron.d.

## Secrets

Store environment variables in /etc/.secrets that are required in order to run
scripts via a cron job. Remember to do `chmod 700 /etc/.secrets` so that root
is the only user that has access.

## Utility scripts

Located in the /utils directory. Some of these scripts will be executed on a
schedule defined in the cron files.
