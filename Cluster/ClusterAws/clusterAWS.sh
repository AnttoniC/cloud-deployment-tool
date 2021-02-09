#!/bin/bash -vx

touch cluster_template.json

NODE=""
TYPE=""


#criando chave para acessar as instancia do cluster
KEYNAME=clusterKey
aws ec2 create-key-pair --key-name $KEYNAME --query 'KeyMaterial' --output text > $KEYNAME.pem
chmod 400 $KEYNAME.pem

# Gera nome único para a pilha
STACKNAME="cluster"`date +%H%M%S`

cat << EOF >> cluster_template.json
{
    "AWSTemplateFormatVersion": "2010-09-09",
    "Description": "Criacao de um cluster",
    "Parameters": {
        "KeyName": {
            "Description": "Nome do par de chaves",
            "Type": "AWS::EC2::KeyPair::KeyName",
            "Default": "$KEYNAME"    
        },
        
        "FaixaIPVPC": {
            "Description": "Faixa IP Utilizada no VPC",
            "Type": "String",
            "Default": "10.0.0.0/16",
            "AllowedValues": [
                "10.0.0.0/16",
                "172.16.0.0/16",
                "192.168.0.0/16"
            ]
        },
        "FaixaIPSubrede": {
            "Description": "Faixa IP Utilizada na Subrede",
            "Type": "String",
            "Default": "10.0.10.0/24",
            "AllowedValues": [
                "10.0.10.0/24",
                "172.16.10.0/24",
                "192.168.10.0/24"
            ]
        },


        "InstanceType": {
            "Description": "Tipo de instancia",
            "Type": "String",
            "Default": "t2.micro",
            "AllowedValues": [
                "t2.micro",
                "t2.small",
                "t2.medium"
            ]
        }
    }
    ,
    "Resources": {

        "VPC": {
            "Type": "AWS::EC2::VPC",
            "Properties": {
                "CidrBlock": {
                    "Ref": "FaixaIPVPC"
                },
                "Tags": [
                    {
                        "Key": "Name",
                        "Value": "ClusterVPC"
                    }
                ]

            }
        },
        "Subnet": {
            "Type": "AWS::EC2::Subnet",
            "Properties": {
                "VpcId": {
                    "Ref": "VPC"
                },
                "CidrBlock": {
                    "Ref": "FaixaIPSubrede"
                },
                "MapPublicIpOnLaunch" : "true"
            }
        },
        "RoteadorInternet": {
            "Type": "AWS::EC2::InternetGateway"
            
        },
        
        "LigacaoRoteadorVPC": {
            "Type": "AWS::EC2::VPCGatewayAttachment",
            "Properties": {
                "InternetGatewayId": {
                    "Ref": "RoteadorInternet"
                },
                "VpcId": {
                    "Ref": "VPC"
                }
            }
        },

        "TabelaRoteamento": {
            "Type": "AWS::EC2::RouteTable",
            "Properties": {
                "VpcId": {
                    "Ref": "VPC"
                }
                
            }
        },
        "EntradaTabelaRoteamento": {
            "Type": "AWS::EC2::Route",
            "Properties": {
                "GatewayId": {
                    "Ref": "RoteadorInternet"
                },
                "DestinationCidrBlock": "0.0.0.0/0",
                "RouteTableId": {
                    "Ref": "TabelaRoteamento"
                }
            }
        },
        "LigacaoTabelaSubRede": {
            "Type": "AWS::EC2::SubnetRouteTableAssociation",
            "Properties": {
                "SubnetId": {
                    "Ref": "Subnet"
                },
                "RouteTableId": {
                    "Ref": "TabelaRoteamento"
                }
            }
        },

        "GrupoDeSeguranca": {
            "Type": "AWS::EC2::SecurityGroup",
            "Properties": {
                "GroupDescription": "Grupo de Seguranca",
                "VpcId": {
                    "Ref": "VPC"
                },
                "SecurityGroupIngress": [
                    {
                        "CidrIp": "0.0.0.0/0",
                        "FromPort": 22,
                        "IpProtocol": "tcp",
                        "ToPort": 22
                    },
                    {
                        "CidrIp": "0.0.0.0/0",
                        "FromPort": 2049,
                        "IpProtocol": "tcp",
                        "ToPort": 2049
                    }
                ]
            }
        },
        "Controller": {
            "Type": "AWS::EC2::Instance",
            "Properties": {
                "Tags": [
                    {
                        "Key": "Name",
                        "Value": "Controller"
                    }
                ],
                "ImageId": "ami-024a64a6685d05041",
                "InstanceType": {
                    "Ref": "InstanceType"
                },
                "KeyName": {
                    "Ref": "KeyName"
                },
                "SecurityGroupIds": [
                    {
                        "Ref": "GrupoDeSeguranca"
                    }
                ],
                "SubnetId": {
                    "Ref": "Subnet"
                },
                 "UserData": {
                    "Fn::Base64": {
                        "Fn::Join": [
                            "",
                            [
								"#!/bin/bash -ex \n",
                                "curl -s https://raw.githubusercontent.com/AnttoniC/TAR/master/CF/nfsServer.sh | bash -ex \n"
                            ]
                        ]
                    }
                }
            }
        }
EOF

#Criando os nós(Compute)

for v in $(seq 1 $NODE);
  do
  v=$((v+0))
  Compute=Compute0$v
  cat  << EOF >> cluster_template.json
  ,
  "$Compute": {
            "Type": "AWS::EC2::Instance",
            "Properties": {
                "Tags": [
                    {
                        "Key": "Name",
                        "Value": "$Compute"
                    }
                ],
                "ImageId": "ami-024a64a6685d05041",
                "InstanceType": {
                    "Ref": "InstanceType"
                },
                "KeyName": {
                    "Ref": "KeyName"
                },
                "SecurityGroupIds": [
                    {
                        "Ref": "GrupoDeSeguranca"
                    }
                ],
                "SubnetId": {
                    "Ref": "Subnet"
                },
                "UserData": {
                    "Fn::Base64": {
                        "Fn::Join": [
                            "",
                            [
                                "#!/bin/bash -ex \n",
                                "export ipS=\"",{"Fn::GetAtt": ["Controller","PrivateIp"]},"\" \n",
                                "curl -s https://raw.githubusercontent.com/AnttoniC/TAR/master/CF/nfsClient.sh | bash -ex \n"
                            ]
                        ]
                    }
                }
            }
        }
EOF
  done

cat << EOF >> cluster_template.json

   },
    "Outputs": {
        "EnderecoPublicoController": {
            "Value": {
                "Fn::GetAtt": [
                    "Controller",
                    "PublicIp"
                ]
            },
            "Description": "Endereco para acessar o Controller"
        }
    }
  }
EOF

#Implantação do template que foi criado acima

aws cloudformation create-stack --stack-name "$STACKNAME" --template-body file://cluster_template.json --parameters \
ParameterKey=InstanceType,ParameterValue=$TYPE \
ParameterKey=KeyName,ParameterValue=$KEYNAME \
ParameterKey=FaixaIPVPC,ParameterValue="10.0.0.0/16" \
ParameterKey=FaixaIPSubrede,ParameterValue="10.0.10.0/24"


echo $TYPE
exit 1

STATUS=$(aws cloudformation describe-stacks --stack-name "$STACKNAME" --query 'Stacks[*].StackStatus' --output text)
var=1
while [ $var -eq 1 ]
do   
STATUS=$(aws cloudformation describe-stacks --stack-name "$STACKNAME" --query 'Stacks[*].StackStatus' --output text)
sleep 10
if [ $STATUS = "CREATE_COMPLETE" ];
then
    var=0
    echo "Cluster criado."
elif [ $STATUS = "ROLLBACK_IN_PROGRESS" ];
then
    var=0
    echo "Erro ao criado cluster."
else
echo "Status atual do cluster em: $STATUS" 
fi
done

#Pegando ip pblico da instancia controller
PUBLICIP=$(aws cloudformation describe-stacks --stack-name "$STACKNAME"  --query 'Stacks[*].Outputs[*].OutputValue' --output text)


echo "Acesse em outro terminal e execute a seguencia de comandos:"
echo "eval $``(ssh-agent -s)"
echo "ssh-add $KEYNAME.pem"
echo "ssh -A ubuntu@$PUBLICIP"

echo "Aperte [enter] duas vezes para finalizar o cluster."
read -p "Primeira vez."
read -p "Segunda vez."
aws cloudformation delete-stack --stack-name $STACKNAME
aws ec2 delete-key-pair --key-name $KEYNAME
rm -rf cluster_template.json
rm -rf $KEYNAME.pem

