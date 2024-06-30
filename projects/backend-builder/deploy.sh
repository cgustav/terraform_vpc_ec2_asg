#!/bin/bash

set -e

# Función para mostrar el uso del script
usage() {
    echo "Uso: $0 [--backend-file-out=/path/to/somewhere]"
    exit 1
}

# Inicializar la variable para el archivo de salida del backend
BACKEND_FILE_OUT=""

# Procesar los argumentos de línea de comandos
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --backend-file-out=*) BACKEND_FILE_OUT="${1#*=}" ;;
        *) usage ;;
    esac
    shift
done

# Ejecutar Terraform
terraform plan -var-file=build.tfvars -out=planned.tfplan
terraform apply "planned.tfplan"
terraform output -json > ./infrastructure.json

# Si se especificó un archivo de salida para el backend, generarlo
if [ ! -z "$BACKEND_FILE_OUT" ]; then
    echo "Generando archivo de configuración del backend..."
    
    # Extraer valores del JSON
    BUCKET_NAME=$(jq -r '.bucket_name.value' ./infrastructure.json)
    BUCKET_KEY=$(jq -r '.bucket_tfstate_object_key.value' ./infrastructure.json)
    REGION=$(jq -r '.region.value' ./infrastructure.json)
    DYNAMODB_TABLE=$(jq -r '.dynamodb_table_name.value' ./infrastructure.json)
    ENCRYPT=$(jq -r '.bucket_entryption_enabled.value' ./infrastructure.json)
    
    # Generar el archivo backend.hcl
    cat > "$BACKEND_FILE_OUT" << EOF
bucket         = "$BUCKET_NAME"
key            = "$BUCKET_KEY"
region         = "$REGION"
dynamodb_table = "$DYNAMODB_TABLE"
encrypt        = $ENCRYPT
EOF
    
    echo "Archivo de configuración del backend generado en: $BACKEND_FILE_OUT"
fi