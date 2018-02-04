//
//  ViewController.swift
//  Demo
//
//  Created by camel_yang on 1/30/18.
//  Copyright © 2018 camelcc. All rights reserved.
//

import UIKit
import MenuPopOverView

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

