// Copyright 2021-present Xsolla (USA), Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at q
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing and permissions and

// swiftlint:disable multiple_closures_with_trailing_closure

import UIKit

protocol SideMenuVCProtocol: BaseViewController
{
    func set(contentVC: BaseViewController?)
    func hide(animated: Bool)
}

class SideMenuVC: BaseViewController, SideMenuVCProtocol
{
    var onMenuItem: ((Int) -> Void)?

    func set(contentVC: BaseViewController?)
    {
        if let controller = self.contentVC
        {
            controller.willMove(toParent: nil)
            controller.view.removeFromSuperview()
            controller.removeFromParent()
        }

        self.contentVC = contentVC
    }

    @IBOutlet private weak var dimmerView: UIView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var containerView: UIView!
    
    private var contentVC: BaseViewController?
    private var dismissOnSwipe: Bool = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        setupScrollView()
        setupDimmerView()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        guard let controller = contentVC else
        {
            dismiss(animated: false, completion: nil)
            return
        }

        if controller.parent == nil
        {
            addChild(controller)
            containerView.addSubview(controller.view)
            controller.view.pinToSuperview()
            controller.didMove(toParent: self)
        }
        
        show()
    }
    
    func setupScrollView()
    {
        scrollView.delegate = self
        scrollView.isHidden = true
    }
    
    func setupDimmerView()
    {
        dimmerView.addTapHandler { [weak self] in self?.hide() }
        dimmerView.isHidden = true
    }
    
    func updateDimmerView()
    {
        let contentOffset = scrollView.contentOffset.x
        let contentWidth = scrollView.bounds.width
            
        let fraction = 1 - (contentOffset / contentWidth)
        
        dimmerView.alpha = fraction
    }
    
    func dismissIfNeeded()
    {
        if (scrollView.bounds.width - scrollView.contentOffset.x) < 1
        {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    @IBAction private func onButton(_ sender: UIButton)
    {
        onMenuItem?(sender.tag)
    }
        
    func show(animated: Bool = true)
    {
        self.scrollView.contentOffset = CGPoint(x: self.scrollView.bounds.width, y: 0)
        scrollView.isHidden = false
        dimmerView.isHidden = false
        
        guard animated else
        {
            scrollView.contentOffset = CGPoint.zero
            dismissOnSwipe = true
            return
        }
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut)
        {
            self.scrollView.contentOffset = CGPoint.zero
        }
        completion:
        { _ in
            self.dismissOnSwipe = true
        }
    }
    
    func hide(animated: Bool = true)
    {
        dismissOnSwipe = false

        guard animated else
        {
            scrollView.contentOffset = CGPoint(x: self.scrollView.bounds.width, y: 0)
            self.dismiss(animated: false, completion: nil)
            return
        }
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut)
        {
            self.scrollView.contentOffset = CGPoint(x: self.scrollView.bounds.width, y: 0)
        }
        completion:
        { _ in
            self.dismiss(animated: false, completion: nil)
        }
    }
}

extension SideMenuVC: UIScrollViewDelegate
{
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        updateDimmerView()
        if dismissOnSwipe { dismissIfNeeded() }
    }
}
