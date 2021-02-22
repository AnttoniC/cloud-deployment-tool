
# AWS CLI
<br>

![img](https://github.com/AnttoniC/TCC/blob/master/Ferramenta/MINP_Aws/ClusterAws/Aws-CLI/IMG/awscli.png)

## Pré-requisitos
É necessário ter Python 2, versão 2.7 ou posterior, ou Python 3, versão 3.4 ou posterior instalado.
## Instalação do AWS CLI no Linux
As etapas a seguir permitem que você instale a AWS CLI versão 1 pela linha de comando em qualquer versão do Linux.<br>
Algumas distribuições linux tem o pacote `awscli` disponível em repositórios para outros gerenciadores de pacotes, como `apt` e `yum`. <br>
Executando o comando abaixo ele irar verficar se a `awscli` está disponivel no seu gerenciador de pacotes. <br>
`apt search awscli`

Veja abaixo um resumo dos comandos de instalação que você pode recortar e colar para executar como um único comando.<br>
## Opção 1: Instalar a AWS CLI versão 1 usando o instalador empacotado com sudo
Para obter a versão mais recente da AWS CLI, use o seguinte bloco de comandos:<br>
```
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
unzip awscli-bundle.zip
sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
```

## Opção 2: Instalar a AWS CLI versão 1 usando pip

Se você ainda não tem o pip instalado, você pode instalá-lo usando o script que o Python Packaging Authority fornece. Execute pip --version para ver se a sua versão do Linux já inclui Python e pip. Se o Python versão 3 ou posterior estiver instalado, recomendamos usar o comando pip3.<br>

## Etapa 1 - Instalar o pip
```
sudo apt update
sudo apt install python3-pip
```

## Etapa 2 - Para obter a versão mais recente da AWS CLI, use o seguinte bloco de comandos:
`pip3 install awscli --upgrade --user`

## Etapa 3 - Verifique se o AWS CLI está instalado corretamente
`aws --version`

## Etapa 4 - Criar um usuario IAM(Identity and Access Management) no console AWS.
Para criar um ou mais usuários do IAM (console).<br>
No painel de navegação, escolha *Usuários* e depois *Adicionar usuário*.<br>

Siga os seguines passos abaixo:<br>
**1 passo:**
Criar nome do seu usuario e selecionar a caixa *Acesso Programático*
![img](https://github.com/AnttoniC/TCC/blob/master/Ferramenta/MINP_Aws/ClusterAws/Aws-CLI/IMG/add_IAM.png)<br>

**2 passo:**
Criar um grupo para o usuario que estamos criando e atribuir políticas de acesso<br>
![img](https://github.com/AnttoniC/TCC/blob/master/Ferramenta/MINP_Aws/ClusterAws/Aws-CLI/IMG/addGroup01.png)
Digite o nome do seu grupo e selecione a permissão *AdministratorAccess* para ter acessos aos recursos e serviços através da AWS-CLI
![img](https://github.com/AnttoniC/TCC/blob/master/Ferramenta/MINP_Aws/ClusterAws/Aws-CLI/IMG/groupCli.png)
Selecione o grupo que criou
![img](https://github.com/AnttoniC/TCC/blob/master/Ferramenta/MINP_Aws/ClusterAws/Aws-CLI/IMG/addGroup02.png)<br>

**3 passo:**
Revise as escolhas para ter certeza que não esqueceu nada e clique em *Criar Usuario*
![img](https://github.com/AnttoniC/TCC/blob/master/Ferramenta/MINP_Aws/ClusterAws/Aws-CLI/IMG/criarUser.png)
Faça download da suas crendencias, esta é a única oportunidade de visualizar ou fazer download das chaves de acesso secretas
![img](https://github.com/AnttoniC/TCC/blob/master/Ferramenta/MINP_Aws/ClusterAws/Aws-CLI/IMG/chaveDeAcesso.png)<br>

## Entrar com as credenciais do usuário IAM através do comando:
No campo *Deafault region name* vamos utilizar a região **us-east-1** Leste dos EUA (Norte da Virgínia) <br>
```
aws configure

AWS Access Key ID [****************TXCG]:
AWS Secret Access Key [****************Wnjw]:
Default region name [us-east-1]:
Default output format [None]:
```
