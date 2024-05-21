#! /bin/bash

# Assign command line arguments to variables
user1=$1
user2=$2

# Check if both users exist
./check_Idss.sh "$user1" "$user2" > /dev/null
check=$?

# Exit with status 1 if any of the users do not exist
if [ $check -ne 0 ]; then
	exit 1  # Exit indicating that not all users exist
fi

# Check if user1 is in user2's friends list
grep "^$user1$" "$user2"/friends.txt > /dev/null
exists=$?

# Determine the friendship status
if [ $exists -eq 1 ]; then
	exit 1  # Exit with status 1 if they are not friends
else
	exit 0  # Exit with status 0 if they are friends
fi
