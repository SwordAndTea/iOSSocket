//
//  ViewController.h
//  TCPClient
//
//  Created by 向尉 on 2017/7/5.
//  Copyright © 2017年 向尉. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <sys/socket.h>
#include <netinet/in.h>

#define PORT 6969

@interface ViewController : UIViewController

@property (nonatomic, assign) NSInteger flag;

@property (nonatomic, retain) NSInputStream *inputStream;

@property (nonatomic, retain) NSOutputStream *outputStream;

@property (weak, nonatomic) IBOutlet UILabel *message;





@end

