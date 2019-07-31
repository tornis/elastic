# Elastic Stack Enterprise Scripts 

Passo a Passo - Montagem de infra Elastic Stack para Testes 

### Pré Requisitos 
São necessários os seguintes serviços instalados:
- CentOS 7/Redhat 7
- Repositório EPEL 
- Docker CE 1.8 ou superior
- docker-compose


### Passo 1 - Instalando reposritório EPEL e dependências 
```
# yum install epel-release
# yum install -y yum-utils device-mapper-persistent-data lvm2 git 
```
### Passo 2 - Instalando o repositorio do Docker CE e instalando o Docker CE
``` 
# yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
# yum install docker-ce
# usermod -aG docker $(whoami)
# systemctl enable docker.service
# systemctl start docker.service
```
### Passo 3 - Instalando o docker-compose
```
# yum install -y python-pip
# pip install docker-compose
# docker-compose version
```

### Passo 4 - Liberando portas do Elasticsearch, Logstash e Kibana no FirewallD (CentOS/RHCE7)
```
# firewall-cmd --zone=public --permanent --add-port=9200/tcp
# firewall-cmd --zone=public --permanent --add-port=5601/tcp
# firewall-cmd --zone=public --permanent --add-port=9600/tcp
```

### Passo 5 - Clonando os scripts Elastic Stack do git da BKTECH
```
# cd /opt/ 
# git clone https://github.com/tornis/elastic.git 
# ls -l 
```

### Passo 6 - Subindo as instancias de Elasticsearch, Kibana e Logstash com docker-compose

_OBS: Após realizado o clone do repositório você perceberá que dentro do elastic-script exitem pastas referente a Stack da Elastic. No caso do Elasticsearch temos a pasta "es" e dentro dela possui o arquivo do docker-compose.yml e arquivos de configuração da ferramenta. O comando docker-compose dever ser executado dentro de cada pasta para que o container suba corretamente._


__Ajustando a VM do SO:__
```
# sysctl -w vm.max_map_count=262144
```
__Dentro da pasta__ 
```
# cd es
# docker-compose up -d
```

__Verificado se o container subiu e se as portas estão operacional__
```
# docker ps
```
Abaixo o resultado esperado de exemplo:
```
00cf84028d3f        docker.elastic.co/elasticsearch/elasticsearch:7.1.1   "/usr/local/bin/dock…"   8 hours ago         Up 8 hours          9200/tcp, 9300/tcp                 es03
8b4bb9b55ac7        docker.elastic.co/elasticsearch/elasticsearch:7.1.1   "/usr/local/bin/dock…"   8 hours ago         Up 8 hours          0.0.0.0:9200->9200/tcp, 9300/tcp   es01
3b67b6d01d1b        docker.elastic.co/elasticsearch/elasticsearch:7.1.1   "/usr/local/bin/dock…"   8 hours ago         Up 8 hours          9200/tcp, 9300/tcp   	          es02
```
Outro comando para verificar se o container Elasticsearch está operando e verificar se a porta 9200 esta operante: 
```
# netstat -nltp | grep 9200
```
__Testado se Elasticsearch está funcional__

Abra um navegador e tente acessar o Elasticsearch usando a url: 
> http://<IP_DO_HOST>:9200/ 

Se pedir login e senha use: ``` elastic/123456 ``` a senha esta definida no aquivo docker-compose.yml

_OBS: Caso o passo 5 não tenha sido concluído com sucesso, repetir os passos anteriores._

### Passo 7 - Definindo senhas para os serviços da Stack(Kibana, Elasticsearch, Beats e Logstash)

_Obs: Nesse passo vamos definir senha para os usuários que estão no core do Elasticsearch. Para isso temos que acessar o container que está com a porta 9200 exposta._ 
```
# docker ps 
``` 
Resultado do comando deve-se paracer conforme abaixo:
``` 
00cf84028d3f        docker.elastic.co/elasticsearch/elasticsearch:7.1.1   "/usr/local/bin/dock…"   8 hours ago         Up 8 hours          9200/tcp, 9300/tcp                 es03
8b4bb9b55ac7        docker.elastic.co/elasticsearch/elasticsearch:7.1.1   "/usr/local/bin/dock…"   8 hours ago         Up 8 hours          0.0.0.0:9200->9200/tcp, 9300/tcp   es01
3b67b6d01d1b        docker.elastic.co/elasticsearch/elasticsearch:7.1.1   "/usr/local/bin/dock…"   8 hours ago         Up 8 hours          9200/tcp, 9300/tcp   	          es02
``` 
_OBS: Procure algo similar a ``` 0.0.0.0:9200->9200/tcp, 9300/tcp ```, isso carateriza o container que esta com a porta exposta assim o ID do container é __8b4bb9b55ac7___

Agora execute o comando abaixo para acessar o container em questão: 
``` 
# docker exec -it <ID_container> /bin/bash 
```

OBS: _Logo aparecerá o prompt do container_

__Dentro do Container__
Siga os passos abaixo: 
```
# ./bin/elasticsearch-setup-passwords interactive 

Initiating the setup of passwords for reserved users elastic,apm_system,kibana,logstash_system,beats_system,remote_monitoring_user.
You will be prompted to enter passwords as the process progresses.
Please confirm that you would like to continue [y/N] <---- COLOQUE "y"

Enter password for [elastic]: <----- COLOQUE A SENHA AQUI 
Reenter password for [elastic]: 
Enter password for [apm_system]: 
Reenter password for [apm_system]: 
Enter password for [kibana]: 
Reenter password for [kibana]: 
Enter password for [logstash_system]: 
Reenter password for [logstash_system]: 
Enter password for [beats_system]: 
Reenter password for [beats_system]: 
Enter password for [remote_monitoring_user]: 
Reenter password for [remote_monitoring_user]: 
Changed password for user [apm_system]
Changed password for user [kibana]
Changed password for user [logstash_system]
Changed password for user [beats_system]
Changed password for user [remote_monitoring_user]
Changed password for user [elastic]

# exit
```

### Passo 8 - Subindo instância do Kibana
_Obs: Agora acessar a pasta kb e editar os aquivos conforme necessidade, no parametro __elasticsearch.username: "kibana"
elasticsearch.password: "123456"__ coloque a senha que foi definida no passo 7, veja os comentários no arquivo kibana.yml_

```
# cd kb
# docker-compose up -d 
```

__Acesse o kibana via navegador__
> http://<IP_DO_HOST>:5601
 
Se pedir login e senha use: ``` elastic/123456 ``` a senha esta definida no aquivo docker-compose.yml
