//
//  LGNTextBookListModel.m
//  NoteDemo
//
//  Created by abc on 2020/5/25.
//  Copyright © 2020 hend. All rights reserved.
//

#import "LGNTextBookListModel.h"

@implementation LGNTextBookListModel

+ (NSDictionary *)mj_objectClassInArray
{
    return @{
             @"chapters" : [LGNTextBookListModel class]
             };
}
@end
