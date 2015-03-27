//
//  ViewController.m
//  dwonloadYoutubeVedio
//
//  Created by Jeffery on 2015/3/26.
//  Copyright (c) 2015年 jeffery. All rights reserved.
//

#import "ViewController.h"

#import "CMCHTTPRequest.h"

#import <HCYoutubeParser/HCYoutubeParser.h>

#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *vedioKeyTextField;
@property (weak, nonatomic) IBOutlet UIView *videoView;

@property (strong, nonatomic) AVPlayerViewController *playerViewController;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.playerViewController = [[AVPlayerViewController alloc] init];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.playerViewController.view setFrame:self.videoView.bounds];
    [self.videoView addSubview:self.playerViewController.view];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [HCYoutubeParser detailsForYouTubeURL:[NSURL URLWithString:textField.text] completeBlock:^(NSDictionary *details, NSError *error) {
        NSLog(@"details = %@",details);
    }];
    
    [HCYoutubeParser h264videosWithYoutubeURL:[NSURL URLWithString:textField.text] completeBlock:^(NSDictionary *videoDictionary, NSError *error) {
        NSLog(@"videoDictionary = %@",videoDictionary);
        
        //http://stackoverflow.com/questions/8372661/how-to-download-a-file-and-save-it-to-the-documents-directory-with-afnetworking
        
//        videoDictionary[@"hd720"]
//        videoDictionary[@"small"]
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:videoDictionary[@"small"]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0f];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"filename.mov"];
        operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];

        
        [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            NSLog(@"totalBytesRead = %@",@(totalBytesRead));
            NSLog(@"bytesRead = %@",@(bytesRead));
            NSLog(@"totalBytesExpectedToRead = %@",@(totalBytesExpectedToRead));
        }];
        
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//            NSData *data = [[NSData alloc] initWithData:responseObject];
            
            NSLog(@"Successfully downloaded file to %@", path);
            
//            NSString *docDir1 = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,   NSUserDomainMask, YES) objectAtIndex:0];
//            
//            NSString *myfilepath = [docDir1 stringByAppendingPathComponent:@"filename.mov"];
//            
//            NSLog(@"url:%@",myfilepath);
            
            AVPlayer *player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:path]];
            
            NSLog(@"player:%@",player);
            self.playerViewController.player = player;
            
            [self.playerViewController.player addObserver:self forKeyPath:@"status" options:0 context:nil];
            [self.playerViewController.player play];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSLog(@"error.description = %@",error.description);
        }];
        [operation start];
    }];
    
    [textField resignFirstResponder];
    return YES;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.playerViewController.player && [keyPath isEqualToString:@"status"])
    {
        if (self.playerViewController.player.status == AVPlayerStatusFailed)
        {
            NSLog(@"AVPlayer Failed");
        }
        else if (self.playerViewController.player.status == AVPlayerStatusReadyToPlay)
        {
            NSLog(@"AVPlayerStatusReadyToPlay");
            [self.playerViewController.player play];
        }
        else if (self.playerViewController.player.status == AVPlayerItemStatusUnknown)
        {
            NSLog(@"AVPlayer Unknown");
        }
    }
}

@end
