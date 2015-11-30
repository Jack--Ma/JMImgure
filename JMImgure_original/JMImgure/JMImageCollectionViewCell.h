//
//  JMImageCollectionViewCell.h
//  JMImgure
//
//  Created by JackMa on 15/11/29.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RWTImgurImage.h"

@interface JMImageCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) RWTImgurImage *imgurImage;
@property (nonatomic, strong) UIImage *image;

@end
