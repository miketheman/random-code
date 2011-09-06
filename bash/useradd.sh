#!/bin/env bash

# Add a new user, specify the UID so we can have the same UID across all machines
# The password is hashed, encrypted, and needs to be single quoted to preserve the $ symbols
# useradd -g usertom -G wheel,usertom -c "Tom Q. User" -u 505 -p '<somepassword>' usertom

# Set the params here
USER="michael"
FULLNAME="'Mike Fiedler'"
ID="1005"
PASSWORD='<somepassword>' # password is obtained from an existing system via:  getent shadow $USER | cut -f2 -d":"

# Add a bunch of servers to a server list variable
SERVERLIST="localhost"

function test_for_user {
    USERID=$(ssh $1 getent passwd $ID | cut -f2 -d":")
    if [ -z $USERID ]
    then
        echo "User ID $ID not found, you may proceed..."
    else
        echo "User ID $ID already exists on this system, exiting."
        exit
    fi
    USERNAME=$(ssh $1 getent passwd $USER | cut -f1 -d":")
    if [ -z $USERNAME ]
    then
        echo "User $USER not found, you may proceed..."
    else
        echo "User $USER already exists on this system, exiting."
        exit
    fi
}

function add_user {
    ssh $1 useradd -g staff -G staff,wheel -c $FULLNAME -u $ID -p \'$PASSWORD\' $USER
    echo "Added user $USER to $1"
}

# Do it!
for SERVER in $SERVERLIST;
do
    echo "Working on $SERVER..."
    test_for_user $SERVER
    add_user $SERVER
    echo "Done!"
done

### END ###