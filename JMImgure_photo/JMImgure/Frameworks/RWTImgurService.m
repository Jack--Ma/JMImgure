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

#import "RWTImgurService.h"
#import "RWTImgurImage.h"
#import "RWTSavedImageService.h"
#import <AFNetworking/AFNetworking.h>

static NSString *imgurClientId = nil;

static NSString * const kRWTImgurServiceAPIBaseURLString = @"https://api.imgur.com/3/";

@interface RWTImgurService () <NSURLSessionTaskDelegate>

@property (strong, nonatomic) NSMutableDictionary *progressCallbacks;
@property (strong, nonatomic) NSMutableDictionary *completionCallbacks;

@end

@implementation RWTImgurService

+ (void)setClientId:(NSString *)clientId {
  imgurClientId = clientId;
}

+ (instancetype)sharedInstance {
  static dispatch_once_t onceToken;
  static RWTImgurService *sharedInstance;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[self alloc] init];
  });
  
  return sharedInstance;
}

- (instancetype)init {
  self = [super init];
  if (!self) {
    return nil;
  }
  
  _progressCallbacks = [NSMutableDictionary dictionary];
  _completionCallbacks = [NSMutableDictionary dictionary];
  
  NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
  
  NSString *clientIdString = [NSString stringWithFormat:@"Client-ID %@", imgurClientId];
  
  [configuration setHTTPAdditionalHeaders:@{@"Authorization" : clientIdString,
                                            @"Content-Type" : @"application/json"}];
  
  _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
  
  return self;
}

- (void)hotViralGalleryThumbnailImagesPage:(NSInteger)page completion:(RWTImgurGalleryCompletion)completion  {
  NSString *urlString = [NSString stringWithFormat:@"gallery/hot/viral/%ld", page];
  NSURL *url = [self imgurAPIUrlWithPathComponents:urlString];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
  operation.responseSerializer = [AFJSONResponseSerializer serializer];
  [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
    NSDictionary *dict = responseObject;
    NSArray *imagesResponse = dict[@"data"];
    NSMutableArray *images = [NSMutableArray array];
    for (NSDictionary *imageDict in imagesResponse) {
      if (![imageDict[@"is_album"] boolValue]) { // no album support
        RWTImgurImage *image = [[RWTImgurImage alloc] initWithDictionary:imageDict];
        [images addObject:image];
      }
    }
    
    completion(images, nil);
  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    NSLog(@"====%@", [error userInfo]);
  }];
  [operation start];
//  
//  NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//    NSError *jsonError;
//    NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data
//                                                                 options:NSJSONReadingAllowFragments
//                                                                   error:&jsonError];
//    NSArray *imagesResponse = responseDict[@"data"];
//    
//    NSMutableArray *images = [NSMutableArray array];
//    for (NSDictionary *imageDict in imagesResponse) {
//      if (![imageDict[@"is_album"] boolValue]) { // no album support
//        RWTImgurImage *image = [[RWTImgurImage alloc] initWithDictionary:imageDict];
//        [images addObject:image];
//      }
//    }
//    
//    completion(images, error);
//  }];
//  
//  [task resume];
}

- (void)uploadImage:(UIImage *)image title:(NSString *)title completion:(RWTImgurUploadCompletion)completion progressCallback:(RWTImgurProgressCallback)progressCallback {
  [self uploadImage:image session:self.session title:title completion:completion progressCallback:progressCallback];
}

- (void)uploadImage:(UIImage *)image session:(NSURLSession *)session title:(NSString *)title completion:(RWTImgurUploadCompletion)completion progressCallback:(RWTImgurProgressCallback)progressCallback {
  
  NSURLSession *sessionToUse;
  if (session != nil) {
    sessionToUse = session;
  } else {
    sessionToUse = self.session;
  }
  
  NSURL *url = [NSURL URLWithString:@"http://api.imgur.com/3/upload"];
//  NSURL *url = [self imgurAPIUrlWithPathComponents:@"image"];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  request.HTTPMethod = @"POST";
  NSDictionary *postBody = @{@"title": title};
  
  NSError *jsonError;
  NSData *jsonPostBody = [NSJSONSerialization dataWithJSONObject:postBody options:kNilOptions error:&jsonError];
  request.HTTPBody = jsonPostBody;
  
  
  RWTSavedImageService *savedImageService = [[RWTSavedImageService alloc] init];
  NSString *uuidString = [[NSUUID UUID] UUIDString];
  
  NSURL *imageToUploadUrl = [savedImageService saveImageToUpload:image name:uuidString];
  
//  NSURLSessionUploadTask *task = [sessionToUse uploadTaskWithRequest:request fromFile:imageToUploadUrl];
  NSURLSessionUploadTask *task = [sessionToUse uploadTaskWithRequest:request fromFile:imageToUploadUrl completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    if (error) {
      NSLog(@"%@", [error userInfo]);
    } else {
      NSLog(@"%@", data);
    }
  }];
  
  if (completion) {
    [self.completionCallbacks setObject:[completion copy] forKey:task];
  }
  
  if (progressCallback) {
    [self.progressCallbacks setObject:[progressCallback copy] forKey:task];
  }
  
  [task resume];
}

- (NSURL *)imgurAPIUrlWithPathComponents:(NSString *)components {
  NSURL *baseURL = [NSURL URLWithString:kRWTImgurServiceAPIBaseURLString];
  NSURL *apiURL = [NSURL URLWithString:components relativeToURL:baseURL];
  
  return apiURL;
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
  RWTImgurProgressCallback progressCallback = [self.progressCallbacks objectForKey:task];
  if (progressCallback) {
    float progress = (float)totalBytesSent/(float)totalBytesExpectedToSend;
    progressCallback(progress);
    if (totalBytesSent == totalBytesExpectedToSend) {
      [self.progressCallbacks removeObjectForKey:task];
    }
  }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
  RWTImgurProgressCallback progressCallback = [self.progressCallbacks objectForKey:task];
  if (progressCallback) {
    [self.progressCallbacks removeObjectForKey:task];
  }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
  
  RWTImgurUploadCompletion completion = self.completionCallbacks[dataTask];
  if (completion != nil) {
    NSError *jsonError;
    NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
    if (!jsonError) {
      RWTImgurImage *imgurImage = [[RWTImgurImage alloc] initWithDictionary:responseDict[@"data"]];
      [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        completion(imgurImage, nil);
      }];
    } else {
      [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        completion(nil, jsonError);
      }];
    }
  }
}

@end
