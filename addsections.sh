#!/bin/bash


if [ "$1" = "" ] || [ "$2" = "" ]
then
    echo "Usage: $0 <xclbin prefix name> <output xclbin> <--dfx, --uuid UUID>"
    exit
fi

SECTIONS=BITSTREAM,BITSTREAM_PARTIAL_PDI,MEM_TOPOLOGY,IP_LAYOUT,CONNECTIVITY,BUILD_METADATA,EMBEDDED_METADATA,SYSTEM_METADATA,GROUP_CONNECTIVITY,GROUP_TOPOLOGY
BIN=$1
OUT_FILE=$2
CMD=xclbinutil
UUID=12345678-9012-3456-7890-123456789012

FLAGS="--force -o $OUT_FILE"

shift
shift

while test $# -gt 0; do
    case "$1" in
        
        -dfx|--dfx)
            echo "xclbin marked to be DFX enabled"
            FLAGS="--key-value SYS:dfx_enable:true $FLAGS"
            shift
        ;;
        -u|--uuid)
            echo "xclbin marked to include feature rom uuid (shell uuid)"
            
            shift
            if test $# -gt 0; then
                UUID=$1
                FLAGS="--key-value SYS:FeatureRomUUID:$UUID $FLAGS"
            else
                echo "no uuid specified"
                exit 1
            fi
            shift
        ;;
    esac
done

FLAGS="--target hw $FLAGS"

for i in ${SECTIONS//,/ }
do
    
    LOWER=$(echo "$i" | awk '{print tolower($0)}')
    case $i in
        
        BITSTREAM | BITSTREAM_PARTIAL_PDI)
            if [ -f "${BIN}_${LOWER}.bit" ]; then
                FLAGS=$(echo "--add-section ${i}:RAW:${BIN}_${LOWER}.bit $FLAGS")
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
