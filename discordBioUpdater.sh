#!/bin/bash
incre=4
while [ $incre -lt $(wc -l bscript | awk '{print $1}') ]
do
bio=$(cat bscript | head -n$incre | tail -n4 | tr "\n" "X" | sed "s/X/\\\n/g")
incre=$(($incre+4))
curl 'https://discord.com/api/v9/users/@me' -X PATCH \
-H 'Content-Type: application/json' \
-H 'Authorization: mfa.INSERT YOUR mfa TOKEN HERE(see README for a how to get it)' \
-H 'TE: Trailers' --data-raw "{\"bio\":\"$bio\"}" > /dev/null
sleep 15
done

#have the entire Bee Movie script in a file named "bscript"
