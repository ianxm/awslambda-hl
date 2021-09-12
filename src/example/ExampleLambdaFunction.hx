package example;

import Type; // for ValueType

/**
 * This is an example lambda handler. Lambda handlers must:
 * - have an empty constructor
 * - be annotated with @:keep
 *
 * example event for this example function: {"a": 1, "b": 2}
 */
@:keep
class ExampleLambdaFunction {
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
        Sys.println(Std.string(event));

        // validate input
        if( !validate(event.a) || !validate(event.b) ){
            throw 'validation failure: event must provide "a" and "b", and they must be numbers';
        }

        // do stuff
        var sum = event.a + event.b;

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
