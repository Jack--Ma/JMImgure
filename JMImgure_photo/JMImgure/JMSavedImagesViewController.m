//
//  JMSavedImagesViewController.m
//  JMImgure
//
//  Created by JackMa on 15/11/29.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import "JMSavedImagesViewController.h"
#import "RWTSavedImageService.h"
#import "JMImageCollectionViewCell.h"
#import "JMImageViewController.h"

@interface JMSavedImagesViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *savedImagesCollectionView;
@property (nonatomic, strong) RWTSavedImageService *savedImageService;
@property (nonatomic, strong) NSArray *imageFileNames;

@end

@implementation JMSavedImagesViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.savedImagesCollectionView.backgroundColor = [UIColor whiteColor];
  self.savedImagesCollectionView.dataSource = self;
  self.savedImagesCollectionView.delegate = self;
  self.savedImageService = [[RWTSavedImageService alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  NSArray *imageFile = [self.savedImageService savedImageFileNames];
  NSMutableArray *tempImageFile = [NSMutableArray arrayWithCapacity:imageFile.count];
  for (int i = 0; i < imageFile.count; i++) {
    NSString *temp = [NSString stringWithFormat:@"%@/%@.jpg", imageFile[i], imageFile[i]];
    if (![temp hasPrefix:@"."]) {
      [tempImageFile addObject:temp];
    }
  }
  self.imageFileNames = [NSArray arrayWithArray:tempImageFile];
  [self.savedImagesCollectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"ViewImage"]) {
    JMImageCollectionViewCell *cell = sender;
    JMImageViewController *imageViewController = segue.destinationViewController;
    imageViewController.image = cell.image;
    
  }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return self.imageFileNames.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  JMImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
  NSString *fileName = self.imageFileNames[indexPath.row];
  cell.image = [self.savedImageService imageNamed:fileName];
  
  return cell;
}
@end
