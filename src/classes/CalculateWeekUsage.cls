/**
 * Created by zon cheng on 4/18/2022.
 */

global class CalculateWeekUsage implements Database.Batchable<sObject>, Schedulable {

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String theQuery = 'SELECT Item_No__c, Customer__c, Week_End_Date__c FROM Customer_Inventory_Count__c Where Customer__c != null AND Item_No__c != null AND Week_End_Date__c != null';
        return Database.getQueryLocator(theQuery);
    }

    public void execute(Database.BatchableContext BC, List<Customer_Inventory_Count__c> countList) {
        Set<Id> itemIds = new Set<Id>();
        Set<Id> accIds = new Set<Id>();
        Date startDate = countList[0].Week_End_Date__c;
        Date endDate = countList[0].Week_End_Date__c;
        for (Customer_Inventory_Count__c iCount : countList) {
            itemIds.add(iCount.Item_No__c);
            accIds.add(iCount.Customer__c);
            if (iCount.Week_End_Date__c > endDate) {
                endDate = iCount.Week_End_Date__c;
            }
            if (iCount.Week_End_Date__c < startDate) {
                startDate = iCount.Week_End_Date__c;
            }
        }
        startDate = startDate.addDays(-7);
        List<GFERP__Item_Ledger_Entry__c> theILEList = [
                SELECT GFERP__Item__c, GFERP__Account__c, GFERP__Posting_Date__c, GFERP__Qty_Base__c FROM GFERP__Item_Ledger_Entry__c WHERE GFERP__Posting_Date__c <=: endDate AND GFERP__Posting_Date__c >: startDate
                AND GFERP__Item__c IN: itemIds AND GFERP__Account__c IN: accIds AND GFERP__Document_Type__c = 'Shipment' AND GFERP__Correction__c = FALSE
        ];

        String mapKey;
        Map<String, Decimal> qtyMap = new Map<String, Decimal>();
        for (GFERP__Item_Ledger_Entry__c ILE : theILEList) {
            Date weekStartDate = ILE.GFERP__Posting_Date__c.toStartOfWeek();
            mapKey = ILE.GFERP__Account__c + ';' + ILE.GFERP__Item__c + ';' + weekStartDate;
            if (!qtyMap.containsKey(mapKey)) {
                qtyMap.put(mapKey, 0);
            }
            Decimal theQty = -1 * ILE.GFERP__Qty_Base__c;
            qtyMap.put(mapKey, qtyMap.get(mapKey) + theQty);
        }

        // transfer out
        Map<String, Decimal> transferOutMap = new Map<String, Decimal>();
        List<Interplant_Transfer__c> transferOut = [
                SELECT Item__c, From_Customer__c, To_Customer__c, Transfer_Date__c, Quantity__c
                FROM Interplant_Transfer__c WHERE To_Customer__c IN: accIds AND Item__c IN: itemIds AND Transfer_Date__c <=: endDate AND Transfer_Date__c >: startDate
        ];
        for (Interplant_Transfer__c IT : transferOut) {
            Date weekStartDate = IT.Transfer_Date__c.toStartOfWeek();
            mapKey = IT.From_Customer__c + ';' + IT.Item__c + ';' + weekStartDate;
            if (!transferOutMap.containsKey(mapKey)) {
                transferOutMap.put(mapKey, 0);
            }
            transferOutMap.put(mapKey, transferOutMap.get(mapKey) - IT.Quantity__c);
        }

        // transfer in
        Map<String, Decimal> transferInMap = new Map<String, Decimal>();
        List<Interplant_Transfer__c> transferIn = [
                SELECT Item__c, From_Customer__c, To_Customer__c, Transfer_Date__c, Quantity__c
                FROM Interplant_Transfer__c WHERE To_Customer__c IN: accIds AND Item__c IN: itemIds AND Transfer_Date__c <=: endDate AND Transfer_Date__c >: startDate
        ];
        for (Interplant_Transfer__c IT : transferIn) {
            Date weekStartDate = IT.Transfer_Date__c.toStartOfWeek();
            mapKey = IT.To_Customer__c + ';' + IT.Item__c + ';' + weekStartDate;
            if (!transferInMap.containsKey(mapKey)) {
                transferInMap.put(mapKey, 0);
            }
            transferInMap.put(mapKey, transferInMap.get(mapKey) + IT.Quantity__c);
        }

        for (Customer_Inventory_Count__c iCount : countList) {
            Date weekStartDate = iCount.Week_End_Date__c.toStartOfWeek();
            mapKey = iCount.Customer__c + ';' + iCount.Item_No__c + ';' + weekStartDate;
            if (qtyMap.containsKey(mapKey)) {
                iCount.Shipped_This_Week__c = qtyMap.get(mapKey);
            }
            if (transferOutMap.containsKey(mapKey)) {
                iCount.Interplant_Transfer_Qty__c = transferOutMap.get(mapKey);
            }
            if (transferInMap.containsKey(mapKey)) {
                if (transferOutMap.containsKey(mapKey)) {
                    iCount.Interplant_Transfer_Qty__c = transferOutMap.get(mapKey) + transferInMap.get(mapKey);
                } else {
                    iCount.Interplant_Transfer_Qty__c = transferInMap.get(mapKey);
                }
            }
        }
        update countList;
    }

    public void finish(Database.BatchableContext BC) {

    }

    public void execute(SchedulableContext sc) {
        Database.executeBatch(new CalculateWeekUsage(), 500);
    }
}