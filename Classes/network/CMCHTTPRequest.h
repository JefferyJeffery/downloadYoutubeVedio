//
//  EUClient.h
//  EasternUnion
//
//  Created by Gia on 9/9/13.
//  Copyright (c) 2013 opemoko. All rights reserved.
//

// #import "AFHTTPClient.h"
#import <AFHTTPRequestOperationManager.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

//Key
extern NSString * const RAFNetworkingOperationErrorKey;


@class Recipient, AFHTTPRequestOperation;

typedef NS_ENUM(NSInteger, TransactionSegmentationStatus) {
    TransactionSegmentationAll = 0,
    TransactionSegmentationPending,
    TransactionSegmentationCompleted,
};

@interface CMCHTTPRequest : AFHTTPRequestOperationManager
+ (CMCHTTPRequest *)httpRequest;

#pragma mark - HTTP Request Serializer + JSON Response Serializer
- (RACSignal *)rac_GET:(NSString *)path parameters:(NSDictionary *)parameters;
- (RACSignal *)rac_POST:(NSString *)path parameters:(NSDictionary *)parameters;
- (RACSignal *)rac_PUT:(NSString *)path parameters:(NSDictionary *)parameters;
- (RACSignal *)rac_DELETE:(NSString *)path parameters:(NSDictionary *)parameters;
- (RACSignal *)rac_PATCH:(NSString *)path parameters:(NSDictionary *)parameters;

#pragma mark - JSON Request Serializer + JSON Response Serializer
- (RACSignal *)rac_JsonRequestGET:(NSString *)path parameters:(NSDictionary *)parameters;
- (RACSignal *)rac_JsonRequestPOST:(NSString *)path parameters:(NSDictionary *)parameters;
- (RACSignal *)rac_JsonRequestPUT:(NSString *)path parameters:(NSDictionary *)parameters;
- (RACSignal *)rac_JsonRequestDELETE:(NSString *)path parameters:(NSDictionary *)parameters;
- (RACSignal *)rac_JsonRequestPATCH:(NSString *)path parameters:(NSDictionary *)parameters;

@end

static CMCHTTPRequest *HTTPRequest()
{
    return [CMCHTTPRequest httpRequest];
}
