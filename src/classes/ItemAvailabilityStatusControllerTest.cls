@IsTest
private class ItemAvailabilityStatusControllerTest {
    @testSetup
    private static void SetupData() {
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
                GFERP__Accounting_Posting_Setup__c = 'Use Company Setup',
                GFERP__Inventory_Class__c = 'Finished Goods',
                GFERP__Standard_Base_Cost__c = 1,
                GFERP__Standard_Material_Base_Cost__c = 1,
                GFERP__Standard_Base_Price__c = 10,
                GFERP__Item_Type__c = 'Inventory'
        );
        insert ItemRecord;
        GFERP__Item_Unit_of_Measure__c ItemUnitMeasureRecord = new GFERP__Item_Unit_of_Measure__c(
                GFERP__Conversion__c = 1,
                GFERP__Item__c = ItemRecord.Id,
                GFERP__Unit_of_Measure__c = UnitMeasureRecord.Id
        );
        insert ItemUnitMeasureRecord;
    }

    @IsTest
    private static void testBehavior1() {
        List<GFERP__Item__c> itemList = [SELECT Name FROM GFERP__Item__c];
        List<GFERP__Item_Unit_of_Measure__c> iuoms = [SELECT Name FROM GFERP__Item_Unit_of_Measure__c];
        Pagereference pgref = Page.ItemAvailProjection;
        Test.setCurrentPage(pgref);
        Test.startTest();
        ApexPages.StandardSetController StdCon = new ApexPages.StandardSetController(itemList);
        ItemAvailabilityStatusController instance  = new ItemAvailabilityStatusController (StdCon);
        List<SelectOption> lstFilterField = instance.lstFilterField;
        lstFilterField = instance.lstFilterOperator;
        lstFilterField = instance.lstFilterField2;
        lstFilterField = instance.lstFilterOperator2;
        lstFilterField = instance.lstfilterInput2;
        lstFilterField = instance.lstFilterField3;
        lstFilterField = instance.lstFilterOperator3;
        lstFilterField = instance.lstfilterInput3;
        lstFilterField = instance.lstFilterField4;
        lstFilterField = instance.lstFilterOperator4;
        lstFilterField = instance.lstfilterInput4;
        lstFilterField = instance.lstFilterOperator5;
        lstFilterField = instance.lstFilterField5;
        lstFilterField = instance.getPageSizeSelectOptions();
        lstFilterField = instance.getSortBySelectOptionsOptions();
        String paginationStat = instance.paginationStat;
        paginationStat = instance.sortExpression;
        instance.Next();
        instance.First();
        instance.Last();
        instance.Previous();
        String te = instance.paginationStat;
        Boolean isTrue = instance.hasRecords;
        isTrue = instance.hasNext;
        isTrue = instance.hasPrevious;
        Integer intValue = instance.pageNumber;

        instance.SelNum='0';
        instance.getQPOinfo();
        //instance.UOM='';
        instance.getQPOinfo();

        //instance.UOM = iuoms[0].Name;
        instance.SelNum = '6';
        instance.getQPOinfo();
        //instance.UOM='';
        instance.getQPOinfo();

        //instance.UOM = iuoms[0].Name;
        instance.SelNum = '1';
        instance.getQPOinfo();
        //instance.UOM='';
        instance.getQPOinfo();
        instance.getQSOinfo();
        instance.getCustomerQTYinfo();
        instance.getLocalQTYinfo();
        instance.getVendorQTYinfo();
        instance.Infoby();
        List<ItemAvailabilityStatusController.wrapItem> wrapList = instance.lstWItem;
        instance.ExportToExcel();
        instance.selFilterField = 'Name';
        instance.filterInput = '456';
        instance.selFilterOp = 'not equals';
        instance.search();

        ItemAvailabilityStatusController newCon = new ItemAvailabilityStatusController();
        Test.stopTest();
    }
}