//
//  main.m
//  otel-oc-demo
//
//  Created by adam on 2023/5/15.
//

#import <Foundation/Foundation.h>
#import "OpenTelemetryUtil.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...

        // 1. OpenTelemetry初始化 (只需初始化一次)
        [OpenTelemetryUtil initOpenTelemetry];
        
        // 2. 获取Tracer
        TracerObjc *tracer = [OpenTelemetryObjc.instance.tracerProvider get:@"oc" instrumentationVersion:@"1.0.0"];
        
        // 3. 创建ParentSpan
        SpanBuilderObjc *parentSpanBuilder = [tracer spanBuilder:@"OC Parent Span"];
        SpanObjc *parentSpan = [[parentSpanBuilder setSpanKind:SpanKindObjc.CLIENT] startSpan];
        [parentSpan setAttribute:@"attrKey1" stringValue:@"value"];
        [parentSpan addEvent:@"span created" attributes:@{@"eventAttrKey": [AttributeValueObjc string:@"stringValue"]}];
       
        // 输出 TraceId 与 SpanId
        NSLog(@"Parent Trace Id: %@", parentSpan.context.traceId);
        NSLog(@"Parent Span Id: %@", parentSpan.context.spanId);
        
        // your code ...
        
        // 4. 创建ChildSpan
        SpanBuilderObjc *childSpanBuilder = [tracer spanBuilder:@"OC Child Span"];
        [childSpanBuilder setParent: parentSpan]; // 关联ParentSpan与ChildSpan
        SpanObjc *childSpan = [[childSpanBuilder setSpanKind:SpanKindObjc.CLIENT] startSpan];
        [childSpan setAttribute:@"attrKey2" stringValue:@"value"];
        
        // 输出 TraceId 与 SpanId
        NSLog(@"Child Trace Id: %@", childSpan.context.traceId);
        NSLog(@"Child Span Id: %@", childSpan.context.spanId);
        
        // your code ...
    
        
        [childSpan end];
        [parentSpan end];
        
        [NSThread sleepForTimeInterval:10.0];
    }
    return 0;
}
