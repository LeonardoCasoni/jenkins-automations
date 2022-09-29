#!/bin/bash -u

echo "DEVOPS Check: Display all the results"
for i in ../../volume/logs/*.log
do
    [[ -e "$i" ]] || break
    echo "--------------------------------------------------------------"
    echo "RESULTS for $i"
    echo " "
    cat ../../volume/logs/"$i"
    echo "--------------------------------------------------------------"
done
