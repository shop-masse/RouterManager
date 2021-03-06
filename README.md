<p align="center"><img src="https://image.ibb.co/hQrjHe/Masse_Router_Manager.png" width="500"/>

</p>


<p align="center">
<a href="https://travis-ci.org/Brayden/RouterManager"><img src="https://img.shields.io/travis/Brayden/RouterManager.svg?style=flat" alt="CI Status" /></a>
<a href="https://cocoapods.org/pods/RouterManager"><img src="https://img.shields.io/cocoapods/v/RouterManager.svg?style=flat" alt="Version" /></a>
<a href="https://cocoapods.org/pods/RouterManager"><img src="https://img.shields.io/cocoapods/l/RouterManager.svg?style=flat" alt="License" /></a>
<a href="https://cocoapods.org/pods/RouterManager"><img src="https://img.shields.io/cocoapods/p/RouterManager.svg?style=flat" alt="Platform" /></a>
</p>


## Overview

MasseRouterManager is a quick to implement library that handles in-app routing from sources such as deep links. 
Quickly add supported routes, and inherit protocol method to get routing into your application. This library supports the ability
to allow your individual view controllers to contain the logic on whether it should be allowed to be displayed based on the
current state of the application, or if additional custom logic is required. This feature makes this library the perfect option
for applications who need to create `guards`  to allow some view controllers to be locked based on a variety of options such
as the users logged in state, their access rights, etc.

<br />

## Requirements

Currently this library only supports Swift applications that utilize Storyboards. In the near future we will be adding additional
functionality that allows you to route to controllers that are programatically defined and scoped.

<br />

## Installation

### CocoaPods
MasseRouterManager is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'MasseRouterManager'
```

<br />

## Usage

Easily add routing and deep linking functionality to your application in a matter of minutes.

**1. Register a URL Scheme in your Info.plist file**

<img src="https://image.ibb.co/iNFwdK/Screen_Shot_2018_08_22_at_11_46_48_PM.png" width="410" />

 <br />
 
**2. Import RouterManager into your AppDelegate**

```swift
import RouterManager
```

 <br />
 
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

<strong>RouterLogic</strong> <br />
    `selectTab` - Corresponding deep link will select a tab from the tab bar controller before performing its actions <br />
    `pushTabIndex` - Indicates which tab from the tab bar controller will be selected <br />
    `presentation` - Has three options of presentation, "stay", "push", and "modal" <br />

 <br />
 
<strong>RouterLink</strong> <br />
    `identifier` - Identifier of the view controller as found in Storyboard <br />
    `storyboard` - Name of storyboard file in the main application Bundle <br />

 <br />
 
<strong>Route</strong> <br />
    `link` - Deep-link URL match to execute this logic <br />
    `routerLink` - RouterLink object <br />
    `routerLogic` - RouterLogic object <br />

 <br />
 
**4. Implement RouterProtocol in View Controllers**

Each view controller that has a route mapped to it must expressly inherit the `RouterProtocol` ideally from an extension of their 
controllers code as the example below exemplifies. Within the protocols required function `canActivate:link:params` you have
the opportunity to check your application and user states to determine if the controller can be deep-linked to. The below example
shows a use case if your application wanted to return `true` or `false` based on a users logged in status if the controller should
be displayed via the deep-link.

```swift
extension MyViewController: RouterProtocol {
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

 <br /> <br />
 
 ## Passing Deep-Link Parameters to Controller
 
 By default MasseRouterManager automatically handles the logistics behind passing route parameters through to your view
 controller for you to have full access of. Let's take a quick look at how to setup a parameter in the route definition and then
 how to access that parameter from the controller `canActivate:link:params` method via the `RouterProtocol`.
 
 ### Defining Param Routes
 
 ```swift
 // Push deep-linked view onto a navigation stack
 let pushRouterLogic = RouterLogic(selectTab: true, pushTabIndex: 4, presentation: .push)
 
 let routeProfile = Route(link: "/profile/:id", routerLink: RouterLink(identifier: "ProfileSummaryViewController", storyboard: "Profile"), routerLogic: pushRouterLogic)
 ```
 
 This example above we setup a route for deep-linking to profiles and all we have to do is annotate a parameter by prefacing it with a colon,
 so this route has one single parameter of name "id" now.
 
 ### Accessing Route Params
 
 ```swift
 extension ProfileSummaryViewController: RouterProtocol {
    func canActivate(link: String, params: [String : Any]) -> Bool {
        if let profileID = params["id"] as? String {
            self.profileID = Int(profileID)
            return true
        }
 
        return false
    }
 }
 ```
 
 The RouterManager automatically grabs the parameters from the deep-link and provides them as a dictionary object to your
 controller. For safety, try utilizing the parameters through an ```if let``` to be certain the value actually exists before using
 it.
 
 <br /> <br />
 
 ## Understanding Guards and Tracking Previous Deep-Link URL

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

<br /> <br />

## Author

Brayden Wilmoth - brayden.wilmoth@shopmasse.com

<br /> <br />

## License

MasseRouterManager is available under the MIT license. See the LICENSE file for more info.
