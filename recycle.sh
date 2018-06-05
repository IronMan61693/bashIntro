#!/bin/bash

# TBD
# * Takes a file or directory as an argument, and moves it into the recycling bin
# directory
# * If no such directory exists, then one should be created
# * Optional flag which empties (rm -rf) the contents of the recycling bin

# First thing I do upon calling this command will be to check if the directory exists in the home directory
# If it does continue, if it does not then I want to create the directory named: .recycle_me in the users home directory

if [ ! -d ~/.recycle_me ]; then
	echo 'Creating recycle directory in your home directory .recycle_me'

	mkdir ~/.recycle_me
fi

# First checks the input is a valid file or directory then
# moves the input (file or directory) to the recycle directory
# the -i asks if we want to overwrite in case the file/directory is already in recycle

function moveFileOrDir {
	GOODFILE=0
	if [ -f "$1" ]; then
		GOODFILE=1
	fi

	if [ -d "$1" ]; then
		GOODFILE=1
	fi

	if [[ "${GOODFILE}" -eq 0 ]]; then
		echo ''
		echo 'If you would like to move a file or directory to the recycle directory'
		echo 'The last argument in the command line needs to be that file or directory which you would like recycled.'
		echo 'Please try again'
		echo ''
		exit -1
	fi

	mv -i $1 ~/.recycle_me
}

# Creates a hidden txt file which for each line saves the file or directory name
# on a line and then a tab followed by the directory from which it was removed

function trackRemoveDirectory {
	if [ ! -f ~/.recycle_me/.recycledinfo.txt ]; then
		touch ~/.recycle_me/.recycledinfo.txt
	fi


	# Appends the following string to the hidden recycledinfo.txt
	# "fileMoved: <filename> currentDirectory <fileDirectory>"
	echo fileMoved: "$1" currentDirectory $PWD | cat >> ~/.recycle_me/.recycledinfo.txt 
}

# This is called if EMPTY=1
#  recursively calls remove in the recycle_me directory to delete everything
# Originially had rm -rf ~/.recycle_me/* && rm -rf ~/.recycle_me/.*
#  But this will give you and error about trying to delete . and ..
# I find the given solution to be simpler

function removeEverything {
	# This deletes the entire directory
	rm -rf ~/.recycle_me/

	# Recreates the directory in the same spot
	mkdir ~/.recycle_me/
	exit 0
}

# This is a function for the help output
# Prints information about the script and then exits
function HelpMe {
	echo ''
	echo 'This will move a file or directory to the ~/.recycle_me directory in your home directory'
	echo 'Example ./recycle.sh -v sample.txt will check if sample.txt is in the current directory'
	echo ' and if it is will send sample.txt to the recycle directory. -v sets the verbose flag'
	echo ' providing additional print statements. The file to recycle must be the last argument'
	echo ' and be present in the current directory.'
	echo 'Optional arguments:'
	echo '-h, --help 		show this help message and exit'
	echo '-v, --verbose 		provides additional about what the script is doing while it is running'
	echo '-e, --empty 		empties the recycle directory'
	echo ''
	exit 0
}


# Need to include -e flag for empty -v for verbose
EMPTY=0
VERBOSE=0

# Since always takes the most recent input by putting in a sample.txt I keep indexing errors for occuring
# without every actually touching sample.txt
TOMOVE=(fill)


# I will be dealing with each input and decrementing the number of inputs
# Once it hits 0 I have run out of command line input to deal with
# $# is the number of command line arguments
while [[ $# -gt 0 ]]; do
	# Sets input equal to the command line argument we will work with
	input="$1"

	# Sets the flags
	case $input in 
		-h|--help)
		HelpMe
		;;
		-v|--verbose)
		VERBOSE=1
		# Shift is effectively popping the first argument off
		shift
		;;
		-e|--empty)
		EMPTY=1
		shift
		;;
		*)
		# This will skip over everything that is not a flag until the last argument
		# I can then access the last input to find what the file/folder is
		TOMOVE+=("$1")
		shift
		;;
	esac

done


# Checks Empty flag if true runs the removeEverything function
if [[ "${EMPTY}" -eq 1 ]]; then

	# Provides more print if Verbose flag
	if [[ "${VERBOSE}" -eq 1 ]]; then

		echo ''
		echo 'Deleting everything in the recycle folder'
	fi

	removeEverything


fi

# Calls moveFileOrDir function with the last argument given in the command line
moveFileOrDir "${TOMOVE[-1]}"

# Calls trackRemoveDirectory to save the information of from where the files are recycled 
trackRemoveDirectory "${TOMOVE[-1]}"

# Provides more print if Verbose flag
if [[ "${VERBOSE}" -eq 1 ]]; then
	echo ''
	echo 'Moving the file' "${TOMOVE[-1]}" 'to the recycle directory ~/.recycle_me'
fi