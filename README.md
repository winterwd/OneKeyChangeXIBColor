###[详细介绍请移步！](http://www.jianshu.com/p/55570716108f)各位同学有问题可以留言，一起进步！


***

###2016.12.22


最近有点闲了，所以就把以前的这个小工具更新一下，这么长时间，还经历过一次Xcode8的更新升级，估计这个小工具是不能用了，打开工程cmd+R了一下，发现还真的不能用了，索性给这个小工具来一次升级。

#####使用上的一些改进：
    1. 我做了一个很好用的界面，你可以在界面上进行颜色值得操作；
    2. 可以点击文件路径 进行选择所需要修改的文件的路径。
   ![simple1.png](http://upload-images.jianshu.io/upload_images/1064509-dc91e5be25dfbe2f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
   ![simple2.png](http://upload-images.jianshu.io/upload_images/1064509-1574fbc2f73b7a6a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

###代码的优化：

####1.先简单说下原理：
    
      -> 分别记录修改前（beforeColor）和修改后（afterColor）的颜色模型， 以及文件路径（filePath）；
      -> 将用户输入的颜色值转化为所需要的类型，也就是将颜色值->ColorValue模型；
      -> 遍历filePath路径下，所以有的.xib和.storyboard文件，并保存文件路径；
      -> 对每一个.xib和.storyboard文件进行DOM解析操作，找到所有color元素标签NSXMLElement；
      -> 找到color元素标签内的NSXMLNode相对应的node.name，over。

####2.一些核心代码：
  - 记录颜色，这个就是textField的一个delegate方法, 文件路径的选择，用的这个NSOpenPanel
    ```
    // NSTextDelegate 获取输入内容
    - (void)controlTextDidChange:(NSNotification *)notification

    //  获取文件选择路径
    - (IBAction)choseFilePath:(NSButton *)sender
  {
        NSOpenPanel *openPanel = [NSOpenPanel openPanel];
        [openPanel setCanChooseFiles:YES];
        [openPanel setCanChooseDirectories:YES];
    
        NSWindow *window = [[NSApplication sharedApplication] keyWindow];
        [openPanel beginSheetModalForWindow:window completionHandler:^(NSModalResponse returnCode) {
            if (returnCode == 1) {
                NSURL *fileUrl = [[openPanel URLs] objectAtIndex:0];
                NSString *filePath = [[fileUrl.absoluteString componentsSeparatedByString:@"file://"] lastObject];
                NSLog(@"fileContext = %@",filePath);
                self.sourcePathTextField.stringValue = filePath;
                self.filePath = filePath;
            }
        }];
}
    ```

  - 颜色数据模型ColorValue
  ```
    // RGB色值转为四位小数 这里‘*10000’再‘0.%ld’是截取小数后四位
    - (void)setRed:(CGFloat)red
    {
        _red = red;
      
        CGFloat temp = red / 255.0;
        NSInteger tempValue = temp * 10000;
        self.redString = [NSString stringWithFormat:@"0.%ld",tempValue];
  }
  ```
  - 搜索.xib和.storyboard文件，这个没什么说的，就是文件操作，检索文件后缀
  - 获取color元素(NSXMLElement)，并操作修改
  ```
    // 获取 XMLDocument
    - (NSXMLDocument *)parsedDataFromData:(NSData *)data colorModel:(WDColorModel *)objColorModel
  {
        NSError *error = nil;
        NSXMLDocument *document = [[NSXMLDocument alloc] initWithData:data options:NSXMLNodePreserveWhitespace error:&error];
        NSXMLElement *rootElement = document.rootElement;
        [self parsedXMLElement:rootElement objColorModel:objColorModel];
    
        if (error) {
            NSLog(@"error = %@",error);
        }
        return document;
  }

    // 修改元素
    - (void)parsedXMLElement:(NSXMLElement *)element objColorModel:(WDColorModel *)objColorModel
    {
        for (NSXMLElement *subElement in element.children) {
            if ([subElement.name isEqualToString:@"color"]) {
              WDColorModel *obj = [WDColorModel colorModelWithArray:subElement.attributes];
                if ([obj isEqual:self.targetColorModel]) {
                    [self updateXMLNodelWithNode:subElement color:objColorModel];
                }
            }
            [self parsedXMLElement:subElement objColorModel:objColorModel];
        }
  }

    // 更新 NSXMLElement
    - (void)updateXMLNodelWithNode:(NSXMLElement *)subElement color:(WDColorModel *)obj
  {
         NSArray *array = subElement.attributes;
         for (NSXMLNode *node in array) {   
            if ([node.name isEqualToString:@"red"]) {
                [node setStringValue:obj.red];
            }
            else if ([node.name isEqualToString:@"green"]) {
                [node setStringValue:obj.green];
            }
            else if ([node.name isEqualToString:@"blue"]) {
                [node setStringValue:obj.blue];
            }
         }
    }
 ```

具体细节见[代码](https://git.oschina.net/winter7/OneKeyChangeXIBColor.git)
> end
