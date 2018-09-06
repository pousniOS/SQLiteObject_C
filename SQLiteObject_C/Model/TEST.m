#import "TEST.h"
@implementation TEST
-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    NSLog(@"UndefinedKey:%@",key);
};
-(void)setValue:(id)value forKey:(NSString *)key{
    if([key isEqualToString:@"salesOrder"]){
        self.salesOrder=[[SalesOrder alloc] init];
        if ([value isKindOfClass:[NSDictionary class]]) {
            [self.salesOrder setValuesForKeysWithDictionary:value];
        }else{
            [super setValue:value forKey:key];
        }
    }else if([key isEqualToString:@"salesRefund"]){
        self.salesRefund=[[SalesRefund alloc] init];
        if ([value isKindOfClass:[NSDictionary class]]) {
            [self.salesRefund setValuesForKeysWithDictionary:value];
        }else{
            [super setValue:value forKey:key];
        }
    }else{
        [super setValue:value forKey:key];
        
    }
}
@end

