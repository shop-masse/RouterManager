//
//  RouterManager.swift
//  masse
//
//  Created by Brayden Wilmoth on 8/6/18.
//  Copyright © 2018 Masse Inc. All rights reserved.
//

import Foundation
import UIKit

protocol RouterProtocol {
    func canActivate(link: String, params: [String: Any]) -> Bool
}

enum RouterPresentation: Int {
    case stay
    case push
    case modal
}

struct RouterLink {
    var identifier: String?
    var storyboard: String?
}

struct RouterLogic {
    var selectTab: Bool?
    var pushTabIndex: Int?
    var presentation: RouterPresentation?
}

struct Route {
    var link: String?
    var routerLink: RouterLink?
    var routerLogic: RouterLogic?
}

public class RouterManager {
    /// Shared instance of the RouterManager singleton
    static let shared = RouterManager()
    
    /// Routes available for deep-linking within the application
    var routes: [Route] = []
    
    /// Stores the latest deep-link URL for future engagement
    var previousDeeplink: URL?
    
    
    
    /// Add a Route object to the list of supported deep-link routes your application requires.
    /// Route objects allow you to add router links, paths to where it should lead, as well as
    /// logic rules on how to present the desired page.
    ///
    /// - parameter route: The Route object that informs us of the designtated view controller path
    func addRoute(route: Route) {
        routes.append(route)
    }
    
    /// Based on the provided link URL object, begin the search of stored Route objects to see
    /// if a match exists. When no match exists an error will be logged out into the console. Also,
    /// the `previousDeepLink` will be stored in case the application needs to access it at a later
    /// time if the canActivate returns false for a given controller.
    ///
    /// - parameter link: The URL object provided as a deep-link from the application
    func triggerRoute(link: URL) {
        previousDeeplink = link
        
        var matchDiscovered = false
        for route in routes {
            if let match = isRouteMatch(link: link, route: route) {
                
                if (match.match) {
                    matchDiscovered = true
                    
                    if (match.canActivate) {
                        // View controller has been activated
                    } else {
                        print("RouterManager: Match successfully found, but could not activate. If you believe this was a mistake please verify the controller implements the ```RouterProtocol```")
                    }
                    
                    // Stop loop execution after match was found
                    break
                }
            }
        }
        
        if (!matchDiscovered) {
            print("RouterManager: No deep-link URL match was found, please verify you have added it with the ```addRoute(route: Route)``` method in your AppDelegate.")
        }
    }
    
    /// Check and compare to see if the deep-link URL object is considered a match with the provided
    /// Route object by doing multiple checks. The first check is to compare the count of pathComponents
    /// in each URL. If there is a match, the process continues by going through each parameter to determine
    /// if each component string matches, or if a variable in the URL is detected we map it to a params
    /// object and continue our comparison operation until we've reached the end of the pathComponents list(s).
    ///
    /// - parameter link: The URL object provided as a deep-link from the application
    /// - parameter route: The Route object that informs us of the designtated view controller path
    ///
    /// - returns: A tuple of two `Bool` objects stating if there was a match found and if so, its ability to activate it
    func isRouteMatch(link: URL, route: Route) -> (match: Bool, canActivate: Bool)? {
        let urlWithoutScheme = removeScheme(url: link)
        
        if let routeURL = URL(string: "\(route.link!)") {
            if routeURL.pathComponents.count == urlWithoutScheme.pathComponents.count {
                
                var params: [String: Any] = [:]
                
                for (c1, c2) in zip(routeURL.pathComponents, urlWithoutScheme.pathComponents) {
                    if (c1.starts(with: ":")) {
                        let key = c1.replacingOccurrences(of: ":", with: "")
                        params[key] = c2
                        
                        continue
                    }
                    
                    if (c1 != c2) {
                        return (false, false)
                    }
                }
                
                let canActivate = checkCanActivate(route: route, params: params)
                return (true, canActivate!)
            }
        }
        
        return (false, false)
    }
    
    /// Retrieves access through the UIStoryboard identified from the `Route` object provided.
    /// Utilizing the storyboard access to the UIViewController also identified from the `Route` object
    /// will see if the controller adheres to the `RouterProtocol` which allows it to respond with
    /// a response that informs us if this view controller is accessible given custom logic of the current
    /// state of the application.
    ///
    /// NOTE: Crashes wlil occur if there is no valid UIStoryboard and UIViewController identifier pair existing.
    ///
    /// - parameter route: The Route object that informs us of the designtated view controller path
    /// - parameter params: The parameters provided from the deep-link URL
    ///
    /// - returns: The `Bool` object stating if the controller can be activated
    func checkCanActivate(route: Route, params: [String: Any]) -> Bool? {
        if let routerLink = route.routerLink {
            let storyboard = UIStoryboard(name: (routerLink.storyboard)!, bundle: Bundle.main)
            if let controller = storyboard.instantiateViewController(withIdentifier: (routerLink.identifier)!) as? RouterProtocol {
                let canActivate = controller.canActivate(link: route.link!, params: params)
                presentController(route: route, controller: controller as! UIViewController)
                
                return canActivate
            }
        }
        
        return false
    }
    
    /// When `checkCanActivate` returns a true, noting that the view controller is in a state to support
    /// its presentation (e.g. user is logged in), then find the most appropriate way to present the
    /// view controller based on the supplied logic rules from the `Route` object. Find the key window,
    /// determine the navigation structure it represents (UITabBarController, UINavigationController, etc)
    /// and find the best way to present it on screen.
    ///
    /// - parameter route: The Route object that informs us of the designtated view controller path
    /// - parameter controller: A UIViewController object that will be presented
    func presentController(route: Route, controller: UIViewController) {
        // Check if the tab bar controller is available, and expected behavior
        if ((UIApplication.shared.keyWindow?.rootViewController?.isKind(of: UITabBarController.self))!) {
            let tbc = UIApplication.shared.keyWindow?.rootViewController as! UITabBarController
            
            if ((route.routerLogic?.selectTab)!) {
                tbc.selectedIndex = (route.routerLogic?.pushTabIndex)!
                let firstTabNVC = tbc.viewControllers![(route.routerLogic?.pushTabIndex)!] as? UINavigationController
                
                if (route.routerLogic?.presentation == .push) {
                    firstTabNVC?.pushViewController(controller, animated: true)
                } else if (route.routerLogic?.presentation == .modal) {
                    firstTabNVC?.present(controller, animated: true, completion: nil)
                } else if (route.routerLogic?.presentation == .stay) {
                    // Do nothing, tab has been switched and that is sufficient
                }
            } else {
                let nvc = tbc.viewControllers![tbc.selectedIndex] as? UINavigationController
                
                if (route.routerLogic?.presentation == .push) {
                    nvc?.pushViewController(controller, animated: true)
                } else if (route.routerLogic?.presentation == .modal) {
                    nvc?.present(controller, animated: true, completion: nil)
                }
            }
        } else {
            UIApplication.shared.keyWindow?.rootViewController?.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension RouterManager {
    /// Removes the scheme out of the provided URL and returns the modified URL object.
    ///
    /// - parameter url: The URL object
    ///
    /// - returns: The `URL` object without the scheme
    func removeScheme(url: URL) -> URL {
        var routeLink: URL?
        let routeLinkString = url.absoluteString
        
        if (url.scheme != nil) {
            routeLink = URL(string: routeLinkString.replacingOccurrences(of: "\(url.scheme!):/", with: ""))
        } else {
            routeLink = url
        }
        
        return routeLink!
    }
}
