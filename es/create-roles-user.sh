#!/bin/bash
docker exec es71 /bin/bash -c "yum -y install expect && /usr/share/elasticsearch/bin/set-pw-es"
curl -u elastic:123456 -X POST http://localhost:9200/_xpack/security/role/logstash_writer -H "Content-type: application/json" -d @create-roles.json
curl -u elastic:123456 -X POST http://localhost:9200/_xpack/security/user/logstash_internal -H "Content-type: application/json" -d @create-user.json
