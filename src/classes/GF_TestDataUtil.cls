public class GF_TestDataUtil {
    
    Public static Account AccountRecord {
        get{
            if (AccountRecord == null) {
                AccountRecord = new Account(
                    Name = 'Cannon Group'
                );
                insert AccountRecord;
            }
            return AccountRecord;
        } private set;
    }
    
    Public static GFERP__Warehouse__c WarehouseRecord {
        get {
            if (WarehouseRecord == null) {
                WarehouseRecord = new GFERP__Warehouse__c(
                    Name = 'Blue',
                    Owned_by_Customer__c = AccountRecord.Id
                );
                insert WarehouseRecord;
                system.debug('Line 22 warehourse == '+WarehouseRecord);
            }
            if (WarehouseRecord.GFERP__Ship_Bin__c == null) {
                GFERP__bin__c ShipBinRecord = new GFERP__bin__c(
                    Name = 'Ship',
                    GFERP__Bin_Type__c = BinTypeShipRecord.Id,
                    GFERP__Warehouse__c = WarehouseRecord.Id
                );
                insert ShipBinRecord;
                WarehouseRecord.GFERP__Ship_Bin__c = ShipBinRecord.Id;
                WarehouseRecord.GFERP__Cross_Dock__c = ShipBinRecord.Id;
                WarehouseRecord.GFERP__Production_Bin__c = ShipBinRecord.Id;
                WarehouseRecord.GFERP__Receive_Bin__c = ShipBinRecord.Id;
                update WarehouseRecord;
            }
            return WarehouseRecord;
        } private set;
    }
    
    Public static GFERP__Warehouse__c WarehouseRecord2 {
        get {
            if (WarehouseRecord2 == null) {
                WarehouseRecord2 = new GFERP__Warehouse__c(Name = 'main',  GFERP__Use_As_In_Transit__c = true);
                insert WarehouseRecord2;
            }
            if (WarehouseRecord2.GFERP__Ship_Bin__c == null) {
                GFERP__bin__c ShipBinRecord = new GFERP__bin__c(
                    Name = 'Ship',
                    GFERP__Bin_Type__c = BinTypeShipRecord.Id,
                    GFERP__Warehouse__c = WarehouseRecord2.Id
                );
                insert ShipBinRecord;
                WarehouseRecord2.GFERP__Ship_Bin__c = ShipBinRecord.Id;
                WarehouseRecord2.GFERP__Cross_Dock__c = ShipBinRecord.Id;
                WarehouseRecord2.GFERP__Production_Bin__c = ShipBinRecord.Id;
                WarehouseRecord2.GFERP__Receive_Bin__c = ShipBinRecord.Id;
                update WarehouseRecord2;
            }
            return WarehouseRecord2;
        } private set;
    }
    
    
    Public static GFERP__Bin_Type__c BinTypeShipRecord {
        get{
            if (BinTypeShipRecord == null) {
                BinTypeShipRecord = new GFERP__Bin_Type__c(Name = 'Ship', GFERP__Ship__c = true);
                insert BinTypeShipRecord;
            }
            return BinTypeShipRecord;
        } private set;
    }
    Public static GFERP__Currency__c CurrencyRecord {
        get {
            if (CurrencyRecord == null) {
                CurrencyRecord = new GFERP__Currency__c(Name = 'USD');
                insert CurrencyRecord;
            }
            return CurrencyRecord;
        } private set;
    }    
    Public static GFERP__GL_Account__c GLAccountRecord {
        get{
            if (GLAccountRecord == null) {
                GLAccountRecord = new GFERP__GL_Account__c(Name = '13100');
                insert GLAccountRecord;
            }
            return GLAccountRecord;
        } private set;
    }
    
    public static GFERP__Unit_of_Measure__c UnitMeasureRecord {
        get {
            if (UnitMeasureRecord == null) {
                UnitMeasureRecord = new GFERP__Unit_of_Measure__c( Name = 'Day', GFERP__Type__c = 'Area' );
                insert UnitMeasureRecord;
            }
            return UnitMeasureRecord;
        } private set;
    }
    
    Public static GFERP__Salesperson_Purchaser__c SalespersonPurchaserRecord {
        get{
            if (SalespersonPurchaserRecord == null) {
                SalespersonPurchaserRecord = new GFERP__Salesperson_Purchaser__c(Name = 'NJ', GFERP__Rep_Name__c = 'NJ', GFERP__Sales_Rep__c = True);
                insert SalespersonPurchaserRecord;
            }
            return SalespersonPurchaserRecord;
        } private set;
    }
    
    Public static GFERP__Item__c ItemRecord {
        get{
            if (ItemRecord == null) {
                ItemRecord = new GFERP__Item__c(
                    Name = '7002',
                    GFERP__Description__c = 'Chocolate Cake',
                    GFERP__Base_Unit_of_Measure__c = UnitMeasureRecord.Id,
                    GFERP__Work_Center__c = false,
                    GFERP__Purchasing_Agent__c = SalespersonPurchaserRecord.Id,
                    GFERP__Blocked__c = false,
                    GFERP__Replenishment_System__c = 'Work Order',
                    GFERP__Costing_Method__c = 'Standard',
                    GFERP__Inventory_Class__c = 'Finished Goods',
                    GFERP__Standard_Base_Cost__c = 1,
                    GFERP__Standard_Material_Base_Cost__c = 1,
                    GFERP__Standard_Base_Price__c = 10,
                    GFERP__Item_Type__c = 'Inventory',
                    GFERP__Long_Description__c = '<image src="https://autodesk.i.lithium.com/t5/image/serverpage/image-id/516281i74784B88B7BE4B86/image-size/large?v=1.0&px=999"/>',
                    GFERP__UPC__c = '888444555444'
                );
                insert ItemRecord;
                system.debug('135 '+ItemRecord);
            }
            if (ItemRecord.GFERP__Purchase_Unit_of_Measure__c == null) {
                GFERP__Item_Unit_of_Measure__c ItemUnitMeasure = new GFERP__Item_Unit_of_Measure__c(
                    Name = 'CS',
                    GFERP__Conversion__c = 1,
                    GFERP__Item__c = ItemRecord.Id,
                    GFERP__Unit_of_Measure__c = UnitMeasureRecord.Id
                );
                insert ItemUnitMeasure;
                ItemRecord.GFERP__Base_UOM_Record_Id__c = ItemUnitMeasure.Id;
                ItemRecord.GFERP__Sales_Unit_of_Measure__c = ItemUnitMeasure.Id;
                ItemRecord.GFERP__Purchase_Unit_of_Measure__c = ItemUnitMeasure.Id;
                update ItemRecord;
            }
            return ItemRecord;
        } private set;
    }
    
    
    public static GFERP__Company_Setup__c CompanySetupRecord {
        get {
            if (CompanySetupRecord == null) {
                GFERP.CompanyMgmt.systemCall = true;
                CompanySetupRecord = new GFERP__Company_Setup__c(
                    Name = UserInfo.getOrganizationname(),
                    GFERP__Days_to_Receive__c = 7,
                    GFERP__Days_to_Ship__c = 2,
                    GFERP__Lines_to_Insert__c = 5,
                    GFERP__Lot_Days_to_Expire__c = 365,
                    GFERP__Warehouse__c = WarehouseRecord.Id,
                    GFERP__Currency__c = CurrencyRecord.Id,
                    GFERP__Payment_Term__c = PaymentTermRecord.Id,
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
                    GFERP__Account_Raw_Material_Inventory__c = GLAccountRecord.Id
                );
                insert CompanySetupRecord;
                List<GFERP__Numbering_Series__c> theNSList = new List<GFERP__Numbering_Series__c>();
                GFERP__Numbering_Series__c theNS = new GFERP__Numbering_Series__c();
                theNS.Name = 'Customer';
                theNS.GFERP__Prefix__c = 'C';
                theNS.GFERP__Separator__c = '-';
                theNS.GFERP__Last_Number_Used__c = 1000000;
                theNSList.add(theNS);
                
                theNS = new GFERP__Numbering_Series__c();
                theNS.Name = 'Pick';
                theNS.GFERP__Prefix__c = 'PK';
                theNS.GFERP__Separator__c = '-';
                theNS.GFERP__Last_Number_Used__c = 1000000;
                theNSList.add(theNS);
                
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
                theNS.Name = 'Put-away';
                theNS.GFERP__Prefix__c = 'PA';
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
                theNS.Name = 'Return Sales Order';
                theNS.GFERP__Prefix__c = 'RMA';
                theNS.GFERP__Separator__c = '-';
                theNS.GFERP__Last_Number_Used__c = 1000000;
                theNSList.add(theNS);
                
                theNS = new GFERP__Numbering_Series__c();
                theNS.Name = 'Sales Credit Memo';
                theNS.GFERP__Prefix__c = 'SM';
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
                
                theNS = new GFERP__Numbering_Series__c();
                theNS.Name = 'Sales Order';
                theNS.GFERP__Prefix__c = 'SO';
                theNS.GFERP__Separator__c = '-';
                theNS.GFERP__Last_Number_Used__c = 1000000;
                theNSList.add(theNS);
                
                theNS = new GFERP__Numbering_Series__c();
                theNS.Name = 'Sales Quote';
                theNS.GFERP__Prefix__c = 'SQ';
                theNS.GFERP__Separator__c = '-';
                theNS.GFERP__Last_Number_Used__c = 1000000;
                theNSList.add(theNS);
                
                theNS = new GFERP__Numbering_Series__c();
                theNS.Name = 'Vendor';
                theNS.GFERP__Prefix__c = 'V';
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
                theNS.Name = 'Work Order';
                theNS.GFERP__Prefix__c = 'WO';
                theNS.GFERP__Separator__c = '-';
                theNS.GFERP__Last_Number_Used__c = 1000000;
                theNSList.add(theNS);
                
                theNS = new GFERP__Numbering_Series__c();
                theNS.Name = 'Promotion Discount';
                theNS.GFERP__Prefix__c = 'PD';
                theNS.GFERP__Separator__c = '-';
                theNS.GFERP__Last_Number_Used__c = 1000000;
                theNSList.add(theNS);
                
                theNS = new GFERP__Numbering_Series__c();
                theNS.Name = 'Standing Order';
                theNS.GFERP__Prefix__c = 'STO';
                theNS.GFERP__Separator__c = '-';
                theNS.GFERP__Last_Number_Used__c = 1000000;
                theNSList.add(theNS);
                
                theNS = new GFERP__Numbering_Series__c();
                theNS.Name = 'Transfer Order';
                theNS.GFERP__Prefix__c = 'TO';
                theNS.GFERP__Separator__c = '-';
                theNS.GFERP__Last_Number_Used__c = 1000000;
                theNSList.add(theNS);
                
                theNS = new GFERP__Numbering_Series__c();
                theNS.Name = 'Breakbulk';
                theNS.GFERP__Prefix__c = 'BB';
                theNS.GFERP__Separator__c = '-';
                theNS.GFERP__Last_Number_Used__c = 1000000;
                theNSList.add(theNS);
                
                theNS = new GFERP__Numbering_Series__c();
                theNS.Name = 'Movement';
                theNS.GFERP__Prefix__c = 'MM';
                theNS.GFERP__Separator__c = '-';
                theNS.GFERP__Last_Number_Used__c = 1000000;
                theNSList.add(theNS);
                insert theNSList;
            }
            return CompanySetupRecord;
        } private set;
    }
    
    Public static Interplant_Transfer__c IntTransferRecord {
        get{
            if (IntTransferRecord == null) {
                IntTransferRecord = new Interplant_Transfer__c(
                    From_Customer__c = AccountRecord.Id,
                    Item__c = ItemRecord.Id,
                    To_Customer__c = AccountRecord.Id,
                    Quantity__c = 2,
                    Transfer_Date__c = System.today() + 3
                );
                insert IntTransferRecord;
            }
            return IntTransferRecord;
        } private set;
    }
    
    Public static GFERP__Payment_Term__c PaymentTermRecord {
        get {
            if (PaymentTermRecord == null) {
                PaymentTermRecord = new GFERP__Payment_Term__c(
                    Name = '14 DAYS',
                    GFERP__Discount_Pct__c = 0,
                    GFERP__Discount_Date_Calculation__c = 0,
                    GFERP__Due_Date_Calculation__c = 0
                );
                insert PaymentTermRecord;
            }
            return PaymentTermRecord;
        } private set;
    }
    
    Public static Customer_Inventory_Count__c CustomerInvCountRecord {
        get {
            if (CustomerInvCountRecord == null) {
                CustomerInvCountRecord = new Customer_Inventory_Count__c(
                    Item_No__c = ItemRecord.Id,
                    Week_End_Date__c = date.parse('4/17/2023'),
                    Customer__c = AccountRecord.Id,
                    Count_Qty__c = 10
                );
                insert CustomerInvCountRecord;
                system.debug('line 383 '+CustomerInvCountRecord.Week_End_Date__c);
            }
            return CustomerInvCountRecord;
        } private set;
    }
    
    Public static GFERP__Item_Ledger_Entry__c ItemLEDEnteryRecord {
        get {
            if (ItemLEDEnteryRecord == null) {
                ItemLEDEnteryRecord = new GFERP__Item_Ledger_Entry__c(
                    GFERP__Item__c = ItemRecord.Id,
                    GFERP__Posting_Date__c = date.parse('1/8/2023'),
                    GFERP__Document_Type__c = 'Shipment',
                    GFERP__Account__c = AccountRecord.Id,
                    GFERP__Correction__c = false
                    
                );
                insert ItemLEDEnteryRecord;
                system.debug('line 410 '+ItemLEDEnteryRecord);
            }
            return ItemLEDEnteryRecord;
        } private set;
    }
    Public static GFERP__Purchase_Line__c PurchLineRecord {
        get {
            if (PurchLineRecord == null) {
                PurchLineRecord = new GFERP__Purchase_Line__c(
                    GFERP__Purchase_Order__c = PORecord.Id,
                    GFERP__Warehouse__c = WarehouseRecord.Id,
                    GFERP__Item__c = ItemRecord.Id,
                    GFERP__Quantity__c = 2,
                    GFERP__Qty_Base__c = 2,
                    GFERP__Conversion__c = 1,
                    GFERP__Unit_of_Measure__c = ItemRecord.GFERP__Base_UOM_Record_Id__c, //ItemUnitMeasureRecord.Id,
                    GFERP__Received_Qty__c = 1,
                    GFERP__Received_Qty_Base__c = 1,
                    GFERP__Invoiced_Qty__c = 0,
                    GFERP__Unit_Cost__c = 20,
                    GFERP__Line_Cost__c = 40,
                    GFERP__Expected_Receipt_Date__c = Date.Today().addDays(7)
                );
                if(Schema.SObjectType.GFERP__Purchase_Line__c.isCreateable()) {
                    insert PurchLineRecord;
                }
            }
            return PurchLineRecord;
        } private set;
    }
    Public static GFERP__Purchase_Line__c PurchLineRecord1 {
        get {
            if (PurchLineRecord1 == null) {
                PurchLineRecord1 = new GFERP__Purchase_Line__c(
                    GFERP__Purchase_Order__c = PORecord.Id,
                    GFERP__Warehouse__c = WarehouseRecord.Id,
                    GFERP__Item__c = ItemRecord.Id,
                    GFERP__Quantity__c = 2,
                    GFERP__Qty_Base__c = 2,
                    GFERP__Conversion__c = 1,
                    GFERP__Unit_of_Measure__c = ItemRecord.GFERP__Base_UOM_Record_Id__c, //ItemUnitMeasureRecord.Id,
                    GFERP__Received_Qty__c = 1,
                    GFERP__Received_Qty_Base__c = 1,
                    GFERP__Invoiced_Qty__c = 0,
                    GFERP__Unit_Cost__c = 20,
                    GFERP__Line_Cost__c = 40,
                    GFERP__Expected_Receipt_Date__c = Date.Today().addDays(7)
                );
                if(Schema.SObjectType.GFERP__Purchase_Line__c.isCreateable()) {
                    insert PurchLineRecord1;
                }
            }
            return PurchLineRecord1;
        } private set;
    }
    
    Public static GFERP__Purchase_Order__c PORecord {
        get {
            if (PORecord == null) {
                PORecord = new GFERP__Purchase_Order__c(
                    Name = 'test',
                    GFERP__Buy_from_Vendor2__c = AccountRecord.Id,
                    GFERP__Pay_to_Vendor__c = Account2Record.Id,
                    GFERP__Expected_Receipt_Date__c = Date.today(),
                    GFERP__Warehouse__c = WarehouseRecord.Id,
                    GFERP__Currency2__c = CurrencyRecord.Id,
                    GFERP__Payment_Term__c = PaymentTermRecord.Id,
                    GFERP__Order_date__c = Date.today(),
                    GFERP__Purchasing_Agent__c = SalespersonPurchaserRecord.Id,
                    GFERP__Shipping_Agent__c = ShippingAgentRecord.Id
                );
                if(Schema.SObjectType.GFERP__Purchase_Order__c.isCreateable()) {
                    insert PORecord;
                }
            }
            return PORecord;
        } private set;
    }
    
    Public static Account Account2Record {
        get{
            if (Account2Record == null) {
                Account2Record = new Account(
                    Name = 'London Postmaster',
                    GFERP__Warehouse__c = WarehouseRecord2.Id,
                    GFERP__Currency__c = CurrencyRecord.Id,
                    GFERP__Payment_Term__c = PaymentTermRecord.Id,
                    GFERP__Tax_Area__c = TaxAreaRecord.Id,
                    GFERP__Sales_Rep__c = SalespersonPurchaserRecord.Id,
                    GFERP__Customer_No__c = '111222333'
                );
                insert Account2Record;
            }
            return Account2Record;
        } private set;
    }
    Public static GFERP__Shipping_Agent__c ShippingAgentRecord {
        get{
            if (ShippingAgentRecord == null) {
                ShippingAgentRecord = new GFERP__Shipping_Agent__c(Name = 'UPS');
                if(Schema.SObjectType.GFERP__Shipping_Agent__c.isCreateable()) {
                    insert ShippingAgentRecord;
                }
            }
            return ShippingAgentRecord ;
        } private set;
    }
    
    Public static GFERP__Tax_Area__c TaxAreaRecord {
        get{
            if (TaxAreaRecord == null) {
                TaxAreaRecord = new GFERP__Tax_Area__c(Name = 'NJ');
                if(Schema.SObjectType.GFERP__Sales_Invoice__c.isCreateable()) {
                    insert TaxAreaRecord;
                }
            }
            return TaxAreaRecord;
        } private set;
    }
    
    public static Import_Sales_Prices__c ImportSalesPriceRecord {
        get{
            if (ImportSalesPriceRecord == null) {
                ImportSalesPriceRecord = new Import_Sales_Prices__c(
                    Currency__c = 'USD',
                    Item__c = '7002',
                    Sales_Price__c = 12,
                    Starting_Date__c = system.today(),
                    Unit_of_Measure__c = 'CS',
                    Minimum_Quantity__c = '111222'
                );
                insert ImportSalesPriceRecord;
            }
            return ImportSalesPriceRecord;
        } private set;
    }
    public static GFERP__Sales_Price2__c SalesPriceRecord {
        get{
            if (SalesPriceRecord == null) {
                SalesPriceRecord = new GFERP__Sales_Price2__c(
                    GFERP__Item__c = ItemRecord.Id,
                    GFERP__Unit_of_Measure__c = ItemRecord.GFERP__Base_UOM_Record_Id__c,
                    GFERP__Sales_Price__c = 12,
                    GFERP__Starting_Date__c = system.today().addDays(-7),
                    GFERP__Currency__c = CurrencyRecord.Id,
                    GFERP__Minimum_Quantity__c = 1,
                    GFERP__Ending_Date__c = system.today()//,
                    //GFERP__Account__c = AccountRecord.Id
                );
                insert SalesPriceRecord;
            }
            return SalesPriceRecord;
        } private set;
    }
    
    public static GFERP__Bin_Content__c BinContentRecord {
        get {
            if (BinContentRecord == null) {
                BinContentRecord  = new GFERP__Bin_Content__c(
                    GFERP__Item__c = ItemRecord.Id,
                    GFERP__Unit_of_Measure__c = ItemRecord.GFERP__Sales_Unit_of_Measure__c,
                    GFERP__Warehouse__c = WarehouseRecord.Id,
                    GFERP__Bin__c = WarehouseRecord.GFERP__Ship_Bin__c,
                    GFERP__Item_Lot__c = ItemLotRecord.Id
                );
                insert BinContentRecord;
            }
            return BinContentRecord;
        } private set;
    }
    
    public static GFERP__Item_Lot__c ItemLotRecord {
        get {
            if (ItemLotRecord == null) {
                ItemLotRecord = new GFERP__Item_Lot__c (
                    Name = 'Test',
                    GFERP__Certificate_Number__c = '123',
                    GFERP__Country_of_Origin2__c = 'Canada',
                    GFERP__Expiration_Date__c = Date.today(),
                    GFERP__Item__c = ItemRecord.Id,
                    GFERP__Manufacture_Date__c = Date.today(),
                    GFERP__Test_Status__c = 'Accept'
                );
                insert ItemLotRecord;
            }
            return ItemLotRecord;
        } private set;
    }
    
    public static GFERP__Warehouse_Entry__c WarehouseEntryRecord {
        get {
            if (WarehouseEntryRecord == null) {
                WarehouseEntryRecord = new GFERP__Warehouse_Entry__c (
                    GFERP__Bin_Content__c = BinContentRecord.Id,
                    GFERP__Bin__c = WarehouseRecord.GFERP__Ship_Bin__c,
                    GFERP__Item__c = ItemRecord.Id,
                    GFERP__Unit_of_Measure__c = ItemRecord.GFERP__Sales_Unit_of_Measure__c,
                    GFERP__Warehouse__c = WarehouseRecord.Id,
                    GFERP__Quantity__c = 100,
                    GFERP__Qty_Base__c = 100,
                    GFERP__Conversion__c = 1,
                    GFERP__Document_No__c = '123',
                    GFERP__Item_Lot__c = ItemLotRecord.Id,
                    GFERP__Activity_Type__c = 'Shipment',
                    GFERP__Posting_Date__c = Date.Today()
                );
                insert WarehouseEntryRecord;
            }
            return WarehouseEntryRecord;
        } private set;
    }
    
    public static GFERP__Item_Ledger_Entry__c ItemLedgerEntryRecord1 {
        get {
            if (ItemLedgerEntryRecord1 == null) {
                ItemLedgerEntryRecord1 = new GFERP__Item_Ledger_Entry__c(
                    GFERP__Item__c = ItemRecord.Id,
                    GFERP__Account__c = AccountRecord.Id,
                    GFERP__Bin__c = WarehouseRecord.GFERP__Ship_Bin__c,
                    GFERP__Bin_Content__c = BinContentRecord.Id,
                    GFERP__Conversion__c = 1,
                    GFERP__Document_No__c = '123',
                    GFERP__Document_Type__c = 'Shipment',
                    //                        GFERP__Whse_Shipment_Line__c = WhseShipmentLineRecord.Id,
                    GFERP__Posting_Date__c = Date.today().addDays(-7),
                    GFERP__Qty_Base__c = -100,
                    GFERP__Quantity__c = -100,
                    GFERP__Remaining_Qty_Base__c = 0,
                    GFERP__Unit_of_Measure__c = ItemRecord.GFERP__Sales_Unit_of_Measure__c,
                    GFERP__Warehouse__c = WarehouseRecord.Id,
                    GFERP__Item_Lot__c = ItemLotRecord.Id
                );
                insert ItemLedgerEntryRecord1;
            }
            return ItemLedgerEntryRecord1;
        }
        private set;
    }
    
    public static GFERP__Item_Ledger_Entry__c ItemLedgerEntryRecord2 {
        get {
            if (ItemLedgerEntryRecord2 == null) {
                ItemLedgerEntryRecord2 = new GFERP__Item_Ledger_Entry__c(
                    GFERP__Item__c = ItemRecord.Id,
                    GFERP__Account__c = AccountRecord.Id,
                    GFERP__Bin__c = WarehouseRecord.GFERP__Ship_Bin__c,
                    GFERP__Bin_Content__c = BinContentRecord.Id,
                    GFERP__Conversion__c = 1,
                    GFERP__Document_No__c = '123',
                    GFERP__Document_Type__c = 'Shipment',
                    //                        GFERP__Whse_Shipment_Line__c = WhseShipmentLineRecord.Id,
                    GFERP__Posting_Date__c = Date.today().addYears(-1).addDays(14),
                    GFERP__Qty_Base__c = -100,
                    GFERP__Quantity__c = -100,
                    GFERP__Remaining_Qty_Base__c = 0,
                    GFERP__Unit_of_Measure__c = ItemRecord.GFERP__Sales_Unit_of_Measure__c,
                    GFERP__Warehouse__c = WarehouseRecord.Id,
                    GFERP__Item_Lot__c = ItemLotRecord.Id
                );
                insert ItemLedgerEntryRecord2;
            }
            return ItemLedgerEntryRecord2;
        }
        private set;
    }
    public static GFERP__User_Setup__c UserSetupRecord {
        get {
            if (UserSetupRecord == null) {
                UserSetupRecord = new GFERP__User_Setup__c (
                    Name = 'Test User',
                    GFERP__Salesforce_User__c = UserInfo.getUserId(),
                    GFERP__Allow_Unpost__c = true,
                    GFERP__Allow_Posting_From__c = Date.Today(),
                    GFERP__Allow_Posting_To__c = Date.Today() + 7,
                    GFERP__Allow_Delete_Sales_Orders__c = true,
                    GFERP__Purchasing_Agent__c = SalespersonPurchaserRecord.Id
                );
                
                insert UserSetupRecord;
                
            }
            return UserSetupRecord;
        }
        private set;
    }
    Public static GFERP__Inventory_Setup__c InventorySetupRecord {
        get {
            if (InventorySetupRecord == null) {
                InventorySetupRecord = new GFERP__Inventory_Setup__c(
                    Name = 'Default', 
                    GFERP__Company_Setup__c = CompanySetupRecord.Id,
                    GFERP__Accrued_AP_Landed_Cost1__c = GLAccountRecord.Id,
                    GFERP__Accrued_AP_Landed_Cost2__c = GLAccountRecord.Id,
                    GFERP__Accrued_AP_Landed_Cost3__c = GLAccountRecord.Id,
                    GFERP__Accrued_AP_Landed_Cost4__c = GLAccountRecord.Id,
                    GFERP__Accrued_AP_Landed_Cost5__c = GLAccountRecord.Id
                );
                
                insert InventorySetupRecord;
                
            }
            return InventorySetupRecord;
        }
        private set;
    }
    Public static GFERP__Whse_Receipt__c WhseReceiptRecord {
        get {
            if (WhseReceiptRecord == null) {
                WhseReceiptRecord = new GFERP__Whse_Receipt__c(
                    Name = 'Test',
                    GFERP__Purchase_Order__c = PORecord.Id,
                    GFERP__Warehouse__c = WarehouseRecord.Id,
                    GFERP__Buy_from_Vendor__c = AccountRecord.Id,
                    GFERP__Document_Status__c = 'Open',
                    GFERP__Currency__c = CurrencyRecord.Id,
                    GFERP__Currency_Factor__c = 1,
                    GFERP__Expected_Receipt_Date__c = Date.Today().addDays(7),
                    GFERP__Actual_Receipt_Date__c = Date.Today(),
                    GFERP__Posting_Date__c = Date.today(),
                    GFERP__Shipping_Agent__c = ShippingAgentRecord.Id
                );
                
                insert WhseReceiptRecord;
                
            }
            return WhseReceiptRecord ;
        }
        private set;
    }
    Public static GFERP__Whse_Receipt_Line__c WhseReceiptLineRecord {
        get {
            if (WhseReceiptLineRecord == null) {
                WhseReceiptLineRecord = new GFERP__Whse_Receipt_Line__c(
                    GFERP__Receipt__c = WhseReceiptRecord.Id,
                    GFERP__Warehouse__c = WarehouseRecord.Id,
                    GFERP__Item__c = ItemRecord.Id,
                    GFERP__Quantity__c = 1.0,
                    GFERP__Qty_Base__c = 1.0,
                    GFERP__Invoiced_Qty__c = 0,
                    GFERP__Invoiced_Qty_Base__c = 0,
                    GFERP__Conversion__c = 1,
                    GFERP__Lot_Tracked__c = true,
                    GFERP__Unit_Cost__c = 1,
                    //Currency_Factor__c = 1,
                    GFERP__Unit_of_Measure__c = ItemUnitMeasureRecord.Id,
                    GFERP__Bin__c = BinRecord.Id,
                    GFERP__Expected_Receipt_Date__c = Date.Today().addDays(7),
                    GFERP__Landed_Cost1__c = 0,
                    GFERP__Landed_Cost2__c = 0,
                    GFERP__Landed_Cost3__c = 0,
                    GFERP__Landed_Cost4__c = 0,
                    GFERP__Landed_Cost5__c = 0,
                    GFERP__Purchase_Line__c = PurchLineRecord.Id,
                    GFERP__Bin_Content__c = BinContentRecord.Id
                );
                
                insert WhseReceiptLineRecord;
                
            }
            return WhseReceiptLineRecord;
        }
        private set;
    }
    public static GFERP__Item_Unit_of_Measure__c ItemUnitMeasureRecord {
        get {
            if (ItemUnitMeasureRecord == null) {
                ItemUnitMeasureRecord = new GFERP__Item_Unit_of_Measure__c(
                    Name = 'Case1', 
                    GFERP__Conversion__c = 5, 
                    GFERP__Item__c = ItemRecord.Id,
                    GFERP__Unit_of_Measure__c = UnitMeasureRecord.Id
                );
                
                insert ItemUnitMeasureRecord;
                
            }
            
            return ItemUnitMeasureRecord;
        }
        private set;
    }
    Public static GFERP__Tracking_Line__c TrackingLine2Record {
        get {
            if (TrackingLine2Record == null) {
                TrackingLine2Record = new GFERP__Tracking_Line__c(
                    GFERP__Bin__c = BinRecord.Id,
                    GFERP__Conversion__c = 1,
                    GFERP__Item__c = ItemRecord.Id,
                    GFERP__Line_No__c = 1,
                    GFERP__Qty_Base__c = 1,
                    GFERP__Quantity__c = 1,
                    GFERP__Transaction_Source__c = 'Receipt',
                    GFERP__Unit_of_Measure__c = ItemUnitMeasureRecord.Id,
                    GFERP__Warehouse__c = WarehouseRecord.Id,
                    GFERP__Bin_Content__c = BinContentRecord.Id,
                    GFERP__Item_Lot__c = ItemLotRecord.Id,
                    GFERP__Receipt_Line__c = WhseReceiptLineRecord.Id,
                    GFERP__Receipt__c = WhseReceiptRecord.Id,
                    GFERP__New_Lot__c = '2',
                    GFERP__Lot_Manufacture_Date__c = system.today(),
                    GFERP__Lot_Expiration_Date__c = system.today() + 7
                );
                
                insert TrackingLine2Record;
                
            }
            return TrackingLine2Record;
        }
        private set;
    }
    Public static GFERP__Bin__c BinRecord {
        get {
            if (BinRecord == null) {
                BinRecord = new GFERP__Bin__c(Name = 'Ship', GFERP__Bin_Type__c = BinTypeShipRecord.Id, GFERP__Warehouse__c = WareHouseRecord.Id);
                
                insert BinRecord;
            }
            return BinRecord;
        }
        private set;
    }
     public static GFERP__Purchase_Order__c PurchaseOrderRecord {
        get {
            if (PurchaseOrderRecord == null) {
                PurchaseOrderRecord = new GFERP__Purchase_Order__c(
                        GFERP__Document_Status__c = 'Open',
                        GFERP__Order_Date__c = Date.today(),
                        GFERP__Buy_from_Vendor2__c = AccountRecord.Id,
                        GFERP__Billing_Contact__c = AccountRecord.GFERP__Billing_Contact__c,
                        GFERP__Warehouse__c = WarehouseRecord.Id,
                        GFERP__Currency2__c = CurrencyRecord.Id,
                        GFERP__Payment_Term__c = PaymentTermRecord.Id,
                        GFERP__Expected_Receipt_Date__c = Date.today().addDays(2),
                        GFERP__Pay_to_Vendor__c = Account2Record.Id,
                        GFERP__Shipping_Agent__c = ShippingAgentRecord.Id,
                        GFERP__Purchasing_Agent__c = SalespersonPurchaserRecord.Id
                );
             
                 insert PurchaseOrderRecord;
            }
            return PurchaseOrderRecord;
        }
        private set;
    }
     public static GFERP__Work_Order__c WorkOrderRecord {
        get {
            if (WorkOrderRecord == null) {
                WorkOrderRecord = new GFERP__Work_Order__c (
                        GFERP__Quantity__c = 2,
                        GFERP__Qty_Base__c = 4,
                        GFERP__Conversion__c = 2,
                        GFERP__Unit_Cost__c = 10,
                        GFERP__Standard_Material_Cost__c = 1,
                        GFERP__Output_Bin__c = BinRecord.Id,
                        GFERP__Output_Item__c = ItemRecord.Id,
                        GFERP__Ending_Date_Time__c = Date.Today().addDays(7),
                        GFERP__Finished_Date__c = Date.Today(),
                        GFERP__Starting_Date_Time__c = Date.Today(),
                        GFERP__Warehouse__c = WarehouseRecord.Id,
                        GFERP__Unit_of_Measure__c = ItemRecord.GFERP__Sales_Unit_of_Measure__c,
//                        GL_Ledger__c = GLLedgerRecord.Id,
                        GFERP__Finished_Qty__c = 2,
                        GFERP__Finished_Qty_Base__c = 4,
                        GFERP__Remaining_Qty__c = 1,
                        GFERP__Remaining_Qty_Base__c = 2,
                        GFERP__Input_Bin__c = BinRecord.Id
                );
              
                 insert WorkOrderRecord;
            }
            return WorkOrderRecord;
        }
        private set;
    }
     Public static GFERP__Purchase_Invoice__c PurchInvoiceRecord {
        get {
            if (PurchInvoiceRecord == null) {
                PurchInvoiceRecord = new GFERP__Purchase_Invoice__c(
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
                        GFERP__Payment_Discount_Pct__c = 10,
                        GFERP__Purchasing_Agent__c = SalespersonPurchaserRecord.Id
                );
                insert PurchInvoiceRecord;
            }
            return PurchInvoiceRecord;
        }
        private set;
    }
     public static GFERP__Sales_Line__c SalesLineRecord {
        get {
            if (SalesLineRecord == null) {
                SalesLineRecord = new GFERP__Sales_Line__c();
                SalesLineRecord.GFERP__Line_No__c = 1;
                SalesLineRecord.GFERP__Description__c = 'Test item';
                SalesLineRecord.GFERP__Sales_Order__c = SalesOrderRecord.id;
                SalesLineRecord.GFERP__Quantity__c = 1100;
                SalesLineRecord.GFERP__Qty_Base__c = 1100;
                SalesLineRecord.GFERP__Shipped_Qty__c = 60;
                SalesLineRecord.GFERP__Shipped_Qty_base__c = 60;
                SalesLineRecord.GFERP__Invoiced_Qty__c = 60;
                SalesLineRecord.GFERP__Invoiced_Qty_Base__c = 60;
                SalesLineRecord.GFERP__Conversion__c = 1;
                SalesLineRecord.GFERP__Unit_Price__c = 10;
                SalesLineRecord.GFERP__Item__c = ItemRecord.Id;
                SalesLineRecord.GFERP__Unit_of_Measure__c = ItemUnitMeasureRecord.Id;
                SalesLineRecord.GFERP__Warehouse__c = WarehouseRecord.Id;
                SalesLineRecord.GFERP__Purchasing_Type__c = 'Special Order';
                SalesLineRecord.GFERP__Shipment_Date__c = Date.today().addDays(7);
                SalesLineRecord.GFERP__Tax_Pct__c = 10;
                SalesLineRecord.GFERP__Returned_from_SIL__c = SalesInvoiceLineRecord.Id;
                SalesLineRecord.GFERP__Replenishment_System__c = 'Work Order';
               
                 insert SalesLineRecord;
            }
            return SalesLineRecord;
        }
        private set;
    }
     public static GFERP__Sales_Order__c SalesOrderRecord {
        get {
            GFERP.CompanyMgmt.systemCall = true;
            if (SalesOrderRecord == null) {
                SalesOrderRecord = new GFERP__Sales_Order__c(
                        GFERP__Order_Date__c = Date.today(),
                        GFERP__Sell_to_Customer__c = AccountRecord.Id,
                        GFERP__Warehouse__c = WarehouseRecord.Id,
                        GFERP__Currency__c = CurrencyRecord.Id,
                        GFERP__Payment_Term__c = PaymentTermRecord.Id,
                        GFERP__Requested_Shipment_Date__c = Date.today().addDays(2),
                        GFERP__Bill_to_Customer__c = Account2Record.Id,
                        GFERP__Shipping_Agent__c = ShippingAgentRecord.Id,
                        GFERP__Tax_Area__c = TaxAreaRecord.Id,
                        GFERP__Sales_Rep__c = SalespersonPurchaserRecord.Id
                );
             
                 insert SalesOrderRecord;
            }
            return SalesOrderRecord;
        }
        private set;
    }
    public static GFERP__Sales_Invoice_Line__c SalesInvoiceLineRecord {
        get{
            if (SalesInvoiceLineRecord == null) {
                SalesInvoiceLineRecord = new GFERP__Sales_Invoice_Line__c(
                        GFERP__Conversion__c = 1,
                        GFERP__Item__c = ItemRecord.Id,
                        GFERP__Item_Type__c = 'Inventory',
                        GFERP__Description__c = 'Test',
                        GFERP__Line_No__c = 5,
                        GFERP__Qty_Base__c = 10,
                        GFERP__Quantity__c = 10,
                        GFERP__Sales_Invoice__c = SalesInvoiceRecord.Id,
                        GFERP__Unit_Cost__c = 2,
                        GFERP__Unit_Price__c = 2,
                        GFERP__Line_Amt_Incl_Tax__c = 10,
                        GFERP__Tax__c = 10,
                        GFERP__Unit_of_Measure__c = ItemRecord.GFERP__Sales_Unit_of_Measure__c,
                        GFERP__Warehouse__c = WarehouseRecord.Id,
                        GFERP__Bin__c = WarehouseRecord.GFERP__Ship_Bin__c,
                        GFERP__Tax_Pct__c=10,
                       GFERP__Line_Amount__c=10
                );
                insert SalesInvoiceLineRecord;
            }
            return SalesInvoiceLineRecord;
        } private set;
    }
     Public static GFERP__Sales_Invoice__c SalesInvoiceRecord {
        get{
            if (SalesInvoiceRecord == null) {
                SalesInvoiceRecord = new GFERP__Sales_Invoice__c(
//                        GFERP__Shipment__c = WhseShipmentRecord.id,
//                        GFERP__Sales_Order__c = SalesOrderRecord.Id,
                        GFERP__Sell_to_Customer__c = AccountRecord.id,
                        GFERP__Actual_Shipment_Date__c = Date.Today() + 100,
                        GFERP__Description__c = 'Test',
                        GFERP__Customer_PO_No__c = '45',
                        GFERP__Document_Status__c = 'Open',
                        GFERP__Order_Date__c = Date.Today(),
                        GFERP__Posting_Date__c = date.today(),
                        GFERP__Invoice_Date__c = date.today() + 100,
                        GFERP__Payment_Term__c = PaymentTermRecord.id,
                        GFERP__Bill_to_Customer__c = AccountRecord.Id,
                        GFERP__Currency__c = CurrencyRecord.Id,
                        GFERP__Due_Date__c = Date.today().addDays(7),
                        GFERP__Payment_Discount_Date__c = Date.today(),
                        GFERP__Tax_Area__c = TaxAreaRecord.Id,
                        GFERP__Sales_Rep__c = SalespersonPurchaserRecord.Id,
                        GFERP__Warehouse__c = WarehouseRecord.Id,
                        GFERP__Ready_to_Post__c = true,
                        GFERP__Bypass_Shipment__c = true
                );
                insert SalesInvoiceRecord;
            }
            return SalesInvoiceRecord;
        } private set;
    }
     Public static GFERP__QC_Test_Line__c QCTestLineRecord {
        get {
            if (QCTestLineRecord == null) {
                QCTestLineRecord = new GFERP__QC_Test_Line__c (
                        GFERP__QC_Test__c = QCTestRecord.Id,
                       // GFERP__Question3__c = QCQuestionRecord.Id,
                        GFERP__Line_No__c = 1

                );
               
                 insert QCTestLineRecord;
            }
            return QCTestLineRecord ;
        }
        private set;
    }
      Public static GFERP__QC_Test__c QCTestRecord {
        get {
            if (QCTestRecord == null) {
                QCTestRecord = new GFERP__QC_Test__c (
                       // GFERP__Item__c = ItemRecord4.Id,
                        //GFERP__Item_Lot__c = ItemLotRecord2.Id,
                       // GFERP__Unit_of_Measure__c = ItemRecord4.GFERP__Sales_Unit_of_Measure__c,
                        GFERP__Old_Test_Status__c = 'Reject',
                        GFERP__New_Test_Status__c = 'Accept',
                        GFERP__Test_Quantity__c = 10,
                        GFERP__Approved_Quantity__c = 8,
                        GFERP__Block_Type__c = 'No Block'
                       // GFERP__Test_by_Technician__c = UserSetupRecord.Id
                );
              
                  insert QCTestRecord;
            }
            return QCTestRecord ;
        }
        private set;
    }
       public static GFERP__Cross_Reference__c CrossReferenceRecord {
        get {
            if (CrossReferenceRecord == null) {
                CrossReferenceRecord = new GFERP__Cross_Reference__c(
                        GFERP__Account__c = GF_TestDataUtil.AccountRecord.Id,
                        GFERP__Item__c = GF_TestDataUtil.ItemRecord.Id,
                        GFERP__Unit_of_Measure__c = GF_TestDataUtil.ItemRecord.GFERP__Sales_Unit_of_Measure__c,
                        GFERP__Cross_Referece_No__c = '254178',
                        GFERP__Default_Sales_UOM_for_Customer__c = true
                );

                    insert CrossReferenceRecord;
            
            }
            return CrossReferenceRecord;
        }
        private set;
    }
    
  	public static GFERP__Whse_Shipment__c WhseShipmentRecord {
        get {
            if (WhseShipmentRecord == null) {
                WhseShipmentRecord = new GFERP__Whse_Shipment__c(
                        GFERP__Document_Status__c = 'Open',
                        GFERP__Actual_Shipment_Date__c = Date.Today() + 100,
                        GFERP__Description__c = 'Test item',
                        GFERP__Sales_Order__c = SalesOrderRecord.id,
                        GFERP__Sell_to_Customer__c = GF_TestDataUtil.Account2Record.id,
                        GFERP__Posting_Date__c = Date.Today(),
                        GFERP__Warehouse__c = GF_TestDataUtil.WarehouseRecord.Id,
                        GFERP__Shipping_Agent__c = GF_TestDataUtil.ShippingAgentRecord.id
                );
                
                    insert WhseShipmentRecord;
              
            }
            return WhseShipmentRecord;
        }
        private set;
    }
 
 	Public static GFERP__Whse_Shipment_Line__c WhseShipmentLineRecord {
        get {
            if (WhseShipmentLineRecord == null) {
                WhseShipmentLineRecord = new GFERP__Whse_Shipment_Line__c(
                        GFERP__Conversion__c = 1,
                        GFERP__Invoiced_Qty__c = 4,
                        GFERP__Invoiced_Qty_Base__c = 4,
                        GFERP__Item_Type__c = 'Inventory',
                        GFERP__Line_No__c = 1,
                        GFERP__Lot_Qty_Entered__c = 5.00,
                        GFERP__Purchasing_Type__c = 'Inventory',
                        GFERP__Qty_Base__c = 10,
                        GFERP__Quantity__c = 10,
                        GFERP__Unit_Cost__c = 10.00,
                        GFERP__Shipment__c = WhseShipmentRecord.Id,
                        GFERP__Warehouse__c = WarehouseRecord.Id,
                        GFERP__Sales_Line__c = SalesLineRecord.Id,
                        GFERP__Sales_Order__c = SalesOrderRecord.Id,
                        GFERP__Item__c = GF_TestDataUtil.ItemRecord.Id,
                        GFERP__Unit_Of_Measure__c =ItemRecord.GFERP__Sales_Unit_of_Measure__c,
                        GFERP__Bin__c = GF_TestDataUtil.BinRecord.Id,
                        GFERP__Bin_Content__c = GF_TestDataUtil.BinContentRecord.Id,
                        GFERP__Lot_Tracked__c = true
                );
               
                    insert WhseShipmentLineRecord;
               
            }
            return WhseShipmentLineRecord;
        }
        private set;
    }
   
}