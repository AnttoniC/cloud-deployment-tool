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
Para visualizar as informações sobre os comandos internos, use a opção **-h**.
Executando o camando sem opções ele retornara um usage.
<br>
Com o comando **chmod** vamos tornar os scripts executáveis. <br>
'''chmod +x cluster.sh deployAzure.sh deployAWS.sh''' <br>

`./cluster -h`<br>
`./cluster`<br>
![img](https://github.com/AnttoniC/cloud-deployment-tool/blob/main/Cluster/Aws-CLI/IMG/-h.png)
<br>

Para executar o cluster na aws ou azure, use a opção **-c** , sendo os paramentos aceitos **_aws** para AWS e **_azure** para Azure. 

`./cluster -c _aws`<br>
`./cluster -c _azure`<br>

Para escolher a quantidade de nós que deseja exceutar no no cluster, use a opção **-n** , as opções aceita de **-n** são(2,4,6 e 8).<br> 

`./cluster -n 2`<br>

Para escolher o tipo de VM ou Instancia do seu cluster, use a opção **-i** , dependendo de qual nuvem você escollher as opções mudam, sendo as opções aceitas para aws (**t2.micro, t2.small e t2.medium**) e para azure (**Standard_B1s e Standard_B1ms**)

Na aws:<br>
`./cluster -i t2.micro`<br>

Na azure:<br>
`./cluster -i Standard_B1s`<br>

Para implantar um cluster na aws execute o seguinte comando:<br>

`./cluster -c _aws -n 2 -i t2.micro` <br>
![img](https://github.com/AnttoniC/cloud-deployment-tool/blob/main/Cluster/Aws-CLI/IMG/deployAWS.png) <br>

Para implantar um cluster na azure execute o seguinte comando:<br>
`./cluster -c _azure -n 2 -i Standard_B1s` <br>
![img](https://github.com/AnttoniC/cloud-deployment-tool/blob/main/Cluster/Aws-CLI/IMG/deployAzure.png) <br>

## Acessando o Clsuter

Na aws: <br>
![img](https://github.com/AnttoniC/cloud-deployment-tool/blob/main/Cluster/Aws-CLI/IMG/acessoAws.png) <br>

Na Azure: <br>
![img](https://github.com/AnttoniC/cloud-deployment-tool/blob/main/Cluster/Aws-CLI/IMG/acessoAzure.png) <br>

