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


  @STORE
  @CASO-3
  @HAPPY
  Scenario: Crear orden válida usando JSON externo

    * def randomId = Math.floor(Math.random() * 100000)

    Given path 'store', 'order'
    And request read('classpath:data/store/createOrder.json')
    When method POST
    Then status 200
    And match response.id == randomId
    And match response.status == "placed"