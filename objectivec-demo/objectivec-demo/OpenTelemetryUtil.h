//
//  OpenTelemetryUtil.h
//  otel-oc-demo
//
//  Created by adam on 2023/5/15.
//

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
