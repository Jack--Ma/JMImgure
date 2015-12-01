//
//  ShareViewController.m
//  JMImgure Share
//
//  Created by JackMa on 15/11/29.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import "ShareViewController.h"

@interface ShareViewController ()

@property (nonatomic, strong) UIImage *image;

@end

@implementation ShareViewController

- (void)viewDidLoad {
  //获取inputItems，在这里itemProvider是你要分享的图片
  NSExtensionItem *firstItem = self.extensionContext.inputItems.firstObject;
  NSItemProvider *itemProvider;
  if (firstItem) {
    itemProvider = firstItem.attachments.firstObject;
  }

  //这里的kUTTypeImage代指@"public.image"，也就是从相册获取的图片类型
  //这里的kUTTypeURL代指网站链接，如在Safari中打开，则应该拷贝保存当前网页的链接
  if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]) {
    [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeURL options:nil completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
      if (!error) {
        //对itemProvider夹带着的URL进行解析
        NSURL *url = (NSURL *)item;
        [UIPasteboard generalPasteboard].URL = url;
      }
    }];
  }
  if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]) {
    [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
      if (!error) {
        //对itemProvider夹带着的图片进行解析
        NSURL *url = (NSURL *)item;
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        self.image = [UIImage imageWithData:imageData];
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
  configItem.value = @"链接将被拷贝到剪贴板";
  return @[configItem];
}

- (void)shareImage {
  //在这里写图片上传的代码
  [self.extensionContext completeRequestReturningItems:@[] completionHandler:^(BOOL expired) {
    NSLog(@"%d", expired);
  }];
}
@end
