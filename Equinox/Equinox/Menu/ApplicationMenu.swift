// Copyright (c) 2021 Dmitry Meduho
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
// distribute, sublicense, create a derivative work, and/or sell copies of the
// Software in any work that is designed, intended, or marketed for pedagogical or
// instructional purposes related to programming, coding, application development,
// or information technology.  Permission for such use, copying, modification,
// merger, publication, distribution, sublicensing, creation of derivative works,
// or sale is expressly withheld.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import AppKit
import EquinoxAssets

// MARK: - Protocols

protocol ApplicationMenuDelegate: AnyObject {
    func applicationMenuNew(_ sender: Any?)
}

// MARK: - Class

final class ApplicationMenu: NSMenu {
    override init(title: String) {
        super.init(title: title)
        setup()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    // MARK: - Setup
    
    private func setup() {
        items = [
            mainMenu,
            fileMenu,
            editMenu,
            windowMenu,
            helpMenu
        ]
    }
    
    // MARK: - Public
    
    weak var applicationDelegate: ApplicationMenuDelegate?
    
    // MARK: - Private
    
    private var mainMenu: MenuItem {
        let menu = MenuItem()
        menu.submenu = NSMenu(title: "MainMenu")
        menu.submenu?.items = [
            MenuItem(
                title: Localization.Menu.Main.about(param1: title),
                keyEquivalent: String(),
                keyModifier: .command,
                action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)),
                target: NSApplication.shared
            ),
            MenuItem.separator(),
            MenuItem(
                title: Localization.Menu.Main.preferences,
                keyEquivalent: ",",
                keyModifier: .command,
                action: nil,
                target: NSApplication.shared,
                isEnabled: false
            ),
            MenuItem.separator(),
            MenuItem(
                title: Localization.Menu.Main.hide(param1: title),
                keyEquivalent: "h",
                keyModifier: .command,
                action: #selector(NSApplication.hide(_:)),
                target: NSApplication.shared
            ),
            MenuItem(
                title: Localization.Menu.Main.hideOthers,
                keyEquivalent: "h",
                keyModifier: [.command, .option],
                action: #selector(NSApplication.hideOtherApplications),
                target: NSApplication.shared
            ),
            MenuItem(
                title: Localization.Menu.Main.showAll,
                keyEquivalent: String(),
                keyModifier: .command,
                action: #selector(NSApplication.unhideAllApplications),
                target: NSApplication.shared
            ),
            MenuItem.separator(),
            MenuItem(
                title: Localization.Menu.Main.quit(param1: title),
                keyEquivalent: "q",
                keyModifier: .command,
                action: #selector(NSApplication.shared.terminate(_:)),
                target: NSApplication.shared
            )
        ]
        return menu
    }
    
    private var fileMenu: MenuItem {
        let menu = MenuItem()
        menu.submenu = NSMenu(title: Localization.Menu.File.file)
        menu.submenu?.items = [
            MenuItem(
                title: Localization.Menu.File.new,
                keyEquivalent: "n",
                keyModifier: .command,
                action: #selector(ApplicationMenu.new(_:)),
                target: self
            )
        ]
        return menu
    }
    
    private var editMenu: MenuItem {
        let menu = MenuItem()
        menu.submenu = NSMenu(title: Localization.Menu.Edit.edit)
        menu.submenu?.items = [
            MenuItem(
                title: Localization.Menu.Edit.undo,
                keyEquivalent: "z",
                keyModifier: .command,
                action: #selector(UndoManager.undo)
            ),
            MenuItem(
                title: Localization.Menu.Edit.redo,
                keyEquivalent: "Z",
                keyModifier: .command,
                action: #selector(UndoManager.redo)
            ),
            MenuItem.separator(),
            MenuItem(
                title: Localization.Menu.Edit.cut,
                keyEquivalent: "x",
                keyModifier: .command,
                action: #selector(NSText.cut(_:))
            ),
            MenuItem(
                title: Localization.Menu.Edit.copy,
                keyEquivalent: "c",
                keyModifier: .command,
                action: #selector(NSText.copy(_:))
            ),
            MenuItem(
                title: Localization.Menu.Edit.paste,
                keyEquivalent: "v",
                keyModifier: .command,
                action: #selector(NSText.paste(_:))
            ),
            MenuItem.separator(),
            MenuItem(
                title: Localization.Menu.Edit.selectAll,
                action: #selector(NSText.selectAll(_:)),
                keyEquivalent: "a"
            ),
            MenuItem.separator(),
            MenuItem(
                title: Localization.Menu.Edit.delete,
                keyEquivalent: "⌫",
                keyModifier: [],
                action: #selector(NSApplication.deleteBackward(_:))
            )
        ]
        return menu
    }
    
    private var windowMenu: MenuItem {
        let menu = MenuItem()
        menu.submenu = NSMenu(title: Localization.Menu.Window.window)
        menu.submenu?.items = [
            MenuItem(
                title: Localization.Menu.Window.minimize,
                keyEquivalent: "m",
                keyModifier: .command,
                action: #selector(NSWindow.miniaturize(_:))
            ),
            MenuItem(
                title: Localization.Menu.Window.zoom,
                keyEquivalent: String(),
                keyModifier: .command,
                action: #selector(NSWindow.performZoom(_:))
            ),
            MenuItem.separator(),
            MenuItem(
                title: Localization.Menu.Window.showAll,
                keyEquivalent: "m",
                keyModifier: .command,
                action: #selector(NSApplication.arrangeInFront(_:))
            )
        ]
        return menu
    }
    
    private var helpMenu: MenuItem {
        let menu = MenuItem()
        menu.submenu = NSMenu(title: Localization.Menu.Help.help)
        helpMenuLinks.allCases.enumerated().forEach { helpMenuIndex, helpLink in
            let menuItem = MenuItem(
                title: helpLink.linkInfo.title,
                keyEquivalent: "",
                keyModifier: .command,
                action: #selector(openURL(_:)),
                target: self
            )
            menu.submenu?.items.append(menuItem)
            if helpMenuIndex == 2 {
                menu.submenu?.items.append(MenuItem.separator())
            }
        }
        return menu
    }
    
    private enum helpMenuLinks: CaseIterable {
        case githubProject
        case githubFAQ
        case githubIssue
        case equinoxWebsite
        case macAppStoreReview
        case productHunt
        var linkInfo: (title: String, url: URL?) {
            switch self {
            case .githubProject:
                return ("GitHub project", URL(string: "https://github.com/rlxone/Equinox"))
            case .githubFAQ:
                return ("Frequently Asked Questions", URL(string: "https://github.com/rlxone/Equinox#faq"))
            case .githubIssue:
                return ("Report an issue", URL(string: "https://github.com/rlxone/Equinox/issues"))
            case .equinoxWebsite:
                return ("Equinox website", URL(string: "https://equinoxmac.com"))
            case .macAppStoreReview:
                return ("Rate Equinox on the Mac App Store", URL(string: "https://apps.apple.com/us/app/equinox-create-wallpaper/id1591510203?action=write-review"))
            case .productHunt:
                return ("Equinox on Product Hunt", URL(string: "https://www.producthunt.com/products/equinox"))
            }
        }
    }
    
    @objc
    private func new(_ sender: Any?) {
        applicationDelegate?.applicationMenuNew(sender)
    }
    
    @objc func unwrapOpenURL(_ url: URL?) {
        guard let url = url else {
            return
        }
        NSWorkspace.shared.open(url)
    }
    
    @objc func openURL(_ sender: NSMenuItem) {
        switch sender.title {
        case "GitHub project":
            unwrapOpenURL(helpMenuLinks.githubProject.linkInfo.url)
        case "Frequently Asked Questions":
            unwrapOpenURL(helpMenuLinks.githubFAQ.linkInfo.url)
        case "Report an issue":
            unwrapOpenURL(helpMenuLinks.githubIssue.linkInfo.url)
        case "Equinox website":
            unwrapOpenURL(helpMenuLinks.equinoxWebsite.linkInfo.url)
        case "Rate Equinox on the Mac App Store":
            unwrapOpenURL(helpMenuLinks.macAppStoreReview.linkInfo.url)
        case "Equinox on Product Hunt":
            unwrapOpenURL(helpMenuLinks.productHunt.linkInfo.url)
        default:
            return
        }
    }
}
