#! /bin/bash

# Check if at least one argument is provided
if [ $# -lt 1 ]; then	
	exit 1  # Exit with status 1 if no arguments are provided
else
	index=2  # Initialize an index to track the exit status

	# Loop through all provided arguments (user IDs)
	for id in "$@"; do
		# Check if a directory for each user ID exists
		if ! [ -d "$id" ]; then
			exit $index  # Exit with the current index value if a directory does not exist
		else
			index=$((index + 1))  # Increment the index for each existing user directory
		fi
	done
fi
exit 0  # Exit with status 0 if all user directories exist
