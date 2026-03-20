#!/bin/bash
#mkdir /redcheck
#Выгрузить файлы redcheck-astra1.7-repo-2.12.0.20663.tar.gz и redcheck-compatibility-repo-astra-1.7+2.12.6.tar.gz в папку /redcheck --> mv /..../redcheck-astra1.7-repo-2.12.0.20663.tar.gz /redcheck  mv /..../redcheck-compatibility-repo-astra-1.7+2.12.6.tar.gz /redcheck
#chmod 777 -R /redcheck
#Проверить названия файлов - они отличаются в зависимости от версии
#не забыть сделать активным сам скрипт ---> chmod +x redcheck212.sh
# Скрипт redcheck212.sh - может лежать где угодно, но можно положить рядом с остальными файлами в папке /redcheck
set -e
sudo bash -c 'cat >> /etc/apt/sources.list <<EOF
deb https://dl.astralinux.ru/astra/stable/1.7_x86-64/repository-extended/ 1.7_x86-64 astra-ce main contrib non-free
EOF'
sudo apt -y update
sleep 5
sudo apt -y install postgresql
sleep 5
sudo systemctl enable postgresql
sudo -u postgres psql <<EOF
CREATE ROLE redcheck WITH PASSWORD 'xxXX1234' LOGIN CREATEDB SUPERUSER;
\q
EOF
sleep 5
sudo chmod 777 /etc/postgresql/14/main/postgresql.conf
sudo echo "listen_addresses = '*'" >> /etc/postgresql/14/main/postgresql.conf
sudo chmod 777 /etc/postgresql/14/main/pg_hba.conf
sudo echo host all redcheck 0.0.0.0/0 scram-sha-256 >> /etc/postgresql/14/main/pg_hba.conf
sudo systemctl restart postgresql
sudo ufw allow 5432/tcp
sleep 5
sudo tar -xvf /redcheck/redcheck-astra1.7-repo-2.12.0.20663.tar.gz -C /usr/local/src
sudo apt-key add /usr/local/src/redcheck-astra-repo/PUBLIC-GPG-KEY-redcheck
sudo tar -xvf /redcheck/redcheck-compatibility-repo-astra-1.7+2.12.6.tar.gz -C /usr/local/src
sudo apt-key add /usr/local/src/redcheck-compatibility/PUBLIC-GPG-KEY-redcheck
echo "deb file:/usr/local/src/redcheck-astra-repo/ 1.7_x86-64 non-free" | sudo tee /etc/apt/sources.list.d/redcheck.list
echo "deb file:/usr/local/src/redcheck-compatibility/ 1.7_x86-64 non-free" | sudo tee -a /etc/apt/sources.list.d/redcheck.list
sudo apt -y update
sudo apt -y install redcheck-api redcheck-client redcheck-scan-service redcheck-sync-service redcheck-cleanup-service
sudo apt-get -y install python3-pip
sudo redcheck-bootstrap

#8 (настроить все сразу)
# IP БД: 127.0.0.1, Порт: 5432, redcheck, пароль: xxXX1234, Имя БД: RedCheck (регистр важен)
# Создать новую БД - yes, Пользовательский ключ шифрования - просто Enter
# K - ключ, скопировать - вставить
# http, Локальный IP Офиса, порт по умолчанию
# После установки - зайти в веб, выбрать контент для синхронизации - далее сначала Проверить обновления контента - дождаться окончания, после нажать Проверить обновления и запустить синхронизацию -- в обратном порядке будет выведена ошибка

#sudo altxmap -O --osscan-guess -T4 -oX nmap_os.xml 192.168.0.0/24
#import sys,xml.etree.ElementTree as ET, csv
#tree = ET.parse('nmap_os.xml')
#root = tree.getroot()
#with open('nmap_os.csv','w',newline='',encoding='utf-8') as f:
#    w = csv.writer(f)
#    w.writerow(['Host','CPE'])
#    for host in root.findall('host'):
#        Host = ''
#        for addr in host.findall('address'):
#            if addr.get('addrtype') == 'ipv4':
#                ip = addr.get('addr'); break
#        if not Host:
#            a = host.find('address')
#            Host = a.get('addr') if a is not None else ''
#        os_name = ''
#        os_elem = host.find('os')
#        if os_elem is not None:
#            om = os_elem.find('osmatch')
#            if om is not None:
#                os_name = om.get('name','')
#        w.writerow([Host, os_name])
#print('Saved nmap_os.csv')
