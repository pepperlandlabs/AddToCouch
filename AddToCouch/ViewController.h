//
//  ViewController.h
//  AddToCouch
//
//  Created by Tyson White on 12/4/13.
//  Copyright (c) 2013 Tyson White. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SavedVidCell.h"
@import Social;

@interface ViewController : UIViewController <UITextFieldDelegate,RMSwipeTableViewCellDelegate>
@property (strong,nonatomic) NSURL *videoURL;
@property (strong, nonatomic) IBOutlet UITextField *roomname;
- (IBAction)keyboardend:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *lastTweet;
@property (strong, nonatomic) IBOutlet UILabel *currentCopied;
@property (strong, nonatomic) IBOutlet UIButton *randomButton;
- (IBAction)randomTap:(id)sender;
- (IBAction)presentQueue:(id)sender;
@property (nonatomic, strong) NSMutableArray *savedVidArray;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) UITableView *tableView;
@property (weak, nonatomic) NSData *jsonData;

@end
