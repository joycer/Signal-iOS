//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

import UIKit
import PromiseKit
import Contacts

@objc
public class OnboardingPermissionsViewController: OnboardingBaseViewController {

    override public func loadView() {
        view = UIView()
        view.addSubview(primaryView)
        primaryView.autoPinEdgesToSuperviewEdges()

        view.backgroundColor = Theme.backgroundColor

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("NAVIGATION_ITEM_SKIP_BUTTON", comment: "A button to skip a view."),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(skipWasPressed))

        let titleLabel = self.titleLabel(text: NSLocalizedString("ONBOARDING_PERMISSIONS_TITLE", comment: "Title of the 'onboarding permissions' view."))
        titleLabel.accessibilityIdentifier = "onboarding.permissions." + "titleLabel"

        let explanationLabel = self.explanationLabel(explanationText: NSLocalizedString("ONBOARDING_PERMISSIONS_EXPLANATION",
                                                                                  comment: "Explanation in the 'onboarding permissions' view."))
        explanationLabel.accessibilityIdentifier = "onboarding.permissions." + "explanationLabel"

        let giveAccessButton = self.primaryButton(title: NSLocalizedString("ONBOARDING_PERMISSIONS_ENABLE_PERMISSIONS_BUTTON",
                                                                    comment: "Label for the 'give access' button in the 'onboarding permissions' view."),
                                           selector: #selector(giveAccessPressed))
        giveAccessButton.accessibilityIdentifier = "onboarding.permissions." + "giveAccessButton"
        let primaryButtonView = OnboardingBaseViewController.horizontallyWrap(primaryButton: giveAccessButton)

        let notNowButton = self.linkButton(title: NSLocalizedString("ONBOARDING_PERMISSIONS_NOT_NOW_BUTTON",
                                                                    comment: "Label for the 'not now' button in the 'onboarding permissions' view."),
                                           selector: #selector(notNowPressed))
        notNowButton.accessibilityIdentifier = "onboarding.permissions." + "notNowButton"

        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            UIView.spacer(withHeight: 20),
            explanationLabel,
            UIView.vStretchingSpacer(),
            notNowButton,
            UIView.spacer(withHeight: 12),
            primaryButtonView
            ])
        stackView.axis = .vertical
        stackView.alignment = .fill
        primaryView.addSubview(stackView)

        stackView.autoPinEdgesToSuperviewMargins()
    }

    // MARK: Request Access

    private func requestAccess() {
        Logger.info("")

        requestContactsAccess().then { _ in
            return PushRegistrationManager.shared.registerUserNotificationSettings()
        }.done { [weak self] in
            guard let self = self else {
                return
            }
            self.onboardingController.onboardingPermissionsDidComplete(viewController: self)
            }.retainUntilComplete()
    }

    private func requestContactsAccess() -> Promise<Void> {
        Logger.info("")

        let (promise, resolver) = Promise<Void>.pending()
        CNContactStore().requestAccess(for: CNEntityType.contacts) { (granted, error) -> Void in
            if granted {
                Logger.info("Granted.")
            } else {
                Logger.error("Error: \(String(describing: error)).")
            }
            // Always fulfill.
            resolver.fulfill(())
        }
        return promise
    }

     // MARK: - Events

    @objc func skipWasPressed() {
        Logger.info("")

        onboardingController.onboardingPermissionsWasSkipped(viewController: self)
    }

    @objc func giveAccessPressed() {
        Logger.info("")

        requestAccess()
    }

    @objc func notNowPressed() {
        Logger.info("")

        onboardingController.onboardingPermissionsWasSkipped(viewController: self)
    }
}
