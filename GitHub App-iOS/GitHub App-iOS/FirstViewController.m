//
//  FirstViewController.m
//  GitHub App-iOS
//
//  Created by Sanjith Kanagavel on 21/10/16.
//  Copyright © 2016 Sanjith Kanagavel. All rights reserved.
//

#import "FirstViewController.h"
#import "Keys.h"
#import "UAGithubEngine.h"
#import "UAGithubJSONParser.h"
#import "CustomCell.h"
#import "KeychainItemWrapper.h"


@interface FirstViewController ()
@property NSMutableArray *repoDetails;
@property NSString *userName;
@property NSString *userPassword;
@end

@implementation FirstViewController
UAGithubEngine *engine;
NSUserDefaults *userDefaults;
UILabel *labelView;
NSDictionary *colorDict;
BOOL loggedIn;
UIButton *button;

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *filepath =[[NSBundle bundleForClass:[self class]] pathForResource:@"lang-color" ofType:@"json"];
    NSData *colorData = [[NSData alloc] initWithContentsOfFile:filepath];
    NSError *error;
    colorDict = [NSJSONSerialization JSONObjectWithData:colorData options:0 error:&error];
    self.repoDetails =[[NSMutableArray alloc] init];
    labelView = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 50)];
    [labelView setCenter:CGPointMake([[UIScreen mainScreen]bounds].size.width/2, [[UIScreen mainScreen]bounds].size.height/2)];
    [labelView setTextColor:[UIColor whiteColor]];
    [labelView setTextAlignment:NSTextAlignmentCenter];
    labelView.text = @"No Repositories found";
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 200, 50);
    [button setTitle:@"Login" forState:UIControlStateNormal];
    [button setTitle:@"Login" forState:UIControlStateSelected];
    [button setCenter:CGPointMake([[UIScreen mainScreen]bounds].size.width/2, [[UIScreen mainScreen]bounds].size.height/2)];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [button setBackgroundColor:[self colorFromHexString:@"#00BFA5"]];
    button.layer.cornerRadius = 5;
    [button addTarget:self action:@selector(signInPullRepo) forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.font= [UIFont fontWithName:@"Helvetica-Bold" size:20.0];
    [button setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [self.tableView registerClass:[CustomCell class] forCellReuseIdentifier:@"CustomCell"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if([defaults stringForKey:@"userName"] == nil) {
        loggedIn = false;
        [self.view addSubview:button];
    }
    else {
        loggedIn = true;
        self.userName = [ defaults objectForKey:@"userName"];
        self.userPassword = [ defaults objectForKey:@"userPassword"];
        [self pullRepos];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
 }


/*
 * SignIn to Git and pull repos
 */

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
            engine = [[UAGithubEngine alloc] initWithUsername:userName.text password:userPassword.text withReachability:YES];
            if(engine != nil) {
                [engine repositoriesWithSuccess:^(id response) {
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
                            loggedIn = true;
                            [button removeFromSuperview];
                            [labelView setText:@"Loading data. Please Wait."];
                            [self.view addSubview:labelView];
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
    
    if ( engine == nil )
    {
        engine = [[UAGithubEngine alloc] initWithUsername:self.userName password:self.userPassword withReachability:YES];
    }
    
    [engine repositoriesWithSuccess:^(id response) {
        
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
            [self.tableView reloadData];
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
    if(loggedIn)
    if(self.repoDetails.count < 1) {
        [labelView setText:@"Loading data..."];
        [self.view addSubview:labelView];
    }
    else {
        [labelView removeFromSuperview];
    }
    return self.repoDetails.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomCell *cell;
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CustomCell" owner:self options:nil];
    cell = [nib objectAtIndex:0];
    NSDictionary *dictVal = [self.repoDetails objectAtIndex:indexPath.row];
    cell.repoDesc.text = [[[dictVal valueForKey:@"description"] description] isEqual:@"<null>" ] ? @"No Description Available": [[dictVal valueForKey:@"description"] description] ;
    cell.repoName.text = [[dictVal valueForKey:@"full_name"] description];
    cell.watchLabel.text = [[dictVal valueForKey:@"watchers"] description];
    cell.starLabel.text = [[dictVal valueForKey:@"stargazers_count"] description];
    cell.forkLabel.text = [[dictVal valueForKey:@"forks_count"] description];
    cell.languageLabel.text = [[[dictVal valueForKey:@"language"] description]  isEqual: @"<null>"] ? @"No Language Available":[[dictVal valueForKey:@"language"] description];
    
    if([[[dictVal valueForKey:@"language"] description]  isEqual: @"<null>"]) {
        [cell.languageLabel setTextColor:[UIColor orangeColor]];
    }
    else {
        [cell.languageLabel setTextColor:[self colorFromHexString:[[colorDict valueForKey:cell.languageLabel.text] valueForKey:@"color"]]];
    }
    
    
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
    return 130;
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
