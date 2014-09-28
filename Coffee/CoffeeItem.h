//
//  CoffeeItem.h
//  Coffee
//
//  Created by Blake Sawyer on 9/16/14.
//  Copyright (c) 2014 Blake Sawyer. All rights reserved.
//

#import "Mantle.h"
#import "MTLModel.h"

@interface CoffeeItem : MTLModel <MTLJSONSerializing>

@property (nonatomic,copy,readonly) NSString *name;
@property (nonatomic,copy,readonly) NSString *description;
@property (nonatomic,copy,readonly) NSURL *imageURL;
@property (nonatomic,retain,readwrite) UIImage *image;
@property (nonatomic,copy,readonly) NSString *coffeeID;
@property (nonatomic,copy,readwrite) NSDate *lastUpdated;

@end
