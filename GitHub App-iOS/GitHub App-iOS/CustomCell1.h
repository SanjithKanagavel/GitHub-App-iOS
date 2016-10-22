//
//  CustomCell1.h
//  GitHub App-iOS
//
//  Created by Sanjith Kanagavel on 22/10/16.
//  Copyright © 2016 Sanjith Kanagavel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCell1 : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *repoName;
@property (strong, nonatomic) IBOutlet UILabel *repoDesc;
@property (strong, nonatomic) IBOutlet UILabel *languageLabel;
@property (strong, nonatomic) IBOutlet UILabel *authorLabel;

@end
