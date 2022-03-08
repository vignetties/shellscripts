#!/bin/bash
#get server details from config file
source ./dsconfig.conf
#to empty mailcont file
> mailcont.txt
# inserting list of host in to file hostlist
/bin/sh  $clipath --connect --controller=$domain --user=$usname --password=$passwd "ls /host" > hostlist.txt
# removing dc from the file hostlist
echo "$(tail -n +2 hostlist.txt)" > hostlist.txt
#storing hc list in array
while read line
do
hslist+=("$line")
done < hostlist.txt
#taking hc count
count=$(cat hostlist.txt | wc -l)
hslistc=$((count - 1))
# inserting list of hc1 nodes in to file serverlist1
/bin/sh  $clipath --connect --controller=$domain --user=$usname --password=$passwd  --command='ls /host='${hslist[0]}'/server' > serverlist1.txt
# inserting list of hc2 nodes in to file serverlist2
/bin/sh  $clipath --connect --controller=$domain --user=$usname --password=$passwd  --command='ls /host='${hslist[1]}'/server' > serverlist2.txt
#storing node list in array
while read line
do
srlist1+=("$line")
done < serverlist1.txt
#taking node count
count=$(cat serverlist1.txt | wc -l)
srlist1c=$((count - 1))
#storing node list in array
while read line
do
srlist2+=("$line")
done < serverlist2.txt
#taking node count
count=$(cat serverlist2.txt | wc -l)
srlist2c=$((count - 1))
# inserting list of ds in to file dslist
/bin/sh  $clipath --connect --controller=$domain --user=$usname --password=$passwd  --command='ls /host='${hslist[0]}'/server='${srlist1[0]}'/subsystem=datasources/data-source' > dslist.txt
#storing ds list in array
while read line
do
dslist+=("$line")
done < dslist.txt
#taking ds count
count=$(cat dslist.txt | wc -l)
dslistc=$((count - 1))
#for loop of nodlist
for (( j=0;j<=srlist1c;j++ ))
do
#for loop of dslist
for (( i=0;i<=dslistc;i++ ))
do
ActiveCount=$( /bin/sh $clipath --connect --controller=$domain --user=$usname --password=$passwd --command='/host='${hslist[0]}'/server='${srlist1[j]}'/subsystem=datasources/data-source='${dslist[i]}'/statistics=pool:read-resource(include-runtime=true)' | sed -n '4p' | awk '{ print  $3 }' | grep -oP '"\K[^"\047]+(?=["\047])')
AvailableCount=$( /bin/sh $clipath --connect --controller=$domain --user=$usname --password=$passwd --command='/host='${hslist[0]}'/server='${srlist1[j]}'/subsystem=datasources/data-source='${dslist[i]}'/statistics=pool:read-resource(include-runtime=true)' | sed -n '5p' | awk '{ print  $3 }' | grep -oP '"\K[^"\047]+(?=["\047])')
#adding activecount with available count
TotalCount=$((ActiveCount + AvailableCount))
#calculating activecount percentage
Activepercen=$((200*$ActiveCount/$TotalCount % 2 + 100*$ActiveCount/$TotalCount))
#threshold value
threshold=65
#checking 
if [ "$Activepercen" -gt "$threshold" ]; then
echo $domain ${hslist[0]} ${srlist1[j]} ${dslist[i]} "  " ActiveCount=$ActiveCount " " AvailableCount=$AvailableCount  >> mailcont.txt
fi

done

done

exit

for (( j=0;j<=srlist2c;j++ ))
do

for (( i=0;i<=dslistc;i++ ))
do

ActiveCount=$( /bin/sh $clipath --connect --controller=$domain --user=$usname --password=$passwd --command='/host='${hslist[1]}'/server='${srlist2[j]}'/subsystem=datasources/data-source='${dslist[i]}'/statistics=pool:read-resource(include-runtime=true)' | sed -n '4p' | awk '{ print  $3 }' | grep -oP '"\K[^"\047]+(?=["\047])')
AvailableCount=$( /bin/sh $clipath --connect --controller=$domain --user=$usname --password=$passwd --command='/host='${hslist[1]}'/server='${srlist2[j]}'/subsystem=datasources/data-source='${dslist[i]}'/statistics=pool:read-resource(include-runtime=true)' | sed -n '5p' | awk '{ print  $3 }' | grep -oP '"\K[^"\047]+(?=["\047])')
TotalCount=$((ActiveCount + AvailableCount))
Activepercen=$((200*$ActiveCount/$TotalCount % 2 + 100*$ActiveCount/$TotalCount))
#threshold=$((TotalCount / 2))
threshold=65

if [ "$Activepercen" -gt "$threshold" ]; then
echo $domain ${hslist[1]} ${srlist2[j]} ${dslist[i]} "  " ActiveCount=$ActiveCount " "  AvailableCount=$AvailableCount  >> mailcont.txt
fi

done

done

if [ -s mailcont.txt ] ; then
mail -s "$(echo -e "DATA SOURCE ALERT in 10.10.10.245  console \nContent-Type: text/html")"  -r appsever@solartis.net  cloud_infra@solartis.com bus@solartis.com  <  mailcont.txt
fi
