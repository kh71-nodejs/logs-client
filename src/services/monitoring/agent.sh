#!/bin/bash
#
# NodeQuery Agent
#
# @version		0.7.7
# @date			2014-07-30
# @copyright	(c) 2014 http://nodequery.com
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# Set environment
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Agent version
version="0.7.7"

# Prepare values
function prep() {
  echo "$1" | sed -e 's/^ *//g' -e 's/ *$//g' | sed -n '1 p'
}

# Base64 values
function base() {
  echo "$1" | tr -d '\n' | base64 | tr -d '=' | tr -d '\n' | sed 's/\//%2F/g' | sed 's/\+/%2B/g'
}

# Integer values
function int() {
  echo ${1/\.*/}
}

# Filter numeric
function num() {
  case $1 in
  '' | *[!0-9\.]*) echo 0 ;;
  *) echo $1 ;;
  esac
}

# Agent version
version=$(prep "$version")

# System uptime
uptime=$(prep $(int "$(cat /proc/uptime | awk '{ print $1 }')"))

# Login session count
sessions=$(prep "$(who | wc -l)")

# Process count
processes=$(prep "$(ps axc | wc -l)")

# Process array
processes_array="$(ps axc -o uname:12,pcpu,rss,cmd --sort=-pcpu,-rss --noheaders --width 120)"
processes_array="$(echo "$processes_array" | grep -v " ps$" | sed 's/ \+ / /g' | sed '/^$/d' | tr "\n" ";")"

# File descriptors
file_handles=$(prep $(num "$(cat /proc/sys/fs/file-nr | awk '{ print $1 }')"))
file_handles_limit=$(prep $(num "$(cat /proc/sys/fs/file-nr | awk '{ print $3 }')"))

# OS details
os_kernel=$(prep "$(uname -r)")

if ls /etc/*release >/dev/null 2>&1; then
  os_name=$(prep "$(cat /etc/*release | grep '^PRETTY_NAME=\|^NAME=\|^DISTRIB_ID=' | awk -F\= '{ print $2 }' | tr -d '"' | tac)")
fi

if [ -z "$os_name" ]; then
  if [ -e /etc/redhat-release ]; then
    os_name=$(prep "$(cat /etc/redhat-release)")
  elif [ -e /etc/debian_version ]; then
    os_name=$(prep "Debian $(cat /etc/debian_version)")
  fi

  if [ -z "$os_name" ]; then
    os_name=$(prep "$(uname -s)")
  fi
fi

case $(uname -m) in
x86_64)
  os_arch=$(prep "x64")
  ;;
i*86)
  os_arch=$(prep "x86")
  ;;
*)
  os_arch=$(prep "$(uname -m)")
  ;;
esac

# CPU details
cpu_name=$(prep "$(cat /proc/cpuinfo | grep 'model name' | awk -F\: '{ print $2 }')")
cpu_cores=$(prep "$(($(cat /proc/cpuinfo | grep 'model name' | awk -F\: '{ print $2 }' | sed -e :a -e '$!N;s/\n/\|/;ta' | tr -cd \| | wc -c) + 1))")

if [ -z "$cpu_name" ]; then
  cpu_name=$(prep "$(cat /proc/cpuinfo | grep 'vendor_id' | awk -F\: '{ print $2 } END { if (!NR) print "N/A" }')")
  cpu_cores=$(prep "$(($(cat /proc/cpuinfo | grep 'vendor_id' | awk -F\: '{ print $2 }' | sed -e :a -e '$!N;s/\n/\|/;ta' | tr -cd \| | wc -c) + 1))")
fi

cpu_freq=$(prep "$(cat /proc/cpuinfo | grep 'cpu MHz' | awk -F\: '{ print $2 }')")

if [ -z "$cpu_freq" ]; then
  cpu_freq=$(prep $(num "$(lscpu | grep 'CPU MHz' | awk -F\: '{ print $2 }' | sed -e 's/^ *//g' -e 's/ *$//g')"))
fi

# RAM usage
ram_total=$(prep $(num "$(cat /proc/meminfo | grep ^MemTotal: | awk '{ print $2 }')"))
ram_free=$(prep $(num "$(cat /proc/meminfo | grep ^MemFree: | awk '{ print $2 }')"))
ram_cached=$(prep $(num "$(cat /proc/meminfo | grep ^Cached: | awk '{ print $2 }')"))
ram_buffers=$(prep $(num "$(cat /proc/meminfo | grep ^Buffers: | awk '{ print $2 }')"))
ram_usage=$((($ram_total - ($ram_free + $ram_cached + $ram_buffers)) * 1024))
ram_total=$(($ram_total * 1024))

# Swap usage
swap_total=$(prep $(num "$(cat /proc/meminfo | grep ^SwapTotal: | awk '{ print $2 }')"))
swap_free=$(prep $(num "$(cat /proc/meminfo | grep ^SwapFree: | awk '{ print $2 }')"))
swap_usage=$((($swap_total - $swap_free) * 1024))
swap_total=$(($swap_total * 1024))

# Disk usage
disk_total=$(prep $(num "$(($(df -P -B 1 | grep '^/' | awk '{ print $2 }' | sed -e :a -e '$!N;s/\n/+/;ta')))"))
disk_usage=$(prep $(num "$(($(df -P -B 1 | grep '^/' | awk '{ print $3 }' | sed -e :a -e '$!N;s/\n/+/;ta')))"))

# Disk array
disk_array=$(prep "$(df -P -B 1 | grep '^/' | awk '{ print $1" "$2" "$3";" }' | sed -e :a -e '$!N;s/\n/ /;ta' | awk '{ print $0 } END { if (!NR) print "N/A" }')")

# Active connections
if [ -n "$(command -v ss)" ]; then
  connections=$(prep $(num "$(ss -tun | tail -n +2 | wc -l)"))
else
  connections=$(prep $(num "$(netstat -tun | tail -n +3 | wc -l)"))
fi

# Network interface
nic=$(prep "$(ip route get 8.8.8.8 | grep dev | awk -F'dev' '{ print $2 }' | awk '{ print $1 }')")

if [ -z $nic ]; then
  nic=$(prep "$(ip link show | grep 'eth[0-9]' | awk '{ print $2 }' | tr -d ':')")
fi

# IP addresses and network usage
ipv4=$(prep "$(ip addr show $nic | grep 'inet ' | awk '{ print $2 }' | awk -F\/ '{ print $1 }' | grep -v '^127' | awk '{ print $0 } END { if (!NR) print "N/A" }')")
ipv6=$(prep "$(ip addr show $nic | grep 'inet6 ' | awk '{ print $2 }' | awk -F\/ '{ print $1 }' | grep -v '^::' | grep -v '^0000:' | grep -v '^fe80:' | awk '{ print $0 } END { if (!NR) print "N/A" }')")

if [ -d /sys/class/net/$nic/statistics ]; then
  rx=$(prep $(num "$(cat /sys/class/net/$nic/statistics/rx_bytes)"))
  tx=$(prep $(num "$(cat /sys/class/net/$nic/statistics/tx_bytes)"))
else
  rx=$(prep $(num "$(ip -s link show $nic | grep '[0-9]*' | grep -v '[A-Za-z]' | awk '{ print $1 }' | sed -n '1 p')"))
  tx=$(prep $(num "$(ip -s link show $nic | grep '[0-9]*' | grep -v '[A-Za-z]' | awk '{ print $1 }' | sed -n '2 p')"))
fi

# Average system load
load=$(prep "$(cat /proc/loadavg | awk '{ print $1" "$2" "$3 }')")

# Detailed system load calculation
time=$(date +%s)
stat=($(cat /proc/stat | head -n1 | sed 's/[^0-9 ]*//g' | sed 's/^ *//'))
cpu=$((${stat[0]} + ${stat[1]} + ${stat[2]} + ${stat[3]}))
io=$((${stat[3]} + ${stat[4]}))
idle=${stat[3]}

if [ -e ./nq-data.log ]; then
  data=($(cat ./nq-data.log))
  interval=$(($time - ${data[0]}))
  cpu_gap=$(($cpu - ${data[1]}))
  io_gap=$(($io - ${data[2]}))
  idle_gap=$(($idle - ${data[3]}))

  if [[ $cpu_gap > "0" ]]; then
    load_cpu=$(((1000 * ($cpu_gap - $idle_gap) / $cpu_gap + 5) / 10))
  fi

  if [[ $io_gap > "0" ]]; then
    load_io=$(((1000 * ($io_gap - $idle_gap) / $io_gap + 5) / 10))
  fi

  if [[ $rx > ${data[4]} ]]; then
    rx_gap=$(($rx - ${data[4]}))
  fi

  if [[ $tx > ${data[5]} ]]; then
    tx_gap=$(($tx - ${data[5]}))
  fi
fi

# System load cache
# echo "$time $cpu $io $idle $rx $tx" > ./nq-data.log

# Prepare load variables
rx_gap=$(prep $(num "$rx_gap"))
tx_gap=$(prep $(num "$tx_gap"))
load_cpu=$(prep $(num "$load_cpu"))
load_io=$(prep $(num "$load_io"))

echo "{'version':'$version', 'uptime':'$uptime', 'sessions':'$sessions', 'processes':'$processes', 'processes_array':'$processes_array', 'file_handles':'$file_handles', 'file_handles_limit':'$file_handles_limit', 'os_kernel':'$os_kernel', 'os_name':'$os_name', 'os_arch':'$os_arch', 'cpu_name':'$cpu_name', 'cpu_cores':'$cpu_cores', 'cpu_freq':'$cpu_freq', 'ram_total':'$ram_total', 'ram_usage':'$ram_usage', 'swap_total':'$swap_total', 'swap_usage':'$swap_usage', 'disk_array':'$disk_array', 'disk_total':'$disk_total', 'disk_usage':'$disk_usage', 'connections':'$connections', 'nic':'$nic', 'ipv4':'$ipv4', 'ipv6':'$ipv6', 'rx':'$rx', 'tx':'$tx', 'rx_gap':'$rx_gap', 'tx_gap':'$tx_gap', 'load':'$load', 'load_cpu':'$load_cpu', 'load_io':'$load_io'}"
