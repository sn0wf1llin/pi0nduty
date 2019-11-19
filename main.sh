#/bin/bash
# get scannow.txt and updateinfo.txt
# read
# scan every host in scannow.txt & place info in now.txt
# scan every in updateinfo.txt & place in update.txt

FILE_SCANNOW=
FILE_SCANNOW_RESULTS=
VERBOSE=
DEFAULT_HEADER=$(perl -e 'print "="x64 . "VVVV" . "="x64')
DEFAULT_FOOTER=$(perl -e 'print "="x64 . "XXXX" . "="x64')
DEFAULT_SEP=$(perl -e 'print "="x40')

function myprint(){
  if [ ! -z $VERBOSE ];
    then echo $1
  fi
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

function write_portion(){
  local message="$1"
  local file="$2"

  if [ ! -f $file ]; then
    echo "No found $file !!!"; exit 1
  fi

  local header="$3"
  local footer="$4"

  echo $header >> $file
  echo $message >> $file
  echo $footer >> $file
  echo >> $file
}

function scan0(){
  local h=$1
  local ip=$2
  local scan_name="scan 0"
  local scan_dt=$(date '+%d/%m/%Y %H:%M:%S')

  write_portion "  $scan_dt $scan_name $h ($i)" $FILE_SCANNOW_RESULTS $DEFAULT_SEP $DEFAULT_SEP


}

function scan1(){
  local h=$1
  local ip=$2
  local scan_name="scan 1"
  local scan_dt=$(date '+%d/%m/%Y %H:%M:%S')

  write_portion "  $scan_dt $scan_name $h ($i)" $FILE_SCANNOW_RESULTS $DEFAULT_SEP $DEFAULT_SEP
}

function scan2(){
  local h=$1
  local ip=$2
  local scan_name="scan 2"
  local scan_dt=$(date '+%d/%m/%Y %H:%M:%S')

  write_portion "  $scan_dt $scan_name $h ($i)" $FILE_SCANNOW_RESULTS $DEFAULT_SEP $DEFAULT_SEP
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

function create_random_file(){
  local random_name=$(cat /dev/urandom | tr -dc '0-9a-zA-Z' | fold -w 256 | head -n 1 | head --bytes 8)
  local file=/tmp/test # $random_name
  if [ -f $file ]; then
    rm -f $file
  fi
  touch $file
  echo $file
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
    file_results=$(create_random_file)
    FILE_SCANNOW_RESULTS=$file_results
    myprint "File $file_results not found. Set to $FILE_SCANNOW_RESULTS"
  fi

  for host in `cat $FILE_SCANNOW`; do
    scan_host $host
  done;
}

# function updateinfo(){
#
#
# }

scannow $FILE_SCANNOW $FILE_SCANNOW_RESULTS
