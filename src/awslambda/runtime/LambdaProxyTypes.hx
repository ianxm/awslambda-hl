package awslambda.runtime;

/*
  lambda proxy request and response types
  https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html
*/

typedef Request = {
    resource :String,
    path :String,
    httpMethod :String,
    ?headers :Dynamic,
    ?multiValueHeaders :Dynamic,
    ?queryStringParameters :Dynamic,
    ?multiValueQueryStringParameters :Dynamic,
    ?pathParameters :Dynamic,
    stageVariables :Dynamic,
    requestContext :RequestContext,
    body :String,
    isBase64Encoded :Bool
};

typedef Response = {
    ?isBase64Encoded :Bool,
    statusCode :Int,
    ?headers :Dynamic,
    ?multiValueHeaders :Dynamic,
    body :String,
};

typedef RequestContext = {
    resourceId :String,
    resourcePath :String,
    httpMethod :String,
    extendedRequestId :String,
    requestTime :String,
    path :String,
    accountId :String,
    protocol :String,
    stage :String,
    domainPrefix :String,
    requestTimeEpoch :Float,
    requestId :String,
    identity :RequestIdentity,
    domainName :String,
    apiId :String
};

typedef RequestIdentity = {
    cognitoIdentityPoolId :String,
    cognitoIdentityId :String,
    apiKey :String,
    principalOrgId :String,
    cognitoAuthenticationType :String,
    userArn :String,
    apiKeyId :String,
    userAgent :String,
    accountId :String,
    caller :String,
    sourceIp :String,
    accessKey :String,
    cognitoAuthenticationProvider :String,
    user :String
};
