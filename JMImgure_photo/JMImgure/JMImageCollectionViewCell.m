//
//  JMImageCollectionViewCell.m
//  JMImgure
//
//  Created by JackMa on 15/11/29.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import "JMImageCollectionViewCell.h"
#import "UIImageView+WebCache.h"

@interface JMImageCollectionViewCell ()

@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@end

@implementation JMImageCollectionViewCell

- (void)setImgurImage:(RWTImgurImage *)imgurImage {
  _imgurImage = imgurImage;
  [self.imageView sd_setImageWithURL:_imgurImage.largeThumbnailLink placeholderImage:nil];
}

- (void)setImage:(UIImage *)image {
  _image = image;
  [self.imageView setImage:_image];
}
@end
