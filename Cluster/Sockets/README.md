# Sockets com Python  
<br>

Objetivo desse exercício é mostrar que o cluster está configurado e o usuário e está pronto para práticas distribuídas.

## Manipulando sockets via protocolo TCP

Um soquete de rede é um ponto final de um fluxo de comunicação entre processos através de uma rede de computadores. Neste exercício vamos criar uma estrutura cliente/Servidor para o cluster criado, onde o servidor controller vai ficar escutando e esperando as conexões dos nós (Computes).

## Etapa 1 - Socket do servidor

Após acessar o controller siga os seguintes passo: <br>

Crie um arquivo servidor.py <br>

Cole o seguinte conteudo no arquivo servidor.py: <br>
```
#!/usr/bin/env python3
import socket
HOST = '10.0.10.123'    # IP do nó Controller
PORT = 50000            # Porta que o Servidor vai aguarda as conexão
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

Vamos criar o arquivo cliente.py em cada no nós computes: <br>

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


