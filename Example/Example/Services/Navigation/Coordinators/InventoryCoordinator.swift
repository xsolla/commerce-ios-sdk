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

protocol InventoryCoordinatorProtocol: Coordinator, Finishable
{
    var reloadRequestHandler: (() -> Void)? { get set }
    var paymentRequestHandler: ((String, Bool, (() -> Void)?) -> Void)? { get set }
}

class InventoryCoordinator: BaseCoordinator<InventoryCoordinator.Dependencies,
                                            InventoryCoordinator.Params>,
                            InventoryCoordinatorProtocol
{
    var reloadRequestHandler: (() -> Void)?
    var paymentRequestHandler: ((String, Bool, (() -> Void)?) -> Void)?

    private var inventoryList: InventoryList?

    override func start()
    {
        showStartVC()
    }

    func showStartVC()
    {
        let dataSource = dependencies.datasourceFactory.createInventoryListDatasource(params: .none)

        let params = InventoryVCFactoryParams(dataSource: dataSource)
        let viewController = dependencies.viewControllerFactory.createInventoryVC(params: params)

        let inventoryList =
        dependencies.modelFactory.createInventoryList(params: .init(loadStateListener: viewController,
                                                                    dataSource: dataSource))

        inventoryList.orderPaymentHandler =
        { [weak self] createdOrder in

            self?.paymentRequestHandler?(createdOrder.paymentToken, createdOrder.isSandbox)
            {
                self?.inventoryList?.requestData()
            }
        }

        viewController.refreshRequestHandler =
        { [weak self] in

            self?.inventoryList?.requestData()
            self?.reloadRequestHandler?()
        }

        self.inventoryList = inventoryList

        inventoryList.requestData()

        pushViewController(viewController)
    }
}

extension InventoryCoordinator
{
    struct Dependencies
    {
        let coordinatorFactory: CoordinatorFactoryProtocol
        let viewControllerFactory: ViewControllerFactoryProtocol
        let datasourceFactory: DatasourceFactoryProtocol
        let modelFactory: ModelFactoryProtocol
    }

    struct Params
    {
        let xsollaSDK: XsollaSDKProtocol
    }
}
