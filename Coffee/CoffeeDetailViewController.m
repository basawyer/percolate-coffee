//
//  CoffeeDetailViewController.m
//  Coffee
//
//  Created by Blake Sawyer on 9/16/14.
//  Copyright (c) 2014 Blake Sawyer. All rights reserved.
//

#import "CoffeeDetailViewController.h"
#import "CoffeeAPIClient.h"
#import "CoffeeItem.h"
#import "UIImageView+AFNetworking.h"

@interface CoffeeDetailViewController ()

@property (nonatomic,strong) CoffeeItem *item;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UIView *separator;
@property (nonatomic,strong) UILabel *descriptionLabel;
@property (nonatomic,strong) UIImageView *coffeeImageView;
@property (nonatomic,strong) UILabel *lastUpdatedLabel;

@end

@implementation CoffeeDetailViewController

-(id)initWithCoffeeItem:(CoffeeItem*)item{
    
    self = [super init];
    if(self){
        self.item = item;
        
        
    }
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBar.topItem.title = @"";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareCoffeeItem)];
    
    //Add title label
    self.titleLabel = [UILabel new];
    [self.titleLabel setTextColor:[UIColor blackColor]];
    [self.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:22.0f]];
    [self.titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.titleLabel.text = self.item.name;
    [self.view addSubview:self.titleLabel];
    
    self.separator = [UIView new];
    [self.separator setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.separator.backgroundColor = [UIColor grayColor];
    [self.view addSubview:self.separator];
    
    //Add description label
    self.descriptionLabel = [UILabel new];
    self.descriptionLabel.text = self.item.description;
    [self.descriptionLabel setTextColor:[UIColor grayColor]];
    [self.descriptionLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f]];
    [self.descriptionLabel setPreferredMaxLayoutWidth:self.view.frame.size.width];
    [self.descriptionLabel setMinimumScaleFactor:12.0/self.descriptionLabel.font.pointSize];
    [self.descriptionLabel setNumberOfLines:4];
    [self.descriptionLabel setAdjustsFontSizeToFitWidth:YES];
    [self.descriptionLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.descriptionLabel];
    
    //Add lastUpdated label
    self.lastUpdatedLabel = [UILabel new];
    [self.lastUpdatedLabel setTextColor:[UIColor grayColor]];
    [self.lastUpdatedLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f]];
    [self.lastUpdatedLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.lastUpdatedLabel.text = @"";
    [self.view addSubview:self.lastUpdatedLabel];
    
    //Add image view if url, added activity indicator while loading image
    if([[self.item.imageURL relativeString] length] > 0){
        
        //Add image view
        self.coffeeImageView = [UIImageView new];
        [self.coffeeImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.view addSubview:self.coffeeImageView];
        
        //Load image
        if(self.item.image == nil){
            
            //Load image
            //Load the image from URL using AFNetworking
            __weak CoffeeDetailViewController *weakSelf = self;
            
            [self.coffeeImageView setImageWithURLRequest:[[CoffeeAPIClient sharedClient] imageURLRequestForCoffeeItem:self.item]
                                        placeholderImage:nil
                                                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                     
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         weakSelf.coffeeImageView.alpha = 0.0;
                                                         weakSelf.item.image = image;
                                                         weakSelf.coffeeImageView.image = weakSelf.item.image;
                                                         [UIView animateWithDuration:0.25
                                                                          animations:^{
                                                                              weakSelf.coffeeImageView.alpha = 1.0;
                                                                          }];
                                                     });
                                                     
                                                 }
             
                                                 failure:NULL];
            
        }
        else{
            
            self.coffeeImageView.image = self.item.image;
        }
        
        
    }
    
    if(self.item.lastUpdated == nil){
        
        //Register for notification from CoffeeAPI Client
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coffeeItemDownloaded:) name:CoffeeDidRetrieveCoffeeItem object:nil];
        
        [[CoffeeAPIClient sharedClient] retrieveCoffeeItemForID:self.item.coffeeID];
        
    }
    else{
        
        self.lastUpdatedLabel.text = [self relativeDateStringForDate:self.item.lastUpdated];
        
    }
    
    [self setupConstraints];

    

}

-(void)viewWillDisappear:(BOOL)animated{
    
    self.item = nil;
}

-(void)coffeeItemDownloaded:(NSNotification*)n{
    
    self.item.lastUpdated = [[CoffeeAPIClient sharedClient] lastCoffeeItem].lastUpdated;
    
    self.lastUpdatedLabel.text = [self relativeDateStringForDate:self.item.lastUpdated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.view setNeedsDisplay];
}

- (NSString *)relativeDateStringForDate:(NSDate *)date
{
    NSCalendarUnit units = NSDayCalendarUnit | NSWeekOfYearCalendarUnit |
    NSMonthCalendarUnit | NSYearCalendarUnit;
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:units
                                                                   fromDate:date
                                                                     toDate:[NSDate date]
                                                                    options:0];
    
    if (components.year > 0) {
        return [NSString stringWithFormat:@"%ld years ago", (long)components.year];
    } else if (components.month > 0) {
        return [NSString stringWithFormat:@"%ld months ago", (long)components.month];
    } else if (components.weekOfYear > 0) {
        return [NSString stringWithFormat:@"%ld weeks ago", (long)components.weekOfYear];
    } else if (components.day > 0) {
        if (components.day > 1) {
            return [NSString stringWithFormat:@"%ld days ago", (long)components.day];
        } else {
            return @"Yesterday";
        }
    } else {
        return @"Today";
    }
}

-(void)shareCoffeeItem{
    
    UIActivityViewController *shareController;
    
    if(self.item.image){
        
        shareController = [[UIActivityViewController alloc] initWithActivityItems:@[self.item.name,self.item.image] applicationActivities:nil];
    }
    else{
        
        shareController = [[UIActivityViewController alloc] initWithActivityItems:@[self.item.name, self.item.description] applicationActivities:nil];
    }
    
    [self presentViewController:shareController animated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupConstraints{
    
    if(self.titleLabel == nil || self.descriptionLabel == nil) return;
    
    NSDictionary *views = @{ @"titleLabel" : self.titleLabel, @"descriptionLabel" : self.descriptionLabel , @"separator" : self.separator, @"lastUpdatedLabel" : self.lastUpdatedLabel};
    
    
    if(self.item.image){  //We have image
        
        views = @{ @"titleLabel" : self.titleLabel, @"descriptionLabel" : self.descriptionLabel, @"separator" : self.separator, @"lastUpdatedLabel" : self.lastUpdatedLabel, @"coffeeImageView" : self.coffeeImageView };
        
        //Vert
        CGFloat height = (self.item.image.size.height/self.item.image.size.width) * self.view.frame.size.width;
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[titleLabel]-[separator(==1)]-[descriptionLabel(==80)]-[coffeeImageView(==imageHeight)]-[lastUpdatedLabel]"
                                                                     options:NSLayoutFormatDirectionLeadingToTrailing
                                                                     metrics:@{@"imageHeight": [NSNumber numberWithFloat:height]}
                                                                       views:views]];
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[coffeeImageView]-|"
                                                                          options:NSLayoutFormatDirectionLeadingToTrailing
                                                                          metrics:nil
                                                                            views:views]];

    }
    else{//No image view
        
        //Just vertical labels
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[titleLabel]-[separator(==1)]-[descriptionLabel(==80)]-[lastUpdatedLabel]"
                                                                     options:NSLayoutFormatDirectionLeadingToTrailing
                                                                     metrics:nil
                                                                       views:views]];
        
    }
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[titleLabel]-|"
                                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                                 metrics:nil
                                                                   views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[separator]-|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[descriptionLabel]-|"
                                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                                 metrics:nil
                                                                        views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[lastUpdatedLabel]-|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:views]];
    
}

@end
