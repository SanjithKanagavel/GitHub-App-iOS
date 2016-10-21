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

//typedef void(^FINISHED) (BOOL);

@interface FirstViewController ()

@end

@implementation FirstViewController
UAGithubEngine *engine;
BOOL testing;
NSUserDefaults *userDefaults;

- (void)viewDidLoad {
    [super viewDidLoad];
    testing =true;
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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
     //= [[NSUserDefaults standardUserDefaults] setObject:@"UserName" forKey:@""];
     //= [[NSUserDefaults standardUserDefaults] setObject:@"UserPassword" forKey:@""];
    NSString *userName;
    NSString *userPassword;
    
    if(!testing) {
        userName = [userDefaults stringForKey:@"UserName"];
        userPassword = [userDefaults stringForKey:@"UserPassword"];
    }
    else {
        userName = @"aPage";
        userPassword = @"bPage";
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
    
    if ( engine == nil )
    {
        engine = [[UAGithubEngine alloc] initWithUsername:userName password:userPassword withReachability:YES];
    }
    
    [engine repositoriesWithSuccess:^(id response) {
        NSLog(@"Got an array of repos: %@", response);
    } failure:^(NSError *error) {
        NSLog(@"Oops: %@", error);
    }];
    
    //NSLog(@"%@ %@",userName,userPassword);
    /*[engine user:@"this_guy" isCollaboratorForRepository:@"UAGithubEngine" success:^(BOOL collaborates) {
        NSLog(@"%d", collaborates);
    } failure:^(NSError *error){
        NSLog(@"D'oh: %@", error);
    }];*/
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
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = [@"Repository" stringByAppendingString:[NSString stringWithFormat:@"%ld", (long)indexPath.row]];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
    }
}


@end
