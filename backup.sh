#!/bin/bash

echo "starting pg_backup script"

if [ -z $PG_USER ]; then
    echo "missing PG_USER env"
    exit 22
fi

if [ -z $PG_PASSWORD ]; then
    echo "missing PG_PASSWORD env"
    exit 22
fi

if [ -z $PG_HOST ]; then
    echo "missing PG_HOST env"
    exit 22
fi

if [ -z $PG_PORT ]; then
    echo "missing PG_PORT env"
    exit 22
fi

if [ -z $PG_DB ]; then
    echo "missing PG_DB env"
    exit 22
fi

if [ -z $B2_APPLICATION_KEY_ID ]; then
    echo "missing B2_APPLICATION_KEY_ID env"
    exit 22
fi

if [ -z $B2_APPLICATION_KEY ]; then
    echo "missing B2_APPLICATION_KEY_ID env"
    exit 22
fi

if [ -z $B2_BUCKET ]; then
    echo "missing B2_BUCKET env"
    exit 22
fi

if [ -z $(which b2) ]; then
    echo "missing b2-tools"
    exit 22
fi

DB_NAMES=`PGPASSWORD=$PG_PASSWORD psql -U $PG_USER -p $PG_PORT -d $PG_DB -c "select datname from pg_database where datistemplate = false and datname <> 'postgres';" -h $PG_HOST -t`

echo "$DB_NAMES" | while IFS= read -r line ; do 
    BACKUPNAME=`echo $line.$(date +%F_%T).dmp`
    PGPASSWORD=$PG_PASSWORD pg_dump -p $PG_PORT -d $line -f $BACKUPNAME -h $PG_HOST -U $PG_USER -F c

    S3PATH=$line"/"$BACKUPNAME
    
    echo "uploading $BACKUPNAME"
    b2 file upload --no-progress $B2_BUCKET $BACKUPNAME $S3PATH > /dev/null
    echo "uploaded $BACKUPNAME"
    rm $BACKUPNAME
done