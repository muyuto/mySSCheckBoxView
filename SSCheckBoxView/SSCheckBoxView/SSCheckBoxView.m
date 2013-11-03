
/*
 Copyright 2011 Ahmet Ardal
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

//
//  SSCheckBoxView.m
//  SSCheckBoxView
//
//  Created by Ahmet Ardal on 12/6/11.
//  Copyright 2011 SpinningSphere Labs. All rights reserved.
//

#import "SSCheckBoxView.h"

static const CGFloat kHeight = 24.0f;

@interface SSCheckBoxView(Private)
- (UIImage *) checkBoxImageForStyle:(SSCheckBoxViewStyle)s
                            checked:(BOOL)isChecked;
- (CGRect) imageViewFrameForCheckBoxImage:(UIImage *)img;
- (void) updateCheckBoxImage;
@end

@implementation SSCheckBoxView

@synthesize style, checked, enabled;
@synthesize stateChangedBlock;
@synthesize tDict;

- (id) initWithFrame:(CGRect)frame
               style:(SSCheckBoxViewStyle)aStyle
             checked:(BOOL)aChecked
{
    frame.size.height = kHeight;
    if (!(self = [super initWithFrame:frame])) {
        return self;
    }

    stateChangedSelector = nil;
    self.stateChangedBlock = nil;
    delegate = nil;
    style = aStyle;
    checked = aChecked;
    self.enabled = YES;

    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor clearColor];

    textLabel = [self checkBoxTxtLabelForStyle:style];

    UIImage *img = [self checkBoxImageForStyle:style checked:checked];
    CGRect imageViewFrame = [self imageViewFrameForCheckBoxImage:img];
    UIImageView *iv = [[UIImageView alloc] initWithFrame:imageViewFrame];
    iv.image = img;
    [self addSubview:iv];
    checkBoxImageView = iv;

    return self;
}

- (void) dealloc
{
    self.stateChangedBlock = nil;
    checkBoxImageView = nil;
    textLabel = nil;
    tDict = nil;
}

- (void) setEnabled:(BOOL)isEnabled
{
    textLabel.enabled = isEnabled;
    enabled = isEnabled;
    checkBoxImageView.alpha = isEnabled ? 1.0f: 0.6f;
}

- (BOOL) enabled
{
    return enabled;
}

- (void) setText:(NSString *)text
{
    [textLabel setText:text];
}
- (void) setLabelText:(NSDictionary*)tdict{
    if (tdict) {
        tDict = tdict;
    }
    if (checked) {
        [textLabel setText:[tDict objectForKey:@"state on"]];
    }else
        [textLabel setText:[tDict objectForKey:@"state off"]];
}

- (void) setChecked:(BOOL)isChecked
{
    checked = isChecked;
    [self updateCheckBoxImage];
}

- (void) setStateChangedTarget:(id<NSObject>)target
                      selector:(SEL)selector
{
    delegate = target;
    stateChangedSelector = selector;
}


#pragma mark -
#pragma mark Touch-related Methods

- (void) touchesBegan:(NSSet *)touches
            withEvent:(UIEvent *)event
{
    if (!enabled) {
        return;
    }

    self.alpha = 0.8f;
    [super touchesBegan:touches withEvent:event];
}

- (void) touchesCancelled:(NSSet *)touches
                withEvent:(UIEvent *)event
{
    if (!enabled) {
        return;
    }

    self.alpha = 1.0f;
    [super touchesCancelled:touches withEvent:event];
}

- (void) touchesEnded:(NSSet *)touches
            withEvent:(UIEvent *)event
{
    if (!enabled) {
        return;
    }

    // restore alpha
    self.alpha = 1.0f;

    // check touch up inside
    if ([self superview]) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:[self superview]];
        CGRect validTouchArea = CGRectMake((self.frame.origin.x - 5),
                                           (self.frame.origin.y - 10),
                                           (self.frame.size.width + 5),
                                           (self.frame.size.height + 10));
        if (CGRectContainsPoint(validTouchArea, point)) {
            checked = !checked;
            [self updateCheckBoxImage];
            if (delegate && stateChangedSelector) {
                [delegate performSelector:stateChangedSelector withObject:self];
            }
            else if (stateChangedBlock) {
                stateChangedBlock(self);
            }
        }
    }

    [super touchesEnded:touches withEvent:event];
}

- (BOOL) canBecomeFirstResponder
{
    return YES;
}


#pragma mark -
#pragma mark Private Methods
- (UILabel *) checkBoxTxtLabelForStyle:(SSCheckBoxViewStyle)s{
    CGRect labelFrame = CGRectMake(25, 0.0f, self.frame.size.width - 25, kHeight); //未灵活调整，视实际情况修正
    UILabel *l = [[UILabel alloc] initWithFrame:labelFrame];
    switch (s) {
        case kSSCheckBoxViewStyleApp1:
            l.textAlignment = kTextAlignmentLeft;
            l.backgroundColor = [UIColor clearColor];
            l.font = [UIFont fontWithName:@"Arial" size:12];
            l.textColor = [UIColor whiteColor];
            l.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            l.shadowColor = [UIColor whiteColor];
            l.shadowOffset = CGSizeMake(0, 0);
            break;
            
        default:
            l.textAlignment = kTextAlignmentLeft;
            l.backgroundColor = [UIColor clearColor];
            l.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
            l.textColor = RGBA(0x2E, 0x2E, 0x2E, 1);
            l.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            l.shadowColor = [UIColor whiteColor];
            l.shadowOffset = CGSizeMake(0, 1);
            break;
    }
    [self addSubview:l];
    return l;
}

- (UIImage *) checkBoxImageForStyle:(SSCheckBoxViewStyle)s
                            checked:(BOOL)isChecked
{
    NSString *suffix = isChecked ? @"on" : @"off";
    NSString *imageName = @"";
    switch (s) {
        case kSSCheckBoxViewStyleBox:
            imageName = @"cb_box_";
            break;
        case kSSCheckBoxViewStyleDark:
            imageName = @"cb_dark_";
            break;
        case kSSCheckBoxViewStyleGlossy:
            imageName = @"cb_glossy_";
            break;
        case kSSCheckBoxViewStyleGreen:
            imageName = @"cb_green_";
            break;
        case kSSCheckBoxViewStyleMono:
            imageName = @"cb_mono_";
            break;
        case kSSCheckBoxViewStyleApp1:
            imageName = @"cb_app1_";
            break;
        default:
            return nil;
    }
    imageName = [NSString stringWithFormat:@"%@%@", imageName, suffix];
    return [UIImage imageNamed:imageName];
}

- (CGRect) imageViewFrameForCheckBoxImage:(UIImage *)img
{
    CGFloat y = floorf((kHeight - img.size.height) / 2.0f);
    return CGRectMake(5.0f, y, img.size.width, img.size.height);
}

- (void) updateCheckBoxImage
{
    checkBoxImageView.image = [self checkBoxImageForStyle:style
                                                  checked:checked];
    [self setLabelText:nil];
}

@end
