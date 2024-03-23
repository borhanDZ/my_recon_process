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
	echo -e "\tC. Assetfinder"
	echo -e "\tD. findomain-linux"
	echo -e "\tE. cert.sh"
	echo -e "\tF. certspotter"
	echo -e "\tG. shuffledns"
	echo -e "\tH. Collect and resolve all subdomain"
	echo -e "\tI. subdomain takeover"
	echo -e "\tJ. Scanning for CORS Misconfiguration"
	echo -e "\tK. Archive based Scanning"
	echo -e "\tL. GF Pattern based Scanning"
	echo -e "\tM. Scanning for JS files"
	echo -e " "
	echo -e "\t1. Full Scan \n"
	echo -e "\t0. Exit Menu\n\n"
	echo -en "\t\tEnter an Option: "
	read -n 1 option
}
if [ -d /$domain/ ]
then
  echo " "
else
  mkdir -p $domain $domain/domain_enum $domain/final_domains $domain/takeovers $domain/diff-scans
fi

function Ammas {
	clear
    echo -e ${ORANGE}"\n[+] Amass Enumeration Started:- "
    amass enum -passive -d $domain -o $domain/Subdomains/amass.txt
}

function Subfinder {
	clear
	echo -e ${CP}"\n[+] subfinder Enumeration Started:- "
	subfinder -d $domain -o $domain/domain_enum/subfinder.txt
}

function Assetfinder {
	clear
	echo -e ${yellow}"\n[+] Assetfinder Enumeration Started:- "
  https://youtu.be/7AxNOn7dgfk?t=306  assetfinder -subs-only $domain | tee $domain/domain_enum/assetfinder.txt
}


function Findomain-linux {
    clear
	echo -e ${BLUE}"\n[+] findomain-linux Enumeration Started:- "
    findomain-linux --target $domain -u $domain/domain_enum/findomain.txt
}

function Cert {
	clear
	echo -e ${CPO}"\n[+] Crt.sh Enumeration Started:- "
	curl -s "https://crt.sh/?q=%.<domain>&output=json" | jq '.[].name_value' | sed 's/\"//g' | sed 's/\*\.//g' | sort -u > $domain/domain_enum/crt.txt
}

function Certspotter {
	clear
	echo -e ${CPO}"\n[+] Certspotter Enumeration Started:- "
	curl -s https://certspotter.com/api/v0/certs\?domain\=$1 | jq '.[].dns_names[]' | sed 's/\"//g' | sed 's/\*\.//g' | sort -u > $domain/domain_enum/crt.txt
}

function Shuffledns {
	clear
	echo -e ${CN}"\n[+] Shuffledns Enumeration Started:- "
    shuffledns -d $domain -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-20000.txt -r ~/tools/resolvers/resolver.txt -o $domain/domain_enum/shuffledns.txt
}
function Collect-Subdomains {
	clear
    echo -e ${CP}"\n[+] Collecting All Subdomains Into Single File:- "
    cat $domain/domain_enum/*.txt > $domain/domain_enum/all.txt
    echo " "
    echo -e ${BLUE}"\n[+] Resolving All Subdomains:- "
	shuffledns -d $domain -list $domain/domain_enum/all.txt -o $domain/final_domains/all-resolved.txt -r ~/tools/resolvers/resolver.txt
    echo " "
	echo -e ${PINK}"\n[+] Checking Services On Subdomains:- "
	cat $domain/final_domains/all-resolved.txt | httpx -threads 30 -o $domain/final_domains/all-httpx.txt
}

function takeover_check {
	clear
	echo -e ${CP}"\n[+] Searching For Subdomain TakeOver:- "
	subzy -hide_fails -targets $domain/domain_enum/all.txt | tee $domain/takeovers/subzy_takeover.txt
	subjack -w $domain/domain_enum/all.txt -t 100 -timeout 30 -o $domain/takeovers/subjack_takeover.txt -ssl
	echo "${magenta} [+] Running nuclei for finding potential takeovers${reset}"
	nuclei -update-templates
	nuclei -l $domain/domain_enum/all.txt -t ~/tools/nuclei-templates/takeovers/ -o $domain/takeovers/nuclei_takeover.txt
}

function fullscan {
	clear
	Ammas;;
	Subfinder;;
	Assetfinder;;
	Findomain-linux;;
	Cert;;
	Certspotter;;
	Shuffledns;;
	Collect-Subdomains;;
	takeover_check;;
}

function csp_ssl_subs {
	clear
    httpx -u mail.yahoo.com -csp-probe -silent -retries 2 | unfurl -u domains | sort -u > csp_sub.txt
	httpx -u mail.yahoo.com -tls-probe -silent -retries 2 | unfurl -u domains | sort -u > ssl_sub.txt

    #cat subdomains.txt | httpx -csp-probe -status-code -retries 2 -no-color | anew csp_probed.txt | cut -d ' ' -f1 | unfurl -u domains | anew -q csp_subdomains.txt
}

function blcscan {
	clear
        bash src/blcscan.sh
}
1
function corsscan 
	clear
        bash src/corsscan.sh
}

function xssscan {
	clear
        bash src/xssscan.sh
}

function sqliscan {
	clear
        bash src/sqliscan.sh
}

function lfiscan {
	clear
        bash src/lfiscan.sh
}

function fullscan {
	clear
    fullscan
}

read -p "Enter domain name : " domain

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
	
	J | j)
	corsscan ;;
	
	K | k)
	archivescan ;;
	
	L | l)
	gfpattern ;;
	
	M | m)
	jsrecon ;;
 
 	XSS | X | x)
	xssscan ;;
 
 	SQLi | S | s)
	sqliscan ;;

 	LFI | R | r)
	lfiscan ;;
 
	1)
	fullscan ;;
	
	*)
	clear
	echo "Wrong selection";;
	esac
	echo -en "\n\n\t\t\tHit any key to continue"
	read -n 1 line
done

clear