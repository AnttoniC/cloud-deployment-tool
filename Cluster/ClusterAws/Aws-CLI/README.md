
# AWS
<br>

![img](https://github.com/AnttoniC/Gerencia/blob/master/Img/zab2.jpg)

## Pré-requisitos
É necessário ter Python 2, versão 2.7 ou posterior, ou Python 3, versão 3.4 ou posterior instalado.
## Instalação do AWS CLI no Linux
As etapas a seguir permitem que você instale a AWS CLI versão 1 pela linha de comando em qualquer compilação do Linux ou do macOS.<br>
Veja a seguir um resumo dos comandos de instalação explicados a seguir que você pode recortar e colar para executar como um único conjunto de comandos.<br>

## Opção 1: Instalar a AWS CLI versão 1 usando o instalador empacotado com sudo
Para obter a versão mais recente da AWS CLI, use o seguinte bloco de comandos:
`curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"` 
`unzip awscli-bundle.zip` 
`sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws`

## Opção 2: Instalar a AWS CLI versão 1 usando pip

Se você ainda não tem o pip instalado, você pode instalá-lo usando o script que o Python Packaging Authority fornece. Execute pip --version para ver se a sua versão do Linux já inclui Python e pip. Se o Python versão 3 ou posterior estiver instalado, recomendamos usar o comando pip3.<br>

## Etapa 1 - Instalar o pip
`sudo apt update`
`sudo apt install python3-pip`

## Etapa 2 - Para obter a versão mais recente da AWS CLI, use o seguinte bloco de comandos:
`pip3 install awscli --upgrade --user`

## Etapa 3 - Verifique se o AWS CLI está instalado corretamente
`aws --version`

## Etapa 4 - Criar um usuario IAM(Identity and Access Management) no console AWS.
![img](https://github.com/AnttoniC/Gerencia/blob/master/Img/zab2.jpg)

## Entrar com as credenciais do usuário IAM através do comando: 
`aws configure`




