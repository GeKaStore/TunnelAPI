#!/bin/bash
# ─────────────────※ ·❆· ※─────────────────
# 𓈃 System Request ➠ Debian 9+/Ubuntu 18.04+/20+
# 𓈃 Develovers ➠ MikkuChan
# 𓈃 Email      ➠ fadztechs2@gmail.com
# 𓈃 telegram   ➠ https://t.me/fadzdigital
# 𓈃 whatsapp   ➠ wa.me/+6285727035336
# ─────────────────※ ·❆· ※─────────────────

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
    print '{"status": "error", "message": "Invalid authentication key"}'
    exit 1
  fi
  
  # Validasi parameter wajib
  if [[ -z "$user" || -z "$masaaktif" || -z "$Quota" || -z "$iplimit" ]]; then
    printf '{"status": "error", "message": "Missing required parameters"}'
    exit 1
  fi
  
  # Generate UUID jika auto atau kosong
  uuid=$(cat /proc/sys/kernel/random/uuid)
  
  # Set flag non-interactive
  non_interactive=true
fi

RED="\033[31m"
YELLOW="\033[33m"
NC='\e[0m'
YELL='\033[0;33m'
BRED='\033[1;31m'
GREEN='\033[0;32m'
ORANGE='\033[33m'
BGWHITE='\e[0;100;37m'

# Getting
CHATID=$(grep -E "^#bot# " "/etc/bot/.bot.db" | cut -d ' ' -f 3)
KEY=$(grep -E "^#bot# " "/etc/bot/.bot.db" | cut -d ' ' -f 2)
export TIME="10"
export URL="https://api.telegram.org/bot$KEY/sendMessage"
clear
#IZIN SCRIPT
MYIP=$(curl -sS ipv4.icanhazip.com)
echo -e "\e[32mloading...\e[0m"
clear
# Warna ANSI untuk tampilan terminal
RED='\033[1;91m'
GREEN='\033[1;92m'
YELLOW='\033[1;93m'
BLUE='\033[1;94m'
CYAN='\033[1;96m'
WHITE='\033[1;97m'
NC='\033[0m' # Reset warna

# Validasi Script
# Hanya jalankan validasi jika tidak dalam mode non-interactive
if [[ "$non_interactive" != "true" ]]; then
  clear
  echo -e "${CYAN}━━━━━━━━━━━━━━━━※❆※━━━━━━━━━━━━━━━━${NC}"
  echo -e "🔄 ${WHITE}MEMERIKSA PERMISSION VPS...${NC}"
  echo -e "${CYAN}━━━━━━━━━━━━━━━━※❆※━━━━━━━━━━━━━━━━${NC}"
  echo -e "✅ ${GREEN}Mengambil IP VPS${NC}"
  ipsaya=$(curl -sS ipv4.icanhazip.com)
  echo -e "✅ ${GREEN}Mengambil Data Server${NC}"
  data_server=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
  date_list=$(date +"%Y-%m-%d" -d "$data_server")
  data_ip="https://raw.githubusercontent.com/GeKaStore/Register/main/register"

  checking_sc() {
    useexp=$(wget -qO- $data_ip | grep $ipsaya | awk '{print $3}')
    if [[ $date_list < $useexp ]]; then
      echo -ne
    else
      clear
      echo -e "${RED}━━━━━━━━━━━━━━━━※❆※━━━━━━━━━━━━━━━━${NC}"
      echo -e "❌ ${WHITE}PERMISSION DENIED!${NC}"
      echo -e "${RED}━━━━━━━━━━━━━━━━※❆※━━━━━━━━━━━━━━━━${NC}"
      echo -e "🚫 VPS Anda: $ipsaya"
      echo -e "💀 Status: ${RED}Diblokir${NC}"
      echo -e ""
      echo -e "📌 Hubungi admin untuk membeli akses."
      echo -e "${RED}━━━━━━━━━━━━━━━━※❆※━━━━━━━━━━━━━━━━${NC}"
      exit 0
    fi
  }
  checking_sc
  clear
fi

# Membaca domain Xray
source /var/lib/kyt/ipvps.conf
if [[ "$IP" == "" ]]; then
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
  if [[ -f "/etc/trojan/.trojan.db" ]]; then
    if grep -q "^### $user " /etc/trojan/.trojan.db; then
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
  
  # Proses pembuatan akun TROJAN
  sed -i '/#trojanws$/a\#! '"$user $exp"'\
},{"password": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json
  sed -i '/#trojangrpc$/a\#! '"$user $exp"'\
},{"password": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json

  # Link Trojan Akun
  systemctl restart xray
  trojanlink="trojan://${uuid}@${domain}:443?path=%2Ftrojan-ws&security=tls&host=${domain}&type=ws&sni=${domain}#${user}"
  trojanlink1="trojan://${uuid}@${domain}:443?mode=gun&security=tls&type=grpc&serviceName=trojan-grpc&sni=${domain}#${user}"

  # Buat file konfigurasi
  cat >/var/www/html/trojan-$user.txt <<-END
      # Format TROJAN For Clash #

# Format Trojan GO/WS

- name: Trojan-$user-GO/WS
  server: ${domain}
  port: 443
  type: trojan
  password: ${uuid}
  network: ws
  sni: ${domain}
  skip-cert-verify: true
  udp: true
  ws-opts:
    path: /trojan-ws
    headers:
        Host: ${domain}

# Format Trojan gRPC

- name: Trojan-$user-gRPC
  type: trojan
  server: ${domain}
  port: 443
  password: ${uuid}
  udp: true
  sni: ${domain}
  skip-cert-verify: true
  network: grpc
  grpc-opts:
    grpc-service-name: trojan-grpc


          #  TROJAN WS TLS #

${trojanlink}

           # TROJAN WS gRPC #

${trojanlink1}
END

  # Set limit IP jika diperlukan
  if [[ $iplimit -gt 0 ]]; then
    mkdir -p /etc/kyt/limit/trojan/ip
    echo -e "$iplimit" > /etc/kyt/limit/trojan/ip/$user
  fi

  # Set quota jika diperlukan
  if [ -z ${Quota} ]; then
    Quota="0"
  fi

  c=$(echo "${Quota}" | sed 's/[^0-9]*//g')
  d=$((${c} * 1024 * 1024 * 1024))

  if [[ ${c} != "0" ]]; then
    echo "${d}" >/etc/trojan/${user}
  fi

  # Update database
  DATADB=$(cat /etc/trojan/.trojan.db | grep "^###" | grep -w "${user}" | awk '{print $2}')
  if [[ "${DATADB}" != '' ]]; then
    sed -i "/\b${user}\b/d" /etc/trojan/.trojan.db
  fi
  echo "### ${user} ${exp} ${uuid} ${Quota} ${iplimit}" >>/etc/trojan/.trojan.db

  # Kirim notifikasi ke Telegram
  BOT_TOKEN=$(cat /etc/telegram_bot/bot_token)
  CHAT_ID=$(cat /etc/telegram_bot/chat_id)
  URL="https://api.telegram.org/bot$BOT_TOKEN/sendMessage"

  location=$(curl -s ipinfo.io/json)
  CITY=$(echo "$location" | jq -r '.city')
  ISP=$(echo "$location" | jq -r '.org')
  MYIP=$(curl -s ifconfig.me)

  CITY=${CITY:-"Saya Gatau"}
  ISP=${ISP:-"Saya Gatau"}

  TEXT="<b>━━━ 𝙄𝙉𝙄 𝘿𝙀𝙏𝘼𝙄𝙇 𝘼𝙆𝙐𝙉 𝙏𝙍𝙊𝙅𝘼𝙉 ━━━</b>

<b>👤 𝙐𝙨𝙚𝙧 𝘿𝙚𝙩𝙖𝙞𝙡𝙨</b>
┣ <b>Username</b>   : <code>${user}</code>
┣ <b>Uuid </b>       : <code>${uuid}</code>
┣ <b>Quota</b>      : <code>${Quota} GB</code>
┣ <b>Status</b>     : <code>Aktif $masaaktif hari</code>
┣ <b>Dibuat</b>     : <code>$tnggl</code>
┗ <b>Expired</b>    : <code>$expe</code>

<b>🌎 𝙎𝙚𝙧𝙫𝙚𝙧 𝙄𝙣𝙛𝙤</b>
┣ <b>Domain</b>     : <code>${domain}</code>
┣ <b>IP</b>         : <code>$MYIP</code>
┣ <b>Location</b>   : <code>$CITY</code>
┗ <b>ISP</b>        : <code>$ISP</code>

<b>🔗 𝘾𝙤𝙣𝙣𝙚𝙘𝙩𝙞𝙤𝙣</b>
┣ <b>TLS Port</b>        : <code>400-900</code>
┣ <b>Network</b>         : <code>ws, grpc</code>
┣ <b>Path</b>            : <code>/trojan-ws</code>
┗ <b>gRPC Service</b>    : <code>trojan-grpc</code>

<b>━━━━━ 𝙏𝙍𝙊𝙅𝘼𝙉 𝙋𝙧𝙚𝙢𝙞𝙪𝙢 𝙇𝙞𝙣𝙠𝙨 ━━━━━</b>
<b>📍 𝙒𝙎 𝙏𝙇𝙎</b>
<pre>${trojanlink}</pre>
<b>📍 𝙜𝙍𝙋𝘾</b>
<pre>${trojanlink1}</pre>

<b>📥 𝘾𝙤𝙣𝙛𝙞𝙜 𝙁𝙞𝙡𝙚 (Clash/OpenClash):</b>
✎ https://${domain}:81/trojan-$user.txt

<b>✨ 𝙏𝙤𝙤𝙡𝙨 & 𝙍𝙚𝙨𝙤𝙪𝙧𝙘𝙚𝙨</b>
┣ https://vpntech.my.id/converteryaml
┗ https://vpntech.my.id/auto-configuration

<b>❓ 𝘽𝙪𝙩𝙪𝙝 𝘽𝙖𝙣𝙩𝙪𝙖𝙣?</b>
✎ https://wa.me/6285727035336

<b>━━━━━━━━━ 𝙏𝙝𝙖𝙣𝙠 𝙔𝙤𝙪 ━━━━━━━━</b>"

  TEXT_ENCODED=$(echo "$TEXT" | jq -sRr @uri)
  curl -s -d "chat_id=$CHAT_ID&disable_web_page_preview=1&text=$TEXT_ENCODED&parse_mode=html" $URL > /dev/null 2>&1

  # Restart layanan
  systemctl restart xray > /dev/null 2>&1
  service cron restart > /dev/null 2>&1

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
    \"ws_tls\": \"$trojanlink\",
    \"grpc\": \"$trojanlink1\",
    \"config_url\": \"https://${domain}:81/trojan-$user.txt\"
  }"
  exit 0
fi