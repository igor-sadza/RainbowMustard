#!/bin/bash

# ------------------------------
# GLOBAL VARIABLES
# ------------------------------
GLOB_COLOR_RED='\033[0;31m'     # color - red 
GLOB_COLOR_GRE='\033[0;32m'     # color - green 
GLOB_COLOR_ORA='\033[0;95m'     # color - magneta 
GLOB_COLOR_CYA='\033[0;96m'     # color - cyan 
GLOB_COLOR_DEF='\033[0m'        # color - default 
GLOB_SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P);

GLOB_EXECUTED_COMAND_STATUS=""
GLOB_EXECUTED_COMAND_OUTPUT=""

# ------------------------------
# HELPER FUNCTIONS
# ------------------------------

#-> Function: helper_execute_command 
#-> ------------------------------
#-> description:        Install needed packages  
#-> parameters:         $1 - Function name
#->                     $2 - Script to execute
#->                     $3 - If quiet then add to eval &>/dev/null
#-> returns:            null

function helper_execute_command() {
        local m_function="$2";
#       echo ${#m_function[@]};

#       if [ ! -z "$(echo ${m_function[@]} | grep 'echo')" ]; then
#               echo "HERE"
#               for i in ${m_function[@]}; do
#                       echo $i
#               done
#       else
#               if [[ "$3" == "quiet" ]]; then
                        GLOB_EXECUTED_COMAND_OUTPUT=$(echo $(eval $2));
#               else
                        eval $2;# &>/dev/null);
#               fi
#       fi


        if [ $? -eq 0 ]; then
                GLOB_EXECUTED_COMAND_STATUS=0;
                echo -e -n "\nFunction:${GLOB_COLOR_ORA}$1${GLOB_COLOR_DEF} \nComand: [${GLOB_COLOR_CYA}${m_function[@]}${GLOB_COLOR_DEF}] \nStatus: ${GLOB_COLOR_GRE}PASS${GLOB_COLOR_DEF}\n"
        else
                GLOB_EXECUTED_COMAND_STATUS=1;
                echo -e -n "\nFunction:${GLOB_COLOR_ORA}$1${GLOB_COLOR_DEF} \nComand: [${GLOB_COLOR_CYA}$2${GLOB_COLOR_DEF}] \nStatus: ${GLOB_COLOR_RED}FAIL${GLOB_COLOR_DEF}\n"
        fi
};

#-> Function: preq_install_packages 
#-> ------------------------------
#-> description:        Install needed packages  
#-> parameters:         null
#-> returns:            null

function preq_install_packages() {
  local m_fun_name="preq_install_packages";     
  local m_pkg_list=( git python3-requests python3-dnspython haproxy certbot );
  helper_execute_command "$m_fun_name" "apt-get install -y $(echo ${m_pkg_list[@]})" "quiet"
};

#-> Function: preq_clone_sublist3r 
#-> ------------------------------
#-> description:        Clone Sublist3r python script
#-> parameters:         null
#-> returns:            null

function preq_clone_sublist3r() {
  local m_fun_name="preq_clone_sublist3r"

  helper_execute_command "$m_fun_name" "find . script | grep ." "quiet"

  if [ $GLOB_EXECUTED_COMAND_STATUS -eq "0" ]; then
    rm -r "$GLOB_SCRIPT_DIR/script"
  fi 

  # Clone script from repo 
  helper_execute_command "$m_fun_name" "git clone https://github.com/aboul3la/sublist3r.git script" #"quiet"
};





# ------------------------------
# GETERS 
# ------------------------------

#-> Function: get_public_ip
#-> ------------------------------
#-> description:        Check our public ip address.
#-> parameters:         null
#-> returns:            Pulibc ip address.

function get_public_ip() {
  local m_fun_name="get_public_ip";
  helper_execute_command $m_fun_name "wget -qO- http://checkip.dyndns.com/ | sed 's/^.*\([0-9]\{2,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\).*$/\1/g'" "quiet"
  #echo $GLOB_EXECUTED_COMAND_OUTPUT
}

#-> Function: get_list_of_our_domains_using_script
#-> ------------------------------
#-> description:        List sub domains using sublist3r script.
#->                     Check if domain is active pinging it.
#-> parameters:         $1 - Our domain (example.com)
#-> returns:            Prints all domains assiosiate with our public ip.

function get_list_of_our_domains_using_script () {
  local m_fun_name="get_list_of_our_domains";
  local m_domain="$1";
  local m_array_domains=();
  helper_execute_command "$m_fun_name" "python3 ${GLOB_SCRIPT_DIR}/script/sublist3r.py -d igor-sadza.pl -o domains_list" "quiet"

  get_public_ip
  local m_our_public_ip=$GLOB_EXECUTED_COMAND_OUTPUT
  echo $GLOB_EXECUTED_COMAND_OUTPUT

  input="${GLOB_SCRIPT_DIR}/domains_list"; 
  while IFS= read -r line; do 
        domain_ip=`ping -c 1 $line | grep PING | sed 's/^.*\([0-9]\{2,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\).*$/\1/g'`; 
        if [[ "$m_our_public_ip" == "$domain_ip" ]]; then
          echo $line
        fi
  done < "$input"
};

#-> Function: get_list_of_our_domains_using_file
#-> ------------------------------
#-> description:        Pass file with subdomains
#->                     Check if domain is active pinging it.
#-> parameters:         $1 - File with domains 
#-> returns:            Prints all domains assiosiate with our public ip.

function get_list_of_our_domains_using_file() {
  local m_fun_name="get_list_of_our_domains_using_file";

  get_public_ip;
  local m_our_public_ip=$GLOB_EXECUTED_COMAND_OUTPUT
  m_domains=();
  input="${GLOB_SCRIPT_DIR}/$1"; 
  while IFS= read -r line; do 
        domain_ip=`ping -c 1 $line | grep PING | sed 's/^.*\([0-9]\{2,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\).*$/\1/g'`; 
        if [[ "$m_our_public_ip" == "$domain_ip" ]]; then
          m_domains+=("$line")
        fi
  done < "$input"

  var=$( echo ${m_domains[@]})

  helper_execute_command "$m_fun_name" "echo $var"
};

# ------------------------------
# Main function
# ------------------------------

function main() {
        preq_install_packages

        #For autmate
#       preq_clone_sublist3r
#       get_list_of_our_domains_using_script "biomed.org.pl"

        get_list_of_our_domains_using_file "domain_list"
        domains=( $(echo $GLOB_EXECUTED_COMAND_OUTPUT) )

        domainsv2=();
        for i in ${domains[@]}; do
                tmp=$(echo -d $i);
                domainsv2+=( "$tmp" )
        done
        echo ${domainsv2[@]}

        certbot certonly --register-unsafely-without-email --agree-tos --standalone --cert-name cert "${domainsv2[@]}"
};

main
