## MobilePay AppSwitch
The MobilePay SDK enables your app to receive payments through the MobilePay app.
![][1]

**How it works**  
1 - You initiate the payment from your own app through the SDK.

2 - It automatically switches to the MobilePay App where the user is asked to sign in.

3 - The user confirms the payment.

4 - The receipt is shown and the user can either tap "videre" or wait one second. A counter is showing the time remaining.

5 - MobilePay switches back to your own app together with a MobilePay transactionId.

## Latest SDK Version ##
|Platform|Version|
|:--------|:---|
|Android| 1.8.0|
|iOS| 1.8.0|
|WP| 1.8.0|

## Support
For technical questions about the MobilePay AppSwitch SDK or other related questions, please contact Danske Bank at **+45 70 114 115** or [kundesupport@danskebank.dk](mailto://kundesupport@danskebank.dk)

## Requirements
Please look at the Danske Bank Developer Site for further details [Danske Bank Developer site](http://danskebank.dk/da-dk/mobilepay/pages/app-switch.aspx)

  [1]: https://github.com/DanskeBank/MobilePay-AppSwitch-SDK/blob/master/doc/wiki/images/mobilepay_appswitch_purchase_flow.png "MobilePay AppSwitch purchase flow"

## MerchantID for test purposes
The MerchantID for testing depends on which country you are targeting. The following IDs can be used:

**APPDK0000000000** - Denmark

**APPNO0000000000** - Norway

**APPFI0000000000** - Finland

When the test MerchantID is used you are able to complete the payment flow without transferring any money.

## Cross-platform
Please look at the wiki page for further details [wiki site](https://github.com/DanskeBank/MobilePay-AppSwitch-SDK/wiki/Cross-platform)

## Documentation
 * [Getting Started on iPhone](https://github.com/DanskeBank/MobilePay-AppSwitch-SDK/wiki/Getting-Started-on-iPhone)
 * [Getting started on Android](https://github.com/DanskeBank/MobilePay-AppSwitch-SDK/wiki/Getting-started-on-Android)
 * [Getting Started on Windows Phone](https://github.com/DanskeBank/MobilePay-AppSwitch-SDK/wiki/Getting-Started-on-Windows-Phone)
 * [Error Handling](https://github.com/DanskeBank/MobilePay-AppSwitch-SDK/wiki/Error-handling)
 * [Parameter Specification](https://github.com/DanskeBank/MobilePay-AppSwitch-SDK/wiki/Parameter-Specification)
 * [Security](https://github.com/DanskeBank/MobilePay-AppSwitch-SDK/wiki/Security)
 * [Supported OS versions](https://github.com/DanskeBank/MobilePay-AppSwitch-SDK/wiki/Supported-OS-versions)
 * [Known Errors](https://github.com/DanskeBank/MobilePay-AppSwitch-SDK/wiki/Known-errors)
 * [Cross-platform](https://github.com/DanskeBank/MobilePay-AppSwitch-SDK/wiki/Cross-platform)
 * [Payment Types](https://github.com/DanskeBank/MobilePay-AppSwitch-SDK/wiki/Payment-Types)
