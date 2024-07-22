import { SSMClient, GetParameterCommand } from "@aws-sdk/client-ssm";
import mysql from "mysql2/promise";
import { fetch } from "node-fetch";

// Configura AWS SDK
const client = new SSMClient({ region: process.env.AWS_REGION });

// Nombres de los parámetros en SSM Parameter Store
const DB_ENDPOINT_PARAM = process.env.DB_ENDPOINT_PARAM;
const DB_NAME_PARAM = process.env.DB_NAME_PARAM;
const DB_USERNAME_PARAM = process.env.DB_USERNAME_PARAM;
const DB_PASSWORD_PARAM = process.env.DB_PASSWORD_PARAM;
const SQL_SCRIPT_URL = process.env.SQL_SCRIPT_URL;

console.log("Reading from ENV: ", {
  DB_ENDPOINT_PARAM: process.env.DB_ENDPOINT_PARAM,
  DB_NAME_PARAM: process.env.DB_NAME_PARAM,
  DB_USERNAME_PARAM: process.env.DB_USERNAME_PARAM,
  DB_PASSWORD_PARAM: process.env.DB_PASSWORD_PARAM,
  SQL_SCRIPT_URL: process.env.SQL_SCRIPT_URL,
});

export const handler = async (event) => {
  try {
    // Descarga el script SQL desde GitHub
    const sqlScript = await downloadSQLScript(SQL_SCRIPT_URL);
    console.log("Downloaded SQL script: ", sqlScript);

    // Obtén los parámetros de SSM Parameter Store
    const dbEndpointParam = await getParameterValue(DB_ENDPOINT_PARAM);
    const dbNameParam = await getParameterValue(DB_NAME_PARAM);
    const dbUsernameParam = await getParameterValue(DB_USERNAME_PARAM);
    const dbPasswordParam = await getParameterValue(DB_PASSWORD_PARAM, true);

    console.log("Received from ssm: ", {
      dbEndpointParam,
      dbNameParam,
      dbUsernameParam,
      dbPasswordParam,
    });

    if (
      !dbEndpointParam ||
      !dbNameParam ||
      !dbUsernameParam ||
      !dbPasswordParam
    ) {
      throw new Error("Unable to retrieve database credentials");
    }

    // Crea una conexión con la base de datos
    const connection = await mysql.createConnection({
      host: dbEndpointParam,
      user: dbUsernameParam,
      password: dbPasswordParam,
      database: dbNameParam,
    });

    // Ejecuta el script de inicialización
    await connection.query(sqlScript);

    // Cierra la conexión
    await connection.end();

    return {
      statusCode: 200,
      body: JSON.stringify({
        message: "Database bootstrapped successfully",
      }),
    };
  } catch (error) {
    console.error("Error bootstrapping database:", error);

    return {
      statusCode: 500,
      body: JSON.stringify({
        message: "Error bootstrapping database",
        error: error.message,
      }),
    };
  }
};

// Función para obtener valores de SSM Parameter Store
const getParameterValue = async (name, withDecryption = false) => {
  const command = new GetParameterCommand({
    Name: name,
    WithDecryption: withDecryption,
  });
  const response = await client.send(command);
  return response.Parameter?.Value;
};

// Función para descargar el script SQL desde GitHub
const downloadSQLScript = async (url) => {
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`Failed to get script: ${response.status}`);
  }
  return await response.text();
};
