/**
 * Created by zon cheng on 8/17/2023.
 */

@IsTest
private class GF_InventoryTest {
    @IsTest
    static void testBehavior() {
        GFERP.CompanyMgmt.systemCall = true;
        Account acc = GF_TestDataUtil.AccountRecord;
        GFERP__Item__c theItem = GF_TestDataUtil.ItemRecord;
        GFERP__Warehouse__c warehouse = GF_TestDataUtil.WarehouseRecord;
        warehouse.FPC_Local_Warehouse__c = true;
        warehouse.Owned_By_Customer__c = acc.Id;
        warehouse.FPC_Local_Warehouse__c = true;
        warehouse.SJP_Warehouse__c = true;
        warehouse.KG_Warehouse__c = true;
        warehouse.BMSI_Warehouse__c = true;
        update warehouse;
        GFERP__Warehouse_Entry__c WarehouseEntryRecord = GF_TestDataUtil.WarehouseEntryRecord;
        GFERP__Item_Ledger_Entry__c ItemLedgerEntryRecord1 = GF_TestDataUtil.ItemLedgerEntryRecord1;
        GFERP__Item_Ledger_Entry__c ItemLedgerEntryRecord2 = GF_TestDataUtil.ItemLedgerEntryRecord2;
        Test.startTest();
        GF_InventoryMgmt.calculateOnHands(new set<Id>{theItem.Id});
        Test.stopTest();
    }
}