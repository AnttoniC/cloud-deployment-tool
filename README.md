# cloud-deployment-tool

## Execução do Script 
<br>
O script tem como objetivo construir um cluster na plataforma de nuvem pública AWS ou Azure, permitindo aos desenvolvedores implantar aplicativos de microsserviços sem gerenciar máquinas virtuais, armazenamento ou rede.
<br>
obs: (Antes de executar esse script certifique que o ambiente de execução está preparado)<br>

## Pré-requisitos

É necessário que o usuário tenha um conta na aws e na azure, para poder realizar a instalação e configuração do aws-cli e azure-cli, segue abaixo um link para instalação e configuração:

Instalção do aws-cli e configuração.<br>
[AWS-CLI](https://github.com/AnttoniC/cloud-deployment-tool/tree/main/Cluster/Aws-CLI)<br>

Instalção do azure-cli e configuração.<br>
[AZURE-CLI](https://github.com/AnttoniC/cloud-deployment-tool/tree/main/Cluster/Azure-CLI)<br>

## Opções de execução do Script
Com o comando **chmod** vamos tornar os scripts executáveis. <br>

`chmod +x cluster.sh deployAzure.sh deployAWS.sh`

Para visualizar as informações sobre os comandos internos, use a opção **-h**.
<br>

```
./cluster -h
 
DESCRIÇÃO
       Esse script tem como finalidade executar um cluster em uma nuvem publica(Azure ou AWS).

       -c, Para implantar em uma das plataformas Azure ou AWS.

             Defina qual cloud vc quer executar o cluster, as opções são:

              AWS [_aws] e AZURE [_azure]

       -n, Define a quantidade de Nós que vc quer implantar no seu cluster.

       -i, Define o tipo de VM ou Isntancia dos nós. As VMs e Intancia disponivel para o cluster
           de acordo com cada plataforma são:

           AWS [t2.micro,t2.small e t2.medium]

           AZURE [Standard_B1s e Standard_B1ms]

EXEMPLOS DE EXECUÇÃO
        Abaixo tem alguns exemplos de execução em cada plataforma.

        Implantando Cluster na AZURE

        ./cluster.sh -c _azure -n 2 -i Standard_B1s

        Implantando Cluster na AWS

        ./cluster.sh -c _aws -n 2 -i t2.micro

```
Executando o camando sem opções ele retornara um usage. <br>
```
./cluster.sh
Usage: ./cluster.sh -c [_aws ou _azure] [-n <2|4|6|8>] [-i <string>]
help: ./cluster.sh -h

```

Para executar o cluster na aws ou azure, use a opção **-c** , sendo os paramentos aceitos **_aws** para AWS e **_azure** para Azure. 

`./cluster.sh -c _aws`<br>
`./cluster.sh -c _azure`<br>

Para escolher a quantidade de nós que deseja exceutar no no cluster, use a opção **-n** , as opções aceita de **-n** são(2,4,6 e 8).<br> 

`./cluster -n 2`<br>

Para escolher o tipo de VM ou Instancia do seu cluster, use a opção **-i** , dependendo de qual nuvem você escollher as opções mudam, sendo as opções aceitas para aws (**t2.micro, t2.small e t2.medium**) e para azure (**Standard_B1s e Standard_B1ms**)

Na aws:<br>
`./cluster.sh -i t2.micro`<br>

Na azure:<br>
`./cluster.sh -i Standard_B1s`<br>

Para implantar um cluster na aws execute o seguinte comando:<br>

```
./cluster.sh -c _aws -n 2 -i t2.micro

2 and t2.micro 
{
    "StackId": "arn:aws:cloudformation:us-east-1:760851492626:stack/cluster213038/3a06b5f0-6fee-11eb-882b-12d7a78ee1f9"
}
Status atual do cluster em: CREATE_IN_PROGRESS
Status atual do cluster em: CREATE_IN_PROGRESS
Status atual do cluster em: CREATE_IN_PROGRESS
Status atual do cluster em: CREATE_IN_PROGRESS
Status atual do cluster em: CREATE_IN_PROGRESS
Cluster criado.

```
Para implantar um cluster na azure execute o seguinte comando:<br>

```
./cluster.sh -c _azure -n 2 -i Standard_B1s
2 and Standard_B1s

#Na etapa inicial da implantação na azure os recursos do cluster vão ser criado no Grupo de Recursos

{
  "id": "/subscriptions/312b5621-1bf1-4857-b6ef-2a9a2a5c222e/resourceGroups/RG214224",
  "location": "southcentralus",
  "managedBy": null,
  "name": "RG214224",
  "properties": {
    "provisioningState": "Succeeded"
  },
  "tags": null,
  "type": "Microsoft.Resources/resourceGroups"
}


#Nessa parte da implatação estamos criando uma conta de armazenmento para Grupo de recursos que foi criado

 - Running .. 

  "primaryLocation": "southcentralus",
  "privateEndpointConnections": [],
  "provisioningState": "Succeeded",
  "resourceGroup": "RG214224",
  "routingPreference": null,
  "secondaryEndpoints": null,
  "secondaryLocation": null,
  "sku": {
    "name": "Standard_LRS",
    "tier": "Standard"
  },
  "statusOfPrimary": "available",
  "statusOfSecondary": null,
  "tags": {},
  "type": "Microsoft.Storage/storageAccounts"
}

#Criando chave publica para acessar o cluster.

Generating public/private rsa key pair.
Your identification has been saved in /home/jarvis/.ssh/Key_Azure.
Your public key has been saved in /home/jarvis/.ssh/Key_Azure.pub.
The key fingerprint is:
SHA256:ERkYSsslGrDsQdZ5AlACmMUXx1rnHYkErYGIYW800ls jarvis@ubuntu
The key's randomart image is:
+---[RSA 2048]----+
|X#B+=+=*++ .     |
|Oo*X+E= =.o      |
|.o.+Oo =.. .     |
|. o.. . ...      |
| .      S        |
|                 |
|                 |
|                 |
|                 |
+----[SHA256]-----+
 - Running ..   
Cluster criado!!
```

## Acessando o Clsuter

Na aws: <br>
```
Acesse em outro terminal e execute a seguencia de comandos:
eval $(ssh-agent -s) #Importando a chave do cluster para o controller acessar os nós.
ssh-add clusterKey.pem 
ssh -A ubuntu@3.239.169.121 #Acessando o controller e compartilhando a chave para acessar os nós

Aperte [enter] duas vezes para finalizar o cluster. #Após a execução você pode deletar o cluster
Primeira vez.
```
<br>
Na Azure: <br>

```
Acesse em outro terminal e execute a seguencia de comandos:
eval $(ssh-agent -s) #Importando a chave do cluster para o controller acessar os nós.
ssh-add ~/.ssh/Key_Azure #Passphrase da chave criada é (azure)
ssh -A ubuntu@157.55.185.117 #Acessando o controller e compartilhando a chave para acessar os nós

Aperte [enter] duas vezes para finalizar o Grupo de Recursos.
Primeira vez.
```
