#!/bin/sh

PSQLCMD="psql -h $BANDWIDTH_DB_HOST -U $BANDWIDTH_DB_USER -d bandwidth -t -c"

FILES=$(find $IPFM_DIR -type f)
for f in $FILES; do
	
	FILEDATA=$(xxd -p "$f" | tr -d '\n')
	FILEDATE=$(date)
	FNAME=$(basename "$f")

	PARENTRECORDCHECK="SELECT id FROM files WHERE filename='"$FNAME"';"
	PARENTRECORDINSERT="INSERT INTO files (filename, uploaded, data) VALUES ('"$FNAME"', NOW(), decode('"$FILEDATA"', 'hex'));"
	
	ROWNUM=$($PSQLCMD "$PARENTRECORDCHECK")
	ROWNUM=$(echo $ROWNUM | xargs)

	test -n "$ROWNUM" && continue;
	ROWNUM=$($PSQLCMD "$PARENTRECORDINSERT")
	ROWNUM=$($PSQLCMD "$PARENTRECORDCHECK")
	ROWNUM=$(echo $ROWNUM | xargs)

	while read p; do

		if echo $p | grep -vq "#.*"; then

			SERVERNAME=$(echo $p | cut -d ' ' -f1)
			DOWNLOADED=$(echo $p | cut -d ' ' -f2)
			UPLOADED=$(echo $p | cut -d ' ' -f3)

			YEAR=$(echo $FNAME | cut -d '_' -f1)
			MONTH=$(echo $FNAME | cut -d '_' -f3)
			DAY=$(echo $FNAME | cut -d '_' -f2)
			TIMESTART=$(echo $FNAME | cut -d '_' -f4)

			SERVERCHECK="SELECT id FROM servers WHERE servername='"$SERVERNAME"';"
			SERVERNUM=$($PSQLCMD "$SERVERCHECK")
			SERVERNUM=$(echo $SERVERNUM | xargs)

			SERVERINSERT="INSERT INTO servers (servername, ip) VALUES ('"$SERVERNAME"', NULL);"; 
			test "$SERVERNUM" = "" && SERVERNUM=$($PSQLCMD "$SERVERINSERT"); SERVERNUM=$($PSQLCMD "$SERVERCHECK");
			SERVERNUM=$(echo $SERVERNUM | xargs)
		
			TIMESTAMP="$YEAR-$MONTH-$DAY $TIMESTART:00"
			ENTRYINSERT="INSERT INTO entries (server, uploaded, downloaded, file, time) VALUES ($SERVERNUM, $UPLOADED, $DOWNLOADED,"$ROWNUM", '"$TIMESTAMP"');"
			INSERT=$($PSQLCMD "$ENTRYINSERT")
		fi
	done < $f
done	
