//
//  NSString+SQLITE.m
//  SQLiteObject_C
//
//  Created by POSUN-MAC on 2018/9/4.
//  Copyright © 2018年 POSUN-MAC. All rights reserved.
//

#import "NSString+SQLITE.h"

@implementation NSString (SQLITE)
+ (NSString *)sqlite_getUUIDString{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    CFRelease(uuid_ref);
    CFRelease(uuid_string_ref);
    return [uuid lowercaseString];
}
@end
