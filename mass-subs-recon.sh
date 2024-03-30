#!/bin/bash

function menu {
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
 =================================================
|   ____  _____  ____ ___  _   _ _                |
|  |  _ \|___ / / ___/ _ \| \ | (_)_______ _ __   |
|  | |_) | |_ \| |  | | | |  \| | |_  / _ \ '__|  |
|  |  _ < ___) | |__| |_| | |\  | |/ /  __/ |     |
|  |_| \_\____/ \____\___/|_| \_|_/___\___|_|     |
|                                                 |
 ================== Anon-Artist ==================
${reset}\n"
	echo -e "\tA. Ammas"
	echo -e "\tB. Subfinder "
	echo -e "\tG. shuffledns"
	echo -e "\tH. Collect and resolve all subdomain"
	echo -e "\tI. Subdomain takeover"
	echo -e "\tJ. Extract subdomains from ssl and CSP headers on resolved subdoamins"
	echo -e " "
	echo -e "\t1. Full Scan \n"
	echo -e "\t0. Exit Menu\n\n"
	echo -en "\t\tEnter an Option: "
	read -n 1 option
}

function Ammas {
	clear
    echo -e ${ORANGE}"\n[+] Amass Enumeration Started:- "
    amass enum -passive -d $domain -o targets/$domain/Subdomains/amass.txt
}

function Subfinder {
	clear
	echo -e ${CP}"\n[+] subfinder Enumeration Started:- "
	subfinder -d $domain -s all -o targets/$domain/domain_enum/subfinder.txt
}

function Shuffledns {
	clear
	echo -e ${CN}"\n[+] Shuffledns Enumeration Started:- "
    shuffledns -d $domain -w ~/Tools/subdomains-top1million-+100000.txt -r ~/resolvers -o targets/$domain/domain_enum/shuffledns.txt
}

function csp_ssl_subs {
	clear
        cat targets/$domain/final_domains/all-resolved.txt | httpx -u mail.yahoo.com -csp-probe -silent -retries 2 | grep $domain | unfurl -u domains | sort -u > targets/$domain/domain_enum/csp_sub.txt
	cat targets/$domain/final_domains/all-resolved.txt | httpx -u mail.yahoo.com -tls-probe -silent -retries 2 | grep $domain | unfurl -u domains | sort -u > targets/$domain/domain_enum/ssl_sub.txt
	cat targets/$domain/domain_enum/csp_sub.txt | sort -u | anew -q targets/$domain/final_domains/all-resolved.txt
	cat targets/$domain/domain_enum/ssl_sub.txt | sort -u | anew -q targets/$domain/final_domains/all-resolved.txt

    #cat subdomains.txt | httpx -csp-probe -status-code -retries 2 -no-color | anew csp_probed.txt | cut -d ' ' -f1 | unfurl -u domains | anew -q csp_subdomains.txt
}

function Collect-Subdomains {
	clear
        echo -e ${CP}"\n[+] Collecting All Subdomains Into Single File:- "
        cat targets/$domain/domain_enum/*.txt > targets/$domain/domain_enum/all.txt
        echo " "
        echo -e ${BLUE}"\n[+] Resolving All Subdomains:- "
	shuffledns -d $domain -list targets/$domain/domain_enum/all.txt -o targets/$domain/final_domains/all-resolved.txt -r ~/resolvers
	echo " "
	echo -e ${BLUE}"\n[+] Extract subs from SSLs and CSP Headers:- "
	csp_ssl_subs
        echo " "
	echo -e ${PINK}"\n[+] Checking Services On Subdomains:- "
	cat targets/$domain/final_domains/all-resolved.txt | httpx -threads 30 -o targets/$domain/final_domains/all-httpx
	echo " "
	echo -e ${PINK}"\n[+] Extract subdomain behind cdn/cloud/waf:- "
	cat targets/$domain/final_domains/all-resolved.txt | cdncheck  -o targets/$domain/final_domains/bcloud-subs
        echo " "
	echo -e ${PINK}"\n[+] Extract subdomain behind self servers (Company):- "
	grep -vf targets/$domain/final_domains/bcloud-subs targets/$domain/final_domains/all-resolved.txt >  targets/$domain/final_domains/srv-subs
	
    #cat targets/$domain/final_domains/srv-subs | httpx > 
}

function takeover_check {
	clear
	echo -e ${CP}"\n[+] Searching For Subdomain TakeOver:- "
	echo "${magenta} [+] Running nuclei for finding potential takeovers${reset}"
	nuclei -update-templates
	nuclei -l targets/$domain/domain_enum/all.txt -t ~/tools/nuclei-templates/http/takeovers/ -o targets/$domain/takeovers/nuclei_takeover.txt
}

function fullscan {
	clear
	Ammas
	Subfinder
	Shuffledns
	Collect-Subdomains
	takeover_check
	exit
}


read -p "Enter domain name : " domain
if [ -z $domain ]; then
  echo -e ${red}"\n[+] domain is empty."
  exit
elif [ -d targets/$domain/ ];then
   echo -e ${ORANGE}"\n[+] $domain directory may be exist! "
elif [ -n $domain ]; then
   mkdir -p targets/$domain targets/$domain/domain_enum targets/$domain/final_domains targets/$domain/takeovers targets/$domain/deep-scans targets/$domain/endp
fi


while [ 1 ]
do
	menu
	case $option in
	0)
	break ;;
	A | a)
	Amass ;;
	
	B | b)
	Subfinder ;;

	C | c)
	Assetfinder ;;

	D | d)
	Findomain-linux ;;
	
	E | e)
	Cert;;

	F | f)
	Certspotter ;;
	
	G | g)
	Shuffledns ;;
	
	H | h)
	Collect-Subdomains ;;
	
	I | i)
	takeover_check ;;

	1)
	fullscan ;;
	
	*)
	clear
	echo "Wrong selection";;
	esac
	echo -en "\n\n\t\t\tHit any key to continue"
	read -n 1 line
done
