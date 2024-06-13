@IsTest
public class GF_ReceiptLabelPDFControllerTest {
 @IsTest
    static void testBehavior5() {
        GFERP__User_Setup__c theUS = GF_TestDataUtil.UserSetupRecord;
        GFERP__Company_Setup__c companySetup = GF_TestDataUtil.CompanySetupRecord;
        GFERP__Inventory_Setup__c inventorySetup = GF_TestDataUtil.InventorySetupRecord;
        GFERP__Whse_Receipt__c WRRecord = GF_TestDataUtil.WhseReceiptRecord;
        GFERP__Whse_Receipt_Line__c WRLRecord = GF_TestDataUtil.WhseReceiptLineRecord;
        GFERP__Tracking_Line__c TLRecord = GF_TestDataUtil.TrackingLine2Record;
        GFERP__Bin_Content__c BCRecord = GF_TestDataUtil.BinContentRecord;
        Test.startTest();
        List<GFERP__Whse_Receipt__c> theList = new List<GFERP__Whse_Receipt__c>{WRRecord};
        ApexPages.StandardSetController stdSet = new ApexPages.StandardSetController(theList);
        GF_ReceiptLabelPDFController inst = new GF_ReceiptLabelPDFController(stdSet);
        stdSet.setSelected(theList);
        inst = new GF_ReceiptLabelPDFController(stdSet);
        Test.stopTest();
    }

}