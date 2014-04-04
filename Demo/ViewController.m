//
//  ViewController.m
//  MenuPopOverView
//
//  Created by Camel Yang on 4/4/14.
//  Copyright (c) 2014 camelcc. All rights reserved.
//

#import "ViewController.h"

#import "MenuPopOverView.h"

@interface ViewController () <MenuPopOverViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [self.view addGestureRecognizer:tap];
}

- (void)tapped:(UITapGestureRecognizer *)tap
{
    CGPoint point = [tap locationInView:self.view];
    MenuPopOverView *popOver = [[MenuPopOverView alloc] init];
    popOver.delegate = self;
    [popOver presentPopoverFromRect:CGRectMake(point.x, point.y, 0, 0) inView:self.view withStrings:@[@"Test1", @"TestAAAAAAA", @"t", @"example", @"loooooooooooooooongbutton"]];
}

- (void)popoverView:(MenuPopOverView *)popoverView didSelectItemAtIndex:(NSInteger)index {
    NSLog(@"select at %ld", (long)index);
}

- (void)popoverViewDidDismiss:(MenuPopOverView *)popoverView {
    NSLog(@"popOver dismissed.");
}

@end
