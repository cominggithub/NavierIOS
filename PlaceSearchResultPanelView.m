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
    static int round = 0;
    
//    [[self.scrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    while ([self.scrollView .subviews count] > 0) {
        //NSLog(@"subviews Count=%d",[[myScrollView subviews]count]);
        [[[self.scrollView  subviews] objectAtIndex:0] removeFromSuperview];
    }

    _places = [[NSArray alloc] initWithArray:places];
    
    round++;

    
    for (i=0; i<places.count && i<3; i++)
    {

        place       = (Place*) [places objectAtIndex:i];
        placeName   = [[UILabel alloc] init];
        [placeName setText:[NSString stringWithFormat:@"%@", place.name]];
        [placeName setFont:self.nameLabel.font];
        [placeName setTextColor:self.nameLabel.textColor];
        [placeName setTextAlignment:self.nameLabel.textAlignment];
        
        frame           = self.nameLabel.frame;
        frame.origin.x += self.nameLabel.frame.size.width*i;

        if (place.address.length < 1)
        {
            frame.origin.y += 10;
        }
        
        placeName.frame = frame;
        
        placeAddr   = [[UILabel alloc] init];
        [placeAddr setText: place.address];
        [placeAddr setFont:self.addressLabel.font];
        [placeAddr setTextColor:self.addressLabel.textColor];
        [placeAddr setTextAlignment:self.addressLabel.textAlignment];
        
        frame           = self.addressLabel.frame;
        frame.origin.x += self.addressLabel.frame.size.width*i;
        placeAddr.frame = frame;
        
        
        [self.scrollView addSubview:placeName];
        [self.scrollView addSubview:placeAddr];
        logfn();
    }
    
    if (places.count > 0)
    {
        self.scrollView.contentSize     = CGSizeMake(self.scrollView.frame.size.width*i, self.scrollView.frame.size.height);
        self.scrollView.pagingEnabled   = YES;
        self.pageControl.numberOfPages  = i;
        
        [self.scrollView setContentOffset:CGPointMake(0,0) animated:YES];
    }
    
    if (places.count > 0)
    {
        self.pageNum                    = 0;
    }
    
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

    self.pageControl.currentPage    = self.pageNum;
    self.leftButton.hidden          = self.pageNum == 0 ? YES:NO;
    
    if (nil != _places && _places.count > 1)
    {
        self.rightButton.hidden = self.pageNum == self.pageControl.numberOfPages-1 ? YES:NO;
    }
    else
    {
        self.rightButton.hidden = YES;
    }
    
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width*self.pageNum,0) animated:YES];

    
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
