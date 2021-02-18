# BandwidthMonitor
Shell Script to Store ipfm logs in database

## Install Script
cp BandwidthMonitor.sh /opt/bin/BandwidthMonitor.sh
chmod +x /opt/bin/BandwidthMonitor.sh

## Install ipfm
apt-get install ipfm
(or whatever your distribution's package manager)

## Setup ipfm with configuration
cp ipfm.conf /etc/ipfm.conf
(or just copy relavant config portion)

## Upload Database Schema

## Create pgpass file for postgresql logins from script

## Define Environmental Variables
They are added in the crontab line below, the environmental variables used by the script are
IPFM_DIR
BANDWIDTH_DB_HOST
BANDWIDTH_DB_USER

## Add Cronjob
5 * * * * IPFM_DIR=/var/log/ipfm/local/hourly BANDWIDTH_DB_HOST=host BANDWIDTH_DB_USER=user /opt/bin/BandwidthMonitor.sh
