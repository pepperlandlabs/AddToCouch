//
//  SavedVidCell.h
//  AddToCouch
//
//  Created by Tyson White on 12/12/13.
//  Copyright (c) 2013 Tyson White. All rights reserved.
//

#import "RMSwipeTableViewCell.h"
#import "ViewController.h"

@protocol SavedVidCellDelegate;

@interface SavedVidCell : RMSwipeTableViewCell

typedef void (^deleteBlock)(SavedVidCell *swipeTableViewCell);

@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) deleteBlock deleteBlockHandler;
@property (nonatomic, assign) id <SavedVidCellDelegate> cellDelegate;
@property (nonatomic, strong) NSMutableArray *savedVidArray;
@property (weak, nonatomic) IBOutlet UILabel *savedVidUrl;
@property (nonatomic, strong) NSString *yturl;


-(void)resetContentView;

@end

@protocol SavedVidCellDelegate <NSObject>
@optional
-(void)swipeTableViewCellDidDelete:(SavedVidCell*)swipeTableViewCell;
@end
