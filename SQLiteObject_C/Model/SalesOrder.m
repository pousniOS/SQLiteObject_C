#import "SalesOrder.h"
@implementation SalesOrder
-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    NSLog(@"UndefinedKey:%@",key);
};
-(void)setValue:(id)value forKey:(NSString *)key{
    if([key isEqualToString:@"salesOrderParts"]){
        self.salesOrderParts=[[NSMutableArray alloc] init];
        for(id object in value){
            SalesOrderParts *obj=[[SalesOrderParts alloc] init];
            if ([object isKindOfClass:[NSDictionary class]]) {
                [obj setValuesForKeysWithDictionary:object];
                [self.salesOrderParts addObject:obj];
            }else{
                [super setValue:value forKey:key];
            }
        }
    }else{
        [super setValue:value forKey:key];
        
    }
}
+(NSDictionary *)sqlite_tablePropertyNameAndElementTypeDictionary{
    return @{@"salesOrderParts":@"SalesOrderParts"};
}
@end



