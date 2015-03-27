//
//  CMCClient+Login.h
//  cmc
//
//  Created by Jeffery on 2015/3/23.
//  Copyright (c) 2015年 china-motor. All rights reserved.
//

#import "CMCHTTPRequest.h"

@interface CMCHTTPRequest (Login)
- (RACSignal *)loginPostWithParams:(NSDictionary *)params;
@end
