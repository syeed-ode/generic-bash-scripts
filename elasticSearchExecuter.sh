#!/bin/bash 

# This program executes elasticsearch 6.2.3 and 2.4.6 queries
# based upon a number of parameters and environtment  variables.




################################################################
#	ENVIRONMENT VARIABLES
#
# ES_VERSION - set externally by the 'es6' or 'es2' aliases
################################################################

################################################################
#	EXECUTION STEPS
#
# It is recommended that you execute the alias 'es2' or 'es6' 
# prior to running this script. It sets up the pertinent 
# environment variables prior to running:
#
# alias es6='export ES_VERSION=6.2.3;s;echo $ES_VERSION'
# alias es2='export ES_VERSION=2.4.3;s;echo $ES_VERSION'
#
# export current_log_file
#
# export ES_PASSWD
# 
################################################################


function collect_curl_parameters() {
	validate_url_method $@
	validate_path_variable $@
	setup_host_auth_headers
	execute_cmd
}

function validate_url_method() {
	method=$(echo ${1} | tr '[:lower:]' '[:upper:]')
	if [ "GET" == "${method}" ] || [ "POST" == "${method}" ] || [ "PUT" == "${method}" ] || [ "HEAD" == "${method}" ]; then
		echo $method
	else
		elasticsearch_usage 1
	fi
}

function validate_path_variable() {
	if [ "$#" -lt 2 ]; then
		elasticsearch_usage 2
	fi

	path="$2"
}

function setup_host_auth_headers() {
	get_host_and_auth
}

function get_host_and_auth() {
	# 2.4.6 or 6.2.3
	if [ "$ES_VERSION" == "6.2.3" ]; then
		port=":9623"
		auth_and_headers="-H \"content-type: application/json; charset=UTF-8\" --user elastic:${ES_PASSWD}"
	elif [[ "$ES_VERSION" == "2.4.3" ]]; then
		port=":9200"
	fi
	host="http://localhost"
	set_x_method
	set_pretty_url
	execution_cmd="curl -i ${xmethod} ${auth_and_headers} '${host}${port}${uri}'"
}

function set_x_method() {
	xmethod="-X"
	xmethod=$xmethod${method}
}

function set_pretty_url() {
	# assure the ampersand is escaped before storing in variable
	pretty=$'&pretty'
	if [[ "${path}" = *"?"* ]]; then
		uri=${path}${pretty}
	else
		uri=${path}"?pretty"
	fi
}

function execute_cmd() {
	new_line_charige_return=$'\n \t'
	# echo "In execute_cmd with execution_cmd: ${new_line_charige_return}$execution_cmd"
	echo "$current_log_file" > $current_log_file
	echo "$ES_VERSION" >> $current_log_file
	echo "$execution_cmd" >> $current_log_file
	echo >> $current_log_file
	eval $execution_cmd >> $current_log_file
	echo "$current_log_file" >> $current_log_file
	echo "$ES_VERSION" >> $current_log_file
	echo "$execution_cmd" >> $current_log_file
	cat $current_log_file
}

function elasticsearch_usage () {
	filename=$(basename $0)
	case $1 in
		"1" )
			echo "Error: Program must supply correct (case insensitive) method"
			usage_es ;;
		"2" )
			echo "Error: Program must supply valid uri portion of path"
			usage_es ;;
	esac
}

function usage_es() {
			echo "Usage: $filename method path" 
			echo "where, "
			echo "      mthod: GET|geT|PoST|PoSt|PUT|put|HEAD|head"
			echo "          case insensitive"
			echo "      path: valid string"
			exit 0
}

clear
collect_curl_parameters $@
