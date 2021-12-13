#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

cmd=$(ip -o link show | awk -F': ' '{print $2}')

for c in $cmd
do
	if [[ $c == "eno1" ]] || [[ $c == "eno2" ]] || [[ $c == "lo" ]] ;
	then
		continue
	else
		fw=$(sudo ethtool -i $c | grep "firmware-version")
		echo $c : $fw
		if [[ $fw != "firmware-version: 7.20 0x800099e3 1.2585.0" ]] ;
		then 
			echo -e "${RED}NOT UPDATED${NC}"
		else
			echo -e "${GREEN}UPDATED${NC}"
		fi
	fi
done
