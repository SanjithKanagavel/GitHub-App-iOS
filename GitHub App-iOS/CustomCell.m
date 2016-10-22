//
//  CustomCell.m
//  GitHub App-iOS
//
//  Created by Sanjith Kanagavel on 22/10/16.
//  Copyright © 2016 Sanjith Kanagavel. All rights reserved.
//

#import "CustomCell.h"

@implementation CustomCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    UIView *view = [UIView new];
    [view setBackgroundColor:[UIColor blackColor]];
    self.selectedBackgroundView = view;
    // Configure the view for the selected state
}

@end
