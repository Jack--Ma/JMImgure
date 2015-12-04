/*
 * Copyright (c) 2014 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import <Foundation/Foundation.h>
@import UIKit;

@class RWTImgurImage;

typedef void (^RWTImgurGalleryCompletion) (NSArray *images, NSError *error);
typedef void (^RWTImgurUploadCompletion) (RWTImgurImage *image, NSError *error);
typedef void (^RWTImgurProgressCallback) (float progress);

@interface RWTImgurService : NSObject <NSURLSessionDelegate>

@property (strong, nonatomic) NSURLSession *session;

+ (void)setClientId:(NSString *)clientId;

+ (instancetype)sharedInstance;

- (void)hotViralGalleryThumbnailImagesPage:(NSInteger)page completion:(RWTImgurGalleryCompletion)completion;

- (void)uploadImage:(UIImage *)image title:(NSString *)title completion:(RWTImgurUploadCompletion)completion progressCallback:(RWTImgurProgressCallback)progressCallback;

- (void)uploadImage:(UIImage *)image session:(NSURLSession *)session title:(NSString *)title completion:(RWTImgurUploadCompletion)completion progressCallback:(RWTImgurProgressCallback)progressCallback;


@end
