#!/bin/bash

CLOUD=""
NODE=""
TYPE=""
export NODE
export TYPE

usage() { echo "Usage: $0 -c [_aws ou _azure] [-n <2|4|6|8>] [-i <string>]"
	  echo "help: $0 -h"; }

ajuda() {   
            echo ""
            echo "DESCRIÇÃO"
            echo "       Esse script tem como finalidade executar um cluster em uma nuvem publica(Azure ou AWS)."
            echo ""
            echo "       -c, Para implantar em uma das plataformas Azure ou AWS."
	    echo ""
            echo "	     Defina qual cloud vc quer executar o cluster, as opções são:"	
            echo ""
            echo " 	      AWS [_aws] e AZURE [_azure]"
            echo ""
            echo "       -n, Define a quantidade de Nós que vc quer implantar no seu cluster."
            echo ""
            echo "       -i, Define o tipo de VM ou Isntancia dos nós. As VMs e Intancia disponivel para o cluster "
            echo "           de acordo com cada plataforma são:"
            echo ""
            echo "           AWS [t2.micro,t2.small e t2.medium]"
            echo ""
            echo "           AZURE [Standard_B1s e Standard_B1ms]"
            echo ""
            echo "EXEMPLOS DE EXECUÇÃO"
            echo "        Abaixo tem alguns exemplos de execução em cada plataforma."
            echo ""
            echo "        Implantando Cluster na AZURE"
            echo ""
            echo "        ./cluster.sh -c _azure -n 2 -i Standard_B1s"
            echo ""
            echo "        Implantando Cluster na AWS"
            echo ""
            echo "        ./cluster.sh -c _aws -n 2 -i t2.micro"; }



while getopts "c:n:i:h" opt; do
    case $opt in
      c) CLOUD="$OPTARG" 
	((c == "_aws" || c == "_azure" ))
      ;;
      n) NODE="$OPTARG"
        ((n == 2 || n == 4 || n == 6 || n == 8)) || usage
      ;;
      i) TYPE="$OPTARG"
      ;;
      h) ajuda
      ;;
      *) usage
      ;;
    esac
done

echo $CLOUD
if [ -z "$TYPE" ]; then
  usage  
  exit 1 # error
else
  if [ -n "$NODE" ]; then
    echo "$NODE and $TYPE"
  else
    usage
  fi
fi 

#Se o tipo de intancia for da aws ele deve executar na aws 
declare -a arrType_aws=("t2.micro" "t2.small" "t2.medium")
if [ $CLOUD == "_aws" ]; then
    for i in "${arrType_aws[@]}"
    do
       if [ "$i" == "$TYPE" ]; then
	 echo "$i"
         ./deployAWS.sh
       else
         echo "Erro na execução do Cluster na AWS"
	 usage
	 echo "./cluster.sh -h para ver as opções"
       fi
    done
elif [ $CLOUD == "_azure" ]; then
#Se o tipo de intancia for da azure ele deve executar na azure 
declare -a arrType_azure=("Standard_B1s" "Standard_B1ms")
    for e in "${arrType_azure[@]}"
    do
       if [ "$e" == "$TYPE" ]; then
	 echo "$e"
       	 ./deployAzure.sh
       else
         echo "Erro na execução do Cluster na Azure"
	 usage
	 echo "./cluster.sh -h para ver as opções"
	fi
    done

else
 echo "$TYPE não é valido!!"
fi
