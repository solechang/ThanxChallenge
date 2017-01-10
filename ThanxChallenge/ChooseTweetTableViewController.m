//
//  ChooseTweetTableViewController.m
//  ThanxChallenge
//
//  Created by Chang Choi on 1/5/17.
//  Copyright © 2017 solechang. All rights reserved.
//

#import "ChooseTweetTableViewController.h"

#import "TweetTableViewController.h"

@interface ChooseTweetTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *thanxUserLabel;
@property (weak, nonatomic) IBOutlet UILabel *thanxHashTagLabel;


@end

@implementation ChooseTweetTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpView];
    
}


- (void) setUpView {
    // Remove empty tableview cells
        self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self performSegueWithIdentifier:@"tweetSegue" sender:self];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"tweetSegue"]){
        TweetTableViewController *controller = (TweetTableViewController *)segue.destinationViewController;
        NSIndexPath *selectedPath = [self.tableView indexPathForSelectedRow];
        if (selectedPath.row == 0) {
            controller.tweet = @"@ThanxInc";
            
        } else if (selectedPath.row == 1) {
            controller.tweet = @"#thanxinc";
        }
    }
}


@end
