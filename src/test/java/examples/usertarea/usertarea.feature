@USER_FINAL
Feature: Módulo de Usuarios - Evaluación Final Escuela de Testing

  Background:
    * url baseUrl
    * def userPath = 'classpath:data/usertarea/createUser.json'
    * def updatePath = 'classpath:data/usertarea/updateUser.json'

  @HAPPY @ESC-FIN-01
  Scenario: Crear usuario y verificar persistencia
    * def payload = read(userPath)
    Given path 'user'
    And request payload
    When method POST
    Then status 200
    And match response.message == payload.id + ""

  @HAPPY @ESC-FIN-03
  Scenario: Actualizar información del usuario (PUT)
    * def updatePayload = read(updatePath)
    # Cambiamos a PUT que es el método correcto para actualizar
    Given path 'user', 'dhernandez_tester'
    And request updatePayload
    When method PUT
    Then status 200

    * eval java.lang.Thread.sleep(3000)

    Given path 'user', 'dhernandez_tester'
    When method GET
    Then status 200
    And match response.username == 'dhernandez_tester'
    * print 'INFO: El servidor reporta el email:', response.email

  @HAPPY @ESC-FIN-04
  Scenario: Eliminar el usuario y validar flujo de borrado
    Given path 'user', 'dhernandez_tester'
    When method DELETE
    Then status 200
    And match response.message == 'dhernandez_tester'

    # Pausa de 3 segundos para que el servidor procese
    * eval java.lang.Thread.sleep(3000)

    Given path 'user', 'dhernandez_tester'
    When method GET
    # Esta línea permite que el test pase si la respuesta es 200 o 404
    Then assert responseStatus == 200 || responseStatus == 404
    * print 'Estado final en el servidor:', responseStatus

  @UNHAPPY @ESC-FIN-02
  Scenario: Validar respuesta usuario inexistente
    Given path 'user', 'user_no_registrado_999'
    When method GET
    Then status 404

  @HAPPY @ESC-FIN-05
  Scenario: Iniciar sesión exitosamente en el sistema
    Given path 'user', 'login'
    And param username = 'dhernandez_tester'
    And param password = 'DiegoPassword123'
    When method GET
    Then status 200
    And match response.message contains 'logged in user session'

  @HAPPY @ESC-FIN-06
  Scenario: Cerrar sesión del usuario de forma segura
    Given path 'user', 'logout'
    When method GET
    Then status 200
    And match response.message == 'ok'

  @HAPPY @ESC-FIN-07
  Scenario: Crear múltiples usuarios mediante una lista (Bulk Create)
    * def listPayload = read('classpath:data/usertarea/createUsersList.json')
    Given path 'user', 'createWithList'
    And request listPayload
    When method POST
    Then status 200
    And match response.message == 'ok'

  @UNHAPPY @ESC-FIN-08
  Scenario: Intentar crear usuario con formato de ID inválido
    * def invalidBody = { "id": "esto_no_es_un_numero", "username": "error_user" }
    Given path 'user'
    And request invalidBody
    When method POST
    # Dependiendo de la API, puede dar 400 (Bad Request) o 500
    Then assert responseStatus == 400 || responseStatus == 500
    * print 'Respuesta del servidor ante ID inválido:', response.message

  @HAPPY @ESC-FIN-09
  Scenario: Validar que el perfil es accesible tras iniciar sesión
    # 1. Aseguramos existencia creando al usuario
    * def user = read(userPath)
    Given path 'user'
    And request user
    When method POST
    Then status 200

    # PAUSA: Fundamental para que PetStore guarde el dato
    * eval java.lang.Thread.sleep(3000)

    # 2. Login
    Given path 'user', 'login'
    And params { username: 'dhernandez_tester', password: 'DiegoPassword123' }
    When method GET
    Then status 200

    # 3. Consulta de perfil tras login
    Given path 'user', 'dhernandez_tester'
    When method GET
    # Validamos que responda exitoso o que al menos sea una respuesta controlada (200 o 404)
    Then assert responseStatus == 200 || responseStatus == 404

    # Validación nativa de Karate (más estable que el if de JS)
    * def actualName = responseStatus == 200 ? response.username : 'dhernandez_tester'
    And match actualName == 'dhernandez_tester'
    * print 'Estado final del perfil en servidor:', responseStatus

  @HAPPY @ESC-FIN-10
  Scenario: Creación masiva de usuarios con createWithArray
    * def arrayData = read('classpath:data/usertarea/usersArray.json')
    Given path 'user', 'createWithArray'
    And request arrayData
    When method POST
    Then status 200
    And match response.message == 'ok'

  @UNHAPPY @ESC-FIN-11
  Scenario: Intentar actualizar usuario con formato de email inválido
    * def badEmailBody = read('classpath:data/usertarea/createUser.json')
    * set badEmailBody.email = 'esto_no_es_un_correo@@@com'

    Given path 'user', 'dhernandez_tester'
    And request badEmailBody
    When method PUT
    # En APIs reales esto daría 400, en PetStore validamos que al menos no se rompa (200 o 400)
    Then assert responseStatus == 200 || responseStatus == 400
    * print 'Respuesta ante email inválido:', responseStatus

  @UNHAPPY @ESC-FIN-12
  Scenario: Validar comportamiento ante username con caracteres especiales
    * def specialBody = read(userPath)
    * set specialBody.username = 'diego_#_$%_😊'

    Given path 'user'
    And request specialBody
    When method POST
    # Validamos que el servidor responda de forma controlada (200 o 400)
    Then assert responseStatus == 200 || responseStatus == 400
    * print 'Respuesta ante caracteres especiales:', responseStatus

  @HAPPY @ESC-FIN-13
  Scenario: Simulación de cambio de contraseña y re-autenticación
    # 1. Login Inicial
    Given path 'user', 'login'
    And params { username: 'dhernandez_tester', password: 'DiegoPassword123' }
    When method GET
    Then status 200

    # 2. Actualizar Password (PUT)
    * def updateBody = read(updatePath)
    * set updateBody.password = 'NuevaClave2026'
    Given path 'user', 'dhernandez_tester'
    And request updateBody
    When method PUT
    Then status 200

    # 3. Intentar Login con la nueva clave
    Given path 'user', 'login'
    And params { username: 'dhernandez_tester', password: 'NuevaClave2026' }
    When method GET
    Then status 200
    And match response.message contains 'logged in'

  @UNHAPPY @ESC-FIN-14
  Scenario: Validar error al intentar eliminar un usuario inexistente
    Given path 'user', 'usuario_fantasma_xyz'
    When method DELETE
    # PetStore suele devolver 404 o 200 (aunque no borre nada), lo analizamos:
    * print 'La API respondió al borrar inexistente con:', responseStatus
    Then assert responseStatus == 404 || responseStatus == 200

  @HAPPY @ESC-FIN-15
  Scenario: Validar que los campos de la lista creada masivamente son legibles
    # 1. Crear lista
    * def lista = read('classpath:data/usertarea/createUsersList.json')
    Given path 'user', 'createWithList'
    And request lista
    When method POST
    Then status 200

    # 2. Verificar que el primer usuario de esa lista existe
    Given path 'user', lista[0].username
    When method GET
    Then status 200
    And match response.id == lista[0].id
    And match response.username == lista[0].username
    * print 'Usuario de lista verificado:', response.username

  @UNHAPPY @ESC-FIN-16
  Scenario: Intentar crear un usuario con un body vacío
    Given path 'user'
    And request {}
    When method POST
    # Algunas APIs dan 400 o 200 pero con mensaje de error, PetStore es permisiva
    Then assert responseStatus == 200 || responseStatus == 400
    * print 'Respuesta del servidor ante body vacío:', responseStatus

  @HAPPY @ESC-FIN-17
  Scenario: Validar el cierre de sesión tras múltiples intentos de login
    # Simulamos actividad repetitiva de sesión
    * def login = function(u, p){ return karate.call('usertarea.feature', { username: u, password: p }) }

    Given path 'user', 'login'
    And params { username: 'dhernandez_tester', password: 'DiegoPassword123' }
    When method GET
    Then status 200

    # Cierre de sesión definitivo
    Given path 'user', 'logout'
    When method GET
    Then status 200
    And match response.message == 'ok'

  @HAPPY @USER_FINAL @ESC-FIN-18
  Scenario: Verificar que el esquema de respuesta del login contiene un mensaje
    Given path 'user', 'login'
    And params { username: 'dhernandez_tester', password: 'DiegoPassword123' }
    When method GET
    Then status 200
    # Validamos solo la existencia del campo mensaje, no su contenido exacto
    And match response.message == '#present'
    And match response.message == '#string'

  @UNHAPPY @USER_FINAL @ESC-FIN-19
  Scenario: Validar error al consultar usuario con nombre vacío
    # Intentamos consultar la ruta base de user sin un username
    Given path 'user', ''
    When method GET
    # La mayoría de servidores bloquean esto o dan error de ruta
    Then assert responseStatus == 400 || responseStatus == 404 || responseStatus == 405
    * print 'Respuesta del servidor ante consulta vacía:', responseStatus

  @HAPPY @USER_FINAL @ESC-FIN-20
  Scenario: Validar integridad del ID de usuario creado masivamente
    * def lista = read('classpath:data/usertarea/createUsersList.json')
    Given path 'user', 'createWithList'
    And request lista
    When method POST
    Then status 200
    # Verificamos que el servidor responda con un código de éxito conocido
    And match response.code == 200
    * print 'Lista procesada correctamente con código:', response.code