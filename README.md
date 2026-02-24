# Proyecto Final: Escuela de Testing - Automatizacion API PetStore

**Estudiante:** Diego Hernandez Terrones  
**N° de Orden:** 18  
**Proyecto:** 18-HernandezTerronesDiegoTestingFinal

---

## Descripcion General
Este proyecto consiste en la automatizacion de pruebas para los modulos User y Store de la API Swagger PetStore. Se ha utilizado Karate DSL para construir una suite robusta de 40 escenarios de prueba, aplicando un analisis profundo de flujos tanto exitosos como de error.

## Estructura del Proyecto
La organizacion de los archivos sigue el estandar de Karate DSL para asegurar el desacoplamiento de la logica y los datos:

src/test/java/
└── examples/
├── store/
│   └── store.feature (Automatizacion de inventarios y ordenes)
└── usertarea/
└── usertarea.feature (Automatizacion de gestion de usuarios)

src/test/resources/data/
├── store/
├── createOrder.json
├── findOrder.json
├── completeOrder.json
└── priorityOrder.json
└── usertarea/
├── createUser.json
├── updateUser.json
├── createUsersList.json
└── usersArray.json

## Cobertura de Pruebas
Se han implementado 40 casos distribuidos de la siguiente manera:

### Modulo User (20 Escenarios)
* CRUD Completo: Creacion, consulta, actualizacion y eliminacion de usuarios.
* Seguridad: Validacion de inicio y cierre de sesion (Login/Logout) y cambio de credenciales.
* Operaciones Masivas: Creacion de usuarios mediante listas (List) y arreglos (Array).
* Analisis de Robustez: Pruebas con IDs invalidos, formatos de email corruptos y caracteres especiales.

### Modulo Store (20 Escenarios)
* Inventario: Validacion de estados oficiales y deteccion de estados no permitidos.
* Ordenes: Creacion con IDs dinamicos, validacion de fechas ISO8601 y cantidades extremas.
* Analisis de Error: Intentos de eliminacion de ordenes inexistentes y manejo de IDs negativos.

## Tecnologias y Configuracion
* Framework: Karate DSL 1.5.0.
* Lenguaje: Java 17 / Maven.
* Configuracion: Uso de karate-config.js para manejo dinamico de ambientes y URLs.
* Datos: Desacoplamiento de datos mediante archivos JSON externos.

## Como ejecutar las pruebas
Para ejecutar la suite completa y generar el reporte de Karate, ejecute el siguiente comando en la terminal raiz del proyecto:

mvn clean test

### Ejecucion por Tags especificos:
* Solo Usuario: mvn test "-Dkarate.options=--tags @USER_FINAL"
* Solo Tienda: mvn test "-Dkarate.options=--tags @STORE"
* Casos Exitosos: mvn test "-Dkarate.options=--tags @HAPPY"
* Casos de Error: mvn test "-Dkarate.options=--tags @UNHAPPY"

---
Entregado el 24/02/2026 para la Evaluacion Final de la Escuela de Testing.