# Proyecto SW Clonados con EC2

## Clonar sitios web

Crea tu script para clonación de sitios web, editalo y adaptalo a tus necesidades

```bash
cp clone.example.sh clone.sh
# Añade una nueva linea por cada sitio web que desees clonar
# Ejemplo:
# (sitio web a clonar/directorio de destino)
echo "clone_site 'http://sitioweb.cl' './sitioweb'" >> clone.sh
```

Ejecuta el comando para clonar el contenido estático de los sitios web que desee:

```bash
chmod +x clone.sh
./clone.sh
```


## Desplegar infraestructura en AWS

Inicializa el estado de tu proyecto terraform (asegúrate de haber generado credenciales válidas y almacenarlas en tu archivo de configuración de AWS).

```bash
terraform init
```

Despliega tu infraestructura en AWS.

```bash
terraform apply
```

Finalmente, destruye tu infraestructura en AWS.

```bash
terraform destroy
```

## Requisitos

- [Terraform](https://www.terraform.io/downloads.html)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- [AWS CLI Configuración](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)
- [AWS CLI Credenciales](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
- [AWS CLI Permisos](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
- [WGET](https://www.gnu.org/software/wget/)





