@IsTest
public class GF_ImportSalesPricesUploaderTest {
	@testSetup static void SetupData() {
        //Setup Data
        GFERP__Item__c ItemRec = GF_TestDataUtil.ItemRecord;
        GFERP__Company_Setup__c  testcompanySetup = GF_TestDataUtil.CompanySetupRecord;
        List<GFERP__Company_Setup__c> testCSList = [SELECT Id From GFERP__Company_Setup__c WHERE Id =: testcompanySetup.Id];
        Account accRecord = new Account(Name = 'amazon shipment');
        insert accRecord;
        System.assertEquals(testCSList.size(),1);
    }
    @IsTest
    static void testBehavior() {

        string csvColumnHeader = 'Item,Unit of Measure,Sales Price,Starting Date\n';
        string csvColumnValues = '7002,CS,12,1/1/2023\n';
        string csvFile = csvColumnHeader + csvColumnValues;
        Account accRecord = [SELECT Name FROM Account LIMIT 1];
        Test.startTest();
        try {
            Pagereference pgref = Page.GF_ImportSalesPrices;
            Test.setCurrentPage(pgref);
            ApexPages.StandardSetController stdrec = new ApexPages.StandardSetController(new List<Import_Sales_Prices__c>());
            GF_ImportSalesPricesUploader testController = new GF_ImportSalesPricesUploader(stdrec);
            //testController.accountId = accRecord.Id;
            testController.nameFile = csvFile;
            testController.contentFile = Blob.valueOf(csvFile);
            testController.ReadFile2();
            testController.returnToList();
            testController.SelectFileAndRead2();
            testController.returnBack();
        } catch (Exception e){}

        Test.stopTest();
    }
}