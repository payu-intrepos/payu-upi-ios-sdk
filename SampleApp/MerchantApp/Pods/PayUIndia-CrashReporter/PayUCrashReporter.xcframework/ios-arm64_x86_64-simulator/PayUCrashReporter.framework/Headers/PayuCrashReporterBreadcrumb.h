#import <Foundation/Foundation.h>

#import "PayuCrashReporterDefines.h"
#import "PayuCrashReporterSerializable.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(Breadcrumb)
@interface PayuCrashReporterBreadcrumb : NSObject <PayuCrashReporterSerializable>

/**
 * Level of breadcrumb
 */
@property (nonatomic) PayUCrashReporterLevel level;

/**
 * Category of bookmark, can be any string
 */
@property (nonatomic, copy) NSString *category;

/**
 * NSDate when the breadcrumb happened
 */
@property (nonatomic, strong) NSDate *_Nullable timestamp;

/**
 * Type of breadcrumb, can be e.g.: http, empty, user, navigation
 * This will be used as icon of the breadcrumb
 */
@property (nonatomic, copy) NSString *_Nullable type;

/**
 * Message for the breadcrumb
 */
@property (nonatomic, copy) NSString *_Nullable message;

/**
 * Arbitrary additional data that will be sent with the breadcrumb
 */
@property (nonatomic, strong) NSDictionary<NSString *, id> *_Nullable data;

/**
 * Initializer for PayuCrashReporterBreadcrumb
 *
 * @param level PayUCrashReporterLevel
 * @param category String
 * @return PayuCrashReporterBreadcrumb
 */
- (instancetype)initWithLevel:(PayUCrashReporterLevel)level category:(NSString *)category;
- (instancetype)init;
+ (instancetype)new NS_UNAVAILABLE;

- (NSDictionary<NSString *, id> *)serialize;

- (BOOL)isEqual:(id _Nullable)other;

- (BOOL)isEqualToBreadcrumb:(PayuCrashReporterBreadcrumb *)breadcrumb;

- (NSUInteger)hash;

@end

NS_ASSUME_NONNULL_END
