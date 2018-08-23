# MasseRouterManager

[![CI Status](https://img.shields.io/travis/Brayden/RouterManager.svg?style=flat)](https://travis-ci.org/Brayden/RouterManager)
[![Version](https://img.shields.io/cocoapods/v/RouterManager.svg?style=flat)](https://cocoapods.org/pods/RouterManager)
[![License](https://img.shields.io/cocoapods/l/RouterManager.svg?style=flat)](https://cocoapods.org/pods/RouterManager)
[![Platform](https://img.shields.io/cocoapods/p/RouterManager.svg?style=flat)](https://cocoapods.org/pods/RouterManager)

## Overview

MasseRouterManager is a quick to implement library that handles in-app routing from sources such as deep links. 
Quickly add supported routes, and inherit protocol method to get routing into your application. This library supports the ability
to allow your individual view controllers to contain the logic on whether it should be allowed to be displayed based on the
current state of the application, or if additional custom logic is required. This feature makes this library the perfect option
for applications who need to create `guards`  to allow some view controllers to be locked based on a variety of options such
as the users logged in state, their access rights, etc.

## Requirements

Currently this library only supports Swift applications that utilize Storyboards. In the near future we will be adding additional
functionality that allows you to route to controllers that are programatically defined and scoped.

## Installation

### CocoaPods
MasseRouterManager is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'MasseRouterManager'
```

## Usage

Easily add routing and deep linking functionality to your application in a matter of minutes.

**1. Register a URL Scheme in your Info.plist file**
<img src="https://image.ibb.co/iNFwdK/Screen_Shot_2018_08_22_at_11_46_48_PM.png" width="410" />

**2. Import RouterManager into your AppDelegate**

```swift
import RouterManager
```

**3. Setup supported routes in the AppDelegate file**

In order to keep your code clean and easily maintainable we highly encourage breaking this out into its
own method, however, still requiring you to call it from your `application:didFinishLaunchingWithOptions` method
in your AppDelegate.

```swift
func setupRoutes() {
    let routerManager = RouterManager.self
    
    // Push deep-linked view onto a navigation stack
    let pushRouterLogic = RouterLogic(selectTab: false, pushTabIndex: 1, presentation: .push)
    
    // Modally present a deep-linked view from a view controller
    let modalRouterLogic = RouterLogic(selectTab: false, pushTabIndex: 0, presentation: .modal)
    
    // scheme://login will trigger the view with the following identifier from storyboard file
    let routeLogin = Route(link: "/login", routerLink: RouterLink(identifier: "LoginNavigationController", storyboard: "Login"), routerLogic: modalRouterLogic)
    
    // Add our route object to be trackable
    routerManager.shared.addRoute(route: routeLogin)
}
```

<em>RouterLogic
    `selectTab` - Corresponding deep link will select a tab from the tab bar controller before performing its actions
    `pushTabIndex` - Indicates which tab from the tab bar controller will be selected
    `presentation` - Has three options of presentation, "stay", "push", and "modal"
</em>

<em>RouterLink
    `identifier` - Identifier of the view controller as found in Storyboard
    `storyboard` - Name of storyboard file in the main application Bundle
</em>

<em>Route
    `link` - Deep-link URL match to execute this logic
    `routerLink` - RouterLink object
    `routerLogic` - RouterLogic object
</em>

**4. Implement RouterProtocol in View Controllers**

Each view controller that has a route mapped to it must expressly inherit the `RouterProtocol` ideally from an extension of their 
controllers code as the example below exemplifies. Within the protocols required function `canActivate:link:params` you have
the opportunity to check your application and user states to determine if the controller can be deep-linked to. The below example
shows a use case if your application wanted to return `true` or `false` based on a users logged in status if the controller should
be displayed via the deep-link.

```swift
extension NotificationListViewController: RouterProtocol {
    func canActivate(link: String, params: [String : Any]) -> Bool {
        if (userIsLoggedIn) {
            // Deep-link will occur
            return true
        }

        // Prevent deep-link from happening
        return false
    }
}
```

**5. Understanding Guards and tracking previous deep-link URL**

The ability to add controller based logic to determine whether a deep link can show helps in a couple of ways. First, being able
to keep code very confined within its context rather than lumping all the logic into a completion block in your AppDelegate.
Secondly, getting to perform logic that may expressly be tightly related to that views state which may change based on the
applications state.

When the `RouterProtocol` method `canActivate:link:params` returns `false`, it most likely means the controller can't
handle it based on the state of the application at this time. Within this method you can instead kick off your own custom logic or
for this example lets say the state of the application is actually a logged out user - so we can't deep link to the profile. When a
deep link is made into the application the RouterManager will store it in an accessible property for us to remember, even if the
controller responded with false. So once we login to the application we can have the option to execute that deep-link again to
go to the profile page.

```swift
// If previous deep link exists, execute it
if let previousDeeplink = RouterManager.shared.previousDeeplink {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        RouterManager.shared.triggerRoute(link: previousDeeplink)
        RouterManager.shared.previousDeeplink = nil
    }
}
```

This snippet simply executes the stored previous deep link after a small delay (enough to let a page transition happen) and then sets
the `previousDeeplink` property to nil to acknowledge the deeplink has been successfully completed and handled.


## Author

Brayden Wilmoth - brayden.wilmoth@shopmasse.com

## License

MasseRouterManager is available under the MIT license. See the LICENSE file for more info.
