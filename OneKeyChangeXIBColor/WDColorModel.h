//
//  WDColorModel.h
//  OneKeyChangeXIBColor
//
//  Created by winter on 16/3/21.
//  Copyright © 2016年 winter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ColorValue : NSObject
@property (nonatomic, assign) CGFloat red;
@property (nonatomic, assign) CGFloat green;
@property (nonatomic, assign) CGFloat blue;

@property (nonatomic, copy) NSString *redString;
@property (nonatomic, copy) NSString *greenString;
@property (nonatomic, copy) NSString *blueString;
@end

@interface WDColorModel : NSObject

@property (nonatomic, strong) ColorValue *color;

@property (nonatomic, copy) NSString *red;
@property (nonatomic, copy) NSString *green;
@property (nonatomic, copy) NSString *blue;

@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *alpha;
@property (nonatomic, copy) NSString *colorSpace;

+ (WDColorModel *)colorModelWithArray:(NSArray<NSXMLNode *> *)array;

@end
