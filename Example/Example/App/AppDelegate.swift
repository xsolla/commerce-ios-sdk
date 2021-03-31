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

@main
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    var coordinator: AppCoordinator?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        // INFO: [@r.mingazov] temp code - метод, который может понадобиться
        // paymentsKit.applicationDidFinishLaunchingWithOptions(launchOptions)
        setupRouting()
        
        return true
    }
    
    private func setupRouting()
    {
        let window = UIWindow()
        self.window = window

        let coordinator = AppCoordinator.build(for: window)
        self.coordinator = coordinator
        
        coordinator.start()
    }
}
