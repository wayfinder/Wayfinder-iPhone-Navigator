/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "BillingManager.h"
#import "LocalizationHandler.h"

@implementation BillingManager

@synthesize originalPurchaseRequest;
@synthesize iPhoneBillingInterface;
@synthesize requiredProduct;
@synthesize purchaseAlertView;

- (id)init {
	if(self = [super init]) {
		
		self.iPhoneBillingInterface = [[IPhoneBillingInterface alloc] init];
		[self.iPhoneBillingInterface release];
		// [self.iPhoneLocationInterface setLocationHandler:self];				
		
		SKPaymentQueue *queue = [SKPaymentQueue defaultQueue];		
		[queue addTransactionObserver:self];		
	}
	return self;
}

- (void)dealloc {
	self.iPhoneBillingInterface = nil;
	self.requiredProduct = nil;	
	self.purchaseAlertView = nil;	
	
	[super dealloc];
}

- (void)purchase:(NSString *)selectionString requiredForProduct:(NSString *)productIdentification newSubscription:(BOOL)newSubscription {
	// self.selectionStr = selectionString;
	// self.productId = productIdentification;
	// self.newSubscriptionRequired = newSubscription;
	
	// Request product data
	SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers: 
								 [NSSet setWithObject: productIdentification]]; 
	request.delegate = self; 
	[request start]; 	
}

- (void)requestPurchase:(NSString *)purchaseRequest causedByStatusCode:(NSInteger)statusCode {
	// If a purchase is required the data field in the status argument contains a colon separated 
	// data type and a data value pair <dataType>;<dataValue> where the dataType="iPhoneAppStore"
	// and the dataType contains the id of the product that needs to be purchased before routing
	// can be resumed.
	self.originalPurchaseRequest = purchaseRequest;
	
	NSRange separatorRange = (NSRange) {';', 1};
	NSCharacterSet *charSet = [NSCharacterSet characterSetWithRange:separatorRange];
	NSArray *components = [purchaseRequest componentsSeparatedByCharactersInSet:charSet];
	if([components count] == 2) {
		NSString *dataType = [components objectAtIndex:0];
		NSString *dataValue = [components objectAtIndex:1];
		
		NSLog(@"Data type = %@", dataType);
		NSLog(@"Data value = %@", dataValue);
		
		if([dataType isEqualToString:@"iPhoneAppStore"]) {						
				[self purchase:purchaseRequest requiredForProduct:dataValue 
			   newSubscription:(statusCode == UNAUTHORIZED_ERROR)];									
		}						
	} 
}

#pragma mark -
#pragma mark SKProductsRequestDelegate methods

- (void)productsRequest:(SKProductsRequest *)request 
	 didReceiveResponse:(SKProductsResponse *)response 
{ 
    NSArray *products = response.products;
	if([products count] == 0) {
		// No products have been found
	}
	else {	
		self.requiredProduct = [products objectAtIndex:0];
		NSString *message;
		if(YES /*self.newSubscriptionRequired*/) {
			message = [LocalizationHandler getString:@"serv_iPh_trial_expiredq_txt"];	
		}
		else {
			message = [LocalizationHandler getString:@"serv_iPh_buy_add_subscrq_txt"];	
		}
		
		//TODO insert arguments into string!!!!
		
		self.purchaseAlertView = [[UIAlertView alloc] initWithTitle:[LocalizationHandler getString:@"[purchase_popup_title]"]
															message:message 
														   delegate:self 
												  cancelButtonTitle:[LocalizationHandler getString:@"iPh_no_tk"] 
												  otherButtonTitles:[LocalizationHandler getString:@"iPh_yes_tk"], nil];
		[self.purchaseAlertView setCancelButtonIndex:0];	
		[self.purchaseAlertView show];	
		[self.purchaseAlertView release];
	}
}

#pragma mark -
#pragma mark UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	// Have the user accepted?
	NSInteger cancelIndex = [alertView cancelButtonIndex];
	if(cancelIndex == buttonIndex) {
		// The user declines to purchase subscription for navigation
	}
	else {
		// The user accepts to purchase sunscription for navigation
		SKPayment *payment = [SKPayment 
							  paymentWithProductIdentifier:self.requiredProduct.productIdentifier]; 
		SKPaymentQueue *queue = [SKPaymentQueue defaultQueue];		
		[queue addPayment:payment];				
	}
}

#pragma mark -
#pragma mark SKPaymentTransactionObserve Methods

- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions {
	for(id obj in transactions) {
		NSLog(@"removeTransaction: %@", obj);
	}
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
	NSLog(@"queuerestoreCompletedTransactionsFailedWithError: %@", error);
}

- (NSString *)fromStateToString:(NSInteger)state {
	switch(state) {
		case SKPaymentTransactionStatePurchasing:
			return @"SKPaymentTransactionStatePurchasing";
		case SKPaymentTransactionStatePurchased:
			return @"SKPaymentTransactionStatePurchased";
		case SKPaymentTransactionStateFailed:
			return @"SKPaymentTransactionStateFailed";
		case SKPaymentTransactionStateRestored:
			return @"SKPaymentTransactionStateRestored";
	}
	
	return @"Unknown";
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
	for(id obj in transactions) {
		NSLog(@"updatedTransactions: %@", obj);
		SKPaymentTransaction *trans = (SKPaymentTransaction *) obj;

		NSLog(@"  error = %@", trans.error);
		NSLog(@"  payment = %0", trans.payment);
		NSLog(@"  state = %@", [self fromStateToString:trans.transactionState]);
		
		switch(trans.transactionState) {
			case SKPaymentTransactionStatePurchasing: {
				break;
			}				
			case SKPaymentTransactionStatePurchased: {
				// TODO: Should be done here but only after the receipt has been verified!!!!!!
				[queue finishTransaction:trans];
				
				const char *ptr = (const char *) trans.transactionReceipt.bytes;
				char buffer[trans.transactionReceipt.length + 1];
				int r;
				for(r = 0; r < trans.transactionReceipt.length; r++) {
					buffer[r] = ptr[r];
				}
				buffer[r] = '\0';
				
				NSString *transactionID = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
				NSString *selectionString = [NSString stringWithFormat:@"IphoneAppStore;%@", self.requiredProduct];
				
				NSLog(@"Transaction ID: %@", transactionID);
				NSLog(@"SelectionString: %@", selectionString);
				
				[iPhoneBillingInterface verifyThirdPartyTransactionWithId:transactionID andSelectionString:self.originalPurchaseRequest];
				
				break;
			}					
			case SKPaymentTransactionStateFailed: {
				SKPaymentQueue *queue = [SKPaymentQueue defaultQueue];					
				[queue finishTransaction:trans];
				break;
			}
			case SKPaymentTransactionStateRestored: {
				// This should occur!!!!
				break;
			}
		}
	}		
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
	for(id obj in queue.transactions) {
		NSLog(@"paymentQueueRestoreCompletedTransactionsFinished: %@", obj);
	}
	
}

@end
