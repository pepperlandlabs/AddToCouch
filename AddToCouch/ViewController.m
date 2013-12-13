//
//  ViewController.m
//  AddToCouch
//
//  Created by Tyson White on 12/4/13.
//  Copyright (c) 2013 Tyson White. All rights reserved.
//

#import "ViewController.h"
#import "SVWebViewController.h"
#import "RMSwipeTableViewCell.h"

@import Social;

@interface ViewController ()

@end

@interface NSDictionary(JSONCategories)
+(NSDictionary*)dictionaryWithContentsOfJSONURLString:
(NSString*)urlAddress;
-(NSData*)toJSON;
@end

@implementation NSDictionary(JSONCategories)
+(NSDictionary*)dictionaryWithContentsOfJSONURLString:
(NSString*)urlAddress
{
    NSData* data = [NSData dataWithContentsOfURL:
                    [NSURL URLWithString: urlAddress] ];
    __autoreleasing NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data
                                                options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;
}

-(NSData*)toJSON
{
    NSError* error = nil;
    id result = [NSJSONSerialization dataWithJSONObject:self
                                                options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;    
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[SavedVidCell class] forCellReuseIdentifier:@"Video_Cell"];
    [self.tableView setRowHeight:80];
    self.roomname.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"roomname"];
    UIPasteboard *appPasteBoard = [UIPasteboard generalPasteboard];
    NSString *text = [appPasteBoard string];
    [self sendTweet:text];
    [self saveVid:text];
    [self fetchedData:_jsonData];
    NSLog(@"View controller got text %@", text);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveClipboard:) name:@"receiveClipboard" object:nil];
	// Do any additional setup after loading the view, typically from a nib.
}

-(NSMutableArray*)savedVidArray {
    return _savedVidArray;
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
    return [self.savedVidArray count];
    NSLog(@"There are %lu vids saved", (unsigned long)self.savedVidArray.count);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Video_Cell";
    SavedVidCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.delegate = self; // optional
    return cell;
    NSLog(@"Table View Loaded");
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectedIndexPath.row != indexPath.row) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self resetSelectedCell];
    }
    if (self.selectedIndexPath.row == indexPath.row) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self resetSelectedCell];
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.selectedIndexPath) {
        [self resetSelectedCell];
    }
}

#pragma mark - RMSwipeTableViewCelliOS7UIDemoTableViewCell delegate method

-(void)swipeTableViewCellDidDelete:(SavedVidCell *)swipeTableViewCell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:swipeTableViewCell];
    [self.savedVidArray removeObjectAtIndex:indexPath.row];
    [swipeTableViewCell resetContentView];
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
    /*if ([self.savedVidArray count]) {
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Reset", nil) style:UIBarButtonItemStylePlain target:self action:@selector(resetDemo)];
        [self.navigationItem setRightBarButtonItem:barButtonItem animated:YES];
    }*/
}

#pragma mark - RMSwipeTableViewCell delegate methods

-(void)swipeTableViewCellDidStartSwiping:(RMSwipeTableViewCell *)swipeTableViewCell {
    NSIndexPath *indexPathForCell = [self.tableView indexPathForCell:swipeTableViewCell];
    if (self.selectedIndexPath.row != indexPathForCell.row) {
        [self resetSelectedCell];
    }
}

-(void)resetSelectedCell {
    SavedVidCell *cell = (SavedVidCell*)[self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
    [cell resetContentView];
    self.selectedIndexPath = nil;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
}

-(void)swipeTableViewCellWillResetState:(RMSwipeTableViewCell *)swipeTableViewCell fromPoint:(CGPoint)point animation:(RMSwipeTableViewCellAnimationType)animation velocity:(CGPoint)velocity {
    if (velocity.x <= -500) {
        self.selectedIndexPath = [self.tableView indexPathForCell:swipeTableViewCell];
        swipeTableViewCell.shouldAnimateCellReset = NO;
        swipeTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSTimeInterval duration = MAX(-point.x / ABS(velocity.x), 0.10f);
        [UIView animateWithDuration:duration
                              delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             swipeTableViewCell.contentView.frame = CGRectOffset(swipeTableViewCell.contentView.bounds, point.x - (ABS(velocity.x) / 150), 0);
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:duration
                                                   delay:0
                                                 options:UIViewAnimationOptionCurveEaseOut
                                              animations:^{
                                                  swipeTableViewCell.contentView.frame = CGRectOffset(swipeTableViewCell.contentView.bounds, -80, 0);
                                              }
                                              completion:^(BOOL finished) {
                                              }];
                         }];
    }
    // The below behaviour is not normal as of iOS 7 beta seed 1
    // for Messages.app, but it is for Mail.app.
    // The user has to pan/swipe with a certain amount of velocity
    // before the cell goes to delete-state. If the user just pans
    // above the threshold for the button but without enough velocity,
    // the cell will reset.
    // Mail.app will, however allow for the cell to reveal the button
    // even if the velocity isn't high, but the pan translation is
    // above the threshold. I am assuming it'll get more consistent
    // in later seed of the iOS 7 beta
    /*
     else if (velocity.x > -500 && point.x < -80) {
     self.selectedIndexPath = [self.tableView indexPathForCell:swipeTableViewCell];
     swipeTableViewCell.shouldAnimateCellReset = NO;
     swipeTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
     NSTimeInterval duration = MIN(-point.x / ABS(velocity.x), 0.15f);
     [UIView animateWithDuration:duration
     animations:^{
     swipeTableViewCell.contentView.frame = CGRectOffset(swipeTableViewCell.contentView.bounds, -80, 0);
     }];
     }
     */
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)keyboardend:(id)sender {
    NSLog(@"Keyboard end");
}

- (void)receiveClipboard: (NSNotification *) notifcation {
    NSLog(@"Receive clipboard");
    [self sendTweet:notifcation.object];
}

- (void)saveVid:(NSString *)text {
    NSError* error;
    NSDictionary* bookmarks = [NSDictionary dictionaryWithObjectsAndKeys:
                               text,
                               @"yturl",
                               nil];
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:bookmarks
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    self.jsonData = jsonData;
    
    NSLog(@"saveVid fired");
    
    self.currentCopied.text = [[NSString alloc] initWithData:jsonData
                                                    encoding:NSUTF8StringEncoding];
}

- (void)fetchedData:(NSData *)jsonData {
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:self.jsonData //1
                          
                          options:kNilOptions
                          error:&error];
    
    NSMutableArray* savedVidArray = [json objectForKey:@"yturl"]; //2
    self.savedVidArray = savedVidArray;
    NSLog(@"bloop %@", savedVidArray);
    
    //NSDictionary* yturls = [savedVidArray objectAtIndex:0];
    //NSString* yturl = [yturls objectForKey:@"yturl"];
    
    //NSLog(@"urls: %@", yturl); //3
    
    
    /*
    
    NSDictionary* bookmarks = [NSDictionary dictionaryWithObjectsAndKeys:
                             text,
                             @"yturl",
                             nil];
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:bookmarks
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    
   // NSMutableArray *savedVidArray = (NSMutableArray* )[NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    
    self.savedVidArray = (NSMutableArray* )[NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];*/
    
}

- (void)sendTweet: (NSString *)text {
    NSURL *url = [NSURL URLWithString:text];
    if (!url) {
        NSLog(@"Failed to get URL from text %@", text);
        return;
    }
    if (!url.host || !url.path) {
        NSLog(@"Got bad URL %@", text);
        return;
    }
    if (self.roomname.text.length <5) {
        NSLog(@"Name not long enough %@", self.roomname.text);
        return;
    }
    if ([text isEqualToString:self.lastTweet.text]) {
        NSLog(@"Same URL as last tweet %@", self.lastTweet.text);
        return;
    }
    NSString *newText = [NSString stringWithFormat:@"@AddToCouch #%@ %@",self.roomname.text,text];
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:newText];
        tweetSheet.completionHandler = ^(SLComposeViewControllerResult result){
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    break;
                case SLComposeViewControllerResultDone:
                    self.lastTweet.text=text;
                    self.lastTweet.hidden=NO;
                    break;
            }
        };
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.roomname resignFirstResponder];
    [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:@"roomname"];
    return YES;
}



- (IBAction)randomTap:(id)sender {
    NSLog(@"playvideo tapped");
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://cute-api.herokuapp.com/get_random_video"]];
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSLog(@"request made");
    NSError *jsonParsingError = nil;
    NSDictionary *videoData = [NSJSONSerialization JSONObjectWithData:response options:0 error:&jsonParsingError];
    self.videoURL = [NSURL URLWithString:[videoData objectForKey:@"url"]];
    NSString *yturl = [self.videoURL absoluteString];
    yturl = [NSString stringWithFormat:@"%@%@", @"http://", yturl];
    NSLog(@"%@", yturl);
    [self sendTweet:yturl];
}

- (IBAction)presentQueue:(id)sender {
    NSString *urlString;
    urlString = [NSString stringWithFormat:@"%@%@", @"http://10.0.0.11:8080/remote/", self.roomname.text];
    NSURL *URL = [NSURL URLWithString:urlString];
	SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithURL:URL];
	webViewController.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:webViewController animated:YES completion:NULL];
}
@end
