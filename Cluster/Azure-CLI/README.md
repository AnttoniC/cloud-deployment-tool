
# Azure  
<br>

![img](https://github.com/AnttoniC/cloud-deployment-tool/blob/main/Cluster/Azure-CLI/IMG/azure.png)

## Instalação do Azure CLI no Linux
Existem duas opções para instalar a CLI do Azure em seu sistema. Primeiro, você pode executar um único comando que baixará um script de instalação e executará os comandos de instalação para você. Ou se preferir, você mesmo pode executar os comandos de instalação em um processo passo a passo. Ambos os métodos são fornecidos abaixo.<br>

## Opção 1: Instalar com um comando

`curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash`

## Opção 2: Instruções de instalação passo a passo

Se você preferir um processo de instalação passo a passo, conclua as etapas a seguir para instalar a CLI do Azure.<br>

## Etapa 1 - Obtenha os pacotes necessários para o processo de instalação
`sudo apt-get update`
`sudo apt-get install ca-certificates curl apt-transport-https lsb-release gnupg`

## Etapa 2 - Baixe e instale a chave de assinatura da Microsoft
`curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null`

## Etapa 3 - Adicione o repositório de software da CLI do Azure (pule esta etapa em distribuições ARM64 Linux)
AZ_REPO=$(lsb_release -cs)
`echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | sudo tee /etc/apt/sources.list.d/azure-cli.list`

## Etapa 4 - Atualize as informações do repositório e instale o azure-cli pacote
`sudo apt-get update`
`sudo apt-get install azure-cli`


## Entrar no Azure com a CLI do Azure
Execute a CLI do Azure com o `az` comando. Para entrar , use o comando `az login`. <br> 
`az login`




