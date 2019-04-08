//
//  Routes.swift
//  SwiftFlowGitHubBrowser
//
//  Created by Benji Encz on 1/5/16.
//  Copyright © 2016 Benji Encz. All rights reserved.
//

import ReSwiftRouter
import SafariServices


let loginRoute:RouteElementIdentifier            = "Login"
let oAuthRoute:RouteElementIdentifier            = "OAuth"
let mainViewRoute:RouteElementIdentifier         = "Main"
let bookmarkRoute:RouteElementIdentifier         = "BookMark"
let repositoryDetailRoute:RouteElementIdentifier = "RepositoryDetail"

let storyboard                                   = UIStoryboard(name: "Main", bundle: nil)

let loginViewControllerIdentifier                = "LoginViewController"
let mainViewControllerIdentifier                 = "MainViewController"
let repositoryDetailControllerIdentifier         = "RepositoryDetailViewController"
let bookmarkControllerIdentifier                 = "BookmarkViewController"


// ------------------------------------------------------------------------------------------------
class RootRoutable:Routable
{
	let window:UIWindow
	
	
	init(window:UIWindow)
	{
		self.window = window
	}
	
	
	func setToLoginViewController() -> Routable
	{
		self.window.rootViewController = storyboard.instantiateViewController(withIdentifier: loginViewControllerIdentifier)
		return LoginViewRoutable(self.window.rootViewController!)
	}
	
	
	func setToMainViewController() -> Routable
	{
		self.window.rootViewController = storyboard.instantiateViewController(withIdentifier: mainViewControllerIdentifier)
		return MainViewRoutable(self.window.rootViewController!)
	}
	
	
	func changeRouteSegment( _ from:RouteElementIdentifier, to:RouteElementIdentifier, animated:Bool, completionHandler:@escaping RoutingCompletionHandler) -> Routable
	{
		if to == loginRoute
		{
			completionHandler()
			return self.setToLoginViewController()
		}
		else if to == mainViewRoute
		{
			completionHandler()
			return self.setToMainViewController()
		}
		else
		{
			fatalError("Route not supported!")
		}
	}
	
	
	func pushRouteSegment( _ routeElementIdentifier:RouteElementIdentifier, animated:Bool, completionHandler:@escaping RoutingCompletionHandler) -> Routable
	{
		if routeElementIdentifier == loginRoute
		{
			completionHandler()
			return self.setToLoginViewController()
		}
		else if routeElementIdentifier == mainViewRoute
		{
			completionHandler()
			return self.setToMainViewController()
		}
		else
		{
			fatalError("Route not supported!")
		}
	}
	
	
	func popRouteSegment( _ routeElementIdentifier:RouteElementIdentifier, animated:Bool, completionHandler:@escaping RoutingCompletionHandler)
	{
		// TODO: this should technically never be called -> bug in router
		completionHandler()
	}
	
}


// ------------------------------------------------------------------------------------------------
class LoginViewRoutable:Routable
{
	let viewController:UIViewController
	
	
	init(_ viewController:UIViewController)
	{
		self.viewController = viewController
	}
	
	
	func pushRouteSegment( _ routeElementIdentifier:RouteElementIdentifier, animated:Bool, completionHandler:@escaping RoutingCompletionHandler) -> Routable
	{
		if routeElementIdentifier == oAuthRoute
		{
			if let url = store.state.authenticationState.oAuthURL
			{
				let safariViewController = SFSafariViewController(url: url)
				self.viewController.present(safariViewController, animated: true, completion: completionHandler)
				return OAuthRoutable()
			}
		}
		
		fatalError("Router could not proceed.")
	}
	
	
	func popRouteSegment( _ routeElementIdentifier:RouteElementIdentifier, animated:Bool, completionHandler:@escaping RoutingCompletionHandler)
	{
		if routeElementIdentifier == oAuthRoute
		{
			self.viewController.dismiss(animated: true, completion: completionHandler)
		}
	}
	
}


// ------------------------------------------------------------------------------------------------
class MainViewRoutable:Routable
{
	let viewController:UIViewController
	
	
	init(_ viewController:UIViewController)
	{
		self.viewController = viewController
	}
	
	
	func pushRouteSegment( _ routeElementIdentifier:RouteElementIdentifier, animated:Bool, completionHandler:@escaping RoutingCompletionHandler) -> Routable
	{
		if routeElementIdentifier == repositoryDetailRoute
		{
			let detailViewController = storyboard.instantiateViewController(withIdentifier: repositoryDetailControllerIdentifier)
			(self.viewController as! UINavigationController).pushViewController(
					detailViewController,
					animated: true,
					completion: completionHandler
			)
			
			return RepositoryDetailRoutable()
			
		}
		else if routeElementIdentifier == bookmarkRoute
		{
			let bookmarkViewController = storyboard.instantiateViewController(withIdentifier: bookmarkControllerIdentifier)
			(self.viewController as! UINavigationController).pushViewController(
					bookmarkViewController,
					animated: true,
					completion: completionHandler
			)
			
			return BookmarkRoutable()
		}
		
		fatalError("Cannot handle this route change!")
	}
	
	
	func changeRouteSegment( _ from:RouteElementIdentifier, to:RouteElementIdentifier, animated:Bool, completionHandler:@escaping RoutingCompletionHandler) -> Routable
	{
		if from == bookmarkRoute && to == repositoryDetailRoute
		{
			(self.viewController as! UINavigationController).popViewController(true)
			{
				let repositoryDetailViewController = storyboard.instantiateViewController(withIdentifier: repositoryDetailControllerIdentifier)
				(self.viewController as! UINavigationController).pushViewController(
						repositoryDetailViewController,
						animated: true,
						completion: completionHandler
				)
			}
			
			return BookmarkRoutable()
		}
		
		// We can run into the following fatal error when back button on repository detail &
		// bookmark button on the main view controller are pressed very quickly subsequently.
		// This happens because the manual route update after the back button tap on the repository
		// detail view hasn't happened yet.
		// We could work around this with more hacks, but it wouldn't be useful to this example code.
		// A discussion/brainstorm for better ways of intercepting back button is going on here:
		// https://github.com/ReSwift/ReSwift-Router/issues/17
		fatalError("Cannot handle this route change!")
	}
	
	
	func popRouteSegment( _ routeElementIdentifier:RouteElementIdentifier, animated:Bool, completionHandler:@escaping RoutingCompletionHandler)
	{
		// no-op, since this is called when VC is already popped.
		completionHandler()
	}
}


// ------------------------------------------------------------------------------------------------
class RepositoryDetailRoutable:Routable
{
}


class BookmarkRoutable:Routable
{
}


class OAuthRoutable:Routable
{
}
