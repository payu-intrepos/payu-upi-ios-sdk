#import <Foundation/Foundation.h>

#ifdef __cplusplus
#    define PayU_CrashReporter_EXTERN extern "C" __attribute__((visibility("default")))
#else
#    define PayU_CrashReporter_EXTERN extern __attribute__((visibility("default")))
#endif

#if TARGET_OS_IOS || TARGET_OS_TV
#    define PayU_CrashReporter_HAS_UIDEVICE 1
#else
#    define PayU_CrashReporter_HAS_UIDEVICE 0
#endif

#if PayU_CrashReporter_HAS_UIDEVICE
#    define PayU_CrashReporter_HAS_UIKIT 1
#else
#    define PayU_CrashReporter_HAS_UIKIT 0
#endif

#define PAYU_CrashReporter_NO_INIT                                                                             \
    -(instancetype)init NS_UNAVAILABLE;                                                            \
    +(instancetype) new NS_UNAVAILABLE;

@class PayuCrashReporterEvent, PayuCrashReporterBreadcrumb;

/**
 * Block used for returning after a request finished
 */
typedef void (^PayUCrashReporterRequestFinished)(NSError *_Nullable error);

/**
 * Block used for request operation finished, shouldDiscardEvent is YES if event
 * should be deleted regardless if an error ocured or not
 */
typedef void (^PayUCrashReporterRequestOperationFinished)(
    NSHTTPURLResponse *_Nullable response, NSError *_Nullable error);
/**
 * Block can be used to mutate a breadcrumb before it's added to the scope.
 * To avoid adding the breadcrumb altogether, return nil instead.
 */
typedef PayuCrashReporterBreadcrumb *_Nullable (^PayUCrashReporterBeforeBreadcrumbCallback)(
    PayuCrashReporterBreadcrumb *_Nonnull breadcrumb);

/**
 * Block can be used to mutate event before its send.
 * To avoid sending the event altogether, return nil instead.
 */
typedef PayuCrashReporterEvent *_Nullable (^PayCrashReporterBeforeSendEventCallback)(PayuCrashReporterEvent *_Nonnull event);

/**
 * A callback to be notified when the last program execution terminated with a crash.
 */
typedef void (^PayCrashReporterOnCrashedLastRunCallback)(PayuCrashReporterEvent *_Nonnull event);

/**
 * Block can be used to determine if an event should be queued and stored
 * locally. It will be tried to send again after next successful send. Note that
 * this will only be called once the event is created and send manully. Once it
 * has been queued once it will be discarded if it fails again.
 */
typedef BOOL (^PayCrashReporterShouldQueueEvent)(
    NSHTTPURLResponse *_Nullable response, NSError *_Nullable error);
/**
 * Loglevel
 */
typedef NS_ENUM(NSInteger, PayUCrashReporterLogLevel) {
    kPayUCrashReporterLogLevelNone = 1,
    kPayCrashReporterLogLevelError,
    kPayUCrashReporterLogLevelDebug,
    kPayUCrashReporterLogLevelVerbose
};

/**
 * CrashReporter level
 */
typedef NS_ENUM(NSUInteger, PayUCrashReporterLevel) {
    // Defaults to None which doesn't get serialized
    kPayUCrashReporterLevelNone = 0,
    // Goes from Debug to Fatal so possible to: (level > Info) { .. }
    kPayUCrashReporterLevelDebug = 1,
    kPayUCrashReporterLevelInfo = 2,
    kPayUCrashReporterLevelWarning = 3,
    kPayUCrashReporterLevelError = 4,
    kPayUCrashReporterLevelFatal = 5,
};

/**
 * Static internal helper to convert enum to string
 */
static NSString *_Nonnull const PayUCrashReporterLevelNames[] = {
    @"none",
    @"debug",
    @"info",
    @"warning",
    @"error",
    @"fatal",
};

static NSUInteger const defaultMaxBreadcrumbs = 100;
