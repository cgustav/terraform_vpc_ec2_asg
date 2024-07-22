#!/bin/sh

layers_dir=./data/layers
rds_layer_dir=$layers_dir/rds-related

# Pack RDS-Related
mkdir -p $rds_layer_dir/nodejs
cp $rds_layer_dir/package.json $rds_layer_dir/nodejs

# Guardar el directorio actual y movernos al nuevo directorio
pushd $rds_layer_dir/nodejs > /dev/null

# Ejecutar el comando
npm install

cd ..

zip -r ./rds-related.zip ./nodejs

# Regresar al directorio original
popd > /dev/null

mv $rds_layer_dir/rds-related.zip $layers_dir/rds-related.zip
rm -rf $rds_layer_dir/nodejs