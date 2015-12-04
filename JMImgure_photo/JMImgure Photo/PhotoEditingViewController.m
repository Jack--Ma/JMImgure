//
//  PhotoEditingViewController.m
//  JMImgure Photo
//
//  Created by JackMa on 15/12/3.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import "PhotoEditingViewController.h"
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
#import "RWTImageFilterService.h"

@interface PhotoEditingViewController () <PHContentEditingController>

@property (strong) PHContentEditingInput *input;

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIButton *undoButton;
@property (nonatomic, weak) IBOutlet UIButton *addButton;

@property (strong, nonatomic) RWTImageFilterService *imageFilterService;
@property (strong, nonatomic) NSString *currentFilterName;
@property (strong, nonatomic) UIImage *filteredImage;

@end

@implementation PhotoEditingViewController

//撤销的button
- (IBAction)undo:(id)sender {
  self.imageView.image = self.input.displaySizeImage;
  self.currentFilterName = nil;
  self.filteredImage = nil;
}

//添加过滤器
- (IBAction)addFilter:(id)sender {
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"过滤器" message:@"请选择一种过滤器" preferredStyle:UIAlertControllerStyleActionSheet];
  //遍历字典
  [self.imageFilterService.availableFilters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
    UIAlertAction *action = [UIAlertAction actionWithTitle:key style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
      //为图片添加过滤
      self.filteredImage = [self.imageFilterService applyFilter:obj toImage:self.input.displaySizeImage];
      self.imageView.image = self.filteredImage;
      self.currentFilterName = obj;
    }];
    [alert addAction:action];
  }];
  UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    [alert dismissViewControllerAnimated:YES completion:nil];
  }];
  [alert addAction:cancel];
  [self presentViewController:alert animated:YES completion:nil];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.imageView.contentMode = UIViewContentModeScaleAspectFit;
  self.imageFilterService = [[RWTImageFilterService alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PHContentEditingController

//在原始编辑界面可以对图片进行调整，当你在这个App想获取的是最原始的图片，那么返回NO
//你想获取调整后的adjustmentData的话，那么返回YES
//只有图片经过调整才会调用此函数，否则默认NO
- (BOOL)canHandleAdjustmentData:(PHAdjustmentData *)adjustmentData {
  return NO;
}

//view Load后，view appear前调用，用来接受原始数据contentEditingInput
- (void)startContentEditingWithInput:(PHContentEditingInput *)contentEditingInput placeholderImage:(UIImage *)placeholderImage {
  //canHandleAdjustmentData:返回YES的话，这里的contentEditingInput也会带上adjustmentData
  //canHandleAdjustmentData:返回NO的话，这里只有原始图像displaySizeImage
  self.input = contentEditingInput;
  self.imageView.image = self.input.displaySizeImage;//将原始图片呈现出来
}

//点击右上方完成button时调用
- (void)finishContentEditingWithCompletionHandler:(void (^)(PHContentEditingOutput *))completionHandler {
  //异步处理图片
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      //创建output并设置
      PHContentEditingOutput *output = [[PHContentEditingOutput alloc] initWithContentEditingInput:self.input];
      NSData *archiveData = [NSKeyedArchiver archivedDataWithRootObject:self.currentFilterName];
#warning Please set your Photos Extension Name and Version here
      PHAdjustmentData *adjustmentData = [[PHAdjustmentData alloc] initWithFormatIdentifier:@"qq100858433.JMImgure.JMImgure-Photo" formatVersion:@"1.0" data:archiveData];
      output.adjustmentData = adjustmentData;
      
      UIImage *fullImage = [UIImage imageWithContentsOfFile:self.input.fullSizeImageURL.path];
      fullImage = [self.imageFilterService applyFilter:self.currentFilterName toImage:fullImage];
      
      //将转化后的图片存到renderedContentURL中
      NSData *jpegData = UIImageJPEGRepresentation(fullImage, 1.0);
      BOOL saved = [jpegData writeToURL:output.renderedContentURL options:NSDataWritingAtomic error:nil];
      if (saved) {
        //回调处理结果给Photos
        //注：这里模拟机调试会出现无法显示修改后图片问题，真机调试没有问题
        completionHandler(output);
      } else {
        NSLog(@"An error occurred during save");
        completionHandler(nil);
      }
      // Clean up temporary files, etc.
    });
}

//点击左上方取消后调用
- (BOOL)shouldShowCancelConfirmation {
  //返回YES，则会弹出AlertSheet让用户确认是否取消
  //返回NO，则页面直接消失
  return NO;
}

//shouldShowCancelConfirmation或finishContentEditingWithCompletionHandler:
//之后调用，此函数在后台运行，负责清理临时文件
- (void)cancelContentEditing {
    // Clean up temporary files, etc.
    // May be called after finishContentEditingWithCompletionHandler: while you prepare output.
}

@end
