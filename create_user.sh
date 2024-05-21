#! /bin/bash

# Assign the first command line argument to the variable 'user'
user=$1

# Acquire a lock for the user
./acquire.sh "$user" "$user"lock

# Check if the user ID exists
./check_Ids.sh $user
check=$?  # Store the exit code of checkIDs.sh

# Check if the number of arguments is correct
if [ $# -ne 1 ]; then
    ./release.sh "$user"lock  # Release the lock
    exit 1  # Exit with status 1 for incorrect argument count
elif [ $check -eq 0 ] ; then  # If the user already exists
    ./release.sh "$user"lock  # Release the lock
    exit 2  # Exit with status 2 indicating user already exists
elif [ $check -eq 2 ]; then   # If the user does not exist, set up the user with
    mkdir $user                # Create a directory for the user
    touch $user/friends.txt    # Create a friends file
    touch $user/wall.txt       # Create a wall file
    echo $user > $user/friends.txt  # Add the user to their own friends list
    ./release.sh "$user"lock   # Release the lock
    exit 0  # Exit with status 0 indicating successful setup
fi
