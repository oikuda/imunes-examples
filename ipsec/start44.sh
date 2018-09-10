#! /bin/sh

. ../common/procedures.sh

if [ $# -eq 1 ]; then
    moon="moon@$1"
    sun="sun@$1"
else
    moon="moon"
    sun="sun"
fi

if isOSlinux; then
    DIR="/etc"
else
    DIR="/usr/local/etc"
fi

hcp moon44_ipsec.conf ${moon}:${DIR}/ipsec.conf
hcp sun44_ipsec.conf ${sun}:${DIR}/ipsec.conf

hcp -r moon/* ${moon}:${DIR}/
hcp -r sun/* ${sun}:${DIR}/

himage -nt $moon ipsec start 
himage -nt $sun ipsec start 

steps=50
for i in `seq 1 $steps`
do
    himage $moon ipsec statusall 2>&1 | grep ^[[:space:]]*net44-net44: >/dev/null
    er1=$?
    himage $sun ipsec statusall 2>&1 | grep ^[[:space:]]*net44-net44: >/dev/null
    er2=$?
    [ $er1 -eq 0 -a $er2 -eq 0 ] && himage $moon ipsec up net44-net44 && exit 0
    sleep 0.1
done

exit 1