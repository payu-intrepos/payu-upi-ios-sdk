#import <Foundation/Foundation.h>


#import "PayuCrashReporterDefines.h"
@class PayuCrashReporterHub, PayuCrashReporterBreadcrumb, PayuCrashReporterId;

NS_ASSUME_NONNULL_BEGIN

// NS_SWIFT_NAME(SDK)
/**
 "static api" for easy access to most common CrashReporter sdk features

 try `PayuCrashReporterHub` for advanced features
 */
@interface PayuCrashReporterSDK : NSObject
PAYU_CrashReporter_NO_INIT

/**
 * Returns current hub
 */
+ (PayuCrashReporterHub *)currentHub;




/**
 * Inits and configures CrashReporter (PayuCrashReporterHub, PayuCrashReporterClient) and sets up all integrations. Make sure to
 * set a valid DSN otherwise.
 */

+ (void)startWithExecutableName:(NSString *)name NS_SWIFT_NAME(start(executableName:));

+ (void)startWithExecutableName:(NSString *)name  withDsn:(NSString *)dsn NS_SWIFT_NAME(start(executableName:dsn:));

/**
 * Captures a message event and sends it to CrashReporter.
 *
 * @param message The message to send to CrashReporter.
 *
 * @return The PayuCrashReporterId of the event or PayuCrashReporterId.empty if the event is not sent.
 */
+ (PayuCrashReporterId *)captureMessage:(NSString *)message NS_SWIFT_NAME(capture(message:));


/**
 * Adds a PayuCrashReporterBreadcrumb to the current Scope on the `currentHub`.
 * If the total number of breadcrumbs exceeds the `max_breadcrumbs` setting, the
 * oldest breadcrumb is removed.
 */
+ (void)addBreadcrumb:(PayuCrashReporterBreadcrumb *)crumb NS_SWIFT_NAME(addBreadcrumb(crumb:));


/**
 * Set logLevel for the current client default kPayCrashReporterLogLevelError
 */
@property (nonatomic, class) PayUCrashReporterLogLevel logLevel;

/**
 * Checks if the last program execution terminated with a crash.
 */
@property (nonatomic, class, readonly) BOOL crashedLastRun;



@end

NS_ASSUME_NONNULL_END
