//
//  WDColorModel.m
//  OneKeyChangeXIBColor
//
//  Created by winter on 16/3/21.
//  Copyright © 2016年 winter. All rights reserved.
//

#import "WDColorModel.h"

@implementation WDColorModel

+ (WDColorModel *)colorModelWithArray:(NSArray<NSXMLNode *> *)array {
    
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
        else if ([node.name isEqualToString:@"customColorSpace"]) {
            model.customColorSpace = node.stringValue;
        }
        else if ([node.name isEqualToString:@"red"]) {
            CGFloat tempValue = [node.stringValue floatValue];
            model.redValue = tempValue;
            model.red = node.stringValue;
        }
        else if ([node.name isEqualToString:@"green"]) {
            CGFloat tempValue = [node.stringValue floatValue];
            model.greenValue = tempValue;
            model.green = node.stringValue;
        }
        else if ([node.name isEqualToString:@"blue"]) {
            CGFloat tempValue = [node.stringValue floatValue];
            model.blueValue = tempValue;
            model.blue  = node.stringValue;
        }
    }
    return model;
}

- (void)setColor:(ColorValue *)color {
    _color = color;
    
    self.red = color.red;
    self.redValue = color.redValue;
    
    self.green = color.green;
    self.greenValue = color.greenValue;
    
    self.blue = color.blue;
    self.blueValue = color.blueValue;
}

- (BOOL)isEqual:(WDColorModel *)object {
    
    BOOL redEqual = fabs(self.redValue - object.redValue) < 0.0001;
    BOOL blueEqual = fabs(self.blueValue - object.blueValue) < 0.0001;
    BOOL greenEqual = fabs(self.greenValue - object.greenValue) < 0.0001;
    
    return redEqual && blueEqual && greenEqual;
}

- (NSString *)description {
    return [NSString stringWithFormat:@" key:%@\n red:%@\n green:%@\n blue:%@\n alpha:%@\n colorSpace:%@\n customColorSpace:%@\n",self.key, self.red, self.green, self.blue, self.alpha, self.colorSpace, self.customColorSpace];
}

@end

@implementation ColorValue

- (BOOL)hasValue {
    return _red && _green && _blue;
}

- (void)clearValue {
    _red = _green = _blue = nil;
}

- (void)setRedValue:(CGFloat)red {
    CGFloat tempValue = red / 255.0;
    _redValue = tempValue;
    self.red = [NSString stringWithFormat:@"%.8f",tempValue];
}

- (void)setGreenValue:(CGFloat)green {
    CGFloat tempValue = green / 255.0;
    _greenValue = tempValue;
    self.green = [NSString stringWithFormat:@"%.8f",tempValue];
}

- (void)setBlueValue:(CGFloat)blue {
    CGFloat tempValue = blue / 255.0;
    _blueValue = tempValue;
    self.blue = [NSString stringWithFormat:@"%.8f",tempValue];
}

@end
