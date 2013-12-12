//
//  PlaceSearchResultPanelView.m
//  NavierIOS
//
//  Created by Coming on 12/7/13.
//  Copyright (c) 2013 Coming. All rights reserved.
//

#import "PlaceSearchResultPanelView.h"
#import "Place.h"

#include "Log.h"

@implementation PlaceSearchResultPanelView
{
    int _pageNum;
    NSArray* _places;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self initSelf];
    }
    return self;
}

-(void) initSelf
{
    _infoView       = (UIView *)[self viewWithTag:100];
    _leftButton     = (UIButton *)[self viewWithTag:101];
    _rightButton    = (UIButton *)[self viewWithTag:102];
    _scrollView     = (UIScrollView *)[self viewWithTag:201];
    _pageControl    = (UIPageControl *)[self viewWithTag:202];
    _nameLabel      = (UILabel *)[self viewWithTag:301];
    _addressLabel   = (UILabel *)[self viewWithTag:302];
    
    _nameLabel.hidden           = YES;
    _addressLabel.hidden        = YES;
    _pageNum                    = -1;
    
    /* configure semi-transparent background */
    self.backgroundColor        = [[UIColor whiteColor] colorWithAlphaComponent:0.85];
    _scrollView.delegate        = self;

    
}

-(void) updatePlaces:(NSArray*) places
{
    int i;
    Place* place;
    UILabel *placeName;
    UILabel *placeAddr;
    CGRect frame;
    
    [[self.scrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];

    _places = [[NSArray alloc] initWithArray:places];
    
    for (i=0; i<places.count; i++)
    {
        place       = (Place*) [places objectAtIndex:i];
        
        placeName   = [[UILabel alloc] init];
        [placeName setText: place.name];
        [placeName setFont:self.nameLabel.font];
        [placeName setTextColor:self.nameLabel.textColor];
        
        frame           = self.nameLabel.frame;
        frame.origin.x += self.nameLabel.frame.size.width*i;
        
        placeName.frame = frame;
        
        placeAddr   = [[UILabel alloc] init];
        [placeAddr setText: place.address];
        [placeAddr setFont:self.addressLabel.font];
        [placeAddr setTextColor:self.addressLabel.textColor];
        
        frame           = self.addressLabel.frame;
        frame.origin.x += self.addressLabel.frame.size.width*i;
        placeAddr.frame = frame;
        
        
        [self.scrollView addSubview:placeName];
        [self.scrollView addSubview:placeAddr];
    }
    
    self.scrollView.contentSize     = CGSizeMake(self.scrollView.frame.size.width*i, self.scrollView.frame.size.height);
    self.scrollView.pagingEnabled   = YES;
    self.pageControl.numberOfPages  = i;
    self.pageNum                    = 0;
    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int page;

    page = self.scrollView.contentOffset.x/self.scrollView.frame.size.width;
    
    if (page >= _places.count)
        return;

    self.pageNum = page;
}

-(int) pageNum
{
    return _pageNum;
}

-(void) setPageNum:(int)pageNum
{
    if (pageNum >= _places.count || pageNum < 0)
    {
        return;
    }
    _pageNum = pageNum;

    self.pageControl.currentPage = self.pageNum;
    self.leftButton.hidden  = self.pageNum == 0 ? YES:NO;
    self.rightButton.hidden = self.pageNum == self.pageControl.numberOfPages-1 ? YES:NO;
    
    /* notify the delegate */
    if (nil != self.delegate && [self.delegate respondsToSelector:@selector(placeSearchResultPanelView:moveToPlace:)])
    {
        [self.delegate placeSearchResultPanelView:self moveToPlace:[_places objectAtIndex:self.pageNum]];
    }
    
}

-(IBAction) handleTapFrom: (UITapGestureRecognizer *)recognizer
{
    self.pageNum = self.pageNum;
}

-(IBAction) pressLeftButton:(UIButton*) sender
{
    self.pageNum--;
}

-(IBAction) pressRightButton:(UIButton*) sender
{
    self.pageNum++;
}
@end
