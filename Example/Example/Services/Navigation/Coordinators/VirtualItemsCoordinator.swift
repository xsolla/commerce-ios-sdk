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

protocol VirtualItemsCoordinatorProtocol: Coordinator, Finishable
{
    var reloadRequestHandler: (() -> Void)? { get set }
    var paymentRequestHandler: ((String, Bool, (() -> Void)?) -> Void)? { get set }
}

class VirtualItemsCoordinator: BaseCoordinator<VirtualItemsCoordinator.Dependencies,
                                               VirtualItemsCoordinator.Params>,
                               VirtualItemsCoordinatorProtocol
{
    var reloadRequestHandler: (() -> Void)?
    var paymentRequestHandler: ((String, Bool, (() -> Void)?) -> Void)?

    private var virtualItemsList: VirtualItemsList?
    private var virtualItemsActionHandler: VirtualItemsActionHandler?

    override func start()
    {
        showStartVC()
    }

    func showStartVC()
    {
        let dataSource = dependencies.datasourceFactory.createVirtualItemsListDatasource(params: .none)

        let viewController =
        dependencies.viewControllerFactory.createVirtualItemsVC(params: .init(dataSource: dataSource))

        let virtualItemsList =
        dependencies.modelFactory.createVirtualItemsList(params: .init(loadStateListener: viewController,
                                                                          dataSource: dataSource))

        virtualItemsActionHandler =
        dependencies.modelFactory.createVirtualItemsActionHandler(params: .init(dataSource: dataSource,
                                                                                viewController: viewController,
                                                                                virtualItemsList: virtualItemsList,
                                                                                store: dependencies.store))
        self.virtualItemsList = virtualItemsList

        virtualItemsActionHandler?.reloadDataRequest =
        { [weak self] in

            self?.virtualItemsList?.requestData()
            self?.reloadRequestHandler?()
        }

        virtualItemsActionHandler?.orderPaymentHandler =
        { [weak self] createdOrder in

            self?.paymentRequestHandler?(createdOrder.paymentToken, createdOrder.isSandbox)
            {
                self?.virtualItemsList?.requestData()
            }
        }

        virtualItemsActionHandler?.bundlePreviewRequest =
        { [weak self] bundle, actionHandler in guard let self = self else { return }

            let bundleDataSource =
                self.dependencies.datasourceFactory.createBundlePreviewDataSource(params: .init(bundle: bundle))

            self.previewBundle(dataSource: bundleDataSource, actionHandler: actionHandler)
        }

        virtualItemsList.requestData()

        pushViewController(viewController)
    }

    func previewBundle(dataSource: BundlePreviewDataSource, actionHandler: BundlePreviewActionHandler?)
    {
        let viewController =
        dependencies.viewControllerFactory.createBundlePreviewVC(params: .init(dataSource: dataSource))

        viewController.actionHandler = actionHandler

        presentViewController(viewController, completion: nil)
    }
}

extension VirtualItemsCoordinator
{
    struct Dependencies
    {
        let coordinatorFactory: CoordinatorFactoryProtocol
        let viewControllerFactory: ViewControllerFactoryProtocol
        let datasourceFactory: DatasourceFactoryProtocol
        let modelFactory: ModelFactoryProtocol
        let store: StoreProtocol
    }

    typealias Params = EmptyParams
}
