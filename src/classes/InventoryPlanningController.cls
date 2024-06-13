public with sharing class InventoryPlanningController {

    public transient List<ItemLine> itemLineList { get; set; }
    public transient List<ItemLine> itemLineSublist { get; set; }
    public Map<String, ItemLine> itemLineMap;
    public date lastDayofWeekOfInterest;
    public date lastDayofLastWeek;
    public Date reportingDate { get; set; }
    public GFERP__Sales_Order__c theDate { get; set; }
    public List<stringObj> varianceGuide { get; set; }
    public List<stringObj> lowWeeks { get; set; }
//    public List<SelectOption> vendorOptions { get; set; }
    public List<SelectOption> customerOptions { get; set; }
//    public String selectedVendor { get; set; }
    public String[] selectedCustomers { get; set; }
    public Set<Id> selectedWhseIds;
    public Set<Id> local3PLWhseIds;

    private integer counter = 0;
    public Integer total_size = 0;
    public Integer list_size { get; set; }
    public String sortExp { get; set; }
    private String sortDirection = 'ASC';
    public String itemSearchKey { get; set; }
    public Date todaysDate { get; set; }
    public String selectedLowWeek { get; set; }
    public String itemNoInput { get; set; }
    public String selFilterOp { get; set; }
    public List<Customer_Inventory_Count__c> viewCICList { get; set; }
    public Id viewItem { get; set; }
    public String listString { get; set; }
    public String viewType { get; set; }

    public InventoryPlanningController() {
        String reportingDateString = ApexPages.CurrentPage().getParameters().get('reportingDate');
        if(reportingDateString != null && reportingDateString != 'null'){
            reportingDate = date.parse(reportingDateString);
        } else {
            reportingDate = Date.today();
        }
        lastDayofWeekOfInterest = reportingDate.toStartOfWeek().addDays(6);
        lastDayofLastWeek = reportingDate.toStartOfWeek().addDays(-1);

        String warehouses = ApexPages.CurrentPage().getParameters().get('warehouses');
        if (warehouses != null) {
            List<String> whseList = warehouses.split(',');
            selectedWhseIds = new Set<Id>();
            for (String whseId : whseList) {
                selectedWhseIds.add(whseId);
            }
        }

        String customers = ApexPages.CurrentPage().getParameters().get('customers');
        if (String.isNotBlank(customers)) {
            selectedCustomers = customers.split(',');
        }

        String local3PLWhseIdsString = ApexPages.CurrentPage().getParameters().get('local3PLWhseIds');
        if (String.isNotBlank(local3PLWhseIdsString)) {
            List<String> local3PLWhseList = local3PLWhseIdsString.split(',');
            local3PLWhseIds = new Set<Id>();
            for (String whseId : local3PLWhseList) {
                local3PLWhseIds.add(whseId);
            }
        }

        selectedLowWeek = ApexPages.CurrentPage().getParameters().get('selectedLowWeek');
        selFilterOp = ApexPages.CurrentPage().getParameters().get('selFilterOp');
        itemNoInput = ApexPages.CurrentPage().getParameters().get('itemNoInput');
        if (itemNoInput == 'null') {
            itemNoInput = null;
        }
        sortExp = ApexPages.CurrentPage().getParameters().get('sortExp');
        sortDirection = ApexPages.CurrentPage().getParameters().get('sortDir');
        if (sortExp == 'null') {
            itemNoInput = null;
        }
        if (sortDirection != 'DESC') {
            sortDirection = 'ASC';
        }
        todaysDate = Date.today();
        if ((String.isNotBlank(selectedLowWeek) && (selectedLowWeek == 'lessThan4' || selectedLowWeek == 'from4to12')) || sortExp == 'LocalOnHand') {
            theDate = new GFERP__Sales_Order__c(GFERP__Requested_Shipment_Date__c = reportingDate);
            filterOnLowWeeks();
        } else {
            initItemLineTable();
            selectBeginAndEndCount();
            itemLineList = itemLineMap.values();
        }
    }

    public InventoryPlanningController(ApexPages.StandardSetController controller) {
        theDate = new GFERP__Sales_Order__c(GFERP__Requested_Shipment_Date__c = Date.today());
        itemLineList = new List<ItemLine>();
        selectedCustomers = new String[]{};
        sortExp = 'Name';
        initItemLineTable();
        initGuide();
        selectWeeks();
        selectBeginAndEndCount();
        paginationInit();
        selectAccounts();
    }

    public InventoryPlanningController(Date selectedDate) {
        theDate = new GFERP__Sales_Order__c(GFERP__Requested_Shipment_Date__c = selectedDate);
        itemLineList = new List<ItemLine>();
        selectedCustomers = new String[]{};
        sortExp = 'Name';
        initItemLineTable();
        initGuide();
        selectWeeks();
        selectBeginAndEndCount();
        paginationInit();
        selectAccounts();
    }

    public void selectCustomerRefreshTheReport() {
        selectedWhseIds = new Set<Id>();
        if (selectedCustomers.size() > 0) {
            List<GFERP__Warehouse__c> selectedWhse = [SELECT Name From GFERP__Warehouse__c Where Owned_By_Customer__c IN: selectedCustomers];
            if (selectedWhse.size() > 0) {
                for (GFERP__Warehouse__c whse :selectedWhse) {
                    selectedWhseIds.add(whse.Id);
                }
            } else {
                selectedWhseIds = null;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'There is no warehouse owned by this customer'));
            }
        }
        filterOnLowWeeks();
    }

    public void refreshTheReport() {
        if (theDate.GFERP__Requested_Shipment_Date__c != null) {
            reportingDate = theDate.GFERP__Requested_Shipment_Date__c;
            lastDayofWeekOfInterest = reportingDate;
            lastDayofWeekOfInterest = lastDayofWeekOfInterest.toStartOfWeek().addDays(6);
        } else {
            reportingDate = date.today();
            lastDayofWeekOfInterest = reportingDate.toStartOfWeek().addDays(6);
        }
        lastDayofLastWeek = lastDayofWeekOfInterest.addDays(-7);
        initItemLineTable();
        selectBeginAndEndCount();
        paginationInit();
    }

    public void selectAccounts() {
        local3PLWhseIds = new Set<Id>();
        customerOptions = new List<SelectOption>();
        //customerOptions.add(new SelectOption('','- All Customers -'));
        List<GFERP__Warehouse__c> whseList = [SELECT Name, Owned_by_Customer__c, Owned_by_Customer__r.Name FROM GFERP__Warehouse__c WHERE Owned_by_Customer__c != null AND FPC_Vendor_Warehouse__c = false ORDER BY Owned_by_Customer__r.Name];
        for (GFERP__Warehouse__c acc : whseList) {
            SelectOption newOption = new SelectOption(acc.Owned_by_Customer__c, acc.Owned_by_Customer__r.Name);
            if (!customerOptions.contains(newOption)) {
                customerOptions.add(newOption);
            }
        }

        List<GFERP__Warehouse__c> localWhse = [Select Name FROM GFERP__Warehouse__c WHERE FPC_Local_Warehouse__c = true];
        for (GFERP__Warehouse__c warehouse : localWhse) {
            local3PLWhseIds.add(warehouse.Id);
        }
    }

    public void initItemLineTable() {
        List<GFERP__Item__c> itemList;
        itemLineMap = new Map<String, InventoryPlanningController.ItemLine>();
        String strQuery = 'SELECT Name, GFERP__Description__c, GFERP__Vendor__c, GFERP__Qty_Base_on_Hand__c FROM GFERP__Item__c WHERE GFERP__Item_Type__c = \'Inventory\' AND GFERP__Blocked__c = false';
        if (String.isNotBlank(itemNoInput)) {
            if (selFilterOp == 'contains') {
                strQuery += ' AND Name LIKE \'%' + String.escapeSingleQuotes(itemNoInput) + '%\'';
            } else if (selFilterOp == 'not contains') {
                strQuery += ' AND  (NOT Name LIKE \'%' + String.escapeSingleQuotes(itemNoInput) + '%\')';
            } else if (selFilterOp == 'equals') {
                strQuery += ' AND Name = \'' + String.escapeSingleQuotes(itemNoInput) + '\'';
            } else if (selFilterOp == 'not equals') {
                strQuery += ' AND  (Name != \'' + String.escapeSingleQuotes(itemNoInput) + '\')';
            }
        }
        strQuery += ' Order By Name ' + sortDirection;
//        system.debug(strQuery);
        itemList = Database.query(strQuery);
        for (GFERP__Item__c item : itemList) {
            ItemLine newItemLine = new ItemLine();
            newItemLine.itemId = item.Id;
            newItemLine.itemNo = item.Name;
            newItemLine.itemDescription = item.GFERP__Description__c;
            newItemLine.actualWkUsage = 0;
            newItemLine.beginCountYear = 0;
            newItemLine.endCountYear = 0;
            newItemLine.shippedLastYear = 0;
            newItemLine.averageWkUsage = 0;
            newItemLine.vendorWhse = 0;
            newItemLine.beginCount = 0;
            newItemLine.endCount = 0;
            newItemLine.localOnHand = 0;
            newItemLine.onOrder = 0;
            newItemLine.vendorWhse = 0;
            newItemLine.shippedLastWeek = 0;
            newItemLine.vendorId = item.GFERP__Vendor__c;
            Decimal totalOnHand1 = item.GFERP__Qty_Base_on_Hand__c.setScale(2);
            //if (totalOnHand1 - totalOnHand1.intValue() > 0.0) {
            //    newItemLine.totalOnHand = totalOnHand1;
            //} else {
            //    newItemLine.totalOnHand = totalOnHand1.intValue();
            //}
            itemLineMap.put(item.Id, newItemLine);
        }
    }
    public void initGuide() {
        varianceGuide = new List<stringObj>();
        varianceGuide.add(new stringObj('25% - 99%', 'yellowFont'));
        varianceGuide.add(new stringObj('(-25%) - (-99%)', 'redFont'));
        varianceGuide.add(new stringObj('Over (-/+) 100%', 'blueFont'));

        lowWeeks = new List<stringObj>();
        lowWeeks.add(new stringObj('< 4', 'orangeBG'));
        lowWeeks.add(new stringObj('4 - 12', 'yellowBG'));
    }

    public void selectWeeks() {
        reportingDate =  theDate.GFERP__Requested_Shipment_Date__c;
        lastDayofWeekOfInterest = reportingDate.toStartOfWeek().addDays(6);
        lastDayofLastWeek = reportingDate.toStartOfWeek().addDays(-1);
    }

    public void selectBeginAndEndCount(){
        //Week of Interest
        // begin count

        List<Customer_Inventory_Count__c> beginInventory;
        List<Interplant_Transfer__c> transferOut;
        if (selectedCustomers != null && selectedCustomers.size() > 0) {
            beginInventory = [
                    SELECT Item_No__c, Week_End_Date__c, Count_Qty__c
                    FROM Customer_Inventory_Count__c
                    WHERE Customer__c IN: selectedCustomers AND Week_End_Date__c <=: lastDayofWeekOfInterest.addDays(-7) AND Week_End_Date__c >: lastDayofWeekOfInterest.addDays(-14)
            ];
            transferOut = [
                    SELECT Item__c, From_Customer__c, To_Customer__c, Transfer_Date__c, Quantity__c
                    FROM Interplant_Transfer__c WHERE From_Customer__c IN: selectedCustomers
                    AND Transfer_Date__c <=: lastDayofWeekOfInterest AND Transfer_Date__c >: lastDayofWeekOfInterest.addDays(-7)
            ];
        } else {
            beginInventory = [
                    SELECT Item_No__c, Week_End_Date__c, Count_Qty__c
                    FROM Customer_Inventory_Count__c
                    WHERE Week_End_Date__c <=: lastDayofWeekOfInterest.addDays(-7) AND Week_End_Date__c >: lastDayofWeekOfInterest.addDays(-14)
            ];
            transferOut = [
                    SELECT Item__c, From_Customer__c, To_Customer__c, Transfer_Date__c, Quantity__c
                    FROM Interplant_Transfer__c
                    WHERE Transfer_Date__c <=: lastDayofWeekOfInterest AND Transfer_Date__c >: lastDayofWeekOfInterest.addDays(-7)
            ];
        }
        for (Customer_Inventory_Count__c result : beginInventory) {
            if (itemLineMap.containsKey(result.Item_No__c)) {
                if (itemLineMap.get(result.Item_No__c).beginCount == null) {
                    itemLineMap.get(result.Item_No__c).beginCount = 0;
                }
                Decimal beginCount1 = result.Count_Qty__c.setScale(2);
                if(beginCount1 - beginCount1.intValue() > 0.0){
                    itemLineMap.get(result.Item_No__c).beginCount += beginCount1;
                } else {
                    itemLineMap.get(result.Item_No__c).beginCount += beginCount1.intValue();
                }
                itemLineMap.get(result.Item_No__c).beginCountId = result.Id;
            }
        }
        for (Interplant_Transfer__c result : transferOut) {
            if (itemLineMap.containsKey(result.Item__c)) {
                Decimal transferQty = result.Quantity__c.setScale(2);
                if (itemLineMap.get(result.Item__c).transferQty == null) {
                    itemLineMap.get(result.Item__c).transferQty = -transferQty;
                } else {
                    itemLineMap.get(result.Item__c).transferQty -= transferQty;
                }
                itemLineMap.get(result.Item__c).transferQtyId = result.Id;
            }
        }


        // end count
        List<Customer_Inventory_Count__c> endInventory;
        List<Interplant_Transfer__c> transferIn;
        if (selectedCustomers != null && selectedCustomers.size() > 0) {
            endInventory = [
                    SELECT Item_No__c, Week_End_Date__c, Count_Qty__c
                    FROM Customer_Inventory_Count__c
                    WHERE Customer__c IN: selectedCustomers AND Week_End_Date__c <=: lastDayofWeekOfInterest AND Week_End_Date__c >: lastDayofWeekOfInterest.addDays(-7)
            ];
            transferIn = [
                    SELECT Item__c, From_Customer__c, To_Customer__c, Transfer_Date__c, Quantity__c
                    FROM Interplant_Transfer__c WHERE To_Customer__c IN: selectedCustomers
                    AND Transfer_Date__c <=: lastDayofWeekOfInterest AND Transfer_Date__c >: lastDayofWeekOfInterest.addDays(-7)
            ];
        } else {
            endInventory = [
                    SELECT Item_No__c, Week_End_Date__c, Count_Qty__c
                    FROM Customer_Inventory_Count__c
                    WHERE Week_End_Date__c <=: lastDayofWeekOfInterest AND Week_End_Date__c >: lastDayofWeekOfInterest.addDays(-7)
            ];
            transferIn = [
                    SELECT Item__c, From_Customer__c, To_Customer__c, Transfer_Date__c, Quantity__c
                    FROM Interplant_Transfer__c
                    WHERE Transfer_Date__c <=: lastDayofWeekOfInterest AND Transfer_Date__c >: lastDayofWeekOfInterest.addDays(-7)
            ];
        }
        for (Customer_Inventory_Count__c result : endInventory) {
            if(itemLineMap.containsKey(result.Item_No__c)){
                if (itemLineMap.get(result.Item_No__c).endCount == null) {
                    itemLineMap.get(result.Item_No__c).endCount = 0;
                }
                Decimal endCount1 = result.Count_Qty__c.setScale(2);
                if(endCount1 - endCount1.intValue() > 0.0){
                    itemLineMap.get(result.Item_No__c).endCount += endCount1;
                } else {
                    itemLineMap.get(result.Item_No__c).endCount += endCount1.intValue();
                }
                itemLineMap.get(result.Item_No__c).endCountId = result.Id;
            }
        }
        for (Interplant_Transfer__c result : transferIn) {
            if (itemLineMap.containsKey(result.Item__c)) {
                Decimal transferQty = result.Quantity__c.setScale(2);
                if (itemLineMap.get(result.Item__c).transferQty == null) {
                    itemLineMap.get(result.Item__c).transferQty = transferQty;
                } else {
                    itemLineMap.get(result.Item__c).transferQty += transferQty;
                }
                itemLineMap.get(result.Item__c).transferQtyId = result.Id;
            }
        }

        // local on hand
        List<AggregateResult> localOHResults = [SELECT GFERP__Item__c itemId, SUM(GFERP__Qty_Base__c) onHand
                                                FROM GFERP__Item_Ledger_Entry__c WHERE GFERP__Warehouse__c IN: local3PLWhseIds AND GFERP__Correction__c = FALSE GROUP BY GFERP__Item__c];
        for (AggregateResult result : localOHResults) {
            if(itemLineMap.containsKey((String)result.get('itemId'))){
                Decimal localOnHand1 = ((Decimal)result.get('onHand')).setScale(2);
                if (localOnHand1 - localOnHand1.intValue() > 0.0) {
                    itemLineMap.get((String)result.get('itemId')).localOnHand = localOnHand1;
                } else {
                    itemLineMap.get((String)result.get('itemId')).localOnHand = localOnHand1.intValue();
                }
            }
        }

        // shipped last week: this is actually shipped current week
        List<AggregateResult> shippedLastWeekResults;
        if (selectedCustomers != null && selectedCustomers.size() > 0) {
        //if (selectedCustomer != null && string.isNotEmpty(selectedCustomer)) {
            shippedLastWeekResults = [SELECT GFERP__Item__c itemId, SUM(GFERP__Qty_Base__c) shippedLastWeek
                                    FROM GFERP__Item_Ledger_Entry__c WHERE GFERP__Posting_Date__c <=: lastDayofLastWeek.addDays(7)
                                    AND GFERP__Posting_Date__c >: lastDayofLastWeek AND GFERP__Document_Type__c = 'Shipment' AND GFERP__Account__c IN: selectedCustomers AND GFERP__Correction__c = FALSE
                                    GROUP BY GFERP__Item__c];
        } else {
            shippedLastWeekResults = [SELECT GFERP__Item__c itemId, SUM(GFERP__Qty_Base__c) shippedLastWeek
                                        FROM GFERP__Item_Ledger_Entry__c WHERE GFERP__Posting_Date__c <=: lastDayofLastWeek.addDays(7)
                                        AND GFERP__Posting_Date__c >: lastDayofLastWeek AND GFERP__Document_Type__c = 'Shipment' AND GFERP__Correction__c = FALSE GROUP BY GFERP__Item__c];
        }
        for (AggregateResult result : shippedLastWeekResults) {
            if(itemLineMap.containsKey((String)result.get('itemId'))){
                Decimal shippedLastWeek1 = (-1)*((Decimal)result.get('shippedLastWeek')).setScale(2);
                if(shippedLastWeek1 - shippedLastWeek1.intValue() > 0.0){
                    itemLineMap.get((String)result.get('itemId')).shippedLastWeek = shippedLastWeek1;
                } else {
                    itemLineMap.get((String)result.get('itemId')).shippedLastWeek = shippedLastWeek1.intValue();
                }
            }
        }
        
        for (string theKey: itemLineMap.keySet()) {
        
            itemLineMap.get(theKey).actualWkUsage = itemLineMap.get(theKey).beginCount - itemLineMap.get(theKey).endCount + zeroIfNull(itemLineMap.get(theKey).transferQty);
        
            Decimal shippedLastWeek1 = itemLineMap.get(theKey).shippedLastWeek == null ? 0 : itemLineMap.get(theKey).shippedLastWeek;
            //This calculation does not work if you post initial inventory by using positive adjustment instead of Whse. Receipt.
            itemLineMap.get(theKey).actualWkUsage += shippedLastWeek1;
            if (itemLineMap.get(theKey).actualWkUsage < 0){
                itemLineMap.get(theKey).actualWkUsage = 0;
            }
        }

        // Year of Interest
        // begin count Year
        List<AggregateResult> beginResultsYear;
        if (selectedWhseIds != null && selectedWhseIds.size() > 0) {
            beginResultsYear = [SELECT GFERP__Item__c itemId, SUM(GFERP__Qty_Base__c) beginCount
            FROM GFERP__Item_Ledger_Entry__c WHERE Customer_Inventory__c = true AND GFERP__Posting_Date__c <=: lastDayofLastWeek.addYears(-1) AND GFERP__Warehouse__c IN: selectedWhseIds AND GFERP__Correction__c = FALSE GROUP BY GFERP__Item__c];
        } else {
            beginResultsYear = [SELECT GFERP__Item__c itemId, SUM(GFERP__Qty_Base__c) beginCount
            FROM GFERP__Item_Ledger_Entry__c WHERE Customer_Inventory__c = true AND GFERP__Posting_Date__c <=: lastDayofLastWeek.addYears(-1) AND GFERP__Correction__c = FALSE GROUP BY GFERP__Item__c];
        }
        for (AggregateResult result : beginResultsYear) {
            if (itemLineMap.containsKey((String)result.get('itemId'))) {
                Decimal beginCount1 = ((Decimal)result.get('beginCount')).setScale(2);
                if(beginCount1 - beginCount1.intValue() > 0.0){
                    itemLineMap.get((String)result.get('itemId')).beginCountYear = beginCount1;
                } else {
                    itemLineMap.get((String)result.get('itemId')).beginCountYear = beginCount1.intValue();
                }
            }
        }

        // end count year
        List<AggregateResult> endResultsYear;
        if (selectedWhseIds != null && selectedWhseIds.size() > 0) {
            endResultsYear = [SELECT GFERP__Item__c itemId, SUM(GFERP__Qty_Base__c) endCount
            FROM GFERP__Item_Ledger_Entry__c WHERE Customer_Inventory__c = true AND GFERP__Posting_Date__c <=: lastDayofLastWeek AND GFERP__Warehouse__c IN: selectedWhseIds AND GFERP__Correction__c = FALSE GROUP BY GFERP__Item__c];
        } else {
            endResultsYear = [SELECT GFERP__Item__c itemId, SUM(GFERP__Qty_Base__c) endCount
            FROM GFERP__Item_Ledger_Entry__c WHERE Customer_Inventory__c = true AND GFERP__Posting_Date__c <=: lastDayofLastWeek AND GFERP__Correction__c = FALSE GROUP BY GFERP__Item__c];
        }
        for (AggregateResult result : endResultsYear) {
            if(itemLineMap.containsKey((String)result.get('itemId'))){
                Decimal endCount1 = ((Decimal)result.get('endCount')).setScale(2);
                if(endCount1 - endCount1.intValue() > 0.0){
                    itemLineMap.get((String)result.get('itemId')).endCountYear = endCount1;
                } else {
                    itemLineMap.get((String)result.get('itemId')).endCountYear = endCount1.intValue();
                }
            }
        }


        // shipped last year
        List<AggregateResult> shippedLastYearResults;
        if (selectedCustomers != null && selectedCustomers.size() > 0) {
            //if (selectedCustomer != null && string.isNotEmpty(selectedCustomer)) {
            shippedLastYearResults = [SELECT GFERP__Item__c itemId, SUM(GFERP__Qty_Base__c) shippedLastYear
            FROM GFERP__Item_Ledger_Entry__c WHERE GFERP__Posting_Date__c <=: lastDayofLastWeek
            AND GFERP__Posting_Date__c >: lastDayofLastWeek.addYears(-1) AND GFERP__Document_Type__c = 'Shipment' AND GFERP__Account__c IN: selectedCustomers AND GFERP__Correction__c = FALSE
            GROUP BY GFERP__Item__c];
        } else {
            shippedLastYearResults = [SELECT GFERP__Item__c itemId, SUM(GFERP__Qty_Base__c) shippedLastYear
            FROM GFERP__Item_Ledger_Entry__c WHERE GFERP__Posting_Date__c <=: lastDayofLastWeek
            AND GFERP__Posting_Date__c >: lastDayofLastWeek.addYears(-1) AND GFERP__Document_Type__c = 'Shipment' AND GFERP__Correction__c = FALSE GROUP BY GFERP__Item__c];
        }
        for (AggregateResult result : shippedLastYearResults) {
            if(itemLineMap.containsKey((String)result.get('itemId'))){
                Decimal shippedLastYear = (-1)*((Decimal)result.get('shippedLastYear')).setScale(2);
                if(shippedLastYear - shippedLastYear.intValue() > 0.0){
                    itemLineMap.get((String)result.get('itemId')).shippedLastYear = shippedLastYear;
                } else {
                    itemLineMap.get((String)result.get('itemId')).shippedLastYear = shippedLastYear.intValue();
                }
            }
        }

        //Average Wk Usage
        for (string theKey: itemLineMap.keySet()) {
            //itemLineMap.get(theKey).averageWkUsage = itemLineMap.get(theKey).beginCountYear - itemLineMap.get(theKey).endCountYear;
            Decimal beginCountYear = itemLineMap.get(theKey).beginCountYear == null ? 0 : itemLineMap.get(theKey).beginCountYear;
            Decimal endCountYear = itemLineMap.get(theKey).endCountYear == null ? 0 : itemLineMap.get(theKey).endCountYear;
            Decimal shippedLastYear = itemLineMap.get(theKey).shippedLastYear == null ? 0 : itemLineMap.get(theKey).shippedLastYear;
            //This calculation does not work if you post initial inventory by using positive adjustment instead of Whse. Receipt.
            if ((beginCountYear - endCountYear + shippedLastYear) / 52 > 0) {
                itemLineMap.get(theKey).averageWkUsage = (beginCountYear - endCountYear + shippedLastYear) / 52;
            } else {
                itemLineMap.get(theKey).averageWkUsage = 0;
            }
        }

        // % Variance
        for (ItemLine iteml : itemLineMap.values()) {
            if (iteml.averageWkUsage > 0.0) {
                iteml.variancePct = (iteml.actualWkUsage - iteml.averageWkUsage) / iteml.averageWkUsage;
            } else {
                iteml.variancePct = 0;
            }
            if (iteml.variancePct <= 0.25 && iteml.variancePct >= 0.99) {
                iteml.textColorClass = 'yellowFont';
            } else if (iteml.variancePct <= -0.25 && iteml.variancePct >= -0.99) {
                iteml.textColorClass = 'redFont';
            } else if (iteml.variancePct >= 1 || iteml.variancePct <= -1) {
                iteml.textColorClass = 'blueFont';
            } else {
                iteml.textColorClass = '';
            }
        }

        // on purchase order
        List<AggregateResult> onOrderResults = [
                SELECT GFERP__Item__c itemId, SUM(GFERP__O_S_Qty_Base__c) OSQty
                FROM GFERP__Purchase_Line__c WHERE GFERP__O_S_Qty_Base__c > 0 GROUP BY GFERP__Item__c
        ];
        for (AggregateResult result : onOrderResults) {
            if(itemLineMap.containsKey((String)result.get('itemId'))){
                Decimal OSQty1 = ((Decimal)result.get('OSQty')).setScale(2);
                if (OSQty1 - OSQty1.intValue() > 0.0) {
                    itemLineMap.get((String)result.get('itemId')).onOrder = OSQty1;
                } else {
                    itemLineMap.get((String)result.get('itemId')).onOrder = OSQty1.intValue();
                }
            }
        }

        // local week
        for (ItemLine iteml : itemLineMap.values()) {
            if (iteml.actualWkUsage > 0.0) {
                Decimal theEndCount = iteml.endCount == null ? 0.0 : iteml.endCount;
                iteml.localWeeks = ((iteml.localOnHand + theEndCount) / iteml.actualWkUsage).setScale(2);
            } else {
                iteml.localWeeks = 0;
            }
        }

        // vendor whse
        // find vendor on item card
        // find all vendor whses for the vendor
        // filer ILE by Warehouse = vendor whse
        List<AggregateResult> vendorWhseResults = [SELECT GFERP__Item__c itemId, SUM(GFERP__Qty_Base__c) onHand
            FROM GFERP__Item_Ledger_Entry__c WHERE GFERP__Warehouse__r.FPC_Vendor_Warehouse__c = true GROUP BY GFERP__Item__c];
        for (AggregateResult result : vendorWhseResults) {
            if(itemLineMap.containsKey((String)result.get('itemId'))){
                //if(itemLineMap.get((String)result.get('itemId')).vendorId != null && itemLineMap.get((String)result.get('itemId')).vendorId == (string)result.get('vendorId')){
                Decimal vendorWhse1 = ((Decimal)result.get('onHand'));
                if (vendorWhse1 - vendorWhse1.intValue() > 0.0) {
                    itemLineMap.get((String)result.get('itemId')).vendorWhse += vendorWhse1;
                } else {
                    itemLineMap.get((String)result.get('itemId')).vendorWhse += vendorWhse1.intValue();
                }
                //}
            }
        }

        // local and vendor whse
        for (ItemLine iteml : itemLineMap.values()) {
            if (iteml.actualWkUsage > 0.00) {
                Decimal localAndVendorWksActual1 = ((iteml.localOnHand + iteml.endCount + iteml.vendorWhse) / iteml.actualWkUsage).setScale(2);
                if (localAndVendorWksActual1 - localAndVendorWksActual1.intValue() > 0.0) {
                    iteml.localAndVendorWksActual = localAndVendorWksActual1;
                } else {
                    iteml.localAndVendorWksActual = localAndVendorWksActual1.intValue();
                }
                Decimal weeksAvailTotalAcutal1 = ((iteml.localOnHand + iteml.endCount + iteml.vendorWhse + iteml.onOrder) / iteml.actualWkUsage).setScale(2);
                if (weeksAvailTotalAcutal1 - weeksAvailTotalAcutal1.intValue() > 0.0) {
                    iteml.weeksAvailTotalAcutal = weeksAvailTotalAcutal1;
                } else {
                    iteml.weeksAvailTotalAcutal = weeksAvailTotalAcutal1.intValue();
                }
            }
            if (iteml.averageWkUsage > 0.00) {
                Decimal localAndVendorWksStandard1 = ((iteml.localOnHand + iteml.endCount + iteml.vendorWhse) / iteml.averageWkUsage).setScale(2);
                if (localAndVendorWksStandard1 - localAndVendorWksStandard1.intValue() > 0.0) {
                    iteml.localAndVendorWksStandard = localAndVendorWksStandard1;
                } else {
                    iteml.localAndVendorWksStandard = localAndVendorWksStandard1.intValue();
                }
                Decimal weeksAvailTotalStandard1 = ((iteml.localOnHand + iteml.endCount + iteml.vendorWhse + iteml.onOrder) / iteml.averageWkUsage).setScale(2);
                if (weeksAvailTotalStandard1 - weeksAvailTotalStandard1.intValue() > 0.0) {
                    iteml.weeksAvailTotalStandard = weeksAvailTotalStandard1;
                } else {
                    iteml.weeksAvailTotalStandard = weeksAvailTotalStandard1.intValue();
                }
            }
        }
        
        for (string theKey: itemLineMap.keySet()) {
            itemLineMap.get(theKey).totalOnHand = itemLineMap.get(theKey).localOnHand + itemLineMap.get(theKey).endCount + itemLineMap.get(theKey).vendorWhse;
        }
    }

    public void paginationInit() {
        itemLineList = itemLineMap.values();
        list_size = 30;
        total_size = itemLineList.size();
        searchInTheList();
    }

    public void refreshTheSublist() {
        total_size = itemLineList.size();
        itemLineSublist = new List<ItemLine>();

        Integer fromIndex = counter;
        Integer toIndex = counter + list_size > total_size ? total_size : counter + list_size;
        for (Integer i = fromIndex; i < toIndex; i++) {
            itemLineSublist.add(itemLineList[i]);
        }
    }

    public void filterOnLowWeeks() {
        refreshTheReport();
        if (selectedLowWeek == null || selectedLowWeek == 'all') {

        } else if (selectedLowWeek == 'lessThan4') {
            List<ItemLine> tempList = new List<ItemLine>();
            for (ItemLine itemLine : itemLineList) {
                if (itemLine.localAndVendorWksActual < 4.0 || itemLine.localAndVendorWksStandard < 4.0 || itemLine.weeksAvailTotalAcutal < 4.0 || itemLine.weeksAvailTotalStandard < 4.0) {
                    tempList.add(itemLine);
                }
            }
            itemLineList = tempList;
            Beginning();
        } else if (selectedLowWeek == 'from4to12') {
            List<ItemLine> tempList = new List<ItemLine>();
            for (ItemLine itemLine : itemLineList) {
                if ((itemLine.localAndVendorWksActual >= 4.0 && itemLine.localAndVendorWksActual <= 12) ||
                        (itemLine.localAndVendorWksStandard >= 4.0 && itemLine.localAndVendorWksStandard <= 12) ||
                        (itemLine.weeksAvailTotalAcutal >= 4.0 && itemLine.weeksAvailTotalAcutal <= 12) ||
                        (itemLine.weeksAvailTotalStandard >= 4.0 && itemLine.weeksAvailTotalStandard <= 12)) {
                    tempList.add(itemLine);
                }
            }
            itemLineList = tempList;
            Beginning();
        }

        if (sortExp == 'LocalOnHand') {
            List<LineWrapper> lineWrappers = new List<LineWrapper>();
            for (ItemLine itemLine : itemLineList) {
                lineWrappers.add(new LineWrapper(itemLine, 'LocalOnHand'));
            }
            lineWrappers.sort();
            itemLineList.clear();
            if (sortDirection == 'ASC') {
                for (LineWrapper wrapper : lineWrappers) {
                    itemLineList.add(wrapper.line);
                }
            } else {
                for (Integer i = lineWrappers.size() - 1; i >= 0; i--) {
                    itemLineList.add(lineWrappers[i].line);
                }
            }
            refreshTheSublist();
        } else if (sortExp == 'endCount') {
            List<LineWrapper> lineWrappers = new List<LineWrapper>();
            for (ItemLine itemLine : itemLineList) {
                lineWrappers.add(new LineWrapper(itemLine, 'endCount'));
            }
            lineWrappers.sort();
            itemLineList.clear();
            if (sortDirection == 'ASC') {
                for (LineWrapper wrapper : lineWrappers) {
                    itemLineList.add(wrapper.line);
                }
            } else {
                for (Integer i = lineWrappers.size() - 1; i >= 0; i--) {
                    itemLineList.add(lineWrappers[i].line);
                }
            }
            refreshTheSublist();
        }
    }

    public void searchInTheList() {
        if (itemSearchKey != null && string.isNotEmpty(itemSearchKey)) {
            itemLineSublist = new List<ItemLine>();
            for (ItemLine iteml : itemLineList) {
                if (iteml.itemDescription.containsIgnoreCase(itemSearchKey) || iteml.itemNo.containsIgnoreCase(itemSearchKey)) {
                    itemLineSublist.add(iteml);
                }
            }
            counter = 0;
            total_size = itemLineSublist.size();
            list_size = itemLineSublist.size();
        } else {
            list_size = 20;
            refreshTheSublist();
        }
    }

    public void viewBeginCounts() {
        viewType = 'beginCount';
        if (String.isNotBlank(viewItem)) {
            if (selectedCustomers != null && selectedCustomers.size() > 0) {
                viewCICList = [
                        SELECT Name, Item_No__c, Week_End_Date__c, Count_Qty__c, Customer__c
                        FROM Customer_Inventory_Count__c
                        WHERE Item_No__c =: viewItem AND Customer__c IN: selectedCustomers AND Week_End_Date__c <=: lastDayofWeekOfInterest.addDays(-7) AND Week_End_Date__c >: lastDayofWeekOfInterest.addDays(-14)
                ];
            } else {
                viewCICList = [
                        SELECT Name, Item_No__c, Week_End_Date__c, Count_Qty__c, Customer__c
                        FROM Customer_Inventory_Count__c
                        WHERE Item_No__c =: viewItem AND Week_End_Date__c <=: lastDayofWeekOfInterest.addDays(-7) AND Week_End_Date__c >: lastDayofWeekOfInterest.addDays(-14)
                ];
            }
        }
    }

    public void viewEndCounts() {
        viewType = 'endCount';
        if (String.isNotBlank(viewItem)) {
            if (selectedCustomers != null && selectedCustomers.size() > 0) {
                viewCICList = [
                        SELECT Name, Item_No__c, Week_End_Date__c, Count_Qty__c, Customer__c
                        FROM Customer_Inventory_Count__c
                        WHERE Item_No__c =: viewItem AND Customer__c IN: selectedCustomers AND Week_End_Date__c <=: lastDayofWeekOfInterest AND Week_End_Date__c >: lastDayofWeekOfInterest.addDays(-7)
                ];
            } else {
                viewCICList = [
                        SELECT Name, Item_No__c, Week_End_Date__c, Count_Qty__c, Customer__c
                        FROM Customer_Inventory_Count__c
                        WHERE Item_No__c =: viewItem AND Week_End_Date__c <=: lastDayofWeekOfInterest AND Week_End_Date__c >: lastDayofWeekOfInterest.addDays(-7)
                ];
            }
        }
    }

    public void refreshBeginCounts(){
        if (viewCICList != null && viewCICList.size() > 0) {
            Decimal totalCount = 0;
            for (Customer_Inventory_Count__c iCount : viewCICList) {
                totalCount += iCount.Count_Qty__c;
            }
            for (ItemLine lItem : itemLineSublist) {
                if (lItem.itemId == viewCICList[0].Item_No__c) {
                    lItem.beginCount = totalCount;
                    break;
                }
            }
        }
    }

    public void refreshEndCounts(){
        if (viewCICList != null && viewCICList.size() > 0) {
            Decimal totalCount = 0;
            for (Customer_Inventory_Count__c iCount : viewCICList) {
                totalCount += iCount.Count_Qty__c;
            }
            for (ItemLine lItem : itemLineSublist) {
                if (lItem.itemId == viewCICList[0].Item_No__c) {
                    lItem.endCount = totalCount;
                    break;
                }
            }
        }
    }

    @RemoteAction
    public static void updateCounts(String countList) {
        List<Customer_Inventory_Count__c> theCountList = (List<Customer_Inventory_Count__c>) JSON.deserialize(countList, List<Customer_Inventory_Count__c>.class);
        update theCountList;
    }

    public void convertToString() {
        listString = JSON.serialize(viewCICList);
    }

    public void Beginning() {
        counter = 0;
        refreshTheSublist();
    }

    public void Previous() {
        counter = counter - list_size >= 0 ? counter - list_size : 0;
        refreshTheSublist();
    }

    public void Next() {
        counter += list_size;
        refreshTheSublist();
    }

    public void End() {
        counter = total_size - math.mod(total_size, list_size);
        refreshTheSublist();
    }

    public Integer getTotalSize() {
        return total_size;
    }

    public Integer getFromCounter() {
        return counter + 1;
    }

    public Integer getToCounter() {
        if (total_size < list_size) {
            return counter + total_size;
        }
        else {
            if (counter + list_size > total_size) {
                return total_size;
            } else {
                return counter + list_size;
            }
        }
    }

    public Boolean getDisablePrevious() {
        if (counter > 0) return false; else return true;
    }

    public Boolean getDisableNext() {
        if (counter + list_size < total_size) return false; else return true;
    }

    public List<SelectOption> getPageSizeSelectOptions() {
        List<SelectOption> fieldOptions = new List<SelectOption>();
        fieldOptions.add(new SelectOption('20', '20'));
        fieldOptions.add(new SelectOption('30', '30'));
        fieldOptions.add(new SelectOption('50', '50'));
        return fieldOptions;
    }

    public List<SelectOption> getSortBySelectOptionsOptions() {
        List<SelectOption> fieldOptions = new List<SelectOption>();
        fieldOptions.add(new SelectOption('Name', 'Item'));
        fieldOptions.add(new SelectOption('endCount', 'End Count'));
        fieldOptions.add(new SelectOption('LocalOnHand', 'Local On Hand'));
        return fieldOptions;
    }

    public List<SelectOption> getLowWeekSelectOptions() {
        List<SelectOption> fieldOptions = new List<SelectOption>();
        fieldOptions.add(new SelectOption('all', 'All'));
        fieldOptions.add(new SelectOption('lessThan4', '< 4'));
        fieldOptions.add(new SelectOption('from4to12', '4 - 12'));
        return fieldOptions;
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

    public String sortExpression {
        get {return sortExp;}
        set {sortDirection = (sortDirection == 'ASC') ? 'DESC' : 'ASC';}
    }

    public String getSortDirection() {
        if (sortExpression == null || sortExpression == '') return 'ASC'; else return sortDirection;
    }

    public Pagereference ExportToExcel() {
        String URL = '/apex/InventoryPlanningReportExcel?reportingDate=' + + reportingDate.month()+'/'+reportingDate.day()+'/'+reportingDate.year() + '&customers=' + string.join(selectedCustomers, ',') + '&local3PLWhseIds=' + string.join((Iterable<Id>)local3PLWhseIds,',') + '&selectedLowWeek=' + selectedLowWeek;
        if (String.isNotBlank(itemNoInput)) {
            URL = URL + '&selFilterOp=' + selFilterOp + '&itemNoInput=' + EncodingUtil.urlEncode(itemNoInput, 'UTF-8');
        }
        if (selectedWhseIds != null && selectedWhseIds.size() > 0) {
            URL += '&warehouses=' + string.join((Iterable<Id>)selectedWhseIds,',');
        }
        if (sortExp == 'LocalOnHand') {
            URL = URL + '&sortExp=LocalOnHand&sortDir=' + sortDirection;
        }
        system.debug(URL);
        PageReference pageRef = new PageReference(URL);
        pageRef.setRedirect(true);
        return pageRef;
    }

    public decimal zeroIfNull(decimal num) {
        if (num == null) num = 0;
        return num;
    }

    public class ItemLine {
        public Id itemId { get; set; }
        public string itemNo { get; set; }
        public string itemDescription { get; set; }
        public Decimal beginCount { get; set; }
        public Decimal endCount { get; set; }
        public String beginCountId { get; set; }
        public String endCountId { get; set; }
        public Decimal transferQty { get; set; }
        public String transferQtyId { get; set; }
        public Decimal shippedLastWeek { get; set; }
        public Decimal beginCountYear { get; set; }
        public Decimal endCountYear { get; set; }
        public Decimal shippedLastYear { get; set; }
        public Decimal actualWkUsage { get; set; }
        public Decimal averageWkUsage { get; set; }
        public Decimal variancePct { get; set; }
        public Decimal localOnHand { get; set; }
        public Decimal localWeeks { get; set; }
        public Decimal vendorWhse { get; set; }
        public string vendorId;
        public Decimal localAndVendorWksActual { get; set; }
        public Decimal localAndVendorWksStandard { get; set; }
        public Decimal totalOnHand { get; set; }
        public Decimal onOrder { get; set; }
        public Decimal weeksAvailTotalAcutal { get; set; }
        public Decimal weeksAvailTotalStandard { get; set; }
        public string textColorClass { get; set; }
        public ItemLine(){}
    }

    public class stringObj {
        public string theValue { get; set; }
        public string theStyle { get; set; }
        public stringObj(string value1, string value2){
            this.theValue = value1;
            this.theStyle = value2;
        }
    }

    public class LineWrapper implements Comparable {
        public ItemLine line;
        public string sortBy;
        public LineWrapper(ItemLine line, String sortBy) {
            this.line = line;
            this.sortBy = sortBy;
        }
        public Integer compareTo(Object compareTo) {
            LineWrapper otherLine = (LineWrapper) compareTo;
            if (sortBy == 'LocalOnHand') {
                if (line.localOnHand > otherLine.line.localOnHand) {
                    return 1;
                } else if (line.localOnHand < otherLine.line.localOnHand) {
                    return -1;
                }
            } else if (sortBy == 'endCount') {
                if (line.endCount > otherLine.line.endCount) {
                    return 1;
                } else if (line.endCount < otherLine.line.endCount) {
                    return -1;
                }
            }
            return 0;
        }
    }
}