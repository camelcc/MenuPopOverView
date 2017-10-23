MenuPopOverView
===============

`MenuPopOverView` is inspired from [PopoverView](https://github.com/cocoa-factory/PopoverView) but looks like a [UIMenuController](https://developer.apple.com/library/ios/documentation/iPhone/Reference/UIMenuController_Class/UIMenuController.html).  The origin requirement is to use `UIMenuController` everywhere which is unfortunate can't since it collided with other UIElements such as `UITextField`.

## Usage

`MenuPopOverView` is drop to use, include `MenuPopOverView.h` and `MenuPopOverView.h`.

To display popover:

```objective-c
CGRect yourViewFrameToPointTo = ...;
UIView *sourceView = ...;
MenuPopOverView *popOver = [[MenuPopOverView alloc] init];
popOver.delegate = ...; // your delegate
[popOver presentPopoverFromRect:yourViewFrameToPointTo inView:sourceView withStrings:@[@"Test1", @"Test2"]];
```

The delegation return which string been selected or if popover dismissed.

```objective-c
- (void)popoverView:(MenuPopOverView *)popoverView didSelectItemAtIndex:(NSInteger)index;
- (void)popoverViewDidDismiss:(MenuPopOverView *)popoverView;
```

![popover](./popOver.png)

### Contact

Camel Yang
- http://twitter.camel_young
- camel.young@gmail.com

### License
[WTFPL](http://www.wtfpl.net/txt/copying)
