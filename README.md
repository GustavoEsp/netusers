
# netusers

## Descrição
`netusers.sh` é um script Bash projetado para gerenciar dispositivos conectados à rede. Ele utiliza o `nmap` para escanear a rede e oferece opções para visualizar e banir dispositivos com base nos endereços MAC.

## Uso

   

    bash ./netusers.sh [OPÇÕES]

## Opções

-   `-v`: Modo verbose. Exibe os resultados no terminal.
-   `-s`: Modo silencioso. Apenas registra os resultados sem imprimir no terminal.
-   `-sv`: Ambos os modos silencioso e verbose. Registra os resultados e exibe no terminal.
-   `-n <rede_ip>`: Especifica o intervalo de IP da rede a ser escaneada (por exemplo, `netusers -n 192.168.1.0/24`).
-   `-b <endereço_MAC>`: Bane pacotes de um dispositivo específico pelo seu endereço MAC.
-   `-h`: Exibe informações de ajuda com os comandos disponíveis.

## Exemplos



#### Escanear a rede e armazenar resultados no log somente
	
    ./netusers.sh -s -n 192.168.0.1/24

### Escanear a rede e mostrar resultados

    ./netusers.sh -v -n 192.168.0.1/24
    
### Banir dispositivo pelo endereço Mac

    ./netusers.sh -b XX:XX:XX:XX:XX:XX



