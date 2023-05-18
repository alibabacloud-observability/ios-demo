## 通过OpenTelemetry上报Objective-C应用数据

### 步骤一：创建应用并添加依赖
1. 选择要创建的应用，如 macOS Command Line Tool

2. 添加依方式：在XCode中选择File -> Add Packages...
- 在搜索框中输入 https://github.com/open-telemetry/opentelemetry-swift （选择1.4.0版本），勾选所需的Package Products：
```
OpentTelemetryProtocolExporter
```

- https://github.com/aliyun-sls/opentelemetry-objc-extension （选择1.0.0版本），勾选所需的Package Products：

```
OpentTelemetryApiObjc
OpentTelemetryProtocolExporterObjc
OpentTelemetrySdkObjc
ResourceExtensionObjc
StdoutExporterObjc
```

### 步骤二： 创建OpenTelemetry初始化工具类

1. 新建 OpenTelemetryUtil.h 头文件，添加如下内容并修改常量值：

- 数据上报接入点：请修改常量endpoint的值，例如 “tracing-analysis-dc-hz.aliyuncs.com”
- 接入点鉴权Token：请修改常量token的值，例如“xxx@xxx@xxx”
- 应用名称：请修改常量serviceName的值
- 主机名称：请修改常量hostName的值
  
```
#ifndef OpenTelemetryUtil_h
#define OpenTelemetryUtil_h

@import GRPC;
@import NIO;

@import OpenTelemetryApiObjc;
@import OpenTelemetrySdkObjc;
@import OpenTelemetryProtocolExporterObjc;
@import URLSessionInstrumentationObjc;
@import StdoutExporterObjc;

NS_ASSUME_NONNULL_BEGIN

@interface OpenTelemetryUtil : NSObject

+ (void)initOpenTelemetry;


@end

NS_ASSUME_NONNULL_END

#endif /* OpenTelemetryUtil_h */

```


2. 新建 OpenTelemetryUtil.m 文件，添加如下内容：

```
#import <Foundation/Foundation.h>

#import "OpenTelemetryUtil.h"


NSString *const endpoint = @"<gRPC-endpoint>"; // 数据上报接入点（不含协议头和端口号）
const int port = 8090; // 接入点端口号
NSString *const token = @"<token>"; // 接入点鉴权Token
NSString *const serviceName = @"<your-service-name>"; // 应用名称
NSString *const hostName = @"<your-host-name>"; // 主机名

@implementation OpenTelemetryUtil

+ (void)initOpenTelemetry {
    
    // 设置应用名与主机名
    NSDictionary *resources = @{
        ResourceAttributesObjc.serviceName: [AttributeValueObjc string:serviceName],
        ResourceAttributesObjc.hostName: [AttributeValueObjc string:hostName]
    };
    
    // 使用OTLP gRPC上报数据
    OtlpTraceExporterObjc *otlpGrpcExporter = [OtlpTraceExporterObjc exporter:endpoint
     port: port
     tls: false
     configuration:[OtlpConfigurationObjc configuration:OtlpConfigurationObjc.DefaultTimeoutInterval headers:@{
        @"Authentication": token}]
    ];
    
    // 控制台打印数据（debug使用）
    StdoutExporterObjc *stdoutExporter = [StdoutExporterObjc stdoutExporter:true];
    
    SpanProcessorObjc *spanProcessor = [BatchSpanProcessorObjc processor: [MultiSpanExporterObjc multiSpanExporter:@[
        stdoutExporter,
        otlpGrpcExporter
    ]]];
    
    TracerProviderBuilderObjc *tracerProviderBuilder = [TracerProviderBuilderObjc builder];
    
    tracerProviderBuilder = [tracerProviderBuilder withResource: [ResourceObjc resource: resources]];
    tracerProviderBuilder = [tracerProviderBuilder addSpanProcessor: spanProcessor];
    
    TracerProviderObjc *tracerProvider = [tracerProviderBuilder build];
    [OpenTelemetryObjc registerTracerProvider: tracerProvider];
    
}

@end

```

### 步骤三： OpenTelemetry初始化

在您的应用初始化方法中添加如下代码：

```
[OpenTelemetryUtil initOpenTelemetry];
```


### 步骤四： 创建Span进行埋点

```
// 获取 Tracer
TracerObjc *tracer = [OpenTelemetryObjc.instance.tracerProvider get:@"oc" instrumentationVersion:@"1.0.0"];

// 创建 Span，设置Span名称
SpanBuilderObjc *parentSpanBuilder = [tracer spanBuilder:@"SpanName"];
SpanObjc *parentSpan = [[parentSpanBuilder setSpanKind:SpanKindObjc.CLIENT] startSpan];

// 输出 TraceId 与 SpanId
NSLog(@"Parent Trace Id: %@", parentSpan.context.traceId);
NSLog(@"Parent Span Id: %@", parentSpan.context.spanId);


// your code ...

// Span结束时要调用end方法
[parentSpan end];
```

### 步骤五： 为Span添加属性和事件

```
// 添加属性
[parentSpan setAttribute:@"attrKey1" stringValue:@"value"];
// 添加事件
[parentSpan addEvent:@"span created" attributes:@{@"eventAttrKey": [AttributeValueObjc string:@"stringValue"]}];
```


### 步骤六： 创建嵌套的Span
```
// 获取Tracer
TracerObjc *tracer = [OpenTelemetryObjc.instance.tracerProvider get:@"oc" instrumentationVersion:@"1.0.0"];
        
// 创建ParentSpan
SpanBuilderObjc *parentSpanBuilder = [tracer spanBuilder:@"OC Parent Span"];
SpanObjc *parentSpan = [[parentSpanBuilder setSpanKind:SpanKindObjc.CLIENT] startSpan];

// your code ...

// 创建ChildSpan
SpanBuilderObjc *childSpanBuilder = [tracer spanBuilder:@"OC Child Span"];
[childSpanBuilder setParent: parentSpan]; // 关联ParentSpan与ChildSpan

// your code ...


[childSpan end];
[parentSpan end];

```


 
