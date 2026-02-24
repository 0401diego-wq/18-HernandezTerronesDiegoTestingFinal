function fn() {
    var env = karate.env;
    karate.log('karate.env system property was:', env);

    if (!env) {
        env = 'dev';
    }

    var baseUrl;

    if (env == 'dev') {
        baseUrl = 'https://petstore.swagger.io/v2';
    } else if (env == 'cert') {
        baseUrl = 'https://petstore.swagger.io/v2';
    }

    var config = {
        env: env,
        baseUrl: baseUrl
    };

    return config;
}