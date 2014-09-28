//
//  CoffeeItem.m
//  Coffee
//
//  Created by Blake Sawyer on 9/16/14.
//  Copyright (c) 2014 Blake Sawyer. All rights reserved.
//

#import "CoffeeItem.h"

@implementation CoffeeItem

+ (NSDateFormatter*)dateFormatter{
    
    NSDateFormatter *dateFormmater = [[NSDateFormatter alloc] init];
    dateFormmater.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormmater.dateFormat = @"yyyy-MM-dd HH:mm:ss.SS";
    return dateFormmater;
    
}

+ (NSDictionary*)JSONKeyPathsByPropertyKey{
    
    return @{
        @"name" : @"name",
        @"description" : @"desc",
        @"imageURL" : @"image_url",
        @"coffeeID" : @"id",
        @"lastUpdated" : @"last_updated_at"
        };
}

+ (NSValueTransformer *)imageURLJSONTransformer{
    
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)lastUpdatedJSONTransformer{
    
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return [self.dateFormatter dateFromString:str];
    } reverseBlock:^(NSDate *date) {
        return [self.dateFormatter stringFromDate:date];
    }];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError **)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self == nil) return nil;
  
    
    return self;
}

@end
