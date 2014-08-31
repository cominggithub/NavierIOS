//
//  IAPImageCell.m
//  NavierIOS
//
//  Created by Coming on 8/3/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import "IAPImageCell.h"

@implementation IAPImageCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

        self.descriptionTextView.layer.borderWidth = 5.0f;
        self.descriptionTextView.layer.borderColor = [[UIColor grayColor] CGColor];
        
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        
        self.descriptionTextView.layer.borderWidth = 5.0f;
        self.descriptionTextView.layer.borderColor = [[UIColor grayColor] CGColor];
        
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
