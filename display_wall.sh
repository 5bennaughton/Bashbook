#! /bin/bash

# Assign the first argument to the variable 'id'
id=$1

# Exit if the number of arguments is not equal to 1
if [ $# -ne 1 ]; then
	exit 1	# Incorrect number of arguments
fi

# Check if the user ID exists
./check_Ids.sh "$id" > /dev/null
check=$? # Get the exit code from the user check

# Process the result of the user check
if [ $check -eq 0 ]; then
	# Set the Internal Field Separator to '_'
	IFS='_'

	# Initialize an array 'input' with the first element as 'start of file'
	input=("start of file")

	# Append the contents of the user's wall to the 'input' array line by line
	mapfile -tO "${#input[@]}" input < "$id"/wall.txt
	input+=("end of file")  # Append 'end of file' to the array

	# Concatenate array elements using IFS and echo the output to the user's pipe
	echo "${input[*]}" > "$id"_pipe	

	exit 0
elif [ $check -eq 2 ]; then
	exit 2	# Exit if the user doesn't exist
fi
