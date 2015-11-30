//
//  JMHotGalleryViewController.m
//  JMImgure
//
//  Created by JackMa on 15/11/29.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import "JMHotGalleryViewController.h"
#import "RWTImgurImage.h"
#import "RWTImgurService.h"
#import "JMProgressNavigationController.h"
#import "JMImageCollectionViewCell.h"
#import "JMImgurImageViewController.h"

@interface JMHotGalleryViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *imagesCollectionView;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) NSArray *images;

@end

@implementation JMHotGalleryViewController

- (IBAction)share:(id)sender {
  UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
  pickerController.delegate = self;
  pickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
  [self presentViewController:pickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
  UIImage *selectedImage = info[UIImagePickerControllerOriginalImage];
  [self dismissViewControllerAnimated:YES completion:nil];
  
  [[RWTImgurService sharedInstance] uploadImage:selectedImage title:@"Objc" completion:^(RWTImgurImage *image, NSError *error) {
    if (!error) {
      NSString *message = [NSString stringWithFormat:@"URL: %@", image.link.absoluteString];
      UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"上传成功"
                                                                     message:message
                                                              preferredStyle:UIAlertControllerStyleAlert];
      UIAlertAction *openAction = [UIAlertAction actionWithTitle:@"查看图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:image.link];
      }];
      UIAlertAction *copyAction = [UIAlertAction actionWithTitle:@"拷贝链接" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [UIPasteboard generalPasteboard].URL = image.link;
      }];
      [alert addAction:openAction];
      [alert addAction:copyAction];
      [self presentViewController:alert animated:YES completion:nil];
      
      self.progressView.hidden = YES;
      [self.progressView setProgress:0 animated:NO];
    } else {
      NSLog(@"Upload error: %@", [error userInfo]);
      self.progressView.hidden = YES;
    }
  } progressCallback:^(float progress) {
    if (progress > 0) {
      self.progressView.hidden = NO;
      [self.progressView setProgress:progress animated:YES];
    }
  }];
}
#pragma mark - 初始化
- (void)viewDidLoad {
  [super viewDidLoad];
  JMProgressNavigationController *navigationController = (JMProgressNavigationController *)self.navigationController;
  self.progressView = navigationController.progressView;
  self.progressView.hidden = YES;
  
  self.imagesCollectionView.backgroundColor = [UIColor whiteColor];
  self.imagesCollectionView.delegate = self;
  self.imagesCollectionView.dataSource = self;
  
  //获取当日热门图片
  __weak typeof(JMHotGalleryViewController *) weakSelf = self;
  [[RWTImgurService sharedInstance] hotViralGalleryThumbnailImagesPage:0 completion:^(NSArray *images, NSError *error) {
    if (!error) {
      weakSelf.images = images;
      dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.imagesCollectionView reloadData];
      });
    } else {
      NSLog(@"Error fetching hot images: %@", [error userInfo]);
    }
  }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource && UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return self.images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  JMImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
  cell.imgurImage = self.images[indexPath.row];
  return cell;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"ViewImage"]) {
    JMImgurImageViewController *imageViewController = segue.destinationViewController;
    JMImageCollectionViewCell *cell = sender;
    NSIndexPath *indexPath = [self.imagesCollectionView indexPathForCell:cell];
    imageViewController.imgurImage = self.images[indexPath.row];
  }
}

@end
