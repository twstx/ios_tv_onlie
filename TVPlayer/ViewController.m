//
//  ViewController.m
//  TVPlayer
//
//  Created by rick tao. on 17/1/19.
//  Copyright © 2016年 rick tao 陶伟胜. All rights reserved.
//

#import "ViewController.h"
#import "TVListModel.h"
#import "PlayViewController.h"
#import "UINavigationController+Rotation.h"
#include <netdb.h>
#include <sys/socket.h>
#include <arpa/inet.h>
@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *tvItems;

@end

@implementation ViewController
-(NSString*)getIPWithHostName:(const NSString*)hostName
{
    const char *hostN= [hostName UTF8String];
    struct hostent* phot;
    
    @try {
        phot = gethostbyname(hostN);
        
    }
    @catch (NSException *exception) {
        return nil;
    }
    
    struct in_addr ip_addr;
    memcpy(&ip_addr, phot->h_addr_list[0], 4);
    char ip[20] = {0};
    inet_ntop(AF_INET, &ip_addr, ip, sizeof(ip));
    
    NSString* strIPAddress = [NSString stringWithUTF8String:ip];
    return strIPAddress;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 70;
    self.tableView.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
    [self.view addSubview:_tableView];
    
    NSDictionary *attr = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.navigationController.navigationBar.titleTextAttributes = attr;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:48/255.0 green:95/255.0 blue:159/255.0 alpha:1.0];
    self.navigationItem.title = @"请选台(added by Rick Tao)";
    NSString *string = [self getIPWithHostName:@"www.baidu.com"];
    NSLog(@"TWS  baidu ip is: %@",string);
}

#pragma mark - tableViewDataSource & Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tvItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    TVListModel *model = self.tvItems[indexPath.row];
    cell.textLabel.text = model.tvName;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
    PlayViewController *playVC = [[PlayViewController alloc] init];
    playVC.TVModel = self.tvItems[indexPath.row];
    [self.navigationController pushViewController:playVC animated:YES];
}

- (NSArray *)tvItems {
    if (_tvItems == nil) {
        _tvItems = [TVListModel tvListModels];
    }
    return _tvItems;
}



@end
