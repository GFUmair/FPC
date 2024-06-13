@IsTest
private class ImportInventory_CustomUploaderTest {
    @testSetup static void SetupData() {
        //GFERP__Company_Setup__c  testcompanySetup = TestDataUtil.CompanySetupRecord;
        GFERP.CompanyMgmt.systemCall = true;
        GFERP__Warehouse__c WarehouseRecord = new GFERP__Warehouse__c(Name = 'Blue');
        insert WarehouseRecord;
        GFERP__Bin_Type__c BinTypeShipRecord = new GFERP__Bin_Type__c(Name = 'Ship', GFERP__Ship__c = true);
        insert BinTypeShipRecord;
        GFERP__Bin__c BinRecord = new GFERP__Bin__c(
            Name = 'Ship',
            GFERP__Bin_Type__c = BinTypeShipRecord.Id,
            GFERP__Warehouse__c = WareHouseRecord.Id
        );
        insert BinRecord;
        
        GFCON__Import_Inventory2__c ImportInventoryRecord = new GFCON__Import_Inventory2__c (
            GFCON__Quantity__c = 10,
            GFCON__Unit_Cost__c = 10,
            GFCON__Posting_date__c = Date.today(),
            GFCON__Bin__c = BinRecord.Name,
            GFCON__Unit_of_Measure__c = 'CS',
            GFCON__Warehouse__c = WarehouseRecord.Name,
            GFCON__Processed__c = false,
            GFCON__Lot_Manufacture_Date__c = System.Today(),
            GFCON__Lot_Expiration_Date__c = System.Today() + 70
        );
        insert ImportInventoryRecord;
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
    }

    @IsTest
    static void testBehavior() {
        List<GFCON__Import_Inventory2__c > testAccountList = [SELECT Name FROM GFCON__Import_Inventory2__c ];
        string csvColumnHeader = '1, 2, 3, 4, 5, 6,7,8,9,10,11,12\n';
        string csvColumnValues = '1, 2, 3, 4, 5,6.00,7.00,3/10/2019,3/10/2020,10,"11",12\n';
        csvColumnValues += 'Blue,7002, 3, 4, 5,6.00,7.00,3/10/2019,3/10/2020,10,"11",12\n';
        string csvFile = csvColumnHeader + csvColumnValues;

        Test.startTest();
        try {
            Pagereference pgref = Page.ImportInventoryCSV_Custom;
            Test.setCurrentPage(pgref);
            ApexPages.StandardSetController stdrec = new ApexPages.StandardSetController(testAccountList);
            ImportInventoryUploader_Custom testController = new ImportInventoryUploader_Custom (stdrec);
            testController.nameFile = csvFile;
            testController.ReadFile();
            testController.getImportInventoryList();
            testController.returnToList();

            testController.SelectFileAndRead();
        }catch (Exception e){}

        Test.stopTest();
    }
}