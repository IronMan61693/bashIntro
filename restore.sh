#!/bin/bash

# TBD
# * Restore a file or directory from the recycling bin
# * If the target is not found, notify the user and exit
# * Implement a list option, which just lists the contents of the recycling bin
# * Optional argument which specifies where to restore files to

# First thing I do upon calling this command will be to check if the directory exists in the home directory
# If it does not continue,  I want to inform the user there is nothing that can be restored

if [ ! -d ~/.recycle_me ]; then
	echo 'You do not have a recycle directory from which to restore files or directories'

	exit -1
fi

# Calls ls on the recycle directory and excludes the 
# recycle info file and the . and .. directories

function listDirectory {
	echo 'The contents of the recycle bin are:'
	ls -a ~/.recycle_me -I .recycledinfo.txt -I . -I ..
	exit 0
}

# First checks the input is a valid file or directory then
# moves the input (file or directory) to the current directory

function moveFileOrDir {
	GOODFILE=0
	if [ -f ~/.recycle_me/"$1" ]; then
		GOODFILE=1
	fi

	if [ -d ~/.recycle_me/"$1" ]; then
		GOODFILE=1
	fi

	if [[ "${GOODFILE}" -eq 0 ]]; then
		echo ''
		echo 'The file or directory you would like restored does not exist:'
		echo "$1"
		echo 'If you believe this to be in error please look inside your ~/.recycle_me'
		echo ''
		exit -1
	fi

	mv -i ~/.recycle_me/"$1" "$2"
}

# Sets the directoryToRestoreTo equal to the results of the grep and cut parsing
# the grep finds the line which contains the first argument of the function
# which is the name of the file or directory we want restored
# we then pipe the results of the grep to cut which uses spaces as the diliminater
# and returns the fourth found, which in this case is the directory of the requested file
# If the directory to restore to is no longer existent set to current directory

function findDeletedDirectory {
	directoryToRestoreTo=$(grep "$1" ~/.recycle_me/.recycledinfo.txt | cut -d ' ' -f4)
	if [ ! -d "${directoryToRestoreTo}" ]; then
		echo 'Attempted to restore the file to its previous directory but that directory no longer exists.'
		echo 'Instead attempting to save to your current directory'
		directoryToRestoreTo=$PWD
	fi

	# This line removes the line of the restored text by using grep to remove the line and save it as temptext.txt
	# and then move the temptext to the one we want as the recycled
	grep -v "$1" ~/.recycle_me/.recycledinfo.txt > temptext.txt; mv temptext.txt ~/.recycle_me/.recycledinfo.txt
}

# This is a function for the help output
# Prints information about the script and then exits
function HelpMe {
	echo ''
	echo 'This will restore a file or directory from the ~/.recycle_me directory to your current directory'
	echo 'Example ./restore.sh -v sample.txt will see if sample.txt is in the recycle directory'
	echo ' and if it is will restore sample.txt to the current directory. The -v flag will set verbose'
	echo ' to true providing additional print statements. The file or directory to be restored '
	echo ' must be the last argument.'
	echo 'Optional arguments:'
	echo '-h, --help 		show this help message and exit'
	echo '-v, --verbose 		provides additional about what the script is doing while it is running'
	echo '-d, --directory 	attempts to send the file back to where it was originally removed'
	echo '-l, --list 		lists the contents of the recycle directory and exit'
	echo ''
	exit 0
}

# Need to include -d flag for specifying the previous directory -v for verbose
# -l flag to list the contents of the directory
DIRECTORY=0
VERBOSE=0
LIST=0

# Defaults the save location to the current directory
directoryToRestoreTo=$PWD

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
		-d|--directory)
		DIRECTORY=1
		shift
		;;
		-l|--list)
		LIST=1
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



# If the flag is set to call the listDirectory function
if [[ "${LIST}" -eq 1 ]]; then
	listDirectory
fi

# If the flag is set to send the file back to the original directory calls the findDeletedDirectory function
# with the requested file as the parameter
if [[ "${DIRECTORY}" -eq 1 ]]; then
	findDeletedDirectory "${TOMOVE[-1]}"
fi


# This erases the text file location in the case it is just moved to the current directory
if [[ "${DIRECTORY}" -eq 0 ]]; then
	# This line removes the line of the restored text by using grep to remove the line and save it as temptext.txt
	# and then move the temptext to the one we want as the recycled
	grep -v "${TOMOVE[-1]}" ~/.recycle_me/.recycledinfo.txt > temptext.txt; mv temptext.txt ~/.recycle_me/.recycledinfo.txt
fi

# Calls the moveFileOrDir function with the file we want restored as the first parameter
# and the directory it is being saved to as the second
moveFileOrDir "${TOMOVE[-1]}" "${directoryToRestoreTo}"

# Provides more print if Verbose flag
if [[ "${VERBOSE}" -eq 1 ]]; then
	echo ''
	echo 'Moving the file' "${TOMOVE[-1]}" 'to the directory' "${directoryToRestoreTo}"
fi

