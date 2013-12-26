//
//  CarPanel1Menu.m
//  NavierIOS
//
//  Created by Coming on 12/13/13.
//  Copyright (c) 2013 Coming. All rights reserved.
//

#import "CarPanel1MenuView.h"
#import <NaviUtil/NaviUtil.h>


#include "Log.h"

@implementation CarPanel1MenuView
{
    
    BOOL _isHud;
    UIColor *_panelColor;
    UIColor *_panelColor1;
    UIColor *_panelColor2;
    UIColor *_panelColor3;
    UIColor *_panelColor4;
    UIColor *_panelColor5;
    NSMutableArray* colorButtons;
    CGSize colorButtonUnselectedSize;
    CGSize colorButtonSelectedSize;
}

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initSelf];
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
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
    self.backIconButton     = (UIButton*) [self viewWithTag:1];
    self.backButton         = (UIButton*) [self viewWithTag:2];
    self.closeButton        = (UIButton*) [self viewWithTag:3];
    self.hudSwitch          = (UISwitch*) [self viewWithTag:301];
    self.speedMphButton     = (UIButton*) [self viewWithTag:303];
    self.speedKmhButton     = (UIButton*) [self viewWithTag:304];
    
    self.panelColor1Button  = (UIButton*) [self viewWithTag:101];
    self.panelColor2Button  = (UIButton*) [self viewWithTag:102];
    self.panelColor3Button  = (UIButton*) [self viewWithTag:103];
    self.panelColor4Button  = (UIButton*) [self viewWithTag:104];
    self.panelColor5Button  = (UIButton*) [self viewWithTag:105];
    
    self.hudLabel           = (UILabel*) [self viewWithTag:201];
    self.speedUnitLabel     = (UILabel*) [self viewWithTag:203];

    
    [self.backIconButton    addTarget:self action:@selector(pressLogoButton:)           forControlEvents:UIControlEventTouchUpInside];
    [self.backButton        addTarget:self action:@selector(pressLogoButton:)           forControlEvents:UIControlEventTouchUpInside];
    [self.closeButton       addTarget:self action:@selector(pressCloseButton:)          forControlEvents:UIControlEventTouchUpInside];
    [self.speedMphButton    addTarget:self action:@selector(pressSpeedUnitMphButton:)   forControlEvents:UIControlEventTouchUpInside];
    [self.speedKmhButton    addTarget:self action:@selector(pressSpeedUnitKmhButton:)   forControlEvents:UIControlEventTouchUpInside];
    [self.panelColor1Button addTarget:self action:@selector(pressPanelColor1Button:)    forControlEvents:UIControlEventTouchUpInside];
    [self.panelColor2Button addTarget:self action:@selector(pressPanelColor2Button:)    forControlEvents:UIControlEventTouchUpInside];
    [self.panelColor3Button addTarget:self action:@selector(pressPanelColor3Button:)    forControlEvents:UIControlEventTouchUpInside];
    [self.panelColor4Button addTarget:self action:@selector(pressPanelColor4Button:)    forControlEvents:UIControlEventTouchUpInside];
    [self.panelColor5Button addTarget:self action:@selector(pressPanelColor5Button:)    forControlEvents:UIControlEventTouchUpInside];
    [self.hudSwitch         addTarget:self action:@selector(hudSwitchValueChanged:)     forControlEvents:UIControlEventValueChanged];

    [self.backButton setTitle:[SystemManager getLanguageString:self.backButton.titleLabel.text] forState:UIControlStateNormal];
    self.hudLabel.text          = [SystemManager getLanguageString:self.hudLabel.text];
    self.speedUnitLabel.text    = [SystemManager getLanguageString:self.speedUnitLabel.text];
    
    colorButtons = [[NSMutableArray alloc] initWithObjects:
                    self.panelColor1Button,
                    self.panelColor2Button,
                    self.panelColor3Button,
                    self.panelColor4Button,
                    self.panelColor5Button, nil];

    /* calculate color button size for selected ans unselected status */
    colorButtonUnselectedSize       = self.panelColor1Button.frame.size;
    colorButtonSelectedSize         = colorButtonUnselectedSize;
    colorButtonSelectedSize.width  += 16;
    colorButtonSelectedSize.height += 16;

 
    self.hidden = true;
    
    /* configure rounded border */
    self.layer.borderColor    = [UIColor grayColor].CGColor;
    self.layer.borderWidth    = 3.0f;
    self.layer.cornerRadius   = 10;
    self.layer.masksToBounds  = YES;
    
    /* adjust center to center position */
    self.frame = CGRectMake(
                            ([SystemManager lanscapeScreenRect].size.width - self.frame.size.width)/2,
                            50,
                            self.frame.size.width,
                            self.frame.size.height
                            );
    
    
}


-(IBAction) pressLogoButton:(id) sender
{
    if (nil != self.delegate && [self.delegate respondsToSelector:@selector(carPanel1MenuView:pressLogoButton:)])
    {
        [self.delegate carPanel1MenuView:self pressLogoButton:TRUE];
    }
}

-(IBAction) pressCloseButton:(id) sender
{
    if (nil != self.delegate && [self.delegate respondsToSelector:@selector(carPanel1MenuView:pressCloseButton:)])
    {
        [self.delegate carPanel1MenuView:self pressCloseButton:TRUE];
    }
}

-(IBAction) pressSpeedUnitMphButton:(id) sender
{
    self.isSpeedUnitMph = TRUE;
}

-(IBAction) pressSpeedUnitKmhButton:(id) sender
{
    self.isSpeedUnitMph = FALSE;
}

-(IBAction) pressPanelColor1Button:(id) sender
{
    self.panelColor = self.panelColor1Button.backgroundColor;
}

-(IBAction) pressPanelColor2Button:(id) sender
{
    self.panelColor = self.panelColor2Button.backgroundColor;
}

-(IBAction) pressPanelColor3Button:(id) sender
{
    self.panelColor = self.panelColor3Button.backgroundColor;
}

-(IBAction) pressPanelColor4Button:(id) sender
{
    self.panelColor = self.panelColor4Button.backgroundColor;
}

-(IBAction) pressPanelColor5Button:(id) sender
{
    self.panelColor = self.panelColor5Button.backgroundColor;
}

-(IBAction) hudSwitchValueChanged:(id) sender
{
    self.isHud = self.hudSwitch.isOn;
}

-(void) setIsHud:(BOOL)isHud
{
    _isHud = isHud;
    [self.hudSwitch setOn:self.isHud];
    
    /* notify the delegate */
    if (nil != self.delegate && [self.delegate respondsToSelector:@selector(carPanel1MenuView:changeHud:)])
    {
        [self.delegate carPanel1MenuView:self changeHud:self.isHud];
    }
    
}

-(void) setIsSpeedUnitMph:(BOOL)isMph
{
    _isSpeedUnitMph = isMph;
    
    if (YES == self.isSpeedUnitMph)
    {
        [self.speedKmhButton setBackgroundColor:[UIColor blackColor]];
        [self.speedMphButton setBackgroundColor:[UIColor blueColor]];
    }
    else
    {
        [self.speedKmhButton setBackgroundColor:[UIColor blueColor]];
        [self.speedMphButton setBackgroundColor:[UIColor blackColor]];
    }
    
    /* notify the delegate */
    if (nil != self.delegate && [self.delegate respondsToSelector:@selector(carPanel1MenuView:changeSpeedUnit:)])
    {
        [self.delegate carPanel1MenuView:self changeSpeedUnit:self.isSpeedUnitMph];
    }
}

-(void) setPanelColor:(UIColor *)panelColor
{
    int i;
    UIButton* button;
    
    _panelColor = panelColor;
    
    /* reset all button size */
    for(i=0; i<colorButtons.count; i++)
    {
        button = [colorButtons objectAtIndex:i];
        if ( YES == CGColorEqualToColor(button.backgroundColor.CGColor, self.panelColor.CGColor))
        {
            [self setColorButtonSelected:button];
        }
        else
        {
            [self setColorButtonUnSelected:button];
        }
    }
    
    /* notify the delegate */
    if (nil != self.delegate && [self.delegate respondsToSelector:@selector(carPanel1MenuView:changeColor:)])
    {
        [self.delegate carPanel1MenuView:self changeColor:self.panelColor];
    }
    
}

-(void) setColorButtonSelected:(UIButton*) button
{
    
    CGRect buttonFrame;
    buttonFrame = button.frame;
    
    if (buttonFrame.size.width == colorButtonUnselectedSize.width)
    {
        buttonFrame.origin.x -= (colorButtonSelectedSize.width  - colorButtonUnselectedSize.width)/2;
        buttonFrame.origin.y -= (colorButtonSelectedSize.height - colorButtonUnselectedSize.height)/2;
        buttonFrame.size      = colorButtonSelectedSize;
        
        button.frame = buttonFrame;
        
        button.layer.borderColor    = [UIColor lightGrayColor].CGColor;
        
        button.layer.borderWidth    = 3.0f;
        button.layer.cornerRadius   = 5;
        button.layer.masksToBounds  = YES;
    }
}

-(void) setColorButtonUnSelected:(UIButton*) button
{
    CGRect buttonFrame;
    buttonFrame = button.frame;
    
    if (buttonFrame.size.width == colorButtonSelectedSize.width)
    {
        buttonFrame.origin.x += (colorButtonSelectedSize.width  - colorButtonUnselectedSize.width)/2;
        buttonFrame.origin.y += (colorButtonSelectedSize.height - colorButtonUnselectedSize.height)/2;
        buttonFrame.size      = colorButtonUnselectedSize;
        
        button.frame = buttonFrame;
        
        [button.layer setBorderWidth:0];
        
    }
}


-(void) setPanelColor1:(UIColor *)panelColor1
{
    _panelColor1Button.backgroundColor = panelColor1;
}

-(void) setPanelColor2:(UIColor *)panelColor2
{
    _panelColor2Button.backgroundColor = panelColor2;
}

-(void) setPanelColor3:(UIColor *)panelColor3
{
    _panelColor3Button.backgroundColor = panelColor3;
}

-(void) setPanelColor4:(UIColor *)panelColor4
{
   _panelColor4Button.backgroundColor = panelColor4;
}

-(void) setPanelColor5:(UIColor *)panelColor5
{
    _panelColor5Button.backgroundColor = panelColor5;
}

@end
