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

@interface KindrTableViewController () <SwipeablePostCell>
@property (nonatomic, strong) APIClient *sharedAPIClient;
@end

@implementation KindrTableViewController

#pragma mark - Properties

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
    
    // table setup
    [self.tableView registerNib:[UINib nibWithNibName:@"PostCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"PostCell"];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.backgroundColor = [UIColor colorWithRed:225.0/255.0 green:225.0/255.0 blue:225.0/255.0 alpha:1.0];
    
    // listen for new kept posts
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keptPostAdded:)
                                                 name:@"PostKept"
                                               object:nil];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//     self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Events

- (void)tapDelete:(NSString *)postId
{
    NSArray *posts = [self.sharedAPIClient getKeptPosts];
    NSPredicate *findPost = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        Post *targetPost = (Post *)evaluatedObject;
        
        return [targetPost.postId isEqualToString:postId];
    }];
    NSArray *filteredPosts = [posts filteredArrayUsingPredicate:findPost];
    
    if ([filteredPosts count]) {
        Post *deletedPost = filteredPosts[0];
        [self.sharedAPIClient savePost:deletedPost asKept:NO];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)keptPostAdded:(NSNotification *)notification
{
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
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
    return [[self.sharedAPIClient getKeptPosts] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *postCellIdentifier = @"PostCell";
    PostCell *cell = [tableView dequeueReusableCellWithIdentifier:postCellIdentifier forIndexPath:indexPath];
    NSArray *posts = [self.sharedAPIClient getKeptPosts];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:postCellIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.delegate = self;
    
    if (indexPath.row < [posts count]) {
        Post *post = (Post *)posts[indexPath.row];
        [cell configureWithPost:post];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Post *post = [self.sharedAPIClient getKeptPosts][indexPath.row];
    PostDetailViewController *destinationVc = [[PostDetailViewController alloc] init];
    destinationVc.post = post;
    [self.navigationController pushViewController:destinationVc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
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
