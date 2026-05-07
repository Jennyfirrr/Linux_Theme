#!/bin/bash
echo "In submenu. Exit 10? (y/n)"
read ans
if [[ "$ans" == "y" ]]; then exit 10; fi
exit 0
