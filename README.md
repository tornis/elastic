# Elastic Stack Enterprise Scripts 

Passo a Passo - Montagem de infra Elastic Stack para Testes usando docker-compose 

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

### Passo 4 - Liberando portas do Elasticsearch, Logstash+Beats e Kibana no FirewallD (CentOS/RHCE7)
```
# firewall-cmd --zone=public --permanent --add-port=9200/tcp
# firewall-cmd --zone=public --permanent --add-port=5601/tcp
# firewall-cmd --zone=public --permanent --add-port=9600/tcp
# firewall-cmd --zone=public --permanent --add-port=5044/tcp
```

### Passo 5 - Clonando os scripts Elastic Stack do git TORNIS
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

_Obs: Nesse passo vamos definir senha para os usuários que estão no core do Elasticsearch. Dentro da pasta "es" temos o script "create-roles-users.sh". Esse script define senhas para os usuários builtin do Elasticsaerch e também cria os usuários que serão usados pelo Logstash para realizar ingestão no Elasticsearch e monitoramento do Pipeline_

```
# cd es
# ./create-roles-users.sh 
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

### Passo 9 - Subindo instância do Logstash
_Obs: Inicialmente o Logstash está configurado para ler o pipeline "__Main__" a partir do Elasticsearch. Observe que dentro da pasta "__ls/config__" estão todos os arquivos de configuração do Logstash. Especificamente no arquivo "__logstash.yml__" temos os parâmetros:
```
xpack.monitoring.elasticsearch.username: logstash_system
xpack.monitoring.elasticsearch.password: "123456"
xpack.monitoring.elasticsearch.hosts: ["http://172.17.0.1:9200"]
...
xpack.management.pipeline.id: ["main"]
xpack.management.elasticsearch.username: logstash_internal
xpack.management.elasticsearch.password: "123456"
xpack.management.elasticsearch.hosts: ["http://172.17.0.1:9200"]
```
eles são responsáveis por habilitar o monitoramento pela MonitorUI e gerência do Pipeline no Kibana.
Então execute o script "__create-pipeline-main.sh__" antes de subir a instância do Logstash. Lembrando que o pipeline padrão está configurando apenas com INPUT e OUTPUT_
```
# cd ls 
# ./create-pipeline-main.sh
```

__Iniciando o Logstash__

```
# cd ls
# docker-compose up -d 
```

__Kibana MonitorUI e Pipeline Config do Logstash__

Identificando a instância do Logstash no Kibana MonitorUI


Identificando o pipeline "__main__" em Logstash Pipeline no Kibana Config
