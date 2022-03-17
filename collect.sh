#!/bin/bash
echo "Hello from $SHELL"
#cd context2
#place="context2"
find . -name pom.xml > pomfiles.txt
cat pomfiles.txt

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
echo "</dependencies>" >> commonpom.xml
echo "</project>" >> commonpom.xml
