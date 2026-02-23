@regresion
Feature: Automatizar el backend de Pet Store

  Background:
    * url apiPetStore
    * def jsonCrearMascota = read('classpath:examples/jsonData/crearMascota.json')
    * def jsonEditMascota = read('classpath:examples/jsonData/actualizarMascota.json')

  @TEST-1 @happypath @crearMascosta
  Scenario: Verificar la creación de una nueva mascota en Pet Store - OK
    Given path 'pet'
    And request jsonCrearMascota
    When method post
    Then status 400
    And match response.id == 556
    And match response.name == 'KevinGood'
    And match response.status == 'available'
    * def idPet = response.id


  @TEST-2 @happypath
  Scenario Outline: Verificar el estado de la mascota por los 3 estados que son available, sold y pending - OK
    Given path 'pet/findByStatus'
    And param status = '<estado>'
    When method get
    Then status 200
    And print response

    Examples:
      | estado    |
      | available |
      | sold      |
      | pending   |


  @TEST-3 @happypath
  Scenario: Verificar la actualizacion de una mascota en Pet Store previamente registrada - OK
    Given path 'pet'
    * set jsonEditMascota.id = '3'
    * set jsonEditMascota.name = 'Sassy'
    * set jsonEditMascota.status = 'sold'
    And request jsonEditMascota
    When method put
    Then status 200
    And print response

  @TEST-4 @happypath
  Scenario Outline: Verificar la busqueda de la mascota por id - OK
    Given path 'pet/' + '<idPet>'
    When method get
    Then status 200
    And print response

    Examples:
      | idPet |
      | 1     |
      | 2     |
      | 3     |

  @TEST-5 @happypath
  Scenario Outline: Verificar la eliminación de la mascota por id - OK
    Given path 'pet/' + '<idPet>'
    When method delete
    Then status 200
    And print response

    Examples:
      | idPet |
      | 1     |
      | 2     |
      | 3     |

  @TEST-6 @happypath
  Scenario: Subir una imagen para una mascota existente
    * def petId = 4
    Given path 'pet', petId, 'uploadImage'
    And multipart file file = { read: 'classpath:examples/imagenes/fotoPerfil.png', filename: 'fotoPerfil.png', contentType: 'image/png' }
    And multipart field additionalMetadata = 'Foto de perfil'
    When method post
    Then status 200


    #  llamar a otro caso de prueba para usarlo después
  @TEST-7 @happypath
  Scenario: Verificar la busqueda de la mascota por id - OK
    * def idMascosta = call read('classpath:examples/users/users.feature@crearMascosta')
    Given path 'pet/' + idMascosta.idPet
    When method get
    Then status 200
    And print response

  @crearSolo
  Scenario: Crear mascota simple desde terminal

    * def idPet = Math.floor(Math.random() * 10000)

    Given path 'pet'
    And request { id: #(idPet), name: 'KevinDog', status: 'available' }
    When method post
    Then status 200
    And print response



