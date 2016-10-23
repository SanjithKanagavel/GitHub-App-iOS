//
//  FifthViewController.m
//  GitHub App-iOS
//
//  Created by Sanjith Kanagavel on 21/10/16.
//  Copyright © 2016 Sanjith Kanagavel. All rights reserved.
//

#import "FifthViewController.h"
#import "Keys.h"
#import "UAGithubEngine.h"
#import "UAGithubJSONParser.h"
#import "UserCell.h"
#import "KeychainItemWrapper.h"

@interface FifthViewController ()
@property NSMutableArray *repoDetails;
@property NSString *userName;
@property NSString *userPassword;
@property UAGithubEngine *engine;
@property UILabel *labelView;
@property NSDictionary *colorDict;
@property BOOL loggedIn;
@property UIButton *button;
@end

@implementation FifthViewController
NSUserDefaults *userDefaults;


- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *filepath =[[NSBundle bundleForClass:[self class]] pathForResource:@"lang-color" ofType:@"json"];
    NSData *colorData = [[NSData alloc] initWithContentsOfFile:filepath];
    NSError *error;
    [self hideLayout];
    self.colorDict = [NSJSONSerialization JSONObjectWithData:colorData options:0 error:&error];
    self.repoDetails =[[NSMutableArray alloc] init];
    self.labelView = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 50)];
    [self.labelView setCenter:CGPointMake([[UIScreen mainScreen]bounds].size.width/2, [[UIScreen mainScreen]bounds].size.height/2)];
    [self.labelView setTextColor:[UIColor whiteColor]];
    [self.labelView setTextAlignment:NSTextAlignmentCenter];
    self.labelView.text = @"No Repositories found";
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    self.button.frame = CGRectMake(0, 0, 200, 50);
    [self.button setTitle:@"Login" forState:UIControlStateNormal];
    [self.button setTitle:@"Login" forState:UIControlStateSelected];
    [self.button setCenter:CGPointMake([[UIScreen mainScreen]bounds].size.width/2, [[UIScreen mainScreen]bounds].size.height/2)];
    [self.button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.button setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [self.button setBackgroundColor:[self colorFromHexString:@"#00BFA5"]];
    self.button.layer.cornerRadius = 5;
    [self.button addTarget:self action:@selector(signInPullRepo) forControlEvents:UIControlEventTouchUpInside];
    self.button.titleLabel.font= [UIFont fontWithName:@"Helvetica-Bold" size:20.0];
    [self.button setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [self.button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if([defaults stringForKey:@"userName"] == nil) {
        self.loggedIn = false;
        [self.view addSubview:self.button];
    }
    else {
        self.loggedIn = true;
        self.userName = [ defaults objectForKey:@"userName"];
        self.userPassword = [ defaults objectForKey:@"userPassword"];
        [self pullRepos];
    }
}

-(void) hideLayout {
    _followerImage.alpha=0;
    _followersLink.alpha=0;
    _repoCount.alpha=0;
    _repoImage.alpha=0;
    _followingCount.alpha=0;
    _followingImage.alpha=0;
    _userGit.alpha=0;
    _userNme.alpha=0;
    _userMail.alpha=0;
    _userLocation.alpha=0;
    _userimage.alpha=0;
    _emailId.alpha=0;
    _emailImage.alpha=0;
    _joinedImage.alpha=0;
    _websiteLink.alpha=0;
    _linkImage.alpha=0;
    _userimage.alpha=0;
    _locationImage.alpha=0;
    _githubImage.alpha=0;
    
}

-(void) showLayout {
    _followerImage.alpha=1;
    _followersLink.alpha=1;
    _repoCount.alpha=1;
    _repoImage.alpha=1;
    _followingCount.alpha=1;
    _followingImage.alpha=1;
    _userGit.alpha=1;
    _userNme.alpha=1;
    _userMail.alpha=1;
    _userLocation.alpha=1;
    _userimage.alpha=1;
    _emailId.alpha=1;
    _emailImage.alpha=1;
    _joinedImage.alpha=1;
    _websiteLink.alpha=1;
    _linkImage.alpha=1;
    _userimage.alpha=1;
    _locationImage.alpha=1;
    _githubImage.alpha=1;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}


-(void) signInPullRepo {
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"SignIn to Github" message: @"Username and Password"
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Username";
        textField.textColor = [UIColor blackColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Password";
        textField.textColor = [UIColor blackColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"SignIn" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSArray * textfields = alertController.textFields;
        UITextField * userName = textfields[0];
        UITextField * userPassword = textfields[1];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
            self.engine = [[UAGithubEngine alloc] initWithUsername:userName.text password:userPassword.text withReachability:YES];
            if(self.engine != nil) {
                [self.engine userWithSuccess:^(id response) {
                    NSError *e = nil;
                    NSError *error = nil;
                    NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:response options:NSJSONWritingPrettyPrinted error:&error];
                    NSString *jsonString = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
                    NSLog(@"jsonData as string:\n%@", jsonString);
                    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: jsonData2 options: NSJSONReadingMutableContainers error: &e];
                    if (!jsonArray) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self signInPullRepo];
                        });
                        NSLog(@"Data Error");
                        return;
                        
                    } else {
                        self.userName = userName.text;
                        self.userPassword = userPassword.text;
                        dispatch_async(dispatch_get_main_queue(), ^{ //Do updates in the main thread
                            self.loggedIn = true;
                            [self.button removeFromSuperview];
                            [self.labelView setText:@"Loading data. Please Wait."];
                            [self.view addSubview:self.labelView];
                            [self saveUserDetail];
                            for(NSDictionary *item in jsonArray) {
                                [self.repoDetails addObject:item];
                                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            }
                        });
                    }
                } failure:^(NSError *error) {
                    NSLog(@"Oops: %@", error);
                }];
                
            }
            
        });
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void) saveUserDetail  {
    NSUserDefaults* defaults1 = [NSUserDefaults standardUserDefaults];
    [defaults1 setObject:self.userName forKey:@"userName"];
    [defaults1 setObject:self.userPassword forKey:@"userPassword"];
    [defaults1 synchronize];
}



-(void) pullRepos {
    [self.repoDetails removeAllObjects];
    
    if(false) {  //replace your git username and password here used for testing
        self.userName = @"";
        self.userPassword = @"";
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        
        if ( self.engine == nil )
        {
            self.engine = [[UAGithubEngine alloc] initWithUsername:self.userName password:self.userPassword withReachability:YES];
        }
        
        [self.engine userWithSuccess:^(id response) {
            
            NSError *e = nil;
            NSError *error = nil;
            NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:response options:NSJSONWritingPrettyPrinted error:&error];
            NSString *jsonString = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
            NSLog(@"jsonData as string:\n%@", jsonString);
            NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: jsonData2 options: NSJSONReadingMutableContainers error: &e];
            if (!jsonArray) {
                NSLog(@"Error parsing JSON: %@", e);
            } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                        [dict setObject:jsonArray forKey:@"data"];
                        NSLog(@"%@",dict);
                        [self showLayout];
                        //_followingCount.text = [[[dict objectForKey:@"data"] objectForKey:@"following"] description];
                });
            }
            
        } failure:^(NSError *error) {
            NSLog(@"Oops: %@", error);
        }];
        
    });
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

//starredGistsWithSuccess

@end