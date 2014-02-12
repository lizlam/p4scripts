#!/bin/bash
# Script to delete empty changelists
# Set $P4PORT and $P4USER environment variables

if [ $# -eq 0 ]
then
    echo "usage: del_empty_changes.sh [client]"
    exit 1
fi

i=0
num=`p4 changes -s pending -c $1 | wc -l`
num_deleted=0
eval array=( $(p4 -ztag changes -s pending -c $1 | grep "change " | awk '{print $3}' ))

# Function to check if changelist contains open files. 
# If changelist contains open files, increment $file_result_count
function is_empty() {
    file_result=`p4 -ztag describe $1 | grep depotFile`
    if [ "$file_result" != "" ]
    then
        file_result_count=`expr $file_result_count + 1`   
    fi
}

# Function to check if changelist contains fixes.
# If changelist contains fixes, increment $fixes_result_count
function check_fixes() {
    fixes_result=`p4 -ztag describe $1 | grep job`
    if [ "$fixes_result" != "" ]
    then
        fixes_result_count=`expr $fixes_result_count + 1`
        change_with_fix=$1
    fi
} 

# Function to check if changelist contains shelved files.
# If changelist contains shelved files, increment $shelved_result_count
function check_shelved() {
    shelved_result=`p4 -ztag describe -s $1 | grep shelved`
    if [ "$shelved_result" != "" ]
    then
        shelved_result_count=`expr $shelved_result_count + 1`
    fi
}

function summarize() {
    echo "-----------S U M M A R Y--------------"
    echo "Total # of pending changelists: `expr $num + 1` "
    echo "# of changelists deleted: $num_deleted"
    echo "# of empty changelists with fixes: $fixes_result_count"
    echo "# of empty changelists with shelved files: $shelved_result_count"    
    echo "# of changelists with open files: $file_result_count"
}


while [ $i -lt $num ]
do
    current_change=${array[$i]}
    is_empty $current_change
    if [ "$file_result" = "" ]
    then
        check_shelved $current_change
        check_fixes $current_change
        p4 -c $1 change -d $current_change
        # Need the extra check since unsuccessful delete of empty
        # changelist with fix returns 0 status
        if [ $? -eq 0 -a "$current_change" != "$change_with_fix" ]
        then
            num_deleted=`expr $num_deleted + 1`
        fi
    else
        echo "Change $current_change is not empty."
    fi
    i=`expr $i + 1`
done
summarize
