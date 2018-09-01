//
//  WDColorModel.h
//  OneKeyChangeXIBColor
//
//  Created by winter on 16/3/21.
//  Copyright © 2016年 winter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ColorValue : NSObject
@property (nonatomic, assign) CGFloat redValue;
@property (nonatomic, assign) CGFloat greenValue;
@property (nonatomic, assign) CGFloat blueValue;

@property (nonatomic, copy) NSString *red;
@property (nonatomic, copy) NSString *green;
@property (nonatomic, copy) NSString *blue;

@property (nonatomic, readonly) BOOL hasValue;
- (void)clearValue;
@end

@interface WDColorModel : NSObject

@property (nonatomic, strong) ColorValue *color;

// RGB小数
@property (nonatomic, assign) CGFloat redValue;
@property (nonatomic, assign) CGFloat greenValue;
@property (nonatomic, assign) CGFloat blueValue;


@property (nonatomic, copy) NSString *red;
@property (nonatomic, copy) NSString *green;
@property (nonatomic, copy) NSString *blue;

@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *alpha;
@property (nonatomic, copy) NSString *colorSpace;
@property (nonatomic, copy) NSString *customColorSpace;

+ (WDColorModel *)colorModelWithArray:(NSArray<NSXMLNode *> *)array;
@end
