package awslambda.runtime;

import haxe.Json;

/*
  lambda proxy request, response, and error types
  https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html
*/

class ServiceError {
    private var statusCode :Int;
    private var name :String;
    private var message :String;
    public var headers(null,default) :Dynamic;

    private function new( statusCode :Int, name :String, message :String, ?headers :Dynamic ){
        this.statusCode = statusCode;
        this.name = name;
        this.message = message;
        this.headers = headers;
    }

    public function toResponse() {
        return {
            "statusCode": statusCode,
            "body": Json.stringify({
                "name": name,
                "message": message
            }),
            "headers": headers,
            "isBase64Encoded": null,
            "multiValueHeaders": null
        };
    }
}

class BadRequest extends ServiceError {
    public function new( message :String, ?headers :Dynamic ){
        super(400, "BadRequest", message, headers);
    }
}
class Unauthorized extends ServiceError {
    public function new( message :String, ?headers :Dynamic ){
        super(401, "Unauthorized", message, headers);
    }
}
class Forbidden extends ServiceError {
    public function new( message :String, ?headers :Dynamic ){
        super(403, "Forbidden", message, headers);
    }
}
class NotFound extends ServiceError {
    public function new( message :String, ?headers :Dynamic ){
        super(404, "Not Found", message, headers);
    }
}
class InternalError extends ServiceError {
    public function new( message :String, ?headers :Dynamic ){
        super(500, "Internal Error", message, headers);
    }
}

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
