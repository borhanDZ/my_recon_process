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
        endpoints enumuration ...
        ${reset}\n" 


read -p "Enter domain name : " domain
#passive: using waymore search on wayback machine(archive.org)common crawal alienvault.com {include api keys: virustotal,urlscan}
waymore -i $domain -mode U -oU endp/waymore.txt  #gets urls without download contents
#passive using github-endpoints
github-endpoints -q -k -d target.com -t git_token -o $domain/endp/github-endpoints.txt
#passive using porch-pirate endpoints on postman.com sources
#porch-pirate -s $domain --urls > porch-pirate-urls
#active: katana from reconftw project .. https://github.com/six2dez/reconftw
if [[ -s "$domain/final_domains/all-httpx" ]]; then
   cat all-httpx | katana -jc -kf all -d 3 -fs rdn -rlm 10 -c 50 -o $domain/endp/katana.txt
else
   echo $domain | katana -jc -kf all -d 3 -fs rdn -rlm 10 -c 50 -o $domain/endp/katana.txt
fi
#gather and filter
cat $domain/endp/*.txt | grep -E "\."$domain".[com|net|co|io|tr|de|cm|io|edu|info|me]+$" | sort -u > $domain/endp/all_endp

# useful comm: extract subdomain that serve wordpress/cms/joomla contents
cat $domain/endp/all_endp | grep -aEi "(wp-|cms|joomla)" | sed -e 's/\.com/.com  /' | cut -d ' ' -f1 | sort -u > $domain/endp/bcms-subs
cat $domain/endp/all_endp | grep "%3D" > $domain/endp/logins
 
 
# remove unnacesary urls atatic contenets (css|ttf|img /them.. /lang.. paths ..etc)
cat $domain/endp/all_endp | sed 's/.js?/.js /' | cut -d ' ' -f1 | urless |grep -aEiv "cms/" | awk -F'/' '!seen[$NF]++' | sort -u > $domain/endp/pured_all_endp

#extract js files from waymore
cat $domain/endp/pured_all_endp | grep "\.js$" > $domain/endp/all-ext_js

#extracted parameters 

cat $domain/endp/pured_all_endp| grep  "?" | grep "=" > $domain/endp/pured_all_param
