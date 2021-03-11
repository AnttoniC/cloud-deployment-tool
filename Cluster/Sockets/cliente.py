
#!/usr/bin/env python3

import socket

HOST = 'IP_Servidor(Controller)'

PORT = 50000

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

s.connect((HOST, PORT))

s.sendall(str.encode("My IP!!"))

data = s.recv(1024)

print("Mensagem ecoada:", data.decode())


