//
//  MenuPopOverView.h
//  SearchBar
//
//  Created by Camel Yang on 4/1/14.
//  Copyright (c) 2014 camelcc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MenuPopOverView;

@protocol MenuPopOverViewDelegate <NSObject>
@optional
- (void)popoverView:(MenuPopOverView *)popoverView didSelectItemAtIndex:(NSInteger)index;
- (void)popoverViewDidDismiss:(MenuPopOverView *)popoverView;

@end

@interface MenuPopOverView : UIView

@property (nonatomic, assign) UIColor *popOverBackgroundColor;
@property (nonatomic, assign) UIColor *popOverHighlightColor;
@property (nonatomic, assign) UIColor *popOverDividerColor;
@property (nonatomic, assign) UIColor *popOverTextColor;

@property (weak, nonatomic) id<MenuPopOverViewDelegate> delegate;

- (void)presentPopoverFromRect:(CGRect)rect inView:(UIView *)view withStrings:(NSArray *)stringArray;

@end
