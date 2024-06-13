@IsTest
public class GF_ImportSalesPriceControllerTest {
	@testSetup static void SetupData() {
        //Setup Data
        GFERP__Company_Setup__c  testcompanySetup = GF_TestDataUtil.CompanySetupRecord;
        List<GFERP__Company_Setup__c> testCSList = [SELECT Id From GFERP__Company_Setup__c WHERE Id =: testcompanySetup.Id];
        Account accRecord = new Account(Name = 'amazon shipment');
        insert accRecord;
        GFERP__Item__c itemRec =  GF_TestDataUtil.ItemRecord;
        
        Import_Sales_Prices__c ispRec =  GF_TestDataUtil.ImportSalesPriceRecord;
        GFERP__Sales_Price2__c spRec =  GF_TestDataUtil.SalesPriceRecord;
        System.assertEquals(testCSList.size(),1);
        
    }
	
    @IsTest
    static void testBehavior() {
		List<Import_Sales_Prices__c> ISPList = [Select Id, Name, Account__c, Currency__c, Account_Id__c, Currency_Code_Id__c,Ending_Date__c,Processed__c,Error_Text__c,Item__c, Item_Id__c, Minimum_Quantity__c, Pricing_Type__c, Sales_Price__c, Sales_Pricing_Group__c, Starting_Date__c, Unit_of_Measure__c, Unit_of_Measure_Id__c From Import_Sales_Prices__c LIMIT 5];
        
        Test.startTest();
        try {
            Pagereference pgref = Page.GF_createSalesPrice;
            Test.setCurrentPage(pgref);
            ApexPages.StandardSetController stdrec = new ApexPages.StandardSetController(ISPList);
            GF_ImportSalesPriceController testController = new GF_ImportSalesPriceController(stdrec);
            testController.createSP();
            
            ApexPages.StandardSetController stdrec1 = new ApexPages.StandardSetController(ISPList);
            stdrec1.setSelected(ISPList);
            GF_ImportSalesPriceController testController1 = new GF_ImportSalesPriceController(stdrec1);
            testController1.createSP();
            testController1.massDelete();
            testController1.returnBack();
        } catch(exception e){}
    }
}