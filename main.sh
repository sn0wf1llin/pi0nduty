#/bin/bash
# get scannow.txt and updateinfo.txt
# read
# scan every host in scannow.txt & place info in now.txt
# scan every in updateinfo.txt & place in update.txt

source ./utils.sh

FILE_SCANNOW=
FILE_SCANNOW_RESULTS=
VERBOSE=1
DEFAULT_HEADER=$(perl -e 'print "="x64 . "VVVV" . "="x64')
DEFAULT_FOOTER=$(perl -e 'print "="x64 . "XXXX" . "="x64')
DEFAULT_SEP=$(perl -e 'print "="x40')

function myprint(){
  if [ ! -z $VERBOSE ];
    then echo $1
  fi
}

function check_dependencies(){
  local check_name="nmap check"
  local nmap_path=`which nmap`
  local checkdep_res=
  if [ -z $nmap_path ]; then
    checkdep_res="Error: no nmap binary found"
  else
    checkdep_res="nmap found: $nmap_path"
  fi
  write_portion "$check_name $checkdep_res" $FILE_SCANNOW_RESULTS $DEFAULT_SEP $DEFAULT_SEP

  check_name="proxychains4 check"
  local proxychains_path=`which proxychains4`
  if [ -z $proxychains_path ]; then
    checkdep_res="Error: no proxychains4 binary found"
  else
    checkdep_res="proxychains4 found: $proxychains_path"
  fi
  write_portion "$check_name $checkdep_res" $FILE_SCANNOW_RESULTS $DEFAULT_SEP $DEFAULT_SEP
}

function scan0(){
  local h=$1
  local ip=$2
  local scan_name="nmap 65535 paranoid"
  local scan_dt=$(date '+%d/%m/%Y %H:%M:%S')

  local nmap_binary=`which nmap`
  local proxychains_binary=`which proxychains4`
  local tempfile=`create_random_file scan`
  local nmap_params="-p80 -sV -T2 -v4 -oN $tempfile"

  $proxychains_binary $nmap_binary $ip $nmap_params 1>/dev/null 2>/dev/null
  write_portion "  $scan_dt start  [$scan_name] $h ($ip)" $FILE_SCANNOW_RESULTS $(perl -e 'print "-"x16') $(perl -e 'print "-"x16')
  cat $tempfile >> $FILE_SCANNOW_RESULTS
  write_portion "  $scan_dt finish [$scan_name]" $FILE_SCANNOW_RESULTS $(perl -e 'print "-"x16') $(perl -e 'print "-"x16')

  rm -f $tempfile
}

function scan1(){
  local h=$1
  local ip=$2
  local scan_name="scan 1"
  local scan_dt=$(date '+%d/%m/%Y %H:%M:%S')

  write_portion "  $scan_dt $scan_name $h ($ip)" $FILE_SCANNOW_RESULTS $DEFAULT_SEP $DEFAULT_SEP
}

function scan2(){
  local h=$1
  local ip=$2
  local scan_name="scan 2"
  local scan_dt=$(date '+%d/%m/%Y %H:%M:%S')

  write_portion "  $scan_dt $scan_name $h ($ip)" $FILE_SCANNOW_RESULTS $DEFAULT_SEP $DEFAULT_SEP
}

function scan_host(){
  local is_valid_ip=$(valid_ip $1)
  local IP=
  local HOST=

  if [[ $is_valid_ip ]]; then
    # IP provided
      IP=$1
      HOST=$(get_hostname $IP)
  else
    HOST=$1
    IP=`host $HOST | grep -i "has address" | cut -d ' ' -f4`
  fi

  write_portion "  Analyze $HOST ($IP)" $FILE_SCANNOW_RESULTS $DEFAULT_HEADER $DEFAULT_SEP
  scan0 $HOST $IP
  scan1 $HOST $IP
  scan2 $HOST $IP

  write_portion '' $FILE_SCANNOW_RESULTS '' $DEFAULT_FOOTER

}

function scannow(){
  local file_to_scan="$1"
  local file_results="$2"

  if [ -z $file_to_scan ]; then
    local default_scan_file="scannow.txt"
    myprint "No file given. Set to default: $default_scan_file";
    file_to_scan=$default_scan_file
  fi

  if [ ! -f $file_to_scan ]; then
    "File $file_to_scan not found. Exit"; exit 1
  else
    FILE_SCANNOW=$file_to_scan
  fi

  if [[ -z $file_results || ! -f $file_results ]]; then
    file_results=$(create_random_file results)
    FILE_SCANNOW_RESULTS=$file_results
    myprint "File $file_results not found. Set to $FILE_SCANNOW_RESULTS"
  fi

  myprint "  --> $FILE_SCANNOW_RESULTS ..."
  for host in `cat $FILE_SCANNOW`; do
    scan_host $host
  done;
}

# function updateinfo(){
#
#
# }

scannow $FILE_SCANNOW $FILE_SCANNOW_RESULTS
