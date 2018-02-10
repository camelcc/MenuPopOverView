MenuPopOverView
===============

`MenuPopOverView` been rewrite in swift. It looks like [UIMenuController](https://developer.apple.com/library/ios/documentation/iPhone/Reference/UIMenuController_Class/UIMenuController.html) but can popover from anyview you want.

## Install

Carthage:

`github "camelcc/MenuPopOverView"`

## Example

```swift
class ViewController: UIViewController {
    var menuPopOverView: MenuPopOverView? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapped(tap:))))
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        menuPopOverView?.dismiss(false)
    }

    @objc private func tapped(tap: UITapGestureRecognizer) {
        let tapLocation = tap.location(in: self.view)
        if menuPopOverView == nil {
            menuPopOverView = MenuPopOverView()
        }
        menuPopOverView?.delegate = self
        menuPopOverView?.present(at: CGRect(x: tapLocation.x, y: tapLocation.y, width: 0, height: 0),
                                in: self.view,
                                with: ["Test1", "TestAAAAAAA", "t", "example", "loooooooooooooooongbutton"])
    }
}

extension ViewController: MenuPopOverViewDelegate {
    func didSelect(view: MenuPopOverView, at index: Int) {
        print("didSelect at \(index)")
    }

    func didDismiss(view: MenuPopOverView) {
        print("didDismiss")
        menuPopOverView = nil
    }
}
```

![popover](./popOver.png)

### License
[WTFPL](http://www.wtfpl.net/txt/copying)

### Support me
[Buy me a coffee](https://paypal.me/camelcc)
