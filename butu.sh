#!/bin/bash
myip=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0' | head -n1`;
myint=`ifconfig | grep -B1 "inet addr:$myip" | head -n1 | awk '{print $1}'`;

flag=0

echo

function create_user() {
	useradd -M $uname
	echo "$uname:$pass" | chpasswd
	usermod -e $expdate $uname

	myip=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0' | head -n1`;
	myip2="s/xxxxxxxxx/$myip/g";	
	wget -qO /tmp/client.ovpn "https://raw.githubusercontent.com/wilkingdead/setup2/master/1194-client.conf"
	sed -i 's/remote xxxxxxxxx 1194/remote xxxxxxxxx 443/g' /tmp/client.ovpn
	sed -i $myip2 /tmp/client.ovpn
	echo ""
	echo "========================="
	echo "Host IP : $myip"
	echo "Port    : 443/22/80"
	echo "Squid   : 8080/3128"
	echo "========================="
	echo "Script by Ibnu Fachrizal , gunakan akun dengan bijak"
	echo "========================="
}

function renew_user() {
	echo "New expiration date for $uname: $expdate...";
	usermod -e $expdate $uname
}

function delete_user(){
	userdel $uname
}

function expired_users(){
	cat /etc/shadow | cut -d: -f1,8 | sed /:$/d > /tmp/expirelist.txt
	totalaccounts=`cat /tmp/expirelist.txt | wc -l`
	for((i=1; i<=$totalaccounts; i++ )); do
		tuserval=`head -n $i /tmp/expirelist.txt | tail -n 1`
		username=`echo $tuserval | cut -f1 -d:`
		userexp=`echo $tuserval | cut -f2 -d:`
		userexpireinseconds=$(( $userexp * 86400 ))
		todaystime=`date +%s`
		if [ $userexpireinseconds -lt $todaystime ] ; then
			echo $username
		fi
	done
	rm /tmp/expirelist.txt
}

function not_expired_users(){
    cat /etc/shadow | cut -d: -f1,8 | sed /:$/d > /tmp/expirelist.txt
    totalaccounts=`cat /tmp/expirelist.txt | wc -l`
    for((i=1; i<=$totalaccounts; i++ )); do
        tuserval=`head -n $i /tmp/expirelist.txt | tail -n 1`
        username=`echo $tuserval | cut -f1 -d:`
        userexp=`echo $tuserval | cut -f2 -d:`
        userexpireinseconds=$(( $userexp * 86400 ))
        todaystime=`date +%s`
        if [ $userexpireinseconds -gt $todaystime ] ; then
            echo $username
        fi
    done
	rm /tmp/expirelist.txt
}

function used_data(){
	myip=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0' | head -n1`
	myint=`ifconfig | grep -B1 "inet addr:$myip" | head -n1 | awk '{print $1}'`
	ifconfig $myint | grep "RX bytes" | sed -e 's/ *RX [a-z:0-9]*/Received: /g' | sed -e 's/TX [a-z:0-9]*/\nTransfered: /g'
}

	clear
	echo "--------------- Selamat datang di Server - IP: $myip ---------------"
	cname=$( awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo )
	cores=$( awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo )
	freq=$( awk -F: ' /cpu MHz/ {freq=$2} END {print freq}' /proc/cpuinfo )
	tram=$( free -m | awk 'NR==2 {print $2}' )
	swap=$( free -m | awk 'NR==4 {print $2}' )
	up=$(uptime|awk '{ $1=$2=$(NF-6)=$(NF-5)=$(NF-4)=$(NF-3)=$(NF-2)=$(NF-1)=$NF=""; print }')

	echo -e "\e[032;1mCPU model:\e[0m $cname"
	echo -e "\e[032;1mNumber of cores:\e[0m $cores"
	echo -e "\e[032;1mCPU frequency:\e[0m $freq MHz"
	echo -e "\e[032;1mTotal amount of ram:\e[0m $tram MB"
	echo -e "\e[032;1mTotal amount of swap:\e[0m $swap MB"
	echo -e "\e[032;1mSystem uptime:\e[0m $up"
	echo -e "\e[032;1mScript by:\e[0m Ibnu Fachrizal | http://sshinjector.net/"
	echo "------------------------------------------------------------------------------"
	echo "Seputar SSH & OpenVPN"
	echo -e "\e[031;1m 1\e[0m) Buat Akun SSH/OpenVPN                    (\e[0;35muser-add\e[0m)"
	echo -e "\e[031;1m 2\e[0m) Generate Akun SSH/OpenVPN                (\e[34;1muser-gen\e[0m)"
	echo -e "\e[031;1m 3\e[0m) Generate Akun Trial                      (\e[0;35muser-trial\e[0m)"
	echo -e "\e[031;1m 4\e[0m) Ganti Password Akun SSH/VPN              (\e[34;1muser-pass\e[0m)"
	echo -e "\e[031;1m 5\e[0m) Tambah Masa Aktif Akun SSH/OpenVPN       (\e[0;35muser-renew\e[0m)"
	echo -e "\e[031;1m 6\e[0m) Hapus Akun SSH/OpenVPN                   (\e[34;1muser-del\e[0m)"
	echo -e "\e[031;1m 7\e[0m) Cek Login Dropbear & OpenSSH             (\e[0;35muser-login\e[0m)"
	echo -e "\e[031;1m 8\e[0m) Auto Limit Multi Login                   (\e[34;1mauto-limit\e[0m)"
	echo -e "\e[031;1m 9\e[0m) Melihat detail user SSH & OpenVPN        (\e[0;35muser-detail\e[0m)"
	echo -e "\e[031;1m10\e[0m) Daftar Akun dan Expire Date              (\e[34;1muser-list\e[0m)"
	echo -e "\e[031;1m11\e[0m) Delete Akun Expire                       (\e[0;35mdelete-user-expire\e[0m)"
	echo -e "\e[031;1m12\e[0m) Kill Multi Login                         (\e[34;1mauto-kill-user\e[0m)"
	echo -e "\e[031;1m13\e[0m) Auto Banned Akun                         (\e[0;35mbanned-user\e[0m)"
	echo -e "\e[031;1m14\e[0m) Unbanned Akun                            (\e[34;1munbanned-user\e[0m)"
	echo -e "\e[031;1m15\e[0m) Mengunci Akun SSH & OpenVPN              (\e[0;35muser-lock\e[0m)"
	echo -e "\e[031;1m16\e[0m) Membuka user SSH & OpenVPN yang terkunci (\e[34;1muser-unlock\e[0m)"
	echo -e "\e[031;1m17\e[0m) Melihat daftar user yang terkick         (\e[0;35mlog-limit\e[0m)"
	echo -e "\e[031;1m18\e[0m) Melihat daftar user yang terbanned       (\e[34;1mlog-ban\e[0m)"
        echo "${color2}Menu Multi Login${color3}"
	echo "${color2}Menu Akaun Expire${color3}"
	echo -e "\e[031;1m19\e[0m) Buat Akun PPTP VPN                       (\e[34;1muser-add-pptp\e[0m)"
	echo -e "\e[031;1m20\e[0m) Hapus Akun PPTP VPN                      (\e[34;1muser-delete-pptp\e[0m)"
	echo -e "\e[031;1m21\e[0m) Lihat Detail Akun PPTP VPN               (\e[34;1mdetail-pptp\e[0m)"
	echo -e "\e[031;1m22\e[0m) Cek login PPTP VPN                       (\e[34;1muser-login-pptp\e[0m)"
	echo -e "\e[031;1m23\e[0m) Lihat Daftar User PPTP VPN               (\e[34;1malluser-pptp\e[0m)"
	echo ""
	echo "${color2}Menu VPS${color3}"
	echo -e "\e[031;1m24\e[0m) Cek Lokasi User                         (\e[34;1mcek-lokasi-user\e[0m)"
	echo -e "\e[031;1m25\e[0m) Set Auto Reboot                         (\e[34;1mauto-reboot\e[0m)"
	echo -e "\e[031;1m26\e[0m) Speedtest                               (\e[34;1mcek-speedttes-vps\e[0m)"
	echo -e "\e[031;1m27\e[0m) Cek Ram                                 (\e[34;1mcek-ram\e[0m)"
	echo -e "\e[031;1m28\e[0m) Edit Banner                             (\e[34;1medit-banner\e[0m)"
	echo -e "\e[031;1m29\e[0m) Edit Port                               (\e[34;1medit-port\e[0m)"
	echo -e "\e[031;1m30\e[0m) Restart                                 (\e[34;1mrestart\e[0m)"
	echo -e "\e[031;1m31\e[0m) Benchmark                               (\e[34;1mbenchmark\e[0m)"
	echo -e "\e[031;1m32\e[0m) Ubah Pasword VPS                        (\e[34;1mpassword\e[0m)"
	echo -e "\e[031;1m33\e[0m) Ubah Hostname VPS                       (\e[34;1mhostname\e[0m)"
	echo -e "\e[031;1m34\e[0m) Reboot Server                           (\e[34;1mreboot\e[0m)"
	echo ""
	echo "Update Premium Script"
	echo -e "\e[031;1m35\e[0m) Log Install                             (\e[34;1mlog-install\e[0m)"
	echo -e "\e[031;1m36\e[0m) Diagnosa (\e[34;1mdiagnosa\e[0m)"
	echo ""
	echo -e "\e[031;1m x\e[0m) Exit"
	read -p "Masukkan pilihan anda, kemudian tekan tombol ENTER: " option1
	case $option1 in
        1)  
          clear
          buatakun.sh
          ;;
        2)  
          clear
          generate.sh
          ;;
        3)	
          clear
          trial.sh
	  ;;	
        4)
          clear
          userpass.sh
          ;;
        5)
          clear
          userrenew.sh
			;;
         6)
           clear
           userdelete.sh
           ;;		
	 7)
	   clear
	   userlogin.sh
	   ;;
	 8)
           clear
	   autolimit.sh
	   ;;	
	 9)
	   clear
           userdetail.sh
           ;;
        10)
           clear
           user-list.sh
           ;;
        11)
           clear
           deleteuserexpire.sh
	   ;;
	12)
	   clear
	   #!/bin/bash
           # Created by http://www.sshinjector.net
           # Dilarang Keras Mengambil/mencuplik/mengcopy sebagian atau seluruh script ini.
           # Hak Cipta sshinjector.net (Dilindungi Undang-Undang nomor 19 Tahun 2002)
           red='\e[1;31m'
           green='\e[0;32m'
           NC='\e[0m'
           echo "Connecting to sshinjector.net..."
           sleep 0.2
           echo "Checking Permision..."
           sleep 0.3
           echo -e "${green}Permission Accepted...${NC}"
           sleep 1
           echo""
	   read -p "Isikan Maximal User Login (1-2): " MULTILOGIN
	   echo "    AUTO KILL MULTI LOGIN    "    
	   echo "-----------------------------"
           autokilluser.sh  $MULTILOGIN
	   autokill.sh  $MULTILOGIN
           echo "-----------------------------"
           echo "AUTO KILL MULTI LOGIN SELESAI"
           ;;
        13)
           clear
           userban.sh
	   ;;
	14)
           clear
           userunban.sh
	   ;;
        15)
	   clear
           userlock.sh
	   ;;
        16)
           clear
           userunlock.sh
	   ;;
	17)
	   clear
	   loglimit.sh
	   ;;
	18)
           clear
           logban.sh
	   ;;
        19)
	   clear
           useraddpptp.sh
	   ;;
        20)
	   clear
           userdeletepptp.sh
           ;;
	21)
	   clear
           detailpptp.sh
           ;;
        22)
           clear
           userloginpptp.sh
	   ;;
        23)
           clear
           alluserpptp.sh
	   ;;
        24)
	   clear
	   userlogin.sh
           echo "Contoh: 49.0.35.16 lalu Enter"
           read -p "Ketik Salah Satu Alamat IP User: " userip
           curl ipinfo.io/$userip
           ;;
	25)
	   clear
           autoreboot.sh
           ;;
	26)
	   clear
           #!/bin/bash
           red='\e[1;31m'
           green='\e[0;32m'
           blue='\e[1;34m'
           NC='\e[0m'
           echo "Connecting to sshinjector.net..."
           sleep 0.2
           echo "Checking Permision..."
           sleep 0.3
           echo -e "${green}Permission Accepted...${NC}"
           sleep 1
           echo""
           echo "Speed Tes Server"
           speedtest.py.sh
           echo ""
	   echo "Script Created by http://www.sshinjector.net"
           echo "Terimakasih sudah berlangganan di sshinjector.net"
           ;;
        27)
           clear
           ram.sh
           ;;
        28)
	  clear
	  echo -e "1.) Simpan text (CTRL + X, lalu ketik Y dan tekan Enter) "  | tee -a log-install.txt
          echo -e "2.) Membatalkan edit text (CTRL + X, lalu ketik N dan tekan Enter)"  | tee -a log-install.txt
          echo "-----------------------------------------------------------"  | tee -a log-install.txt
          read -p "Tekan ENTER untuk melanjutkan........................ "
          nano /bannerssh
          /etc/init.d/dropbear restart
	  ;;
       29)
          clear
          ubahport.sh
	  ;;
       30)	
          clear
          restart.sh
	  ;;	
       31)
	  clear
          wget freevps.us/downloads/bench.sh -O - -o /dev/null|bash
          ;;
       32)
          clear
	  echo "Masukan Password VPS, yang mau diganti :"
	  passwd
	  ;;	
       33)
	  clear
	  echo "Masukan HOSTNAME VPS, yang mau diganti :"
          echo "contoh : " hostname ibnu 
          ;;
       34)
	  clear
	  reboot
          ;;
       35)
	  clear
	  log-install.sh
          ;;
       36)
          clear
          diagnosa.sh
	  ;;
       37)
          wget
          ;;
        x)
          ;;
        *) menu;;
        esac
