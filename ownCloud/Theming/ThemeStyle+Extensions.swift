//
//  ThemeStyle+Extensions.swift
//  ownCloud
//
//  Created by Felix Schwarz on 26.10.18.
//  Copyright © 2018 ownCloud GmbH. All rights reserved.
//

/*
 * Copyright (C) 2018, ownCloud GmbH.
 *
 * This code is covered by the GNU Public License Version 3.
 *
 * For distribution utilizing Apple mechanisms please see https://owncloud.org/contribute/iOS-license-exception/
 * You should have received a copy of this license along with this program. If not, see <http://www.gnu.org/licenses/gpl-3.0.en.html>.
 *
 */

import Foundation
import ownCloudSDK

extension ThemeStyle {
	func themeStyleExtension(isDefault: Bool = false, isBranding: Bool = false) -> OCExtension {
		let features : [String:Any] = [
			ThemeStyleFeatureKeys.localizedName : self.localizedName,
			ThemeStyleFeatureKeys.isDefault	    : isDefault,
			ThemeStyleFeatureKeys.isBranding    : isBranding
		]

		return OCExtension(identifier: OCExtensionIdentifier(rawValue: self.identifier), type: .themeStyle, location: OCExtensionLocationIdentifier(rawValue: self.identifier), features: features, objectProvider: { (_, _, _) -> Any? in
			return self
		})
	}

	static var defaultStyle: ThemeStyle {
		let matchContext = OCExtensionContext(location: OCExtensionLocation(ofType: .themeStyle, identifier: nil),
						      requirements: [ThemeStyleFeatureKeys.isDefault : true], // Match default
						      preferences: [ThemeStyleFeatureKeys.isBranding : true]) // Prefer brandings (=> boosts score of brandings so it outmatches built-in styles)

		if let matches : [OCExtensionMatch] = try? OCExtensionManager.shared.provideExtensions(for: matchContext),
		   matches.count > 0,
		   let styleExtension = matches.first?.extension,
		   let defaultStyle = styleExtension.provideObject(for: matchContext) as? ThemeStyle {
			return defaultStyle
		}

		Log.error("Couldn't get defaultStyle")

		return ThemeStyle.ownCloudDark
	}

	static var preferredStyle : ThemeStyle {
		set {
			UserDefaults.standard.setValue(newValue.identifier, forKey: "preferred-theme-style")
		}

		get {
			var style : ThemeStyle?

			if let preferredThemeStyleIdentifier = UserDefaults.standard.string(forKey: "preferred-theme-style") {
				style = .forIdentifier(preferredThemeStyleIdentifier)
			}

			if style == nil {
				style = .defaultStyle
			}

			return style!
		}
	}

	static func forIdentifier(_ identifier: String) -> ThemeStyle? {
		let matchContext = OCExtensionContext(location: OCExtensionLocation(ofType: .themeStyle, identifier: OCExtensionLocationIdentifier(rawValue: identifier)), requirements: nil, preferences: nil)

		if let matches : [OCExtensionMatch] = try? OCExtensionManager.shared.provideExtensions(for: matchContext),
		   matches.count > 0,
		   let styleExtension = matches.first?.extension,
		   let style = styleExtension.provideObject(for: matchContext) as? ThemeStyle {
			return style
		}

		return nil
	}

	static var availableStyles : [ThemeStyle]? {
		let matchContext = OCExtensionContext(location: OCExtensionLocation(ofType: .themeStyle, identifier: nil), requirements: nil, preferences: nil)

		if let matches : [OCExtensionMatch] = try? OCExtensionManager.shared.provideExtensions(for: matchContext), matches.count > 0 {
			var styles : [ThemeStyle] = []

			for match in matches {
				if let style = match.extension.provideObject(for: matchContext) as? ThemeStyle {
					styles.append(style)
				}
			}

			return styles
		}

		return nil
	}

	static func registerDefaultStyles() {
		OCExtensionManager.shared.addExtension(ThemeStyle.ownCloudLight.themeStyleExtension())
		OCExtensionManager.shared.addExtension(ThemeStyle.ownCloudDark.themeStyleExtension(isDefault: true))
		OCExtensionManager.shared.addExtension(ThemeStyle.ownCloudClassic.themeStyleExtension())
	}
}

extension OCExtensionType {
	static let themeStyle: OCExtensionType  =  OCExtensionType("app.themeStyle")
}

struct ThemeStyleFeatureKeys {
	static let localizedName: String = "localizedName"
	static let isDefault: String = "isDefault"
	static let isBranding: String = "isBranding"
}
