//
//  TCPSocketClientManager.h
//  TCPClient
//
//  Created by 向尉 on 2017/7/11.
//  Copyright © 2017年 向尉. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCPSocketClientManager : NSObject

@property (nonatomic, retain) NSString *HOST;

@property (nonatomic, assign) UInt32 PORT;

@property (nonatomic, assign) NSInteger flag;

@property (nonatomic, retain) NSInputStream *inputStream;

@property (nonatomic, retain) NSOutputStream *outputStream;

-(instancetype)initWithHOST:(NSString *) host PORT:(UInt32)Port;

@end
