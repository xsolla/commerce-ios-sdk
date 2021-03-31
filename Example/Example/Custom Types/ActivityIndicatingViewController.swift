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
// swiftlint:disable line_length

import UIKit

class ActivityIndicatingViewController: UIViewController
{
    var animated: Bool = true
    
    let dimmerView = UIView(frame: .zero)
    let activityIndicator = UIActivityIndicatorView(frame: .zero)
    let gradientView = RadialGradientView(frame: .zero)
    
    init()
    {
        super.init(nibName: nil, bundle: nil)
        logger.debug(.initialization, domain: .example) { String(describing: Self.self) }
    }
    
    deinit
    {
        let deinitingType = String(describing: type(of: self))
        logger.debug(.deinitialization, domain: .example) { deinitingType }
    }
    
    required init?(coder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        setupDimmerView()
        setupRadialGradientView()
        setupActivityIndicator()
        
        setupConstraints()
        
        view.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        show(animated: self.animated)
    }
    
    // MARK: - Setup
    
    private func setupDimmerView()
    {
        view.addSubview(dimmerView)
        dimmerView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
    }
    
    private func setupActivityIndicator()
    {
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupRadialGradientView()
    {
        view.addSubview(gradientView)
        gradientView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints()
    {
        dimmerView.pinToSuperview()
        
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        gradientView.centerXAnchor.constraint(equalTo: activityIndicator.centerXAnchor).isActive = true
        gradientView.centerYAnchor.constraint(equalTo: activityIndicator.centerYAnchor).isActive = true
        gradientView.widthAnchor.constraint(equalTo: activityIndicator.widthAnchor, multiplier: 20).isActive = true
        gradientView.heightAnchor.constraint(equalTo: activityIndicator.heightAnchor, multiplier: 20).isActive = true
    }
    
    // MARK: - Show / Hide / Dismiss
    
    private func show(animated: Bool = true)
    {
        activityIndicator.startAnimating()
        
        guard animated else
        {
            view.alpha = 1
            return
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut)
        {
            self.view.alpha = 1
        }
    }
    
    func hide(animated: Bool = true)
    {
        guard animated else
        {
            view.alpha = 0
            dismissOrRemoveFromParent()
            return
        }

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut)
        {
            self.view.alpha = 0
        }
        completion:
        { _ in
            self.dismissOrRemoveFromParent()
        }

    }
    
    private func dismissOrRemoveFromParent()
    {
        guard parent != nil else
        {
            dismiss(animated: false, completion: nil)
            return
        }
        
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}

extension ActivityIndicatingViewController
{
    enum EmbeddingMode
    {
        case inside
        case over
    }
    
    func presentEmbedded<T: EmbeddableControllerContainerProtocol>(in viewController: T,
                                                                   embeddingMode: EmbeddingMode = .over,
                                                                   animated: Bool = true)
    {
        Self.presentEmbedded(activityVC: self, in: viewController, embeddingMode: embeddingMode, animated: animated)
    }

    @discardableResult
    static func presentEmbedded<T: EmbeddableControllerContainerProtocol>(in viewController: T,
                                                                          embeddingMode: EmbeddingMode = .over,
                                                                          animated: Bool = true) -> ActivityIndicatingViewController
    {
        let activityVC = ActivityIndicatingViewController()
        
        presentEmbedded(activityVC: activityVC, in: viewController, embeddingMode: embeddingMode, animated: animated)
        
        return activityVC
    }
    
    static func presentEmbedded<T: EmbeddableControllerContainerProtocol>(activityVC: ActivityIndicatingViewController,
                                                                          in viewController: T,
                                                                          embeddingMode: EmbeddingMode = .over,
                                                                          animated: Bool = true)
    {
        activityVC.animated = animated
        
        let containerView: UIView
        let mode: EmbeddingMode
        
        if let view = viewController.getContaiterViewForEmbeddableViewController()
        {
            containerView = view
            mode = (view == viewController.view) ? .inside : embeddingMode
        }
        else
        {
            containerView = viewController.view
            mode = .inside
        }
        
        viewController.addChild(activityVC)
        
        switch mode
        {
            case .inside: do
            {
                containerView.addSubview(activityVC.view)
                activityVC.view.pinToSuperview()
            }
            
            case .over: do
            {
                guard let superview = containerView.superview else
                {
                    fatalError("Container view must have a superview in .over mode")
                }
                
                superview.addSubview(activityVC.view)
                activityVC.view.translatesAutoresizingMaskIntoConstraints = false
                activityVC.view.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
                activityVC.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
                activityVC.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
                activityVC.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
            }
        }
        
        activityVC.didMove(toParent: viewController)
    }
}
