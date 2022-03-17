#!/bin/bash
#echo "Hello from $SHELL"
#cd context2
#place="context2"
##find . -name pom.xml > pomfiles.txt
#cat pomfiles.txt
> pomfiles.txt
> commonpom.xml

ls *.xml > pomfiles.txt

while read line
do
pomfiles+=("$line")
done < pomfiles.txt

count=$(cat  pomfiles.txt | wc -l)
pomlistc=$((count - 1))
echo $pomlistc
#sed -n '/dependencies/, /dependencies/{ /dependencies/! { /dependencies/! p } }'
for (( c=0;c<=$pomlistc;c++ ))
do
  # echo "Welcome $c times"
sed -n '/<dependencies>/, /<\/dependencies>/{ /<dependencies>/! { /<\/dependencies>/! p } }' ${pomfiles[$c]} >> commonpom.xml
done

count1=$(cat commonpom.xml | grep \<dependency\> | wc -l)
#dcount=$((count1 - 1))
for (( i=1;i<=$count1;i++ ))
do
  # echo "Welcome $c times"
sed '/<dependency>/!d;x;s/^/x/;/x\{'$i'\}/!{x;d};x;:a;n;/<\/dependency>/!ba;q' commonpom.xml | grep "<version>"
if [ $? -eq 0 ]; then
sed '/<dependency>/!d;x;s/^/x/;/x\{'$i'\}/!{x;d};x;:a;n;/<\/dependency>/!ba;q' commonpom.xml | grep "version\}"
if [ $? -ne 0 ]; then
sed '/<dependency>/!d;x;s/^/x/;/x\{'$i'\}/!{x;d};x;:a;n;/<\/dependency>/!ba;q' commonpom.xml >> newpom.xml
fi
fi
done

echo "</dependencies>" >> newpom.xml
echo "</project>" >> newpom.xml
