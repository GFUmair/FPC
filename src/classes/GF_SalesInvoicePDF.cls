global with sharing class GF_SalesInvoicePDF {
    public String SIId;
    global GFERP__Sales_Invoice__c theSI {get; set;}
    global List<GFERP__Sales_Invoice_Line__c> theSILList {get; set;}
    global GFERP__Company_Setup__c theCompanySetup {get; set;}
    global Decimal totalDiscount {get; set;}
    global Decimal subtotal {get; set;}
    global Decimal totalTax {get; set;}
    global Decimal totalAmount {get; set;}
    global String docTitle {get; set;}
    global Decimal balanceAmount {get; set;}
    global Decimal paymentAmount { get; set; }
    global Boolean isCashReceiptEnable { get; set; }

    global GF_SalesInvoicePDF(ApexPages.StandardController controller) {
        SIId = controller.getId();
        theCompanySetup = GFERP.CompanyMgmt.getCompanySetup();
        selectSI();
        selectSILList();
        if (theSI != null && theCompanySetup.GFERP__Enable_Cash_Receipt__c) {
            isCashReceiptEnable = true;
            selectALE();
        } else {
            isCashReceiptEnable = false;
        }
    }

    private void selectSI() {
        Map<String, Schema.SObjectField> fields = Schema.SObjectType.GFERP__Sales_Invoice__c.fields.getMap();
        List<String> lstFields = new List<String>();
        for (Schema.SObjectField field : fields.values()) {
            lstFields.add(field.getDescribe().getName());
        }
        String strQuery = 'SELECT ' + String.join(lstFields, ',');
        strQuery += ',GFERP__GL_Ledger2__r.Phone__c,GFERP__GL_Ledger2__r.Logo__c,GFERP__GL_Ledger2__r.Postal_Code__c,GFERP__GL_Ledger2__r.State__c,GFERP__GL_Ledger2__r.City__c,GFERP__GL_Ledger2__r.Street__c,GFERP__GL_Ledger2__r.Name,GFERP__Sell_to_Customer__r.Name,GFERP__Bill_to_Customer__r.Name,GFERP__Tax_Area__r.Name,GFERP__Shipping_Agent__r.Name,GFERP__Shipping_Contact__r.Name,GFERP__Billing_Contact__r.Name,' +
                'GFERP__Warehouse__r.Name,GFERP__Sales_Rep__r.Name,GFERP__Currency__r.Name,GFERP__Broker__r.Name,GFERP__Payment_Term__r.Name,GFERP__Payment_Term__r.GFERP__Description__c,GFERP__Alternate_Shipping__r.Name,GFERP__Sales_Order__r.Name';
        strQuery += ' FROM GFERP__Sales_Invoice__c WHERE Id = : SIId';
        theSI = Database.query(strQuery);

        totalDiscount = theSI.GFERP__Invoice_Discount__c.setScale(2, RoundingMode.HALF_UP);
        subtotal = theSI.GFERP__Invoice_Amount__c.setScale(2, RoundingMode.HALF_UP);
        totalTax = theSI.GFERP__Invoice_Tax__c.setScale(2, RoundingMode.HALF_UP);
        totalAmount = theSI.GFERP__Invoice_Amt_Incl_Tax__c.setScale(2, RoundingMode.HALF_UP);
        docTitle = theSI.GFERP__Credit_Memo__c ? 'CREDIT MEMO' : 'SALES INVOICE';
    }

    private void selectSILList() {
        Map<String, Schema.SObjectField> fields = Schema.SObjectType.GFERP__Sales_Invoice_Line__c.fields.getMap();
        List<String> lstFields = new List<String>();
        for (Schema.SObjectField field : fields.values()) {
            lstFields.add(field.getDescribe().getName());
        }
        String strQuery = 'SELECT ' + String.join(lstFields, ',');
        strQuery += ',GFERP__Item__r.Name,GFERP__Item__r.GFERP__Costing_Method__c,GFERP__Item__r.GFERP__Standard_Base_Cost__c,GFERP__Item__r.GFERP__Inventory_Class__c,GFERP__Item__r.GFERP__Serial_Tracked__c,GFERP__Item__r.GFERP__Catch_Weight__c,GFERP__Item__r.GFERP__UPC__c';
        strQuery += ',GFERP__Item__r.GFERP__Lot_Tracked__c,GFERP__Item__r.GFERP__Item_Category__c,GFERP__Unit_of_Measure__r.Name,GFERP__Sales_Line__r.GFERP__Quantity__c,GFERP__Shipment_Line__r.GFERP__Quantity__c';
        strQuery += ',GFERP__Item__r.GFERP__Base_Unit_of_Measure__r.Name FROM GFERP__Sales_Invoice_Line__c WHERE GFERP__Sales_Invoice__c =: SIId ORDER BY GFERP__Line_No__c';
        theSILList = Database.query(strQuery);
    }

    public void selectALE() {
        balanceAmount = 0;
        paymentAmount = 0;
        /*
        List<Account_Ledger_Entry__c> theALEList = [SELECT Name, Amount__c, Remaining_Amount__c FROM Account_Ledger_Entry__c WHERE Sales_Invoice__c =: theSI.Id];
        if (theALEList.size() > 0) {
            balanceAmount = theALEList[0].Remaining_Amount__c;
            paymentAmount = totalAmount - balanceAmount;
        }*/
        if (theSI.GFERP__Document_Status__c == 'Posted') {
            for (GFERP__Account_Ledger_Entry__c ALE : [SELECT Name, GFERP__Amount__c, GFERP__Remaining_Amount__c FROM GFERP__Account_Ledger_Entry__c WHERE GFERP__Sales_Invoice__c =: theSI.Id]){
                balanceAmount += ALE.GFERP__Remaining_Amount__c;
            }
            paymentAmount = totalAmount - balanceAmount;
        }
    }
}