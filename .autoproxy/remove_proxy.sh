remove_keyword() #For removing keyword from file mainly from .bashrc or .zshrc
{
	for var in ${proxy_var[@]}; do
		sed -i "/$var/d" "$1"
	done
	sed -i "/no_proxy/d" "$1"
	sed -i "/NO_PROXY/d" "$1"
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

bash_loc="$HOME/.bashrc"
zsh_loc="$HOME/.zshrc"
proxy_var=("http_proxy" "https_proxy" "ftp_proxy" "HTTP_PROXY" "HTTPS_PROXY" "FTP_PROXY")

proxy_unset
