#!/bin/bash
#check dependisies
if ! command -v curl &> /dev/null; then echo "curl Not Installed"; exit 0; fi
if ! command -v jq &> /dev/null; then echo "jq Not Installed"; exit 0; fi
if ! command -v awk &> /dev/null; then echo " awk Not Installed"; exit 0; fi
if ! command -V grep &> /dev/null; then echo "grep Not Installed"; exit 0; fi
if ! command -v sed &> /dev/null; then echo "sed Not Installed"; exit 0; fi

#Setup variables
token="authorization: mfa."  #PUT YOUR MFA TOKEN HERE
copyfrom=$1 #Server ID you want to copy from
copyto=$2 #Server ID you want to copy to (You must have channel+roles creations+movement rights)

#CHANGE SERVERNAME AND SERVER ICON
servername=$(curl https://discord.com/api/v9/guilds/$copyfrom -H "$token" | jq | grep name | head -n1 | sed 's/"name": "\|",//g' | sed 's/^[ \t]*//')
wget https://cdn.discordapp.com/icons/$copyfrom/$(curl https://discord.com/api/v9/guilds/$copyfrom -H "$token" | jq | grep icon | head -n1 | sed 's/"icon": "\|",//g' | sed 's/^[ \t]*//') -O icon.png
base64icon=$(base64 -w 0 icon.png)
curl "https://discord.com/api/v9/guilds/$copyto" -X 'PATCH' -H "$token" -H 'content-type: application/json' --data-binary "{\"icon\":\"data:image/png;base64,$base64icon\",\"name\":\"$servername\"}"


#GRAB ROLES AND CHANNELS
curl "https://discord.com/api/v9/guilds/$copyfrom/channels" -H "$token" | jq | grep '{\|"name"\|"type"\|"topic"\|"bitrate"\|"user_limit"\|"rate_limit_per_user"\|"position"\|"nsfw"\|}' | sed 's/      .*//g' | sed '/^[[:space:]]*$/d' > tempfile-channels
curl "https://discord.com/api/v9/guilds/$copyfrom/roles" -H "$token" | jq | sed "s/\"id\":.*\|\]\|\[//g" | sed '/^[[:space:]]*$/d' > tempfile-roles


#CREATE CHANNELS
output=0
while read -r line
do
echo "${line//\},/\}}" >> channel-out$output
if [ "$line" = '},' ]
then
((output++))
fi
done < tempfile-channels

echo "Can't put Channales in categories as they use the category-id that is bound to the $copyfrom server--- and im too lazy to match category-id with their name and then apply the new id to them"

for channel in channel-out*
do
curl "https://discord.com/api/v9/guilds/$copyto/channels" \
  -H "$token" \
  -H 'content-type: application/json' \
  --data-binary @"$channel"
done


#CREATE ROLES
output=0
while read -r line
do
echo "${line//\},/\}}" >> role-out$output
if [ "$line" = '},' ]
then
((output++))
fi
done < tempfile-roles

echo "Can't apply permissions to Channels as they use the role-ID that is bound to the $copyfrom server--- and im too lazy to match role-ids with their name and then apply the new id to them"

for role in role-out*
do
curl "https://discord.com/api/v9/guilds/$copyto/roles" \
-X 'POST' \
-H "$token" \
-H 'content-type: application/json' \
--data-binary @"$role"
done




