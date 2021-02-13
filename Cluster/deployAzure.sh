
#!/bin/bash

set +x

ResourceGroup="RG"`date +%H%M%S`
# A conta de armazenamento deve ser única.
StorageAccount="storage"`date +%H%M%S`
# criando grupo de recursos na região Centro-Sul dos EUA (southcentralus).
az group create --name $ResourceGroup --location southcentralus

# criando conta de armazenamento para implantar recursos na mesma região (southcentralus).
az storage account create -n $StorageAccount -g $ResourceGroup -l southcentralus --sku Standard_LRS

echo "Criando chave publica para acesso ssh as VMs"
KeyName=Key_Azure
ssh-keygen -f ~/.ssh/$KeyName -t rsa -N azure


KEYAZURE=$(cat ~/.ssh/Key_Azure.pub)

touch ~/mod_cluster.json

S='$schema'

cat << EOF >> ~/mod_cluster.json

{
  "$S": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",

  "parameters": {
    "vmName": {
      "defaultValue": "vmController",
      "type": "string",
      "minLength": 1
    },
    "vmAdminUserName": {
      "defaultValue": "ubuntu",
      "type": "string",
      "minLength": 1
    },

    "vmAdminKey": {
      "defaultValue": "$KEYAZURE",
      "type": "securestring"
    },

    "vmUbuntuOSVersion": {
      "type": "string",
      "defaultValue": "18.04-LTS",
      "allowedValues": [
        "12.04.5-LTS",
        "14.04.2-LTS",
        "16.04.0-LTS",
        "18.04-LTS"
      ]
    },


    "vmSize": {
      "defaultValue": "$TYPE",
      "type": "string",
      "allowedValues": [
        "Standard_B1s",
        "Standard_B1ms"
      ],
      "metadata": {
        "description": "Size of vm"
      }
    },
    "networkSecurityGroupName": {
      "type": "string",
      "defaultValue": "nsgCluster"
    },

    "storageAccountName": {
      "type": "string",
      "defaultValue": "$StorageAccount"
    },
    "storageAccountResourceGroup": {
      "type": "string",
      "defaultValue": "$ResourceGroup"
    },
    "ipPublicDnsName": {
      "defaultValue": "azdnsip",
      "type": "string",
      "minLength": 1
    },
    "_artifactsLocation": {
      "defaultValue": "https://raw.githubusercontent.com/AnttoniC/TCC/master/Ferramenta/MINP_Azure",
      "type": "string"

    }
  },
  "variables": {
    "vNetPrefix": "10.0.0.0/16",
    "vNetSubnet1Name": "Subnet-1",
    "vNetSubnet1Prefix": "10.0.0.0/24",
    "vNetSubnet2Name": "Subnet-2",
    "vNetSubnet2Prefix": "10.0.1.0/24",
    "vmImagePublisher": "Canonical",
    "vmImageOffer": "UbuntuServer",
    "vmOSDiskName": "vmOSDisk",
    "vmVnetID": "[resourceId('Microsoft.Network/virtualNetworks', 'vNet')]",
    "vmSubnetRef": "[concat(variables('vmVnetID'), '/subnets/', variables('vNetSubnet1Name'))]",
    "vmStorageAccountContainerName": "vhds",
    "vmNicName": "[concat(parameters('vmName'), 'NetworkInterface')]",
    "ipPublicName": "ipPublic"


  },
  "resources": [
    {
      "name": "vNet",
      "type": "Microsoft.Network/virtualNetworks",
      "location": "[resourceGroup().location]",
      "apiVersion": "2016-03-30",
      "dependsOn": [],
      "tags": {
        "displayName": "vNet"
      },
      "properties": {
        "addressSpace": {
          "addressPrefixes": [
            "[variables('vNetPrefix')]"
          ]
        },
        "subnets": [
          {
            "name": "[variables('vNetSubnet1Name')]",
            "properties": {
              "addressPrefix": "[variables('vNetSubnet1Prefix')]"
            }
          },
          {
            "name": "[variables('vNetSubnet2Name')]",
            "properties": {
              "addressPrefix": "[variables('vNetSubnet2Prefix')]"
            }
          }
        ]
      }
    },

    {
      "name": "[parameters('networkSecurityGroupName')]",
      "apiVersion": "2016-03-30",
      "type": "Microsoft.Network/networkSecurityGroups",
      "location": "[resourceGroup().location]",
      "properties": {
        "securityRules": [
          {
            "name": "SSH",
            "properties": {
              "priority": 1000,
              "protocol": "TCP",
              "access": "Allow",
              "direction": "Inbound",
              "sourceAddressPrefix": "*",
              "sourcePortRange": "*",
              "destinationAddressPrefix": "*",
              "destinationPortRange": "22"
            }
          },
          {
            "name": "NFS",
            "properties": {
              "priority": 1010,
              "protocol": "TCP",
              "access": "Allow",
              "direction": "Inbound",
              "sourceAddressPrefix": "*",
              "sourcePortRange": "*",
              "destinationAddressPrefix": "*",
              "destinationPortRange": "2049"
            }
          }
        ]
      }

    },

    {
      "name": "[variables('vmNicName')]",
      "type": "Microsoft.Network/networkInterfaces",
      "location": "[resourceGroup().location]",
      "apiVersion": "2016-03-30",
      "dependsOn": [
        "[resourceId('Microsoft.Network/networkSecurityGroups/', parameters('networkSecurityGroupName'))]",
        "[resourceId('Microsoft.Network/virtualNetworks', 'vNet')]",
        "[resourceId('Microsoft.Network/publicIPAddresses', variables('ipPublicName'))]"

      ],
      "tags": {
        "displayName": "vmControllerNic"
      },
      "properties": {
        "ipConfigurations": [
          {
            "name": "ipconfig1",
            "properties": {
              "privateIPAllocationMethod": "Static",
              "privateIPAddress": "10.0.0.16",
              "subnet": {
                "id": "[variables('vmSubnetRef')]"
              },

              "networkSecurityGroup": {
                "id": "[resourceId('Microsoft.Network/networkSecurityGroups',parameters('networkSecurityGroupName'))]"
              },
              "publicIPAddress": {
                "id": "[resourceId('Microsoft.Network/publicIPAddresses', variables('ipPublicName'))]"
              }
            }
          }
        ]
      }
    },

    {
      "name": "[parameters('vmName')]",
      "type": "Microsoft.Compute/virtualMachines",
      "location": "southcentralus",
      "apiVersion": "2015-06-15",
      "dependsOn": [
        "[resourceId('Microsoft.Network/networkInterfaces', variables('vmNicName'))]"
      ],
      "tags": {
        "displayName": "vmController"
      },
      "properties": {
        "hardwareProfile": {
          "vmSize": "[parameters('vmSize')]"
        },
        "osProfile": {
          "computerName": "[parameters('vmName')]",
          "adminUsername": "[parameters('vmAdminUsername')]",
          "adminPassword": "[parameters('vmAdminKey')]",
          "linuxConfiguration": {
            "disablePasswordAuthentication": true,
            "ssh": {
              "publicKeys": [
                {
                  "path": "[concat('/home/', parameters('vmAdminUserName'), '/.ssh/authorized_keys')]",
                  "keyData": "[parameters('vmAdminKey')]"
                }
              ]
            }
          }
        },
        "storageProfile": {
          "imageReference": {
            "publisher": "[variables('vmImagePublisher')]",
            "offer": "[variables('vmImageOffer')]",
            "sku": "[parameters('vmUbuntuOSVersion')]",
            "version": "latest"
          },
          "osDisk": {
            "name": "vmOSDisk",
            "vhd": {
              "uri": "[concat(reference(resourceId(parameters('storageAccountResourceGroup'), 'Microsoft.Storage/storageAccounts', parameters('storageAccountName')), '2016-01-01').primaryEndpoints.blob, variables('vmStorageAccountContainerName'), '/', variables('vmOSDiskName'), '.vhd')]"
            },
            "caching": "ReadWrite",
            "createOption": "FromImage"
          }
        },
        "networkProfile": {
          "networkInterfaces": [
            {
              "id": "[resourceId('Microsoft.Network/networkInterfaces', variables('vmNicName'))]"
            }
          ]
        }
      }
    },

    {
      "type": "Microsoft.Compute/virtualMachines/extensions",
      "name": "[concat(parameters('vmName'),'/installcustomscript')]",
      "apiVersion": "2015-05-01-preview",
      "location": "[resourceGroup().location]",
      "dependsOn": [
        "[concat('Microsoft.Compute/virtualMachines/', parameters('vmName'))]"
      ],
      "properties": {
        "publisher": "Microsoft.Azure.Extensions",
        "type": "CustomScript",
        "typeHandlerVersion": "2.0",
        "autoUpgradeMinorVersion": true,
        "settings": {
          "fileUris": [
            "[concat(parameters('_artifactsLocation'), '/Scripts/nfsServer.sh')]"
          ],
          "commandToExecute": "bash nfsServer.sh"
        }
      }
    },

    {
      "name": "[variables('ipPublicName')]",
      "type": "Microsoft.Network/publicIPAddresses",
      "location": "[resourceGroup().location]",
      "apiVersion": "2016-03-30",
      "dependsOn": [],
      "tags": {
        "displayName": "ipPublic"
      },
      "properties": {
        "publicIPAllocationMethod": "Dynamic",
        "dnsSettings": {
          "domainNameLabel": "[parameters('ipPublicDnsName')]"
        }
      }

    },

EOF


for v in $(seq 1 $NODE);
  do
  if [ $v != $NODE ]
  then
   v=$((v+0))
   Compute=compute0$v

cat << EOF >> ~/mod_cluster.json

    {
      "name": "$Compute",
      "type": "Microsoft.Compute/virtualMachines",
      "location": "southcentralus",
      "apiVersion": "2015-06-15",
      "dependsOn": [
        "[concat('Microsoft.Compute/virtualMachines/','vmController')]",
        "[resourceId('Microsoft.Network/networkInterfaces', 'Nic$Compute')]"
      ],
      "tags": {
        "displayName": "$Compute"
      },
      "properties": {
        "hardwareProfile": {
          "vmSize": "[parameters('vmSize')]"
        },
        "osProfile": {
          "computerName": "$Compute",
          "adminUsername": "ubuntu",
          "adminPassword": "[parameters('vmAdminKey')]",
          "linuxConfiguration": {
            "disablePasswordAuthentication": true,
            "ssh": {
              "publicKeys": [
                {
                  "path": "[concat('/home/', 'ubuntu', '/.ssh/authorized_keys')]",
                  "keyData": "[parameters('vmAdminKey')]"
                }
              ]
            }
          }
        },
        "storageProfile": {
          "imageReference": {
            "publisher": "[variables('vmImagePublisher')]",
            "offer": "[variables('vmImageOffer')]",
            "sku": "[parameters('vmUbuntuOSVersion')]",
            "version": "latest"
          },
          "osDisk": {
            "name": "vmOSDisk",
            "vhd": {
              "uri": "[concat(reference(resourceId(parameters('storageAccountResourceGroup'), 'Microsoft.Storage/storageAccounts', parameters('storageAccountName')), '2016-01-01').primaryEndpoints.blob, variables('vmStorageAccountContainerName'), '/','vmOSDiskuser$Compute', '.vhd')]"
            },
            "caching": "ReadWrite",
            "createOption": "FromImage"
          }
        },
        "networkProfile": {
          "networkInterfaces": [
            {
              "id": "[resourceId('Microsoft.Network/networkInterfaces', 'Nic$Compute')]"
            }
          ]
        }
      }
    },
    {
      "type": "Microsoft.Compute/virtualMachines/extensions",
      "name": "[concat('$Compute','/installcustomscript')]",
      "apiVersion": "2015-05-01-preview",
      "location": "[resourceGroup().location]",
      "dependsOn": [
        "[concat('Microsoft.Compute/virtualMachines/','$Compute')]"
      ],
      "properties": {
        "publisher": "Microsoft.Azure.Extensions",
        "type": "CustomScript",
        "typeHandlerVersion": "2.0",
        "autoUpgradeMinorVersion": true,
        "settings": {
          "fileUris": [
            "[concat(parameters('_artifactsLocation'), '/Scripts/nfsClient.sh')]"
          ],
          "commandToExecute": "bash nfsClient.sh"
        }
      }
    },

    {
      "name": "ip$Compute",
      "type": "Microsoft.Network/publicIPAddresses",
      "location": "[resourceGroup().location]",
      "apiVersion": "2016-03-30",
      "dependsOn": [],
      "tags": {
        "displayName": "ip$Compute"
      },
      "properties": {
        "publicIPAllocationMethod": "Dynamic",
        "dnsSettings": {
          "domainNameLabel": "ip$Compute"
        }
      }

    },

    {
      "name": "Nic$Compute",
      "type": "Microsoft.Network/networkInterfaces",
      "location": "[resourceGroup().location]",
      "apiVersion": "2016-03-30",
      "dependsOn": [
        "[resourceId('Microsoft.Network/networkSecurityGroups/', parameters('networkSecurityGroupName'))]",
        "[resourceId('Microsoft.Network/virtualNetworks', 'vNet')]",
        "[resourceId('Microsoft.Network/publicIPAddresses', 'ip$Compute')]"


      ],
      "tags": {
        "displayName": "Nic$Compute"
      },
      "properties": {
        "ipConfigurations": [
          {
            "name": "ipconfig1",
            "properties": {
              "privateIPAllocationMethod": "Dynamic",
              "subnet": {
                "id": "[variables('vmSubnetRef')]"
              },

              "networkSecurityGroup": {
                "id": "[resourceId('Microsoft.Network/networkSecurityGroups',parameters('networkSecurityGroupName'))]"
              },
              "publicIPAddress": {
                "id": "[resourceId('Microsoft.Network/publicIPAddresses', 'ip$Compute')]"
              }
            }
          }
        ]
      }
    },
  
EOF
  else
    Compute=compute0$NODE
    cat << EOF >> ~/mod_cluster.json
  {
      "name": "$Compute",
      "type": "Microsoft.Compute/virtualMachines",
      "location": "southcentralus",
      "apiVersion": "2015-06-15",
      "dependsOn": [
        "[concat('Microsoft.Compute/virtualMachines/','vmController')]",
        "[resourceId('Microsoft.Network/networkInterfaces', 'Nic$Compute')]"
      ],
      "tags": {
        "displayName": "$Compute"
      },
      "properties": {
        "hardwareProfile": {
          "vmSize": "[parameters('vmSize')]"
        },
        "osProfile": {
          "computerName": "$Compute",
          "adminUsername": "ubuntu",
          "adminPassword": "[parameters('vmAdminKey')]",
          "linuxConfiguration": {
            "disablePasswordAuthentication": true,
            "ssh": {
              "publicKeys": [
                {
                  "path": "[concat('/home/', 'ubuntu', '/.ssh/authorized_keys')]",
                  "keyData": "[parameters('vmAdminKey')]"
                }
              ]
            }
          }
        },
        "storageProfile": {
          "imageReference": {
            "publisher": "[variables('vmImagePublisher')]",
            "offer": "[variables('vmImageOffer')]",
            "sku": "[parameters('vmUbuntuOSVersion')]",
            "version": "latest"
          },
          "osDisk": {
            "name": "vmOSDisk",
            "vhd": {
              "uri": "[concat(reference(resourceId(parameters('storageAccountResourceGroup'), 'Microsoft.Storage/storageAccounts', parameters('storageAccountName')), '2016-01-01').primaryEndpoints.blob, variables('vmStorageAccountContainerName'), '/','vmOSDiskuser$Compute', '.vhd')]"
            },
            "caching": "ReadWrite",
            "createOption": "FromImage"
          }
        },
        "networkProfile": {
          "networkInterfaces": [
            {
              "id": "[resourceId('Microsoft.Network/networkInterfaces', 'Nic$Compute')]"
            }
          ]
        }
      }
    },
    {
      "type": "Microsoft.Compute/virtualMachines/extensions",
      "name": "[concat('$Compute','/installcustomscript')]",
      "apiVersion": "2015-05-01-preview",
      "location": "[resourceGroup().location]",
      "dependsOn": [
        "[concat('Microsoft.Compute/virtualMachines/','$Compute')]"
      ],
      "properties": {
        "publisher": "Microsoft.Azure.Extensions",
        "type": "CustomScript",
        "typeHandlerVersion": "2.0",
        "autoUpgradeMinorVersion": true,
        "settings": {
          "fileUris": [
            "[concat(parameters('_artifactsLocation'), '/Scripts/nfsClient.sh')]"
          ],
          "commandToExecute": "bash nfsClient.sh"
        }
      }
    },

    {
      "name": "ip$Compute",
      "type": "Microsoft.Network/publicIPAddresses",
      "location": "[resourceGroup().location]",
      "apiVersion": "2016-03-30",
      "dependsOn": [],
      "tags": {
        "displayName": "ip$Compute"
      },
      "properties": {
        "publicIPAllocationMethod": "Dynamic",
        "dnsSettings": {
          "domainNameLabel": "ip$Compute"
        }
      }

    },

    {
      "name": "Nic$Compute",
      "type": "Microsoft.Network/networkInterfaces",
      "location": "[resourceGroup().location]",
      "apiVersion": "2016-03-30",
      "dependsOn": [
        "[resourceId('Microsoft.Network/networkSecurityGroups/', parameters('networkSecurityGroupName'))]",
        "[resourceId('Microsoft.Network/virtualNetworks', 'vNet')]",
        "[resourceId('Microsoft.Network/publicIPAddresses', 'ip$Compute')]"


      ],
      "tags": {
        "displayName": "Nic$Compute"
      },
      "properties": {
        "ipConfigurations": [
          {
            "name": "ipconfig1",
            "properties": {
              "privateIPAllocationMethod": "Dynamic",
              "subnet": {
                "id": "[variables('vmSubnetRef')]"
              },

              "networkSecurityGroup": {
                "id": "[resourceId('Microsoft.Network/networkSecurityGroups',parameters('networkSecurityGroupName'))]"
              },
              "publicIPAddress": {
                "id": "[resourceId('Microsoft.Network/publicIPAddresses', 'ip$Compute')]"
              }
            }
          }
        ]
      }
    }
EOF
  fi
  done

cat << EOF >> ~/mod_cluster.json
  
  ],
  "outputs": {

    "vmIP": {
      "type": "string",
      "value": "[reference(variables('ipPublicName')).dnsSettings.fqdn]"
    }
    
  }

}
EOF

az deployment group create --resource-group $ResourceGroup --template-file ~/mod_cluster.json

STATUS=$(az deployment group show -g $ResourceGroup -n mod_cluster --query "properties.provisioningState" --output tsv)
var=1
while [ $var -eq 1 ]
do   
STATUS=$(az deployment group show -g $ResourceGroup -n mod_cluster --query "properties.provisioningState" --output tsv)
#echo "Cluster em criação..."
sleep 10
if [ $STATUS = "Succeeded" ];
then
    var=0
    echo "Cluster criado!!"
elif [ $STATUS = "Failed" ];
then
    var=0
    echo "Erro ao criado cluster!!"
else
echo "Status atual do cluster em: $STATUS" 
fi
done

#pegando ip da vmController onde parametro esta definido como ipPublic
#os paramentros de consulta dos computes está definido como ipcompute01 de acordo com cada nó
PUBLICIP=$(az network public-ip show -g $ResourceGroup --name ipPublic --query "ipAddress" -o tsv)

#Essa sequencia de comandos é para que a VM Controller possa acessar as VMs Compute
echo "Acesse em outro terminal e execute a seguencia de comandos:"
echo "eval $``(ssh-agent -s)"
echo "ssh-add ~/.ssh/$KeyName"
echo "ssh -A ubuntu@$PUBLICIP"
echo "Passphrase da chave criada é:(azure)"
echo ""
echo ""
echo "Aperte [enter] duas vezes para finalizar o Grupo de Recursos."
read -p "Primeira vez."
read -p "Segunda vez."
echo "Deletando chave publica(Key_Azure e Key_Azure.pub )."
rm -rf ~/.ssh/Key_Azure*
rm -rf ~/mod_cluster.json
echo "Digite (y) para deletar o Grupo de Recurso: $ResourceGroup"
az group delete -n $ResourceGroup 
