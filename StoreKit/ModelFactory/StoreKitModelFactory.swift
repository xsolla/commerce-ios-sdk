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

import Foundation

protocol ModelFactoryProtocol
{
    func getItemGroups(response: GetItemGroupsResponse) -> [StoreItemGroup]
    func getAllVirtualItems(response: GetAllVirtualItemsResponse) -> [StoreVirtualItemShort]
    func getVirtualItems(response: GetVirtualItemsResponse) -> [StoreVirtualItem]
    func getVirtualCurrency(response: GetVirtualCurrencyResponse) -> [StoreVirtualCurrency]
    func getVirtualCurrencyPackages(response: GetVirtualCurrencyPackagesResponse) -> [StoreCurrencyPackage]
    func getItemsOfGroup(response: GetItemsOfGroupResponse) -> [StoreVirtualItem]
    func getBundlesList(response: GetBundlesListResponse) -> [StoreBundle]
    func getBundle(response: GetBundleResponse) -> StoreBundle
    func getOrder(response: GetOrderResponse) -> StoreOrder
    func getStoreOrderPaymentInfo(response: CreateOrderResponse, isSandbox: Bool) -> StoreOrderPaymentInfo
    func getOrderId(response: PurchaseItemByVirtualCurrencyResponse) -> Int
    func getFreeOrderId(response: CreateFreeOrderResponse) -> Int
    func getRedeemedCouponItems(response: RedeemCouponResponse) -> [StoreRedeemedCouponItem]
    func getCouponRewards(response: GetCouponRewardsResponse) -> StoreCouponRewards
    func getPromocodeRewards(response: GetPromocodeRewardsResponse) -> StorePromocodeRewards
    func getPromocode(response: PromocodeResponse) -> StorePromocode
    func getStoreCart(response: GetCartByCartIdResponse) -> StoreCart
    func getStoreCart(response: GetCurrentUserCartResponse) -> StoreCart
    func getStoreCartWithWarnings(response: FillCartWithItemsResponse) -> StoreCartWithWarnings
    func getStoreCartWithWarnings(response: FillSpecificCartWithItemsResponse) -> StoreCartWithWarnings
    func getStoreGame(response: GameResponse) -> StoreGame
    func getStoreGames(response: GetGamesListResponse) -> [StoreGame]
    func getStoreGameKey(response: GameKeyResponse) -> StoreGameKey
    func getStoreGameKeys(response: [GameKeyResponse]) -> [StoreGameKey]
    func getStoreDRMs(response: DRMListResponse) -> [StoreDRM]
    func getStoreUserGamesList(response: UserGamesListResponse) -> StoreUserGamesList
}

class StoreKitModelFactory: ModelFactoryProtocol
{
    func getItemGroups(response: GetItemGroupsResponse) -> [StoreItemGroup]
    {
        response.groups.map(getStoreItemGroup)
    }

    func getAllVirtualItems(response: GetAllVirtualItemsResponse) -> [StoreVirtualItemShort]
    {
        response.items.map(getStoreVirtualItemShort)
    }

    func getVirtualItems(response: GetVirtualItemsResponse) -> [StoreVirtualItem]
    {
        response.items.map(getStoreVirtualItem)
    }

    func getVirtualCurrency(response: GetVirtualCurrencyResponse) -> [StoreVirtualCurrency]
    {
        response.items.map(getStoreVirtualCurrency)
    }

    func getVirtualCurrencyPackages(response: GetVirtualCurrencyPackagesResponse) -> [StoreCurrencyPackage]
    {
        response.items.map(getStoreCurrencyPackage)
    }

    func getItemsOfGroup(response: GetItemsOfGroupResponse) -> [StoreVirtualItem]
    {
        response.items.map(getStoreVirtualItem)
    }

    func getBundlesList(response: GetBundlesListResponse) -> [StoreBundle]
    {
        response.items.map(getStoreBundle)
    }

    func getBundle(response: GetBundleResponse) -> StoreBundle
    {
        let content: [StoreBundle.ContentItem] = response.content.map
        { item in

            let price = item.price.flatMap(getStoreItemPrice)
            let virtualPrices = item.virtualPrices.map(getStoreItemVirtualPrice)
            let attributes = item.attributes.map(getStoreItemAttribute)
            let groups = item.groups.map(getStoreItemGroupShort)
            let inventoryOptions = getStoreItemInventoryOptions(response: item.inventoryOptions)

            return StoreBundle.ContentItem(sku: item.sku,
                                           name: item.name,
                                           groups: groups,
                                           attributes: attributes,
                                           type: item.type,
                                           description: item.description,
                                           imageUrl: item.imageUrl,
                                           isFree: item.isFree,
                                           price: price,
                                           virtualPrices: virtualPrices,
                                           inventoryOptions: inventoryOptions,
                                           virtualItemType: item.virtualItemType,
                                           quantity: item.quantity)
        }

        return StoreBundle(sku: response.sku,
                           name: response.name,
                           groups: response.groups.map(getStoreItemGroupShort),
                           attributes: response.attributes.map { getStoreItemAttribute(response: $0) },
                           type: response.type,
                           description: response.description,
                           imageUrl: response.imageUrl,
                           isFree: response.isFree,
                           price: response.price.flatMap(getStoreItemPrice),
                           virtualPrices: response.virtualPrices.map(getStoreItemVirtualPrice),
                           bundleType: response.bundleType,
                           totalContentPrice: response.totalContentPrice.flatMap(getStoreItemPrice),
                           content: content,
                           promotions: response.promotions.map(getStoreItemPromotion),
                           limits: response.limits.flatMap(getStoreItemLimits))
    }

    func getOrder(response: GetOrderResponse) -> StoreOrder
    {
        let content: StoreOrder.Content? = response.content.flatMap
        { content in

            let virtualPrice = content.virtualPrice != nil
            ? getStoreItemVirtualPrice(response: content.virtualPrice!)
            : nil

            let items = content.items?.map
            {
                StoreOrder.Content.Item(sku: $0.sku,
                                        quantity: $0.quantity,
                                        isFree: $0.isFree,
                                        price: $0.price.flatMap(getStoreItemPrice))
            }

            return StoreOrder.Content(price: content.price.flatMap(getStoreItemPrice),
                                      virtualPrice: virtualPrice,
                                      isFree: content.isFree,
                                      items: items)
        }

        return StoreOrder(orderId: response.orderId, status: response.status, content: content)
    }

    func getStoreOrderPaymentInfo(response: CreateOrderResponse, isSandbox: Bool) -> StoreOrderPaymentInfo
    {
        StoreOrderPaymentInfo(orderId: response.orderId,
                              paymentToken: response.token,
                              isSandbox: isSandbox)
    }

    func getOrderId(response: PurchaseItemByVirtualCurrencyResponse) -> Int
    {
        response.orderId
    }
    
    func getFreeOrderId(response: CreateFreeOrderResponse) -> Int
    {
        response.orderId
    }
    
    func getRedeemedCouponItems(response: RedeemCouponResponse) -> [StoreRedeemedCouponItem]
    {
        response.items.map(getStoreCouponRedeemedItem)
    }

    func getPromocode(response: PromocodeResponse) -> StorePromocode
    {
        let items: [StorePromocode.Item] = response.items.map
        { item in

            return StorePromocode.Item(sku: item.sku,
                                       groups: item.groups?.map(getStoreItemGroupShort),
                                       name: item.name,
                                       type: item.type,
                                       description: item.description,
                                       imageUrl: item.imageUrl,
                                       quantity: item.quantity,
                                       isFree: item.isFree)
        }

        return StorePromocode(cartId: response.cartId,
                              price: response.price.flatMap(getStoreItemPrice),
                              isFree: response.isFree,
                              items: items)
    }

    func getCouponRewards(response: GetCouponRewardsResponse) -> StoreCouponRewards
    {
        let rewards = response.bonus.map(getReward)

        return StoreCouponRewards(rewards: rewards, isSelectable: response.isSelectable)
    }

    func getPromocodeRewards(response: GetPromocodeRewardsResponse) -> StorePromocodeRewards
    {
        let rewards = response.bonus.map(getReward)
        let discountedItems = response.discountedItems?.map(getDiscountedItem) ?? []
        let discount = response.discount.flatMap { StorePromocodeRewards.Discount(percent: $0.percent) }

        return StorePromocodeRewards(rewards: rewards,
                                     discount: discount,
                                     isSelectable: response.isSelectable,
                                     discountedItems: discountedItems)
    }

    func getStoreCart(response: GetCartByCartIdResponse) -> StoreCart
    {
        let items = response.items.map
        { item in
            StoreCartItem(sku: item.sku,
                          groups: item.groups.map(getStoreItemGroupShort),
                          name: item.name,
                          attributes: item.attributes.map(getStoreItemAttribute),
                          type: item.type,
                          description: item.description,
                          imageUrl: item.imageUrl,
                          quantity: item.quantity,
                          price: getStoreItemPrice(response: item.price),
                          isFree: item.isFree,
                          isBonus: item.isBonus)
        }

        return StoreCart(cartId: response.cartId,
                         price: response.price.flatMap(getStoreItemPrice),
                         isFree: response.isFree,
                         items: items)
    }

    func getStoreCart(response: GetCurrentUserCartResponse) -> StoreCart
    {
        let items = response.items.map
        { item in
            StoreCartItem(sku: item.sku,
                          groups: item.groups.map(getStoreItemGroupShort),
                          name: item.name,
                          attributes: item.attributes.map(getStoreItemAttribute),
                          type: item.type,
                          description: item.description,
                          imageUrl: item.imageUrl,
                          quantity: item.quantity,
                          price: getStoreItemPrice(response: item.price),
                          isFree: item.isFree,
                          isBonus: item.isBonus)
        }

        return StoreCart(cartId: response.cartId,
                         price: response.price.flatMap(getStoreItemPrice),
                         isFree: response.isFree,
                         items: items)
    }

    func getStoreCartWithWarnings(response: FillCartWithItemsResponse) -> StoreCartWithWarnings
    {
        let items = response.items.map
        { item in
            StoreCartItem(sku: item.sku,
                          groups: item.groups.map(getStoreItemGroupShort),
                          name: item.name,
                          attributes: item.attributes.map(getStoreItemAttribute),
                          type: item.type,
                          description: item.description,
                          imageUrl: item.imageUrl,
                          quantity: item.quantity,
                          price: getStoreItemPrice(response: item.price),
                          isFree: item.isFree,
                          isBonus: item.isBonus)
        }

        let warnings = response.warnings.map
        {
            StoreCartWarning(sku: $0.sku,
                             errorCode: $0.errorCode,
                             quantity: $0.quantity,
                             errorMessage: $0.errorMessage)
        }

        return StoreCartWithWarnings(cartId: response.cartId,
                                     price: response.price.flatMap(getStoreItemPrice),
                                     isFree: response.isFree,
                                     items: items,
                                     warnings: warnings)
    }

    func getStoreCartWithWarnings(response: FillSpecificCartWithItemsResponse) -> StoreCartWithWarnings
    {
        let items = response.items.map
        { item in
            StoreCartItem(sku: item.sku,
                          groups: item.groups.map(getStoreItemGroupShort),
                          name: item.name,
                          attributes: item.attributes.map(getStoreItemAttribute),
                          type: item.type,
                          description: item.description,
                          imageUrl: item.imageUrl,
                          quantity: item.quantity,
                          price: getStoreItemPrice(response: item.price),
                          isFree: item.isFree,
                          isBonus: item.isBonus)
        }

        let warnings = response.warnings.map
        {
            StoreCartWarning(sku: $0.sku,
                             errorCode: $0.errorCode,
                             quantity: $0.quantity,
                             errorMessage: $0.errorMessage)
        }

        return StoreCartWithWarnings(cartId: response.cartId,
                                     price: response.price.flatMap(getStoreItemPrice),
                                     isFree: response.isFree,
                                     items: items,
                                     warnings: warnings)
    }

    func getStoreGame(response: GameResponse) -> StoreGame
    {
        StoreGame(sku: response.sku,
                  name: response.name,
                  groups: response.groups.map(getStoreItemGroupShort),
                  type: response.type,
                  unitType: response.unitType,
                  gameDescription: response.gameDescription,
                  imageURL: response.imageURL,
                  attributes: response.attributes.map(getStoreItemAttribute),
                  unitItems: response.unitItems.map(getStoreGameUnitItem))
    }

    func getStoreGames(response: GetGamesListResponse) -> [StoreGame]
    {
        response.items.map(getStoreGame)
    }

    func getStoreGameKey(response: GameKeyResponse) -> StoreGameKey
    {
        StoreGameKey(sku: response.sku,
                     name: response.name,
                     groups: response.groups.map(getStoreItemGroupShort),
                     type: response.type,
                     gameKeyDescription: response.gameKeyDescription,
                     imageURL: response.imageURL,
                     attributes: response.attributes.map(getStoreItemAttribute),
                     isFree: response.isFree,
                     price: getStoreItemPrice(response: response.price),
                     virtualPrices: response.virtualPrices.map(getStoreItemVirtualPrice),
                     drmSku: response.drmSku,
                     drmName: response.drmName,
                     isPreOrder: response.isPreOrder,
                     hasKeys: response.hasKeys,
                     releaseDate: response.releaseDate)
    }

    func getStoreGameKeys(response: [GameKeyResponse]) -> [StoreGameKey]
    {
        response.map(getStoreGameKey)
    }

    func getStoreDRMs(response: DRMListResponse) -> [StoreDRM]
    {
        response.drm.map(getStoreDRM)
    }

    func getStoreUserGamesList(response: UserGamesListResponse) -> StoreUserGamesList
    {
        StoreUserGamesList(hasMore: response.hasMore,
                           totalItemsCount: response.totalItemsCount,
                           items: response.items.map(getStoreUserGame))
    }
}

private extension StoreKitModelFactory
{

    func getStoreItemPrice(response: PriceResponse) -> StoreItemPrice
    {
        StoreItemPrice(amount: response.amount,
                       amountWithoutDiscount: response.amountWithoutDiscount,
                       currency: response.currency)
    }

    func getStoreItemGroup(response: GetItemGroupsResponse.Group) -> StoreItemGroup
    {
        return StoreItemGroup(externalId: response.externalId,
                              name: response.name,
                              description: response.description,
                              imageUrl: response.imageUrl,
                              order: response.order,
                              level: response.level,
                              children: response.children?.map(getStoreItemGroup),
                              parentExternalId: response.parentExternalId)
    }

    func getStoreItemGroupShort(response: GroupResponse) -> StoreItemGroupShort
    {
        StoreItemGroupShort(externalId: response.externalId, name: response.name)
    }

    func getStoreVirtualItemShort(response: GetAllVirtualItemsResponse.Item) -> StoreVirtualItemShort
    {
        let groups = response.groups.map(getStoreItemGroupShort)

        return StoreVirtualItemShort(sku: response.sku,
                                     name: response.name,
                                     groups: groups,
                                     description: response.description)
    }

    func getStoreVirtualItem(response: GetVirtualItemsResponse.Item) -> StoreVirtualItem
    {
        StoreVirtualItem(sku: response.sku,
                         name: response.name,
                         groups: response.groups.map(getStoreItemGroupShort),
                         attributes: response.attributes.map(getStoreItemAttribute),
                         type: response.type,
                         description: response.description,
                         imageUrl: response.imageUrl,
                         isFree: response.isFree,
                         price: response.price.flatMap(getStoreItemPrice),
                         virtualPrices: response.virtualPrices.map(getStoreItemVirtualPrice),
                         inventoryOptions: getStoreItemInventoryOptions(response: response.inventoryOptions),
                         virtualItemType: response.virtualItemType,
                         promotions: response.promotions.map(getStoreItemPromotion),
                         limits: response.limits.flatMap(getStoreItemLimits))
    }

    func getStoreVirtualItem(response: GetItemsOfGroupResponse.Item) -> StoreVirtualItem
    {
        StoreVirtualItem(sku: response.sku,
                         name: response.name,
                         groups: response.groups.map(getStoreItemGroupShort),
                         attributes: response.attributes.map(getStoreItemAttribute),
                         type: response.type,
                         description: response.description,
                         imageUrl: response.imageUrl,
                         isFree: response.isFree,
                         price: response.price.flatMap(getStoreItemPrice),
                         virtualPrices: response.virtualPrices.map(getStoreItemVirtualPrice),
                         inventoryOptions: getStoreItemInventoryOptions(response: response.inventoryOptions),
                         virtualItemType: response.virtualItemType,
                         promotions: response.promotions.map(getStoreItemPromotion),
                         limits: response.limits.flatMap(getStoreItemLimits))
    }

    func getStoreVirtualCurrency(response: GetVirtualCurrencyResponse.Item) -> StoreVirtualCurrency
    {
        StoreVirtualCurrency(sku: response.sku,
                             name: response.name,
                             groups: response.groups.map(getStoreItemGroupShort),
                             attributes: response.attributes.map(getStoreItemAttribute),
                             type: response.type,
                             description: response.description,
                             imageUrl: response.imageUrl,
                             isFree: response.isFree,
                             price: response.price.flatMap(getStoreItemPrice),
                             virtualPrices: response.virtualPrices.map(getStoreItemVirtualPrice),
                             inventoryOptions: getStoreItemInventoryOptions(response: response.inventoryOptions),
                             promotions: response.promotions.map(getStoreItemPromotion),
                             limits: response.limits.flatMap(getStoreItemLimits))
    }

    func getStoreCurrencyPackage(response: GetVirtualCurrencyPackagesResponse.Item) -> StoreCurrencyPackage
    {
        let groups = response.groups.map(getStoreItemGroupShort)
        let virtualPrices = response.virtualPrices.map(getStoreItemVirtualPrice)
        let attributes = response.attributes.map(getStoreItemAttribute)

        let content: [StoreCurrencyPackage.ContentItem] = response.content.map
        {
            let inventoryOptions = getStoreItemInventoryOptions(response: $0.inventoryOptions)

            return StoreCurrencyPackage.ContentItem(sku: $0.sku,
                                                    name: $0.name,
                                                    type: $0.type,
                                                    description: $0.description,
                                                    imageUrl: $0.imageUrl,
                                                    quantity: $0.quantity,
                                                    inventoryOptions: inventoryOptions)
        }

        return StoreCurrencyPackage(sku: response.sku,
                                    name: response.name,
                                    groups: groups,
                                    attributes: attributes,
                                    type: response.type,
                                    bundleType: response.bundleType,
                                    description: response.description,
                                    imageUrl: response.imageUrl,
                                    isFree: response.isFree,
                                    price: response.price.flatMap(getStoreItemPrice),
                                    virtualPrices: virtualPrices,
                                    content: content,
                                    promotions: response.promotions.map(getStoreItemPromotion))
    }

    func getStoreBundle(response: GetBundlesListResponse.Item) -> StoreBundle
    {
        let content: [StoreBundle.ContentItem] = response.content.map
        { item in

            let price = item.price.flatMap(getStoreItemPrice)
            let virtualPrices = item.virtualPrices.map(getStoreItemVirtualPrice)
            let attributes = item.attributes.map(getStoreItemAttribute)
            let groups = item.groups.map(getStoreItemGroupShort)
            let inventoryOptions = getStoreItemInventoryOptions(response: item.inventoryOptions)

            return StoreBundle.ContentItem(sku: item.sku,
                                           name: item.name,
                                           groups: groups,
                                           attributes: attributes,
                                           type: item.type,
                                           description: item.description,
                                           imageUrl: item.imageUrl,
                                           isFree: item.isFree,
                                           price: price,
                                           virtualPrices: virtualPrices,
                                           inventoryOptions: inventoryOptions,
                                           virtualItemType: item.virtualItemType,
                                           quantity: item.quantity)
        }

        let groups = response.groups.map(getStoreItemGroupShort)
        let attributes = response.attributes.map(getStoreItemAttribute)
        let virtualPrices = response.virtualPrices.map(getStoreItemVirtualPrice)

        return StoreBundle(sku: response.sku,
                           name: response.name,
                           groups: groups,
                           attributes: attributes,
                           type: response.type,
                           description: response.description,
                           imageUrl: response.imageUrl,
                           isFree: response.isFree,
                           price: response.price.flatMap(getStoreItemPrice),
                           virtualPrices: virtualPrices,
                           bundleType: response.bundleType,
                           totalContentPrice: response.totalContentPrice.flatMap(getStoreItemPrice),
                           content: content,
                           promotions: response.promotions.map(getStoreItemPromotion),
                           limits: response.limits.flatMap(getStoreItemLimits))
    }

    func getStoreItemVirtualPrice(response: VirtualPriceResponse) -> StoreItemVirtualPrice
    {
        return StoreItemVirtualPrice(amount: response.amount,
                                     amountWithoutDiscount: response.amountWithoutDiscount,
                                     sku: response.sku,
                                     isDefault: response.isDefault,
                                     imageUrl: response.imageUrl,
                                     name: response.name,
                                     type: response.type,
                                     description: response.description)
    }

    func getStoreItemAttribute(response: AttributeResponse) -> StoreItemAttribute
    {
        let values = response.values.map { StoreItemAttribute.Value(externalId: $0.externalId, value: $0.value) }

        return StoreItemAttribute(externalId: response.externalId,
                                  name: response.name,
                                  values: values)
    }
    
    func getStoreItemPromotion(response: StoreItemPromotionResponse) -> StoreItemPromotion
    {
        let discount = StoreItemPromotion.Discount(percent: response.discount.percent, value: response.discount.value)
        let bonus = response.bonus.map { StoreItemPromotion.Bonus(sku: $0.sku, quantity: $0.quantity ) }
        
        var limits: StoreItemPromotion.Limits? = nil
        if response.limits != nil
        {
            let available = response.limits!.perUser.available
            let total = response.limits!.perUser.total
            let limitsPerUser = StoreItemPromotion.LimitsPerUser(available: available, total: total)
            limits = StoreItemPromotion.Limits(perUser: limitsPerUser)
        }

        return StoreItemPromotion(name: response.name,
                                  dateStart: response.dateStart,
                                  dateEnd: response.dateEnd,
                                  discount: discount,
                                  bonus: bonus,
                                  limits: limits)
    }

    func getStoreItemInventoryOptions(response: InventoryOptionsResponse) -> StoreItemInventoryOptions
    {
        let consumable: StoreItemInventoryOptions.Consumable? = response.consumable.flatMap
        {
            StoreItemInventoryOptions.Consumable(usagesCount: $0.usagesCount)
        }

        let expirationPeriod: StoreItemInventoryOptions.ExpirationPeriod? = response.expirationPeriod.flatMap
        {
            StoreItemInventoryOptions.ExpirationPeriod(type: $0.type, value: $0.value)
        }

        return StoreItemInventoryOptions(consumable: consumable, expirationPeriod: expirationPeriod)
    }

    func getStoreCouponRedeemedItem(response: RedeemCouponResponse.Item) -> StoreRedeemedCouponItem
    {
        let groups = response.groups?.map(getStoreItemGroupShort)

        return StoreRedeemedCouponItem(sku: response.sku,
                                       groups: groups,
                                       name: response.name,
                                       type: response.type,
                                       description: response.description,
                                       imageUrl: response.imageUrl,
                                       quantity: response.quantity,
                                       isFree: response.isFree)
    }

    func getReward(response: BonusResponse) -> StoreReward
    {
        let unitItems = response.item.unitItems?.map
        { unitItem in
            StoreRewardItem.UnitItem(sku: unitItem.sku,
                                     type: unitItem.type,
                                     name: unitItem.name,
                                     drmName: unitItem.drmName,
                                     drmSKU: unitItem.drmSku)
        }

        let rewardItem = StoreRewardItem(sku: response.item.sku,
                                         name: response.item.name,
                                         type: response.item.type,
                                         description: response.item.description,
                                         imageUrl: response.item.imageUrl,
                                         unitItems: unitItems)

        return StoreReward(item: rewardItem, quantity: response.quantity)
    }

    func getDiscountedItem(response: GetPromocodeRewardsResponse.DiscountedItem) -> StorePromocodeRewards.DiscountedItem
    {
        let discount = StorePromocodeRewards.Discount(percent: response.discount.percent)
        return StorePromocodeRewards.DiscountedItem(sku: response.sku, discount: discount)
    }

    func getStoreGameUnitItem(response: GameUnitItemResponse) -> StoreGameUnitItem
    {
        StoreGameUnitItem(sku: response.sku,
                          type: response.type,
                          isFree: response.isFree,
                          price: getStoreItemPrice(response: response.price),
                          virtualPrices: response.virtualPrices.map(getStoreItemVirtualPrice),
                          drmSku: response.drmSku,
                          drmName: response.drmName,
                          isPreOrder: response.isPreOrder,
                          hasKeys: response.hasKeys,
                          releaseDate: response.releaseDate)
    }

    func getStoreDRM(response: DRMResponse) -> StoreDRM
    {
        StoreDRM(sku: response.sku,
                 name: response.name,
                 image: response.image,
                 link: response.link,
                 redeemInstructionLink: response.redeemInstructionLink,
                 drmID: response.drmID)
    }

    func getStoreUserGame(response: UserGameResponse) -> StoreUserGame
    {
        StoreUserGame(name: response.name,
                      itemDescription: response.itemDescription,
                      imageURL: response.imageURL,
                      projectID: response.projectID,
                      gameSku: response.gameSku,
                      drm: response.drm,
                      isPreOrder: response.isPreOrder)
    }
    
    func getStoreItemLimits(response: StoreItemLimitsResponse) -> StoreItemLimits
    {
        let available = response.perUser.available
        let total = response.perUser.total
        let recurrentSchedule = response.perUser.recurrentSchedule.map {
            StoreItemLimits.LimitsPerUser.RecurrentSchedule(intervalType: $0.intervalType,
                                                            resetNextDate: $0.resetNextDate)
        }
        let perUser = StoreItemLimits.LimitsPerUser(available: available,
                                                    total: total,
                                                    recurrentSchedule: recurrentSchedule)

        return StoreItemLimits(perUser: perUser)
    }
}
