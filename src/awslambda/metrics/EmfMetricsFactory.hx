package awslambda.metrics;

import awslambda.metrics.EmfMetrics;

/*
  The metrics factory is used to generate metrics objects, which emit metrics events.
 */
class EmfMetricsFactory {
    // the namespace in cloudwatch where the metrics will appear
    private var namespace :String;

    // the dimensions that apply to these metrics
    private var dimensionSets :Array<Array<Dimension>>;
    
    public function new( namespace :String ){
        this.namespace = namespace;
        this.dimensionSets = [];
    }

    public function addDimensionSet( dimensionSet :Array<Dimension> ) :Void {
        dimensionSets.push(dimensionSet);
    }

    public function makeMetrics() :EmfMetrics {
        return new EmfMetrics(namespace, dimensionSets);
    }
}
