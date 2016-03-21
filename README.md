#OneKeyChangeXIBColor

设置一下属性即可完成 一键修改

    // ff6000 替换
//    UIColor *color = [UIColor colorWithRed:0.4078 green:0.7216 blue:0.0627 alpha:1.0];
    self.targetColorModel = [[WDColorModel alloc] init];
    self.targetColorModel.red = @"0.4078" ;
    self.targetColorModel.green = @"0.7216";
    self.targetColorModel.blue = @"0.0627";
    
    // ed6d1f 需要被替换的
//  UIColor *color = [UIColor colorWithRed:0.9294 green:0.4275 blue:0.1216 alpha:1.0];
    WDColorModel *objColorModel = [[WDColorModel alloc] init];
    objColorModel.red = @"0.9294";
    objColorModel.green = @"0.4275";
    objColorModel.blue = @"0.1216";
    
    // 源文件路径
    NSString *sourcePath = @"/Users/winter/Desktop/OneKeyChangeXIBColor/testXIB";