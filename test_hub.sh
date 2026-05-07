#!/bin/bash
while true; do
    echo "In hub. Press enter to go to submenu."
    read
    ./test_sub.sh
    if [[ $? -eq 10 ]]; then
        echo "Returned 10, continuing..."
        continue
    fi
    echo "Exiting hub."
    exit 0
done
