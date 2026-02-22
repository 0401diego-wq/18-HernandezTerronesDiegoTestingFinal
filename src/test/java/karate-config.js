function fn() {
  var env = karate.env; // get system property 'karate.env'
  karate.log('karate.env system property was:', env);



  if (!env) {
    env = 'dev';
  }

  if (env == 'dev') {
    apiPetStore = 'https://petstore.swagger.io/v2/'
  } else if (env == 'cert') {

  }

  var config = {
      env: env,
      myVarName: 'someValue',
      apiPetStore: apiPetStore
    }

  return config;
}