//
//  FourthViewController.m
//  GitHub App-iOS
//
//  Created by Sanjith Kanagavel on 21/10/16.
//  Copyright © 2016 Sanjith Kanagavel. All rights reserved.
//

#import "FourthViewController.h"
#import "Keys.h"
#import "UAGithubEngine.h"
#import "UAGithubJSONParser.h"
#import "UserCell.h"
#import "KeychainItemWrapper.h"

@interface FourthViewController ()
@property NSMutableArray *repoDetails;
@property NSString *userName;
@property NSString *userPassword;
@property UAGithubEngine *engine;
@property UILabel *labelView;
@property NSDictionary *colorDict;
@property BOOL loggedIn;
@property UIButton *button;
@end

@implementation FourthViewController
NSUserDefaults *userDefaults;


- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *filepath =[[NSBundle bundleForClass:[self class]] pathForResource:@"lang-color" ofType:@"json"];
    NSData *colorData = [[NSData alloc] initWithContentsOfFile:filepath];
    NSError *error;
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
    [self.tableView registerClass:[UserCell class] forCellReuseIdentifier:@"CustomCell"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
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
                [self.engine FollowingWithSuccess:^(id response) {
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
                                [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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
        
        [self.engine FollowingWithSuccess:^(id response) {
            
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
                    for(NSDictionary *item in jsonArray) {
                        [self.repoDetails addObject:item];
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    }
                    
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



#pragma UITableView

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.loggedIn) {
        if(self.repoDetails.count < 1) {
            [self.labelView setText:@"Loading data..."];
            [self.view addSubview:self.labelView];
        }
        else {
            [self.labelView removeFromSuperview];
        }
    }
    return self.repoDetails.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserCell *cell;
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"UserCell" owner:self options:nil];
    cell = [nib objectAtIndex:0];
    NSDictionary *dictVal = [self.repoDetails objectAtIndex:indexPath.row];
    cell.userLabel.text =  [[dictVal valueForKey:@"login"] description];
    NSURL *url = [NSURL URLWithString:[[dictVal valueForKey:@"avatar_url"] description]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:data];
    [cell.userImage setImage:image];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.repoDetails removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
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