//
//  CoffeeTableViewCell.m
//  Coffee
//
//  Created by Blake Sawyer on 9/16/14.
//  Copyright (c) 2014 Blake Sawyer. All rights reserved.
//

#import "CoffeeTableViewCell.h"
#import "CoffeeAPIClient.h"
#import "UIImageView+AFNetworking.h"

#define IMAGE_HEIGHT 128.0

@interface CoffeeTableViewCell ()

@property (nonatomic,strong) CoffeeItem *item;
@property (nonatomic,strong) NSString *reuseID;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *descriptionLabel;
@property (nonatomic,strong) UIImageView *coffeeImageView;
@property (nonatomic) BOOL didSetupConstraints;


@end

@implementation CoffeeTableViewCell

+ (CGFloat)cellHeightForCoffeeItem:(CoffeeItem*)item{
    
    
    if(item.imageURL.relativeString.length == 0){ //No image default size
        
        return 70.0f + (3*8.0f);
    }
    else{

        return IMAGE_HEIGHT + 70.0f + (4*8.0f);
        
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier coffeeItem:(CoffeeItem*)item{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        //Initialize
        //self.reuseID = reuseIdentifier;
        self.item = item;
        self.didSetupConstraints = NO;
        
        //Add detail button
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        //Add title label
        self.titleLabel = [UILabel new];
        [self.titleLabel setTextColor:[UIColor blackColor]];
        [self.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f]];
        [self.titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.titleLabel.text = self.item.name;
        [self.contentView addSubview:self.titleLabel];
        
        //Add description label
        self.descriptionLabel = [UILabel new];
        [self.descriptionLabel setTextColor:[UIColor grayColor]];
        [self.descriptionLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f]];
        [self.descriptionLabel setMinimumScaleFactor:12.0/self.descriptionLabel.font.pointSize];
        [self.descriptionLabel setNumberOfLines:2];
        self.descriptionLabel.text = self.item.description;
        [self.descriptionLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addSubview:self.descriptionLabel];
        
        //Add image view if url
        if([[self.item.imageURL relativeString] length] > 0){
            
            //Add image view
            self.coffeeImageView = [UIImageView new];
            [self.coffeeImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
            [self.contentView addSubview:self.coffeeImageView];
            
            if(self.item.image == nil){
                
                //Load image
                //Load the image from URL using AFNetworking
                __weak CoffeeTableViewCell *weakSelf = self;
                
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
                           weakSelf.didSetupConstraints = NO;
                           [weakSelf setNeedsUpdateConstraints];
                           [[weakSelf superview] setNeedsUpdateConstraints];
                       });
                       
                   }

                                                     failure:NULL];

            }
            else{
                
                self.coffeeImageView.image = self.item.image;
            }
            
        }
        
        [self setNeedsUpdateConstraints];

    }
    
    return self;
}

- (void)updateConstraints {
    
    if (self.didSetupConstraints == NO){
        [self setupConstraints];
    }
    [super updateConstraints];
    
}

-(void)setupConstraints{
    
    //return;
    
    if(self.titleLabel == nil || self.descriptionLabel == nil) return;
   
    NSDictionary *views = @{ @"titleLabel" : self.titleLabel, @"descriptionLabel" : self.descriptionLabel };
    
    
    if(self.item.image){  //We have image view
        
         views = @{ @"titleLabel" : self.titleLabel, @"descriptionLabel" : self.descriptionLabel, @"coffeeImageView" : self.coffeeImageView };
        
        //Vert labels
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[titleLabel(==20)][descriptionLabel(==40)]-5-[coffeeImageView(==imageHeight)]"
                                                                     options:NSLayoutFormatDirectionLeadingToTrailing
                                                                     metrics:@{@"imageHeight":@IMAGE_HEIGHT}
                                                                       views:views]];
        
        //Image view width
        CGFloat width = (self.item.image.size.width/self.item.image.size.height) * IMAGE_HEIGHT;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[coffeeImageView(==imageWidth)]"
                                                                     options:NSLayoutFormatDirectionLeadingToTrailing
                                                                     metrics:@{@"imageWidth": [NSNumber numberWithFloat:width]}
                                                                       views:views]];
    }
    else{//No image view
        
        //Just vertical labels
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[titleLabel(==20)][descriptionLabel(==40)]"
                                                                     options:NSLayoutFormatDirectionLeadingToTrailing
                                                                     metrics:nil
                                                                       views:views]];
     
    }

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[titleLabel]-|"
                                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                                 metrics:nil
                                                                   views:views]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[descriptionLabel]-|"
                                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                                 metrics:nil
                                                                   views:views]];
    
    self.didSetupConstraints = YES;
    
}

@end
