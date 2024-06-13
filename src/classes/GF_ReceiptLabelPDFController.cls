/**
* Created by umair cheng on 1/26/2024.
*/
global with Sharing class GF_ReceiptLabelPDFController {
    global String errMsg { get; set; }
    global List<String> WRId;
    global List<GFERP__Whse_Receipt__c> selectedwhseList { get; set; }
    global List<GFERP__Whse_Receipt_Line__c> theWRLList { get; set; }
    global List<GFERP__Pallet__c> thePLList { get; set; }
    global GFERP__Company_Setup__c companySetup { get; set; }

    global GF_ReceiptLabelPDFController(ApexPages.StandardController Controller) {
        WRId = new List<String>();
        companySetup = [SELECT GFERP__Barcode_Generator__c FROM GFERP__Company_Setup__c LIMIT 1];
        WRId.add(Controller.getId());
        selectWR();
        selectWRLList();
        selectWRPalletsList();
    }
    public GF_ReceiptLabelPDFController(ApexPages.StandardSetController controller) {
        WRId = new List<String>();
        companySetup = [SELECT GFERP__Barcode_Generator__c FROM GFERP__Company_Setup__c LIMIT 1];
        errMsg = '';
        selectedwhseList = new List<GFERP__Whse_Receipt__c>();
        for (GFERP__Whse_Receipt__c whseRe : (GFERP__Whse_Receipt__c[]) controller.getSelected()) {
            WRId.add(whseRe.Id);
        }
        if (WRId.size() != 0) {
            selectWR();
            selectWRLList();
            selectWRPalletsList();
        }
    }
    private void selectWR() {
        Map<String, Schema.SObjectField> fields = Schema.SObjectType.GFERP__Whse_Receipt__c.fields.getMap();
        List<String> lstFields = new List<String>();
        for (Schema.SObjectField field : fields.values()) {
            lstFields.add(field.getDescribe().getName());
        }
        String strQuery = 'SELECT ' + String.join(lstFields, ',');
        strQuery += ',GFERP__Purchase_Order__r.Name,GFERP__Buy_from_Vendor__r.Name,GFERP__Sell_to_Customer__r.Name,GFERP__Alternate_Shipping2__r.Name,GFERP__Shipping_Agent__r.Name,GFERP__Warehouse__r.Name FROM GFERP__Whse_Receipt__c WHERE Id IN: WRId ORDER BY FERP__Purchase_Order__r.Name';
    }

    private void selectWRLList() {
        Map<String, Schema.SObjectField> fields = Schema.SObjectType.GFERP__Whse_Receipt_Line__c.fields.getMap();
        List<String> lstFields = new List<String>();
        for (Schema.SObjectField field : fields.values()) {
            lstFields.add(field.getDescribe().getName());
        }
        String strQuery = 'SELECT ' + String.join(lstFields, ',');
        strQuery += ',GFERP__Item__r.Name,GFERP__Unit_of_Measure__r.Name,GFERP__Item__r.GFERP__UPC__c,GFERP__Item__r.GFERP__Brand__c,GFERP__Item__r.GFERP__Manufacturer__r.Name,GFERP__Receipt__r.GFERP__Purchase_Order__r.Name, GFERP__Receipt__r.GFERP__Actual_Receipt_Date__c,' +
                '(Select GFERP__Item_Lot__c, GFERP__Item_Lot__r.Name, GFERP__Item_Lot__r.GFERP__Manufacture_Date__c, GFERP__Item_Lot__r.GFERP__Expiration_Date__c, GFERP__Quantity__c, GFERP__Serial_No__c from GFERP__Tracking_Lines__r)' +
                ' FROM GFERP__Whse_Receipt_Line__c WHERE GFERP__Receipt__c IN: WRId ORDER BY GFERP__Receipt__r.GFERP__Purchase_Order__r.Name, GFERP__Item__r.Name';
        theWRLList = Database.query(strQuery);
    }
    private void selectWRPalletsList() {
        Map<String, Schema.SObjectField> fields = Schema.SObjectType.GFERP__Pallet__c.fields.getMap();
        List<String> lstFields = new List<String>();
        for (Schema.SObjectField field : fields.values()) {
            lstFields.add(field.getDescribe().getName());
        }
        String strQuery = 'SELECT ' + String.join(lstFields, ',');
        strQuery += ',GFERP__Whse_Receipt__r.GFERP__Purchase_Order__r.Name, GFERP__Whse_Receipt__r.GFERP__Actual_Receipt_Date__c,' +
                '(Select GFERP__Item_Description__c, GFERP__Item__c, GFERP__Item__r.Name,  GFERP__Item_Lot__r.Name, GFERP__Quantity__c from GFERP__Pallet_Lines__r)' +
                ' FROM GFERP__Pallet__c WHERE GFERP__Whse_Receipt__c IN: WRId ORDER BY GFERP__Whse_Receipt__r.GFERP__Purchase_Order__r.Name';
        thePLList = Database.query(strQuery);
    }
}