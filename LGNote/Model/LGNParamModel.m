//
//  ParamModel.m
//  NoteDemo
//
//  Created by hend on 2018/10/10.
//  Copyright © 2018年 hend. All rights reserved.
//

#import "LGNParamModel.h"

@implementation LGNParamModel

- (void)setResourceName:(NSString *)ResourceName{
    ResourceName = [ResourceName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (ResourceName.length > 20) {
        ResourceName = [ResourceName substringToIndex:20];
    }
    _ResourceName = ResourceName;
}

- (NSString *)UserID{
    if (!_UserID) {
        _UserID = @"userID_null";
    }
    return _UserID;
}

- (NSInteger)UserType{
    if (!_UserType) {
        _UserType = 2;
    }
    return _UserType;
}

- (NSString *)UserName{
    if (!_UserName) {
        _UserName = @"userName_null";
    }
    return _UserName;
}

- (NSString *)SchoolID{
    if (!_SchoolID) {
        _SchoolID = @"schoolID_null";
    }
    return _SchoolID;
}

//- (NSString *)SubjectID{
//    if (!_SubjectID) {
//        _SubjectID = @"";
//    }
//    return _SubjectID;
//}

- (NSString *)SearchKeycon{
    if (!_SearchKeycon) {
        _SearchKeycon = @"";
    }
    return _SearchKeycon;
}

- (NSString *)Token{
    if (!_Token) {
        _Token = @"";
    }
    return _Token;
}

- (NSString *)Secret{
    if (!_Secret) {
        _Secret = @"";
    }
    return _Secret;
}

- (NSString *)StartTime{
    if (!_StartTime) {
        _StartTime = @"";
    }
    return _StartTime;
}

- (NSString *)EndTime{
    if (!_EndTime) {
        _EndTime = @"";
    }
    return _EndTime;
}

- (NSString *)MaterialID{
    if (!_MaterialID) {
        _MaterialID = @"";
    }
    return _MaterialID;
}


//- (NSString *)SystemID{
//    if (!_SystemID) {
//        _SubjectID = @"S21";
//    }
//    return _SystemID;
//}

- (void)setSystemID:(NSString *)SystemID{
    _SystemID = SystemID;
    self.C_SystemID = SystemID;
    if ([SystemID isEqualToString:@"S21"] || [SystemID isEqualToString:@"101"]) {
        self.C_SystemID = @"All";
    }
}

- (void)setC_SystemID:(NSString *)C_SystemID{
    _C_SystemID = C_SystemID;
    
}

- (void)setSubjectID:(NSString *)SubjectID{
    _SubjectID = SubjectID;
    self.C_SubjectID = SubjectID;
}

- (void)setC_SubjectID:(NSString *)C_SubjectID{
    _C_SubjectID = C_SubjectID;
}

- (void)setSystemType:(SystemType)SystemType{
    _SystemType = SystemType;
    switch (SystemType) {
        case SystemType_HOME:
            _SystemName = @"课后作业";
            break;
        case SystemType_KQ:
            _SystemName = @"课前预习";
            break;
        case SystemType_KT:
            _SystemName = @"课堂教案";
            break;
        case SystemType_CP:
            _SystemName = @"基础平台";
            break;
        case SystemType_ASSISTANTER:
            _SystemName = @"学习小助手";
            break;
         case SystemType_ZNT:
            _SystemName = @"重难题辅导";
            break;
        case SystemType_YPT:
            _SystemName = @"蓝鸽云平台";
            break;
        case SystemType_DZJC:
            _SystemName = @"电子教材";
            break;
        case SystemType_XYTJ:
            _SystemName = @"学友推荐";
            break;
            
        default:
            _SystemName = @"重难题辅导";
            break;
            
    }
}
//- (SystemType)SystemType{
//    if (!_SystemType) {
//        _SystemType = SystemType_ASSISTANTER;
//    }
//    return _SystemType;
//}

@end
