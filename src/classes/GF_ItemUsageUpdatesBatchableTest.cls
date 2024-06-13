@isTest
public class GF_ItemUsageUpdatesBatchableTest {

    @testSetup static void makeData(){  
        GFERP__Warehouse__c WareHouseRec = GF_TestDataUtil.WarehouseRecord;
        GFERP__Item__c ItemRec = GF_TestDataUtil.ItemRecord;
        Interplant_Transfer__c IntTransferRec = GF_TestDataUtil.IntTransferRecord;
        Customer_Inventory_Count__c CustomerInvCountRecord = GF_TestDataUtil.CustomerInvCountRecord;
       // GFERP__Item_Ledger_Entry__c ItemLEDEnteryRec = GF_TestDataUtil.ItemLEDEnteryRecord;
        
        GFERP__Company_Setup__c companySetup1 = GF_TestDataUtil.CompanySetupRecord;
        List<GFERP__Company_Setup__c> theCSList = [SELECT Id From GFERP__Company_Setup__c WHERE Id = : companySetup1.Id];
        GFERP__Item_Usage__c iu = new GFERP__Item_Usage__c();
        insert iu;
        
        System.assertEquals(theCSList.size(), 1);
    }
    
    @isTest
    public static void testselected(){
    
        
        Test.StartTest();
        String schedule = '0 0 2 * * ?';
        System.schedule('MyScheduledJob', schedule, new GF_ItemUsageUpdatesSchedulable());
        
        Test.StopTest();
        
    }
    
}