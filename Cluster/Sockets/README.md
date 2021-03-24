# Sockets com Python  
<br>

## Manipulando sockets via protocolo TCP

Um soquete de rede é um ponto final de um fluxo de comunicação entre processos através de uma rede de computadores. Neste exercício vamos criar uma estrutura cliente/Servidor para o cluster criado, onde o servidor controller vai ficar escutando e esperando as conexões dos nós (Computes). <br>

Cluster é um termo em inglês que significa “aglomerar” ou “aglomeração” e pode ser aplicado em vários contextos. No caso da computação, o termo define uma arquitetura de sistema capaz de combinar vários computadores para trabalharem em conjunto. O cluster a ser criado nesse exercício vai conter cinco máquinas virtuais sendo 1 controller e 4 computes, que são os nós. <br>

![img](https://github.com/AnttoniC/cloud-deployment-tool/blob/main/Cluster/Aws-CLI/IMG/cluster4n.png)

## Descrição do exercício
Crie um cluster com 4 nós onde o controller vai está executando o **servidor.py** e os nós(compute) vão está rodando o **cliente.py**. Siga as etapas abaixo para realizar a configuração dos nós. Objetivo desse exercício é mostrar que o cluster está configurado e o usuário está pronto para práticas distribuídas.

Para criar um cluster na azure execute o seguinte comando: <br>
`./cluster.sh -c _azure -n 4 -i Standard_B1s`<br>
Para criar um cluster na aws execute o seguinte comando:<br>
`./cluster.sh -c _aws -n 4 -i t2.micro`<br>
Após a execução do comando para criar o cluster com 4 nós, você receberá a seguinte saída no terminal:<br>
Na aws: <br>
```
Acesse em outro terminal e execute a sequência de comandos para acessar o servidor controller:
eval $(ssh-agent -s) #Importando a chave do cluster para o controller acessar os nós.
ssh-add clusterKey.pem 
ssh -A ubuntu@3.239.169.121 #Acessando o controller e compartilhando a chave para acessar os nós

Aperte [enter] duas vezes para finalizar o cluster. #Após a execução você pode deletar o cluster
Primeira vez.
```
<br>
Na Azure: <br>

```
Acesse em outro terminal e execute a sequência de comandos para acessar o servidor controller:
eval $(ssh-agent -s) #Importando a chave do cluster para o controller acessar os nós.
ssh-add ~/.ssh/Key_Azure #Passphrase da chave criada é (azure)
ssh -A ubuntu@157.55.185.117 #Acessando o controller e compartilhando a chave para acessar os nós
Aperte [enter] duas vezes para finalizar o Grupo de Recursos.
Primeira vez.
```
<br>
Quando acessar o controller através da sequência de comando da saída acima, execute o comando **ls** para listar os arquivos do diretório onde você está vai aparecer um arquivo IPs.txt contendo os IPs dos nós do Cluster. <br>
Após conseguir acessar o controller siga para etapa 1, no servidor controller vai ficar rodando o socket servidor.py, faça as alterações que a etapa e solicita. <br>


## Etapa 1 - Socket do servidor

Após acessar o controller siga os seguintes passo: <br>

Crie um arquivo servidor.py <br>

Cole o seguinte conteudo no arquivo servidor.py: <br>
```
#!/usr/bin/env python3
import socket
HOST = '10.0.10.123'    # IP do nó Controller
PORT = 50000            # Porta que o Servidor vai aguardar as conexao
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind((HOST, PORT))
s.listen()
print("Aguardando conexão dos Computers Nodes")
conn, ender = s.accept()
print("Conectado em", ender)
while True:
    data = conn.recv(1024)
    if not data:
        print("Fechando a conexão")
        conn.close()
        break
        conn.sendall(data)
```
<br>
Lembre de colocar o IP privado do controller, com o comando abaixo ele mostra o IP privado: <br>

`hostname -I`

Execute o socket servidor.py: <br>

`python3 servidor.py`


## Etapa 2 - Socket do cliente

Vamos criar o arquivo cliente.py em cada nó computes do cluster: <br>

Crie um arquivo cliente.py <br>


Cole o seguinte conteudo no arquivo cliente.py: <br>

```
#!/usr/bin/env python3
import socket
HOST = '10.0.10.123' # IP do nó Controller
PORT = 50000         # Servidor e Cliente tem que esta na mesma porta
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((HOST, PORT))
s.sendall(str.encode("My IP!!"))
data = s.recv(1024)
print("Mensagem ecoada:", data.decode())

```

Execute o socket cliente.py: <br>

`python3 cliente.py` <br>


