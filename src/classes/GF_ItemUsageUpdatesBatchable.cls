global class GF_ItemUsageUpdatesBatchable implements Database.Batchable<sObject> {
    public List<Customer_Inventory_Count__c> beginInventory = new List<Customer_Inventory_Count__c>();
    public List<Interplant_Transfer__c> transferOut = new List<Interplant_Transfer__c>();
    public List<AggregateResult> shippedLastWeekResults = new List<AggregateResult>();
    public List<GFERP__Warehouse__c> whseList = new List<GFERP__Warehouse__c>();
    public List<GFERP__Item__c> itemList = new List<GFERP__Item__c>();
    Public Date currentWeekEnd;
    public Date firstWeekOfLastYear;
    public Map<String, GFERP__Warehouse__c> customersMap = new Map<String, GFERP__Warehouse__c>();
    Public Map<Integer, weekDates> weekDatesMaps = new Map<Integer, weekDates>();
    public Map<String, Map<String, Map<Integer, ItemLine>>> itemLineWarehouseMap = new Map<String, Map<String, Map<Integer, ItemLine>>>(); 
    public Map<String, ItemLine> itemLineMap = new Map<String, ItemLine>(); 
    public GFERP__Demand_Planning_Setup__c DPSRec = new GFERP__Demand_Planning_Setup__c();
    public List<GFERP__Item_Usage__c> itemUsageList = new list<GFERP__Item_Usage__c>();
            
    
    public Database.QueryLocator start(Database.BatchableContext c){
        /*List<GFERP__Item_Usage__c> t = [Select Id From GFERP__Item_Usage__c];
        Delete t;*/
        
        // get all non-blocked and inventory items
        String query = 'SELECT Name, GFERP__Description__c, GFERP__Vendor__c, GFERP__Qty_Base_on_Hand__c FROM GFERP__Item__c WHERE GFERP__Item_Type__c = \'Inventory\' AND GFERP__Blocked__c = false Order By Name';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext c, List<GFERP__Item__c> scope){
        itemList = scope;
        setWeekDatesMaps();
        setCustomersFromWarehouse();
        init();
        
    }  
    global void finish(Database.BatchableContext BC) {}
    
    public void populateDataToObject(){
        try{
            beginInventory = [
                SELECT Item_No__c, Week_End_Date__c, Count_Qty__c, Customer__c
                FROM Customer_Inventory_Count__c
                WHERE Customer__c IN: customersMap.keySet() AND Week_End_Date__c >=: firstWeekOfLastYear.addDays(-14) AND Week_End_Date__c <: currentWeekEnd
            ];
            transferOut = [
                SELECT Item__c, From_Customer__c, To_Customer__c, Transfer_Date__c, Quantity__c
                FROM Interplant_Transfer__c WHERE (From_Customer__c IN: customersMap.keySet() OR To_Customer__c IN: customersMap.keySet())
                AND Transfer_Date__c >=: firstWeekOfLastYear AND Transfer_Date__c <: currentWeekEnd
            ];
            shippedLastWeekResults = [SELECT GFERP__Item__c itemId, GFERP__Posting_Date__c postingDate, SUM(GFERP__Qty_Base__c) shippedLastWeek, GFERP__Account__c customer, GFERP__Warehouse__c warehose
                                        FROM GFERP__Item_Ledger_Entry__c WHERE GFERP__Posting_Date__c >=: firstWeekOfLastYear
                                        AND GFERP__Posting_Date__c <: currentWeekEnd AND GFERP__Document_Type__c = 'Shipment' AND GFERP__Account__c IN: customersMap.keySet() AND GFERP__Correction__c = FALSE
                                        GROUP BY GFERP__Item__c, GFERP__Posting_Date__c, GFERP__Account__c, GFERP__Warehouse__c];
            DPSRec = [Select Name, GFERP__Locked_Best_Fit_Model__c From GFERP__Demand_Planning_Setup__c Limit 1];
        }catch(exception ex){
            system.debug('Error: populateDataToObject() ' + ex.getMessage() + ' Line: ' + ex.getLineNumber());
        }
        
    }
    
    public void init(){
        itemLineWarehouseMap = new Map<String, Map<String, Map<Integer, ItemLine>>>();
        try{
            populateDataToObject();
            initItemLineTable();
            // get customer inventory for column A and B calculation
            for (Customer_Inventory_Count__c result : beginInventory) {
                if (itemLineMap.containsKey(result.Item_No__c)) {
                    
            
                    // Begin Count. A Column calculation
                    Integer wNo = getWeekNoFromDate(result.Week_End_Date__c.addDays(7));
                    ItemLine tempItem = itemLineMap.get(result.Item_No__c);
                    if(itemLineWarehouseMap.get(result.Item_No__c).get(result.Customer__c) == null){
                        itemLineWarehouseMap.get(result.Item_No__c).put(result.Customer__c, new Map<Integer, ItemLine>());
                        itemLineWarehouseMap.get(result.Item_No__c).get(result.Customer__c).put(wNo, getNewItemLineCopy(tempItem));
                    }
                    tempItem = itemLineWarehouseMap.get(result.Item_No__c).get(result.Customer__c).get(wNO);
                    if(tempItem == null) {
                        itemLineWarehouseMap.get(result.Item_No__c).get(result.Customer__c).put(wNO, getNewItemLineCopy(itemLineMap.get(result.Item_No__c)));
                        tempItem = itemLineWarehouseMap.get(result.Item_No__c).get(result.Customer__c).get(wNO);
                    }
                    if (tempItem.beginCount == null) {
                        tempItem.beginCount = 0;
                    }
                    Decimal beginCount1 = result.Count_Qty__c.setScale(2);
                    if(beginCount1 - beginCount1.intValue() > 0.0){
                        tempItem.beginCount += beginCount1;
                    } else {
                        tempItem.beginCount += beginCount1.intValue();
                    }
                    tempItem.beginCountId = result.Id;
                    // End Count. B Column calculation
                    Integer endWeekNo = getWeekNoFromDate(result.Week_End_Date__c);
                    tempItem = itemLineMap.get(result.Item_No__c);
                    if(itemLineWarehouseMap.get(result.Item_No__c).get(result.Customer__c) == null){
                        itemLineWarehouseMap.get(result.Item_No__c).put(result.Customer__c, new Map<Integer, ItemLine>());
                        itemLineWarehouseMap.get(result.Item_No__c).get(result.Customer__c).put(endWeekNo, getNewItemLineCopy(tempItem));
                    }
                    tempItem = itemLineWarehouseMap.get(result.Item_No__c).get(result.Customer__c).get(endWeekNo);
                    if(tempItem == null) {
                        itemLineWarehouseMap.get(result.Item_No__c).get(result.Customer__c).put(endWeekNo, getNewItemLineCopy(itemLineMap.get(result.Item_No__c)));
                        tempItem = itemLineWarehouseMap.get(result.Item_No__c).get(result.Customer__c).get(endWeekNo);
                    }
                    if (tempItem.endCount == null) {
                        tempItem.endCount = 0;
                    }
                    Decimal endCount1 = result.Count_Qty__c.setScale(2);
                    if(endCount1 - endCount1.intValue() > 0.0){
                        tempItem.endCount += endCount1;
                    } else {
                        tempItem.endCount += endCount1.intValue();
                    }
                    tempItem.endCountId = result.Id;
                }
            }
            List<String> tempLinesStr = new List<String>();
            // C Column calculation
            for (Interplant_Transfer__c result : transferOut) {
                if (itemLineMap.containsKey(result.Item__c)) {
                    Integer wNo = getWeekNoFromDate(result.Transfer_Date__c);
                    // Transfer Out
                    ItemLine tempItem = itemLineMap.get(result.Item__c);
                    if(itemLineWarehouseMap.get(result.Item__c).get(result.From_Customer__c) == null){
                        itemLineWarehouseMap.get(result.Item__c).put(result.From_Customer__c, new Map<Integer, ItemLine>());
                        itemLineWarehouseMap.get(result.Item__c).get(result.From_Customer__c).put(wNo, getNewItemLineCopy(tempItem));
                    }
                    tempItem = itemLineWarehouseMap.get(result.Item__c).get(result.From_Customer__c).get(wNO);
                    if(tempItem == null) {
                        itemLineWarehouseMap.get(result.Item__c).get(result.From_Customer__c).put(wNO, getNewItemLineCopy(itemLineMap.get(result.Item__c)));
                        tempItem = itemLineWarehouseMap.get(result.Item__c).get(result.From_Customer__c).get(wNO);
                    }
                    Decimal transferQty = result.Quantity__c.setScale(2);
                    if (tempItem.transferQty == null) {
                        tempItem.transferQty = -transferQty;
                    } else {
                        tempItem.transferQty -= transferQty;
                    }
                    // Transfer In
                    if(itemLineWarehouseMap.get(result.Item__c).get(result.To_Customer__c) == null){
                        itemLineWarehouseMap.get(result.Item__c).put(result.To_Customer__c, new Map<Integer, ItemLine>());
                        itemLineWarehouseMap.get(result.Item__c).get(result.To_Customer__c).put(wNo, getNewItemLineCopy(tempItem));
                    }
                    tempItem = itemLineWarehouseMap.get(result.Item__c).get(result.To_Customer__c).get(wNO);
                    if(tempItem == null) {
                        itemLineWarehouseMap.get(result.Item__c).get(result.To_Customer__c).put(wNO, getNewItemLineCopy(itemLineMap.get(result.Item__c)));
                        tempItem = itemLineWarehouseMap.get(result.Item__c).get(result.To_Customer__c).get(wNO);
                    }
                    transferQty = result.Quantity__c.setScale(2);
                    if (tempItem.transferQty == null) {
                        tempItem.transferQty = transferQty;
                    } else {
                        tempItem.transferQty += transferQty;
                    }
                    tempItem.transferQtyId = result.Id;
                    
                }
            }
            //T Column calculation
            List<String> tempList = new List<String>();
            for (AggregateResult result : shippedLastWeekResults) {
                if(itemLineMap.containsKey((String)result.get('itemId'))){
                    Integer wNo = getWeekNoFromDate((Date)result.get('postingDate'));
                    ItemLine tempItem = new ItemLine();
                    tempItem = itemLineMap.get((String)result.get('itemId'));
                    String customerId = (String)result.get('customer');
                    /*if(tempWhos.get((String)result.get('customer')) != null){
                        customerId = tempWhos.get((String)result.get('warehose')).Owned_by_Customer__c;
                    }*/
                    if(customerId != null){
                        if(itemLineWarehouseMap.get((String)result.get('itemId')).get(customerId) == null){
                            itemLineWarehouseMap.get((String)result.get('itemId')).put(customerId, new Map<Integer, ItemLine>());
                            itemLineWarehouseMap.get((String)result.get('itemId')).get(customerId).put(wNo, getNewItemLineCopy(tempItem));
                        }
                        tempItem = itemLineWarehouseMap.get((String)result.get('itemId')).get(customerId).get(wNO);
                        if(tempItem == null) {
                            itemLineWarehouseMap.get((String)result.get('itemId')).get(customerId).put(wNO, getNewItemLineCopy(itemLineMap.get((String)result.get('itemId'))));
                            tempItem = itemLineWarehouseMap.get((String)result.get('itemId')).get(customerId).get(wNO);
                        }
                        tempItem.weekNo = wNo;
                            
                        Decimal shippedLastWeek1 = (-1)*((Decimal)result.get('shippedLastWeek')).setScale(2);
                        if(shippedLastWeek1 - shippedLastWeek1.intValue() > 0.0){
                            tempItem.shippedLastWeek += shippedLastWeek1;
                        } else {
                            tempItem.shippedLastWeek += shippedLastWeek1.intValue();
                        }
                    }
                }
            }
            GFERP__Item_Usage__c itemUsageTemp = new GFERP__Item_Usage__c();
            for(String itemId :itemLineWarehouseMap.keySet()){
                for(String customersId :itemLineWarehouseMap.get(itemId).keySet()){
                    for(Integer weekN :itemLineWarehouseMap.get(itemId).get(customersId).keySet()){
                        weekDates temp =  weekDatesMaps.get(weekN);
                        ItemLine tempItem = itemLineWarehouseMap.get(itemId).get(customersId).get(weekN);
                        // calculate Column D
                        tempItem.actualWkUsage = tempItem.beginCount - tempItem.endCount + zeroIfNull(tempItem.transferQty);
                        Decimal shippedLastWeek1 = tempItem.shippedLastWeek == null ? 0 : tempItem.shippedLastWeek;
                        //This calculation does not work if you post initial inventory by using positive adjustment instead of Whse. Receipt.
                        tempItem.actualWkUsage += shippedLastWeek1;
                        if (tempItem.actualWkUsage < 0){
                            tempItem.actualWkUsage = 0;
                        }
                        if(tempItem.actualWkUsage != 0){
                            itemUsageTemp = new GFERP__Item_Usage__c();
                            itemUsageTemp.GFERP__Item__c = tempItem.itemId;
                            itemUsageTemp.GFERP__Warehouse__c = customersMap.get(customersId).Id;
                            itemUsageTemp.GFERP__Starting_Date__c = temp.weekStartDate;
                            itemUsageTemp.GFERP__Ending_Date__c = temp.weekEndDate;
                            itemUsageTemp.GFERP__Sales_Qty__c = tempItem.actualWkUsage;
                            if(DPSRec.GFERP__Locked_Best_Fit_Model__c != null)
                            itemUsageTemp.GFERP__Best_Fit_Model__c = DPSRec.GFERP__Locked_Best_Fit_Model__c;
                            //itemUsageTemp.External_Id__c = 'transferQty = ' + tempItem.transferQty + ' beginCount = ' + tempItem.beginCount + ' endCount = ' + tempItem.endCount + ' shippedLastWeek = ' + tempItem.shippedLastWeek;
                            
                            itemUsageList.add(itemUsageTemp);    
                        }
                    }
                }
            }
            if(itemUsageList.size() > 0){
                insert itemUsageList;
            }    
        }catch(Exception ex){
            system.debug('Error init(): ' + ex.getMessage() + ' Line no: ' + ex.getLineNumber());
        }
        
    }
    
    /*public void insertrecordsInBatch(List<GFERP__Item_Usage__c> IURecs){
        
        List<GFERP__Item_Usage__c> recordsToUpdate = new List<GFERP__Item_Usage__c>();
        
        for (GFERP__Item_Usage__c record : IURecs) {
            // Perform necessary operations on the record
            
            // Add the modified record to the collection for update
            recordsToUpdate.add(record);
            
            // Check if the collection size reaches the batch size
            if (recordsToUpdate.size() == 200) {
                // Perform the update operation
                Database.insert(recordsToUpdate, false);
                
                // Clear the collection for the next batch
                recordsToUpdate.clear();
            }
        }
        
        // Perform the final update if there are remaining records in the collection
        if (!recordsToUpdate.isEmpty()) {
            Database.update(recordsToUpdate, false);
        }
    }*/
    public ItemLine getNewItemLineCopy(ItemLine tempItem){
        ItemLine temp = new ItemLine();
        temp.itemId = tempItem.itemId;
        temp.itemNo = tempItem.itemNo; 
        temp.beginCount = tempItem.beginCount;
        temp.endCount = tempItem.endCount;
        temp.weekStartDate = tempItem.weekStartDate;
        temp.weekEndDate = tempItem.weekEndDate;
        temp.beginCountId = tempItem.beginCountId;
        temp.endCountId = tempItem.endCountId;
        temp.warehouse = tempItem.warehouse;
        temp.transferQty = tempItem.transferQty;
        temp.transferQtyId = tempItem.transferQtyId;
        temp.shippedLastWeek = tempItem.shippedLastWeek;
        temp.actualWkUsage = tempItem.actualWkUsage;
        return temp;
    }
    public Map<Id, GFERP__Warehouse__c> tempWhos;
    public void setCustomersFromWarehouse() {
        customersMap = new Map<String, GFERP__Warehouse__c>();
        tempWhos = new Map<Id, GFERP__Warehouse__c>([SELECT Name, Owned_by_Customer__c, Owned_by_Customer__r.Name
            FROM GFERP__Warehouse__c WHERE Owned_by_Customer__c != null AND FPC_Vendor_Warehouse__c = false ORDER BY Owned_by_Customer__r.Name]);
        for (GFERP__Warehouse__c acc : tempWhos.values()) {
            if (!customersMap.keySet().contains(acc.Owned_by_Customer__c)) {
                customersMap.put(acc.Owned_by_Customer__c, acc);
            }
        }
    }
    
    public void initItemLineTable() {
        itemLineMap = new Map<String, ItemLine>();
        try{
            for (GFERP__Item__c item : itemList) {
                ItemLine newItemLine = new ItemLine();
                newItemLine.itemId = item.Id;
                newItemLine.itemNo = item.Name;
                newItemLine.actualWkUsage = 0;
                newItemLine.beginCount = 0;
                newItemLine.endCount = 0;
                newItemLine.shippedLastWeek = 0;
                newItemLine.weekNo = 0;
                itemLineMap.put(item.Id, newItemLine);
                itemLineWarehouseMap.put(item.Id, new Map<String, Map<Integer, ItemLine>>());
            }    
        }catch(Exception ex){
            system.debug('Error initItemLineTable(): ' + ex.getMessage());
        }
        
    }
    
    public void setWeekDatesMaps(){
        
        date myDate = date.today();
        // Current week end date
        currentWeekEnd = myDate.toStartofWeek().addDays(7);
        // First day of the last year
        firstWeekOfLastYear = Date.newInstance(myDate.year() - 1, 1, 1);
        
        //firstWeekOfLastYear = myDate.toStartofWeek();
        Date tempStartDate = firstWeekOfLastYear.toStartofWeek();
        
        weekDatesMaps = new Map<Integer, weekDates>();
        weekDates tempWeekDates = new weekDates();
        // Weeks calculation
        for(Integer weekNo = 1; currentWeekEnd >= tempStartDate; weekNo++){
            Date tempEndDate = tempStartDate.addDays(6);
            tempWeekDates = new weekDates();
            tempWeekDates.weekStartDate = tempStartDate;
            tempWeekDates.weekEndDate = tempEndDate;
            weekDatesMaps.put(weekNo, tempWeekDates);
            tempStartDate = tempStartDate.addDays(7);
        }
    }
    
    public Integer getWeekNoFromDate(Date d){
        Integer wn = 0;
        for(Integer weekNo :weekDatesMaps.keySet()){
            weekDates temp =  weekDatesMaps.get(weekNo);
            if(temp.weekStartDate <= d && temp.weekEndDate >= d){
                wn = weekNo;
                break;
            }
        }
        return wn;
    }
    
    public decimal zeroIfNull(decimal num) {
        if (num == null) num = 0;
        return num;
    }
    
    public class weekDates {
        public Date weekStartDate { get; set; }
        public Date weekEndDate { get; set; }
        public weekDates(){}
    }
    public class ItemLine {
        public Id itemId { get; set; }
        public string itemNo { get; set; }
        public Decimal beginCount { get; set; }
        public Decimal endCount { get; set; }
        public Date weekStartDate { get; set; }
        public Date weekEndDate { get; set; }
        public String beginCountId { get; set; }
        public String endCountId { get; set; }
        public GFERP__Warehouse__c warehouse { get; set; }
        public Decimal transferQty { get; set; }
        public String transferQtyId { get; set; }
        public Decimal shippedLastWeek { get; set; }
        public Decimal actualWkUsage { get; set; }
        public Integer weekNo { get; set; }
        public ItemLine(){}
    }
}