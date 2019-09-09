#!/bin/bash
docker exec es73_1 /bin/bash -c "yum -y install expect && /usr/share/elasticsearch/bin/set-pw-es"
echo "Criando roles do Logstash..."
curl -u elastic:123456 -X POST http://localhost:9200/_xpack/security/role/logstash_writer -H "Content-type: application/json" -d @create-roles.json
curl -u elastic:123456 -X POST http://localhost:9200/_xpack/security/user/logstash_internal -H "Content-type: application/json" -d @create-user.json
echo "Senhas e roles setada com sucesso!!!"
sleep 3
clear
echo "Processo finalizado com sucesso!!!"

