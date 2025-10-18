#!/bin/bash

STACK_NAME="PixTransactionWorkflow-SFN"
REGION="sa-east-1"
TEMPLATE_FILE="template/pix-transaction-workflow.yaml"
PARAMETER_FILE="parameters/sa-east-1.json"

echo "Iniciando o deploy da Stack CloudFormation: $STACK_NAME na região $REGION"

aws cloudformation deploy \
    --template-file $TEMPLATE_FILE \
    --stack-name $STACK_NAME \
    --parameter-overrides $(cat $PARAMETER_FILE | jq -r '.[].ParameterKey + "=" + .[].ParameterValue' | tr '\n' ' ') \
    --capabilities CAPABILITY_IAM \
    --region $REGION

if [ $? -eq 0 ]; then
    echo "Deploy concluído com sucesso! 🎉"
else
    echo "Falha no deploy. Verifique os logs do CloudFormation."
fi
