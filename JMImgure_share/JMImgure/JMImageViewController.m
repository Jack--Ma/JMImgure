//
//  JMImageViewController.m
//  JMImgure
//
//  Created by JackMa on 15/11/29.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import "JMImageViewController.h"
#import "RWTSavedImageService.h"
#import "RWTImageFilterService.h"

@interface JMImageViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) RWTImageFilterService *filterService;
@property (nonatomic, strong) UIImage *filteredImage;

@end

@implementation JMImageViewController

- (void)addFilter:(UIBarButtonItem *)sender {
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"添加过滤" message:@"选择一种过滤器" preferredStyle:UIAlertControllerStyleActionSheet];
  
  //遍历所有的过滤器，显示到每一个ActionView上
  __weak typeof(JMImageViewController *) weakSelf = self;
  [self.filterService.availableFilters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
    NSString *displayName = key;
    NSString *filterName = obj;
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:displayName style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
      weakSelf.filteredImage = [weakSelf.filterService applyFilter:filterName toImage:weakSelf.image];
      [weakSelf.imageView setImage:weakSelf.filteredImage];
    }];
    [alert addAction:action];
  }];
  
  UIAlertAction *noneAction = [UIAlertAction actionWithTitle:@"None" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    [weakSelf.imageView setImage:weakSelf.image];
  }];
  [alert addAction:noneAction];
  
  [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 初始化
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self.imageView setImage:self.image];
  
  UIBarButtonItem *addFilterBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"添加过滤" style:UIBarButtonItemStylePlain target:self action:@selector(addFilter:)];
  self.navigationItem.rightBarButtonItem = addFilterBarButtonItem;
  
  self.filterService = [[RWTImageFilterService alloc] init];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

@end
