//
//  OpenTelemetryUtil.m
//  otel-oc-demo
//
//  Created by adam on 2023/5/15.
//

#import <Foundation/Foundation.h>

#import "OpenTelemetryUtil.h"

@import GRPC;
@import NIO;

@import OpenTelemetryApiObjc;
@import OpenTelemetrySdkObjc;
@import OpenTelemetryProtocolExporterObjc;
@import URLSessionInstrumentationObjc;
@import StdoutExporterObjc;

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
