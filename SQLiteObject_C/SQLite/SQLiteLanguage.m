//
//  SQLiteLanguage.m
//  SQLiteLanguageStructure
//
//  Created by POSUN-MAC on 2018/6/23.
//  Copyright © 2018年 POSUN-MAC. All rights reserved.
//
#import "SQLiteLanguage.h"
#pragma make - ============ SQL关键字 ============
static NSString *const SQL_CREATE=@"CREATE";
static NSString *const SQL_PRIMARY=@"PRIMARY";
static NSString *const SQL_TABLE=@"TABLE";
static NSString *const SQL_KEY=@"KEY";
static NSString *const SQL_NOT=@"NOT";
static NSString *const SQL_SPACE=@" ";
static NSString *const SQL_INTEGER=@"INTEGER";
static NSString *const SQL_REAL=@"REAL";
static NSString *const SQL_TEXT=@"TEXT";
static NSString *const SQL_BLOB=@"BLOB";
static NSString *const SQL_CONSTRAINT=@"CONSTRAINT";
static NSString *const SQL_FOREIGN=@"FOREIGN";
static NSString *const SQL_REFERENCES=@"REFERENCES";
static NSString *const SQL_DROP=@"DROP";
static NSString *const SQL_INSERT=@"INSERT";
static NSString *const SQL_INTO=@"INTO";
static NSString *const SQL_VALUES=@"VALUES";
static NSString *const SQL_SELECT=@"SELECT";
static NSString *const SQL_FROM=@"FROM";
static NSString *const SQL_WHERE=@"WHERE";
static NSString *const SQL_ORDER=@"ORDER";
static NSString *const SQL_BY=@"BY";
/**运算符**/
static NSString *const SQL_AND=@"AND";// AND 运算符允许在一个 SQL 语句的 WHERE 子句中的多个条件的存在。
static NSString *const SQL_BETWEEN=@"BETWEEN";//BETWEEN 运算符用于在给定最小值和最大值范围内的一系列值中搜索值。
static NSString *const SQL_EXISTS=@"EXISTS";//EXISTS 运算符用于在满足一定条件的指定表中搜索行的存在。
static NSString *const SQL_IN=@"IN";//IN 运算符用于把某个值与一系列指定列表的值进行比较。
static NSString *const SQL_LIKE=@"LIKE";//LIKE 运算符用于把某个值与使用通配符运算符的相似值进行比较。
static NSString *const SQL_GLOB=@"GLOB";// GLOB 运算符用于把某个值与使用通配符运算符的相似值进行比较。GLOB 与 LIKE 不同之处在于，它是大小写敏感的。
static NSString *const SQL_OR=@"OR";//OR 运算符用于结合一个 SQL 语句的 WHERE 子句中的多个条件。
static NSString *const SQL_IS=@"IS";//IS 运算符与 = 相似。
static NSString *const SQL_UNIQUE=@"UNIQUE";//UNIQUE 运算符搜索指定表中的每一行，确保唯一性（无重复）。
static NSString *const SQL_UPDATE=@"UPDATE";
static NSString *const SQL_SET=@"SET";
static NSString *const SQL_DELETE=@"DELETE";
static NSString *const SQL_OFFSET=@"OFFSET";
static NSString *const SQL_LIMIT=@"LIMIT";
static NSString *const SQL_DESC=@"DESC";
static NSString *const SQL_ASC=@"ASC";
static NSString *const SQL_GROUP=@"GROUP";
static NSString *const SQL_HAVING=@"HAVING";
static NSString *const SQL_ALTER=@"ALTER";
static NSString *const SQL_ADD=@"ADD";
static NSString *const SQL_COLUMN=@"COLUMN";
static NSString *const SQL_BEGIN=@"BEGIN";
static NSString *const SQL_TRANSACTION=@"TRANSACTION";
static NSString *const SQL_COMMIT=@"COMMIT";
static NSString *const SQL_ROLLBACK=@"ROLLBACK";
static NSString *const SQL_SEMICOLON=@";";//分号;
static NSString *const SQL_COMMA=@",";
static NSString *const SQL_VACUUM=@"VACUUM";
static NSString *const SQL_DEFAULT=@"DEFAULT";
static NSString *const SQL_CHECK=@"CHECK";
static NSString *const SQL_AUTOINCREMENT=@"AUTOINCREMENT";
#pragma make - ============ 宏定义 ============
#define SQLlStrAppendString(lang) if(lang){[self.sqllStr appendString:lang];}
#define SQLlStrAppendSPACE SQLlStrAppendString(SQL_SPACE)
#define SQLlStrAppendAndSPACE(lang) SQLlStrAppendString(lang); SQLlStrAppendString(SQL_SPACE)

@interface SQLiteLanguage()
@property(nonatomic,copy)NSMutableString *sqllStr;
@end
@implementation SQLiteLanguage
-(instancetype)init{
    if (self=[super init]) {
        _sqllStr=[[NSMutableString alloc] init];
    }
    return self;
}
#pragma mark - ============ 数据类型 ============
-(SQLiteLanguage *)INTEGER{
    SQLlStrAppendAndSPACE(SQL_INTEGER);
    return self;
}
-(SQLiteLanguage *)REAL{
    SQLlStrAppendAndSPACE(SQL_REAL);
    return self;
}
-(SQLiteLanguage *)TEXT{
    SQLlStrAppendAndSPACE(SQL_TEXT);
    return self;
}
-(SQLiteLanguage *)BLOB{
    SQLlStrAppendAndSPACE(SQL_BLOB);
    return self;
}
#pragma mark ============ 创建表 ============
-(SQLiteLanguage *)CREATE{
    SQLlStrAppendAndSPACE(SQL_CREATE);
    return self;
}
-(SQLiteLanguage *)INSERT{
    SQLlStrAppendAndSPACE(SQL_INSERT);
    return self;
}
-(SQLiteLanguage *)PRIMARY{
    SQLlStrAppendAndSPACE(SQL_PRIMARY);
    return self;
}
- (SQLiteLanguage * (^)(NSString *value))NOT{
    return ^SQLiteLanguage *(NSString *value){
        SQLlStrAppendAndSPACE(SQL_NOT);
        SQLlStrAppendAndSPACE(value);
        return self;
    };
}
-(SQLiteLanguage *)FOREIGN{
    SQLlStrAppendAndSPACE(SQL_FOREIGN);
    return self;
}
-(SQLiteLanguage * (^)(NSString *tableName))REFERENCES{
    return ^SQLiteLanguage *(NSString *tableName){
        SQLlStrAppendAndSPACE(SQL_REFERENCES);
        SQLlStrAppendAndSPACE(tableName);
        
        return self;
    };
}
- (SQLiteLanguage * (^)(NSString *name))TABLE{
    return ^SQLiteLanguage *(NSString *name){
        SQLlStrAppendAndSPACE(SQL_TABLE);
        SQLlStrAppendAndSPACE(name);
        return self;
    };
}
- (SQLiteLanguage * (^)(NSString *fristName,...))KEY{
    return ^SQLiteLanguage *(NSString *fristName,...){
        NSMutableArray *array = [NSMutableArray array];
        if (fristName){
            va_list argsList;
            [array addObject:fristName];
            va_start(argsList, fristName);
            id arg;
            while ((arg = va_arg(argsList, id))){
                [array addObject:arg];
            }
            va_end(argsList);
        }
        if (array.count) {
            SQLlStrAppendAndSPACE(([NSString stringWithFormat:@"%@(%@) ",SQL_KEY,[array componentsJoinedByString:@","]]));
        }else{
            SQLlStrAppendAndSPACE(SQL_KEY);
        }
        return self;
    };
}
-(SQLiteLanguage * (^)(NSString *name))columnName{
    return ^SQLiteLanguage *(NSString *name){
        SQLlStrAppendAndSPACE(name);
        return self;
    };
}
-(SQLiteLanguage * (^)(NSString *name))CONSTRAINT{
    return ^SQLiteLanguage *(NSString *name){
        SQLlStrAppendAndSPACE(SQL_CONSTRAINT);
        SQLlStrAppendAndSPACE(name);
        return self;
    };
}
- (SQLiteLanguage * (^)(id fristColumn,...))COLUMNS{
    return ^SQLiteLanguage*(id fristColumn,...){
        NSMutableArray *array = [NSMutableArray array];
        if (fristColumn){
            va_list argsList;
            [array addObject:fristColumn];
            va_start(argsList, fristColumn);
            id arg;
            while ((arg = va_arg(argsList, id))){
                [array addObject:arg];
            }
            va_end(argsList);
        }
        __block NSMutableArray *subSqllArray=[[NSMutableArray alloc] init];
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if([obj isKindOfClass:[SQLiteLanguage class]]){
                SQLiteLanguage *sqliteLanguage=obj;
                [subSqllArray addObject:sqliteLanguage.sql];
            }else if ([obj isKindOfClass:[NSString class]]){
                [subSqllArray addObject:obj];
            }
        }];
        SQLlStrAppendAndSPACE(([NSString stringWithFormat:@"(%@)",[subSqllArray componentsJoinedByString:@","]]));
        return self;
    };
}
#pragma mark - ============ 约束 ============
- (SQLiteLanguage *)UNIQUE{
    SQLlStrAppendAndSPACE(SQL_UNIQUE);
    return self;
}
- (SQLiteLanguage * (^)(NSString *value))DEFAULT{
    return ^SQLiteLanguage *(NSString *value){
        SQLlStrAppendAndSPACE(SQL_DEFAULT);
        SQLlStrAppendAndSPACE(value);
        return self;
    };
}
- (SQLiteLanguage * (^)(NSString *condition))CHECK{
    return ^SQLiteLanguage *(NSString *condition){
        SQLlStrAppendAndSPACE(SQL_CHECK);
        SQLlStrAppendAndSPACE(([NSString stringWithFormat:@"(%@)",condition]));
        return self;
    };
}
- (SQLiteLanguage *)AUTOINCREMENT{
    SQLlStrAppendAndSPACE(SQL_AUTOINCREMENT);
    return self;
}
#pragma mark ============ 删除表 ============
-(SQLiteLanguage *)DROP{
    SQLlStrAppendAndSPACE(SQL_DROP);
    return self;
}
#pragma mark ============ SELECT查询 ============
- (SQLiteLanguage * (^)(NSString * condition,NSString *fristName,...))SELECT{
    return ^SQLiteLanguage *(NSString *condition,NSString *fristName,...){
        NSMutableArray *array = [NSMutableArray array];
        if (fristName){
            va_list argsList;
            [array addObject:fristName];
            va_start(argsList, fristName);
            id arg;
            while ((arg = va_arg(argsList, id))){
                [array addObject:arg];
            }
            va_end(argsList);
        }
        if (array.count) {
            SQLlStrAppendAndSPACE(([NSString stringWithFormat:@"%@ %@ %@ ",SQL_SELECT,condition,[array componentsJoinedByString:@","]]));
        }else{
            SQLlStrAppendAndSPACE(SQL_SELECT);
            SQLlStrAppendAndSPACE(condition);
        }
        return self;
    };
}
- (SQLiteLanguage * (^)(NSString *tableName))FROM{
    return ^SQLiteLanguage *(NSString *tableName){
        SQLlStrAppendAndSPACE(SQL_FROM);
        SQLlStrAppendAndSPACE(tableName);
        return self;
    };
}
- (SQLiteLanguage * (^)(NSString *rows))LIMIT{
    return ^SQLiteLanguage *(NSString *rows){
        SQLlStrAppendAndSPACE(SQL_LIMIT);
        SQLlStrAppendAndSPACE(rows);
        return self;
    };
}
- (SQLiteLanguage * (^)(NSString *rowNumber))OFFSET{
    return ^SQLiteLanguage *(NSString *rowNumber){
        SQLlStrAppendAndSPACE(SQL_OFFSET);
        SQLlStrAppendAndSPACE(rowNumber);
        return self;
    };
}
- (SQLiteLanguage * (^)(NSString *name))WHERE{
    return ^SQLiteLanguage *(NSString *name){
        SQLlStrAppendAndSPACE(SQL_WHERE);
        SQLlStrAppendAndSPACE(name);
        return self;
    };
}
#pragma mark ============ 表数据插入 ============
- (SQLiteLanguage * (^)(NSString *tableName))INTO{
    return ^SQLiteLanguage *(NSString *tableName){
        SQLlStrAppendAndSPACE(SQL_INTO);
        SQLlStrAppendAndSPACE(tableName);
        return self;
    };
}

- (SQLiteLanguage * (^)(NSString *fristValue,...))VALUES{
    return ^SQLiteLanguage *(NSString *fristValue,...){
        NSMutableArray *array = [NSMutableArray array];
        if (fristValue){
            va_list argsList;
            [array addObject:fristValue];
            va_start(argsList, fristValue);
            id arg;
            while ((arg = va_arg(argsList, id))){
                [array addObject:arg];
            }
            va_end(argsList);
        }
        if (array.count) {
            SQLlStrAppendAndSPACE(([NSString stringWithFormat:@"%@(%@) ",SQL_VALUES,[array componentsJoinedByString:@","]]));
        }else{
            SQLlStrAppendAndSPACE(SQL_VALUES);
        }
        return self;
    };
}
#pragma mark ============ 运算符 ============
- (SQLiteLanguage * (^)(NSString *value))AND{
    return ^SQLiteLanguage *(NSString *value){
        SQLlStrAppendAndSPACE(SQL_AND);
        SQLlStrAppendAndSPACE(value);
        return self;
    };
}
- (SQLiteLanguage * (^)(NSString *value))OR{
    return ^SQLiteLanguage *(NSString *value){
        SQLlStrAppendAndSPACE(SQL_OR);
        SQLlStrAppendAndSPACE(value);
        return self;
    };
}
- (SQLiteLanguage * (^)(SQLiteLanguage *sqll))EXISTS{
    return ^SQLiteLanguage*(SQLiteLanguage *sqll){
        SQLlStrAppendAndSPACE(([NSString stringWithFormat:@"%@(%@)",SQL_EXISTS,sqll.sql]));
        return self;
    };
}
- (SQLiteLanguage * (^)(NSString *value))BETWEEN{
    return ^SQLiteLanguage *(NSString *value){
        SQLlStrAppendAndSPACE(SQL_BETWEEN);
        SQLlStrAppendAndSPACE(value);
        return self;
    };
}
- (SQLiteLanguage * (^)(NSString *value))LIKE{
    return ^SQLiteLanguage *(NSString *value){
        SQLlStrAppendAndSPACE(SQL_LIKE);
        SQLlStrAppendAndSPACE(value);
        return self;
    };
}
- (SQLiteLanguage * (^)(NSString *value))IS{
    return ^SQLiteLanguage *(NSString *value){
        SQLlStrAppendAndSPACE(SQL_IS);
        SQLlStrAppendAndSPACE(value);
        return self;
    };
}

- (SQLiteLanguage * (^)(NSString *value))GLOB{
    return ^SQLiteLanguage *(NSString *value){
        SQLlStrAppendAndSPACE(SQL_GLOB);
        SQLlStrAppendAndSPACE(value);
        return self;
    };
}
- (SQLiteLanguage * (^)(NSString *value,...))IN{
    return ^SQLiteLanguage *(NSString *value,...){
        NSMutableArray *array = [NSMutableArray array];
        if (value){
            va_list argsList;
            [array addObject:value];
            va_start(argsList, value);
            id arg;
            while ((arg = va_arg(argsList, id))){
                [array addObject:arg];
            }
            va_end(argsList);
        }
        if (array.count) {
            SQLlStrAppendAndSPACE(([NSString stringWithFormat:@"%@(%@) ",SQL_IN,[array componentsJoinedByString:@","]]));
        }else{
            SQLlStrAppendAndSPACE(SQL_IN);
        }
        return self;
    };
}
#pragma mark ============ UPDATE更新表数据 ============
-(SQLiteLanguage * (^)(NSString *tableName))UPDATE{
    return ^SQLiteLanguage *(NSString *tableName){
        SQLlStrAppendAndSPACE(SQL_UPDATE);
        SQLlStrAppendAndSPACE(tableName);
        return self;
    };
}
- (SQLiteLanguage * (^)(NSString *keyAndValue,...))SET{
    return ^SQLiteLanguage *(NSString *keyAndValue,...){
        
        NSMutableArray *array = [NSMutableArray array];
        if (keyAndValue){
            va_list argsList;
            [array addObject:keyAndValue];
            va_start(argsList, keyAndValue);
            id arg;
            while ((arg = va_arg(argsList, id))){
                [array addObject:arg];
            }
            va_end(argsList);
        }
        if (array.count) {
            SQLlStrAppendAndSPACE(([NSString stringWithFormat:@"%@ %@",SQL_SET,[array componentsJoinedByString:@","]]));
        }else{
            SQLlStrAppendAndSPACE(SQL_IN);
        }
        return self;
    };
}
#pragma mark ============ DELETE删除表数据 ============
-(SQLiteLanguage *)DELETE{
    SQLlStrAppendAndSPACE(SQL_DELETE);
    return self;
}
#pragma mark ============ ORDER BY排序 ============
- (SQLiteLanguage * (^)(NSString *name))BY{
    return ^SQLiteLanguage *(NSString *name){
        SQLlStrAppendAndSPACE(SQL_BY);
        SQLlStrAppendAndSPACE(name);
        return self;
    };
}
-(SQLiteLanguage *)ORDER{
    SQLlStrAppendAndSPACE(SQL_ORDER);
    return self;
}
-(SQLiteLanguage *)DESC{
    SQLlStrAppendAndSPACE(SQL_DESC);
    return self;
}
-(SQLiteLanguage *)ASC{
    SQLlStrAppendAndSPACE(SQL_ASC);
    return self;
}
#pragma mark ============ GROUP BY排序 ============
-(SQLiteLanguage *)GROUP{
    SQLlStrAppendAndSPACE(SQL_GROUP);
    return self;
}
- (SQLiteLanguage * (^)(NSString *value))HAVING{
    return ^SQLiteLanguage *(NSString *value){
        SQLlStrAppendAndSPACE(SQL_HAVING);
        SQLlStrAppendAndSPACE(value);
        return self;
    };
}
#pragma mark ============ ALTER修改表 ============
-(SQLiteLanguage * (^)(NSString *name))COLUMN;{
    return ^SQLiteLanguage*(NSString *name){
        SQLlStrAppendAndSPACE(SQL_COLUMN);
        SQLlStrAppendAndSPACE(name);
        return self;
    };
}
-(SQLiteLanguage *)ALTER{
    SQLlStrAppendAndSPACE(SQL_ALTER);
    return self;
}
-(SQLiteLanguage * (^)(NSString *value))ADD{
    return ^SQLiteLanguage *(NSString *value){
        SQLlStrAppendAndSPACE(SQL_ADD);
        SQLlStrAppendAndSPACE(value);
        return self;
    };
}
#pragma mark ============ 事务 ============
-(SQLiteLanguage *)BEGIN{
    SQLlStrAppendAndSPACE(SQL_BEGIN);
    return self;
}
-(SQLiteLanguage *)TRANSACTION{
    SQLlStrAppendAndSPACE(SQL_TRANSACTION);
    return self;
}
-(SQLiteLanguage *)COMMIT{
    SQLlStrAppendAndSPACE(SQL_COMMIT);
    return self;
}
-(SQLiteLanguage *)ROLLBACK{
    SQLlStrAppendAndSPACE(SQL_ROLLBACK);
    return self;
}
#pragma mark ============ VACUUM ============
- (SQLiteLanguage * (^)(NSString *name))VACUUM{
    return ^SQLiteLanguage *(NSString *name){
        SQLlStrAppendAndSPACE(SQL_VACUUM);
        SQLlStrAppendAndSPACE(name);
        return self;
    };
}
#pragma mark ============ 其他 ============
-(SQLiteLanguage *(^)(SQLiteLanguage *sqll))APPEND{
    return ^SQLiteLanguage*(SQLiteLanguage *sqll){
        SQLlStrAppendAndSPACE(sqll.sql);
        return self;
    };
}
-(SQLiteLanguage *)SEMICOLON{
    SQLlStrAppendAndSPACE(SQL_SEMICOLON);
    return self;
}
-(SQLiteLanguage *)COMMA{
    SQLlStrAppendAndSPACE(SQL_COMMA);
    return self;
}
-(SQLiteLanguage*)RESET{
    _sqllStr=[[NSMutableString alloc] init];
    return self;
}
#pragma mark ============ GET方法 ============
-(NSString *)sql{
    return _sqllStr;
}
@end
