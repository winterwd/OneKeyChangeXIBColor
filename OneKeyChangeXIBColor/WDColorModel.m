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
        else if ([node.name isEqualToString:@"customColorSpace"]) {
            model.customColorSpace = node.stringValue;
        }
        else if ([node.name isEqualToString:@"red"]) {
            CGFloat temp = [node.stringValue floatValue];
            NSInteger tempValue = temp * 10000;
            model.redValue = tempValue;
            model.red = [NSString stringWithFormat:@"0.%ld",tempValue];
        }
        else if ([node.name isEqualToString:@"green"]) {
            CGFloat temp = [node.stringValue floatValue];
            NSInteger tempValue = temp * 10000;
            model.greenValue = tempValue;
            model.green = [NSString stringWithFormat:@"0.%ld",tempValue];
        }
        else if ([node.name isEqualToString:@"blue"]) {
            CGFloat temp = [node.stringValue floatValue];
            NSInteger tempValue = temp * 10000;
            model.blueValue = tempValue;
            model.blue = [NSString stringWithFormat:@"0.%ld",tempValue];
        }
    }
    return model;
}

- (void)setColor:(ColorValue *)color
{
    _color = color;
    
    self.red = color.redString;
    CGFloat temp = [color.redString floatValue];
    NSInteger tempValue = temp * 10000;
    self.redValue = tempValue;
    
    self.green = color.greenString;
    temp = [color.greenString floatValue];
    tempValue = temp * 10000;
    self.greenValue = tempValue;
    
    self.blue = color.blueString;
    temp = [color.blueString floatValue];
    tempValue = temp * 10000;
    self.blueValue = tempValue;
}

// 修正-0.0001
- (NSInteger )minusValueStringWith:(NSString *)valueString
{
    CGFloat value = [valueString floatValue];
    value -= 0.00009;
    
    NSInteger tempValue = value * 10000;
    return tempValue;
}

// 修正+0.0001
- (NSInteger )plusValueStringWith:(NSString *)valueString
{
    CGFloat value = [valueString floatValue];
    value += 0.00011;
    
    NSInteger tempValue = value * 10000;
    return tempValue;
}

- (BOOL)isEqual:(WDColorModel *)object
{
    // 修正-0.0001
    NSInteger objMinusRedValue = [self minusValueStringWith:object.red];
    NSInteger objMinusBlueValue = [self minusValueStringWith:object.blue];
    NSInteger objMinusGreenValue = [self minusValueStringWith:object.green];
    
    // 修正+0.0001
    NSInteger objPlusRedValue = [self plusValueStringWith:object.red];
    NSInteger objPlusBlueValue = [self plusValueStringWith:object.blue];
    NSInteger objPlusGreenValue = [self plusValueStringWith:object.green];
    
    BOOL redEqual = NO;
    BOOL blueEqual = NO;
    BOOL greenEqual = NO;
    
    if (self.redValue == object.redValue) {
        redEqual = YES;
    }
    else if (self.redValue == objMinusRedValue) {
        redEqual = YES;
    }
    else if (self.redValue == objPlusRedValue) {
        redEqual = YES;
    }
    
    // blue
    if (self.blueValue == object.blueValue) {
        blueEqual = YES;
    }
    else if (self.blueValue == objMinusBlueValue) {
        blueEqual = YES;
    }
    else if (self.blueValue == objPlusBlueValue) {
        blueEqual = YES;
    }
    
    // green
    if (self.greenValue == object.blueValue) {
        greenEqual = YES;
    }
    else if (self.greenValue == objMinusGreenValue) {
        greenEqual = YES;
    }
    else if (self.greenValue == objPlusGreenValue) {
        greenEqual = YES;
    }

    return redEqual && blueEqual && greenEqual;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"key:%@\n red:%@\n green:%@\n blue:%@\n alpha:%@\n colorSpace:%@\n customColorSpace:%@\n",self.key, self.red, self.green, self.blue, self.alpha, self.colorSpace, self.customColorSpace];
}

@end

@implementation ColorValue


- (void)setRed:(CGFloat)red
{
    _red = red;
    
    CGFloat temp = red / 255.0;
    NSInteger tempValue = temp * 10000;
    temp = tempValue / 10000.0;
    self.redString = [NSString stringWithFormat:@"%.4f",temp];
}

- (void)setGreen:(CGFloat)green
{
    _green = green;
    
    CGFloat temp = green / 255.0;
    NSInteger tempValue = temp * 10000;
    temp = tempValue / 10000.0;
    self.greenString = [NSString stringWithFormat:@"%.4f",temp];
}

- (void)setBlue:(CGFloat)blue
{
    _blue = blue;
    
    CGFloat temp = blue / 255.0;
    NSInteger tempValue = temp * 10000;
    temp = tempValue / 10000.0;
    self.blueString = [NSString stringWithFormat:@"%.4f",temp];
}
@end
