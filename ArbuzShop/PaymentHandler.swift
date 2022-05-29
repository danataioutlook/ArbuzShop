//
//  PaymentHandler.swift
//  ArbuzShop
//
//  Created by Dana on 29.05.2022.
//

import Foundation
import PassKit

typealias PaymentCompletionHandler = (Bool) -> Void

class PaymentHandler : NSObject {
    var PaymentController : PKPaymentAuthorizationController?
    var PaymentSummaryItems = [PKPaymentSummaryItem] ()
    var PaymentStatus = PKPaymentAuthorizationStatus.failure
    var completionHandler : PaymentCompletionHandler?
    
    static let supportedNetworks : [PKPaymentNetwork] = [
        .visa,
            .masterCard]
    
    func shippingMethodCalculator() ->[PKShippingMethod]{
        let today = Date()
        let calender = Calendar.current
        
        let shippingStart = calender.date(byAdding:.day, value: 5, to:today)
        let shippingEnd = calender.date(byAdding: .day, value:10,  to: today)
        
        
        if let shippingEnd = shippingEnd, let shippingStart = shippingStart {
            
            let startComponents = calender.dateComponents([.calendar, .year,.month , .day], from: shippingStart)
            let endComponents = calender.dateComponents([.calendar, .year,.month , .day], from: shippingEnd)
            
            let shippingDelivery = PKShippingMethod(label: "Delivery", amount: NSDecimalNumber(string:" 0.00"))
            
            shippingDelivery.dateComponentsRange = PKDateComponentsRange(start:startComponents , end: endComponents)
            
            shippingDelivery.detail = "Arbuzs sent to your address"
            shippingDelivery.identifier = "DELIVERY"
            
            return [shippingDelivery]
        }
        return []
    }
    
    func startPayment(products:[Product], total : Int, completion: @escaping PaymentCompletionHandler){
        completionHandler = completion
        
        PaymentSummaryItems = []
        
        products.forEach{ product in
           let item =  PKPaymentSummaryItem(label: product.name, amount: NSDecimalNumber(string: "\(product.price).00"), type: .final)
            
            PaymentSummaryItems.append(item)
            
        }
        let total = PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(string: "\(total).00") , type: .final)
        PaymentSummaryItems.append(total)
        
        let paymentRequest = PKPaymentRequest()
        paymentRequest.paymentSummaryItems = PaymentSummaryItems
        paymentRequest.merchantIdentifier = "merchant.io.designcode.arbuz"
        paymentRequest.merchantCapabilities = .capability3DS
        paymentRequest.countryCode = "KZ"
        paymentRequest.currencyCode = "KZT"
        paymentRequest.supportedNetworks = PaymentHandler.supportedNetworks
        paymentRequest.shippingType = .delivery
        paymentRequest.shippingMethods = shippingMethodCalculator()
        paymentRequest.requiredShippingContactFields = [.name, .postalAddress]
        
      PaymentController =   PKPaymentAuthorizationController(paymentRequest: paymentRequest)
        PaymentController?.delegate = self
        PaymentController?.present(completion: { (presented : Bool) in
            
            if presented{
                debugPrint("Presented payment Controller")
            } else{
                debugPrint("Failed tp present payment controller")
            }
        })
                                   
                                   }
                                   }

extension PaymentHandler :PKPaymentAuthorizationControllerDelegate{
    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        let errors = [Error] ()
        let status = PKPaymentAuthorizationStatus.success
        
        self.PaymentStatus = status
        completion(PKPaymentAuthorizationResult(status: status, errors: errors))
    }
    
    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss{
            DispatchQueue.main.async {
                if self.PaymentStatus == .success{
                    if let completionHandler = self.completionHandler{
                        completionHandler(true)
                    }
                   
                 else{
                     if let  completionHandler = self.completionHandler{
                    completionHandler(false)
                }
            }
        }
    }
        }
    }


}
