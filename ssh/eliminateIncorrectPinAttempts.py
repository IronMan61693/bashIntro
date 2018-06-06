#!/usr/bin/env python3

import sys

# I will input a text document that contains lines with wrong
# Furthermore I will have a dictionary with all numbers from 0000 to 9999
# If there is a line with the number and wrong I will eliminate that number from the dictionary so I am 
# able to narrow down the numbers that are still possible


possiblePinSet = set()

# Adds all of the possible pins to the set
for i in range(10):
	possiblePinSet.add('{0:04}'.format(i))

def cleanPins(text):
	for line in text.splitlines():
		print(line)
		if 'Wrong!' in str(line):
			print("discarded", line.split(":")[1])

			possiblePinSet.discard(int(line.split(":")[1]))


def main():


	# Opens the file and makes a local copy to be modified
	with open(sys.argv[1], mode = 'r') as READ_FILE:

		myFile = READ_FILE.read()

	READ_FILE.close()


	cleanPins(myFile)

	for pin in possiblePinSet:
		print(pin)

# This is a check to make sure the script is being handled correctly
if (__name__ == "__main__"):
	main()