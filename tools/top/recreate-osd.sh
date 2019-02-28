#! /bin/bash

INITSTATE=`ceph health`
FORCEMODE=0;
VERBOSE=0
BLUESTORE=0;

while [[ $# -gt 0 ]]
do
    key="$1"

    case "$key" in
        -f) 
        shift; 
        FORCEMODE=1;
        ;;

        -v)
        shift;
        VERBOSE=1;   
        ;; 

        --db)
        DBD=$2  
        shift;
        shift;
        ;;

        --osd)
        OSD=$2
        shift;
        shift;
        ;;

        --dev)
        DEV=$2
        shift;
        shift;
        ;;

        *)
        shift;
        ;;
    esac
done

function draw(){
    if [[ $VERBOSE -eq 1 ]];
    then 
        echo ${1}
    fi
}


if [[ -z $OSD ]];
then
    draw "no OSD provided"
    exit
fi

draw "Checking ceph health"
draw $INITSTATE


if [[ `echo $INITSTATE | grep -q "HEALTH_OK"` -eq 0 ]]; 
then
    if [[ $FORCEMODE -eq 0 ]];
    then
        draw "Ceph is unhealthy, aborting"
        exit
    else
        draw "Ceph is unhealthy"
    fi
else
    draw "Ceph is healthy"
fi


echo "ceph-volume lvm zap $DEV"
echo "ceph osd destroy $OSD"

if [[ -z $DBD ]];
then 
    echo "ceph-volume lvm create --osd-id $OSD --data $DEV"
else
    echo "ceph-volume lvm create --osd-id $OSD --data $DEV --block.db $DBD"
fi


## TODO
#
# Auto discover osd to be replaced (grep on ceph osd tree down to find down osd on the host)
# Auto find if 2-disk OSDs are used
# Auto find unused journal partition and adapt ceph-volume lvm create accordingly

 
