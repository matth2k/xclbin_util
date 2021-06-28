#!/bin/bash


if [ "$1" = "" ]
then
  echo "Usage: $0 <xclbin>"
  exit
fi


BIN=${1%.xclbin}
CMD=xclbinutil
FLAGS="--force -i $BIN.xclbin"

echo "Printing xclbin info to ${BIN}_info.txt"
$CMD --info $FLAGS > ${BIN}_info.txt


SECTIONS=$(awk '/UUID \(xclbin\):/{flag=1;next}/=/{flag=0}flag' ${BIN}_info.txt)

for i in ${SECTIONS//,/ }
do

    LOWER=$(echo "$i" | awk '{print tolower($0)}')
    case $i in

    BITSTREAM)
    echo "Dumping bitstream to ${BIN}_bitstream.bit"
    $CMD --dump-section BITSTREAM:RAW:${BIN}_bitstream.bit $FLAGS > stdout.txt
    ;;

    MEM_TOPOLOGY | IP_LAYOUT | CONNECTIVITY | BUILD_METADATA | GROUP_CONNECTIVITY | GROUP_TOPOLOGY)
    echo "Dumping $LOWER to ${BIN}_${LOWER}.json"
    $CMD --dump-section ${i}:JSON:${BIN}_${LOWER}.json $FLAGS >> stdout.txt
    ;;

    EMBEDDED_METADATA)
    echo "Dumping $LOWER to ${BIN}_${LOWER}.xml"
    $CMD --dump-section ${i}:RAW:${BIN}_${LOWER}.xml $FLAGS >> stdout.txt
    ;;

    SYSTEM_METADATA)
    echo "Dumping $LOWER to ${BIN}_${LOWER}.json"
    $CMD --dump-section ${i}:RAW:${BIN}_${LOWER}.json $FLAGS >> stdout.txt
    ;;

    *)
    echo "Skipping section '$i'"
    ;;
esac
done
