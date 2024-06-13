@IsTest
private class GF_PDFTest {

    @IsTest
    static void GF_PDF() {
        GFERP__Company_Setup__c companySetup = GF_TestDataUtil.CompanySetupRecord;
        GFERP__Purchase_Order__c thePO = GF_TestDataUtil.PurchaseOrderRecord;
        GFERP__Purchase_Line__c thePL = GF_TestDataUtil.PurchLineRecord;
        GFERP__Sales_Order__c theSO = GF_TestDataUtil.SalesOrderRecord;
        GFERP__Sales_Line__c theSOline = GF_TestDataUtil.SalesLineRecord;
        GFERP__Warehouse__c warehouse = GF_TestDataUtil.WarehouseRecord2;
        GFERP__Warehouse__c warehouse1 = GF_TestDataUtil.WarehouseRecord;
        GFERP__Sales_Invoice__c SalesInvoiceRecord1 = GF_TestDataUtil.SalesInvoiceRecord;
        GFERP__Cross_Reference__c CRRecord = GF_TestDataUtil.CrossReferenceRecord;
        GFERP__Whse_Shipment__c theWS = GF_TestDataUtil.WhseShipmentRecord;
        GFERP__Whse_Shipment_Line__c theWSL = GF_TestDataUtil.WhseShipmentLineRecord;
        GFERP__Warehouse__c theWSL2 = GF_TestDataUtil.WarehouseRecord2;
        GFERP__Bin_Type__c theWSL3 = GF_TestDataUtil.BinTypeShipRecord;
        GFERP__Item__c theWSL4 = GF_TestDataUtil.ItemRecord;
        GFERP__Item_Ledger_Entry__c theWSL5 = GF_TestDataUtil.ItemLedgerEntryRecord1;
        thePL.GFERP__Work_Order__c = GF_TestDataUtil.WorkOrderRecord.Id;
        update thePL;
        GFERP__Purchase_Invoice__c PIRecord = GF_TestDataUtil.PurchInvoiceRecord;
        
        Account theAcc = [SELECT Name FROM Account WHERE Id =: thePO.GFERP__Buy_from_Vendor2__c];
        theAcc.GFERP__Print_Cross_Reference_on_PO__c = true;
        update theAcc; 
        GFERP__Sales_Line__c theSL = GF_TestDataUtil.SalesLineRecord;
        GFERP__QC_Test_Line__c QCTestLineRecord = GF_TestDataUtil.QCTestLineRecord;
        Test.startTest();
        PageReference pref = Page.GF_PurchaseOrderPDFCustom1;
        Test.setCurrentPage(pref);
        GF_PurchaseOrderPDF instance = new GF_PurchaseOrderPDF(new ApexPages.StandardController(GF_TestDataUtil.PORecord));
        Integer i = instance.decimalPlaces;
        List<GFERP__Sales_Order__c> theSOList = [SELECT Name FROM GFERP__Sales_Order__c];
         GF_SalesOrderPDF SOPDF = new GF_SalesOrderPDF(new ApexPages.StandardController(GF_TestDataUtil.SalesOrderRecord));
        SOPDF.getSOSLList();
         GF_SalesInvoicePDF instance2 = new GF_SalesInvoicePDF(new ApexPages.StandardController(GF_TestDataUtil.SalesInvoiceRecord));
        
        CRRecord.GFERP__Account__c = theWS.GFERP__Sell_to_Customer__c;
        update CRRecord;
        PageReference pref2 = Page.GF_PackingSlipPDFCustom;        
        Test.setCurrentPage(pref);
        pref.getParameters().put('id',theWS.Id);
      	Account theAcc2 = [SELECT Name, GFERP__Print_Cross_Reference_on_Packing_List__c, GFERP__Print_Cross_Reference_on_Pallet_List__c FROM Account WHERE Id =: theWS.GFERP__Sell_to_Customer__c];
        theAcc2.GFERP__Print_Cross_Reference_on_Pallet_List__c = true;
        theAcc2.GFERP__Print_Cross_Reference_on_Packing_List__c = true;
        update theAcc2;
        GF_PackingSlipPDFController Packing = new GF_PackingSlipPDFController(new ApexPages.StandardController(theWS));
        //instance.PrintPackingList();
        Packing.theWS.GFERP__Document_Status__c = 'Closed';
        List<GFERP__Whse_Shipment__c> theList = new List<GFERP__Whse_Shipment__c>{theWS};
        ApexPages.StandardSetController theStdC = new ApexPages.StandardSetController(theList);
        theStdC.setSelected(theList);
        GF_PackingSlipPDFController instance1 = new GF_PackingSlipPDFController(theStdC);
        List<GFERP__Whse_Shipment__c> theWRList = [SELECT Id From GFERP__Whse_Shipment__c WHERE Id =: theWS.Id];
        System.assertEquals(theWRList.size(),1); 
        
        
        
        
        Test.stopTest();    
    }

}