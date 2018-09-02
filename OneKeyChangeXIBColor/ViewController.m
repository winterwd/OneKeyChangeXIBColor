//
//  ViewController.m
//  OneKeyChangeXIBColor
//
//  Created by winter on 16/3/21.
//  Copyright © 2016年 winter. All rights reserved.
//

#import "ViewController.h"
#import "WDColorModel.h"

@interface ViewController ()<NSTextDelegate>
@property (weak) IBOutlet NSTextField *beforeRTF;
@property (weak) IBOutlet NSTextField *beforeGTF;
@property (weak) IBOutlet NSTextField *beforeBTF;
@property (weak) IBOutlet NSTextField *afterRTF;
@property (weak) IBOutlet NSTextField *afterGTF;
@property (weak) IBOutlet NSTextField *afterBTF;

@property (nonatomic, assign) NSInteger modifiedNum;

@property (weak) IBOutlet NSTextField *modifyResult;
@property (weak) IBOutlet NSTextField *sourcePathTextField;

@property (weak) IBOutlet NSProgressIndicator *indicator;
@property (weak) IBOutlet NSView *indicatorView;

@property (nonatomic, strong) NSMutableArray *xibFilePaths;
@property (nonatomic, strong) NSMutableArray *sbFilePaths;

@property (nonatomic, strong) ColorValue *beforeColor;
@property (nonatomic, strong) ColorValue *afterColor;
@property (nonatomic, copy) NSString *filePath;

/** 替换的 */
@property (nonatomic, strong) WDColorModel *targetColorModel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.xibFilePaths = [NSMutableArray array];
    self.sbFilePaths = [NSMutableArray array];
    
    self.beforeColor = [[ColorValue alloc] init];
    self.afterColor = [[ColorValue alloc] init];
}

#pragma mark - delegate

- (void)controlTextDidChange:(NSNotification *)notification {
    self.modifyResult.hidden = YES;
    NSTextField *sender = notification.object;
    NSTextView *textView = notification.userInfo[@"NSFieldEditor"];
    NSString *string = textView.string;
    if (string.length == 0) {
        return;
    }
    NSUInteger value = [string floatValue];
    if (value >255) {
        [self showResult:@"色值为非负且不大于255的整数！"];
        return;
    }
    
    switch (sender.tag) {
        case 100:
            self.beforeColor.redValue = value;
            break;
        case 101:
            self.beforeColor.greenValue = value;
            break;
        case 102:
            self.beforeColor.blueValue = value;
            break;
        case 103:
            self.afterColor.redValue = value;
            break;
        case 104:
            self.afterColor.greenValue = value;
            break;
        case 105:
            self.afterColor.blueValue = value;
            break;
        case 0:
            // filepath
            self.filePath = string;
            break;
    }
}

#pragma mark - action

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

- (IBAction)startChage:(NSButton *)sender {
    if (self.beforeColor.hasValue && self.afterColor.hasValue) {
        if (self.filePath.length > 0) {
            [self startAnimation];
            [self startChangeXibColorWith:self.beforeColor after:self.afterColor sourcePath:self.filePath];
        }
        else {
            [self showResult:@"请选择文件路径！"];
        }
    }
    else {
        [self showResult:@"请输入修改前后的颜色值！"];
    }
}

- (void)startAnimation {
    self.modifyResult.hidden = YES;
    self.indicatorView.hidden = NO;
    [self.indicator startAnimation:nil];
}

- (void)stopAnimation {
    [self.indicator stopAnimation:nil];
    self.indicatorView.hidden = YES;
}

- (void)showResult:(NSString *)result {
    NSColor *color = [NSColor colorWithSRGBRed:0.80 green:0.23 blue:0.08 alpha:1.00];//redColor
    [self showResult:result color:color];
}

- (void)showResult:(NSString *)result color:(NSColor *)color {
    self.modifyResult.hidden = NO;
    self.modifyResult.textColor = color;
    [self.modifyResult setStringValue:result];
}

- (void)finshedClear {
    [self.beforeRTF setStringValue:@""];
    [self.beforeGTF setStringValue:@""];
    [self.beforeBTF setStringValue:@""];
    [self.afterRTF setStringValue:@""];
    [self.afterGTF setStringValue:@""];
    [self.afterBTF setStringValue:@""];
    
    [self.beforeColor clearValue];
    [self.afterColor clearValue];
}

#pragma mark - changeColor

/**
 开始执行 修改 xib或stroyboard 控件的颜色
 
 @param beforColor 修改前的颜色值
 @param afterColor 修改后的颜色值
 @param sourcePath 所需要修改的文件路径
 */
- (void)startChangeXibColorWith:(ColorValue *)beforColor after:(ColorValue *)afterColor sourcePath:(NSString *)sourcePath {
    // clear
    self.modifiedNum = 0;
    [self.xibFilePaths removeAllObjects];
    [self.sbFilePaths removeAllObjects];
    
    self.targetColorModel = [[WDColorModel alloc] init];
    self.targetColorModel.color = beforColor;
    
    WDColorModel *objColorModel = [[WDColorModel alloc] init];
    objColorModel.color = afterColor;
    
    [self findXibOrStoryboardFile:sourcePath];
    [self modifyColorModel:objColorModel];
}

// 搜索xib/storyboard文件
- (void)findXibOrStoryboardFile:(NSString*)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    if ([fileManager fileExistsAtPath:path isDirectory:&isDir]&&isDir) {
        NSArray* files = [fileManager contentsOfDirectoryAtPath:path error:nil];
        for (NSString* file in files) {
            [self findXibOrStoryboardFile:[path stringByAppendingPathComponent:file]];
        }
    } else {
        if ([path containsString:@".xib"]) {
            [self.xibFilePaths addObject:path];
        }
        if ([path containsString:@".storyboard"]) {
            [self.sbFilePaths addObject:path];
        }
    }
}

// 开始修改颜色 objColorModel : 需要被替换的
- (void)modifyColorModel:(WDColorModel *)objColorModel {
    if (self.xibFilePaths.count == 0 && self.sbFilePaths.count == 0) {
        NSLog(@"error = 该路径下没有xib/storyboard文件");
        [self showResult:@"当前目录下没有发现xib或者storyboard文件！"];
        return;
    }
    
    [self modifyColorModel:objColorModel filePaths:self.xibFilePaths];
    [self modifyColorModel:objColorModel filePaths:self.sbFilePaths];
    
    [self stopAnimation];
    
    NSInteger total = self.xibFilePaths.count + self.sbFilePaths.count;
    ;
    
    if (self.modifiedNum > 0) {
        NSColor *color = [NSColor colorWithSRGBRed:0.15 green:0.65 blue:0.11 alpha:1.00];//green
        NSString *result = [NSString stringWithFormat:@"总共 %ld 个文件，找到并修改了 %ld 处色值", total, (long)self.modifiedNum];
        [self showResult:result color: color];
    }
    else {
        NSString *result = [NSString stringWithFormat:@"总共 %ld 个文件，未找到所要修改的色值！", total];
        [self showResult:result ];
    }
    [self finshedClear];
}

// 修改 并返回结果
- (void)modifyColorModel:(WDColorModel *)objColorModel filePaths:(NSMutableArray *)filePaths {
    for (NSString *filePath in filePaths) {
        NSData *xmlData = [NSData dataWithContentsOfFile:filePath];
        NSXMLDocument *document = [self parsedDataFromData:xmlData colorModel:objColorModel];
        // 存储新的
        BOOL result = [self saveXMLFile:filePath xmlDoucment:document];
        if (!result) {
            NSLog(@"修改之后，文件保存失败！。。。");
        }
    }
}

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
    self.modifiedNum++;
    
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
        //        else if ([node.name isEqualToString:@"key"]) {
        //            [node setStringValue:obj.key];
        //        }
        //        else if ([node.name isEqualToString:@"colorSpace"]) {
        //            [node setStringValue:obj.colorSpace];
        //        }
        //        else if ([node.name isEqualToString:@"alpha"]) {
        //            [node setStringValue:obj.alpha];
        //        }
        //        else if ([node.name isEqualToString:@"customColorSpace"]) {
        //            // Xcode8 以后
        //            [node setStringValue:obj.customColorSpace];
        //        }
    }
}

// 创建新的 NSXMLElement
- (NSXMLElement *)creatXMLNodel:(WDColorModel *)obj {
    
    NSXMLElement *subNode = [NSXMLElement elementWithName:@"color"];
    [subNode addAttribute:[NSXMLNode attributeWithName:@"key" stringValue:obj.key]];
    [subNode addAttribute:[NSXMLNode attributeWithName:@"red" stringValue:obj.red]];
    [subNode addAttribute:[NSXMLNode attributeWithName:@"green" stringValue:obj.green]];
    [subNode addAttribute:[NSXMLNode attributeWithName:@"blue" stringValue:obj.blue]];
    [subNode addAttribute:[NSXMLNode attributeWithName:@"alpha" stringValue:obj.alpha]];
    [subNode addAttribute:[NSXMLNode attributeWithName:@"colorSpace" stringValue:obj.colorSpace]];
    
    if (obj.customColorSpace.length > 0) {
        // Xcode8 以后
        [subNode addAttribute:[NSXMLNode attributeWithName:@"customColorSpace" stringValue:obj.customColorSpace]];
    }
    return subNode;
}

- (BOOL)saveXMLFile:(NSString *)destPath xmlDoucment:(NSXMLDocument *)XMLDoucment {
    
    if (XMLDoucment == nil) {
        return NO;
    }
    
    if ( ![[NSFileManager defaultManager] fileExistsAtPath:destPath]) {
        if ( ![[NSFileManager defaultManager] createFileAtPath:destPath contents:nil attributes:nil]){
            return NO;
        }
    }
    
    NSData *XMLData = [XMLDoucment XMLDataWithOptions:NSXMLNodePrettyPrint];
    if (![XMLData writeToFile:destPath atomically:YES]) {
        NSLog(@"Could not write document out...");
        return NO;
    }
    return YES;
}

@end
