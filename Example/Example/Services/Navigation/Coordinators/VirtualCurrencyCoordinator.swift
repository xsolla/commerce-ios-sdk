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

protocol VirtualCurrencyCoordinatorProtocol: Coordinator, Finishable
{
    var paymentRequestHandler: ((String, Bool, (() -> Void)?) -> Void)? { get set }
}

class VirtualCurrencyCoordinator: BaseCoordinator<VirtualCurrencyCoordinator.Dependencies,
                                                  VirtualCurrencyCoordinator.Params>,
                                  VirtualCurrencyCoordinatorProtocol
{
    var paymentRequestHandler: ((String, Bool, (() -> Void)?) -> Void)?

    private var virtualCurrencyList: VirtualCurrencyList?

    override func start()
    {
        showStartVC()
    }

    func showStartVC()
    {
        let dataSource = dependencies.datasourceFactory.createVirtualCurrencyListDatasource(params: .none)

        let viewController =
        dependencies.viewControllerFactory.createVirtualCurrencyVC(params: .init(dataSource: dataSource))

        let virtualCurrencyList =
        dependencies.modelFactory.createVirtualCurrencyList(params: .init(loadStateListener: viewController,
                                                                          dataSource: dataSource))

        virtualCurrencyList.orderPaymentHandler =
        { [weak self] createdOrder in

            self?.paymentRequestHandler?(createdOrder.paymentToken, createdOrder.isSandbox)
            {
                self?.virtualCurrencyList?.requestData()
            }
        }

        self.virtualCurrencyList = virtualCurrencyList

        virtualCurrencyList.requestData()

        pushViewController(viewController)
    }
}

extension VirtualCurrencyCoordinator
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
