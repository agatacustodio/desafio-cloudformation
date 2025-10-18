# Pix Transaction Workflow - AWS Step Functions (CloudFormation)

Este repositório contém um template AWS CloudFormation que define uma **Máquina de Estados (Step Functions)** para orquestrar um fluxo de transação financeira, como um pagamento Pix, garantindo a atomicidade e a resiliência das etapas.



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
