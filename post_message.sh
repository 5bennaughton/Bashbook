#! /bin/bash

# Assign command line arguments to variables for sender, receiver, and message
sender="$1"
receiver="$2"
message="$3"

# Check if both sender and receiver IDs exist
./check_Ids.sh $sender $receiver
check=$?

# Process the result of the ID check
if [ $check -eq 2 ]; then	
	exit 1 # Exit if the sender doesn't exist
elif [ $check -eq 3 ]; then
	exit 2 # Exit if the receiver doesn't exist
elif [ $check -eq 0 ]; then
	# Check if sender and receiver are friends
	./check_friends.sh $sender $receiver > /dev/null
	friends=$?

	if [ $friends -ne 0 ]; then
		exit 3 # Exit if users are not friends
	else 
		# Acquire lock for receiver's wall
		./acquire.sh $receiver/wall.txt "$receiver"walllock.txt

		# Append the message to the receiver's wall
		echo "$sender: $message" >> ./$receiver/wall.txt

		# Release the lock
		./release.sh "$receiver"walllock.txt

		# Successful completion
		exit 0
	fi
fi
