public with sharing class ItemAvailabilityStatusController {
    public Integer PageSize { get; set; }
    public String filterInput { get; set; }
    public String selFilterField { get; set; }
    public String selFilterOp { get; set; }

    public String filterInput2 { get; set; }
    public String selFilterField2 { get; set; }
    public String selFilterOp2 { get; set; }

    public String filterInput3 { get; set; }
    public String selFilterField3 { get; set; }
    public String selFilterOp3 { get; set; }

    public String filterInput4 { get; set; }
    public String selFilterField4 { get; set; }
    public String selFilterOp4 { get; set; }

    public String filterInput5 { get; set; }
    public String selFilterField5 { get; set; }
    public String selFilterOp5 { get; set; }
    
    public String filterInput6 { get; set; }
    public String selFilterField6 { get; set; }
    public String selFilterOp6 { get; set; }

    public Date onHandAsOfDate { get; set; }

    public Set<Id> SetLocalWhseId = new Set<Id>();
    public Set<Id> SetVendorWhseId = new Set<Id>();
    public Set<Id> SetCustomerWhseId = new Set<Id>();
    public Date todaysDate { get; set; }
    public String filterString { get; set; }

    public String sortExp { get; set; }
    private String sortDirection = 'ASC';

    public ItemAvailabilityStatusController() {
        filterInput = ApexPages.CurrentPage().getParameters().get('filterInput');
        selFilterField = ApexPages.CurrentPage().getParameters().get('selFilterField');
        selFilterOp = ApexPages.CurrentPage().getParameters().get('selFilterOp');
        filterInput2 = ApexPages.CurrentPage().getParameters().get('filterInput2');
        selFilterField2 = ApexPages.CurrentPage().getParameters().get('selFilterField2');
        selFilterOp2 = ApexPages.CurrentPage().getParameters().get('selFilterOp2');
        filterInput3 = ApexPages.CurrentPage().getParameters().get('filterInput3');
        selFilterField3 = ApexPages.CurrentPage().getParameters().get('selFilterField3');
        selFilterOp3 = ApexPages.CurrentPage().getParameters().get('selFilterOp3');
        filterInput4 = ApexPages.CurrentPage().getParameters().get('filterInput4');
        selFilterField4 = ApexPages.CurrentPage().getParameters().get('selFilterField4');
        selFilterOp4 = ApexPages.CurrentPage().getParameters().get('selFilterOp4');
        filterInput5 = ApexPages.CurrentPage().getParameters().get('filterInput5');
        selFilterField5 = ApexPages.CurrentPage().getParameters().get('selFilterField5');
        selFilterOp5 = ApexPages.CurrentPage().getParameters().get('selFilterOp5');
        filterInput6 = ApexPages.CurrentPage().getParameters().get('filterInput6');
        selFilterField6 = ApexPages.CurrentPage().getParameters().get('selFilterField6');
        selFilterOp6 = ApexPages.CurrentPage().getParameters().get('selFilterOp6');
        String onHandAsOfDateString = ApexPages.CurrentPage().getParameters().get('onHandAsOfDate');
        if(onHandAsOfDateString != null && onHandAsOfDateString != 'null'){
            onHandAsOfDate = date.parse(onHandAsOfDateString);
        }

        if (filterInput == 'null') {
            filterInput = '';
        }

        if (filterInput2 == 'null') {
            filterInput2 = '';
        }

        if (filterInput3 == 'null') {
            filterInput3 = '';
        }

        if (filterInput4 == 'null') {
            filterInput4 = '';
        }

        if (filterInput6 == 'null') {
            filterInput6 = '';
        }

        PageSize = 1000;
        sortExp = 'Name';
        todaysDate = Date.today();
        selectWhse();
        search();
    }

    public ItemAvailabilityStatusController(ApexPages.StandardSetController controller) {
        PageSize = 25;
        sortExp = 'Name';
        onHandAsOfDate = Date.today();
        selectWhse();
        search();
    }

    private void selectWhse() {
        //SetLocalWhseId
        for (GFERP__Warehouse__c Whse : [SELECT Id FROM GFERP__Warehouse__c WHERE FPC_Local_Warehouse__c = :true]) {
            SetLocalWhseId.add(Whse.Id);
        }
        //SetVendorWhseId
        for (GFERP__Warehouse__c Whse : [SELECT Id FROM GFERP__Warehouse__c WHERE FPC_Vendor_Warehouse__c = :true]) {
            SetVendorWhseId.add(Whse.Id);
        }
        //SetCustomerWhseId
        for (GFERP__Warehouse__c Whse : [SELECT Id FROM GFERP__Warehouse__c WHERE (Owned_By_Customer__c != null)]) {
            SetCustomerWhseId.add(Whse.Id);
        }
    }

    public List<wrapItem> lstWItem {
        get {
            String strQuery;
            List<AggregateResult> results;
            /*
            List<GFERP__Purchase_Line__c> thePLList = new List<GFERP__Purchase_Line__c>();
            //PL
            strQuery = 'SELECT GFERP__Item__c, GFERP__Item__r.Name, GFERP__Unit_of_Measure__c, GFERP__Unit_of_Measure__r.Name, GFERP__Expected_Receipt_Date__c ' +
                    'FROM GFERP__Purchase_Line__c ' +
                    'WHERE GFERP__Purchase_Order__r.GFERP__Closed__c = false ' +
                    'AND GFERP__Item_Type__c = \'Inventory\' ';
            if (!String.isEmpty(selFilterField3) && !String.isEmpty(filterInput3)) {
                if (selFilterOp3 == 'equals') {
                    strQuery += ' AND ' + selFilterField3 + '  = \'' + String.escapeSingleQuotes(filterInput3) + '\'';
                } else if (selFilterOp3 == 'not equals') {
                    strQuery += ' AND  (' + selFilterField3 + '  != \'' + String.escapeSingleQuotes(filterInput3) + '\')';
                }
            }
            strQuery += 'ORDER BY GFERP__Expected_Receipt_Date__c ASC';
            thePLList = Database.query(strQuery);
            */
            List<Id> itemIds = new List<Id>();

            for (GFERP__Item__c item : (List<GFERP__Item__c>) stdCon.getRecords()) {
                itemIds.add(item.Id);
            }

            //Local On hand
            Map<Id, Decimal> mapLocalOnHand = new Map<Id, Decimal>();
            strQuery = 'SELECT GFERP__Item__c, SUM(GFERP__Qty_Base__c) Quantity FROM GFERP__Warehouse_Entry__c WHERE GFERP__Item__c IN :itemIds AND GFERP__Warehouse__c IN :SetLocalWhseId AND GFERP__Bin_Content__r.GFERP__Bin_Type__c != \'QC\'';
            if (!String.isEmpty(selFilterField3) && !String.isEmpty(filterInput3)) {
                if (selFilterOp3 == 'equals') {
                    strQuery += ' AND ' + selFilterField3 + ' = \'' + String.escapeSingleQuotes(filterInput3) + '\'';
                } else if (selFilterOp3 == 'not equals') {
                    strQuery += ' AND  (' + selFilterField3 + ' != \'' + String.escapeSingleQuotes(filterInput3) + '\')';
                }
            }
            if (onHandAsOfDate != null) {
                strQuery += ' AND GFERP__Posting_Date__c <: onHandAsOfDate';
            }
            strQuery += ' GROUP BY GFERP__Item__c';
            results = Database.query(strQuery);
            for (AggregateResult result : results) {
                mapLocalOnHand.put((Id) result.get('GFERP__Item__c'), (Decimal) result.get('Quantity'));
            }

            //Vendor On hand
            Map<Id, Decimal> mapVendorOnHand = new Map<Id, Decimal>();
            strQuery = 'SELECT GFERP__Item__c, SUM(GFERP__Qty_Base__c) Quantity FROM GFERP__Warehouse_Entry__c WHERE GFERP__Item__c IN :itemIds AND GFERP__Warehouse__c IN :SetVendorWhseId AND GFERP__Bin_Content__r.GFERP__Bin_Type__c != \'QC\'';
            if (!String.isEmpty(selFilterField3) && !String.isEmpty(filterInput3)) {
                if (selFilterOp3 == 'equals') {
                    strQuery += ' AND ' + selFilterField3 + ' = \'' + String.escapeSingleQuotes(filterInput3) + '\'';
                } else if (selFilterOp3 == 'not equals') {
                    strQuery += ' AND  (' + selFilterField3 + ' != \'' + String.escapeSingleQuotes(filterInput3) + '\')';
                }
            }
            if (onHandAsOfDate != null) {
                strQuery += ' AND GFERP__Posting_Date__c <: onHandAsOfDate';
            }
            strQuery += ' GROUP BY GFERP__Item__c';
            results = Database.query(strQuery);
            for (AggregateResult result : results) {
                mapVendorOnHand.put((Id) result.get('GFERP__Item__c'), (Decimal) result.get('Quantity'));
            }

            //Customer On hand
            Map<Id, Decimal> mapCustomerOnHand = new Map<Id, Decimal>();
            strQuery = 'SELECT Item_No__c, Count_Qty__c, Week_End_Date__c FROM Customer_Inventory_Count__c WHERE Item_No__c IN :itemIds';
            //strQuery = 'SELECT Item_No__c, SUM(Count_Qty__c) Quantity FROM Customer_Inventory_Count__c WHERE Item_No__c IN :itemIds';
            //strQuery = 'SELECT GFERP__Item__c, SUM(GFERP__Qty_Base__c) Quantity FROM GFERP__Bin_Content__c WHERE GFERP__Item__c IN :itemIds AND GFERP__Warehouse__c IN :SetCustomerWhseId';
            /*
            if (!String.isEmpty(selFilterField3) && !String.isEmpty(filterInput3)) {
                if (selFilterOp3 == 'equals') {
                    strQuery += ' AND ' + selFilterField3 + '  = \'' + String.escapeSingleQuotes(filterInput3) + '\'';
                } else if (selFilterOp3 == 'not equals') {
                    strQuery += ' AND  (' + selFilterField3 + '  != \'' + String.escapeSingleQuotes(filterInput3) + '\')';
                }
            }*/
            //strQuery += ' GROUP BY GFERP__Item__c';
            if (onHandAsOfDate != null) {
                strQuery += ' AND Week_End_Date__c <: onHandAsOfDate';
            }
            //strQuery += ' GROUP BY Item_No__c, Week_End_Date__c, Count_Qty__c';
            strQuery += ' ORDER BY Week_End_Date__c DESC';
            List<Customer_Inventory_Count__c> results1 = Database.query(strQuery);
            //for (AggregateResult result : results) {
            for (Customer_Inventory_Count__c result : results1) {
                if(mapCustomerOnHand.get((Id) result.get('Item_No__c')) == null)
                    mapCustomerOnHand.put((Id) result.get('Item_No__c'), (Decimal) result.get('Count_Qty__c'));
            }

            Map<Id, wrapItem> mapWItem = new Map<Id, wrapItem>();

            for (GFERP__Item__c Item : (List<GFERP__Item__c>) stdCon.getRecords()) {
                mapWItem.put(Item.Id, new wrapItem(Item));
                //Local on hand
                if (mapLocalOnHand.containsKey(Item.Id)) {
                    mapWItem.get(Item.Id).LocalQtyOnHand = mapLocalOnHand.get(Item.Id);
                } else {
                    mapWItem.get(Item.Id).LocalQtyOnHand = 0;
                }
                //Vendor on hand
                if (mapVendorOnHand.containsKey(Item.Id)) {
                    mapWItem.get(Item.Id).VendorQtyOnHand = mapVendorOnHand.get(Item.Id);
                } else {
                    mapWItem.get(Item.Id).VendorQtyOnHand = 0;
                }
                //Customer on hand
                if (mapCustomerOnHand.containsKey(Item.Id)) {
                    mapWItem.get(Item.Id).CustomerQtyOnHand = mapCustomerOnHand.get(Item.Id);
                } else {
                    mapWItem.get(Item.Id).CustomerQtyOnHand = 0;
                }
            }

            string ItemId;
            String itemFieldName = 'GFERP__Item__c';
            // on PO
            strQuery = 'SELECT GFERP__Item__c, SUM(GFERP__O_S_Qty_Base__c) outstandingQuantity ' +
                    'FROM GFERP__Purchase_Line__c ' +
                    'WHERE GFERP__Purchase_Order__r.GFERP__Closed__c = false ' +
                    'AND GFERP__Item_Type__c = \'Inventory\'';
//            if (!String.isEmpty(selFilterField3) && !String.isEmpty(filterInput3)) {
//                if (selFilterOp3 == 'equals') {
//                    strQuery += ' AND ' + selFilterField3 + '  = \'' + String.escapeSingleQuotes(filterInput3) + '\'';
//                } else if (selFilterOp3 == 'not equals') {
//                    strQuery += ' AND  (' + selFilterField3 + '  != \'' + String.escapeSingleQuotes(filterInput3) + '\')';
//                }
//            }
            strQuery += ' GROUP BY GFERP__Item__c';

            for (AggregateResult ar : Database.query(strQuery)) {
                //ItemId = string.valueOf(ar.get('Unit_of_Measure__c'));
                ItemId = string.valueOf(ar.get(itemFieldName));
                if (!mapWItem.containsKey(ItemId)) continue;
                wrapItem wItem = mapWItem.get(ItemId);
                wItem.QtyonPO = decimal.valueOf(string.valueOf(ar.get('outstandingQuantity'))).setScale(5, RoundingMode.HALF_UP);
            }

            // on SO
            strQuery = 'SELECT SUM(GFERP__O_S_Qty_Base__c) outstandingQuantity, GFERP__Item__c ' +
                    'FROM GFERP__Sales_Line__c ' +
                    'WHERE GFERP__Sales_Order__r.GFERP__Closed__c = false ' +
                    'AND GFERP__Item_Type__c = \'Inventory\'';
            if (!String.isEmpty(selFilterField3) && !String.isEmpty(filterInput3)) {
                if (selFilterOp3 == 'equals') {
                    strQuery += ' AND ' + selFilterField3 + '  = \'' + String.escapeSingleQuotes(filterInput3) + '\'';
                } else if (selFilterOp3 == 'not equals') {
                    strQuery += ' AND  (' + selFilterField3 + '  != \'' + String.escapeSingleQuotes(filterInput3) + '\')';
                }
            }
            strQuery += ' GROUP BY GFERP__Item__c';

            for (AggregateResult ar : Database.query(strQuery)) {
                ItemId = string.valueOf(ar.get(itemFieldName));
                if (!mapWItem.containsKey(ItemId)) continue;
                wrapItem wItem = mapWItem.get(ItemId);
                wItem.QtyonSO = decimal.valueOf(string.valueOf(ar.get('outstandingQuantity'))).setScale(5, RoundingMode.HALF_UP);
            }
            for (wrapItem wItem : mapWItem.values()) {
                wItem.QtyAvailable = wItem.LocalQtyOnHand + wItem.VendorQtyOnHand - wItem.QtyOnSO + wItem.QtyOnPO;
                decimal SafetyStock;
                if (wItem.theItem.GFERP__Safety_Stock__c == null) {
                    SafetyStock = 0;
                } else {
                    SafetyStock = wItem.theItem.GFERP__Safety_Stock__c;
                }
                wItem.Variance = wItem.LocalQtyOnHand - SafetyStock;
            }
            return mapWItem.values();
        }
    }

    public List<SelectOption> getPageSizeSelectOptions() {
        List<SelectOption> fieldOptions = new List<SelectOption>();
        fieldOptions.add(new SelectOption('25', '25'));
        fieldOptions.add(new SelectOption('50', '50'));
        fieldOptions.add(new SelectOption('100', '100'));
        return fieldOptions;
    }

    public List<SelectOption> lstFilterField {
        get {
            if (lstFilterField == null) {
                lstFilterField = new List<SelectOption>();
                lstFilterField.add(new SelectOption('Name', 'Item No.'));
                lstFilterField.add(new SelectOption('Description__c', 'Item Description'));
            }
            return lstFilterField;
        }
        set;
    }

    public List<SelectOption> lstFilterOperator {
        get {
            if (lstFilterOperator == null) {
                lstFilterOperator = new List<SelectOption>();
                lstFilterOperator.add(new SelectOption('contains', 'contains'));
                lstFilterOperator.add(new SelectOption('not contains', 'not contains'));
                lstFilterOperator.add(new SelectOption('equals', 'equals'));
                lstFilterOperator.add(new SelectOption('not equals', 'not equals'));
            }
            return lstFilterOperator;
        }
        set;
    }

    public List<SelectOption> lstFilterField2 {
        get {
            if (lstFilterField2 == null) {
                lstFilterField2 = new List<SelectOption>();
                lstFilterField2.add(new SelectOption('GFERP__Item_Category__r.Name', 'Item Category'));
            }
            return lstFilterField2;
        }
        set;
    }

    public List<SelectOption> lstFilterOperator2 {
        get {
            if (lstFilterOperator2 == null) {
                lstFilterOperator2 = new List<SelectOption>();
                lstFilterOperator2.add(new SelectOption('equals', 'equals'));
                lstFilterOperator2.add(new SelectOption('not equals', 'not equals'));
            }
            return lstFilterOperator2;
        }
        set;
    }

    public List<SelectOption> lstfilterInput2 {
        get {
            if (lstfilterInput2 == null) {
                lstfilterInput2 = new List<SelectOption>();
                lstfilterInput2.add(new SelectOption('', ''));
                List<GFERP__Item_Category__c> lstItemCategory = new List<GFERP__Item_Category__c>([SELECT Id, Name FROM GFERP__Item_Category__c ORDER BY Name]);
                system.debug('lstItemCategory***' + lstItemCategory);
                if (lstItemCategory != null && lstItemCategory.size() > 0) {
                    for (GFERP__Item_Category__c theIC : lstItemCategory) {
                        lstfilterInput2.add(new SelectOption(theIC.Name, theIC.Name));
                    }
                }
            }
            return lstfilterInput2;
        }
        set;
    }
    
    public List<SelectOption> lstFilterField6 {
        get {
            if (lstFilterField6 == null) {
                lstFilterField6 = new List<SelectOption>();
                lstFilterField6.add(new SelectOption('GFERP__Brand__c', 'Brand'));
            }
            return lstFilterField6;
        }
        set;
    }

    public List<SelectOption> lstFilterOperator6 {
        get {
            if (lstFilterOperator6 == null) {
                lstFilterOperator6 = new List<SelectOption>();
                lstFilterOperator6.add(new SelectOption('equals', 'equals'));
                lstFilterOperator6.add(new SelectOption('not equals', 'not equals'));
            }
            return lstFilterOperator6;
        }
        set;
    }

    public List<SelectOption> lstfilterInput6 {
        get {
            if (lstfilterInput6 == null) {
                lstfilterInput6 = new List<SelectOption>();
                lstfilterInput6.add(new SelectOption('', ''));
                List<PicklistEntry> brandOpts = GFERP__Item__c.GFERP__Brand__c.getDescribe().getPicklistValues();
                for (PicklistEntry pickEntry : brandOpts ) {
                   lstfilterInput6.add(new SelectOption(pickEntry.getValue(), pickEntry.getLabel()));
                }
            }
            return lstfilterInput6;
        }
        set;
    }

    public List<SelectOption> lstFilterField3 {
        get {
            if (lstFilterField3 == null) {
                lstFilterField3 = new List<SelectOption>();
                lstFilterField3.add(new SelectOption('GFERP__Warehouse__r.Name', 'Warehouse'));
            }
            return lstFilterField3;
        }
        set;
    }

    public List<SelectOption> lstFilterOperator3 {
        get {
            if (lstFilterOperator3 == null) {
                lstFilterOperator3 = new List<SelectOption>();
                lstFilterOperator3.add(new SelectOption('equals', 'equals'));
                lstFilterOperator3.add(new SelectOption('not equals', 'not equals'));
            }
            return lstFilterOperator3;
        }
        set;
    }

    public List<SelectOption> lstfilterInput3 {
        get {
            if (lstfilterInput3 == null) {
                lstfilterInput3 = new List<SelectOption>();
                lstfilterInput3.add(new SelectOption('', ''));
                List<GFERP__Warehouse__c> lstWarehouse = new List<GFERP__Warehouse__c>([
                        SELECT Id, Name
                        FROM GFERP__Warehouse__c
                        WHERE
                        (FPC_Local_Warehouse__c = :true OR FPC_Vendor_Warehouse__c = :true) ORDER BY Name
                ]);
                if (lstWarehouse != null && lstWarehouse.size() > 0) {
                    for (GFERP__Warehouse__c theWhse : lstWarehouse) {
                        lstfilterInput3.add(new SelectOption(theWhse.Name, theWhse.Name));
                    }
                }
            }
            return lstfilterInput3;
        }
        set;
    }

    public List<SelectOption> lstFilterField4 {
        get {
            if (lstFilterField4 == null) {
                lstFilterField4 = new List<SelectOption>();
                lstFilterField4.add(new SelectOption('GFERP__Vendor__r.Name', 'Preferred Vendor'));
            }
            return lstFilterField4;
        }
        set;
    }

    public List<SelectOption> lstFilterOperator4 {
        get {
            if (lstFilterOperator4 == null) {
                lstFilterOperator4 = new List<SelectOption>();
                lstFilterOperator4.add(new SelectOption('equals', 'equals'));
                lstFilterOperator4.add(new SelectOption('not equals', 'not equals'));
            }
            return lstFilterOperator4;
        }
        set;
    }

    public List<SelectOption> lstfilterInput4 {
        get {
            if (lstfilterInput4 == null) {
                lstfilterInput4 = new List<SelectOption>();
                lstfilterInput4.add(new SelectOption('', ''));
                Set<Id> SetVendorId = new Set<Id>();
                List<GFERP__Item__c> lstItem = new List<GFERP__Item__c>([SELECT Id, GFERP__Vendor__c FROM GFERP__Item__c]);
                FOR (GFERP__Item__c theItem : [SELECT Id, GFERP__Vendor__c FROM GFERP__Item__c WHERE GFERP__Vendor__c != null]){
                    SetVendorId.add(theItem.GFERP__Vendor__c);
                }
                List<Account> lstVendor = new List<Account>([SELECT Id, Name FROM Account WHERE Id =: SetVendorId ORDER BY Name] );
                if (lstVendor != null && lstVendor.size() > 0) {
                    for (Account theAccount : lstVendor) {
                        lstfilterInput4.add(new SelectOption(theAccount.Name, theAccount.Name));
                    }
                }
            }
            return lstfilterInput4;
        }
        set;
    }

    public List<SelectOption> lstFilterField5 {
        get {
            if (lstFilterField5 == null) {
                lstFilterField5 = new List<SelectOption>();
                lstFilterField5.add(new SelectOption('GFERP__Safety_Stock__c', 'Safety'));
            }
            return lstFilterField5;
        }
        set;
    }

    public List<SelectOption> lstFilterOperator5 {
        get {
            if (lstFilterOperator5 == null) {
                lstFilterOperator5 = new List<SelectOption>();
                lstFilterOperator5.add(new SelectOption('>', 'greater than'));
                lstFilterOperator5.add(new SelectOption('=', 'equal'));
                lstFilterOperator5.add(new SelectOption('<', 'less than'));
            }
            return lstFilterOperator5;
        }
        set;
    }

/*************** Warpper Class *******************/
    public class wrapItem {
        public Id WarehouseId { get; set; }
        public GFERP__Item__c theItem { get; set; }
        public Decimal LocalQtyOnHand { get; set; }
        public Decimal VendorQtyOnHand { get; set; }
        public Decimal CustomerQtyOnHand { get; set; }
        public Decimal QtyAvailable { get; set; }
        public Decimal QtyOnSO { get; set; }
        public Decimal QtyOnPO { get; set; }
        public Decimal Variance { get; set; }

        public wrapItem(GFERP__Item__c Item) {
            this.WarehouseId = null;
            theItem = Item;
            LocalQtyOnHand = 0;
            VendorQtyOnHand = 0;
            CustomerQtyOnHand = 0;
            QtyAvailable = 0;
            QtyOnPO = 0;
            QtyOnSO = 0;
            Variance = 0;
        }
    }

/********************** Pagination *************************/
    public ApexPages.StandardSetController stdCon;

    public void resetPageSize(){
        stdCon.setPageSize(pageSize);
    }
    public voId search() {
        System.debug('Search Called=======>' + selFilterField);
        String SearchType = ApexPages.CurrentPage().getParameters().get('theSearch');
        String strQuery = '';
        strQuery = 'SELECT Name,GFERP__Vendor__r.Name, GFERP__Safety_Stock__c, GFERP__Base_UOM_Record_Id__c, GFERP__Base_Unit_of_Measure__r.Name,GFERP__Description__c, GFERP__Item_Category__r.Name, GFERP__Standard_Base_Price__c, GFERP__Standard_Base_Cost__c, GFERP__Brand__c ' +
                'FROM GFERP__Item__c WHERE GFERP__Item_Type__c=\'Inventory\'';
//strQuery += ' AND Item__r.Name = \'7000FIFOLOT\' AND Unit_of_Measure__r.Name = \'LB\'';   // for testing
        if (String.isBlank(selFilterField) && SearchType == 'Item') {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'Please Select Field to Filter'));
        } else {
            System.debug('criteria met=======>' + selFilterOp);
            if (!String.isEmpty(selFilterField) && !String.isEmpty(filterInput)) {

                if (selFilterOp == 'contains') {
                    strQuery += ' AND ' + selFilterField + ' LIKE \'%' + String.escapeSingleQuotes(filterInput) + '%\'';
                } else if (selFilterOp == 'not contains') {
                    strQuery += ' AND  (NOT ' + selFilterField + ' LIKE \'%' + String.escapeSingleQuotes(filterInput) + '%\')';
                } else if (selFilterOp == 'equals') {
                    strQuery += ' AND ' + selFilterField + ' = \'' + String.escapeSingleQuotes(filterInput) + '\'';
                } else if (selFilterOp == 'not equals') {
                    strQuery += ' AND  (' + selFilterField + ' != \'' + String.escapeSingleQuotes(filterInput) + '\')';
                }
            }

            if (!String.isEmpty(selFilterField2) && !String.isEmpty(filterInput2)) {
                if (selFilterOp2 == 'equals') {
                    strQuery += ' AND ' + selFilterField2 + ' = \'' + String.escapeSingleQuotes(filterInput2) + '\'';
                } else if (selFilterOp2 == 'not equals') {
                    strQuery += ' AND  (' + selFilterField2 + ' != \'' + String.escapeSingleQuotes(filterInput2) + '\')';
                }
            }
            filterString = selFilterField2 + '/' + filterInput2;

            if (!String.isEmpty(selFilterField6) && !String.isEmpty(filterInput6)) {
                if (selFilterOp6 == 'equals') {
                    strQuery += ' AND ' + selFilterField6 + ' = \'' + String.escapeSingleQuotes(filterInput6) + '\'';
                } else if (selFilterOp6 == 'not equals') {
                    strQuery += ' AND  (' + selFilterField6 + ' != \'' + String.escapeSingleQuotes(filterInput6) + '\')';
                }
            }
            filterString += '/'+selFilterField6 + '/' + filterInput6;

            filterString += '/' + selFilterField4 + '/' + filterInput4;
            if (!String.isEmpty(selFilterField4) && !String.isEmpty(filterInput4)) {
                if (selFilterOp4 == 'equals') {
                    strQuery += ' AND ' + selFilterField4 + '  = \'' + String.escapeSingleQuotes(filterInput4) + '\'';
                } else if (selFilterOp4 == 'not equals') {
                    strQuery += ' AND  (' + selFilterField4 + '  != \'' + String.escapeSingleQuotes(filterInput4) + '\')';
                }
            }
            if (!String.isEmpty(selFilterField5) && !String.isEmpty(filterInput5)) {
                strQuery += ' AND ' + selFilterField5 + ' ' + selFilterOp5 + ' ' + filterInput5;
            }
            strQuery += ' ORDER BY '+sortExp+' '+sortDirection+' NULLS LAST';
            System.debug('-->strQuery : ' + strQuery);
            filterString += strQuery;
            stdCon = new ApexPages.StandardSetController(Database.getQueryLocator(strQuery));
            stdCon.setPageSize(pageSize);
        }
    }

    public String sortExpression {
        get {return sortExp;}
        set {sortDirection = (sortDirection == 'ASC') ? 'DESC' : 'ASC';}
    }

    public String getSortDirection() {
        if (sortExpression == null || sortExpression == '') return 'ASC'; else return sortDirection;
    }

    public List<SelectOption> getSortBySelectOptionsOptions() {
        List<SelectOption> fieldOptions = new List<SelectOption>();
        fieldOptions.add(new SelectOption('Name', 'Item'));
        fieldOptions.add(new SelectOption('GFERP__Base_Unit_of_Measure__r.Name', 'Unit of Measure'));
        fieldOptions.add(new SelectOption('GFERP__Item_Category__r.Name', 'Item Category'));
        fieldOptions.add(new SelectOption('GFERP__Safety_Stock__c', 'Safety Stock'));
        return fieldOptions;
    }

// indicates whether there are more records after the current page set.
    public Boolean hasNext {
        get {
            return stdCon.getHasNext();
        }
        set;
    }

// indicates whether there are more records before the current page set.
    public Boolean hasPrevious {
        get {
            return stdCon.getHasPrevious();
        }
        set;
    }

// returns the page number of the current page set
    public Integer pageNumber {
        get {
            return stdCon.getPageNumber();
        }
        set;
    }

// returns the first page of records
    public voId first() {
        stdCon.first();
    }

// returns the last page of records
    public voId last() {
        stdCon.last();
    }

// returns the previous page of records
    public voId previous() {
        stdCon.previous();
    }

// returns the next page of records
    public voId next() {
        stdCon.next();
    }

    public String paginationStat {
        get {
            Integer pageRangeStart = ((stdCon.getPageNumber() - 1) * pagesize) + 1;
            Integer pageRangeEnd = stdCon.getPageNumber() * pagesize;
            if (pageRangeEnd > stdCon.getResultSize()) {
                pageRangeEnd = stdCon.getResultSize();
            }
            return 'Showing  ' + pageRangeStart + '  to  ' +
                    pageRangeEnd + '  of  ' + stdCon.getResultSize() ;
        }
    }

    public Boolean hasRecords {
        get {
            return stdCon.getResultSize() > 0;
        }
    }

    public voId Infoby() {
        search();
    }

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public Id ItemId { get; set; }
    public String method { get; set; }
    public String SelNum { get; set; }
    public List<Customer_Inventory_Count__c> CIC { get; set; }
    
    public List<GFERP__Bin_Content__c> BC { get; set; }
    public List<GFERP__Purchase_Line__c> QPO { get; set; }
    public List<GFERP__Sales_Line__c > QSO { get; set; }

    public void getLocalQTYinfo() {
        String strQuery = 'SELECT Id, Name, GFERP__Available__c, GFERP__Quantity__c, GFERP__Qty_Base__c, GFERP__Expiration_Date__c, GFERP__Unit_of_Measure__r.Name, GFERP__Warehouse__r.Name, GFERP__Bin__c, GFERP__Bin__r.Name ' +
                'FROM GFERP__Bin_Content__c ' +
                'WHERE GFERP__Quantity__c != 0 AND GFERP__Item__c = :ItemId AND GFERP__Warehouse__c IN : SetLocalWhseId AND GFERP__Bin_Type__c != \'QC\'';
        if (!String.isEmpty(selFilterField3) && !String.isEmpty(filterInput3)) {
            if (selFilterOp3 == 'equals') {
                strQuery += ' AND ' + selFilterField3 + '  = \'' + String.escapeSingleQuotes(filterInput3) + '\'';
            } else if (selFilterOp3 == 'not equals') {
                strQuery += ' AND  (' + selFilterField3 + '  != \'' + String.escapeSingleQuotes(filterInput3) + '\')';
            }
        }
        strQuery += ' ORDER BY GFERP__Expiration_Date__c ASC LIMIT 200';
        BC = Database.query(strQuery);
    }

    public void getVendorQTYinfo() {
        String strQuery = 'SELECT Id, Name, GFERP__Available__c, GFERP__Quantity__c, GFERP__Qty_Base__c, GFERP__Expiration_Date__c, GFERP__Unit_of_Measure__r.Name, GFERP__Warehouse__r.Name, GFERP__Bin__c, GFERP__Bin__r.Name ' +
                'FROM GFERP__Bin_Content__c ' +
                'WHERE GFERP__Quantity__c != 0 AND GFERP__Item__c = :ItemId AND GFERP__Warehouse__c IN : SetVendorWhseId AND GFERP__Bin_Type__c != \'QC\'';
        if (!String.isEmpty(selFilterField3) && !String.isEmpty(filterInput3)) {
            if (selFilterOp3 == 'equals') {
                strQuery += ' AND ' + selFilterField3 + '  = \'' + String.escapeSingleQuotes(filterInput3) + '\'';
            } else if (selFilterOp3 == 'not equals') {
                strQuery += ' AND  (' + selFilterField3 + '  != \'' + String.escapeSingleQuotes(filterInput3) + '\')';
            }
        }
        strQuery += ' ORDER BY GFERP__Expiration_Date__c ASC LIMIT 200';
        BC = Database.query(strQuery);
    }

    public void getCustomerQTYinfo() {
        /*String strQuery = 'SELECT Id, Name, GFERP__Available__c, GFERP__Quantity__c, GFERP__Qty_Base__c, GFERP__Expiration_Date__c, GFERP__Unit_of_Measure__r.Name, GFERP__Warehouse__r.Name, GFERP__Bin__c, GFERP__Bin__r.Name ' +
                'FROM GFERP__Bin_Content__c ' +
                'WHERE GFERP__Quantity__c != 0 AND GFERP__Item__c = :ItemId AND GFERP__Warehouse__c IN : SetCustomerWhseId';*/
        String strQuery = 'SELECT Id, Name, Week_End_Date__c, Last_Week_End_Date__c, Week_Usage__c, Count_Qty__c, Customer__r.Name, Previous_Count_Qty__c, Item_No__c, Item_No__r.Name ' +
                'FROM Customer_Inventory_Count__c ' +
                //'WHERE Count_Qty__c != 0 AND Item_No__c = :ItemId';
                'WHERE Item_No__c = :ItemId';
        
        /*
        if (!String.isEmpty(selFilterField3) && !String.isEmpty(filterInput3)) {
            if (selFilterOp3 == 'equals') {
                strQuery += ' AND ' + selFilterField3 + '  = \'' + String.escapeSingleQuotes(filterInput3) + '\'';
            } else if (selFilterOp3 == 'not equals') {
                strQuery += ' AND  (' + selFilterField3 + '  != \'' + String.escapeSingleQuotes(filterInput3) + '\')';
            }
        }*/
        if (onHandAsOfDate != null) {
            strQuery += ' AND Week_End_Date__c <: onHandAsOfDate';
        }
        strQuery += ' ORDER BY Week_End_Date__c DESC LIMIT 1';

        CIC = Database.query(strQuery);
    }
    public voId getQPOinfo() {
        String strQuery = '';
        if (ItemId != null) {
            strQuery = 'SELECT Id, GFERP__Purchase_Order__c, GFERP__Purchase_Order__r.Name, GFERP__Vendor__c, GFERP__Outstanding_Qty__c, GFERP__Unit_of_Measure__r.Name, GFERP__O_S_Qty_Base__c, GFERP__Expected_Receipt_Date__c ' +
                    'FROM GFERP__Purchase_Line__c ' +
                    'WHERE GFERP__Item__c = :ItemId AND GFERP__O_S_Qty_Base__c <> 0.0 ' +
                    'AND GFERP__Purchase_Order__r.GFERP__Closed__c = false ' +
                    'AND GFERP__Purchase_Order__r.GFERP__Return_Order__c != true ';
        } else {
            strQuery = 'SELECT Id, GFERP__Purchase_Order__c, GFERP__Purchase_Order__r.Name, GFERP__Vendor__c, GFERP__Outstanding_Qty__c, GFERP__Unit_of_Measure__r.Name, GFERP__O_S_Qty_Base__c, GFERP__Expected_Receipt_Date__c ' +
                    'FROM GFERP__Purchase_Line__c ' +
                    'WHERE GFERP__Item__c = :ItemId AND GFERP__O_S_Qty_Base__c <> 0.0 ' +
                    'AND GFERP__Purchase_Order__r.GFERP__Closed__c = false ' +
                    'AND GFERP__Purchase_Order__r.GFERP__Return_Order__c != true ';
        }
        if (!String.isEmpty(selFilterField3) && !String.isEmpty(filterInput3)) {
            if (selFilterOp3 == 'equals') {
                strQuery += ' AND ' + selFilterField3 + '  = \'' + String.escapeSingleQuotes(filterInput3) + '\'';
            } else if (selFilterOp3 == 'not equals') {
                strQuery += ' AND  (' + selFilterField3 + '  != \'' + String.escapeSingleQuotes(filterInput3) + '\')';
            }
        }
        strQuery += ' ORDER BY GFERP__Expected_Receipt_Date__c ASC LIMIT 200';
        QPO = Database.query(strQuery);
    }

    public voId getQSOinfo() {
        String strQuery = '';
        if (ItemId != null) {
            strQuery = 'SELECT Id, GFERP__Sales_Order__r.Name, GFERP__Sell_to_Customer__c, GFERP__Sales_Order__r.GFERP__Alternate_Shipping__c, GFERP__Outstanding_Qty__c, GFERP__O_S_Qty_Base__c, GFERP__Item__c, GFERP__Item__r.Name, GFERP__Shipment_Date__c, GFERP__Unit_of_Measure__r.Name ' +
                    'FROM GFERP__Sales_Line__c ' +
                    'WHERE GFERP__Item__c = :ItemId AND GFERP__O_S_Qty_Base__c <> 0.0 ' +
                    'AND GFERP__Sales_Order__r.GFERP__Closed__c = false ' +
                    'AND GFERP__Sales_Order__r.GFERP__Return_Order__c != true ';
        } else {
            strQuery = 'SELECT Id, GFERP__Sales_Order__r.Name, GFERP__Sell_to_Customer__c, GFERP__Sales_Order__r.GFERP__Alternate_Shipping__c, GFERP__Outstanding_Qty__c, GFERP__O_S_Qty_Base__c, GFERP__Item__c, GFERP__Item__r.Name, GFERP__Shipment_Date__c, GFERP__Unit_of_Measure__r.Name ' +
                    'FROM GFERP__Sales_Line__c ' +
                    'WHERE GFERP__Item__c = :ItemId AND GFERP__O_S_Qty_Base__c <> 0.0 ' +
                    'AND GFERP__Sales_Order__r.GFERP__Closed__c = false ' +
                    'AND GFERP__Sales_Order__r.GFERP__Return_Order__c != true ';
        }

        if (!String.isEmpty(selFilterField3) && !String.isEmpty(filterInput3)) {
            if (selFilterOp3 == 'equals') {
                strQuery += ' AND ' + selFilterField3 + '  = \'' + String.escapeSingleQuotes(filterInput3) + '\'';
            } else if (selFilterOp3 == 'not equals') {
                strQuery += ' AND  (' + selFilterField3 + '  != \'' + String.escapeSingleQuotes(filterInput3) + '\')';
            }
        }
        strQuery += ' ORDER BY GFERP__Shipment_Date__c ASC LIMIT 200';
        QSO = Database.query(strQuery);
    }

    public Pagereference ExportToExcel() {
        String URL = '/apex/ItemAvailabilityStatusExcel?filterInput=' + filterInput + '&selFilterField=' + selFilterField +
                '&selFilterOp=' + selFilterOp + '&filterInput2=' + filterInput2 + '&selFilterField2=' + selFilterField2 +
                '&selFilterOp2=' + selFilterOp2 + '&filterInput3=' + filterInput3 + '&selFilterField3=' + selFilterField3 +
                '&selFilterOp3=' + selFilterOp3 + '&filterInput4=' + filterInput4 + '&selFilterField4=' + selFilterField4 +
                '&selFilterOp4=' + selFilterOp4 + '&filterInput5=' + filterInput5 + '&selFilterField5=' + selFilterField5 +
                '&selFilterOp5=' + selFilterOp5 + '&filterInput6=' + filterInput6 + '&selFilterField6=' + selFilterField6 +
                '&selFilterOp6=' + selFilterOp6 + '&onHandAsOfDate=' + onHandAsOfDate.month()+'/'+onHandAsOfDate.day()+'/'+onHandAsOfDate.year();
        PageReference pageRef = new PageReference(URL);
        pageRef.setRedirect(true);
        return pageRef;
    }

    public class DataException extends exception {
    }
}