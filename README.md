###[详细介绍请移步！](http://www.jianshu.com/p/55570716108f)各位同学有问题可以留言，一起进步！


***

- ####2016.12.22


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


- ####2016.03.21

事情是这样的，今天UI妹子哭着对我说，所有界面的主题色要统一修改（cao，尼玛，上周不是刚改过的吗！吐血了！）

现在iOS开发，我基本界面都是用xib或者storyboard的，所以一般跟主题色有关的控件颜色就直接在上面设置好了，现在妹子说让我换个颜色，这个要死人，听说Android那边可以一键修改啊，为啥我们大iOS就木有这个功能！！！

本着懒人的想法，于是就有了今天的文章！

我要写段代码，让它帮我来修改，这样岂不是更能显得我们搞程序的B格😂

先说下思路吧：其实很简单，首先遍历整个文件夹，找出所有的.xib和.storyboard（注意：这些文件其实都是xml文件），这下好了，找出xml文本中所有color的标签，然后修改属性，生成新的xml,搞定！

设置以下属性即可完成 修改
```
// 工程总目录 源文件路径绝对（这里路径直接将你的工程目录拖进来）
NSString *sourcePath = @"/Users/winter/Desktop/OneKeyChangeXIBColor/test";
// 工程修改前颜色 RGB
NSInteger red_pre = 237;
NSInteger green_pre = 109;
NSInteger blue_pre = 31;
// 修改后的颜色 RGB
NSInteger red_mod = 255;
NSInteger green_mod = 96;
NSInteger blue_mod = 0;
```