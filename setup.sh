#!/bin/bash

# prevent this script from running outside of project root (same dir as script itself)
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
CURRENT_DIR="$(pwd)"

# check if the current directory is the same as the script directory
if [ "$CURRENT_DIR" != "$SCRIPT_DIR" ]; then
    echo "Error: script must be executed from the project root."
    exit 1
fi

# get config variables
source config.ini

# parse any named command line options
# first check that we have the correct getopt version
getopt -T &>/dev/null
if [[ ! $? -ne 4 ]]; then 
	# correct getopt version
	while getopts ":a:b:" opt; do
	  case $opt in
		a) arg1="$OPTARG"
		;;
		b) arg2="$OPTARG"
		;;
		\?) echo "Invalid option -$OPTARG" >&2
		;;
	  esac
	done
else
	echo "Your systems getopt version is too old (must be >= 4). No arguments can be parsed."
	read -p "Proceed with default script behaviour? [y/n] " choice
	case "$choice" in
	  y|Y ) echo "Proceeding...";;
	  * ) echo "Exiting the script..."; exit;;
	esac

fi

# check that the build directory doesn't exist already
if [ ! -d "build" ]; then
	# setup the cmake build directory for the first time
	mkdir build
	cmake -B build -S .
fi

# create lib directory if it doesnt exist
if [ ! -d "lib" ]; then
	echo "Creating lib directory."
	mkdir lib
fi

if [ ! -d "lib/catch2" ]; then
	echo "Installing Catch2 into lib/catch2"
	mkdir -p lib/catch2
	git clone https://github.com/catchorg/Catch2.git
	cd Catch2
	$PY ./tools/scripts/generateAmalgamatedFiles.py
	mv ./extras/catch_amalgamated.hpp ./lib/catch2/catch.hpp
	mv ./extras/catch_amalgamated.cpp ./lib/catch2/catch.cpp
	rm -rf Catch2
fi



