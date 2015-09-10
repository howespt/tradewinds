//
//  UIColor+Tradewinds.m
//  Tradewinds
//
//  Created by Phil Howes on 30/05/2015.
//  Copyright (c) 2015 Phil Howes. All rights reserved.
//

#import "UIColor+Tradewinds.h"

@implementation UIColor (Tradewinds)

+ (UIColor *)availableGreen {
  return [self colorWithHexString:@"#2ecc71"];
}

+ (UIColor *)reservedRed {
  return [self colorWithHexString:@"#e74c3c"];
}

+ (UIColor *)tradewindsGray {
  return [self colorWithHexString:@"#607D8B"];
}

+ (UIColor *)tradewindsBackgroundGray {
  return [self colorWithHexString:@"#FAFAFA"];
}

// takes @"#123456"
+ (UIColor *)colorWithHexString:(NSString *)str {
  const char *cStr = [str cStringUsingEncoding:NSASCIIStringEncoding];
  long x = strtol(cStr+1, NULL, 16);
  return [self colorWithHex:(UInt32)x];
}

// takes 0x123456
+ (UIColor *)colorWithHex:(UInt32)col {
  unsigned char r, g, b;
  b = col & 0xFF;
  g = (col >> 8) & 0xFF;
  r = (col >> 16) & 0xFF;
  return [UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:1];
}

@end
