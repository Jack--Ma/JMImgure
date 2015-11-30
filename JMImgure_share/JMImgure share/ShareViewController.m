//
//  ShareViewController.m
//  JMImgure Share
//
//  Created by JackMa on 15/11/29.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import "ShareViewController.h"
#import "RWTImgurService.h"
#import "RWTImgurImage.h"

@interface ShareViewController ()

@property (nonatomic, strong) UIImage *image;

@end

@implementation ShareViewController

- (void)viewDidLoad {
#warning 在这里设置你的CLIENT ID
  [RWTImgurService setClientId:@"8a45300c7f22a24"];
  
  //获取inputItems，在这里itemProvider是你要分享的图片
  NSExtensionItem *firstItem = self.extensionContext.inputItems.firstObject;
  NSItemProvider *itemProvider;
  if (firstItem) {
    itemProvider = firstItem.attachments.firstObject;
  }

  //这里的kUTTypeImage代指@"public.image"，也就是从相册获取的图片类型
  if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]) {
    //对itemProvider夹带着的图片进行解析
    [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
      if (!error) {
        NSURL *url = (NSURL *)item;
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        self.image = [UIImage imageWithData:imageData];
      } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"无法加载图片" message:@"请尝试其他图片" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
          [self dismissViewControllerAnimated:YES completion:nil];
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
      }
    }];
  }
}

//设置Post是否有效，当你每次输入内容的时候，都会调用此方法
- (BOOL)isContentValid {
  if (self.image) {
    return YES;
  } else {
    return NO;
  }
}

//设置点击Post后的动作
- (void)didSelectPost {
  [self shareImage];
}

//在这里设置弹出sheet的底部，要求用SLComposeSheetConfigurationItem的对象
- (NSArray *)configurationItems {
  SLComposeSheetConfigurationItem *configItem = [[SLComposeSheetConfigurationItem alloc] init];
  configItem.title = @"链接将被拷贝到剪贴板";
  return @[configItem];
}

- (void)shareImage {
  NSURLSession *defaultSession = [RWTImgurService sharedInstance].session;
  NSURLSessionConfiguration *defaultConfig = defaultSession.configuration;
  NSDictionary *defaultHeaders = defaultConfig.HTTPAdditionalHeaders;
  
  NSURLSessionConfiguration *backgroundConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"group.qq100858433.JMImgvue.backgroundsession"];
  backgroundConfig.sharedContainerIdentifier = @"group.qq100858433.JMImgvue";
  backgroundConfig.HTTPAdditionalHeaders = defaultHeaders;
  
  NSURLSession *backgroundSession = [NSURLSession sessionWithConfiguration:backgroundConfig delegate:[RWTImgurService sharedInstance] delegateQueue:[NSOperationQueue mainQueue]];
  
  [[RWTImgurService sharedInstance] uploadImage:self.image session:backgroundSession title:self.contentText completion:^(RWTImgurImage *image, NSError *error) {
    if (!error) {
      [UIPasteboard generalPasteboard].URL = image.link;
      NSLog(@"Image shared: %@", image.link.absoluteString);
    } else {
      NSLog(@"Error sharing image: %@", error);
    }
  } progressCallback:^(float progress) {
    NSLog(@"Upload progress for extension: %f", progress);
  }];
  
}
@end
