//
//  GoogleMapUIViewController.m
//  NavierIOS
//
//  Created by Coming on 13/2/25.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "GoogleMapUIViewController.h"
#import "SavePlaceViewController.h"
#import "SelectPlaceViewController.h"
#import "RouteNavigationViewController.h"
#import "MarkerMenuFloatView.h"
#import "PlaceSearchResultPanelView.h"

#define FILE_DEBUG TRUE
#include <NaviUtil/Log.h>


#define MARKER_MENU_FLOAT_OFFSET 10

@interface GoogleMapUIViewController ()
{
    
    BOOL isMapMovedAfterTappingMarker;
}
@end

@implementation GoogleMapUIViewController
{
    ADBannerView *adView;
    int markMenuOffset;
    bool isShowMarkMenu;
    bool isShowMarkMenuFloat;
    UIView *markMenu;
    MarkerMenuFloatView *markerMenuFloatView;
    PlaceSearchResultPanelView *placeSearchResultPanel;

    RouteNavigationViewController *routeNavigationViewController;
    Place *selectedPlace;
    
    UILabel *markMenuNameLabel;
    UILabel *markMenuSnippetLabel;
    UIButton *markMenuSetStartButton;
    UIButton *markMenuSetEndButton;
    UIButton *markMenuSaveAsHomeButton;
    UIButton *markMenuSaveAsOfficeButton;
    UIButton *markMenuSaveAsFavorButton;
    
    SavePlaceViewController *savePlaceViewController;
    SelectPlaceViewController *selectPlaceViewController;
    
    MapManager *mapManager;
    int zoomLevel;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    
}

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self = [super init];
        if (self)
        {
        }
    }
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}


-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    
    return toInterfaceOrientation == UIInterfaceOrientationLandscapeRight;
}


- (void)viewDidLoad
{
    
    
    NSString* navigationText;
    NSString* placeText;
    UIFont* textFont;
    [super viewDidLoad];
    
    
//    self.view.frame = [SystemManager lanscapeScreenRect];

    isMapMovedAfterTappingMarker        = FALSE;
    /* google map initialization */
    mapManager                          = [[MapManager alloc] init];
    mapManager.mapView.frame            = CGRectMake(0, 0, self.googleMapView.frame.size.width, self.googleMapView.frame.size.height);
    mapManager.mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    mapManager.mapView.delegate         = self;
    mapManager.delegate                 = self;
    [self.googleMapView insertSubview:mapManager.mapView atIndex:0];
    
    
    textFont = [UIFont boldSystemFontOfSize:14.0];
    navigationText = [SystemManager getLanguageString:@"Navigate"];
    placeText = [SystemManager getLanguageString:@"Place"];
    
    [self.navigationButton setTitle:navigationText forState:UIControlStateNormal];
    [self.placeButton setTitle:placeText forState:UIControlStateNormal];
    
    [self addMarkerMenuFloat];
    [self addPlaceSearchResultPanel];
    
    savePlaceViewController         = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass
                                       ([SavePlaceViewController class])];
    selectPlaceViewController       = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass
                                       ([SelectPlaceViewController class])];
    routeNavigationViewController   = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass
                                       ([RouteNavigationViewController class])];
    
    savePlaceViewController.delegate    = self;
    selectPlaceViewController.delegate  = self;
    
    [self addBanner:self.contentView];
    [self showAdAnimated:NO];
    
    self.topView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.85];
    
}


- (void)viewDidUnload {
    [self setTitleLabel:nil];
    [self setNavigationButton:nil];
    [self setPlaceButton:nil];
    [self setPressPlaceButton:nil];
    [self setContentView:nil];
    [self setGoogleMapView:nil];
    [self setTopView:nil];
    [self setZoomPanel:nil];
    [super viewDidUnload];
}

-(void) viewWillAppear:(BOOL)animated
{
    
    if(self.placeToSearch != nil && self.placeToSearch.length > 0)
    {
        [mapManager searchPlace:self.placeToSearch];
    }

    [self showAdAnimated:NO];
    [self hideMarkerMenuFloat];

    /* update current place and reset the route start place */
    mapManager.updateToCurrentPlace         = TRUE;
    mapManager.useCurrentPlaceAsRouteStart  = TRUE;
    
}

#pragma  mark - Banner
-(void) addBanner:(UIView*) contentView
{
    if (FALSE == [SystemConfig getBoolValue:CONFIG_IS_AD])
        return;
    
    if ([ADBannerView instancesRespondToSelector:@selector(initWithAdType:)])
    {
        adView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
    } else
    {
        adView = [[ADBannerView alloc] init];
    }
    
    //    adView = [[ADBannerView alloc] initWithFrame:CGRectZero];
//    adView.requiredContentSizeIdentifiers      = [NSSet setWithObject:ADBannerContentSizeIdentifierLandscape];
//    adView.currentContentSizeIdentifier        = ADBannerContentSizeIdentifierLandscape;
    [adView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    adView.delegate                            = self;
    adView.accessibilityLabel                  = @"banner";


    [self.view addSubview:adView];

    [self showAdAnimated:NO];
}

- (void)showAdAnimated:(BOOL)animated
{

    if (nil == adView)
        return;

    CGRect contentFrame = self.contentView.frame;
    CGRect bannerFrame = adView.frame;
    CGRect zoomPanelFrame = self.zoomPanel.frame;
    
    if (adView.bannerLoaded)
    {
        
        contentFrame.origin.y        = adView.frame.size.height;
        if (contentFrame.size.height + adView.frame.size.height != self.view.bounds.size.height)
        {
            contentFrame.size.height = self.view.bounds.size.height - adView.frame.size.height;
        }
        bannerFrame.origin.y         = 0;
        
    } else
    {
        contentFrame.origin.y       = 0;
        contentFrame.size.height    = self.view.bounds.size.height;
        bannerFrame.origin.y        = -adView.frame.size.height;
    }

    [UIView animateWithDuration:animated ? 0.25 : 0.0 animations:^{
        _contentView.frame  = contentFrame;
        _zoomPanel.frame    = zoomPanelFrame;
        adView.frame       = bannerFrame;
        
    }];
    
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (!self.bannerIsVisible)
    {
        //        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        // Assumes the banner view is just off the bottom of the screen.
        //        banner.frame = CGRectOffset(banner.frame, 0, -banner.frame.size.height);
        //        [UIView commitAnimations];
        self.bannerIsVisible = YES;
        [self showAdAnimated:YES];
        
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    if (self.bannerIsVisible)
    {
        self.bannerIsVisible = NO;
        [self showAdAnimated:YES];
    }
}


- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    BOOL shouldExecuteAction = true; // your application implements this method
    
    if (!willLeave && shouldExecuteAction)
    {
        // insert code here to suspend any services that might conflict with the advertisement
    }
    
    return shouldExecuteAction;
    
    return false;
}



- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    
}

#pragma  mark - MarkMenuFloat
-(void) addMarkerMenuFloat
{
    isShowMarkMenu = false;

    NSArray *xibContents = [[NSBundle mainBundle] loadNibNamed:@"MarkerMenuFloat" owner:self options:nil];
    markerMenuFloatView = [xibContents lastObject];

    markerMenuFloatView.hidden = TRUE;
    
    [markerMenuFloatView.routeStartButton addTarget:self
                                             action:@selector(pressRouteStartButton:)
                                   forControlEvents:UIControlEventTouchUpInside];

    [markerMenuFloatView.routeEndButton addTarget:self
                                             action:@selector(pressRouteEndButton:)
                                   forControlEvents:UIControlEventTouchUpInside];

    [markerMenuFloatView.saveAsHomeButton addTarget:self
                                             action:@selector(pressSaveAsHomeButton:)
                                   forControlEvents:UIControlEventTouchUpInside];

    [markerMenuFloatView.saveAsOfficeButton addTarget:self
                                             action:@selector(pressSaveAsOfficeButton:)
                                   forControlEvents:UIControlEventTouchUpInside];

    [markerMenuFloatView.saveAsFavorButton addTarget:self
                                             action:@selector(pressSaveAsFavorButton:)
                                   forControlEvents:UIControlEventTouchUpInside];

    

    [self.googleMapView addSubview:markerMenuFloatView];

}


-(void) showMarkerMenuFloat:(CGPoint) pos
{
//    if (false == isShowMarkMenuFloat)
    {
        /* show full menu for searched places */
        if (kPlaceType_Home     == selectedPlace.placeType ||
            kPlaceType_Office   == selectedPlace.placeType ||
            kPlaceType_Favor    == selectedPlace.placeType)
        {
            [markerMenuFloatView showRouteButtonOnly];
            
        }
        /* show only route button menu for saved places */
        else
        {
            [markerMenuFloatView show];
        }
        
        isShowMarkMenuFloat = TRUE;

        markerMenuFloatView.hidden   = FALSE;
        [self moveMarkerMenuFloat:pos];
    }
}

-(void) hideMarkerMenuFloat
{
    if (true == isShowMarkMenuFloat)
    {
        isShowMarkMenuFloat     = false;
        markerMenuFloatView.hidden   = !isShowMarkMenuFloat;

    }
}

-(void) moveMarkerMenuFloat:(CGPoint) pos
{
    CGRect frame;
    
    frame = markerMenuFloatView.frame;
    
    frame.origin.x      = pos.x - frame.size.width/2;
    frame.origin.y      = pos.y + MARKER_MENU_FLOAT_OFFSET;
    
    markerMenuFloatView.frame    = frame;
}

#pragma  mark - MarkMenu


-(void) saveAsHome:(Place*)p
{
    if (p.placeType != kPlaceType_SearchedPlace)
    {
        [self hideMarkerMenuFloat];
        return;
    }
    
    savePlaceViewController.currentPlace = p;
    savePlaceViewController.sectionMode  = kSectionMode_Home;
    [self presentViewController:savePlaceViewController animated:YES completion:nil];
}

-(void) saveAsOffice:(Place*)p
{
    if (p.placeType != kPlaceType_SearchedPlace)
    {
        [self hideMarkerMenuFloat];
        return;
    }
    
    savePlaceViewController.currentPlace = p;
    savePlaceViewController.sectionMode  = kSectionMode_Office;
    [self presentViewController:savePlaceViewController animated:YES completion:nil];
}

-(void) saveAsFavor:(Place*)p
{
    
    if (p.placeType != kPlaceType_SearchedPlace)
    {
        [self hideMarkerMenuFloat];
        return;
    }
    
    savePlaceViewController.currentPlace = p;
    savePlaceViewController.sectionMode  = kSectionMode_Favor;
    [self presentViewController:savePlaceViewController animated:YES completion:nil];
}


-(void) updateMarkMenu
{
    if (nil != selectedPlace)
    {
        
        markMenuNameLabel.text      = selectedPlace.name;
        markMenuSnippetLabel.text   = selectedPlace.address;
    }
}

-(void) addMarkMenu
{
    isShowMarkMenu = false;
    
    NSArray *xibContents = [[NSBundle mainBundle] loadNibNamed:@"MarkMenu" owner:self options:nil];
    
    CGRect frame;
    
    frame.origin.x      = self.view.frame.size.width;
    frame.origin.y      = 0;
    frame.size.width    = 200;
    frame.size.height   = 460;
    
    
    
    markMenu = [xibContents lastObject];
    markMenu.accessibilityLabel = @"markMenu";
    
    markMenu.frame = frame;
    

    markMenuSetStartButton      = (UIButton *)[markMenu viewWithTag:3];
    markMenuSetEndButton        = (UIButton *)[markMenu viewWithTag:4];
    markMenuSaveAsHomeButton    = (UIButton *)[markMenu viewWithTag:5];
    markMenuSaveAsOfficeButton  = (UIButton *)[markMenu viewWithTag:6];
    markMenuSaveAsFavorButton   = (UIButton *)[markMenu viewWithTag:7];
    
    
    [markMenuSetStartButton addTarget:self
                               action:@selector(pressSetStartButton:)
                     forControlEvents:UIControlEventTouchUpInside];
    
    [markMenuSetEndButton addTarget:self
                             action:@selector(pressSetEndButton:)
                   forControlEvents:UIControlEventTouchUpInside];
    
    [markMenuSaveAsHomeButton addTarget:self
                                 action:@selector(pressSaveAsHomeButton:)
                       forControlEvents:UIControlEventTouchUpInside];
    
    [markMenuSaveAsOfficeButton addTarget:self
                                   action:@selector(pressSaveAsOfficeButton:)
                         forControlEvents:UIControlEventTouchUpInside];
    
    [markMenuSaveAsFavorButton addTarget:self
                                  action:@selector(pressSaveAsFavorButton:)
                        forControlEvents:UIControlEventTouchUpInside];
    
    [self.googleMapView addSubview:markMenu];
}

-(void) showMarkMenu
{
    if (false == isShowMarkMenu)
    {
        isShowMarkMenu = true;
        [self updateMarkMenu];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:.4];
        markMenu.frame = CGRectOffset( markMenu.frame, (-1)*markMenuOffset, 0 ); // offset by an amount
        [UIView commitAnimations];
    }
}

-(void) hideMarkMenu
{
    if (true == isShowMarkMenu)
    {
        isShowMarkMenu = false;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:.4];
        markMenu.frame = CGRectOffset( markMenu.frame, markMenuOffset, 0 ); // offset by an amount
        [UIView commitAnimations];
    }
    
}

#if 0
-(void) setRouteStart:(Place*) p
{
    if ([routeEndPlace isCoordinateEqualTo:p])
    {
        routeEndPlace = nil;
    }
    
    if (![routeStartPlace isCoordinateEqualTo:p])
    {
        isRouteChanged                  = true;
        routeStartPlace.placeRouteType  = kPlaceRouteType_None;
        routeStartPlace                 = p;
        routeStartPlace.placeRouteType  = kPlaceRouteType_Start;
        [self planRoute];
    }
}

-(void) setRouteEnd:(Place*) p
{
    if ([routeStartPlace isCoordinateEqualTo:p])
    {
        routeStartPlace = nil;
    }
    
    if (![routeEndPlace isCoordinateEqualTo:p])
    {
        isRouteChanged                  = true;
        routeEndPlace.placeRouteType    = kPlaceRouteType_None;
        routeEndPlace                   = p;
        routeEndPlace.placeRouteType    = kPlaceRouteType_End;
        [self planRoute];
    }
    
}

-(void) saveAsHome:(Place*)p
{
    if (p.placeType != kPlaceRouteType_None)
    {
        [self hideMarkMenu];
        return;
    }
    savePlaceViewController.currentPlace = p;
    savePlaceViewController.sectionMode  = kSectionMode_Home;
    [self presentModalViewController:savePlaceViewController animated:YES];
}

-(void) saveAsOffice:(Place*)p
{
    if (p.placeType != kPlaceRouteType_None)
    {
        [self hideMarkMenu];
        return;
    }
    
    savePlaceViewController.currentPlace = p;
    savePlaceViewController.sectionMode  = kSectionMode_Office;
    [self presentModalViewController:savePlaceViewController animated:YES];
}

-(void) saveAsFavor:(Place*)p
{

    if (p.placeType != kPlaceRouteType_None)
    {
        [self hideMarkMenu];
        return;
    }
    
    savePlaceViewController.currentPlace = p;
    savePlaceViewController.sectionMode  = kSectionMode_Favor;
    [self presentModalViewController:savePlaceViewController animated:YES];
}


-(void) updateMarkMenu
{
    if (nil != selectedPlace)
    {
        
        markMenuNameLabel.text      = selectedPlace.name;
        markMenuSnippetLabel.text   = selectedPlace.address;
    }
}

-(void) addMarkMenu
{
    isShowMarkMenu = false;
    
    NSArray *xibContents = [[NSBundle mainBundle] loadNibNamed:@"MarkMenu" owner:self options:nil];
    
    CGRect frame;
    
    frame.origin.x      = self.view.frame.size.width;
    frame.origin.y      = 0;
    frame.size.width    = 200;
    frame.size.height   = 460;
    

    
    _markMenu = [xibContents lastObject];
    _markMenu.accessibilityLabel = @"markMenu";
    
    _markMenu.frame = frame;
    
    markMenuNameLabel           =  (UILabel *)[_markMenu viewWithTag:1];
    markMenuSnippetLabel        =  (UILabel *)[_markMenu viewWithTag:2];
    markMenuSetStartButton      = (UIButton *)[_markMenu viewWithTag:3];
    markMenuSetEndButton        = (UIButton *)[_markMenu viewWithTag:4];
    markMenuSaveAsHomeButton    = (UIButton *)[_markMenu viewWithTag:5];
    markMenuSaveAsOfficeButton  = (UIButton *)[_markMenu viewWithTag:6];
    markMenuSaveAsFavorButton   = (UIButton *)[_markMenu viewWithTag:7];
    
    
    
    [markMenuSetStartButton addTarget:self
                               action:@selector(pressSetStartButton:)
                     forControlEvents:UIControlEventTouchUpInside];
    
    [markMenuSetEndButton addTarget:self
                             action:@selector(pressSetEndButton:)
                   forControlEvents:UIControlEventTouchUpInside];
    
    [markMenuSaveAsHomeButton addTarget:self
                                 action:@selector(pressSaveAsHomeButton:)
                       forControlEvents:UIControlEventTouchUpInside];
    
    [markMenuSaveAsOfficeButton addTarget:self
                                   action:@selector(pressSaveAsOfficeButton:)
                         forControlEvents:UIControlEventTouchUpInside];
    
    [markMenuSaveAsFavorButton addTarget:self
                                  action:@selector(pressSaveAsFavorButton:)
                        forControlEvents:UIControlEventTouchUpInside];
    
    [self.googleMapView addSubview:_markMenu];
}

-(void) showMarkMenu
{
    if (false == isShowMarkMenu)
    {
        isShowMarkMenu = true;
        [self updateMarkMenu];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:.4];
        _markMenu.frame = CGRectOffset( _markMenu.frame, (-1)*markMenuOffset, 0 ); // offset by an amount
        [UIView commitAnimations];
    }
}

-(void) hideMarkMenu
{
    if (true == isShowMarkMenu)
    {
        isShowMarkMenu = false;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:.4];
        _markMenu.frame = CGRectOffset( _markMenu.frame, markMenuOffset, 0 ); // offset by an amount
        [UIView commitAnimations];
    }
    
}

#endif


#pragma mark - Search Place

-(void) addPlaceSearchResultPanel
{
    CGRect frame;
    CGRect landscapeFrame;
    NSArray *xibContents = [[NSBundle mainBundle] loadNibNamed:@"PlaceSearchResultPanel" owner:self options:nil];
    
    
    placeSearchResultPanel          = [xibContents objectAtIndex:0];
    placeSearchResultPanel.hidden   = YES;
    landscapeFrame                  = self.view.bounds;

    if (landscapeFrame.size.height > landscapeFrame.size.width)
    {
        CGFloat tmpValue;
        tmpValue                    = landscapeFrame.size.width;
        landscapeFrame.size.width   = landscapeFrame.size.height;
        landscapeFrame.size.height  = tmpValue;
    }
    
    frame                                       = placeSearchResultPanel.frame;
    frame.origin.x                              = (landscapeFrame.size.width - frame.size.width)/2;
    frame.origin.y                              = landscapeFrame.size.height - frame.size.height;
    
    placeSearchResultPanel.frame                = frame;
    placeSearchResultPanel.autoresizingMask     = UIViewAutoresizingFlexibleTopMargin;
    placeSearchResultPanel.delegate             = self;

    [self.googleMapView addSubview:placeSearchResultPanel];
    
}



-(void) showSearchPlacePanel
{
    if (YES == placeSearchResultPanel.hidden)
    {
        placeSearchResultPanel.hidden = NO;
    }
}

-(void) hideSearchPlacePanel
{
    if (NO == placeSearchResultPanel.hidden)
    {
        placeSearchResultPanel.hidden = YES;
    }
    
}



#pragma mark - Operations

-(void) searchPlace:(NSString*) placeText
{
    [mapManager searchPlace:placeText];
}

#pragma  mark - UI Actions

- (IBAction)pressZoomOutButton:(id)sender
{
    [mapManager zoomIn];
}

- (IBAction)pressZoomInButton:(id)sender
{
    [mapManager zoomOut];
}

- (IBAction)pressHomeButton:(id)sender
{
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)pressSearchButton:(id)sender
{
    
}

- (IBAction)pressPlaceButton:(id)sender
{
    if ([User getSectionCount:selectPlaceViewController.sectionMode] > 0)
    {
        [self presentViewController:selectPlaceViewController animated:YES completion:nil];
    }
}

- (IBAction)pressNavigationButton:(id)sender
{
    if (YES == mapManager.hasRoute)
    {
        [routeNavigationViewController startRouteNavigationFrom:mapManager.routeStartPlace To:mapManager.routeEndPlace];
        [self presentViewController:routeNavigationViewController animated:YES completion:nil];
    }

    [self hideMarkerMenuFloat];
}

- (IBAction)pressTestButton:(id)sender
{
    
    [self presentViewController:selectPlaceViewController animated:YES completion:nil];
    
}


-(IBAction) pressRouteStartButton:(id) sender
{
    mapManager.routeStartPlace = selectedPlace;
    [self hideMarkerMenuFloat];
}

-(IBAction) pressRouteEndButton:(id) sender
{
    mapManager.routeEndPlace = selectedPlace;
    [self hideMarkerMenuFloat];
}

-(IBAction) pressSaveAsHomeButton:(id) sender
{
    [self saveAsHome:selectedPlace];
    [self hideMarkerMenuFloat];
}

-(IBAction) pressSaveAsOfficeButton:(id) sender
{
    [self saveAsOffice:selectedPlace];
    [self hideMarkerMenuFloat];
    
}

-(IBAction) pressSaveAsFavorButton:(id) sender
{
    [self saveAsFavor:selectedPlace];
    [self hideMarkerMenuFloat];
}

#pragma mark - delegates

- (BOOL) mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    CGPoint point;
    Place* tmpPlace;
    tmpPlace = [mapManager placeByMarker:marker];
    
    if (nil != tmpPlace)
    {
        point = [mapView.projection pointForCoordinate:marker.position];
        /* tap a new marker */
        if (tmpPlace != selectedPlace)
        {
            selectedPlace = tmpPlace;
            [self showMarkerMenuFloat:point];
        }
        /* tap on the same marker */
        else
        {
            if (NO == isMapMovedAfterTappingMarker)
            {
                if (YES == isShowMarkMenuFloat)
                    [self hideMarkerMenuFloat];
                else
                    [self showMarkerMenuFloat:point];
            }
            /* info window is hidden now, so hide marker menu */
            else
            {
                [self hideMarkerMenuFloat];
            }
        }
    }

    isMapMovedAfterTappingMarker = FALSE;
    

    return NO;
}


- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    CGPoint p;
    p = [mapView.projection pointForCoordinate:coordinate];
    
    if (YES == isShowMarkMenuFloat)
    {
        [self hideMarkerMenuFloat];
    }
    
}

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position
{
    if (YES == isShowMarkMenuFloat)
    {
        [self moveMarkerMenuFloat:[mapView.projection pointForCoordinate:position.target]];
    }

    isMapMovedAfterTappingMarker = TRUE;
}

- (void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture;
{
    if (YES == gesture)
    {
        [self hideMarkerMenuFloat];
    }
}

-(void) mapManager: (MapManager*) mapManager placeSearchResult:(NSArray*) places
{
    if (nil != places && places.count > 0)
    {
        [placeSearchResultPanel updatePlaces:places];
        [self showSearchPlacePanel];
    }
}

-(void) mapManager: (MapManager*) mapManager updateCurrentPlace:(Place*) place
{
    if (nil != place)
    {
        [self hideMarkerMenuFloat];
    }
    
}

-(void) placeSearchResultPanelView:(PlaceSearchResultPanelView*) pv moveToPlace:(Place*) p;
{
    [self hideMarkerMenuFloat];
    [mapManager moveToPlace:p];
}

-(void) savePlaceViewController:(SavePlaceViewController*) spvc placeChanged:(BOOL) placeChanged
{
    if (YES == placeChanged)
        [mapManager refreshMap];
}

-(void) selectPlaceViewController:(SelectPlaceViewController*) s placeSelected:(Place*) p
{
    if (nil == p)
        return;
    
    selectedPlace = p;
    [mapManager moveToPlace:p];
}

-(void) selectPlaceViewController:(SelectPlaceViewController*) s placeEdited:(BOOL) placeEdited
{
    if (YES == placeEdited)
        [mapManager refreshMap];
}

@end

