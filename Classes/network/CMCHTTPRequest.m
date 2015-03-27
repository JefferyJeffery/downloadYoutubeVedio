//
//  EUClient.m
//  EasternUnion
//
//  Created by Gia on 9/9/13.
//  Copyright (c) 2013 opemoko. All rights reserved.
//

#import "CMCHTTPRequest.h"
NSString * const RAFNetworkingOperationErrorKey = @"AFHTTPRequestOperation";


NSString * const kBaseUrl = @"http://turing-alcove-87904.appspot.com";
//NSString * const kBaseUrl = @"http://localhost:8090/";

@implementation CMCHTTPRequest
+ (CMCHTTPRequest *)httpRequest {
    static CMCHTTPRequest *httpRequest = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        httpRequest = [[CMCHTTPRequest alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    });
    
    return httpRequest;
}

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (self) {
        //defaule
        self.requestSerializer = [AFHTTPRequestSerializer serializer];
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        
        // add AFNetworkReachabilityManager
        [self addAFNetworkReachabilityManager];
    }
    
    return self;
}

#pragma mark - private method
-(void) addAFNetworkReachabilityManager
{
    self.reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    [self.reachabilityManager startMonitoring];
    [self.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"The Internet connection appears to be offline."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
                break;
            case AFNetworkReachabilityStatusUnknown:
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:
            default:
            {
                
            }
                break;
        }
    }];
}

- (RACSignal *)rac_requestPath:(NSString *)path parameters:(NSDictionary *)parameters method:(NSString *)method {
    return [RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        
        NSString *fullURLString = [[NSURL URLWithString:path relativeToURL:self.baseURL] absoluteString];
        
        NSURLRequest *request = [self.requestSerializer requestWithMethod:method URLString:fullURLString parameters:parameters error:nil];
        
        AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:nil failure:nil];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {

            [subscriber sendNext:RACTuplePack(operation, responseObject)];
            [subscriber sendCompleted];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            NSMutableDictionary *userInfo = [error.userInfo mutableCopy] ?: [NSMutableDictionary dictionary];
            userInfo[RAFNetworkingOperationErrorKey] = operation;
            [subscriber sendError:[NSError errorWithDomain:error.domain code:error.code userInfo:userInfo]];
            
        }];
        
        [self.operationQueue addOperation:operation];
        
        return [RACDisposable disposableWithBlock:^{
            [operation cancel];
        }];
    }];
}

#pragma mark - HTTP Request Serializer + JSON Response Serializer
- (RACSignal *)rac_GET:(NSString *)path parameters:(NSDictionary *)parameters {
    return [[self rac_requestPath:path parameters:parameters method:@"GET"]
            setNameWithFormat:@"<%@: %p> -rac_getPath: %@, parameters: %@", self.class, self, path, parameters];
    
}

- (RACSignal *)rac_POST:(NSString *)path parameters:(NSDictionary *)parameters {
    return [[self rac_requestPath:path parameters:parameters method:@"POST"]
            setNameWithFormat:@"<%@: %p> -rac_postPath: %@, parameters: %@", self.class, self, path, parameters];
    
}

- (RACSignal *)rac_PUT:(NSString *)path parameters:(NSDictionary *)parameters {
    return [[self rac_requestPath:path parameters:parameters method:@"PUT"]
            setNameWithFormat:@"<%@: %p> -rac_putPath: %@, parameters: %@", self.class, self, path, parameters];
    
}

- (RACSignal *)rac_DELETE:(NSString *)path parameters:(NSDictionary *)parameters {
    return [[self rac_requestPath:path parameters:parameters method:@"DELETE"]
            setNameWithFormat:@"<%@: %p> -rac_deletePath: %@, parameters: %@", self.class, self, path, parameters];
}

- (RACSignal *)rac_PATCH:(NSString *)path parameters:(NSDictionary *)parameters {
    return [[self rac_requestPath:path parameters:parameters method:@"PATCH"]
            setNameWithFormat:@"<%@: %p> -rac_patchPath: %@, parameters: %@", self.class, self, path, parameters];
}

#pragma mark - JSON Request Serializer + JSON Response Serializer
- (RACSignal *)rac_JsonRequestGET:(NSString *)path parameters:(NSDictionary *)parameters {
    self.requestSerializer = [AFJSONRequestSerializer serializer];
    return [[self rac_requestPath:path parameters:parameters method:@"GET"]
            setNameWithFormat:@"<%@: %p> -rac_getPath: %@, parameters: %@", self.class, self, path, parameters];
    
}

- (RACSignal *)rac_JsonRequestPOST:(NSString *)path parameters:(NSDictionary *)parameters {
    self.requestSerializer = [AFJSONRequestSerializer serializer];
    return [[self rac_requestPath:path parameters:parameters method:@"POST"]
            setNameWithFormat:@"<%@: %p> -rac_postPath: %@, parameters: %@", self.class, self, path, parameters];
    
}

- (RACSignal *)rac_JsonRequestPUT:(NSString *)path parameters:(NSDictionary *)parameters {
    self.requestSerializer = [AFJSONRequestSerializer serializer];
    return [[self rac_requestPath:path parameters:parameters method:@"PUT"]
            setNameWithFormat:@"<%@: %p> -rac_putPath: %@, parameters: %@", self.class, self, path, parameters];
    
}

- (RACSignal *)rac_JsonRequestDELETE:(NSString *)path parameters:(NSDictionary *)parameters {
    self.requestSerializer = [AFJSONRequestSerializer serializer];
    return [[self rac_requestPath:path parameters:parameters method:@"DELETE"]
            setNameWithFormat:@"<%@: %p> -rac_deletePath: %@, parameters: %@", self.class, self, path, parameters];
}

- (RACSignal *)rac_JsonRequestPATCH:(NSString *)path parameters:(NSDictionary *)parameters {
    self.requestSerializer = [AFJSONRequestSerializer serializer];
    return [[self rac_requestPath:path parameters:parameters method:@"PATCH"]
            setNameWithFormat:@"<%@: %p> -rac_patchPath: %@, parameters: %@", self.class, self, path, parameters];
}

@end
