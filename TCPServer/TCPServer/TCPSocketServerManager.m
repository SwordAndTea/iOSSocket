//
//  TCPSocketServerManager.m
//  TCPServer
//
//  Created by 向尉 on 2017/7/11.
//  Copyright © 2017年 向尉. All rights reserved.
//

#import "TCPSocketServerManager.h"
#include <sys/socket.h>
#include <netinet/in.h>
#import <ifaddrs.h>
#import <arpa/inet.h>

@implementation TCPSocketServerManager

void WriteStreamClientCallBack(CFWriteStreamRef stream,CFStreamEventType eventType,void * clientCallBackInfo)
{
    CFWriteStreamRef outputStream=stream;
    uint8 buff[]="hello client";
    if (outputStream != NULL)
    {
        CFWriteStreamWrite(outputStream, buff, strlen((const char *)buff)+1);
        CFWriteStreamClose(outputStream);
        CFWriteStreamUnscheduleFromRunLoop(outputStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
        outputStream=NULL;
    }
}
//当客户端把数据写入socket时调用
void ReadStreamClientCallBack(CFReadStreamRef stream, CFStreamEventType eventType,void *clientCallBackInfo)
{
    uint8 buff[255];
    CFReadStreamRef inputStream= stream;
    if (inputStream !=NULL)
    {
        CFReadStreamRead(stream, buff, 255);
        printf("receive data %s\n",buff);
        CFReadStreamClose(inputStream);
        CFReadStreamUnscheduleFromRunLoop(inputStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
        inputStream = NULL;
    }
}

//服务器端接受到客户端请求后回调
void AcceptCallBack(CFSocketRef socketRef, CFSocketCallBackType callBackType,CFDataRef address,const void *data,void *info)
{
    
    CFReadStreamRef readStream = NULL;
    CFWriteStreamRef writeStream = NULL;
    CFSocketNativeHandle sock= *(CFSocketNativeHandle *) data;
    
    //创建读写 socket 流
    CFStreamCreatePairWithSocket(kCFAllocatorDefault, sock, &readStream, &writeStream);
    if (!readStream || !writeStream)
    {
        close(sock);
        fprintf(stderr, "CFSreamCreatePairWithSocket()failed\n");
        return;
    }
    CFStreamClientContext streamClientContext={0,NULL,NULL,NULL,NULL};
    
    CFReadStreamSetClient(readStream, kCFStreamEventHasBytesAvailable, ReadStreamClientCallBack, &streamClientContext);
    
    CFWriteStreamSetClient(writeStream, kCFStreamEventCanAcceptBytes, WriteStreamClientCallBack, &streamClientContext);
    
    CFReadStreamScheduleWithRunLoop(readStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
    
    CFWriteStreamScheduleWithRunLoop(writeStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
    
    CFReadStreamOpen(readStream);
    
    CFWriteStreamOpen(writeStream);
}

-(instancetype)initWithPORT:(NSInteger)port
{
    self=[super init];
    if (self)
    {
        _PORT=port;
        [self initSocket];
    }
    return self;
}


-(NSString *)getIpAddresses
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL)
        {
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

-(int)initSocket
{
    CFSocketRef socketServer;//定义一个服务器socket
    
    CFSocketContext CTX={0,NULL,NULL,NULL,NULL};//创建socket context
    
    socketServer = CFSocketCreate(NULL, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, (CFSocketCallBack)AcceptCallBack, &CTX);
    if (socketServer == NULL)
    {
        return -1;
    }
    int yes=1;
    setsockopt(CFSocketGetNative(socketServer), SOL_SOCKET, SO_REUSEADDR, (void *)&yes, sizeof(yes));
    struct sockaddr_in addr;
    memset(&addr, 0, sizeof(addr));
    addr.sin_len=sizeof(addr);
    addr.sin_family=AF_INET;
    addr.sin_port=htons(_PORT);
    addr.sin_addr.s_addr=htonl(INADDR_ANY);
    
    CFDataRef address=CFDataCreate(kCFAllocatorDefault, (UInt8 *)&addr, sizeof(addr));
    if (CFSocketSetAddress(socketServer, (CFDataRef) address) != kCFSocketSuccess)
    {
        fprintf(stderr, "Socket 绑定失败\n");
        CFRelease(socketServer);
        return -1;
    }
    CFRunLoopSourceRef sourceRef=CFSocketCreateRunLoopSource(kCFAllocatorDefault, socketServer, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), sourceRef, kCFRunLoopCommonModes);
    CFRelease(sourceRef);
    
    printf("Socket listing on port %ld\n",_PORT);
    CFRunLoopRun();
    return 1;
}

@end
