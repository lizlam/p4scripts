#!/bin/bash
# Quick and dirty P4V custom tool to view file content in Swarm
#
# In P4V, click on Tools -> Manage Custom Tools...
# Click on New -> Tool...
# In Add Tool dialog, enter:
#       Name: View in Swarm
#       Application: /path/to/swarm.sh (this file)
#       Arguments: %D
browser=/usr/bin/firefox
baseSwarmUrl=http://swarm.workshop.perforce.com
ellipses='...'
 
i=1
for i in $*
do
    file=`echo $i | awk '{print substr($1, 2); }'`
    last3chars=`echo $file | awk '{print substr($1, length($1)-2, length($1)); }'`
 
    # Check to see if selection in p4v is a directory
    if [ $last3chars == $ellipses ]
    then 
        file=`echo $file | awk '{print substr($1, 1, length($1)-3); }'`
    fi
    urls=$urls' '$baseSwarmUrl$file
done
$browser $urls
