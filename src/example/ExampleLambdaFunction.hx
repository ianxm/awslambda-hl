package example;

import Type; // for ValueType
import awslambda.runtime.LambdaProxyTypes;
import awslambda.metrics.EmfMetricsFactory;

/**
 * This is an example lambda handler. Lambda handlers must:
 * - have an empty constructor
 * - be annotated with @:keep
 *
 * example event for this example function: {"a": 1, "b": 2}
 */
@:keep
class ExampleLambdaFunction {
    final metricsFactory = new EmfMetricsFactory("HlExampleLambda");

    /**
     * This is required.
     */
    public function new() {
    }

    /**
     * This is the actual lambda handler implementation. This is where you do what you want.
     *
     * @param event request as an anonymous object
     * @returns response as an anonymous object
     * @throws string on error
     */
    public function lambdaHandler( event :Dynamic ) :Dynamic {
        final metrics = metricsFactory.makeMetrics();
        Sys.println(Std.string(event));

        // validate input
        if( !validate(event.a) || !validate(event.b) ){
            metrics.addCount("InvalidRequest");
            metrics.emitMetrics();
            throw new BadRequest("invalid request: event must provide \"a\" and \"b\", and they must be numbers", null);
        }

        // do stuff
        var sum = event.a + event.b;

        // write a metric
        metrics.addCount("Success");
        metrics.emitMetrics();

        // return response as an anonymous object
        return {sum: sum};
    }

    /**
     * @return true if param is valid
     */
    private function validate( param ){
        return param != (Type.typeof(param) == ValueType.TInt || Type.typeof(param) == ValueType.TFloat);
    }
}
