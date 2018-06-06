#!/bin/bash

# First thing I do upon calling this command will be to check if the directory exists in the home directory
# If it does continue, if it does not then I want to create the directory named: .recycle_me in the users home folder
# once the folder exists I will use the move command recursively to move all of the contents of the input (required)
# to this directory

if [ ! -d ~/.recycle_me ]; then
	echo 'Creating recycle directory name in your home folder .recycle_me'
	mkdir ~/.recycle_me
fi

# I will write a getopt enhanced version all inside a giant if statement and if getopt enhanced is false I will
# have a pure version as well
function moveFiles {
	mv -i $1 ~/.recycle_me
	echo 'Moved $1 to the recycle'
}

# Need to include -e flag for empty -h flag for help and specify what is being moved -v for verbose
EMPTY=0
VERBOSE=0

POSITION=()

# I will be dealing with each input and decrementing the number of inputs
# Once it hits 0 I have run out of command line input to deal with
# $# is the number of command line arguments
while [[ $# -gt 0 ]]; do
	# Sets input equal to the command line argument we will work with
	input="$1"

	case $input in 
		-c|--check)
		CHECK='Check success'
		shift
		;;
		-e|--empty)
		EMPTY=1
		shift
		;;
		*)
		POSITION+=("$1")
		shift
		;;
	esac
done

echo 'Empty is now ' "${EMPTY}"
echo ' and the check is ' "${CHECK}"