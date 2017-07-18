//
//  ViewController.m
//  TCPClient
//
//  Created by 向尉 on 2017/7/5.
//  Copyright © 2017年 向尉. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<NSStreamDelegate>

@end

@implementation ViewController

-(void)initNetworkCommunication
{
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStraem;
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"192.168.100.187", PORT, &readStream, &writeStraem);
    _inputStream =(__bridge_transfer NSInputStream *)readStream;
    _outputStream=(__bridge_transfer NSOutputStream *)writeStraem;
    [_inputStream setDelegate:self];
    [_outputStream setDelegate:self];
    [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_inputStream open];
    [_outputStream open];
}

-(IBAction)sendData:(id)sender
{
    _flag=0;
    [self initNetworkCommunication];
}

-(IBAction)receiveData:(id)sender
{
    _flag=1;
    [self initNetworkCommunication];
}

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
                _message.text=resultString;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self initNetworkCommunication];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
