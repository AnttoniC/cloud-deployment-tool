#!/bin/bash

#set -x

CLOUD=""
NODE=""
TYPE=""
export NODE
export TYPE

usage() { echo "Usage: $0 -c [_aws ou _azure] [-n <2|4|6|8>] [-i <string>]"
	  echo "help: $0 -h" 1>&2; exit 1; }

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
      ;;
      n) NODE="$OPTARG"
      ;;
      i) TYPE="$OPTARG"
      ;;
      h) ajuda
      ;;
      *) usage	
      ;;
    esac
done


#if [ $NODE ]; then
#     declare -a arrType=("2" "4" "6" "8")
#     for j in "${arrType[@]}"
#     do
#       if [ $NODE -ne $j ]; then
#           echo $j
#       fi
#      done
#fi


if [ -z "$TYPE" ] || [ -z "$CLOUD" ] ; then
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
if [ $CLOUD == "_aws" ]; then
    declare -a arrType_aws=("t2.micro" "t2.small" "t2.medium")
    for i in "${arrType_aws[@]}"
    do
       declare -a arrType_aws=("t2.micro" "t2.small" "t2.medium")
       if [ "$i" == "$TYPE" ]; then
	 ./deployAWS.sh
       fi
    done
       if [ $i != $TYPE ]; then
         echo "Erro na execução do Cluster na AWS"
#         echo "$TYPE não é valido!!"
	 echo "./cluster.sh -h para ver as opções"
       else
	 usage
       fi

#Se o tipo de intancia for da azure ele deve executar na azure 
elif [ $CLOUD == "_azure" ]; then
    declare -a arrType_azure=("Standard_B1s" "Standard_B1ms")
    for e in "${arrType_azure[@]}"
    do
       if [ "$e" == "$TYPE" ]; then
       	 ./deployAzure.sh
       fi
    done
       if [ $e != $TYPE ]; then
         echo "Erro na execução do Cluster na Azure"
 #        echo "$TYPE não é valido!!"
	 echo "./cluster.sh -h para ver as opções"
       else
	 usage
       fi
    
else
   if [ $CLOUD != "_aws" ] || [ $CLOUD != "_azure" ]; then
      echo "$CLOUD não é valido!!"
   fi 
fi

