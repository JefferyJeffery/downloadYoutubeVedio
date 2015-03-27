//
//  CMCClient+Login.m
//  cmc
//
//  Created by Jeffery on 2015/3/23.
//  Copyright (c) 2015年 china-motor. All rights reserved.
//

#import "CMCHTTPRequest+Login.h"

@implementation CMCHTTPRequest (Login)
- (RACSignal *)loginPostWithParams:(NSDictionary *)params
{
    static NSString *endpoint = @"login";
    
    return [[self rac_POST:endpoint parameters:params] reduceEach:^id(AFHTTPRequestOperation *operation,NSDictionary * response){
        return response;
    }];
}
@end
