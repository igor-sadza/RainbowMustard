#!/bin/bash

function stop_all() {
        if [[ -n ${b_stop_all-} ]]; then
                running_vms=($(qm list | grep running | sed 's/ //g' | sed 's/[^0-9].*$//g'));
                running_cts=($(pct list | grep running | sed 's/ //g' | sed 's/[^0-9].*$//g'));

                if [[ -z $running_vms ]] && [[ -z $running_cts ]]; then
                        echo "Nothing to stop!"
                else
                        declare -a group=( "running_vms" "running_cts" );
                        for i in ${group[@]}; do
                                lst=${i[@]}
                                for j in ${!lst}; do
                                        suffix=$(echo -n $i | sed "s/[^ct]//g")
                                        if [[ "${suffix}" == "ct" ]]; then
                                                pct stop $j
                                                echo "container stoped: $j"
                                        else
                                                qm stop $j
                                                echo "virtual machine stoped: $j"
                                        fi
                                done
                        done
                fi
        fi
}

function stop_selected() {
        if [[ -n ${b_stop_selected-} ]]; then
                echo -n "Provide ids to stop (separated by space):"
                read -a id_array 
                if [[ ! -z $id_array ]]; then
                        running_vms=($(qm list | grep running | sed 's/ //g' | sed 's/[^0-9].*$//g'));
                        running_cts=($(pct list | grep running | sed 's/ //g' | sed 's/[^0-9].*$//g'));
                        declare -a group=( "running_vms" "running_cts" );

                        for i in ${id_array[@]}; do
                                for j in ${group[@]}; do
                                        lst=${j[@]}
                                        for k in ${!lst}; do
                                                suffix=$(echo -n $j | sed "s/[^ct]//g")
                                                if [[ "${suffix}" == "ct" ]]; then
                                                        if [[ "${k}" == "${i}" ]]; then
                                                                pct stop $k
                                                                echo "container stoped: $k"
                                                        fi
                                                else
                                                        if [[ "${k}" == "${i}" ]]; then
                                                                qm stop $k
                                                                echo "virtual machine stoped: $k"
                                                        fi
                                                fi
                                        done
                                done
                        done
                else
                        echo "Nothing to stop!"
                fi
        fi
}

function script_usage() {
cat << EOF
        Usage:
             -h | --help                  Displays this help.
        STOP FUNCTIONS:
            -sa | --stop-all              Stop all containers and virtual machines.
            -ss | --stop-selected         Stop selected containers and virtual machines.
EOF
}

function parse_params() {
        local param
        while [[ $# -gt 0 ]]; do
                param="$1"
                shift
                case $param in
                        -h | --help)
                                script_usage
                                exit 0
                        ;;
                        -sa | --stop-all)
                                b_stop_all=true
                                ;;
                        -ss | --stop-selected)
                                b_stop_selected=true
                                ;;
                        *)
                        echo "Invalid parameter was provided: $param"
                        ;;
                esac
        done
}

function main() {
         parse_params "$@"

         stop_all
         stop_selected
#        echo "$@"
}

if ! (return 0 2> /dev/null); then
    main "$@"
fi
