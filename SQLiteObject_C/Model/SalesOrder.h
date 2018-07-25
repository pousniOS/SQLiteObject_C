#import <Foundation/Foundation.h>
#import "SalesOrderParts.h"
@interface SalesOrder:NSObject
@property(nonatomic,copy)NSString  *deliveryType;
@property(nonatomic,copy)NSString  *orderDate;
@property(nonatomic,copy)NSString  *requireArriveDate;
@property(nonatomic,retain)NSMutableArray  *salesOrderParts;
@property(nonatomic,copy)NSString  *refundType;
@property(nonatomic,copy)NSString  *assistantId;
@property(nonatomic,copy)NSString  *deliveryTypeName;
@property(nonatomic,copy)NSString  *assistant1;
@property(nonatomic,copy)NSString  *needInstall;
@property(nonatomic,copy)NSString  *subscribeDispatch;
@property(nonatomic,copy)NSString  *warehouseId;
@property(nonatomic,copy)NSString  *orgId;
@property(nonatomic,copy)NSString  *warehouseName;
@property(nonatomic,copy)NSString  *orgName;
@property(nonatomic,copy)NSString  *priceSum;
@property(nonatomic,retain)NSNumber  *number;
@end
