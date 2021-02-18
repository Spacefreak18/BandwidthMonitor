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
pg_restore -U $BANDWIDTH_DB_USER -h $BANDWIDTH_DB_HOST -d bandwidth bandwidth_db.sql

## Create pgpass file for postgresql logins from script

## Define Environmental Variables
They are added in the crontab line below, the environmental variables used by the script are
IPFM_DIR
BANDWIDTH_DB_HOST
BANDWIDTH_DB_USER

## Add Cronjob
5 * * * * IPFM_DIR=/var/log/ipfm/local/hourly BANDWIDTH_DB_HOST=host BANDWIDTH_DB_USER=user /opt/bin/BandwidthMonitor.sh

## Get Month's Bandwidth Summary Per Server in Megabytes
SELECT servers.servername As Server, SUM(entries.downloaded)/1000000 As Down, SUM(entries.uploaded)/1000000 As Up FROM entries JOIN servers ON entries.server=servers.id WHERE time>='2021-02-01' AND time<'2021-03-01' GROUP BY servers.servername ORDER BY down DESC 

## Retrieve original ipfm hourly dump plain file from database
psql -U $BANDWIDTH_DB_USER -d bandwidth -h $BANDWIDTH_DB_HOST -W -c "SELECT encode(data, 'hex') FORM files WHERE id=1" > ./ipfm.log; xxd -p -r ./ipfm.log
