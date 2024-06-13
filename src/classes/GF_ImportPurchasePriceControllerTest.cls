@IsTest
public class GF_ImportPurchasePriceControllerTest {
	@testSetup static void SetupData() {
        //Setup Data
        GFERP__Company_Setup__c  testcompanySetup = GF_TestDataUtil.CompanySetupRecord;
        Account AccountRecord = GF_TestDataUtil.AccountRecord;
        GFERP__Currency__c CurrencyRecord = GF_TestDataUtil.CurrencyRecord;
        GFERP__Item__c ItemRecord = GF_TestDataUtil.ItemRecord;
        GFERP__Cross_Reference__c CrossReferenceRecord = CrossReferenceRecord1;
        CrossReferenceRecord.GFERP__Blocked__c = false;
        update CrossReferenceRecord;
    }
    
    @IsTest
    static void testBehavior() {
        Import_Purchase_Price__c ImportPurchasePriceRecord = ImportPurchasePriceRecord;
        Import_Purchase_Price__c ImportPurchasePriceRecord1 = ImportPurchasePriceRecord1;
        Import_Purchase_Price__c ImportPurchasePriceRecord2 = ImportPurchasePriceRecord2;
        Pagereference pgref = Page.GF_CreatePurchasePrice;
        Test.setCurrentPage(pgref);
        ApexPages.StandardSetController stdrec = new ApexPages.StandardSetController(new List<Import_Purchase_Price__c>{ImportPurchasePriceRecord1});
        stdrec.setSelected(new List<Import_Purchase_Price__c>{ImportPurchasePriceRecord1});
        GF_ImportPurchasePriceController testController = new GF_ImportPurchasePriceController(stdrec);
        
        testController.importPurchaseOrder();
        testController.returnBack();
        testController.massDelete();
        
        ApexPages.StandardSetController stdrec1 = new ApexPages.StandardSetController(new List<Import_Purchase_Price__c>{ImportPurchasePriceRecord2});
        stdrec1.setSelected(new List<Import_Purchase_Price__c>{ImportPurchasePriceRecord2});
        GF_ImportPurchasePriceController testController1 = new GF_ImportPurchasePriceController(stdrec1);
        
        testController1.importPurchaseOrder();
        testController1.returnBack();
        testController1.massDelete();
        
        ApexPages.StandardSetController stdrec2 = new ApexPages.StandardSetController(new List<Import_Purchase_Price__c>{ImportPurchasePriceRecord});
        stdrec2.setSelected(new List<Import_Purchase_Price__c>{ImportPurchasePriceRecord});
        GF_ImportPurchasePriceController testController2 = new GF_ImportPurchasePriceController(stdrec2);
        
        testController2.importPurchaseOrder();
        testController2.returnBack();
        testController2.massDelete();
        
    }
    
    Public static Import_Purchase_Price__c ImportPurchasePriceRecord {
        get{
            if (ImportPurchasePriceRecord == null) {
                ImportPurchasePriceRecord = new Import_Purchase_Price__c(
                    Account__c = 'Cannon Group',
                    End_Date__c = system.today().addDays(5),
                    Item__c = '7002',
                    Unit_of_Measure__c = 'CS',
                    Minimum_Quantity__c = 5,
                    Purchase_Price__c = 5,
                    Starting_Date__c = system.today().addDays(1),
                    Currency_Code__c = 'USD'
                );
                insert ImportPurchasePriceRecord;
            }
            return ImportPurchasePriceRecord;
        } private set;
    }
    Public static Import_Purchase_Price__c ImportPurchasePriceRecord1 {
        get{
            if (ImportPurchasePriceRecord1 == null) {
                ImportPurchasePriceRecord1 = new Import_Purchase_Price__c(
                    Account__c = '',
                    Item__c = '',
                    Unit_of_Measure__c = '',
                    Currency_Code__c = ''
                );
                insert ImportPurchasePriceRecord1;
            }
            return ImportPurchasePriceRecord1;
        } private set;
    }
    Public static Import_Purchase_Price__c ImportPurchasePriceRecord2 {
        get{
            if (ImportPurchasePriceRecord2 == null) {
                ImportPurchasePriceRecord2 = new Import_Purchase_Price__c(
                    Account__c = 's',
                    Item__c = 's',
                    Unit_of_Measure__c = 's',
                    Currency_Code__c = 's'
                );
                insert ImportPurchasePriceRecord2;
            }
            return ImportPurchasePriceRecord2;
        } private set;
    }
    public static GFERP__Cross_Reference__c CrossReferenceRecord1 {
        get {
            if (CrossReferenceRecord1 == null) {
                CrossReferenceRecord1 = new GFERP__Cross_Reference__c(
                        GFERP__Account__c = GF_TestDataUtil.AccountRecord.Id,
                        GFERP__Item__c = GF_TestDataUtil.ItemRecord.Id,
                        GFERP__Unit_of_Measure__c = GF_TestDataUtil.ItemRecord.GFERP__Sales_Unit_of_Measure__c,
                        GFERP__Cross_Referece_No__c = '7002',
                        GFERP__Default_Sales_UOM_for_Customer__c = true
                );

                    insert CrossReferenceRecord1;
            
            }
            return CrossReferenceRecord1;
        }
        private set;
    }
}