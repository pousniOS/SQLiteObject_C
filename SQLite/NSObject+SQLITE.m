//
//  NSObject+SQLITE.m
//  SQLiteObject_C
//
//  Created by POSUN-MAC on 2018/7/23.
//  Copyright © 2018年 POSUN-MAC. All rights reserved.
//

#import "NSObject+SQLITE.h"
#import "NSObject+Dictionary.h"

#define SQLITE_TABLE_PRIMARYKEY_ID @"SQLITE_TABLE_PRIMARYKEY_ID"
#define SQLITE_TABLE_FOREIGNKEY_ID @"SQLITE_TABLE_FOREIGNKEY_ID"
#define SQLITE_TABLE_DEFULTKEY_TYPE @"unsigned long long"
#define SQLITE_DATABASEE @"SQLIT_DATABASEE.db"
@implementation NSObject (SQLITE)
+(NSString *)dbPath{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:[NSString stringWithFormat:@"/%@",SQLITE_DATABASEE]];
}
+(BOOL)tableIsExist{
    [self dbOpen];
    SHARESQLITEObjectC.SQLL.RESET.SELECT(@"count(*)",nil).FROM(@"sqlite_master").WHERE(@"type='table'").AND([NSString stringWithFormat:@"tbl_name='%@'",[self tableName]]);
    if (SHARESQLITEObjectC.execSQLL) {
        NSDictionary *countDic = [SHARESQLITEObjectC.execSQLResultArray firstObject];
        NSString *countStr=[countDic objectForKey:@"count(*)"];
        return [countStr integerValue];
    }else{
        return NO;
    }
}
+(NSArray *)analyticalBuildTableField{
    NSArray *fieldArray =[self propertyInforArray];
    fieldArray=[self filterProperty:[self table_UnconversionProperty]];
    fieldArray=[self checkSetKEY:fieldArray andKey:[self table_PrimaryKey]];
    fieldArray=[self checkSetKEY:fieldArray andKey:[self table_ForeignKey]];
    return fieldArray;
}
+(BOOL)tableCreate{
    return [self tableCreateWithFOREIGNKEYTable:nil];
}
+(BOOL)tableCreateWithFOREIGNKEYTable:(NSString *)tableName{
    if ([self tableIsExist]) {
        return YES;
    }
    NSArray *fieldArray =[self analyticalBuildTableField];
    SQLiteLanguage *sql =SQLlang;
    [fieldArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *propertyType=obj[PropertyType];
        NSString *propertyName=obj[PropertyName];
        
        if ([self isStringType:propertyType]) {
            sql.columnName(propertyName);
            [sql TEXT];
        }else if ([self isCNumberType:propertyType]){
            sql.columnName(propertyName);
            [sql INTEGER];
        }else if ([self isCFNumberType:propertyType]){
            sql.columnName(propertyName);
            [sql REAL];
        }else if ([self isValueType:propertyType]){
            sql.columnName(propertyName);
            [sql REAL];
        }else if ([self isArrayType:propertyType]){
            NSDictionary *dic=[self table_ArrayPropertyNameAndElementTypeDictionary];
            NSString *type =dic[propertyName];
            if (type) {
                Class class=NSClassFromString(type);
                NSString *FOREIGNKEY_FROMTABLE=[class table_ForeignKeyFromTable];
                if (!FOREIGNKEY_FROMTABLE) {
                    FOREIGNKEY_FROMTABLE=[self tableName];
                }
                [class tableCreateWithFOREIGNKEYTable:FOREIGNKEY_FROMTABLE];
                
            }else{
                sql.columnName(propertyName);
                [sql TEXT];
            }
        }else if ([self isDictionaryType:propertyType]){
            sql.columnName(propertyName);
            [sql TEXT];
        }else{
            Class class=NSClassFromString(propertyType);
            NSString *FOREIGNKEY_FROMTABLE=[class table_ForeignKeyFromTable];
            if (!FOREIGNKEY_FROMTABLE) {
                FOREIGNKEY_FROMTABLE=[self tableName];
            }
            [class tableCreateWithFOREIGNKEYTable:FOREIGNKEY_FROMTABLE];
        }
        if ([propertyName isEqualToString:[self table_PrimaryKey]]) {
            sql.PRIMARY.KEY(nil);
            if ([propertyName isEqualToString:SQLITE_TABLE_PRIMARYKEY_ID]) {
                [sql AUTOINCREMENT];
            }
        }
        if ([propertyName isEqualToString:[self table_ForeignKey]]) {
            sql.FOREIGN.KEY(propertyName,nil).REFERENCES([NSString stringWithFormat:@"%@(%@)",tableName,[self table_ForeignKeyFromTable]]);
        }
        [sql COMMA];
    }];
    SHARESQLITEObjectC.SQLL.RESET.CREATE.TABEL(NSStringFromClass(self)).COLUMNS(sql,nil);

    NSLog(@"%@",SHARESQLITEObjectC.SQLL.sql);
    return NO;//SHARESQLITEObjectC.execSQLL;
}

+(BOOL)tableDrop{
    return YES;
}
+(BOOL)dbOpen{
    if (SHARESQLITEObjectC.isOpen) {
        if ([SHARESQLITEObjectC.dbPath isEqualToString:self.dbPath]) {
            return YES;
        }else{
            if ([SHARESQLITEObjectC close]) {
                return [SHARESQLITEObjectC openWithFilePath:self.dbPath];
            }else{
                return NO;
            }
        }
    }else{
        return [SHARESQLITEObjectC openWithFilePath:self.dbPath];
    }
}
+(NSArray *)checkSetKEY:(NSArray *)propertys andKey:(NSString *)key{
    __block BOOL flag=NO;
    [propertys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj[PropertyName] isEqualToString:key]) {
            flag=YES;
            *stop=YES;
        }
    }];
    if (!flag) {
        NSMutableArray *array=[propertys mutableCopy];
        [array addObject:@{
                           PropertyName:key,
                           PropertyType:SQLITE_TABLE_DEFULTKEY_TYPE,
                           }];
        propertys=array;
    }
    return propertys;
}
+(NSString *)tableName{
    return NSStringFromClass(self);
}
+(NSSet*)table_UnconversionProperty{
    return nil;
}
+(NSString *)table_PrimaryKey{
    return SQLITE_TABLE_PRIMARYKEY_ID;
}
+(NSString*)table_ForeignKey{
    return SQLITE_TABLE_FOREIGNKEY_ID;
}
+(NSDictionary*)table_ArrayPropertyNameAndElementTypeDictionary{
    return nil;
}
+(NSString*)table_ForeignKeyFromKey{
    return SQLITE_TABLE_PRIMARYKEY_ID;
}
+(NSString*)table_ForeignKeyFromTable{
    return nil;
}
@end
