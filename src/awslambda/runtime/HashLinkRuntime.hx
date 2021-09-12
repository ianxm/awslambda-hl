package awslambda.runtime;

import haxe.Http;
import sys.net.Socket;
import sys.io.Process;
import haxe.io.Eof;
import haxe.Json;

/**
 * Implements the aws lambda runtime api for hashlink
 * https://docs.aws.amazon.com/lambda/latest/dg/runtimes-custom.html.
 */
class HashLinkRuntime {
    private static var LOG_TAG(default,null) = "LAMBDA_RUNTIME";
    private static var REQUEST_ID_HEADER(default,null) = "Lambda-Runtime-Aws-Request-Id";
    private static var TRACE_ID_HEADER(default,null) = "Lambda-Runtime-Trace-Id";
    private static var CLIENT_CONTEXT_HEADER(default,null) = "Lambda-Runtime-Client-Context";
    private static var COGNITO_IDENTITY_HEADER(default,null) = "Lambda-Runtime-Cognito-Identity";
    private static var DEADLINE_MS_HEADER(default,null) = "Lambda-Runtime-Deadline-Ms";
    private static var FUNCTION_ARN_HEADER(default,null) = "Lambda-Runtime-Invoked-Function-Arn";

    private static var VERSION(default,null) = "0.0.1";
    private static var USER_AGENT(default,null) = "AWS_Lambda_HashLink/" + VERSION;
    private static var CONTENT_TYPE(default,null) = "text/html";

    private static var HANDLER_NAME(default,null) = "_HANDLER"; // handler name is not used
    private static var ROOT_NAME(default,null) = "LAMBDA_TASK_ROOT";
    private static var RUNTIME_API_NAME(default,null) = "AWS_LAMBDA_RUNTIME_API";

    private var runtimeUrl(default,default) :String;
    private var requestId(default,default) :String;
    public var handlerObject(null,default) :Dynamic;
    public var handlerMethod(null,default) :Dynamic;

    public function new() {
        runtimeUrl = Sys.getEnv(RUNTIME_API_NAME);
        var fullHandlerName = Sys.getEnv(HANDLER_NAME); // "packageName.ClassName.methodName"
        var handlerObjectName = fullHandlerName.substr(0, fullHandlerName.lastIndexOf("."));
        var handlerMethodName = fullHandlerName.substr(fullHandlerName.lastIndexOf(".")+1);
        this.handlerObject = Type.createInstance(Type.resolveClass(handlerObjectName), []);
        this.handlerMethod = Reflect.field(handlerObject, handlerMethodName);
    }

    /**
     * The execution loop.
     */
    public function start() {
        Sys.println('Starting HashLink runtime v$VERSION');
        // loop forever
        while (true) {
            try {
                getNext();
            } catch (e :Dynamic) {
                Sys.println('error: $e');
                Sys.println(haxe.CallStack.exceptionStack());
                Sys.sleep(0.003); // wait a bit
            }
        }
        Sys.println("HashLink runtime exiting");
    }

    /**
     * Get an event and process it.
     */
    private function getNext() {
        var nextUrl = '$runtimeUrl/2018-06-01/runtime/invocation/next';
        var nextReq = new Http(nextUrl);
        nextReq.setHeader("User-Agent", USER_AGENT);
        nextReq.noShutdown = true;
        nextReq.onData = function(data) {
            var event = Json.parse(data);
            requestId = nextReq.responseHeaders.get(REQUEST_ID_HEADER);
            var result = Reflect.callMethod(handlerObject, handlerMethod, [event]);
            postSuccess(Json.stringify(result));
        }
        nextReq.onError = function(msg) {
            var result = {statusCode: 500, body: msg};
            var resultJson = Json.stringify(result);
            if (msg != "Eof") {
                postFailure(resultJson);
            }
            throw resultJson;
        }
        nextReq.request(false);
    }

    /**
     * Post a success message back to aws.
     */
    private function postSuccess(payload) {
        var url = '$runtimeUrl/2018-06-01/runtime/invocation/$requestId/response';
        doPost(url, payload);
    }

    /**
     * Post a failure message back to aws.
     */
    private function postFailure(payload) {
        var url = '$runtimeUrl/2018-06-01/runtime/invocation/$requestId/error';
        doPost(url, payload);
    }

    /**
     * Make the HTTP post request.
     *
     * @param url the url
     * @param payload the HTTP payload
     */
    private function doPost(url :String, payload :String) {
        Sys.println('response: $payload');
        var request = new Http(url);
        request.setHeader("User-Agent", USER_AGENT);
        request.setHeader("Content-Type", CONTENT_TYPE);
        request.setHeader("Content-Length", Std.string(payload.length));
        request.setPostData(payload);
        request.onData = function(data) {
            Sys.println('result data: $data');
        }
        request.onError = function(msg) {
            Sys.println('result error: $msg');
        }
        request.request(true);
    }


    /**
     * Start the lambda container. This is called by bootstrap.
     */
    public static function main() {
        var runtime = new HashLinkRuntime();
        runtime.start();
    }
}