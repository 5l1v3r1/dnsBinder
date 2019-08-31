#!/bin/bash
######################################################################
# SCRIPT NAME : ./dnsBinder.sh
######################################################################
#
# CHORFA Alla-eddine a.k.a. Dino
# h4ckr213dz@gmail.com
# https://github.com/dino213dz
#
# Description: Get target version using DNS BIND
# Created: 08/06/19
# Updated: 30/06/19
# Version: 1.0
#		___.___    ~            _____________
#		\  \\  \   ,, ???      |        '\\\\\\
#		 \  \\  \ /<   ?       |        ' ____|_
#		  --\//,- \_.  /_____  |        '||::::::
#		      o- /   \_/    '\ |        '||_____|
#		      | \ '   o       '________|_____|
#		      |  )-   #     <  ___/____|___\___
#		      `_/'------------|    _    '  <<<:|
#	        	  /________\| |_________'___o_o|
#
######################################################################
# VARIABLES:
######################################################################

#SCRIPT VARS:
d213_author="CHORFA Alla-eddine a.k.a. Dino"
d213_email="h4ckr213dz@gmail.com"
d213_website="https://github.com/dino213dz"
d213_version="1.0"
d213_created="08/06/19"
d213_updated="30/06/19"

#STYLE VARS:
declare -A d213_colors=( ['red']="\033[1;31m" ['yellow']="\033[1;33m" ['green']="\033[1;32m" ['cyan']="\033[1;36m" ['blue']="\033[1;34m" ['magenta']="\033[1;35m" ['white']="\033[1;37m" ['black']="\033[1;30m" )
declare -A d213_styles=( ['reset']="\033[0m" ['italic']="\033[1;31m" ['bold']="\033[1;31m" ['underlined']="\033[1;31m" ['blink']="\033[1;31m" )
declare -A d213_puces=( ['plus']="[+] " ['minus']=" |_[-] " )

#TEXTE STYLES VARS
style_title=${d213_colors["yellow"]}""${d213_puces["plus"]}
style_subtitle=${d213_colors["yellow"]}""${d213_puces["minus"]}
style_subsubtitle=${d213_colors["yellow"]}"  "${d213_puces["minus"]}


fichier_temp='./tmp.out'
banner='ICAgXyAgICAgICAgIF9fX19fIF8gICAgICAgXyAgICAgICAgIAogX3wgfF9fXyBfX198IF9fICB8X3xfX18gX3wgfF9fXyBfX18gCnwgLiB8ICAgfF8gLXwgX18gLXwgfCAgIHwgLiB8IC1ffCAgX3wKfF9fX3xffF98X19ffF9fX19ffF98X3xffF9fX3xfX198X3wgIAo='
outputActivated='FALSE'
portParDefaut="53"
portDns="$portParDefaut"

######################################################################
# FUNCTIONS:
######################################################################
function afficherAide {
	echo -e '- Syntaxe:
   - dnsBinder.sh [-d|--domain|--domaine] dns_server [-o|--output|--sortie output_file]
- Examples
   - dnsBinder.sh -d "ns01.example.com"
   - dnsBinder.sh --domain "ns01.example.com"
   - dnsBinder.sh --domaine "ns01.example.com"
   - dnsBinder.sh -d "ns01.example.com" -o dns_example_information.txt
   - dnsBinder.sh -d "ns01.example.com" --output dns_example_information.txt
   - dnsBinder.sh -d "ns01.example.com" --sortie dns_example_information.txt'	
	}
function RequeteNslookup {
	taille_min_reponse_requete=3
	requete=$(nslookup -q=txt -class=CHAOS port=$portDns version.bind $dnsServer 2>&1|grep -i 'VERSION.BIND'|cut -d '"' -f 2)
	if [ ${#requete} -lt $taille_min_reponse_requete ];then
		requete="Error: Aucune réponse/No response"
	fi
	echo $requete		
	}
function RequeteDig {
	type=$1
	requete_traitee=''
	total=0
	taille_min_reponse_requete=5
	#AUTHORS BIND
	if [ "$type" = "AUTHORS" ];then
		requete=$(dig -t txt -c chaos AUTHORS.BIND @$dnsServer -p $portDns 2>&1|sort -u > "$fichier_temp")
		nb_lignes=$(cat $fichier_temp|wc -l)
		#si reponse vide
		if [ $nb_lignes -lt $taille_min_reponse_requete ];then
			requete="Error: No response"
		elif [[ $requete =~ "couldn't get address" ]];then
			requete="Error: DNS server not reachable"
		#si reponse valable
		else
			while read -r ligne ;do
				ligne=${ligne/AUTHORS.BIND*TXT/VERBTXT}
				ligne=${ligne//'"'/''}
				ligne=${ligne//'  '/' '}
				if [[ "$ligne" =~ "VERBTXT" ]];then
					#nom moins de 2 cars (inclus quillemets)
					ligne=${ligne/VERBTXT/""}
					if [[ ${#ligne} -gt 4 ]];then
						total=$(($total+1))
						requete_traitee="$requete_traitee   "${d213_colors["yellow"]}"   \02 ├─¤"${d213_colors["green"]}"$ligne\n" # n° $total:
					fi
				fi
			done < $fichier_temp
			requete="$requete_traitee"
			requete="\n $requete   "${d213_colors["yellow"]}"   \02 └─■ Total:"${d213_colors["cyan"]}" $total"
		fi
	#VERSION.BIND	,ID.BIND,	HOSTNAME.BIND
	else		
		if [ "$type" = "ID" ];then
			bind_type="SERVER"
		else
			bind_type="BIND"
		fi
		requete=$(dig -t txt -c chaos $type.$bind_type @$dnsServer -p $portDns 2>&1 |egrep -i "$type.$bind_type.*CH.*TXT"|sed "s/.*TXT//g"|sed 's/"//g' )
		#si serveur introuvable
		if [ ${#requete} -lt $taille_min_reponse_requete ];then
			requete="Error: No response"
		elif [[ $requete =~ "couldn't get address" ]];then
			requete="Error: DNS server not reachable"
		fi

	fi
	echo $requete	
	}
######################################################################
# ARGS:
######################################################################
args=("$@")
nb_args=$#
for no_arg in $(seq 0 $nb_args); do
	value=${args[$no_arg]}
	if [ ${#value} -gt 0 ];then
		if [ "$value" = "--help" ] || [ "$value" = "-h" ];then
			afficherAide
			exit
		fi
		if [ "$value" = "--domain" ] || [ "$value" = "--domaine" ] || [ "$value" = "-d" ];then
			dnsServer=${args[$(($no_arg+1))]}
		fi
		if [ "$value" = "--port" ] || [ "$value" = "-p" ];then
			portDns=${args[$(($no_arg+1))]}
		fi
		if [ "$value" = "--output" ] || [ "$value" = "--sortie" ] || [ "$value" = "-o" ];then
			outputActivated='TRUE'
			outputFile=${args[$(($no_arg+1))]}
		fi
	fi
done

######################################################################
# MAIN PROGRAM:
######################################################################

echo -e ${d213_colors["yellow"]}
echo $banner|base64 -d
echo -e ${d213_styles["green"]}"\t\tVersion $d213_version\n"

#verifs
if [ ${#dnsServer} -eq 0 ];then
	echo -e "Error:\nNeed DNS server name or ip: [--domain|-d]\n"
	afficherAide
	exit
else
	echo -e ${d213_colors["yellow"]}"■ DNS Server: "${d213_colors["green"]}$dnsServer${d213_styles["reset"]}
	echo -e ${d213_colors["yellow"]}" └─■ PORT: "${d213_colors["green"]}$portDns${d213_styles["reset"]}
fi

#verifs
if [ ${#outputFile} -ne 0 ];then
	echo -e ${d213_colors["yellow"]}"■ Output file: "${d213_colors["green"]}$outputFile${d213_styles["reset"]}
fi

# PARAMS
echo -e ""
######################################################################
# VERSION.BIND
echo -e ${d213_colors["yellow"]}"■ VERSION.BIND: "${d213_styles["reset"]}
# NSLOOKUP
#echo -en ${d213_colors["yellow"]}" ├─■ NSLOOKUP REQUEST: "${d213_styles["reset"]}
#requete 
#requete_nslookup_ver=$(RequeteNslookup)
#afficher le resultat de la requete
#if [[ $requete_nslookup_ver =~ "Error:" ]];then
#	echo -e ${d213_colors["red"]}""$requete_nslookup_ver""${d213_styles["reset"]}
#else
#	echo -e ${d213_colors["green"]}""$requete_nslookup_ver""${d213_styles["reset"]}
#fi
# DIG
echo -en ${d213_colors["yellow"]}" └─■ DIG REQUEST: "${d213_styles["reset"]}
#requete 
requete_dig_ver=$(RequeteDig "VERSION")
#afficher le resultat de la requete
if [[ $requete_dig_ver =~ "Error:" ]];then
	echo -e ${d213_colors["red"]}""$requete_dig_ver""${d213_styles["reset"]}
else
	echo -e ${d213_colors["green"]}""$requete_dig_ver""${d213_styles["reset"]}
fi
######################################################################
echo -e ""
# AUTHORS.BIND
echo -e ${d213_colors["yellow"]}"■ AUTHORS.BIND: "${d213_styles["reset"]}
# DIG
echo -en ${d213_colors["yellow"]}" └─■ DIG REQUEST: "${d213_styles["reset"]}
#requete 
requete_dig_authors=$(RequeteDig "AUTHORS")
#afficher le resultat de la requete
if [[ $requete_dig_authors =~ "Error:" ]];then
	echo -e ${d213_colors["red"]}""$requete_dig_authors""${d213_styles["reset"]}
else
	echo -e ${d213_colors["green"]}""$requete_dig_authors""${d213_styles["reset"]}
fi
######################################################################
echo -e ""
# HOSTNAME.BIND
echo -e ${d213_colors["yellow"]}"■ HOSTNAME.BIND: "${d213_styles["reset"]}
# DIG
echo -en ${d213_colors["yellow"]}" └─■ DIG REQUEST: "${d213_styles["reset"]}
#requete 
requete_dig_hostname=$(RequeteDig "HOSTNAME")
#afficher le resultat de la requete
if [[ $requete_dig_hostname =~ "Error:" ]];then
	echo -e ${d213_colors["red"]}""$requete_dig_hostname""${d213_styles["reset"]}
else
	echo -e ${d213_colors["green"]}""$requete_dig_hostname""${d213_styles["reset"]}
fi
######################################################################
echo -e ""
# ID.BIND
echo -e ${d213_colors["yellow"]}"■ ID.SERVER: "${d213_styles["reset"]}
# DIG
echo -en ${d213_colors["yellow"]}" └─■ DIG REQUEST: "${d213_styles["reset"]}
#requete 
requete_dig_id=$(RequeteDig "ID")
#afficher le resultat de la requete
if [[ $requete_dig_id =~ "Error:" ]];then
	echo -e ${d213_colors["red"]}""$requete_dig_id""${d213_styles["reset"]}
else
	echo -e ${d213_colors["green"]}""$requete_dig_id""${d213_styles["reset"]}
fi
######################################################################
# EXPOER TO OUTPUT FILE:
######################################################################

if [ "$outputActivated" = 'TRUE' ] ;then
	requete_dig_authors_for_output=""${requete_dig_authors//'\'${d213_colors["yellow"]}/""}
	requete_dig_authors_for_output=${requete_dig_authors_for_output//'\'${d213_colors["green"]}/""}
	requete_dig_authors_for_output=${requete_dig_authors_for_output//'\'${d213_colors["cyan"]}/""}
	requete_dig_authors_for_output=${requete_dig_authors_for_output//'■'/''}
	requete_dig_authors_for_output=${requete_dig_authors_for_output//'¤'/''}
	requete_dig_authors_for_output=${requete_dig_authors_for_output//'└'/''}
	requete_dig_authors_for_output=${requete_dig_authors_for_output//'├'/''}
	requete_dig_authors_for_output=${requete_dig_authors_for_output//'─'/'-'}
	requete_dig_authors_for_output=${requete_dig_authors_for_output//'\02'/''}
	requete_dig_authors_for_output=${requete_dig_authors_for_output//'\\02'/''}
	echo -e "SERVER: $dnsServer" > $outputFile
	echo -e "DATE: "$(/bin/date "+%c")"" >> $outputFile
	echo -e "VERSION BIND:" >> $outputFile
	#echo -e " - NSLOOKUP: $requete_nslookup_ver" >> $outputFile
	echo -e " - DIG REQUEST: $requete_dig_ver" >> $outputFile
	echo -e "AUTHORS BIND:" >> $outputFile
	echo -e " - DIG REQUEST: $requete_dig_authors_for_output" >> $outputFile
	echo -e "HOSTNAME BIND:" >> $outputFile
	echo -e " - DIG REQUEST: $requete_dig_hostname" >> $outputFile
	echo -e "ID BIND:" >> $outputFile
	echo -e " - DIG REQUEST: $requete_dig_id" >> $outputFile
	
fi

######################################################################
# END:
######################################################################

rm -f $fichier_temp 2>&1 >/dev/null
#echo -e ${d213_colors["cyan"]}"Program End"${d213_styles["reset"]}

