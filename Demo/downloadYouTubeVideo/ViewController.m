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
@property (weak, nonatomic) IBOutlet UILabel *statusLbl;
@property (weak, nonatomic) IBOutlet UIProgressView *progrssBar;

@property (strong, nonatomic) AVPlayerViewController *playerViewController;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.playerViewController = [[AVPlayerViewController alloc] init];
    
    [self.progrssBar setProgress:0];
    self.statusLbl.text = @"";
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
    [self.progrssBar setProgress:0];
    self.statusLbl.text = @"";
    
//    [HCYoutubeParser detailsForYouTubeURL:[NSURL URLWithString:textField.text] completeBlock:^(NSDictionary *details, NSError *error) {
//        NSLog(@"details = %@",details);
//    }];
    
    [HCYoutubeParser h264videosWithYoutubeURL:[NSURL URLWithString:textField.text] completeBlock:^(NSDictionary *videoDictionary, NSError *error) {
        NSLog(@"videoDictionary = %@",videoDictionary);
        
        //http://stackoverflow.com/questions/8372661/how-to-download-a-file-and-save-it-to-the-documents-directory-with-afnetworking
        if ([[videoDictionary objectForKey:kYoutubeInfoStatus] isEqualToString:vYoutubeStatusOK]) {
            
            NSString *URLString;
            NSString *VideoLiveURLString;
            if ([videoDictionary objectForKey:kYoutubeVideoHD720] != nil) {
                URLString = [videoDictionary objectForKey:kYoutubeVideoHD720];
            } else if ([videoDictionary objectForKey:kYoutubeVideoMedium] != nil) {
                URLString = [videoDictionary objectForKey:kYoutubeVideoMedium];
            } else if ([videoDictionary objectForKey:kYoutubeVideoSmall] != nil) {
                URLString = [videoDictionary objectForKey:kYoutubeVideoSmall];
            } else if ([videoDictionary objectForKey:kYoutubeVideoLive] != nil) {
                VideoLiveURLString = [videoDictionary objectForKey:kYoutubeVideoLive];
            } else {
                self.statusLbl.text = @"Couldn't find youtube video";
            }
            
            if (URLString) {
                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0f];
                
                AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"filename.mov"];
                operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
                
                [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                    float progress = (float)totalBytesRead / (float)totalBytesExpectedToRead;
                    
                    [self.progrssBar setProgress:progress animated:YES];
                }];
                
                [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
                    AVPlayer *player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:path]];
                    
                    NSLog(@"player:%@",player);
                    self.playerViewController.player = player;
                    
                    [self.playerViewController.player addObserver:self forKeyPath:@"status" options:0 context:nil];
                    [self.playerViewController.player play];
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    self.statusLbl.text = error.description;
                }];
                [operation start];
            } else if (VideoLiveURLString) {
                AVPlayer *player = [AVPlayer playerWithURL:[NSURL URLWithString:VideoLiveURLString]];
                
                NSLog(@"player:%@",player);
                self.playerViewController.player = player;
                
                [self.playerViewController.player addObserver:self forKeyPath:@"status" options:0 context:nil];
                [self.playerViewController.player play];
            
            }
            
        } else {
            NSString *YoutubeErrorReason = [videoDictionary objectForKey:kYoutubeErrorReason];
            self.statusLbl.text = YoutubeErrorReason;
        }
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
