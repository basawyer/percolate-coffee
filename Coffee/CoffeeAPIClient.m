//
//  CoffeeAPIClient.m
//  Coffee
//
//  Created by Blake Sawyer on 9/16/14.
//  Copyright (c) 2014 Blake Sawyer. All rights reserved.
//

#import "CoffeeAPIClient.h"

#define kCoffeeBaseUrl @"http://coffeeapi.percolate.com/api/coffee/"
#define kCoffeeAPIKey @"WuVbkuUsCXHPx3hsQzus4SE"

NSString * const CoffeeDidRetrieveAllCoffeeItems = @"net.blakesawyer.percolate.Coffee.DidRetrieveAllCoffeeItems";
NSString * const CoffeeDidNotRetrieveAllCoffeeItems = @"net.blakesawyer.percolate.Coffee.DidNotRetrieveAllCoffeeItems";
NSString * const CoffeeDidRetrieveCoffeeItem = @"net.blakesawyer.percolate.Coffee.DidRetrieveCoffeeItem";
NSString * const CoffeeDidNotRetrieveCoffeeItem = @"net.blakesawyer.percolate.Coffee.DidNotRetrieveCoffeeItem";

@implementation CoffeeAPIClient

+ (instancetype)sharedClient {
    static CoffeeAPIClient *sharedCoffeeAPIClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCoffeeAPIClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kCoffeeBaseUrl]];
    });
    return sharedCoffeeAPIClient;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    if (self = [super initWithBaseURL:url]) {
        
        AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
        self.responseSerializer = responseSerializer;
        //self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"image/jpeg", nil];
        
        self.requestSerializer = [AFHTTPRequestSerializer serializer];
        [self.requestSerializer setValue:@"application/json"
                      forHTTPHeaderField:@"Accept"];
        [self.requestSerializer setValue:@"application/json"
                      forHTTPHeaderField:@"Content-Type"];
        [self.requestSerializer setValue:kCoffeeAPIKey forHTTPHeaderField:@"api_key"];
        
        
        [self.reachabilityManager startMonitoring];
        _allCoffeeItems = [NSArray array];
        _lastCoffeeItem = nil;
    }
    return self;
}


- (void)handleError:(NSError *)error forTask:(NSURLSessionDataTask *)task {
    
    //Log error
}



-(void)retrieveAllCoffeeItems{
    
    if (self.reachabilityManager.networkReachabilityStatus == 0) {
        
        //Notify user of no network
        
        return;
    }
    
    self.allCoffeeItems = [NSArray array];
    
    __weak CoffeeAPIClient *weakSelf = self;
    
    [self GET:@""
   parameters:@{ @"api_key" : kCoffeeAPIKey }
       success:^(NSURLSessionDataTask *task, id responseObject) {
           
           //NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
           
           //NSLog(@"%@",responseString);
           
           NSArray *itemsJSONArray = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
           
           NSMutableArray *items = [NSMutableArray array];
           
           for(NSDictionary *dict in itemsJSONArray){
               
               CoffeeItem *newItem = [MTLJSONAdapter modelOfClass:[CoffeeItem class] fromJSONDictionary:dict error:nil];
               [items addObject:newItem];
           }
           
           self.allCoffeeItems = [items copy];
           
           [[NSNotificationCenter defaultCenter] postNotificationName:CoffeeDidRetrieveAllCoffeeItems object:weakSelf];
       }
       failure:^(NSURLSessionDataTask *task, NSError *error) {
           [[NSNotificationCenter defaultCenter] postNotificationName:CoffeeDidNotRetrieveAllCoffeeItems object:nil];
           [weakSelf handleError:error forTask:task];
       }];
    
    
}

-(void)retrieveCoffeeItemForID:(NSString*)coffeeID{
    
    if (self.reachabilityManager.networkReachabilityStatus == 0) {
        
        //Notify user of no network
        
        return;
    }
    
    __weak CoffeeAPIClient *weakSelf = self;
    
    [self GET:coffeeID
    parameters:@{ @"api_key":kCoffeeAPIKey }
       success:^(NSURLSessionDataTask *task, id responseObject) {
           
           NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
           
           self.lastCoffeeItem = [MTLJSONAdapter modelOfClass:[CoffeeItem class] fromJSONDictionary:dict error:nil];
           
           [[NSNotificationCenter defaultCenter] postNotificationName:CoffeeDidRetrieveCoffeeItem object:weakSelf];
       }
       failure:^(NSURLSessionDataTask *task, NSError *error) {
           [[NSNotificationCenter defaultCenter] postNotificationName:CoffeeDidNotRetrieveCoffeeItem object:nil];
           [weakSelf handleError:error forTask:task];
       }];
    
}

-(NSURLRequest*)imageURLRequestForCoffeeItem:(CoffeeItem*)item{
    
    return [NSURLRequest requestWithURL:item.imageURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    
}

@end
