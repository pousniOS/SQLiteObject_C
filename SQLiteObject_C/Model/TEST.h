#import <Foundation/Foundation.h>
#import "SalesRefund.h"
#import "SalesOrder.h"
#import "NSObject+Dictionary.h"
@interface TEST:NSObject
@property(nonatomic,retain)SalesRefund  *salesRefund;
@property(nonatomic,retain)SalesOrder  *salesOrder;
@property(nonatomic,assign)double testDouble;
@end
