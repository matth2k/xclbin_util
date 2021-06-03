#!/bin/bash


if [ "$1" = "" ] || [ "$2" = "" ]
then
  echo "Usage: $0 <xclbin prefix name> <output xclbin>"
  exit
fi


SECTIONS=BITSTREAM,MEM_TOPOLOGY,IP_LAYOUT,CONNECTIVITY,BUILD_METADATA,EMBEDDED_METADATA,SYSTEM_METADATA,GROUP_CONNECTIVITY,GROUP_TOPOLOGY
BIN=$1
CMD=xclbinutil
FLAGS="--force -o $2"

for i in ${SECTIONS//,/ }
do

    LOWER=$(echo "$i" | awk '{print tolower($0)}')
    case $i in

    BITSTREAM)
    if [ -f "${BIN}_bitstream.bit" ]; then
        FLAGS=$(echo "--add-section BITSTREAM:RAW:${BIN}_bitstream.bit $FLAGS")
    fi
    ;;

    MEM_TOPOLOGY | IP_LAYOUT | CONNECTIVITY | BUILD_METADATA | GROUP_CONNECTIVITY | GROUP_TOPOLOGY)
    if [ -f "${BIN}_${LOWER}.json" ]; then
        FLAGS=$(echo "--add-section ${i}:JSON:${BIN}_${LOWER}.json $FLAGS")
    fi
    ;;

    EMBEDDED_METADATA)
    if [ -f "${BIN}_${LOWER}.xml" ]; then
        FLAGS=$(echo "--add-section ${i}:RAW:${BIN}_${LOWER}.xml $FLAGS")
    fi
    ;;

    SYSTEM_METADATA)
    if [ -f "${BIN}_${LOWER}.json" ]; then
        FLAGS=$(echo "--add-section ${i}:RAW:${BIN}_${LOWER}.json $FLAGS")
    fi
    ;;

    *)
    echo "Skipping section '$i'"
    ;;
esac
done

echo "Running $CMD $FLAGS"
$CMD $FLAGS
