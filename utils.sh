#!/bin/bash

function create_random_file(){
  local postfix=
  if [ -z "$1" ]; then postfix="scan"
  else postfix="$1" ; fi

  local random_name="$(openssl rand -hex 8)_$postfix.txt"
  local file=$random_name
  if [ -f $file ]; then
    rm -f $file
  fi
  touch $file
  echo $file
}


function valid_ip(){
  local ip=$1
  local stat=1

  if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    OIFS=$IFS
    IFS='.'
    ip=($ip)
    IFS=$OIFS
    [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
        && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
    stat=$?
  fi
  return $stat
}

function get_hostname(){
  return `dig +short -x $1`
}

# write_portion MESSAGE FILE HEADER FOOTER
function write_portion(){
  local message="$1"
  local file="$2"

  if [ ! -f $file ]; then
    echo "No found $file !!!"; exit 1
  fi

  local header="$3"
  local footer="$4"

  echo -e $header >> $file
  echo -e $message >> $file
  echo -e $footer >> $file
}
