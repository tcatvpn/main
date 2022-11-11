#!/bin/bash
##INSTALADOR DEPENDENCIAS ONEVPS
echo "INSTALADOR DNSTT BY @Andley302";
sleep 5;
##COMPILA DNSTT
cd /usr/local;
wget https://golang.org/dl/go1.16.2.linux-amd64.tar.gz;
tar xvf go1.16.2.linux-amd64.tar.gz;
export GOROOT=/usr/local/go;
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH;
cd /root;
git clone https://www.bamsoftware.com/git/dnstt.git;
cd /root/dnstt/dnstt-server;
go build;
cd /root/dnstt/dnstt-server && cp dnstt-server /root/dnstt-server;
##DEFAULT KEYS
#cd /root;
#wget https://raw.githubusercontent.com/Andley302/utils/main/dnstt_installer/server.key;
#wget https://raw.githubusercontent.com/Andley302/utils/main/dnstt_installer/server.pub;
##GERAR KEYS
cd /root && ./dnstt-server -gen-key -privkey-file server.key -pubkey-file server.pub;
##RESET IPTABLES
cd /root && rm -rf iptables* && wget https://raw.githubusercontent.com/Andley302/utils/main/dnstt_installer/iptables.sh && chmod +x iptables.sh && ./iptables.sh;
##ENABLE RC.LOCAL
set_ns () {
cd /etc;
mv rc.local rc.local.bkp;
wget https://raw.githubusercontent.com/Andley302/utils/main/dnstt_installer/rc.local;
wget https://raw.githubusercontent.com/Andley302/utils/main/dnstt_installer/restartdns.sh;
chmod +x /etc/rc.local;
echo -ne "\033[1;32m INFORME SEU NS (NAMESERVER)\033[1;37m: "; read nameserver
sed -i "s;1234;$nameserver;g" /etc/rc.local > /dev/null 2>&1
sed -i "s;1234;$nameserver;g" restartdns.sh > /dev/null 2>&1
systemctl enable rc-local;
systemctl start rc-local;
chmod +x restartdns.sh;
mv restartdns.sh /bin/restartdns;
}
#EXECUTA FUNCAO
set_ns
cd /root;
##FIM
echo "Finalizando....";
restartdns;
sleep 5;
clear;
echo "";
echo "Fim! Sua key: " && cat server.pub;
echo "";
echo "A key está no arquivo server.pub.Guarde os arquivos server.pub e server.key em local seguro.";
echo "Se já tiver essas keys e queira usar,substitua o server.pub e server.key na pasta root e reinicie o servidor";
