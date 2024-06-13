@IsTest
private class MonthEndReconciliationCustomTest {
     @testSetup
    private static void SetupData() {
        GFERP.CompanyMgmt.systemCall = true;
        Account accountRecord = new Account(Name = 'TestCustomer');
        insert accountRecord;
        GFERP__Warehouse__c WarehouseRecord = new GFERP__Warehouse__c(Name = 'Blue', Owned_By_Customer__c = accountRecord.Id, FPC_Local_Warehouse__c = true);
        insert WarehouseRecord;
        GFERP__Warehouse__c WarehouseRecord2 = new GFERP__Warehouse__c(Name = 'Blue2', FPC_Vendor_Warehouse__c = true);
        insert WarehouseRecord2;
        GFERP__Warehouse__c WarehouseRecord3 = new GFERP__Warehouse__c(Name = 'Blue3');
        insert WarehouseRecord3;
        GFERP__Bin_Type__c BinTypeShipRecord = new GFERP__Bin_Type__c(Name = 'Ship', GFERP__Ship__c = true);
        insert BinTypeShipRecord;
        GFERP__Bin__c BinRecord = new GFERP__Bin__c(Name = 'Ship',GFERP__Bin_Type__c = BinTypeShipRecord.Id,GFERP__Warehouse__c = WareHouseRecord.Id);
        insert BinRecord;
        GFERP__Bin__c BinRecord2 = new GFERP__Bin__c(Name = 'Ship',GFERP__Bin_Type__c = BinTypeShipRecord.Id,GFERP__Warehouse__c = WareHouseRecord2.Id);
        insert BinRecord2;
        GFERP__Bin__c BinRecord3 = new GFERP__Bin__c(Name = 'Ship',GFERP__Bin_Type__c = BinTypeShipRecord.Id,GFERP__Warehouse__c = WareHouseRecord3.Id);
        insert BinRecord3;
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
                GFERP__Inventory_Class__c = 'Finished Goods',
                GFERP__Standard_Base_Cost__c = 1,
                GFERP__Standard_Material_Base_Cost__c = 1,
                GFERP__Standard_Base_Price__c = 10,
                GFERP__Item_Type__c = 'Inventory'
        );
        insert ItemRecord;
        GFERP__Item_Unit_of_Measure__c ItemUnitMeasureRecord = new GFERP__Item_Unit_of_Measure__c(GFERP__Conversion__c = 1,GFERP__Item__c = ItemRecord.Id,GFERP__Unit_of_Measure__c = UnitMeasureRecord.Id);
        insert ItemUnitMeasureRecord;
        GFERP__Item_Lot__c ItemLotRecord = new GFERP__Item_Lot__c(
                        Name = 'Lot10987',
                        GFERP__Item__c = ItemRecord.Id,
                        GFERP__Test_Status__c = 'Accept',
                        GFERP__Expiration_Date__c = Date.Today().addDays(7),
                        GFERP__Manufacture_Date__c = Date.Today()
                );
                insert ItemLotRecord;
        GFERP__GL_Account__c GLAccountRecord = new GFERP__GL_Account__c(
            Name = '13100'
        );
        GFERP__GL_Account__c GLAccountRecord2 = new GFERP__GL_Account__c(
            Name = '53100'
        );
        insert GLAccountRecord;
        insert GLAccountRecord2;
        GFERP__Currency__c CurrencyRecord = new GFERP__Currency__c( Name = 'USD' );
        insert CurrencyRecord;
        GFERP__Payment_Term__c PaymentTermRecord = new GFERP__Payment_Term__c(
                        Name = '14 DAYS',
                        GFERP__Discount_Pct__c = 0,
                        GFERP__Discount_Date_Calculation__c = 0,
                        GFERP__Due_Date_Calculation__c = 0
                );
        insert PaymentTermRecord;
        GFERP__Company_Setup__c CompanySetupRecord = new GFERP__Company_Setup__c(
            Name = 'FPC',
            GFERP__Days_to_Receive__c = 7,
            GFERP__Days_to_Ship__c = 2,
            GFERP__Lines_to_Insert__c = 5,
            GFERP__Lot_Days_to_Expire__c = 365,
            GFERP__Payment_Term__c = PaymentTermRecord.Id,
            GFERP__Currency__c = CurrencyRecord.Id,
            GFERP__Warehouse__c = WarehouseRecord.Id,
            GFERP__Allow_Posting_From__c = Date.newInstance(2015, 1, 1),
            GFERP__Allow_Posting_To__c = Date.newInstance(2019, 1, 1),
            GFERP__Account_AP__c = GLAccountRecord.Id,
            GFERP__Account_AR__c = GLAccountRecord.Id,
            GFERP__Account_Capacity_Expense__c = GLAccountRecord.Id,
            GFERP__Account_Capacity_Variance__c = GLAccountRecord.Id,
            GFERP__Account_Finished_Good_Inventory__c = GLAccountRecord.Id,
            GFERP__Account_Inventory_Adjustment__c = GLAccountRecord.Id,
            GFERP__Account_Material_Variance__c = GLAccountRecord.Id,
            GFERP__Account_Purchase_Price_Variance__c = GLAccountRecord.Id,
            GFERP__Account_WIP_Inventory__c = GLAccountRecord.Id,
            GFERP__Account_Sales_Tax_Payable__c = GLAccountRecord.Id,
            GFERP__Account_Raw_Material_Inventory__c = GLAccountRecord.Id,
            Account_Accrued_AP_Id__c = GLAccountRecord2.Id,
            Account_Default_Sales_Id__c = GLAccountRecord.Id,
            Account_Default_COGS_Id__c = GLAccountRecord.Id,
            GFERP__Enable_Bypass_Shipment__c = true
        );
        insert CompanySetupRecord;
         GFERP__Demand_Planning_Setup__c DemandPlanningSetup = new GFERP__Demand_Planning_Setup__c(
                 Name = 'Default',
                 GFERP__Consolidate_Planning_to_Warehouse__c = WarehouseRecord.Id,
                 GFERP__Periods_to_Forecast__c = 12,
                 GFERP__Periods_to_Re_Forecast__c = 12
         );
         insert DemandPlanningSetup;
        GFERP__Numbering_Series__c theNS;
                List<GFERP__Numbering_Series__c> theNSList = new List<GFERP__Numbering_Series__c>();

                theNS = new GFERP__Numbering_Series__c();
                theNS.Name = 'Purchase Credit Memo';
                theNS.GFERP__Prefix__c = 'PM';
                theNS.GFERP__Separator__c = '-';
                theNS.GFERP__Last_Number_Used__c = 1000000;
                theNSList.add(theNS);

                theNS = new GFERP__Numbering_Series__c();
                theNS.Name = 'Purchase Invoice';
                theNS.GFERP__Prefix__c = 'PI';
                theNS.GFERP__Separator__c = '-';
                theNS.GFERP__Last_Number_Used__c = 1000000;
                theNSList.add(theNS);

                theNS = new GFERP__Numbering_Series__c();
                theNS.Name = 'Purchase Invoice Temp';
                theNS.GFERP__Prefix__c = 'Temp';
                theNS.GFERP__Separator__c = '-';
                theNS.GFERP__Last_Number_Used__c = 1000000;
                theNSList.add(theNS);

                theNS = new GFERP__Numbering_Series__c();
                theNS.Name = 'Purchase Order';
                theNS.GFERP__Prefix__c = 'PO';
                theNS.GFERP__Separator__c = '-';
                theNS.GFERP__Last_Number_Used__c = 1000000;
                theNSList.add(theNS);

                theNS = new GFERP__Numbering_Series__c();
                theNS.Name = 'Return Purchase Order';
                theNS.GFERP__Prefix__c = 'RPO';
                theNS.GFERP__Separator__c = '-';
                theNS.GFERP__Last_Number_Used__c = 1000000;
                theNSList.add(theNS);

                theNS = new GFERP__Numbering_Series__c();
                theNS.Name = 'Sales Invoice';
                theNS.GFERP__Prefix__c = 'SI';
                theNS.GFERP__Separator__c = '-';
                theNS.GFERP__Last_Number_Used__c = 1000000;
                theNSList.add(theNS);

                theNS = new GFERP__Numbering_Series__c();
                theNS.Name = 'Warehouse Receipt';
                theNS.GFERP__Prefix__c = 'WR';
                theNS.GFERP__Separator__c = '-';
                theNS.GFERP__Last_Number_Used__c = 1000000;
                theNSList.add(theNS);

                theNS = new GFERP__Numbering_Series__c();
                theNS.Name = 'Warehouse Shipment';
                theNS.GFERP__Prefix__c = 'WS';
                theNS.GFERP__Separator__c = '-';
                theNS.GFERP__Last_Number_Used__c = 1000000;
                theNSList.add(theNS);

         theNS = new GFERP__Numbering_Series__c();
         theNS.Name = 'Sales Invoice';
         theNS.GFERP__Prefix__c = 'SI';
         theNS.GFERP__Separator__c = '-';
         theNS.GFERP__Last_Number_Used__c = 1000000;
         theNSList.add(theNS);

         theNS = new GFERP__Numbering_Series__c();
         theNS.Name = 'Sales Invoice Temp';
         theNS.GFERP__Prefix__c = 'Temp';
         theNS.GFERP__Separator__c = '-';
         theNS.GFERP__Last_Number_Used__c = 1000000;
         theNSList.add(theNS);

                insert theNSList;

         List<GFERP__Bin_Content__c> binContents = new List<GFERP__Bin_Content__c>();
        GFERP__Bin_Content__c BinContentRecord = new GFERP__Bin_Content__c(
                        GFERP__Item__c = ItemRecord.Id,
                        GFERP__Unit_of_Measure__c = ItemUnitMeasureRecord.Id,
                        GFERP__Warehouse__c = WarehouseRecord.Id,
                        GFERP__Bin__c = BinRecord.Id,
                        GFERP__Item_Lot__c = ItemLotRecord.Id
                );
         binContents.add(BinContentRecord);
        GFERP__Bin_Content__c BinContentRecord2 = new GFERP__Bin_Content__c(
                        GFERP__Item__c = ItemRecord.Id,
                        GFERP__Unit_of_Measure__c = ItemUnitMeasureRecord.Id,
                        GFERP__Warehouse__c = WarehouseRecord2.Id,
                        GFERP__Bin__c = BinRecord2.Id,
                        GFERP__Item_Lot__c = ItemLotRecord.Id
                );
         binContents.add(BinContentRecord2);
        GFERP__Bin_Content__c BinContentRecord3 = new GFERP__Bin_Content__c(
                        GFERP__Item__c = ItemRecord.Id,
                        GFERP__Unit_of_Measure__c = ItemUnitMeasureRecord.Id,
                        GFERP__Warehouse__c = WarehouseRecord3.Id,
                        GFERP__Bin__c = BinRecord3.Id,
                        GFERP__Item_Lot__c = ItemLotRecord.Id
                );
         binContents.add(BinContentRecord3);
         insert binContents;
        GFERP__Purchase_Order__c PORecord = new GFERP__Purchase_Order__c(
                        Name = 'test',
                        GFERP__Buy_from_Vendor2__c = AccountRecord.Id,
                        GFERP__Pay_to_Vendor__c = AccountRecord.Id,
                        GFERP__Expected_Receipt_Date__c = Date.today(),
                        GFERP__Warehouse__c = WarehouseRecord.Id,
                        GFERP__Currency2__c = CurrencyRecord.Id,
                        GFERP__Payment_Term__c = PaymentTermRecord.Id,
                        GFERP__Order_date__c = Date.today()
                );
        insert PORecord;
        GFERP__Purchase_Line__c PurchLineRecord = new GFERP__Purchase_Line__c(
                        GFERP__Purchase_Order__c = PORecord.Id,
                        GFERP__Warehouse__c = WarehouseRecord.Id,
                        GFERP__Item__c = ItemRecord.Id,
                        GFERP__Quantity__c = 2,
                        GFERP__Qty_Base__c = 2,
                        GFERP__Conversion__c = 1,
                        GFERP__Unit_of_Measure__c = ItemUnitMeasureRecord.Id,
                        GFERP__Received_Qty__c = 1,
                        GFERP__Received_Qty_Base__c = 1,
                        GFERP__Invoiced_Qty__c = 0,
                        GFERP__Unit_Cost__c = 20,
                        GFERP__Line_Cost__c = 40,
                        GFERP__Expected_Receipt_Date__c = Date.Today().addDays(7)
                );
        insert PurchLineRecord;
        GFERP__Whse_Receipt__c WhseReceiptRecord = new GFERP__Whse_Receipt__c(
                        Name = 'Test',
                        GFERP__Purchase_Order__c = PORecord.Id,
                        GFERP__Warehouse__c = WarehouseRecord.Id,
                        GFERP__Buy_from_Vendor__c = AccountRecord.Id,
                        GFERP__Document_Status__c = 'Open',
                        GFERP__Expected_Receipt_Date__c = Date.Today().addDays(7),
                        GFERP__Actual_Receipt_Date__c = Date.Today(),
                        GFERP__Posting_Date__c = Date.today(),
                        GFERP__Currency__c = CurrencyRecord.Id
                );
        insert WhseReceiptRecord;
        GFERP__Whse_Receipt_Line__c WhseReceiptLineRecord = new GFERP__Whse_Receipt_Line__c(
                        GFERP__Receipt__c = WhseReceiptRecord.Id,
                        GFERP__Warehouse__c = WarehouseRecord.Id,
                        GFERP__Item__c = ItemRecord.Id,
                        GFERP__Quantity__c = 1,
                        GFERP__Qty_Base__c = 1,
                        GFERP__Conversion__c = 1,
                        GFERP__Lot_Tracked__c = true,
                        GFERP__Unit_of_Measure__c = ItemUnitMeasureRecord.Id,
                        GFERP__Bin__c = BinRecord.Id,
                        GFERP__Expected_Receipt_Date__c = Date.Today().addDays(7),
                        GFERP__Purchase_Line__c = PurchLineRecord.Id,
                        GFERP__Bin_Content__c = BinContentRecord.Id
                );
        insert WhseReceiptLineRecord;
        GFERP__Purchase_Invoice__c PurchInvoiceRecord = new GFERP__Purchase_Invoice__c(
                        GFERP__Purchase_Order__c = POrecord.Id,
                        GFERP__Buy_from_Vendor__c = AccountRecord.Id,
                        GFERP__Pay_to_Vendor__c = AccountRecord.Id,
                        GFERP__Currency2__c = CurrencyRecord.Id,
                        GFERP__Payment_Term__c = PaymentTermRecord.Id,
                        GFERP__Actual_Receipt_Date__c = Date.Today(),
                        GFERP__Posting_Date__c = Date.Today(),
                        GFERP__Document_Status__c = 'Open',
                        GFERP__Due_Date__c = Date.Today().addDays(7),
                        GFERP__Invoice_Date__c = Date.Today(),
                        GFERP__Order_Date__c = Date.Today(),
                        GFERP__Payment_Discount_Date__c = Date.Today(),
                        GFERP__Vendor_Invoice_No__c = '1234',
                        GFERP__Payment_Discount_Pct__c = 10
                );
        insert PurchInvoiceRecord;
        PurchInvoiceRecord.GFERP__Document_Status__c = 'Posted';
        update PurchInvoiceRecord;
        GFERP__Purchase_Invoice_Line__c PurchInvLineRecord = new GFERP__Purchase_Invoice_Line__c(
                        GFERP__Purchase_Invoice__c = PurchInvoiceRecord.Id,
                        GFERP__Item__c = ItemRecord.Id,
                        GFERP__Quantity__c = 1,
                        GFERP__Qty_Base__c = 1,
                        GFERP__Conversion__c = 1,
                        GFERP__Unit_of_Measure__c = ItemUnitMeasureRecord.Id,
                        GFERP__Unit_Cost__c = 10,
                        GFERP__Line_Cost__c = 10,
                        GFERP__Purchase_Line__c = PurchLineREcord.Id,
                        GFERP__Receipt_Line__c = WhseReceiptLineRecord.Id
                );
                insert PurchInvLineRecord;
         GFERP__Tax_Area__c TaxAreaRecord = new GFERP__Tax_Area__c (Name = 'NOTAX');
         insert TaxAreaRecord;
         GFERP__Sales_Invoice__c SalesInvoiceRecord = new GFERP__Sales_Invoice__c(
                 GFERP__Sell_to_Customer__c = AccountRecord.Id,
                 GFERP__Bill_to_Customer__c = AccountRecord.Id,
                 GFERP__Actual_Shipment_Date__c = Date.Today() + 100,
                 GFERP__Customer_PO_No__c = '111222',
                 GFERP__Document_Status__c = 'Open',
                 GFERP__Order_Date__c = Date.Today(),
                 GFERP__Invoice_Date__c = date.today() + 100,
                 GFERP__Posting_Date__c = date.today() + 100,
                 GFERP__Payment_Term__c = PaymentTermRecord.Id,
                 GFERP__Currency__c = CurrencyRecord.Id,
                 GFERP__Currency_Factor__c = 1,
                 GFERP__Tax_Area__c = TaxAreaRecord.Id,
                 GFERP__Warehouse__c = WarehouseRecord.Id,
                 GFERP__Due_Date__c = Date.today().addDays(7),
                 GFERP__Bypass_Shipment__c = true
         );
         insert SalesInvoiceRecord;
         GFERP__Item_Ledger_Entry__c ItemLedgerEntryRecord = new GFERP__Item_Ledger_Entry__c(
                        GFERP__Item__c = ItemRecord.Id,
                        GFERP__Account__c = AccountRecord.Id,
                        GFERP__Bin__c = Binrecord.Id,
                        GFERP__Bin_Content__c = BinContentRecord.Id,
                        GFERP__Conversion__c = 1,
                        GFERP__Document_No__c = '123',
                        GFERP__Document_Type__c = 'Shipment',
                        GFERP__Whse_Receipt_Line__c = WhseReceiptLineRecord.Id,
                        GFERP__Item_Lot__c = ItemLotRecord.Id,
                        GFERP__Posting_Date__c = Date.today(),
                        GFERP__Qty_Base__c = 10,
                        GFERP__Quantity__c = 10,
                        GFERP__Remaining_Qty_Base__c = 0,
                        GFERP__Unit_of_Measure__c = ItemUnitMeasureRecord.Id,
                        GFERP__Warehouse__c = WarehouseRecord.Id
                );
                insert ItemLedgerEntryRecord;
        GFERP__Item_Ledger_Entry__c ItemLedgerEntryRecord2 = new GFERP__Item_Ledger_Entry__c(
                        GFERP__Item__c = ItemRecord.Id,
                        GFERP__Account__c = AccountRecord.Id,
                        GFERP__Bin__c = Binrecord2.Id,
                        GFERP__Bin_Content__c = BinContentRecord2.Id,
                        GFERP__Conversion__c = 1,
                        GFERP__Document_No__c = '123',
                        GFERP__Document_Type__c = 'Shipment',
                        GFERP__Whse_Receipt_Line__c = WhseReceiptLineRecord.Id,
                        GFERP__Item_Lot__c = ItemLotRecord.Id,
                        GFERP__Posting_Date__c = Date.today(),
                        GFERP__Qty_Base__c = 10,
                        GFERP__Quantity__c = 10,
                        GFERP__Remaining_Qty_Base__c = 0,
                        GFERP__Unit_of_Measure__c = ItemUnitMeasureRecord.Id,
                        GFERP__Warehouse__c = WarehouseRecord2.Id
                );
                insert ItemLedgerEntryRecord2;
        GFERP__Item_Ledger_Entry__c ItemLedgerEntryRecord3 = new GFERP__Item_Ledger_Entry__c(
                        GFERP__Item__c = ItemRecord.Id,
                        GFERP__Account__c = AccountRecord.Id,
                        GFERP__Bin__c = Binrecord3.Id,
                        GFERP__Bin_Content__c = BinContentRecord3.Id,
                        GFERP__Conversion__c = 1,
                        GFERP__Document_No__c = '1234',
                        GFERP__Document_Type__c = 'Shipment',
                        GFERP__Whse_Receipt_Line__c = WhseReceiptLineRecord.Id,
                        GFERP__Item_Lot__c = ItemLotRecord.Id,
                        GFERP__Posting_Date__c = Date.today(),
                        GFERP__Qty_Base__c = 10,
                        GFERP__Quantity__c = 10,
                        GFERP__Remaining_Qty_Base__c = 0,
                        GFERP__Unit_of_Measure__c = ItemUnitMeasureRecord.Id,
                        GFERP__Warehouse__c = WarehouseRecord3.Id
                );
                insert ItemLedgerEntryRecord3;
         List<GFERP__Cost_Entry__c> costEntries = new List<GFERP__Cost_Entry__c>();
        GFERP__Cost_Entry__c CostEntryRecord = new GFERP__Cost_Entry__c(
                GFERP__Purchase_Invoice__c = PurchInvoiceRecord.Id,
                GFERP__Item__c = ItemRecord.Id,
                GFERP__Invoiced_Cost__c = 100,
                GFERP__Sales_Invoice__c = SalesInvoiceRecord.Id,
                GFERP__Expected_Cost__c = 120,
                GFERP__Cost_Adjustment__c = true,
                GFERP__Cost_Posted__c = false,
                GFERP__Posting_Date__c = Date.today().addMonths(-1),
                GFERP__Item_Ledger_Entry__c = ItemLedgerEntryRecord.Id
            );
         costEntries.add(CostEntryRecord);
        GFERP__Cost_Entry__c CostEntryRecord2 = new GFERP__Cost_Entry__c(
                GFERP__Purchase_Invoice__c = PurchInvoiceRecord.Id,
                GFERP__Item__c = ItemRecord.Id,
                GFERP__Invoiced_Cost__c = 100,
                GFERP__Sales_Invoice__c = SalesInvoiceRecord.Id,
                GFERP__Expected_Cost__c = 120,
                GFERP__Cost_Adjustment__c = true,
                GFERP__Cost_Posted__c = false,
                GFERP__Posting_Date__c = Date.today().addMonths(-1),
                GFERP__Item_Ledger_Entry__c = ItemLedgerEntryRecord2.Id
            );
         costEntries.add(CostEntryRecord2);
        GFERP__Cost_Entry__c CostEntryRecord3 = new GFERP__Cost_Entry__c(
                GFERP__Purchase_Invoice__c = PurchInvoiceRecord.Id,
                GFERP__Item__c = ItemRecord.Id,
                GFERP__Invoiced_Cost__c = 100,
                GFERP__Sales_Invoice__c = SalesInvoiceRecord.Id,
                GFERP__Expected_Cost__c = 120,
                GFERP__Cost_Adjustment__c = true,
                GFERP__Cost_Posted__c = false,
                GFERP__Posting_Date__c = Date.today().addMonths(-1),
                GFERP__Item_Ledger_Entry__c = ItemLedgerEntryRecord3.Id
            );
         costEntries.add(CostEntryRecord3);
        GFERP__Cost_Entry__c CostEntryRecord4 = new GFERP__Cost_Entry__c(
                GFERP__Purchase_Invoice__c = PurchInvoiceRecord.Id,
                GFERP__Item__c = ItemRecord.Id,
                GFERP__Invoiced_Cost__c = 100,
                GFERP__Sales_Invoice__c = SalesInvoiceRecord.Id,
                GFERP__Expected_Cost__c = 120,
                GFERP__Cost_Adjustment__c = true,
                GFERP__Cost_Posted__c = false,
                GFERP__Posting_Date__c = Date.today().addDays(-1),
                GFERP__Item_Ledger_Entry__c = ItemLedgerEntryRecord.Id
            );
         costEntries.add(CostEntryRecord4);
        GFERP__Cost_Entry__c CostEntryRecord5 = new GFERP__Cost_Entry__c(
                GFERP__Purchase_Invoice__c = PurchInvoiceRecord.Id,
                GFERP__Item__c = ItemRecord.Id,
                GFERP__Invoiced_Cost__c = 100,
                GFERP__Sales_Invoice__c = SalesInvoiceRecord.Id,
                GFERP__Expected_Cost__c = 120,
                GFERP__Cost_Adjustment__c = true,
                GFERP__Cost_Posted__c = false,
                GFERP__Posting_Date__c = Date.today().addDays(-1),
                GFERP__Item_Ledger_Entry__c = ItemLedgerEntryRecord2.Id
            );
         costEntries.add(CostEntryRecord5);
        GFERP__Cost_Entry__c CostEntryRecord6 = new GFERP__Cost_Entry__c(
                GFERP__Purchase_Invoice__c = PurchInvoiceRecord.Id,
                GFERP__Item__c = ItemRecord.Id,
                GFERP__Invoiced_Cost__c = 100,
                GFERP__Sales_Invoice__c = SalesInvoiceRecord.Id,
                GFERP__Expected_Cost__c = 120,
                GFERP__Cost_Adjustment__c = true,
                GFERP__Cost_Posted__c = false,
                GFERP__Posting_Date__c = Date.today().addDays(-1),
                GFERP__Item_Ledger_Entry__c = ItemLedgerEntryRecord3.Id
            );
         costEntries.add(CostEntryRecord6);
        insert costEntries;
       GFERP__GL_Batch__c GLBatchRecord = new GFERP__GL_Batch__c();
        insert GLBatchRecord;
       GFERP__GL_Entry__c GLEntryRecord = new GFERP__GL_Entry__c(
                        GFERP__GL_Account__c = GLAccountRecord.Id,
                        GFERP__Posting_Date__c = Date.Today().addMonths(-1),
                        GFERP__Transaction_Source__c = 'Purchase Invoice',
                        GFERP__Purchase_Invoice__c = PurchInvoiceRecord.Id,
                        GFERP__Document_No__c = 'Temp-1000001',
                        GFERP__GL_Batch__c = GLBatchRecord.Id, // #GFERP-846
                        GFERP__Amount__c = 100
                );
                insert GLEntryRecord;
    }
     @IsTest
    static void testBehavior1() {
        Test.startTest();
        try {
            List<GFERP__GL_Account__c> GLAList = [SELECT Name FROM GFERP__GL_Account__c];
            Pagereference pgref = Page.MonthEndReconciliationConfirmation;
            Test.setCurrentPage(pgref);
            Date theToday = Date.today();
            String theTodayString = theToday.month() + '/' + theToday.day() + '/' + theToday.year();
            pgref.getParameters().put('endDate', theTodayString);
            ApexPages.StandardSetController testStdSetCon = new ApexPages.StandardSetController(GLAList);
            MonthEndReconciliationExportExcel_Custom testImpAccount = new MonthEndReconciliationExportExcel_Custom(testStdSetCon);
            testImpAccount.theISO = new GFCON__Import_Sales_Order__c(GFCON__Requested_Delivery_Date__c = theToday);
            testImpAccount.selectAccountSalesAndCOGS();
            testImpAccount.returnBackToList();
        } catch (Exception e) {
            system.debug('zon-->'+e.getLineNumber());
            system.debug('zon-->'+e.getMessage());
        }
        Test.stopTest();
    }
}