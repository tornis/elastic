#!/bin/bash
echo "Criando pipeline main para o Logstash..."
curl -u elastic:123456 -X PUT "http://localhost:5601/api/logstash/pipeline/main" -H 'kbn-xsrf: true' -H 'Content-Type: application/json' -d @create-pipeline-logstash.json
clear
echo "Criando pipeline main para o Logstash... OK!"
