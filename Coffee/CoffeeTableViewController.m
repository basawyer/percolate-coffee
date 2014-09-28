//
//  CoffeeTableViewController.m
//  Coffee
//
//  Created by Blake Sawyer on 9/16/14.
//  Copyright (c) 2014 Blake Sawyer. All rights reserved.
//

#import "CoffeeTableViewController.h"
#import "CoffeeAPIClient.h"
#import "CoffeeTableViewCell.h"
#import "CoffeeDetailViewController.h"

@interface CoffeeTableViewController ()

@property (nonatomic,retain) NSArray *items;

@end

@implementation CoffeeTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
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
    
    [self refresh];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)refresh{
    
    //Register for notification from CoffeeAPI Client
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coffeeItemsUpdated) name:CoffeeDidRetrieveAllCoffeeItems object:nil];
    
    [[CoffeeAPIClient sharedClient] retrieveAllCoffeeItems];
}

-(void)coffeeItemsUpdated{
    
    self.items = [CoffeeAPIClient sharedClient].allCoffeeItems;
    [self.tableView reloadData];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CoffeeDidRetrieveAllCoffeeItems object:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return self.items.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row < 0 || indexPath.row >= self.items.count) return nil;
    
    CoffeeTableViewCell *cell = [[CoffeeTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CoffeeTableViewCell" coffeeItem:self.items[indexPath.row]];
    
    return cell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //NSLog(@"%d : %f",indexPath.row,[CoffeeTableViewCell cellHeightForCoffeeItem:[self.items objectAtIndex:indexPath.row]]);
    return [CoffeeTableViewCell cellHeightForCoffeeItem:[self.items objectAtIndex:indexPath.row]];

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CoffeeDetailViewController *detailView = [[CoffeeDetailViewController alloc] initWithCoffeeItem:[self.items objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:detailView animated:YES];
    
}

@end
