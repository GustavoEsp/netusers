#!/bin/bash

OPTERR=0
option_s=0
option_v=0

red_color="\033[0;31m"
green_color="\033[92m"
normal_color="\033[0m"

verificar_modo_print(){
	if  [ $option_v == 1 ] && [ $option_s == 1 ] 
	then
		if [ $maquina_atual == $nome_maquina ]
		then
			echo "$nome_maquina $ip_maquina - Localhost" >> lognetusersTemp.log
			echo "$nome_maquina $ip_maquina - Localhost";
		else
			echo "$nome_maquina $ip_maquina - $mac_maquina - $conectividade" >> lognetusersTemp.log
			echo "$nome_maquina $ip_maquina - $mac_maquina - $conectividade" 
			
		fi
		cat lognetusersTemp.log | sort | uniq > lognetuserOficial.log
		cat lognetuserOficial.log > lognetusersTemp.log
	elif [[ $option_v == 0 && $option_s == 1 ]]
	then
		# mostrar caso seja silent
		if [ $maquina_atual == $nome_maquina ]
		then
			echo "$nome_maquina $ip_maquina - Localhost" >> lognetusersTemp.log
		else
			echo "$nome_maquina $ip_maquina - $mac_maquina - $conectividade" >> lognetusersTemp.log
		fi
		cat lognetusersTemp.log | sort | uniq > lognetuserOficial.log 
		cat lognetuserOficial.log > lognetusersTemp.log
	# mostrar caso seja ambos
	elif [ $option_v == 1 ] && [ $option_s==0 ] 
	then
		# mostrar caso seja verbose
		if [ $maquina_atual == $nome_maquina ]
		then
			echo "$nome_maquina $ip_maquina - Localhost"
		else
			echo "$nome_maquina $ip_maquina - $mac_maquina - $conectividade" 
		fi
	fi
}

while getopts n:b:u:svh* OPCAO
do
    # Verifica o parâmetro armazenado em 'OPCAO'
    case $OPCAO in
        # Atribui uma ação.
        s) option_s=1 ;;
        v) option_v=1 ;;
        n) arg_ip="$OPTARG" ;;
        b) ban_mac_target="$OPTARG" 
        ;;
		u) unban_mac_target="$OPTARG"
		;;
        h)
            echo "Use: netusers [OPÇÕES]..."
            echo 'script to manage network connected devices.'
            echo
            echo '-v    verbose, echo results'
            echo '-s    Silent, only log'
			echo '-sv   Both silent and verbose mode'
            echo '-n    Network ip (netusers -n xxx.xxx.xxx.xxx/xx)'
            echo '-b    ban packets by device mac address (netusers -b XX:XX:XX:XX:XX:XX)'
            echo '-h    Show available commands'
            echo
            echo 'Made by GustavoESP'

            exit 0
            ;;
        *) echo "Error! Use: netusers -h to get help"; exit 1;;
    esac
done

net_scan(){
	echo "[*] Scanning network..."
	echo -e "\n\n" >> lognetusersTemp.log
	contador=0
	maquina_atual=$(hostname| awk '{print tolower($0)}')'.lan' 

	while IFS= read -r line
	do
		let contador++	
		
		# nome da maquina
		if [ $contador == 1 ] 
		then
			nome_maquina=$(echo $line | awk -F " " '{print $5}')
			ip_maquina=$(echo $line | awk -F " " '{print $6}')
			
			if [[ $nome_maquina =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]] # caso não tenha nome, o ip passa para o nome_maquina. entao deve haver validacao
			then
				ip_maquina="($nome_maquina)"
				nome_maquina="Unknown"
			fi

		# host
		elif [ $contador == 2 ] 
		then
			conectividade=$(echo $line | awk -F " " '{print $3}')
						
		# mac address
		elif [ $contador == 3 ] 
		then
			mac_maquina=$(echo $line | awk -F " " '{print $3}')
			verificar_modo_print
			contador=0
		fi
	done < <(sudo nmap -sP $arg_ip | tail -n +2 2> /dev/null)
	
 
}

# depois de todo processo...

if [ $option_s == 1 ] || [ $option_v == 1 ]
then
	net_scan
	if [ $? -eq 0 ]
	then	
		if [ $option_s == 1 ] 
		then
			echo -e "${green_color}[*] Sucess! ${normal_color} See formatted info on lognetuserOficial.log or raw info on lognetusers.log"
		fi
	else
		echo "Error"
		echo $?
	fi
elif [ ban_mac_target != "" ]
then
	echo "[*] banning mac address: $ban_mac_target"
	/sbin/iptables -A INPUT -m mac --mac-source $ban_mac_target -j DROP 2> /dev/null
	if [ ! $? -eq 0 ]
	then
		echo -e "${red_color}[*] Error! ${normal_color} Check your mac adress input and try again!"
	else	
		echo -e "${green_color}[*] Sucess! ${normal_color} $ban_mac_target has been banned from sending packets"
		echo -e "[*] Warning! Changes may take a while to start working, you should restart the machine!"
	fi
fi

