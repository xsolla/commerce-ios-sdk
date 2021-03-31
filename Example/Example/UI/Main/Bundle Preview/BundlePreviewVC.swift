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

import UIKit
import SDWebImage

protocol BundlePreviewVCProtocol: BaseViewController
{
    var dismissRequest: ((BundlePreviewVCProtocol) -> Void)? { get set }
}

class BundlePreviewVC: BaseViewController, BundlePreviewVCProtocol
{
    var dataSource: BundlePreviewDataSource!
    var dismissRequest: ((BundlePreviewVCProtocol) -> Void)?
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dismissButton: UIButton!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var actionButton: Button!
    
    @IBOutlet private weak var bundleImageView: UIImageView!
    @IBOutlet private weak var bundleTitleLabel: UILabel!
    @IBOutlet private weak var bundleDescriptionLabel: UILabel!
    
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var discountedPriceLabel: UILabel!
    @IBOutlet private weak var priceCurrencyImage: UIImageView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        titleLabel.attributedText = L10n.BundlePreview.title
            .attributed(.heading1, color: .xsolla_white)
            .aligned(.center)
        
        setupBundleInfo()
        setupBundleContents()
        setupBundlePrice()
        setupActionButton()
        
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        logger.info { "Showing bundle preview: \(self.dataSource.bundleName.string)" }

    }
 
    private func setupTableView()
    {
        tableView.registerXib(for: BundleContentListCell.self)
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
    }
    
    private func setupBundleInfo()
    {
        switch dataSource.bundleImage
        {
            case .image(let image): bundleImageView.image = image
            case .url(let stringUrl): do
            {
                if let url = URL(string: stringUrl)
                {
                    bundleImageView.sd_setImage(with: url)
                }
                else
                {
                    bundleImageView.image = Asset.Images.imagePlaceholder.image
                }
            }
        }
        
        bundleTitleLabel.attributedText = dataSource.bundleName
        bundleTitleLabel.isHidden = bundleTitleLabel.attributedText == nil
        bundleDescriptionLabel.attributedText = dataSource.bundleDescription
        bundleDescriptionLabel.isHidden = bundleDescriptionLabel.attributedText == nil

    }
    
    private func setupBundleContents()
    {
        
    }
    
    private func setupBundlePrice()
    {
        priceLabel.attributedText = dataSource.bundlePrice
        discountedPriceLabel.attributedText = dataSource.bundleDiscountedPrice
        discountedPriceLabel.isHidden = discountedPriceLabel.attributedText == nil
        
        setupPriceCurrencyView(image: dataSource.bundlePriceCurrencyImage)
    }
    
    private func setupActionButton()
    {
        actionButton.setupAppearance(config: Button.largeContained)
    }
    
    func setupPriceCurrencyView(image: Image?)
    {
        guard let image = image else { priceCurrencyImage.isHidden = true; return }
        
        priceCurrencyImage.isHidden = false
        
        if case .image(let image) = image { priceCurrencyImage.image = image }
        
        switch image
        {
            case .image(let image): priceCurrencyImage.image = image
            case .url(let stringUrl): do
            {
                guard let url = URL(string: stringUrl) else
                {
                    priceCurrencyImage.image = nil
                    return
                }
                
                priceCurrencyImage.sd_setImage(with: url)
            }
        }
    }
    
    // MARK: - Action Handlers
    
    @IBAction private func onDismissButton(_ sender: UIButton)
    {
        dismissRequest?(self)
    }
    
    @IBAction private func onActionButton(_ sender: Button)
    {
        logger.debug { "Buy bundle action button pressed" }
        dismissRequest?(self)
    }
}
