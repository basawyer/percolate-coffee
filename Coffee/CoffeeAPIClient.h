//
//  CoffeeAPIClient.h
//  Coffee
//
//  Created by Blake Sawyer on 9/16/14.
//  Copyright (c) 2014 Blake Sawyer. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import "CoffeeItem.h"

@interface CoffeeAPIClient : AFHTTPSessionManager

@property (nonatomic, strong) NSArray *allCoffeeItems;
@property (nonatomic, strong) CoffeeItem *lastCoffeeItem;

+ (instancetype)sharedClient;

-(void)retrieveAllCoffeeItems;
-(void)retrieveCoffeeItemForID:(NSString*)coffeeID;
-(NSURLRequest*)imageURLRequestForCoffeeItem:(CoffeeItem*)item;

@end

// Notification constants
extern NSString * const CoffeeDidRetrieveAllCoffeeItems;
extern NSString * const CoffeeDidNotRetrieveAllCoffeeItems;
extern NSString * const CoffeeDidRetrieveCoffeeItem;
extern NSString * const CoffeeDidNotRetrieveCoffeeItem;

