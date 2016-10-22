//
//  CustomCell.h
//  GitHub App-iOS
//
//  Created by Sanjith Kanagavel on 22/10/16.
//  Copyright © 2016 Sanjith Kanagavel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *repoName;
@property (strong, nonatomic) IBOutlet UILabel *repoDesc;
@property (strong, nonatomic) IBOutlet UILabel *watchLabel;
@property (strong, nonatomic) IBOutlet UILabel *languageLabel;
@property (strong, nonatomic) IBOutlet UILabel *starLabel;
@property (strong, nonatomic) IBOutlet UILabel *forkLabel;


@end
