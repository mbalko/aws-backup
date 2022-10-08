#!/bin/sh

if [ $# != 2 ]; then
  echo "Usage: $0 <file containing paths to folders which will be backed up> <s3:// url to bucket [and folder in it] without ending />"
  exit
fi

PATHS="$1"
DIR="$(dirname $0)"
BUCKET="$2"
STAMP=$(date +%Y-%m-%d)

CURR_DIR=$DIR/$STAMP

mkdir $DIR/$STAMP

cat $PATHS | while read line; do
  SERVICE=$(basename $line)
  echo "Creating zip for $SERVICE"
  zip "$CURR_DIR/${SERVICE}_$STAMP.zip" -r $line > /dev/null
done

echo "Uploading to $BUCKET:"
ls -lh $CURR_DIR
aws s3 cp $CURR_DIR $BUCKET/$STAMP/ --recursive --storage-class INTELLIGENT_TIERING
rm -rf $CURR_DIR
