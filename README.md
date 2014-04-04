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

The MIT License (MIT)

Copyright (c) 2014 Camel Yang

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
