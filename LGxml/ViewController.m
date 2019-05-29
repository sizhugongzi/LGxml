//
//  ViewController.m
//  LGXML
//
//  Created by 甘延娇 on 2019/5/14.
//  Copyright © 2019 itheima. All rights reserved.
//

#import "ViewController.h"
#import "XLItem.h"
#import "MJExtension.h"
#import <SafariServices/SafariServices.h>

@interface ViewController ()<UITableViewDataSource,NSXMLParserDelegate,UITableViewDelegate>

@property (nonatomic,strong) XLItem *xlItem;
@property (nonatomic,strong) NSMutableArray *itemsArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
// 用来记录当前xml解析的节点名称
@property (nonatomic, copy) NSString *currentElementName;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self downloadData];
}

- (void)downloadData
{
    //01 确定请求路径
    NSURL *url = [NSURL URLWithString:@"https://www.cnet.com/rss/news"];
    //02 创建会话对象
    NSURLSession *session = [NSURLSession sharedSession];
    //03 创建TASK 执行Task
    [[session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //04 解析服务器返回的数据
        //001 创建XML解析器(NSXMLParser-SAX)
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
        
        //002 设置代理
        parser.delegate = self;
        //003 开始解析 本身是阻塞式的
        [parser parse];
        //06 刷新UI
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.tableView reloadData];
        }];
    }] resume];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.itemsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //01 获得cell
    static NSString * const ID = @"new";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    //02 设置cell
    //001 得到该行cell对应的数据
    XLItem *item = self.itemsArray[indexPath.row];
    NSLog(@"%@",item.title);
    //002 设置标题和子标题
    cell.textLabel.text = [self.itemsArray[indexPath.row] title];
    //03 返回cell
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XLItem *item = self.itemsArray[indexPath.row];
    NSURL *url = [NSURL URLWithString:item.link];
    SFSafariViewController *safariVc = [[SFSafariViewController alloc] initWithURL:url];
    [self presentViewController:safariVc animated:YES completion:nil];
}

#pragma mark -----------------------
#pragma mark NSXMLParserDelegate
//01 开始解析XML文档的时候调用
-(void)parserDidStartDocument:(NSXMLParser *)parser
{
    self.itemsArray = [NSMutableArray array];
}

//02 开始解析XML文档中某个元素的时候调用 该方法会调用多次
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict
{
    self.currentElementName = elementName;
    
    if ([elementName isEqualToString:@"item"]) {
        XLItem *item = [[XLItem alloc] init];
        [_itemsArray addObject:item];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (_currentElementName != nil) {
        XLItem *item = [_itemsArray lastObject];
        [item setValue:string forKey:_currentElementName];
    }
}

//03 某个元素解析完毕之后会调用该方法
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    _currentElementName = nil;
}

//04 整个XML文档解析完毕
-(void)parserDidEndDocument:(NSXMLParser *)parser
{
    //NSLog(@"%@",[_itemsArray[0] title]);
}


@end
