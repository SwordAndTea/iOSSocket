//
//  TCPSocketServerManager.h
//  TCPServer
//
//  Created by 向尉 on 2017/7/11.
//  Copyright © 2017年 向尉. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCPSocketServerManager : NSObject

@property(nonatomic,assign) NSInteger PORT;

-(instancetype)initWithPORT:(NSInteger) port;

-(NSString *)getIpAddresses;

@end
