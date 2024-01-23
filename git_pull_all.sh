#!/bin/bash

# Runs 'git pull' within each of the subdirectories of this directory

# Change to the parent directory
parent_directory=$(pwd)

# Loop through each subdirectory
for dir in */; do
    # Navigate into the subdirectory
    cd "$parent_directory/$dir" || exit

    # Check if the directory is a Git repository
    if [ -d ".git" ]; then
        # Perform git pull
        echo "Pulling updates for $dir"
        git pull
    else
        echo "Skipping $dir - Not a Git repository"
    fi

    echo

    # Move back to the parent directory
    cd "$parent_directory" || exit
done

echo "Done!"
echo
