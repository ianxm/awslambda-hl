## AWS Lambda HashLink Runtime

AWS Lambda is a serverless architecture that can run microservices
written in haxe and compiled to HashLink. This project contains the
HashLink runtime as well as an example microservice implementation.

## Building and Installing the Example

To build the runtime and example handler, run the build script
included in this project. This will create a zip file in the dist
directory containing the example implementation.

To set up the lambda function in AWS
1. create lambda function
2. set the Runtime to 'Custom AL2'
3. upload `lambda_handler.zip` and save
4. set the 'Runtime settings' > 'Handler' to `example.ExampleLambdaFunction.lambdaHandler`

The example lambda function is set up and ready. Here are some test
inputs:

1. {"a": 1, "b": 2} // returns sum=3
2. {"a": 1.1, "b": -2.3} // returns sum=-1.2
3. {"a": "car", "b": 2} // returns validation error
4. {"one": 1} // returns validation error

## Usage

To write your own lambda implementation, create a class with a method
that takes a `Dynamic` and returns another `Dynamic`. The request
event will be passed in as an anonymous object. The `lambdaHandler`
method should return an anonymous object with the response, or throw a
`HashLinkRuntime.ServiceError` containing an error message on
failure. `BadRequest` is meant for 4xx type errors. `InternalError` is
meant for 5xx type errors. The handler object must have an empty
constructor and be annotated with `@:keep`.

The constructor will be called once at lambda container startup.  The
handler method will be called for each event. Lambda determins when
new containers are needed and when existing containers are reused.

Compile with `-lib awslambda-hl` to get the runtime. This will include
a `main` method so you do not need to provide one. Since your handler
isn't referenced from main, you have to explicitly add it to the build
by referencing the class name directly in the build command, the same
way this project's "build.hxml" references the example handler.

Follow the above steps to set up the lambda function in AWS, but set
the 'Handler' setting to match your class. It should be formatted as
"packageName.ClassName.methodName".

Use something like the following to zip the lambda bundle. It is
including the 'bin' and 'lib' directories (excluding the example code)
from the awslambda-hl library. These contain the lambda bootstrap
script and hashlink binaries compiled for AL2.

```
#!/bin/bash

mkdir -p dist
rm -f dist/*.zip

HERE=$(pwd)
AWSLAMBDA_LIB=$(haxelib libpath awslambda-hl)

cd $AWSLAMBDA_LIB/bin && \
zip --symlinks -ry $HERE/dist/lambda_handler.zip * -x bin/lambda_handler.hl && \
cd $HERE && \
zip -ry $HERE/dist/lambda_handler.zip bin
```

## Lambda Proxy Integration

If you're using a [Lambda Proxy
Integration](https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html)
you can use the types defined in `awslambda.runtime.LambdaProxyTypes`
for the input and output of your handler method.

## EMF Metrics

You can write metrics to CloudWatch using the provided metrics
classes. Metrics are written to the logs, and CloudWatch automatically
extracts them and saves them as metrics in the background.

Usage is straightforward. You basically create a `MetricsFactory`
which specifies the CloudWatch namespace and metric dimensions, then
get a `metrics` object from it and set metrics, then emit the metrics
before exiting. Review the example lambda function to see how it is
done and look at the cloudwatch documentation for details.
