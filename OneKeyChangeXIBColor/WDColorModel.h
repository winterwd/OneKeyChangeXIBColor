//
//  WDColorModel.h
//  OneKeyChangeXIBColor
//
//  Created by winter on 16/3/21.
//  Copyright © 2016年 winter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDColorModel : NSObject

@property (nonatomic, copy) NSString *red;
@property (nonatomic, copy) NSString *green;
@property (nonatomic, copy) NSString *blue;

@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *alpha;
@property (nonatomic, copy) NSString *colorSpace;

+ (WDColorModel *)colorModelWithArray:(NSArray<NSXMLNode *> *)array;

@end
