@IsTest
public class GF_ImportPurchasePriceUploaderTest {
	@testSetup static void SetupData() {
        //Setup Data
        GFERP__Company_Setup__c  testcompanySetup = GF_TestDataUtil.CompanySetupRecord;
    }
    
    @IsTest
    static void testBehavior() {

        string csvColumnHeader = 'account,end date,item,uom,minimum quantity,purchase price,starting date,currency\n';
        string csvColumnValues = 'Cannon Group,01/01/2024,7002,Case1,5,6,3/10/2024,USD';
        string csvFile = csvColumnHeader + csvColumnValues;

        Test.startTest();
        try {
            Pagereference pgref = Page.GF_CreatePurchasePrice;
            Test.setCurrentPage(pgref);
            ApexPages.StandardSetController stdrec = new ApexPages.StandardSetController(new List<Import_Purchase_Price__c>());
            GF_ImportPurchasePriceUploader testController = new GF_ImportPurchasePriceUploader(stdrec);
            testController.nameFile = csvFile;
            testController.contentFile = Blob.valueof(csvFile);
            //testController.ReadFile2();
            testController.returnToList();

            testController.SelectFileAndRead2();
        }catch (Exception e){}

        Test.stopTest();
    }
}