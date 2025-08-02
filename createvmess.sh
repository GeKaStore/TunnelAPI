#!/bin/bash
#  ·· 
#  System Request  Debian 9+/Ubuntu 18.04+/20+
#  Develovers  MikkuChan
#  Email       fadztechs2@gmail.com
#  telegram    https://t.me/fadzdigital
#  whatsapp    wa.me/+6285727035336
#  ·· 

# ==================== KONFIGURASI HTTP ====================
# Jika dipanggil via web server (http), set output sebagai JSON
if [[ "$REQUEST_METHOD" == "GET" ]]; then
  # Ambil parameter dari query string
  user=$(echo "$QUERY_STRING" | grep -oE '(^|&)user=[^&]*' | cut -d= -f2)
  masaaktif=$(echo "$QUERY_STRING" | grep -oE '(^|&)exp=[^&]*' | cut -d= -f2)
  Quota=$(echo "$QUERY_STRING" | grep -oE '(^|&)quota=[^&]*' | cut -d= -f2)
  iplimit=$(echo "$QUERY_STRING" | grep -oE '(^|&)iplimit=[^&]*' | cut -d= -f2)
  auth=$(echo "$QUERY_STRING" | grep -oE '(^|&)auth=[^&]*' | cut -d= -f2)
  
  # Validasi auth key
  source .env
  valid_auth=$AUTHKEY
  if [[ "$auth" != "$valid_auth" ]]; then
    echo -e "Content-Type: application/json\r\n"
    echo '{"status": "error", "message": "Invalid authentication key"}'
    exit 1
  fi
  
  # Validasi parameter wajib
  if [[ -z "$user" || -z "$masaaktif" || -z "$Quota" || -z "$iplimit" ]]; then
    echo -e "Content-Type: application/json\r\n"
    echo '{"status": "error", "message": "Missing required parameters"}'
    exit 1
  fi
  
  # Generate UUID jika auto atau kosong
  uuid=$(cat /proc/sys/kernel/random/uuid)
  
  # Set flag non-interactive
  non_interactive=true
fi

# ==================== KONFIGURASI AWAL ====================
RRED="\033[31m"
YELLOW="\033[33m"
NC='\e[0m'
YELL='\033[0;33m'
BRED='\033[1;31m'
GREEN='\033[0;32m'
ORANGE='\033[33m'
BGWHITE='\e[0;100;37m'

# Warna ANSI untuk tampilan terminal
RED='\033[1;91m'
GREEN='\033[1;92m'
YELLOW='\033[1;93m'
BLUE='\033[1;94m'
CYAN='\033[1;96m'
WHITE='\033[1;97m'
NC='\033[0m' # Reset warna

# ==================== VALIDASI SCRIPT ====================
# Hanya jalankan validasi jika tidak dalam mode non-interactive
if [[ "$non_interactive" != "true" ]]; then
  clear
  echo -e "\e[32mloading...\e[0m"
  clear
  
  # Validasi permission VPS
  echo -e "${CYAN}${NC}"
  echo -e " ${WHITE}MEMERIKSA PERMISSION VPS...${NC}"
  echo -e "${CYAN}${NC}"
  echo -e " ${GREEN}Mengambil IP VPS${NC}"
  ipsaya=$(curl -sS ipv4.icanhazip.com)
  echo -e " ${GREEN}Mengambil Data Server${NC}"
  data_server=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
  date_list=$(date +"%Y-%m-%d" -d "$data_server")
  data_ip="https://raw.githubusercontent.com/GeKaStore
  /Register/main/register"

  checking_sc() {
    useexp=$(wget -qO- $data_ip | grep $ipsaya | awk '{print $3}')
    if [[ $date_list < $useexp ]]; then
      echo -ne
    else
      clear
      echo -e "${RED}${NC}"
      echo -e " ${WHITE}PERMISSION DENIED!${NC}"
      echo -e "${RED}${NC}"
      echo -e " VPS Anda: $ipsaya"
      echo -e " Status: ${RED}Diblokir${NC}"
      echo -e ""
      echo -e " Hubungi admin untuk membeli akses."
      echo -e "${RED}${NC}"
      exit 0
    fi
  }
  checking_sc
  clear
fi

# ==================== KONFIGURASI DOMAIN ====================
source /var/lib/kyt/ipvps.conf
if [[ "$IP" = "" ]]; then
  domain=$(cat /etc/xray/domain)
else
  domain=$IP
fi

# ==================== PROSES PEMBUATAN AKUN ====================
# Jika dalam mode non-interactive, langsung buat akun tanpa prompt
if [[ "$non_interactive" == "true" ]]; then
  # Validasi username tidak boleh kosong
  if [[ -z "$user" ]]; then
    printf '{"status": "error", "message": "Username cannot be empty"}'
    exit 1
  fi
  
  # Validasi karakter username (hanya alphanumeric, dash, underscore)
  if [[ ! "$user" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    printf '{"status": "error", "message": "Username hanya boleh menggunakan huruf, angka, - dan _"}'
    exit 1
  fi

  # Cek duplikasi username
  user_exists_config=false
  if grep -q "\"email\"[[:space:]]*:[[:space:]]*\"$user\"" /etc/xray/config.json; then
    user_exists_config=true
  fi

  user_exists_db=false
  if [[ -f "/etc/vmess/.vmess.db" ]]; then
    if grep -q "^### $user " /etc/vmess/.vmess.db; then
      user_exists_db=true
    fi
  fi

  if [[ "$user_exists_config" == "true" ]] || [[ "$user_exists_db" == "true" ]]; then
    printf '{"status": "error", "message": "Username already exists"}'
    exit 1
  fi
  
  # Validasi masa aktif
  if ! [[ "$masaaktif" =~ ^[0-9]+$ ]] || [[ "$masaaktif" -le 0 ]]; then
    printf '{"status": "error", "message": "Masa aktif harus angka positif"}'
    exit 1
  fi
  
  # Validasi quota
  if ! [[ "$Quota" =~ ^[0-9]+$ ]]; then
    printf '{"status": "error", "message": "Quota harus angka"}'
    exit 1
  fi
  
  # Validasi iplimit
  if ! [[ "$iplimit" =~ ^[0-9]+$ ]]; then
    printf '{"status": "error", "message": "IP limit harus angka"}'
    exit 1
  fi
  
  # Hitung tanggal kadaluarsa
  tgl=$(date -d "$masaaktif days" +"%d")
  bln=$(date -d "$masaaktif days" +"%b")
  thn=$(date -d "$masaaktif days" +"%Y")
  expe="$tgl $bln, $thn"
  tgl2=$(date +"%d")
  bln2=$(date +"%b")
  thn2=$(date +"%Y")
  tnggl="$tgl2 $bln2, $thn2"
  exp=$(date -d "$masaaktif days" +"%Y-%m-%d")
  
  # Proses pembuatan akun VMESS
  sed -i '/#vmess$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","alterId": '"0"',"email": "'""$user""'"' /etc/xray/config.json
  sed -i '/#vmessgrpc$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","alterId": '"0"',"email": "'""$user""'"' /etc/xray/config.json

  # Buat konfigurasi VMESS
  asu=`cat<<EOF
      {
      "v": "2",
      "ps": "${user}",
      "add": "${domain}",
      "port": "443",
      "id": "${uuid}",
      "aid": "0",
      "net": "ws",
      "path": "/vmess",
      "type": "none",
      "host": "${domain}",
      "tls": "tls"
}
EOF`
  ask=`cat<<EOF
      {
      "v": "2",
      "ps": "${user}",
      "add": "${domain}",
      "port": "80",
      "id": "${uuid}",
      "aid": "0",
      "net": "ws",
      "path": "/vmess",
      "type": "none",
      "host": "${domain}",
      "tls": "none"
}
EOF`
  grpc=`cat<<EOF
      {
      "v": "2",
      "ps": "${user}",
      "add": "${domain}",
      "port": "443",
      "id": "${uuid}",
      "aid": "0",
      "net": "grpc",
      "path": "vmess-grpc",
      "type": "none",
      "host": "${domain}",
      "tls": "tls"
}
EOF`
  
  vmesslink1="vmess://$(echo $asu | base64 -w 0)"
  vmesslink2="vmess://$(echo $ask | base64 -w 0)"
  vmesslink3="vmess://$(echo $grpc | base64 -w 0)"
  
  # Restart layanan
  systemctl restart xray > /dev/null 2>&1
  service cron restart > /dev/null 2>&1

  # Buat file konfigurasi
  cat >/var/www/html/vmess-$user.txt <<-END
           # FORMAT OpenClash #

# Format Vmess WS TLS
- name: Vmess-$user-WS TLS
  type: vmess
  server: ${domain}
  port: 443
  uuid: ${uuid}
  alterId: 0
  cipher: auto
  udp: true
  tls: true
  skip-cert-verify: true
  servername: ${domain}
  network: ws
  ws-opts:
    path: /vmess
    headers:
      Host: ${domain}

# Format Vmess WS Non TLS
- name: Vmess-$user-WS Non TLS
  type: vmess
  server: ${domain}
  port: 80
  uuid: ${uuid}
  alterId: 0
  cipher: auto
  udp: true
  tls: false
  skip-cert-verify: false
  servername: ${domain}
  network: ws
  ws-opts:
    path: /vmess
    headers:
      Host: ${domain}

# Format Vmess gRPC
- name: Vmess-$user-gRPC (SNI)
  server: ${domain}
  port: 443
  type: vmess
  uuid: ${uuid}
  alterId: 0
  cipher: auto
  network: grpc
  tls: true
  servername: ${domain}
  skip-cert-verify: true
  grpc-opts:
    grpc-service-name: vmess-grpc

              #  VMESS WS TLS #
${vmesslink1}

         # VMESS WS NON TLS #
${vmesslink2}

           # VMESS WS gRPC #
${vmesslink3}
END

  # Set limit IP jika diperlukan
  if [[ $iplimit -gt 0 ]]; then
    mkdir -p /etc/kyt/limit/vmess/ip
    echo -e "$iplimit" > /etc/kyt/limit/vmess/ip/$user
  fi

  # Set quota jika diperlukan
  if [ -z ${Quota} ]; then
    Quota="0"
  fi

  c=$(echo "${Quota}" | sed 's/[^0-9]*//g')
  d=$((${c} * 1024 * 1024 * 1024))

  if [[ ${c} != "0" ]]; then
    echo "${d}" >/etc/vmess/${user}
  fi

  # Update database
  DATADB=$(cat /etc/vmess/.vmess.db | grep "^###" | grep -w "${user}" | awk '{print $2}')
  if [[ "${DATADB}" != '' ]]; then
    sed -i "/\b${user}\b/d" /etc/vmess/.vmess.db
  fi
  echo "### ${user} ${exp} ${uuid} ${Quota} ${iplimit}" >>/etc/vmess/.vmess.db

  # Kirim notifikasi Telegram (jika ada konfigurasi)
  if [ -f "/etc/telegram_bot/bot_token" ] && [ -f "/etc/telegram_bot/chat_id" ]; then
    BOT_TOKEN=$(cat /etc/telegram_bot/bot_token)
    CHAT_ID=$(cat /etc/telegram_bot/chat_id)
    
    location=$(curl -s ipinfo.io/json)
    CITY=$(echo "$location" | jq -r '.city')
    ISP=$(echo "$location" | jq -r '.org')
    MYIP=$(curl -s ifconfig.me)
    
    CITY=${CITY:-"Unknown"}
    ISP=${ISP:-"Unknown"}
    
    TEXT="<b>━━━━━━ 𝙑𝙈𝙀𝙎𝙎 𝙋𝙍𝙀𝙈𝙄𝙐𝙈 ━━━━━</b>

<b>👤 𝙐𝙨𝙚𝙧 𝘿𝙚𝙩𝙖𝙞𝙡𝙨</b>
┣ <b>Username</b>   : <code>$user</code>
┣ <b>UUID</b>       : <code>$uuid</code>
┣ <b>Quota</b>      : <code>${Quota} GB</code>
┣ <b>Status</b>     : <code>Aktif $masaaktif hari</code>
┣ <b>Dibuat</b>     : <code>$tnggl</code>
┗ <b>Expired</b>    : <code>$expe</code>

<b>🌎 𝙎𝙚𝙧𝙫𝙚𝙧 𝙄𝙣𝙛𝙤</b>
┣ <b>Domain</b>     : <code>$domain</code>
┣ <b>IP</b>         : <code>$MYIP</code>
┣ <b>Location</b>   : <code>$CITY</code>
┗ <b>ISP</b>        : <code>$ISP</code>

<b>🔗 𝘾𝙤𝙣𝙣𝙚𝙘𝙩𝙞𝙤𝙣</b>
┣ <b>TLS Port</b>        : <code>400-900</code>
┣ <b>Non-TLS Port</b>    : <code>80, 8080, 8081-9999</code>
┣ <b>Network</b>         : <code>ws, grpc</code>
┣ <b>Path</b>            : <code>/vmess</code>
┣ <b>gRPC Service</b>    : <code>vmess-grpc</code>
┣ <b>Security</b>        : <code>auto</code>
┗ <b>alterId</b>         : <code>0</code>

<b>━━━━━ 𝙑𝙈𝙀𝙎𝙎 𝙋𝙧𝙚𝙢𝙞𝙪𝙢 𝙇𝙞𝙣𝙠𝙨 ━━━━━</b>
<b>📍 𝙒𝙎 𝙏𝙇𝙎</b>
<pre>$vmesslink1</pre>
<b>📍 𝙒𝙎 𝙉𝙤𝙣-𝙏𝙇𝙎</b>
<pre>$vmesslink2</pre>
<b>📍 𝙜𝙍𝙋𝘾</b>
<pre>$vmesslink3</pre>

<b>📥 𝘾𝙤𝙣𝙛𝙞𝙜 𝙁𝙞𝙡𝙚 (Clash/OpenClash):</b>
➤ https://${domain}:81/vmess-$user.txt

<b>✨ 𝙏𝙤𝙤𝙡𝙨 & 𝙍𝙚𝙨𝙤𝙪𝙧𝙘𝙚𝙨</b>
┣  https://vpntech.my.id/converteryaml
┗  https://vpntech.my.id/auto-configuration

<b>❓ 𝘽𝙪𝙩𝙪𝙝 𝘽𝙖𝙣𝙩𝙪𝙖𝙣?</b>
➤ https://wa.me/6285727035336

<b>━━━━━━━━━ 𝙏𝙝𝙖𝙣𝙠 𝙔𝙤𝙪 ━━━━━━━━</b>
"
    TEXT_ENCODED=$(echo "$TEXT" | jq -sRr @uri)
    curl -s -d "chat_id=$CHAT_ID&disable_web_page_preview=1&text=$TEXT_ENCODED&parse_mode=html" "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" > /dev/null 2>&1
  fi

  # Output JSON untuk response HTTP
  printf "{
    \"status\": \"success\",
    \"username\": \"$user\",
    \"uuid\": \"$uuid\",
    \"domain\": \"$domain\",
    \"expired\": \"$exp\",
    \"quota_gb\": \"$Quota GB\",
    \"ip_limit\": \"$iplimit\",
    \"created\": \"$tnggl\",
    \"ws_tls\": \"$vmesslink1\",
    \"ws_ntls\": \"$vmesslink2\",
    \"grpc\": \"$vmesslink3\"
  }"
  exit 0
fi