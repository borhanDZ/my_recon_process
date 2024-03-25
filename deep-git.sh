#!/bin/bash


#colors
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
blue=`tput setaf 4`
magenta=`tput setaf 5`
reset=`tput sgr0`

NC='\033[0m'
RED='\033[1;38;5;196m'
GREEN='\033[1;38;5;040m'
ORANGE='\033[1;38;5;202m'
BLUE='\033[1;38;5;012m'
BLUE2='\033[1;38;5;032m'
PINK='\033[1;38;5;013m'
GRAY='\033[1;38;5;004m'
NEW='\033[1;38;5;154m'
YELLOW='\033[1;38;5;214m'
CG='\033[1;38;5;087m'
CP='\033[1;38;5;221m'
CPO='\033[1;38;5;205m'
CN='\033[1;38;5;247m'
CNC='\033[1;38;5;051m'

	clear
	echo
	echo -e "\t\t\t${red}
	github deep scans for subdomains ...
	${reset}\n" 


read -p "Enter domain name : " domain
echo " "
read -p "Enter github access token : " $token

github-subdomains -d $domain/diff-scans/.com -e -t $token -o $domain/diff-scans/git-subs

shuffledns -d $domain -list $domain/diff-scans/git-subs -r ~/tools/resolvers/resolver.txt -o $domain/diff-scans/shuffledns


grep -vf $domain/domain_enum/all.txt git-subs | grep -E "\."$domain"$" > $domain/diff-scans/new-subs-git

grep -vf $domain/domain_enum/all.txt shuffledns > $domain/diff-scans/new-subs-git-resolved
#cat $domain/diff-scans/shuffledns.txt | grep -E "[^.]"$domain".[a-z]+$" > $domain/diff-scans/ext-$domain.tld
#cat $domain/diff-scans/shuffledns.txt | grep -E "\."$domain".[com|net|co|io|tr|de|cm|io|edu|info|me]+$" > $domain/diff-scans/$domain.tld
#cat $domain/diff-scans/shuffledns.txt | grep -E "\."$domain".[com]+$" > $domain/diff-scans/$domain.com
#cat $domain/diff-scans/shuffledns.txt | grep -E "\."$domain".[net]+$" > $domain/diff-scans/$domain.net
#cat $domain/diff-scans/shuffledns.txt | grep -E "\."$domain".[co]+$" > $domain/diff-scans/$domain.co
#cat $domain/diff-scans/shuffledns.txt | grep -E "\."$domain".[io]+$" > $domain/diff-scans/$domain.io
