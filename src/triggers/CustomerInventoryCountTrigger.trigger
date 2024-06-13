/**
 * Created by zon cheng on 4/18/2022.
 */

trigger CustomerInventoryCountTrigger on Customer_Inventory_Count__c (before update, before insert) {
    Set<Id> accIds = new Set<Id>();
    Set<Id> itemIds = new Set<Id>();
    Set<Date> dates = new Set<Date>();
    for (Customer_Inventory_Count__c iCount: Trigger.new) {
        if (iCount.Customer__c != null) {
            accIds.add(iCount.Customer__c);
        }
        if (iCount.Item_No__c != null) {
            itemIds.add(iCount.Item_No__c);
        }
        if (iCount.Week_End_Date__c != null) {
            dates.add(iCount.Week_End_Date__c.addDays(-7));
        }
    }
    if (accIds.size() > 0) {
        String mapKey;
        Map<String, Customer_Inventory_Count__c> previousCountMap = new Map<String, Customer_Inventory_Count__c>();
        List<Customer_Inventory_Count__c> previousCounts = [SELECT Item_No__c, Customer__c, Week_End_Date__c, Count_Qty__c FROM Customer_Inventory_Count__c WHERE Customer__c IN: accIds AND Item_No__c IN: itemIds AND Week_End_Date__c IN: dates];
        for (Customer_Inventory_Count__c iCount : previousCounts) {
            mapKey = iCount.Item_No__c + ';' + iCount.Customer__c + ';' + iCount.Week_End_Date__c;
            previousCountMap.put(mapKey, iCount);
        }
        for (Customer_Inventory_Count__c iCount: Trigger.new) {
            if (iCount.Customer__c != null && iCount.Item_No__c != null) {
                Date previousDate = iCount.Week_End_Date__c.addDays(-7);
                mapKey = iCount.Item_No__c + ';' + iCount.Customer__c + ';' + previousDate;
                if (previousCountMap.containsKey(mapKey)) {
                    iCount.Previous_Count_Qty__c = previousCountMap.get(mapKey).Count_Qty__c;
                }
            }
        }
    }
}