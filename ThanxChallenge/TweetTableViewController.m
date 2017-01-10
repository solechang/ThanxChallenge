//
//  TweetTableViewController.m
//  ThanxChallenge
//
//  Created by Chang Choi on 1/9/17.
//  Copyright © 2017 solechang. All rights reserved.
//

#import "TweetTableViewController.h"
#import "STTwitterAPI.h"

#import "TweetTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

#import "Tweet.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface TweetTableViewController ()

@property (nonatomic) NSMutableArray *tweetArray;
@property (nonatomic) NSString *max_id;
@property (nonatomic) NSString *since_id;

@property (nonatomic) STTwitterAPI *twitter;


@end

@implementation TweetTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpView];
    [self getTweet];
}

- (void) viewWillDisappear:(BOOL)animated {
    
    [SVProgressHUD dismiss];
    [super viewWillDisappear:animated];
}

- (void) setUpView {
    
    // Set title
    self.title = self.tweet;
    
    // Remove empty tableview cells
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void) getTweet {
    // Initialize tweetArray
    self.tweetArray = [[NSMutableArray alloc] init];
    
    [SVProgressHUD showWithStatus:@"Loading.."];
    
    // Get Tweet using STTwitterAPI
    
    self.twitter = [STTwitterAPI twitterAPIAppOnlyWithConsumerKey:@"ik1ifymqwN37kPfWIZnFzYznm" consumerSecret:@"d0VEAJlkyWWBIXzVDBfpJKkwB9ieArIBLGnICWfobSzny1eK9f"];
    
    [self.twitter verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString *userID) {
        
        if ( [self.tweet isEqualToString:@"#thanxinc"] ) {
            
             // get #thanxinc tweets
            [self.twitter getSearchTweetsWithQuery:self.tweet geocode:nil lang:nil locale:nil resultType:nil count:@"100" until:nil sinceID:nil maxID:nil includeEntities:nil callback:nil successBlock:^(NSDictionary *searchMetadata, NSArray *statuses) {
            
                for (  NSDictionary *status in statuses ) {
                    
                    Tweet *tweet = [[Tweet alloc] init];
                    tweet.text = status[@"text"];
                    NSDictionary *user = status[@"user"];
                    tweet.name = user[@"name"];
                    tweet.imageURL = user[@"profile_image_url"];
                    tweet.username = user[@"screen_name"];
                    [self.tweetArray addObject:tweet];
                    
                }
                [SVProgressHUD dismiss];
                [self.tableView reloadData];
                
            } errorBlock:^(NSError *error) {
                [SVProgressHUD dismiss];
                NSLog(@"Error : %@",error);
            }];
        } else {
            
            // get @thanxinc's timeline
            [self.twitter getUserTimelineWithScreenName:self.tweet sinceID:nil maxID:nil count:25 successBlock:^(NSArray *statuses) {
                
                for (  NSDictionary *status in statuses ) {
                    // Serialize
                    Tweet *tweet = [[Tweet alloc] init];
                    tweet.text = status[@"text"];
                    NSDictionary *user = status[@"user"];
                    tweet.name = user[@"name"];
                    tweet.imageURL = user[@"profile_image_url"];
                    tweet.username = user[@"screen_name"];
                    self.max_id = status[@"id"];
                    [self.tweetArray addObject:tweet];
                    
                }
                
                [SVProgressHUD dismiss];
                [self.tableView reloadData];

            } errorBlock:^(NSError *error) {
                 [SVProgressHUD dismiss];
                 NSLog(@"Error : %@",error);
            }];
            
        }
        
    } errorBlock:^(NSError *error) {
        NSLog(@"Error %@", error);
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.tweetArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tweetCell" forIndexPath:indexPath];
    
    Tweet *tweet = [self.tweetArray objectAtIndex:indexPath.row];
    cell.nameLabel.text = tweet.name;
    cell.usernameLabel.text = [NSString stringWithFormat:@"@%@", tweet.username];
    cell.tweetLabel.text = tweet.text;
    
    // Display image
    [cell.profileImageView sd_setImageWithURL:[NSURL URLWithString:tweet.imageURL] placeholderImage:nil options:SDWebImageRefreshCached];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Last cell to load more
    NSInteger lastSectionIndex = [tableView numberOfSections] - 1;
    NSInteger lastRowIndex = [tableView numberOfRowsInSection:lastSectionIndex] - 1;
    if ((indexPath.section == lastSectionIndex) && (indexPath.row == lastRowIndex)) {
        
        [SVProgressHUD showWithStatus:@"Loading.."];
        // This is the last cell
        // Reaching end of table view
        [self.twitter getUserTimelineWithScreenName:self.tweet sinceID:nil maxID:self.max_id count:25 successBlock:^(NSArray *statuses) {
            
            [self.tweetArray removeLastObject]; // Remove last tweet because of duplicates
            
            for (  NSDictionary *status in statuses ) {
                
                Tweet *tweet = [[Tweet alloc] init];
                tweet.text = status[@"text"];
                NSDictionary *user = status[@"user"];
                tweet.name = user[@"name"];
                tweet.imageURL = user[@"profile_image_url"];
                tweet.username = user[@"screen_name"];
                self.max_id = status[@"id"];
                [self.tweetArray addObject:tweet];
                
            }
            
            [SVProgressHUD dismiss];
            [self.tableView reloadData];
            
        } errorBlock:^(NSError *error) {
            [SVProgressHUD dismiss];
            NSLog(@"Error : %@",error);
        }];

        
        
    }
}

@end
