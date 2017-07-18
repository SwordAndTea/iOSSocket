//
//  TCPSocketClientManager.m
//  TCPClient
//
//  Created by 向尉 on 2017/7/11.
//  Copyright © 2017年 向尉. All rights reserved.
//

#import "TCPSocketClientManager.h"
#include <sys/socket.h>
#include <netinet/in.h>

@interface TCPSocketClientManager ()<NSStreamDelegate>

@end

@implementation TCPSocketClientManager

-(instancetype)initWithHOST:(NSString *)host PORT:(UInt32)Port
{
    self=[super init];
    if (self)
    {
        _HOST=host;
        _PORT=Port;
        [self initNetworkCommunicationWithHOST:_HOST PORT:_PORT];
    }
    return self;
}

-(void)initNetworkCommunicationWithHOST:(NSString *)host PORT:(UInt32)port
{
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStraem;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)host,port, &readStream, &writeStraem);
    _inputStream =(__bridge_transfer NSInputStream *)readStream;
    _outputStream=(__bridge_transfer NSOutputStream *)writeStraem;
    [_inputStream setDelegate:self];
    [_outputStream setDelegate:self];
    [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_inputStream open];
    [_outputStream open];
}
#pragma mark - NSStreamDelegate
-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    
    NSString *event;
    switch (eventCode) {
        case NSStreamEventNone:
            event=@"NSStreamEventNone";
            break;
        case NSStreamEventOpenCompleted:
            event=@"NSStreamEventCompleted";
            break;
        case NSStreamEventHasBytesAvailable:
            event=@"NSStreamEventHasBytesAvailable";
            if (_flag == 1 && aStream == _inputStream)
            {
                NSMutableData *input=[[NSMutableData alloc]init];
                uint8_t buff[1024];
                NSInteger len;
                while ([_inputStream hasBytesAvailable])
                {
                    len=[_inputStream read:buff maxLength:sizeof(buff)];
                    if (len > 0)
                    {
                        [input appendBytes:buff length:len];
                    }
                }
                NSString *resultString=[[NSString alloc]initWithData:input encoding:NSUTF8StringEncoding];
                NSLog(@"receive %@",resultString);
            }
            break;
        case NSStreamEventHasSpaceAvailable:
            event=@"NSStreamEventHasSpaceAvailable";
            if (_flag == 0 && aStream == _outputStream)
            {
                UInt8 buff[] = "hello sever";
                [_outputStream write:buff maxLength:strlen((const char *)buff) +1];
                [_outputStream close];
            }
            break;
        case NSStreamEventErrorOccurred:
            event=@"NSStreamEventErrorOccurred";
            [self close];
            break;
        case NSStreamEventEndEncountered:
            event=@"NSStreamEventEndEncountered";
            NSLog(@"error: %ld : %@",[[aStream streamError] code],[[aStream streamError] localizedDescription]);
        default:
            [self close];
            event=@"UnKnown";
            break;
    }
    NSLog(@"even----- %@",event);
}

-(void)close
{
    [_outputStream close];
    [_outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream setDelegate:nil];
    [_inputStream close];
    [_inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_inputStream setDelegate:nil];
}

@end
