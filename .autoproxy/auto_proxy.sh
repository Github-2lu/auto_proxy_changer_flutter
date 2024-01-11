#!/bin/bash
remove_keyword() #For removing keyword from file mainly from .bashrc or .zshrc
{
	for var in ${proxy_var[@]}; do
		sed -i "/$var/d" "$1"
	done
	sed -i "/no_proxy/d" "$1"
	sed -i "/NO_PROXY/d" "$1"
}

adding_keyword() #for adding keyword in .bashrc or .zshrc
{
# 	echo "$1, $2, $3"
	for var in ${proxy_var[@]}; do
		echo "export $var=$1" >>"$3"
	done
        echo "export no_proxy=$2" >> "$3"
        echo "export NO_PROXY=$2" >> "$3"
}

proxy_set()
{
	echo "$1, $2, $3, $4, $5"
	temp_proxy="http://$1:$2"

	if [ "$4" != "" ];
	then
		temp_proxy="http://$4:$5@$1:$2"
	fi

	gsettings set org.gnome.system.proxy mode 'none' # to set proxy to none to set another proxy
	if [ -f "$bash_loc" ]
	then
		remove_keyword $bash_loc # removing old proxy if any in .bashrc
		adding_keyword $temp_proxy $3 $bash_loc # adding new proxy in that file
	fi
	if [ -f "$zsh_loc" ]
	then
		remove_keyword $zsh_loc # similar in zshrc
		adding_keyword $temp_proxy $3 $zsh_loc
	fi
# 	temp_proxy="http://$1:$2/"
	for var in ${proxy_var[@]}; do
		export $var=$temp_proxy # exporting proxy for current session
	done
	export no_proxy=$3
	export NO_PROXY=$3

	no_proxy_for_gnome="["

	for i in $(echo $no_proxy | tr "," "\n")
	do
        no_proxy_for_gnome=$no_proxy_for_gnome"'$i'",
	done
	no_proxy_for_gnome=$(echo $no_proxy_for_gnome | rev | cut -c2- | rev)
	no_proxy_for_gnome=$no_proxy_for_gnome"]"
# 	echo $no_proxy_for_gnome


#gnome settings to set proxy works for both firefox and chrome if DE is Gnome or Gnome based like cinnamon
	gsettings set org.gnome.system.proxy mode 'manual'
	gsettings set org.gnome.system.proxy.http enabled true
	gsettings set org.gnome.system.proxy.http host $1
	gsettings set org.gnome.system.proxy.http port $2
	gsettings set org.gnome.system.proxy.https host $1
	gsettings set org.gnome.system.proxy.https port $2
	gsettings set org.gnome.system.proxy.ftp host $1
	gsettings set org.gnome.system.proxy.ftp port $2
	gsettings set org.gnome.system.proxy.socks host $1
	gsettings set org.gnome.system.proxy.socks port $2
	gsettings set org.gnome.system.proxy ignore-hosts "$no_proxy_for_gnome"
# 	echo "gnome added"
# if DE is kde plasma then this will change settings. ESSENTIAL FOR GOOGLE CHROME TO WORK
	if [ "$DESKTOP_SESSION" = "plasma" ]
	then
		kwriteconfig5 --file kioslaverc --group 'Proxy Settings' --key ProxyType "1"
		kwriteconfig5 --file kioslaverc --group 'Proxy Settings' --key httpProxy "http://$1:$2"
		kwriteconfig5 --file kioslaverc --group 'Proxy Settings' --key httpsProxy "http://$1:$2"
		kwriteconfig5 --file kioslaverc --group 'Proxy Settings' --key ftpProxy "http://$1:$2"
		kwriteconfig5 --file kioslaverc --group 'Proxy Settings' --key socksProxy "http://$1:$2"
		kwriteconfig5 --file kioslaverc --group 'Proxy Settings' --key NoProxyFor $3
		kwriteconfig5 --file kioslaverc --group 'Proxy Settings' --key Authmode 0
		dbus-send --type=signal /KIO/Scheduler org.kde.KIO.Scheduler.reparseSlaveConfiguration string:''
	fi
# 	echo "kde added	"
}

proxy_unset()
{
# unsetting proxy in current session
	for var in  ${proxy_var[@]};do
		unset $var
	done
	unset no_proxy
	unset NO_PROXY
# removing proxies in .bashrc and .zshrc
	if [ -f "$bash_loc" ]
	then
		remove_keyword $bash_loc
	fi
	if [ -f "$zsh_loc" ]
	then
		remove_keyword $zsh_loc
	fi
# unsetting gnome proxy
	gsettings set org.gnome.system.proxy mode 'none'
# unsetting plasma proxy
	if [ "$DESKTOP_SESSION" = "plasma" ]
	then
		if [ -f "$HOME/.config/kioslaverc" ]
		then
			rm "$HOME/.config/kioslaverc"
		fi
	fi
	echo "[+] proxy is unset"
}

proxy_get()
{
# 	echo $proxies_loc
	res=$(cat $proxies_loc | jq -r ".[$1]")
# 	echo "$res"
	name=$(echo "$res" | jq -r ".name")
	host=$(echo "$res" | jq -r ".host")
	port=$(echo "$res" | jq -r ".port")
	username=$(echo "$res" | jq -r ".username")
	password=$(echo "$res" | jq -r ".password")
	noProxy=$(echo "$res" | jq -r ".noProxy")
	echo "$host, $port, $username, $password, $noProxy"

	proxy_set $host $port $noProxy $username $password
	echo "[+] $name proxy is set."
}

# my .bashrc and .zshrc location
bash_loc="$HOME/.bashrc"
zsh_loc="$HOME/.zshrc"
proxies_loc="$HOME/.autoproxy/proxies.json"
# echo $proxies_loc
# cat $proxies_loc
# proxy variables
proxy_var=("http_proxy" "https_proxy" "ftp_proxy" "HTTP_PROXY" "HTTPS_PROXY" "FTP_PROXY")
echo "Setup is complete"


prev_wifi=""
# echo "$prev_wifi"
# echo "no proxy"
proxy_unset

while [ true ];
do
	current_wifi=$(iwgetid -r)
# 	echo "prev_wifi: ${prev_wifi}"
# 	echo "current_wifi: ${current_wifi}"

	if [ "$current_wifi" != "$prev_wifi" ] && [ "$current_wifi" != "" ];
	then
		res=''
		i=0
		while [ "$res" != "null" ];
		do
			res=$(cat $proxies_loc | jq -r ".[$i]")
			if [ "$res" != "null" ];
			then
# 				echo "$i"
# 				echo "$res"
# 				echo "$current_wifi"
				possible_wifi=$(echo "$res" | jq -r ".name")
# 				echo "possible_wifi: $possible_wifi"
				if [ "$current_wifi" = "$possible_wifi" ];
				then
# 					echo "${possible_wifi} found"
					proxy_get $i
					break
				fi
				let "i += 1"
			else
				proxy_unset
# 				echo "No proxy found"
			fi
		done
		prev_wifi="$current_wifi"
# 		echo "$prev_wifi"
	fi
	sleep 1
done
