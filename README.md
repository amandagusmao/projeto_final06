# Aula 06 - Projeto Final
Objetivo: Criar um pipeline de CI/CD que provisiona uma infraestrutura na Azure usando Terraform, configura os servidores usando Ansible, e utiliza GitHub Actions para orquestrar todo o processo.

- Recursos a serem criados na Azure:

1. Resource Group
2. Virtual Network (VNet)
3. Subnets
4. Network Security Group (NSG)
5. Public IP
6. Network Interface
7. Virtual Machine (VM).

## 1. Configurar o Repositório no GitHub
Crie um repositório no GitHub para o projeto.
Adicione os arquivos de configuração do Terraform e Ansible no repositório.

## 2. Configurar o Terraform
- **Arquivo provider.tf:**
1. Crie um arquivo provider.tf que configure o provedor Azure com os recursos necessários.
2. Inclua a configuração do backend local para armazenar o estado do Terraform.

- **Arquivo variables.tf:**
1. Crie um arquivo variables.tf para definir variáveis como nome do resource group, localização e credenciais da VM.
2. Inclua variáveis para o nome do resource group (student-rg), localização (eastus), nome de usuário da VM (azureuser), e senha da VM.

- **Arquivo main.tf:**
  
Crie um arquivo main.tf que contenha os seguintes recursos:
   1. Resource Group: Nome: student-rg
   2. Virtual Network: Nome: student-vnet, endereço IP: 10.0.0.0/16
   3. Subnet: Nome: student-subnet, endereço IP: 10.0.1.0/24
   4. Network Security Group: Nome: student-nsg
   5. Public IP: Nome: student-pip
   6. Network Interface: Nome: student-nic, associada à subnet e ao public IP
   7. Virtual Machine: Nome: student-vm, tipo de instância: Standard_B1s, SO: Ubuntu 22.04 LTS Gen2, associada à network interface, nome de usuário azureuser, senha fornecida pela variável

- **Arquivo outputs.tf:**
1. Crie um arquivo outputs.tf para definir as saídas dos recursos provisionados, como o endereço IP público da VM.

## 3. Configurar o Ansible
- **Arquivo playbook.yml:**
1. Crie um arquivo playbook.yml que inclua as seguintes tarefas:
2. Atualizar e atualizar pacotes apt.
3. Instalar o servidor web Nginx.

- **Arquivo inventory.ini:**
1. Crie um arquivo inventory.ini para listar o IP público da VM.

## 4. Configurar GitHub Actions
- Configurar Segredos no GitHub:
No repositório GitHub, vá para Settings > Secrets e adicione os seguintes segredos:
1. ARM_CLIENT_ID
2. ARM_CLIENT_SECRET
3. ARM_SUBSCRIPTION_ID
4. ARM_TENANT_ID
5. TF_VAR_vm_admin_password (senha do administrador da VM - esta variável de ambiente pode ser usada na configuração chamando var.vm_admin_password)
Referência: https://developer.hashicorp.com/terraform/cli/config/environment-variables#tf_var_nameLinks to an external site.

- **Arquivo .github/workflows/terraform.yml:**

Crie um arquivo de workflow do GitHub Actions que:
1. Faça checkout do repositório.
2. Instale e configure o Terraform.
3. Execute os comandos de formatação e linting do Terraform (terraform fmt, TFLint).
4. Execute as verificações de segurança com Checkov (a opção soft_fail pode ser usada).
5. Inicialize e aplique os planos do Terraform.
6. Instale o Ansible.
7. Execute o playbook do Ansible para configurar a VM.
