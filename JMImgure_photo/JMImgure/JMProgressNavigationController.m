//
//  JMProgressNavigationController.m
//  JMImgure
//
//  Created by JackMa on 15/11/29.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import "JMProgressNavigationController.h"

@interface JMProgressNavigationController ()

@end

@implementation JMProgressNavigationController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
  self.progressView.hidden = YES;
  [self.view addSubview:self.progressView];
  
  NSArray *verticalConstraints = [NSLayoutConstraint
                                  constraintsWithVisualFormat:@"V:[navigationBar]-[progressView(2@20)]"
                                  options:NSLayoutFormatDirectionLeadingToTrailing
                                  metrics:nil
                                  views:@{@"progressView": self.progressView, @"navigationBar": self.navigationBar}];
  
  NSArray *horizontalConstraints = [NSLayoutConstraint
                                    constraintsWithVisualFormat:@"H:|[progressView]|"
                                    options:NSLayoutFormatDirectionLeadingToTrailing
                                    metrics:nil
                                    views:@{@"progressView": self.progressView}];
  
  [self.view addConstraints:verticalConstraints];
  [self.view addConstraints:horizontalConstraints];
  
  [self.progressView setTranslatesAutoresizingMaskIntoConstraints:NO];
  [self.progressView setProgress:0 animated:NO];
}


@end
