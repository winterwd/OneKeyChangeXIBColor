//
//  ViewController.m
//  OneKeyChangeXIBColor
//
//  Created by winter on 16/3/21.
//  Copyright © 2016年 winter. All rights reserved.
//

#import "ViewController.h"
#import "WDColorModel.h"

@interface ViewController ()<NSTextDelegate,NSPathControlDelegate>
@property (weak) IBOutlet NSTextField *modifySuccess;
@property (weak) IBOutlet NSTextField *modifyFailed;
@property (weak) IBOutlet NSTextField *sourcePathTextField;

@property (weak) IBOutlet NSProgressIndicator *indicator;
@property (weak) IBOutlet NSView *indicatorView;

@property (nonatomic, strong) NSMutableArray *xibFilePaths;
@property (nonatomic, strong) NSMutableArray *storyboardFilePaths;

@property (nonatomic, strong) ColorValue *beforeColor;
@property (nonatomic, strong) ColorValue *afterColor;
@property (nonatomic, copy) NSString *filePath;

/** 替换的 */
@property (nonatomic, strong) WDColorModel *targetColorModel;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.xibFilePaths = [NSMutableArray array];
    self.storyboardFilePaths = [NSMutableArray array];
    
    self.beforeColor = [[ColorValue alloc] init];
    self.afterColor = [[ColorValue alloc] init];
}

#pragma mark - delegate

- (void)controlTextDidChange:(NSNotification *)notification
{
    NSTextField *sender = notification.object;
    NSTextView *textView = notification.userInfo[@"NSFieldEditor"];
    NSString *string = textView.string;
    
    switch (sender.tag) {
        case 100:
            self.beforeColor.red = [string floatValue];
            break;
        case 101:
            self.beforeColor.green = [string floatValue];
            break;
        case 102:
            self.beforeColor.blue = [string floatValue];
            break;
        case 103:
            self.afterColor.red = [string floatValue];
            break;
        case 104:
            self.afterColor.green = [string floatValue];
            break;
        case 105:
            self.afterColor.blue = [string floatValue];
            break;
        case 0:
            // filepath
            self.filePath = string;
            break;
    }
}

#pragma mark - action

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

- (IBAction)startChage:(NSButton *)sender
{
    if (self.filePath.length > 0) {
        [self startAnimation];
        
        [self startChangeXibColorWith:self.beforeColor after:self.afterColor sourcePath:self.filePath];
    }
    else {
        
    }
}

- (void)startAnimation
{
    self.indicatorView.hidden = NO;
    [self.indicator startAnimation:nil];
}

- (void)stopAnimation
{
    [self.indicator stopAnimation:nil];
    self.indicatorView.hidden = YES;
}

#pragma mark - changeColor
/**
 开始执行 修改 xib或stroyboard 控件的颜色

 @param beforColor 修改前的颜色值
 @param afterColor 修改后的颜色值
 @param sourcePath 所需要修改的文件路径
 */
- (void)startChangeXibColorWith:(ColorValue *)beforColor after:(ColorValue *)afterColor sourcePath:(NSString *)sourcePath
{
    self.targetColorModel = [[WDColorModel alloc] init];
    self.targetColorModel.color = beforColor;

    WDColorModel *objColorModel = [[WDColorModel alloc] init];
    objColorModel.color = afterColor;

    [self findXibOrStoryboardFile:sourcePath];
    [self modifyColorModel:objColorModel];
}

// 搜索xib/storyboard文件
- (void)findXibOrStoryboardFile:(NSString*)path
{
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
        else if ([path containsString:@".storyboard"]) {
            [self.storyboardFilePaths addObject:path];
        }
    }
}

// 开始修改颜色 objColorModel : 需要被替换的
- (void)modifyColorModel:(WDColorModel *)objColorModel
{
    BOOL xibResult = [self modifyColorModel:objColorModel filePaths:self.xibFilePaths];
    BOOL storyboardResult =[self modifyColorModel:objColorModel filePaths:self.storyboardFilePaths];

    [self stopAnimation];
    if (xibResult && storyboardResult) {
        self.modifySuccess.hidden = NO;
        self.modifyFailed.hidden = YES;
    }
    else {
        self.modifySuccess.hidden = YES;
        self.modifyFailed.hidden = NO;
    }
    
    if (self.xibFilePaths.count == 0 && self.storyboardFilePaths.count == 0) {
        NSLog(@"error = 该路径下没有xib/storyboard文件");
    }
}

// 修改 并返回结果
- (BOOL)modifyColorModel:(WDColorModel *)objColorModel filePaths:(NSMutableArray *)filePaths
{
    BOOL result = NO;
    for (NSString *filePath in filePaths) {
        NSData *xmlData = [NSData dataWithContentsOfFile:filePath];
        NSXMLDocument *document = [self parsedDataFromData:xmlData colorModel:objColorModel];
        // 存储新的
        result = [self saveXMLFile:filePath xmlDoucment:document];
    }
    return result;
}

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
        NSXMLElement *objNode = nil;
        NSInteger index = subElement.index;
        if ([subElement.name isEqualToString:@"color"]) {
            WDColorModel *obj = [WDColorModel colorModelWithArray:subElement.attributes];
            if ([obj isEqual:self.targetColorModel]) {
                objNode = [self creatXMLNodel:obj];
            }
        }
        if (objNode) {
            // 替换
            [element replaceChildAtIndex:index withNode:objNode];
        }
        [self parsedXMLElement:subElement objColorModel:objColorModel];
    }
}

// 设置新的 NSXMLElement
- (NSXMLElement *)creatXMLNodel:(WDColorModel *)obj
{
    NSXMLElement *subNode = [NSXMLElement elementWithName:@"color"];
    [subNode addAttribute:[NSXMLNode attributeWithName:@"key" stringValue:obj.key]];
    [subNode addAttribute:[NSXMLNode attributeWithName:@"red" stringValue:self.targetColorModel.red]];
    [subNode addAttribute:[NSXMLNode attributeWithName:@"green" stringValue:self.targetColorModel.green]];
    [subNode addAttribute:[NSXMLNode attributeWithName:@"blue" stringValue:self.targetColorModel.blue]];
    [subNode addAttribute:[NSXMLNode attributeWithName:@"alpha" stringValue:obj.alpha]];
    [subNode addAttribute:[NSXMLNode attributeWithName:@"colorSpace" stringValue:obj.colorSpace]];
    return subNode;
}

- (BOOL)saveXMLFile:(NSString *)destPath xmlDoucment:(NSXMLDocument *)XMLDoucment
{
    if (XMLDoucment == nil) {
        return NO;
    }

    if ( ! [[NSFileManager defaultManager] fileExistsAtPath:destPath]) {
        if ( ! [[NSFileManager defaultManager] createFileAtPath:destPath contents:nil attributes:nil]){
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
