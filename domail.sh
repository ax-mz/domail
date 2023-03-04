#!/bin/bash

# Inspired by rix4uni (https://github.com/rix4uni/EmailFinder)
# Fixes:
# - Displays emails even if only one page 
# - Exits if domain doesn't exist on skymem.info

checkSkymem(){
	# Checks if domain exists on www.skymem.info
	EMAILS=$(curl -s http://www.skymem.info/srch?q=$DOMAIN | grep 'href="/srch?q=' | sed '1d' | cut -d">" -f2 | cut -d"<" -f1)
	if [[ $EMAILS ]];
	then
		# If it does, displays emails from first page 
		echo "$EMAILS" 
	else
		echo "No result for '$DOMAIN' on skymem.info"
		exit 1
	fi

	DOMAIN_ID=$(curl -s http://www.skymem.info/srch?q=$DOMAIN | grep '<a href="/domain/' | cut -d"?" -f1 | cut -d"/" -f3)
	if [[ $DOMAIN_ID ]];
	then
		# Checks if there are more than 1 page. If it does, displays emails from page 2 to last page
		END_PAGE=$(curl -s http://www.skymem.info/domain/$DOMAIN_ID?p=2 | grep 'aria-label="Next">' | tail -1 | cut -d"=" -f4 | cut -d'"' -f1)
		if [[ $END_PAGE ]];
		then
			for i in $(seq 2 $END_PAGE);
			do
				curl -s http://www.skymem.info/domain/$DOMAIN_ID?p=$i | grep 'href="/srch?q=' | sed '1d' | cut -d">" -f2 | cut -d"<" -f1
			done
		fi
	fi
}

if [ -z $1 ];
then
	echo "Usage : $0 [DOMAIN]"
	exit 1
else
	DOMAIN=$1
fi

checkSkymem $DOMAIN
