//
//  WAlertViewController.swift
//  yopago
//
//  Created by Melina Miranda on 09/10/2020.
//  Copyright © 2020 YOP. All rights reserved.
//
import Foundation
import UIKit

enum ErrorType {
    case inputCVV
}

enum WAlertAction {
    case accept
    case allow
    case back
    case cancel
    case cancelConfirmation
    case logout
    case remove
    case reverseConfirmation
    case retry
    case retryPaymentRecoveryAction
    case update
}

enum WAlertIcon {
    case bankAccount
    case bill
    case camera
    case card
    case error
    case logout
    case password
    case revert
    case support
}

enum WAlertType {
    case cancelTransaction
    case changePasswordError
    case bankAccountStoredFailure
    case encryptionIngenicoFailure
    case fetchCurrencies
    case infoFiscalID
    case invalidAmount
    case invalidSelfPayment
    case invalidSelfTransfer
    case invalidUsername
    case logout
    case nonAvailable
    case passwordMismatch
    case register
    case removeBankAccount
    case removeCard
    case requestBankAccount
    case requestCVV
    case requireCameraPermission
    case requireFields
    case requireUpdate
    case retryPaymentRecoveryAction
    case retrySamePayment
    case retrySameRequest
    case reverseConfirmation
    case reverseFailure
    case reverseSuccess
    case reverseWithoutFunds
    case scanQrNotFound
    case uploadBillFailure
    case uploadBillWithoutPoints
    case unsupportedGateway
    case unsupportedOperation
    case transactionFailure
    case wabiPaymentFailure
    case withdrawWithoutFunds
    case withdrawalFailure
}

@available(iOS 9.0,*) struct WAlert {
    var actions: [WAlertAction:WAlertActionBlock?]
    var icon: WAlertIcon
    var message: String?
    var title: String?
    var type: WAlertType
}

fileprivate let WAlertViewAnimationDuration = TimeInterval(UINavigationControllerHideShowBarDuration)
@available(iOS 9.0,*) typealias WAlertActionBlock = (_ wAlertView: WAlertViewController ) -> Void

@available(iOS 9.0, *)
class WAlertViewController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {
    var wAlert: WAlert!
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var wAlertView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundImageView.image = UIImage(named: "img_background_modal")
        modalPresentationStyle = .overFullScreen
        submitButton.layer.cornerRadius = submitButton.bounds.height / 2
        wAlertView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        
        // configure text field
        inputTextField.delegate = self
        inputTextField.isHidden = wAlert.type != .requestCVV ? true:false
        inputTextField.keyboardType = .numberPad
        
        // error label appears only for input text field
        errorLabel.isHidden = true
        
        // taps gestures recognizer
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismiss(sender:)))
        tap.delegate = self
        wAlertView.addGestureRecognizer(tap)
        let tapAction = UITapGestureRecognizer(target: self, action: #selector(action(sender:)))
        submitButton.addGestureRecognizer(tapAction)
        
        updateText()
        updateIcon()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        wAlertView.alpha = 0
        contentView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        UIView.animate(withDuration: WAlertViewAnimationDuration, animations: { [weak self] in
            self?.wAlertView.alpha = 1
            self?.contentView?.transform = CGAffineTransform(scaleX: 1, y: 1)
        }) { completed in
            UIView.animate(withDuration: WAlertViewAnimationDuration, animations: { [weak self] in
                self?.wAlertView?.transform = .identity
            })
        }
    }
    
    // MARK:- Class methods
    
    func updateViewWith(error: ErrorType, message: String? = nil) {
        switch error {
        case .inputCVV :
            errorLabel.isHidden = false
            errorLabel.text = message
        }
        stackView.layoutIfNeeded()
    }
    
    private func updateText() {
        let type = wAlert.type
        var closeTitle: String?
        var message: String?
        var submitTitle: String!
        var title: String?
        
        switch type {
        case .bankAccountStoredFailure:
            message = wAlert.message
        case .cancelTransaction:
            message = wAlert.message
            title = wAlert.title
        case .changePasswordError, .passwordMismatch:
            if type == .changePasswordError {
                message = NSLocalizedString("CHANGE_PASSWORD_ERROR_MESSAGE", comment: "Change password error message")
            } else {
                message = NSLocalizedString("CHANGE_PASSWORD_MISMATCH", comment: "Change password mismatch")
            }
            title = NSLocalizedString("CHANGE_PASSWORD_ERROR_TITLE", comment: "Change password error title")
        case .encryptionIngenicoFailure:
            title = NSLocalizedString("ENCRYPTION_FAIL", comment: "Popup title error when ingenico encryption fail")
        case .fetchCurrencies:
            title = NSLocalizedString("AMOUNT_FETCH_CURRENCIES_ERROR", comment: "Error occured when fetching currencies")
        case .infoFiscalID:
            message = wAlert.message
        case .invalidAmount:
            message = NSLocalizedString("INVALID_AMOUNT", comment: "Alert amount error message")
            title = NSLocalizedString("ERROR", comment: "Alert amount error title")
        case .invalidSelfPayment:
            message = NSLocalizedString("INVALID_SELF_PAYMENT", comment: "Alert self transaction error message")
            title = NSLocalizedString("PAYMENT_ERROR_TITLE", comment: "Alert who error title")
        case .invalidSelfTransfer:
            message = NSLocalizedString("INVALID_SELF_TRANSACTION", comment: "Alert self transaction error message")
            title = NSLocalizedString("ERROR", comment: "Alert who error title")
        case .invalidUsername:
            message = NSLocalizedString("INVALID_USERNAME", comment: "Alert who error message")
            title = NSLocalizedString("ERROR", comment: "Alert who error title")
        case .logout:
            message = NSLocalizedString("LOGOUT_MODAL_MESSAGE", comment: "Message of the modal before log out")
            title = NSLocalizedString("LOGOUT_MODAL_TITLE", comment: "Title of the modal before log out")
        case .nonAvailable:
            title = NSLocalizedString("PERMISION_DISABLED_TITLE", comment: "Title that appears when an action is disabled")
            message = NSLocalizedString("PERMISSION_DISABLED_MESSAGE", comment: "Message that appears when an action is disabled")
        case .register:
            title = NSLocalizedString("ERROR", comment: "Alert error title")
            message = NSLocalizedString("REGISTER_ERROR_UNKNOWN", comment: "Register error generic")
        case .removeBankAccount:
            title = NSLocalizedString("REMOVE_BANK_ACCOUNT_CONFIRMATION", comment: "Ask the user if he/she really want to remove his/her bank account")
        case .removeCard:
            message = wAlert.message
            title = NSLocalizedString("REMOVE_CARD", comment: "Remove card confirmation popup title")
        case .reverseConfirmation:
            message = NSLocalizedString("REVERSE_CONFIRMATION_MESSAGE", comment: "Message for reverse confirmation")
            title = NSLocalizedString("REVERSE_CONFIRMATION_TITLE", comment: "Title for reverse confirmation")
        case .requestBankAccount:
            message = NSLocalizedString("BANK_REQUIREMENT_ALERT_MESSAGE", comment: "Message for bank account requirement's alert")
            title = NSLocalizedString("BANK_REQUIREMENT_ALERT_TITLE", comment: "Title for bank account requirement's alert")
        case .requestCVV:
            message = wAlert.message
            title = wAlert.title
        case .requireCameraPermission:
            message = NSLocalizedString("CAMERA_PERMISSION_REQUIRED_QR_MESSAGE", comment: "Message for camera permission required to scan qr when it has been denied")
            title = NSLocalizedString("CAMERA_PERMISSION_REQUIRED_QR_TITLE", comment: "Title for camera permission required to scan qr when it has been denied")
        case .requireFields:
            message = NSLocalizedString("FORM_ALL_FIELDS_REQUIRED_MESSAGE", comment: "Error message when form not complete")
            title = NSLocalizedString("FORM_ALL_FIELDS_REQUIRED_TITLE", comment: "Error title when form not complete")
        case .requireUpdate:
            message = NSLocalizedString("PERMISSION_UNKNOWN_MESSAGE", comment: "Message that appears when an action is unknown or not supported")
            title = NSLocalizedString("PERMISSION_UNKNOWN_TITLE", comment: "Title that appears when an action is unknown or not supported")
        case .retryPaymentRecoveryAction:
            message = wAlert.message
        case .retrySamePayment:
            title = NSLocalizedString("PAYMENT_ALREADY_DONE_TITLE", comment: "Title for alert when user try to pay a money request with same nonce twice")
        case .retrySameRequest:
            title = NSLocalizedString("MONEY_ALREADY_REQUESTED", comment: "Alert user already create the money request")
        case .reverseWithoutFunds:
            message = NSLocalizedString("INSUFFICIENT_FUNDS_ERROR", comment: "Insufficient funds error reverting a operation")
        case .reverseFailure:
            message = NSLocalizedString("REVERSE_FAILURE", comment: "Message when reverse failed")
        case .reverseSuccess:
            message = NSLocalizedString("REVERSE_SUCCESS", comment: "Message when reverse successful")
        case .scanQrNotFound:
            message = NSLocalizedString("SCAN_QR_USERNAME_NOT_FOUND", comment: "Error message when QR user is not found")
            title = NSLocalizedString("ERROR", comment: "Error")
        case .transactionFailure:
            title = NSLocalizedString("ERROR", comment: "Alert review error title")
            message = NSLocalizedString("REVIEW_TRY_AGAIN", comment: "Alert review error message")
        case .uploadBillFailure:
            title = NSLocalizedString("UPLOAD_BILL_ERROR_TITLE", comment: "Upload bill error title")
        case .uploadBillWithoutPoints:
            message = NSLocalizedString("UPLOAD_BILL_INSUFFICIENT_FUNDS", comment: "Upload bill without wabicredits error message")
        case .unsupportedGateway:
            message = NSLocalizedString("ADD_CREDIT_CARD_NO_GATEWAY", comment: "User enters card but there is no gateway supported to process it")
            title = NSLocalizedString("ERROR", comment: "Error")
        case .unsupportedOperation:
            message = NSLocalizedString("UNAVAILABLE_ACTION_MESSAGE", comment: "Text for pop up when a shortcut is not available in the country or missing requirements")
            title = NSLocalizedString("UNSUPPORTED_OPERATION_TITLE", comment: "Not supported operation popover title")
        case .wabiPaymentFailure:
            message = NSLocalizedString("WABI_MONEY_REQUEST_ERROR_MESSAGE", comment: "Message for wabi money request error popup")
            title = NSLocalizedString("WABI_MONEY_REQUEST_ERROR_TITLE", comment: "Title for wabi money request error popup")
        case .withdrawWithoutFunds:
            title = NSLocalizedString("NO_FUNDS_FOR_WITHDRAW", comment: "No funds availables for withdraw alert")
        case .withdrawalFailure:
            message = NSLocalizedString("REVIEW_TRY_AGAIN", comment: "Alert review error message")
            title = NSLocalizedString("PAYMENT_ERROR_TITLE", comment: "Alert review error title")
        }
        
        for action in wAlert.actions.keys {
            switch action {
            case .accept:
                submitTitle = NSLocalizedString("ACCEPT", comment: "Accept button")
            case .allow:
                submitTitle = NSLocalizedString("ALLOW", comment: "Allow button")
            case .back:
                closeTitle = NSLocalizedString("BACK", comment: "Back button")
            case .cancel:
                closeTitle = NSLocalizedString("CANCEL", comment: "Cancel button")
            case .cancelConfirmation:
                submitTitle = NSLocalizedString("CANCEL_CONFIRMATION_ACTION", comment: "Cancel confirmation button")
            case .logout:
                submitTitle = NSLocalizedString("LOGOUT_CONFIRMATION_ACTION", comment: "Logout confirmation button")
            case .remove:
                submitTitle = NSLocalizedString("REMOVE_CONFIRMATION_ACTION", comment: "Remove confirmation button")
            case .reverseConfirmation:
                submitTitle = NSLocalizedString("REVERSE_CONFIRMATION_ACTION", comment: "Reverse confirmation button")
            case .retry:
                submitTitle = NSLocalizedString("RETRY", comment: "Retry button")
            case .retryPaymentRecoveryAction:
                submitTitle = wAlert.title
            case .update:
                submitTitle = NSLocalizedString("UPDATE", comment: "Update button")
            }
        }
        
        if  title != nil {
            titleLabel.text = title
        } else {
            titleLabel.isHidden = true
        }
        
        if  message != nil {
            messageLabel.text = message
        } else {
            messageLabel.isHidden = true
        }
        
        if closeTitle != nil {
            closeButton.setTitle(closeTitle, for: .normal)
        } else {
            closeButton.isHidden = true
        }
        
        submitButton.setTitle(submitTitle, for: .normal)
    }
    
    private func updateIcon() {
        switch wAlert.icon {
        case .bankAccount:
            iconImageView.image = UIImage(named: "icn_modal_bank")
        case .bill:
            iconImageView.image = UIImage(named: "icn_bill")
        case .camera:
            iconImageView.image = UIImage(named: "icn_camera")
        case .card:
            iconImageView.image = UIImage(named: "icn_modal_card")
        case .error:
            iconImageView.image = UIImage(named: "icn_modal_error")
        case .logout:
            iconImageView.image = UIImage(named: "icn_modal_logout")
        case .password:
            iconImageView.image = UIImage(named: "icn_modal_password")
        case .revert:
            iconImageView.image = UIImage(named: "icn_symbol_money_on")
        case .support:
            iconImageView.image = UIImage(named: "icn_modal_support")
        }
    }
    
    @IBAction func closeButtonAction(_ sender: UIButton) {
        dismiss()
    }
    
    @objc private func action(sender: UITapGestureRecognizer? = nil) {
        let actions = wAlert.actions
        for action in actions {
            if action.value?(self) == nil {
                dismiss()
            }
        }
    }
    
    @objc func dismiss(sender: UITapGestureRecognizer? = nil) {
        UIView.animate(withDuration: WAlertViewAnimationDuration, animations: { [weak self] in
            self?.wAlertView.alpha = 0
            self?.contentView?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }) { [weak self] completed in
            self?.dismiss(animated: false)
        }
    }
    
    // MARK:- UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view == contentView || touch.view == stackView {
            return false
        } else {
            return true
        }
    }

    // MARK:- UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let currentCvv = textField.text {
            let nsCurrent = currentCvv as NSString
            let newCvv = nsCurrent.replacingCharacters(in: range, with: string)
            guard newCvv.count <= 4 else { return false } // by default at least 4 numbers has a cvv of a credit card
        }
        return true
    }
}
