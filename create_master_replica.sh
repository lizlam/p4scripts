#/bin/bash

MASTER_P4PORT=127.0.0.1:1777
MASTER_ROOT=/home/perforce/master
REPLICA_P4PORT=127.0.0.1:1888
REPLICA_ROOT=/home/perforce/replica

if [ ! -d $MASTER_ROOT ] 
then
    mkdir -p $MASTER_ROOT
fi

if [ ! -d $REPLICA_ROOT ]
then
    mkdir -p $REPLICA_ROOT
fi

# Spec definitions 
MASTER_SERVER_SPEC="ServerID:\tmaster\nType:\tserver\nServices:\tstandard\nDescription:\n\tCreated by Perforce."
REPLICA_SERVER_SPEC="ServerId:\treplica\nType:\tserver\nServices:\tforwarding-replica\nDescription:\n\tCreated by Perforce."
SERVICE_USER_SPEC="User:\tservice\nType:\tservice\nEmail:\tservice@perforce.com\nFullName:\tservice\n"
PROTECT_TABLE_SPEC="Protections:\n\twrite user * * //...\n\tsuper user perforce * //...\n\tsuper user service * //..."

echo -e $MASTER_SERVER_SPEC > $MASTER_ROOT/master.txt  
echo -e $REPLICA_SERVER_SPEC > $MASTER_ROOT/replica.txt
echo -e $SERVICE_USER_SPEC > $MASTER_ROOT/service.txt
echo -e "$PROTECT_TABLE_SPEC" > $MASTER_ROOT/protect.txt

# Set up master server
p4d -p $MASTER_P4PORT -r $MASTER_ROOT &
sleep 5
p4 -p $MASTER_P4PORT server -i < $MASTER_ROOT/master.txt
p4 -p $MASTER_P4PORT server -i < $MASTER_ROOT/replica.txt
p4 -p $MASTER_P4PORT user -f -i  < $MASTER_ROOT/service.txt
p4 -p $MASTER_P4PORT protect -i < $MASTER_ROOT/protect.txt

# Set up configurables
p4 -p $MASTER_P4PORT configure set replica#P4TARGET=$MASTER_P4PORT
p4 -p $MASTER_P4PORT configure set replica#P4LOG=log.replica
p4 -p $MASTER_P4PORT configure set replica#P4AUDIT=audit.replica
p4 -p $MASTER_P4PORT configure set replica#server=3
p4 -p $MASTER_P4PORT configure set replica#monitor=1
p4 -p $MASTER_P4PORT configure set "replica#startup.1=pull -i 1"
p4 -p $MASTER_P4PORT configure set "replica#startup.2=pull -i 1"
p4 -p $MASTER_P4PORT configure set "replica#startup.3=pull -i 1" 
p4 -p $MASTER_P4PORT configure set replica#db.replication=readonly
p4 -p $MASTER_P4PORT configure set replica#lbr.replication=readonly
p4 -p $MASTER_P4PORT configure set replica#serviceUser=service
p4 -p $MASTER_P4PORT configure set replica#rpl.forward.all=1

# Take checkpoint and replay in replica
if [ ! -f ${MASTER_ROOT}/checkpoint.1 ]
then
    p4 -p $MASTER_P4PORT admin checkpoint
fi

p4d -r $REPLICA_ROOT -jr $MASTER_ROOT/checkpoint.1
p4d -r $REPLICA_ROOT -In replica -p $REPLICA_P4PORT -d -q 

