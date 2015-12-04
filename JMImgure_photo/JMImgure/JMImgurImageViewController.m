//
//  JMImgurImageViewController.m
//  JMImgure
//
//  Created by JackMa on 15/11/29.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import "JMImgurImageViewController.h"
#import "RWTSavedImageService.h"
#import "UIImageView+WebCache.h"

@interface JMImgurImageViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIProgressView *progressView;

@end

@implementation JMImgurImageViewController

- (void)saveImage:(UIBarButtonItem *)buttonItem {
  self.navigationItem.rightBarButtonItem.enabled = NO;
  RWTSavedImageService *savedImageService = [[RWTSavedImageService alloc] init];
  [savedImageService saveImage:self.imageView.image name:self.imgurImage.imgurId];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  __weak typeof(JMImgurImageViewController *) weakSelf = self;
  [self.imageView sd_setImageWithURL:self.imgurImage.link placeholderImage:nil options:kNilOptions progress:^(NSInteger receivedSize, NSInteger expectedSize) {
    float progress = (float)receivedSize/(float)expectedSize;
    dispatch_async(dispatch_get_main_queue(), ^{
      [weakSelf.progressView setProgress:progress animated:YES];
    });
  } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    if (error) {
      NSLog(@"Error loading image at %@: %@", weakSelf.imgurImage.link.absoluteString, error);
    }
    weakSelf.progressView.hidden = YES;
    weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
  }];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  //设置title和右边的保存按钮
  self.title = self.imgurImage.title;
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveImage:)];
  self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
