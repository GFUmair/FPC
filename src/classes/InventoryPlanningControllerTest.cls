@IsTest
private class InventoryPlanningControllerTest {
    @testSetup static void SetupData() {
        GFERP.CompanyMgmt.systemCall = true;
        Account accountRecord = new Account(Name = 'TestCustomer');
        insert accountRecord;
        GFERP__Warehouse__c WarehouseRecord = new GFERP__Warehouse__c(Name = 'Blue', Owned_By_Customer__c = accountRecord.Id);
        insert WarehouseRecord;
        GFERP__Bin_Type__c BinTypeShipRecord = new GFERP__Bin_Type__c(Name = 'Ship', GFERP__Ship__c = true);
        insert BinTypeShipRecord;
        GFERP__Bin__c BinRecord = new GFERP__Bin__c(
            Name = 'Ship',
            GFERP__Bin_Type__c = BinTypeShipRecord.Id,
            GFERP__Warehouse__c = WareHouseRecord.Id
        );
        insert BinRecord;
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
    }

    @IsTest
    static void testBehavior() {
        List<GFERP__Item__c> itemtList = [SELECT Name FROM GFERP__Item__c];
        List<Account> accList = [Select Name From Account];
        Test.startTest();
//        try {
            Pagereference pgref = Page.InventoryPlanningReport;
            Test.setCurrentPage(pgref);
            ApexPages.StandardSetController stdrec = new ApexPages.StandardSetController(itemtList);
            InventoryPlanningController testController = new InventoryPlanningController(stdrec);
            testController.selectedCustomers.add(accList[0].Id);
            testController.selectCustomerRefreshTheReport();
            testController.itemSearchKey = '7002';
            testController.searchInTheList();
            testController.Beginning();
            testController.Previous();
            testController.Next();
            testController.End();
            Integer intValue = testController.getTotalSize();
            intValue = testController.getFromCounter();
            intValue = testController.getToCounter();
            Boolean isTrue = testController.getDisablePrevious();
            isTrue = testController.getDisableNext();
            List<SelectOption> options = testController.getPageSizeSelectOptions();
            options = testController.getLowWeekSelectOptions();
            options = testController.lstFilterOperator;
            options = testController.getSortBySelectOptionsOptions();
            String testVal = testController.sortExpression;
            testVal = testController.getSortDirection();
            testController.selectedLowWeek = 'from4to12';
            testController.filterOnLowWeeks();
            testController.selectedLowWeek = 'lessThan4';
            testController.filterOnLowWeeks();
        testController.reportingDate = Date.today();
        testController.local3PLWhseIds = new Set<Id>();

            testController.ExportToExcel();

        testController.selFilterOp = 'not equals';
        testController.itemNoInput = 'testitem';
        testController.initItemLineTable();

            InventoryPlanningController theCon = new InventoryPlanningController();
//        } catch (Exception e){}
        Test.stopTest();
    }

    @IsTest
    static void testBehavior2() {
        List<GFERP__Item__c> itemtList = [SELECT Name FROM GFERP__Item__c];
        List<Account> accList = [Select Name From Account];
        Test.startTest();
        Pagereference pgref = Page.InventoryPlanningReport;
        Test.setCurrentPage(pgref);
        ApexPages.StandardSetController stdrec = new ApexPages.StandardSetController(itemtList);
        InventoryPlanningController testController = new InventoryPlanningController(stdrec);
        testController.selectedCustomers.add(accList[0].Id);
        testController.selectCustomerRefreshTheReport();
        testController.sortExp = 'LocalOnHand';
        testController.filterOnLowWeeks();
        testController.viewItem = itemtList[0].Id;
        testController.viewBeginCounts();
        testController.refreshBeginCounts();
        testController.viewEndCounts();
        testController.refreshEndCounts();
        testController.convertToString();
//        testController.selectedVendor = new List()
//        testController.initItemLineTable();

        Test.stopTest();
    }
}