#!/bin/bash

# Assign the first argument to 'id' and set a trap to remove the corresponding pipe upon exit
id=$1
trap 'rm "$id"_pipe' EXIT

# Check if exactly one argument (id) is provided
if [ $# -ne 1 ]; then
	echo "Error: This script requires one ID as a parameter."
	exit 1
fi 

# Check if the ID exists by calling checkIDs.sh, create a new user if it doesn't
if ! ./check_Ids.sh "$id" ; then
	./create_user.sh "$id" 
fi

# Start the server if it isn't already running
if ! [ -e server ]; then
	./server.sh &   # Start the server in the background
	sleep 1        # Wait for the server to initialize
	echo "Started server."
fi

# Create a named pipe for the user
mkfifo "$id"_pipe

# Login to the server by sending a login command
echo "$id login" > ./server
read -r ret < "$id"_pipe  # Read the login response from the server
echo "$ret"

# Loop to handle user commands
while true; do
	read -rp "Enter a command followed by the arguments: " req
	echo "$id" "$req" > ./server  # Send the request to the server
	read -r ret < "$id"_pipe      # Read the response from the server

	# Check if the response is an error
	(echo "$ret" | grep "^nok:") > /dev/null
	error=$?

	# Check if the response is the start of a file (for wall display)
	(echo "$ret" | grep "^start of file") > /dev/null
	wall=$?

	# Process the response based on its type
	if [ $error -eq 0 ]; then
		output=$(echo "${ret//nok: /error: }")
		echo "$output"
	elif [ "$ret" == "exited" ]; then
		echo "Exiting..."
		exit 0
	elif [ $wall -eq 0 ]; then
		# Split the response into an array and print each line except the first and last
		IFS='_' read -ra out <<< "$ret"
		length=${#out[@]}
		for (( i=1; i<length-1; i++ )); do			
			printf '%s\n' "${out[$i]}"	
		done
	else
		# Print the response if it's not an error or wall display
		output=$(echo "${ret//ok: /}")
		echo "$output"
	fi
done
