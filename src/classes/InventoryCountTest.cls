@IsTest
private class InventoryCountTest {

    @testSetup static void SetupData() {
        GFERP.CompanyMgmt.systemCall = true;
        Account accountRecord = new Account(Name = 'TestCustomer');
        insert accountRecord;
        GFERP__Unit_of_Measure__c UnitMeasureRecord = new GFERP__Unit_of_Measure__c( Name = 'Day', GFERP__Type__c = 'Area' );
        insert UnitMeasureRecord;
        GFERP__Item__c ItemRecord = new GFERP__Item__c(
                Name = '7002',
                GFERP__Description__c = 'Chocolate Cake',
                GFERP__Base_Unit_of_Measure__c = UnitMeasureRecord.Id,
                GFERP__Work_Center__c = false,
                GFERP__Blocked__c = false,
                GFERP__Replenishment_System__c = 'Work Order',
                GFERP__Costing_Method__c = 'Standard',
                //GFERP__Accounting_Posting_Setup__c = 'Use Company Setup',
                GFERP__Inventory_Class__c = 'Finished Goods',
                GFERP__Standard_Base_Cost__c = 1,
                GFERP__Standard_Material_Base_Cost__c = 1,
                GFERP__Standard_Base_Price__c = 10,
                GFERP__Item_Type__c = 'Inventory'
        );
        insert ItemRecord;
        Customer_Inventory_Count__c newCIC = new Customer_Inventory_Count__c();
        insert newCIC;
        Customer_Inventory_Count__c newCIC2 = new Customer_Inventory_Count__c(Customer__c = accountRecord.Id, Item_No__c = ItemRecord.Id, Week_End_Date__c = Date.today().toStartOfWeek().addDays(-1), Count_Qty__c = 10);
        insert newCIC2;

        Interplant_Transfer__c newIT = new Interplant_Transfer__c(Item__c = ItemRecord.Id, From_Customer__c = accountRecord.Id, To_Customer__c = accountRecord.Id, Transfer_Date__c = Date.today().toStartOfWeek().addDays(-1), Quantity__c = 1);
        insert newIT;
    }

    @IsTest
    static void testBehavior() {
        Test.startTest();
        List<Customer_Inventory_Count__c> theList = [SELECT Name FROM Customer_Inventory_Count__c WHERE Item_No__c = null];
        ApexPages.StandardSetController controller = new ApexPages.StandardSetController(theList);
        controller.setSelected(theList);
        CustomerInventoryCountController theCon = new CustomerInventoryCountController(controller);
        theCon.massDelete();
        theCon.returnBack();

        Database.executeBatch(new CalculateWeekUsage(), 100);
        Test.stopTest();
    }
}