package awslambda.metrics;

using Lambda;
import haxe.Json;

typedef Dimension = {
    var name :String;
    var value :String;
}

// https://docs.aws.amazon.com/AmazonCloudWatch/latest/APIReference/API_MetricDatum.html
enum abstract MetricUnit(String) {
    var Seconds = "Seconds";
    var Microseconds = "Microseconds";
    var Milliseconds = "Milliseconds";
    var Bytes = "Bytes";
    var Kilobytes = "Kilobytes";
    var Megabytes = "Megabytes";
    var Gigabytes = "Gigabytes";
    var Terabytes = "Terabytes";
    var Bits = "Bits";
    var Kilobits = "Kilobits";
    var Megabits = "Megabits";
    var Gigabits = "Gigabits";
    var Terabits = "Terabits";
    var Percent = "Percent";
    var Count = "Count";
    var Bytes_Second = "Bytes/Second";
    var Kilobytes_Second = "Kilobytes/Second";
    var Megabytes_Second = "Megabytes/Second";
    var Gigabytes_Second = "Gigabytes/Second";
    var Terabytes_Second = "Terabytes/Second";
    var Bits_Second = "Bits/Second";
    var Kilobits_Second = "Kilobits/Second";
    var Megabits_Second = "Megabits/Second";
    var Gigabits_Second = "Gigabits/Second";
    var Terabits_Second = "Terabits/Second";
    var Count_Second = "Count/Second";
    var None = "None";
}

typedef MetricType = {
    var unit :MetricUnit;
    var value :Float;
};

typedef MetricMetaType = {
    var Name :String;
    var Unit :String;
}

/*
  Emit metrics events to cloudwatch by calling the `add` or `set` methods here, and then calling `emitMetrics`.
 */
class EmfMetrics {
    private var namespace :String;
    private var dimensionSets :Array<Array<Dimension>>;
    private var metrics :Map<String,MetricType>;
    private var alreadySent = false;

    public function new( namespace, dimensionSets ){
        this.namespace = namespace;
        this.dimensionSets = dimensionSets;
        this.metrics = new Map<String,MetricType>();
    }

    /*
      Convenience method to set or increase a metric with a count
     */
    public function addCount( name, ?count=1 ){
        final currentMetric = metrics.get(name);
        final currentCount =  if( currentMetric == null ){
            0;
        } else if( currentMetric.unit != MetricUnit.Count ){
            Sys.println("WARN: Metric type mismatch, dropping old value");
            0;
        } else {
            Std.int(currentMetric.value);
        }
            
        setCount(name, currentCount + count);
    }

    /*
      Convenience method to write a metric with a count
     */
    public inline function setCount( name, count ){
        setMetric(name, count, MetricUnit.Count);
    }

    /*
      Convenience method to set or increase a metric with a time in ms
     */
    public function addTime( name, timeMs ){
        final currentMetric = metrics.get(name);
        final currentTimeMs = if( currentMetric == null ){
            0.0;
        } else if( currentMetric.unit != MetricUnit.Milliseconds ){
            Sys.println("WARN: Metric type mismatch, dropping old value");
            0.0;
        } else {
            currentMetric.value;
        }
            
        setCount(name, currentTimeMs + timeMs);
    }

    /*
      Convenience method to write a metric with a time in ms
     */
    public inline function setTimeMs( name, timeMs ){
        setMetric(name, timeMs, MetricUnit.Milliseconds);
    }

    /*
      General method to write a metric with the given values
     */
    public inline function setMetric( name, value, unit ){
        metrics.set(name, { unit: unit, value: value });
    }

    // https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Embedded_Metric_Format_Specification.html
    public function emitMetrics() {
        if( alreadySent ){
            Sys.println("WARN: Refusing to send duplicate metrics");
        }
                
        final timestamp = Date.now().getTime();

        final dimensionsMeta = [];
        
        final metricsMeta = [];

        final metricsObj :Dynamic = {
            "_aws": {
                "Version": "1.0",
                "Timestamp": timestamp,
                "CloudWatchMetrics": [
                    {
                        "Namespace": namespace,
                        "Dimensions": dimensionsMeta,
                        "Metrics": metricsMeta
                    }
                ]
            }
        };

        final dimensionSetsToWrite = dimensionSets.length == 0 ? [[]] : dimensionSets;
        for( dimensionSet in dimensionSetsToWrite ){
            dimensionsMeta.push(dimensionSet.map( ii -> ii.name ));
            for( dimension in dimensionSet ){
                Reflect.setField(metricsObj, dimension.name, dimension.value);
            }
        }

        for( metric in metrics.keyValueIterator() ){
            metricsMeta.push({
                "Name": metric.key,
                "Unit": Std.string(metric.value.unit)
            });
            Reflect.setField(metricsObj, metric.key, metric.value.value);
        }

        Sys.println(Json.stringify(metricsObj));
        alreadySent = true;
    }
}
