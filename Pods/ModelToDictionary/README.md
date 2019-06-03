# ModelToDictionary
**前言**

在项目开发中，将Model对象数据转换成NSDictionary对象(或包含NSDictionary对象的数组)，然后通过接口提交给服务器是开发中频繁需要做的事情，然而手动的去拼写NSDictionary对象既麻烦又容易出错。所以我就写了这样的一个功能，可以将Model对象数据转换成NSDictionary对象。并且可以重写Model类方法来重命名生成的字典的key以及可以屏蔽掉一些在生成NSDictionary对象不需要的键值对。

---
1.只需在项目里引入NSObject+Dictionary类别,然后调用“-(NSDictionary *)toDictionary”方法例如：
```
//给test对象赋值（注意填写正确的文件路径）
NSString *str=[NSString stringWithContentsOfFile:@"/Users/POSUN/Documents/ModelToDictionary/ModelToDictionary/TestJson.json" encoding:NSUTF8StringEncoding error:nil];

if (str == nil){return;}
NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
NSError *error=nil;
NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
options:NSJSONReadingMutableContainers
error:&error];
TEST *test=[[TEST alloc] init];
[test setValuesForKeysWithDictionary:dic];

//将test对象转换传NSDictionary对象
NSDictionary *testDic=[test toDictionary];
NSLog("%@",testDic);

```
运行结果：
```
2018-07-16 17:25:07.007223+0800 ModelToDictionary[3678:582786] {
salesOrder =     {
assistant1 = xxx;
assistantId = 000001;
deliveryType = Y;
deliveryTypeName = "\U9001\U8d27\U4e0a\U95e8";
needInstall = Y;
number = 4534;
orderDate = 1525507xxx;
orgId = A;
orgName = "xxx\U6709\U9650\U516c\U53f8";
priceSum = "3.000000";
refundType = 1;
requireArriveDate = 1525593xxx;
salesOrderParts =         {
billPrice = "3.00";
goods =             {
Id = "";
enableSn = "";
giftFlag = "";
goodsTypeName = "";
partName = "xxxCFXB50YB8-70//4";
pnModel = 5L;
serialRuleId = "";
};
partRecId = "01.01.01.400050";
priceRate = "0.000000";
qtyPlan = 1;
unitId = tai;
unitName = "\U53f0";
unitPrice = 3;
};
subscribeDispatch = N;
warehouseId = 1013;
warehouseName = "xxx\U5e93";
};
salesRefund =     {
assistant1 = xxx;
assistantId = 000001;
buyerId = QB027;
buyerName = xxx;
orderDate = 1525507xxx;
orgId = A;
orgName = "xxx\U6709\U9650\U516c\U53f8";
priceSum = "3.000000";
refundType = 1;
requireArriveDate = 1525593xxx;
salesOrderParts =         {
billPrice = "3.00";
goods =             {
Id = "";
enableSn = "";
goodsTypeId = "";
goodsTypeName = "";
partName = "xxxCFXB40YB8-70//4";
pnModel = 4L;
serialRuleId = "";
unitId = "";
unitName = "";
};
partRecId = "01.01.01.400043";
priceRate = "0.000000";
qtyPlan = 1;
unitId = tai;
unitName = "\U53f0";
unitPrice = 3;
};
warehouseId = 1011;
warehouseName = "xxx\U5e93";
};
testDouble = 0;
}
```
---
2.重置生成NSdictionary对象的Key,需要在对应的Model类重写“-(NSDictionary*)YYMTD_ResetKeyDictionary”例如：

```
#import "TEST.h"
@implementation TEST
-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
NSLog(@"UndefinedKey:%@",key);
};
-(void)setValue:(id)value forKey:(NSString *)key{
if([key isEqualToString:@"salesRefund"]){
self.salesRefund=[[SalesRefund alloc] init];
[self.salesRefund setValuesForKeysWithDictionary:value];
}else if([key isEqualToString:@"salesOrder"]){
self.salesOrder=[[SalesOrder alloc] init];
[self.salesOrder setValuesForKeysWithDictionary:value];
}else{
[super setValue:value forKey:key];
}
}

-(NSDictionary*)YYMTD_ResetKeyDictionary{
return @{
@"salesOrder":@"SO",
};
}
@end
```
然后调用“-(NSDictionary *)toDictionary”运行结果：
```
2018-07-16 17:26:12.677741+0800 ModelToDictionary[3699:584637] {
SO =     {
assistant1 = xxx;
assistantId = 000001;
deliveryType = Y;
deliveryTypeName = "\U9001\U8d27\U4e0a\U95e8";
needInstall = Y;
number = 4534;
orderDate = 1525507xxx;
orgId = A;
orgName = "xxx\U6709\U9650\U516c\U53f8";
priceSum = "3.000000";
refundType = 1;
requireArriveDate = 1525593xxx;
salesOrderParts =         {
billPrice = "3.00";
goods =             {
Id = "";
enableSn = "";
giftFlag = "";
goodsTypeName = "";
partName = "xxxCFXB50YB8-70//4";
pnModel = 5L;
serialRuleId = "";
};
partRecId = "01.01.01.400050";
priceRate = "0.000000";
qtyPlan = 1;
unitId = tai;
unitName = "\U53f0";
unitPrice = 3;
};
subscribeDispatch = N;
warehouseId = 1013;
warehouseName = "xxx\U5e93";
};
salesRefund =     {
assistant1 = xxx;
assistantId = 000001;
buyerId = QB027;
buyerName = xxx;
orderDate = 1525507xxx;
orgId = A;
orgName = "xxx\U6709\U9650\U516c\U53f8";
priceSum = "3.000000";
refundType = 1;
requireArriveDate = 1525593xxx;
salesOrderParts =         {
billPrice = "3.00";
goods =             {
Id = "";
enableSn = "";
goodsTypeId = "";
goodsTypeName = "";
partName = "xxxCFXB40YB8-70//4";
pnModel = 4L;
serialRuleId = "";
unitId = "";
unitName = "";
};
partRecId = "01.01.01.400043";
priceRate = "0.000000";
qtyPlan = 1;
unitId = tai;
unitName = "\U53f0";
unitPrice = 3;
};
warehouseId = 1011;
warehouseName = "xxx\U5e93";
};
testDouble = 0;
}
```
可以看到原本key为salesOrder的被修改成了SO。
---
3.生成NSdictionary时去掉不需要的键值对,需要在对应的Model类重写“-(NSSet*)YYMTD_UnconversionProperty”例如：
```
#import "TEST.h"
@implementation TEST
-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
NSLog(@"UndefinedKey:%@",key);
};
-(void)setValue:(id)value forKey:(NSString *)key{
if([key isEqualToString:@"salesRefund"]){
self.salesRefund=[[SalesRefund alloc] init];
[self.salesRefund setValuesForKeysWithDictionary:value];
}else if([key isEqualToString:@"salesOrder"]){
self.salesOrder=[[SalesOrder alloc] init];
[self.salesOrder setValuesForKeysWithDictionary:value];
}else{
[super setValue:value forKey:key];
}
}

-(NSSet *)YYMTD_UnconversionProperty{
NSSet *set=[[NSSet alloc] initWithObjects:@"salesRefund", nil];
return set;
}
@end
```
然后调用“-(NSDictionary *)toDictionary”运行结果：
```
2018-07-16 17:31:21.647170+0800 ModelToDictionary[3745:592039] {
salesOrder =     {
assistant1 = xxx;
assistantId = 000001;
deliveryType = Y;
deliveryTypeName = "\U9001\U8d27\U4e0a\U95e8";
needInstall = Y;
number = 4534;
orderDate = 1525507xxx;
orgId = A;
orgName = "xxx\U6709\U9650\U516c\U53f8";
priceSum = "3.000000";
refundType = 1;
requireArriveDate = 1525593xxx;
salesOrderParts =         {
billPrice = "3.00";
goods =             {
Id = "";
enableSn = "";
giftFlag = "";
goodsTypeName = "";
partName = "xxxCFXB50YB8-70//4";
pnModel = 5L;
serialRuleId = "";
};
partRecId = "01.01.01.400050";
priceRate = "0.000000";
qtyPlan = 1;
unitId = tai;
unitName = "\U53f0";
unitPrice = 3;
};
subscribeDispatch = N;
warehouseId = 1013;
warehouseName = "xxx\U5e93";
};
testDouble = 0;
}
```
可以看到生成的NSDictionary里salesRefund被去掉了。

**项目地址：https://github.com/pousniOS/ModelToDictionary**
