#! /bin/bash

# Set a trap to remove the 'server' file upon script exit
trap "rm server" EXIT

# Create a named pipe 'server'
mkfifo server	
sleep 1		# Brief sleep to ensure the named pipe is set up

# Initialize a counter to track the number of logged-in users
count=0		

# Start an infinite loop to continuously handle incoming requests
while true; do
    # Read input from the 'server' named pipe into variables
	read id request friendID other < server 

    # Process the request based on its type
	case $request in 
		add)
            # Handle 'add' request to add a friend
			if ! [ "$friendID" = '' ]; then 
				./add_friends.sh "$id" "$friendID"  # Call the add_friend script
				check=$?  # Capture the exit status of the last command

                # Process the result of add_friend.sh
				if [ $check -eq 1 ]; then
			 		echo "nok: friend already added" > "$id"_pipe
				elif [ $check -eq 3 ]; then
					echo "nok: user $friendID doesn't exist" > "$id"_pipe
				else		
					echo "ok: friend $friendID added" > "$id"_pipe
				fi	
			else
				echo "nok: specify the friend ID" > "$id"_pipe
			fi
			;;
		post)
            # Handle 'post' request to post a message
			if ! { [ "$friendID" = '' ] || [ "$other" = '' ]; }; then
				./post_message.sh "$id" "$friendID" "$other"  # Call the post_messages script
				check=$?  # Capture the exit status

                # Process the result of post_messages.sh
				if [ $check -eq 2 ]; then
					echo "nok: receiver $friendID does not exist" > "$id"_pipe
				else
					echo "ok: message posted" > "$id"_pipe
				fi
			else
				echo "nok: enter the friend ID followed by the message in quotes" > "$id"_pipe
			fi
			;;
		display)
            # Handle 'display' request to display user's wall
			if ! [ "$friendID" = '' ]; then
				./display_wall.sh "$id" "$friendID"  # Call the display_wall script
				check=$?  # Capture the exit status

                # Process the result of display_wall.sh
				if [ $check -eq 2 ]; then
					echo "nok: user $friendID does not exist" > "$id"_pipe
				fi
			else
                echo "nok: enter the friend ID" > "$id"_pipe
            fi
			;;
		login)
            # Handle 'login' request
			((count++))	 # Increment the user count
			echo "Welcome to BashBook $id" > "$id"_pipe	
			;;
		exit)
            # Handle 'exit' request
			((count--))	 # Decrement the user count
			echo "exited" > "$id"_pipe	

            # Exit the script if no users are logged in
			if [ $count -le 0 ]; then	
				exit 0			
			fi
			;;
		*)
            # Handle invalid commands
			echo "only valid commands are add [friend ID], post [friend ID] [message], display [friend ID] or exit" > "$id"_pipe
			;;
	esac
done
