***

### 2018.9.2

这个改色的小工具，本来是我自己在工作中，碰到的需要解决的问题，就做了一个这样的小工具，当时仅限满足自己的需求，但是最近有简友留言，提出有bug，还提出了一些改进的意见(多谢@灯塔的焰火)，本是打算，赶紧修复一些这些问题，怎奈懒癌病犯，以至拖到今日，实在惭愧！。。。

此次优化如下：

	-> 1，优化了匹配色值算法；
	-> 2，优化颜色数据模型ColorValue；
	-> 3，优化结果提示，失败情况下用红色，修改完成则用绿色；
	-> 4，修改完成后，恢复初始状态，以节省资源，提高性能；

如果此工具对你有帮助，那就顺手给个star吧 -> [star](https://github.com/winterwd/OneKeyChangeXIBColor)

***

### 2016.12.22


最近有点闲了，所以就把以前的这个小工具更新一下，这么长时间，还经历过一次Xcode8的更新升级，估计这个小工具是不能用了，打开工程cmd+R了一下，发现还真的不能用了，索性给这个小工具来一次升级。

##### 使用上的一些改进：
    1. 我做了一个很好用的界面，你可以在界面上进行颜色值得操作；
    2. 可以点击文件路径 进行选择所需要修改的文件的路径。
    
![simple1.png](http://upload-images.jianshu.io/upload_images/1064509-1574fbc2f73b7a6a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/500)

![simple2.png](https://upload-images.jianshu.io/upload_images/1064509-276e4ffac67faabf.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/500)

![simple3.png](https://upload-images.jianshu.io/upload_images/1064509-620fc44e86481643.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/500)

### 代码的优化：

#### 1.先简单说下原理：
    
	-> 分别记录修改前（beforeColor）和修改后（afterColor）的颜色模型， 以及文件路径（filePath）；
	-> 将用户输入的颜色值转化为所需要的类型，也就是将颜色值->ColorValue模型；
	-> 遍历filePath路径下，所以有的.xib和.storyboard文件，并保存文件路径；
	-> 对每一个.xib和.storyboard文件进行DOM解析操作，找到所有color元素标签NSXMLElement；
	-> 找到color元素标签内的NSXMLNode相对应的node.name，over。

#### 2.一些核心代码：

  - 记录颜色，这个就是textField的一个delegate方法, 文件路径的选择，用的这个NSOpenPanel;
  
	```obj-C
	// NSTextDelegate 获取输入内容
    - (void)controlTextDidChange:(NSNotification *)notification;
	
    //  获取文件选择路径
    - (IBAction)choseFilePath:(NSButton *)sender {
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

  - 颜色数据模型ColorValue;
  
	```obj-C
	// 直接存储 转化后RGB色值，_redValue为CGFloat类型，作为匹配参考值，这里截取小数后8位，作为要修改的色值
	- (void)setRedValue:(CGFloat)red {
	    CGFloat tempValue = red / 255.0;
    	_redValue = tempValue;
    	self.red = [NSString stringWithFormat:@"%.8f",tempValue];
	}
	```
	
  - 色值匹配算法;
 
	```obj-C
	// 相比较以前的容错算法来说，这样的写法更简洁，在此，暂时将相似精度值设置为0.0001
	- (BOOL)isEqual:(WDColorModel *)object {
    
	    BOOL redEqual = fabs(self.redValue - object.redValue) < 0.0001;
	    BOOL blueEqual = fabs(self.blueValue - object.blueValue) < 0.0001;
	    BOOL greenEqual = fabs(self.greenValue - object.greenValue) < 0.0001;
	    
	    return redEqual && blueEqual && greenEqual;
	}
	```
	
  - 搜索.xib和.storyboard文件，这个没什么说的，就是文件操作，检索文件后缀;
  
  - 获取color元素(NSXMLElement)，并操作修改;
  
  ```obj-C
    // 获取 XMLDocument
    - (NSXMLDocument *)parsedDataFromData:(NSData *)data colorModel:(WDColorModel *)objColorModel {
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
    - (void)parsedXMLElement:(NSXMLElement *)element objColorModel:(WDColorModel *)objColorModel {
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
    - (void)updateXMLNodelWithNode:(NSXMLElement *)subElement color:(WDColorModel *)obj {
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

具体细节见[代码](https://github.com/winterwd/OneKeyChangeXIBColor)，如果觉得不错，那就顺手start🤗
> End
