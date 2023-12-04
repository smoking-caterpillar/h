#!/bin/bash

# Check if a domain name is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <rootdomain.com>"
    exit 1
fi

DOMAIN=$1

# Use dig to find name servers for the domain
echo "Retrieving name servers for $DOMAIN..."
NAME_SERVERS=$(dig ns $DOMAIN +short)

if [ -z "$NAME_SERVERS" ]; then
    echo "No name servers found for $DOMAIN."
    exit 1
fi

# Iterate through each name server and perform nmap scans
for NS in $NAME_SERVERS; do
    echo "Performing checks on name server: $NS"

    # Check for Zone Transfer
    echo "Checking for Zone Transfer..."
    nmap --script=dns-zone-transfer -p 53 $NS

    # Check for DNSSEC (Note: nmap doesn't directly check DNSSEC, but retrieves related info)
    echo "Checking for DNSSEC related info..."
    nmap --script=dns-nsid -p 53 $NS

    # Check if Recursive Queries are disabled
    echo "Checking if Recursive Queries are Disabled..."
    nmap -sU -p 53 --script=dns-recursion $NS

    echo "-------------------------------------"
done

echo "Checks completed for $DOMAIN."
