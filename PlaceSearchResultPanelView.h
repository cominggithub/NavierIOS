//
//  PlaceSearchResultPanelView.h
//  NavierIOS
//
//  Created by Coming on 12/7/13.
//  Copyright (c) 2013 Coming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Place.h"

@class PlaceSearchResultPanelView;

@protocol PlaceSearchResultPanelViewDelegate <NSObject>

-(void) placeSearchResultPanelView:(PlaceSearchResultPanelView*) pv moveToPlace:(Place*) p;

@end

@interface PlaceSearchResultPanelView : UIView <UIScrollViewAccessibilityDelegate>
@property (weak, nonatomic) UIView *infoView;
@property (weak, nonatomic) UIButton *leftButton;
@property (weak, nonatomic) UIButton *rightButton;
@property (weak, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) UIPageControl *pageControl;
@property (weak, nonatomic) UILabel *nameLabel;
@property (weak, nonatomic) UILabel *addressLabel;
@property (nonatomic) int pageNum;
@property (weak) id<PlaceSearchResultPanelViewDelegate> delegate;
-(void) updatePlaces:(NSArray*) places;
-(IBAction) handleTapFrom: (UITapGestureRecognizer *)recognizer;
@end
