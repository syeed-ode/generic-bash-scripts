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
	process_data_field
	setup_host_auth_headers
	execute_cmd
}

function process_data_field() {

	# ${data} is placed in double quotes so that when it is expanded
	# it is treated as a single word. If you don't do this the shell
	# will expand ${data} into individual words and the shell will 
	# complain that there are too many qrguments
	if [ -n "${data}" ]; then 
	# sometimes the variable being test will expand to nothing. The 
	# test will become [ -n ], which returns 'true'. Surrounding 
	# the variable in double quotes ensures there will be an empty
	# string as an argument (i.e. [ -n "" ])
		validate_data_field
	else
		echo "No data received"
	fi
}

function validate_data_field() {
	if [ "${path}" = *"_analyze"* ] && [ "${ES_VERSION}" == "2.4.6" ]; then
		echo "No validation required. data: ${data}"
	else 
		validate_json_data
	fi
}

# esrun -d '{"hello":"is it me youre looking for"}' GET /gb/_search

function validate_json_data() {
	data_json_attempt=$(echo ${data} | json_pp 2>$BAD_DATA)
	if [ $? -eq 0 ]; then 
		data="-d '${data}'"
	else
		data_json_attempt=$(cat $BAD_DATA)
		elasticsearch_usage 4
	fi
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
	elif [[ "$ES_VERSION" == "2.4.6" ]]; then
		port=":9200"
	fi
	host="http://localhost"
	set_x_method
	set_pretty_url
	execution_cmd="curl -i ${xmethod} ${auth_and_headers} '${host}${port}${uri}' ${data}"
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
	echo "$current_log_file" > $current_log_file
	echo "$ES_VERSION" >> $current_log_file
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
			usage_es 
			exit 1 ;;
		"2" )
			echo "Error: Program must supply valid uri portion of path"
			usage_es 
			exit 2 ;;
		"3" )
			echo "Error: Program was supplied incorrect option only option '-d' is supported"
			usage_es 
			exit 3 ;;
		"4" )
			echo "Error: JSON body is malformated.${new_line_charige_return}${data_json_attempt}${new_line_charige_return}data: ${new_line_charige_return}${data}"
			exit 4 ;;
	esac
}

function usage_es() {
			echo "usage: $filename [-d 'data' | -f filename] method path" 
			echo "where, "
			echo "      method: GET|geT|PoST|PoSt|PUT|put|HEAD|head"
			echo "          case insensitive"
			echo "      path: valid string"
			echo "      data: valid JSON (must be within single quotes)"
			echo "            or text string for analyzer 2.* (must be "
			echo "            within double quotes)"
			echo "      filename: file which contains valid json body"
}

clear
new_line_charige_return=$'\n \t'
while getopts ":d:f:" opt; do 
	case $opt in 
		d  ) 
			data=$OPTARG 
			;;
		f  )
			data=$(cat $OPTARG) 
			;;
		\? ) 
			elasticsearch_usage 3 
			;;
	esac
done

shift $(($OPTIND - 1))

collect_curl_parameters $@
