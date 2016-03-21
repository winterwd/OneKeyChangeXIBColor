//
//  WDColorModel.m
//  OneKeyChangeXIBColor
//
//  Created by winter on 16/3/21.
//  Copyright © 2016年 winter. All rights reserved.
//

#import "WDColorModel.h"

@implementation WDColorModel

+ (WDColorModel *)colorModelWithArray:(NSArray<NSXMLNode *> *)array
{
     WDColorModel *model = [[WDColorModel alloc] init];
    for (NSXMLNode *node in array) {
        if ([node.name isEqualToString:@"key"]) {
            model.key = node.stringValue;
        }
        else if ([node.name isEqualToString:@"colorSpace"]) {
            model.colorSpace = node.stringValue;
        }
        else if ([node.name isEqualToString:@"alpha"]) {
            model.alpha = node.stringValue;
        }
        else if ([node.name isEqualToString:@"red"]) {
            model.red = [NSString stringWithFormat:@"%.4f",[node.stringValue floatValue]];
        }
        else if ([node.name isEqualToString:@"green"]) {
            model.green = [NSString stringWithFormat:@"%.4f",[node.stringValue floatValue]];
        }
        else if ([node.name isEqualToString:@"blue"]) {
            model.blue = [NSString stringWithFormat:@"%.4f",[node.stringValue floatValue]];
        }
    }
    return model;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"key:%@\nred:%@\ngreen:%@\nblue:%@",self.key,self.red,self.green,self.blue];
}

- (BOOL)isEqual:(WDColorModel *)object
{
    NSString *selfValue = [NSString stringWithFormat:@"red:%@_green:%@_blue:%@",self.red,self.green,self.blue];
    NSString *objValue = [NSString stringWithFormat:@"red:%@_green:%@_blue:%@",object.red,object.green,object.blue];
    
    if ([selfValue isEqualToString:objValue]) {
        return YES;
    }
    return NO;
}
@end
