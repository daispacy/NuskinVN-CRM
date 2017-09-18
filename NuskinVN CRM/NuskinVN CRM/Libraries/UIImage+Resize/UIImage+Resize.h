//
//  UIImage+Resize.h
//  HungryGoWhere
//
//  Created by Linh Le on 11/25/12.
//  Copyright (c) 2012 Linh Le. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PhotoResizedInfo;

@interface UIImage (UIImage_Resize)

+(PhotoResizedInfo *)imageWithImage:(UIImage*)image scaledToMaxSize:(CGSize)maxSize maxBytesLength:(NSInteger)maxBytesLength extension:(NSString*)extension;
- (UIImage *)imageScaledToFillSize:(CGSize)size;
+ (UIImage *) imageFromAttribute:(NSAttributedString *)text withSize:(CGSize) size;
- (UIImage *)resizedImage:(CGSize)newSize
     interpolationQuality:(CGInterpolationQuality)quality;
@end
