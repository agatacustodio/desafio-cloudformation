# Cash Out via Pix - Workflow Automatizado com AWS CloudFormation

Este repositório contém um template AWS CloudFormation que define uma **Máquina de Estados (Step Functions)** para orquestrar o fluxo de transação financeira de um Cash Out via Pix.

## O que é o AWS CloudFormation?

É um serviço da Amazon Web Services (AWS) que permite modelar e provisionar infraestrutura na nuvem de forma automatizada e previsível, utilizando um arquivo de modelo.

---

## Arquitetura do Workflow

A State Machine orquestra as seguintes etapas, utilizando funções AWS Lambda como tarefas (Tasks):

1.  **ValidarSolicitacao**: Verifica a integridade e validade da solicitação de Pix.
2.  **ChecarSaldo**: Consulta o saldo disponível na conta de origem.
3.  **TemSaldo?** (Choice):
    * **Sim**: Vai para `DeduzirSaldo`.
    * **Não / Falha**: Vai para `RegistrarFalha`.
4.  **DeduzirSaldo**: Reserva ou debita o valor da transação.
5.  **ExecutarPix**: Chama a API externa ou interna para processar a transação Pix.
6.  **ErroNaAPIPix?** (Choice):
    * **Sim**: Vai para `EstornarSaldo`.
    * **Não**: Vai para `NotificarCliente`.
7.  **EstornarSaldo**: Reverte o valor debitado ou reservado devido a uma falha na execução do Pix. Vai para `RegistrarFalha`.
8.  **NotificarCliente**: Envia uma notificação de sucesso da transação.
9.  **RegistrarFalha**: Registra o log da falha (se ocorrer um `Catch` ou falta de saldo/erro API).
10. **RegistrarTransacao**: Etapa final que registra o status final (sucesso ou falha) no banco de dados.

## Como Implantar

### Pré-requisitos

* Conta AWS configurada.
* AWS CLI instalado e configurado.
* `jq` instalado para processar o arquivo de parâmetros (opcional, se usar o `deploy.sh`).
* **As funções AWS Lambda referenciadas no template (e a Role IAM do Step Functions) devem ser criadas antes da implantação deste stack.**

### 1. Configurar Parâmetros

Edite o arquivo `parameters/sa-east-1.json` substituindo `<SEU_ID_DE_CONTA>` pelos seus ARNs reais das funções Lambda.

### 2. Executar o Deploy

Use o script de deploy para implantar a State Machine via AWS CloudFormation:

```bash
chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

## Insights
O uso do AWS CloudFormation oferece três grandes vantagens:

1.  **Infraestrutura como Código:** O template atua como a **fonte única da verdade**, permitindo o **controle de versão** da infraestrutura (como código) para maior transparência e rastreabilidade das alterações.
2.  **Natureza Declarativa:** Simplifica a implantação, pois o CFN se encarrega do "como" (ordem, dependências), permitindo que você se concentre apenas em **declarar "o quê"** deve ser criado.
3.  **Gerenciamento do Ciclo de Vida e Rollback:** Garante a **segurança** da implantação. Em caso de qualquer falha, o CFN realiza um **rollback automático** para o último estado funcional conhecido, mantendo a consistência do sistema.

Além disso, o uso de **Parâmetros** torna os templates **reutilizáveis** em diferentes ambientes (Dev/Prod) ou contas.
