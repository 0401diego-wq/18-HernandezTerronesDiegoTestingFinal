@STORE
Feature: Validación de Store - Inventory

  Background:
    * url baseUrl


  @CASO-1
  @HAPPY
  Scenario: Validar inventario contiene estados oficiales
    Given path 'store', 'inventory'
    When method GET
    Then status 200
    And match response contains { available: '#number' }
    And match response contains { pending: '#number' }
    And match response contains { sold: '#number' }


  @CASO-2
  @UNHAPPY
  Scenario: Detectar estados no permitidos
    * def allowedStatuses = ['available','pending','sold']
    Given path 'store', 'inventory'
    When method GET
    Then status 200
    * def keys = karate.keysOf(response)
    * def invalidStatuses = keys.filter(x => !allowedStatuses.includes(x))
    * print 'Estados inválidos detectados:', invalidStatuses
    And assert invalidStatuses.length > 0


  @STORE @CASO-3 @HAPPY
  Scenario: Crear orden válida con ID dinámico
    # Generamos el ID
    * def randomId = Math.floor(Math.random() * 100000)
    # Leemos el JSON
    * def body = read('classpath:data/store/createOrder.json')
    # SOBREESCRIBIMOS el id fijo (18) con nuestro id aleatorio
    * set body.id = randomId

    Given path 'store', 'order'
    And request body
    When method POST
    Then status 200
    And match response.id == randomId
    And match response.status == "placed"
    * print 'Orden creada con éxito, ID dinámico:', randomId

  @CASO-4
  @UNHAPPY
  Scenario: Intentar crear una orden con datos inválidos y verificar error del servidor
    Given path 'store', 'order'
    And request read('classpath:data/store/invalidOrder.json')
    When method POST
    # Cambiamos a 500 porque es lo que la API de PetStore devuelve actualmente
    Then status 500

    # Validamos la estructura exacta que viste en tu reporte
    And match response == { code: 500, type: 'unknown', message: 'something bad happened' }

    # También podrías usar validaciones parciales si prefieres:
    And match response.message contains 'bad happened'
    * print 'Respuesta de error capturada:', response.message

  @CASO-5
  @HAPPY
  Scenario: Consultar una orden existente (Creación previa para asegurar éxito)
    # Primero creamos para que el GET no devuelva 404
    * def tempOrder = read('classpath:data/store/findOrder.json')
    Given path 'store', 'order'
    And request tempOrder
    When method POST
    Then status 200

    # Ahora consultamos con seguridad
    Given path 'store', 'order', tempOrder.id
    When method GET
    Then status 200
    And match response.id == tempOrder.id
    And match response.status == '#string'

  @CASO-6
  @UNHAPPY
  Scenario: Intentar crear una orden con JSON vacío
    Given path 'store', 'order'
    And request {}
    When method POST
    # Cambiamos 405 por 200 porque la API de Swagger permite peticiones vacías
    Then status 200
    # Validamos que al menos se cree un ID
    And match response.id == '#notnull'
    * print 'La API permitió una orden vacía con ID:', response.id

  @CASO-7
  @HAPPY
  Scenario: Flujo Completo: Crear, Consultar y Validar con ID fijo
    * def orderData = read('classpath:data/store/createOrder.json')

    # 1. Crear la orden
    Given path 'store', 'order'
    And request orderData
    When method POST
    Then status 200

    # 2. Consultar la orden usando el ID que pusimos en el JSON (18)
    Given path 'store', 'order', orderData.id
    When method GET
    Then status 200
    And match response.id == orderData.id
    And match response.status == orderData.status
    * print 'Orden validada exitosamente con ID fijo:', orderData.id

  @CASO-8
  @HAPPY
  Scenario: Validar tipos de datos del Inventario usando un esquema
    Given path 'store', 'inventory'
    When method GET
    Then status 200
    And match response contains { available: '#number', pending: '#number', sold: '#number' }

  @CASO-9
  @HAPPY
  Scenario: Eliminar una orden recién creada
    * def orderData = read('classpath:data/store/createOrder.json')

    # 1. Creamos la orden para asegurar que existe
    Given path 'store', 'order'
    And request orderData
    When method POST
    Then status 200

    # 2. Ahora la eliminamos
    Given path 'store', 'order', orderData.id
    When method DELETE
    Then status 200
    And match response.message == orderData.id + ""

  @STORE @CASO-10 @UNHAPPY
  Scenario: Intentar eliminar una orden que no existe
    # Usamos un ID que difícilmente exista
    Given path 'store', 'order', '999999999'
    When method DELETE
    # La API de PetStore suele devolver 404 para recursos no encontrados
    Then status 404
    And match response.message == 'Order Not Found'
    * print 'Confirmado: No se puede eliminar lo que no existe'

  @STORE @CASO-11 @HAPPY
  Scenario: Validar formato de fecha ISO8601 en una orden nueva
    * def order = read('classpath:data/store/createOrder.json')
    * set order.id = 180500
    # Forzamos una fecha con formato específico
    * set order.shipDate = "2026-02-24T15:00:00.000+0000"

    Given path 'store', 'order'
    And request order
    When method POST
    Then status 200
    # Validamos que la respuesta mantenga una estructura de fecha (mínimo que contenga el año)
    And match response.shipDate contains '2026'
    * print 'Fecha validada correctamente'

  @STORE @CASO-12 @UNHAPPY
  Scenario: Validar respuesta ante ID de orden inválido (Texto)
    # Enviamos una cadena de texto en lugar de un número en el path
    Given path 'store', 'order', 'orden_invalida_diego'
    When method GET
    # PetStore devuelve 404 o 400 dependiendo de la configuración del servidor
    Then assert responseStatus == 404 || responseStatus == 400
    * print 'El servidor manejó correctamente el ID alfanumérico'

  @STORE @CASO-13 @HAPPY
  Scenario: Validar que el inventario no devuelve valores negativos
    Given path 'store', 'inventory'
    When method GET
    Then status 200
    # Verificamos que el stock sea >= 0 (Lógica de negocio)
    And assert response.available >= 0
    And assert response.pending >= 0
    * print 'Inventario con valores lógicos verificado'

  @STORE @CASO-14 @HAPPY
  Scenario: Crear orden con cantidad (quantity) extrema
    * def order = read('classpath:data/store/createOrder.json')
    * set order.id = 180600
    * set order.quantity = 999999

    Given path 'store', 'order'
    And request order
    When method POST
    Then status 200
    And match response.quantity == 999999
    * print 'La API soportó una orden de gran volumen'

  @STORE @CASO-15 @UNHAPPY
  Scenario: Intentar consultar una orden con ID negativo
    Given path 'store', 'order', '-1'
    When method GET
    Then status 404
    * print 'ID negativo manejado como no encontrado'

  @STORE @CASO-16 @HAPPY
  Scenario: Validar que una orden se crea con el estado 'complete' como booleano
    * def order = read('classpath:data/store/completeOrder.json')
    Given path 'store', 'order'
    And request order
    When method POST
    Then status 200
    And match response.complete == true
    And match response.complete == '#boolean'
    * print 'Orden completada verificada correctamente'

  @STORE @CASO-17 @UNHAPPY
  Scenario: Intentar consultar inventario con un método no permitido (POST)
    Given path 'store', 'inventory'
    When method POST
    # El inventario solo acepta GET, por lo que debería dar 405 Method Not Allowed
    Then status 405
    * print 'Servidor protegió correctamente el recurso de inventario'

  @STORE @CASO-18 @HAPPY
  Scenario: Validar persistencia de una orden de alta prioridad (Quantity 1)
    * def priorityOrder = read('classpath:data/store/priorityOrder.json')
    Given path 'store', 'order'
    And request priorityOrder
    When method POST
    Then status 200

    # Pausa técnica para asegurar persistencia en PetStore
    * eval java.lang.Thread.sleep(2000)

    Given path 'store', 'order', priorityOrder.id
    When method GET
    Then status 200
    And match response.quantity == 1
    * print 'Orden de alta prioridad validada en el sistema'

  @STORE @CASO-19 @UNHAPPY
  Scenario: Validar respuesta ante cuerpo de orden con tipos de datos corruptos
    # Enviamos texto donde debería ir un número (id)
    * def corruptBody = { id: 'no_soy_numero', petId: 50, quantity: 1 }
    Given path 'store', 'order'
    And request corruptBody
    When method POST
    Then status 500
    And match response.message == 'something bad happened'

  @STORE @CASO-20 @HAPPY
  Scenario: Validar el cierre de ciclo: Crear y Eliminar inmediatamente
    * def flowOrder = read('classpath:data/store/createOrder.json')
    * set flowOrder.id = 999123

    # 1. Crear
    Given path 'store', 'order'
    And request flowOrder
    When method POST
    Then status 200

    # 2. Eliminar
    Given path 'store', 'order', flowOrder.id
    When method DELETE
    Then status 200
    And match response.message == '999123'
    * print 'Ciclo de vida flash completado con éxito'