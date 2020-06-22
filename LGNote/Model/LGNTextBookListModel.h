//
//  LGNTextBookListModel.h
//  NoteDemo
//
//  Created by abc on 2020/5/25.
//  Copyright © 2020 hend. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LGNTextBookListModel : NSObject
//教材列表

@property (nonatomic,copy) NSString * UnionName;
@property (nonatomic,copy) NSString * UnionId;
@property (nonatomic,strong) NSMutableArray <LGNTextBookListModel*>* chapters;

//[2]    (null)    @"chapters" : @"3 elements"
//"SchoolID": "S27-511-AF57",
//     "SubjectID": "S2-Biology",
//     "SubjectName": "生物",
//     "CourseNO": "F15201C5-718F-4906-AD53-B7E3CF255C65",
//     "CourseName": "高中二年级生物",
//     "CourseClassType": 21,
//     "CourseClassID": "2989AB4F-D9E4-4B5C-AD33-5AC02B0475DE",
//     "CourseClassName": "生物高二（1）班",
//     "ClassID": "2B36CA4C-9D63-4401-9E44-EE08844BD902",
//     "ClassName": "高二（1）班",
//     "CollegeID": null,
//     "CountStu": 63,
//     "TeacherID": null,
//     "TeacherName": null,
//     "GlobalGrade": "K11",
//     "GradeID": "AC6F56E5-E9AD-481E-B6CB-1BFC7BEF43BB",
//     "GradeName": "高中二年级"

@property (nonatomic,copy) NSString * SubjectName;
@property (nonatomic,copy) NSString * SubjectID;
@property (nonatomic,copy) NSString * TeacherID;

@end

NS_ASSUME_NONNULL_END
