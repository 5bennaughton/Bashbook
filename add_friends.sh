#! /bin/bash

# Assign command line arguments to variables
id=$1
friend=$2

# Check if both the user ID and friend ID exist
./check_Ids.sh "$id" "$friend"
check=$?	# Capture the exit status of checkIDs.sh

# Process the result of the ID check
if [ $check -eq 0 ]; then
	# Acquire a global lock for modifying friend files
	./acquire.sh server.sh friendslocklock.txt

	# Acquire a lock for the user's friends list
	./acquire.sh "$id"/friends.txt "$id"friendslock.txt

	# Acquire a lock for the friend's friends list if they are not the same person
	if ! [ $id == $friend ]; then
		./acquire.sh "$friend"/friends.txt "$friend"friendslock.txt
	fi

	# Release the global lock
	./release.sh friendslocklock.txt

	# Check if the user and the friend are already friends
	./check_friends.sh "$id" "$friend"
	friends=$?

	# Add each other as friends if they are not already friends
	if [ $friends -eq 1 ]; then
		echo "$friend" >> "$id"/friends.txt	# Add friend to user's friends.txt
		echo "$id" >> "$friend"/friends.txt	# Add user to friend's friends.txt

		# Release locks for both user and friend
		./release.sh "$id"friendslock.txt
		./release.sh "$friend"friendslock.txt

		exit 0	# Exit with status 0 indicating success
	else
		# Release locks if they are already friends
		./release.sh "$id"friendslock.txt
		./release.sh "$friend"friendslock.txt

		exit 1	# Exit with status 1 indicating they are already friends
	fi
elif [ $check -eq 2 ]; then
	exit 2 # Exit with status 2 indicating the user doesn't exist
elif [ $check -eq 3 ]; then
	exit 3 # Exit with status 3 indicating the friend doesn't exist
fi
