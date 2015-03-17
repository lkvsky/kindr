//
//  KindrTableViewController.m
//  Kindr
//
//  Created by Kyle Lucovsky on 3/13/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

#import "KindrTableViewController.h"
#import "APIClient.h"
#import "Post.h"
#import "PostDetailViewController.h"
#import "PostCell.h"

@interface KindrTableViewController ()
@property (strong, nonatomic) NSMutableArray *posts;
@property (nonatomic, strong) APIClient *sharedAPIClient;
@end

@implementation KindrTableViewController

#pragma mark - Properties

- (NSMutableArray *)posts
{
    if (!_posts) {
        NSArray *keptPosts = [self.sharedAPIClient getKeptPosts];
        
        if (!keptPosts) {
            keptPosts = @[];
        }
        
        _posts = [[NSMutableArray alloc] initWithArray:keptPosts];
    }
    
    return _posts;
}

- (APIClient *)sharedAPIClient
{
    if (!_sharedAPIClient) _sharedAPIClient = [APIClient sharedAPIClient];
    
    return _sharedAPIClient;
}

#pragma mark - Initialization

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Custom Logo
    UIImage *kindrLogo = [UIImage imageNamed:@"kindr_logo.png"];
    UIImageView *kindrImageView = [[UIImageView alloc] initWithImage:kindrLogo];
    kindrImageView.contentMode = UIViewContentModeScaleAspectFit;
    kindrImageView.clipsToBounds = YES;
    kindrImageView.frame = CGRectMake(0, 0, kindrImageView.superview.frame.size.width, 45);
    [self.navigationItem setTitleView:kindrImageView];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//     self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [self.tableView reloadData];
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
    return [self.posts count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *postCellIdentifier = @"Kept Post";
    PostCell *cell = [tableView dequeueReusableCellWithIdentifier:postCellIdentifier forIndexPath:indexPath];
 
    if (!cell) {
        cell = [[PostCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:postCellIdentifier];
    }
    
    if (indexPath.row < [self.posts count]) {
        Post *post = (Post *)self.posts[indexPath.row];
        [cell configureWithPost:post];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Post *post = self.posts[indexPath.row];
    PostDetailViewController *destinationVc = [[PostDetailViewController alloc] init];
    destinationVc.post = post;
    [self.navigationController pushViewController:destinationVc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.tableView.frame.size.width * 0.5;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
