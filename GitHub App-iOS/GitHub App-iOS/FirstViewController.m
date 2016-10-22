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

//typedef void(^FINISHED) (BOOL);

@interface FirstViewController ()
@property NSMutableArray *repoDetails;
@end

@implementation FirstViewController
UAGithubEngine *engine;
BOOL testing;
NSUserDefaults *userDefaults;


- (void)viewDidLoad {
    [super viewDidLoad];
    testing =true;
    self.repoDetails =[[NSMutableArray alloc] init];
    [self.tableView registerClass:[CustomCell class] forCellReuseIdentifier:@"CustomCell"]; //registering custom cell
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    /*if(true)
    {
        NSMutableDictionary *tempData = [[NSMutableDictionary alloc]init];
        [tempData setValue:@"Description" forKey:@"description"];
        [tempData setValue:@"Git Repo Name" forKey:@"full_name"];
        [tempData setValue:@"10" forKey:@"watchers_count"];
        [tempData setValue:@"10" forKey:@"stargazers_count"];
        [tempData setValue:@"10" forKey:@"forks"];
        [tempData setValue:@"Objective-C" forKey:@"language"];
        [self.repoDetails addObject:tempData];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        return;
    }*/
    
    if(!testing) {
        userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"GitHubCredentials"];
        NSString *userName = [userDefaults stringForKey:@"UserName"];
        NSString *userPassword = [userDefaults stringForKey:@"UserPassword"];
        NSLog(@"%@ %@",userName,userPassword);
        if([userDefaults stringForKey:@"UserName"] == nil) {
            printf("Account not found");
            [self signIn];
        }
        else {
            printf("Account found");
            [self pullRepos];
        }
    }
    else{
        [self pullRepos];
    }

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void) signIn {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"SignIn to Github"
                                                                              message: @"Username and Password"
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
                dispatch_async(dispatch_get_main_queue(), ^{
                    [userDefaults setObject:@"UserName" forKey:userName.text];
                    [userDefaults setObject:@"UserPassword" forKey:userPassword.text];
                    [userDefaults synchronize];
                    [self pullRepos];
                });
            }
            
        });
    }]];
    [self presentViewController:alertController animated:YES completion:nil];

}

-(void) pullRepos {
    [self.repoDetails removeAllObjects];
    
    NSString *userName;
    NSString *userPassword;
    
    if(!testing) {
        userName = [userDefaults stringForKey:@"UserName"];
        userPassword = [userDefaults stringForKey:@"UserPassword"];
    }
    else {
        //replace your username and password here
        userName = @"";
        userPassword = @"";
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
    
    if ( engine == nil )
    {
        engine = [[UAGithubEngine alloc] initWithUsername:userName password:userPassword withReachability:YES];
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
        }
        });
    }

    } failure:^(NSError *error) {
        NSLog(@"Oops: %@", error);
    }];
        
});
}

- (BOOL)prefersStatusBarHidden {return YES;}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma UITableView

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.repoDetails.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CustomCell *cell;
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CustomCell" owner:self options:nil];
    cell = [nib objectAtIndex:0];
    NSDictionary *dictVal = [self.repoDetails objectAtIndex:indexPath.row];
    cell.repoDesc.text = [[[dictVal valueForKey:@"description"] description] isEqual:@"<null>" ] ? @"No Description Available": [[dictVal valueForKey:@"description"] description] ;
    cell.repoName.text = [[dictVal valueForKey:@"full_name"] description];
    cell.watchLabel.text = [[dictVal valueForKey:@"watchers_count"] description];
    cell.starLabel.text = [[dictVal valueForKey:@"stargazers_count"] description];
    cell.forkLabel.text = [[dictVal valueForKey:@"forks_count"] description];
    cell.languageLabel.text = [[[dictVal valueForKey:@"language"] description]  isEqual: @"<null>"] ? @"No Language Available":[[dictVal valueForKey:@"language"] description];
    return cell;
    
    /*UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSDictionary *dictVal = [self.repoDetails objectAtIndex:indexPath.row];
    cell.textLabel.text = dictVal[@"full_name"];
    return cell;*/
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        //when delete is tapped
        [self.repoDetails removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 130;
}


@end
