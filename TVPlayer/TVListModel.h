//
//  TVListModel.h
//  TVPlayer
//
//  Created by rick tao. on 17/1/19.
//  Copyright © 2016年 rick tao 陶伟胜. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TVListModel : NSObject

@property (nonatomic, copy) NSString *tvName;
@property (nonatomic, copy) NSString *tvURL;

+ (NSArray *)tvListModels;

@end
