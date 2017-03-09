//
//  TVListModel.m
//  TVPlayer
//
//  Created by rick tao. on 17/1/19.
//  Copyright © 2016年 rick tao 陶伟胜. All rights reserved.
//

#import "TVListModel.h"

@implementation TVListModel

+ (NSArray *)tvListModels {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"TVList.plist" ofType:nil];
    
    NSDictionary *tvlist = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSArray *tvItems = tvlist[@"CCTV"];
    
    NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:35];
    
    [tvItems enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        TVListModel *model = [[TVListModel alloc] init];
        model.tvName = obj[@"tvName"];
        model.tvURL = obj[@"tvURL"];

        [arrayM addObject:model];
    }];
    
    return arrayM;
}

@end
