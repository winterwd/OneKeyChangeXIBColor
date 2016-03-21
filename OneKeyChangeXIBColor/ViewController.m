//
//  ViewController.m
//  OneKeyChangeXIBColor
//
//  Created by winter on 16/3/21.
//  Copyright © 2016年 winter. All rights reserved.
//

#import "ViewController.h"
#import "WDColorModel.h"

@interface ViewController ()
@property (weak) IBOutlet NSTextField *modifySuccess;
@property (weak) IBOutlet NSTextField *modifyFailed;


@property (nonatomic, strong) NSMutableArray *xibFilePaths;
@property (nonatomic, strong) NSMutableArray *storyboardFilePaths;

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
    
    
    // ff6000 替换
    //    UIColor *color = [UIColor colorWithRed:0.4078 green:0.7216 blue:0.0627 alpha:1.0];
    self.targetColorModel = [[WDColorModel alloc] init];
    self.targetColorModel.red = @"0.4078" ;
    self.targetColorModel.green = @"0.7216";
    self.targetColorModel.blue = @"0.0627";
//    self.targetColorModel.red = @"0.9294" ;
//    self.targetColorModel.green = @"0.4275";
//    self.targetColorModel.blue = @"0.1216";
    
    // ed6d1f 需要被替换的
//  UIColor *color = [UIColor colorWithRed:0.9294 green:0.4275 blue:0.1216 alpha:1.0];
    WDColorModel *objColorModel = [[WDColorModel alloc] init];
    objColorModel.red = @"0.9294";
    objColorModel.green = @"0.4275";
    objColorModel.blue = @"0.1216";
//    objColorModel.red = @"0.4078";
//    objColorModel.green = @"0.7216";
//    objColorModel.blue = @"0.0627";
    
    // 源文件路径绝对
    NSString *sourcePath = @"/Users/winter/Desktop/OneKeyChangeXIBColor/testXIB";
    ;
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
            if ([obj isEqual:objColorModel]) {
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
