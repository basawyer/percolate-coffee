//
//  CoffeeTableViewCell.h
//  Coffee
//
//  Created by Blake Sawyer on 9/16/14.
//  Copyright (c) 2014 Blake Sawyer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoffeeItem.h"

@interface CoffeeTableViewCell : UITableViewCell

@property (nonatomic,strong,readonly) CoffeeItem *item;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier coffeeItem:(CoffeeItem*)item;
+ (CGFloat)cellHeightForCoffeeItem:(CoffeeItem*)item;

@end
