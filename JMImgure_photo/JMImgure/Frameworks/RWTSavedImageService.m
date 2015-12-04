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

#import "RWTSavedImageService.h"

@implementation RWTSavedImageService

- (NSArray *)savedImageFileNames {
  NSURL *imagesDirectoryURL = [self imagesDirectoryURL];
  NSError *error;
  NSArray *imageNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:imagesDirectoryURL.path error:&error];
  if (error) {
    NSLog(@"Error loading images");
  }
  
  return imageNames;
}

- (UIImage *)imageNamed:(NSString *)imageName {
  NSURL *imageURL = [self imagesDirectoryURL];
  imageURL = [imageURL URLByAppendingPathComponent:imageName];
  
  UIImage *image = [UIImage imageWithContentsOfFile:imageURL.path];
  return image;
}

- (NSURL *)saveImage:(UIImage *)image name:(NSString *)name {
  return [self saveImageToUpload:image name:name url:[self imagesDirectoryURL]];
}

- (NSURL *)saveImageToUpload:(UIImage *)image name:(NSString *)name {
  return [self saveImageToUpload:image name:name url:[self imagesToUploadDirectoryURL]];
}

- (NSURL *)saveImageToUpload:(UIImage *)image name:(NSString *)name url:(NSURL *)url {
  NSString *temp = [NSString stringWithFormat:@"Images/%@", name];
  NSURL *containerURL = [self URLForDirectoryWithName:temp];
  containerURL = [containerURL URLByAppendingPathComponent:name];
  containerURL = [containerURL URLByAppendingPathExtension:@"jpg"];
  [UIImageJPEGRepresentation(image, 1.0) writeToFile:containerURL.path atomically:YES];

  return containerURL;
}

- (NSURL *)imagesDirectoryURL {
  return [self URLForDirectoryWithName:@"Images"];
}

- (NSURL *)imagesToUploadDirectoryURL {
  return [self URLForDirectoryWithName:@"Uploads"];
}

- (NSURL *)URLForDirectoryWithName:(NSString *)name {
#warning 在这里设置你的APP GROUP ID
  NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.qq100858433.JMImgvue"];
  containerURL = [containerURL URLByAppendingPathComponent:name];
  
  if (![[NSFileManager defaultManager] fileExistsAtPath:containerURL.path]) {
    [[NSFileManager defaultManager] createDirectoryAtURL:containerURL withIntermediateDirectories:NO attributes:nil error:nil];
  }
  
  return containerURL;
}


@end
