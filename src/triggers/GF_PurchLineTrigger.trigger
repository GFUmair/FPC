trigger GF_PurchLineTrigger on GFERP__Purchase_Line__c (before update, before insert) {
    Set<Id> itmIds = new Set<Id>();
    Set<Id> UOMIds = new Set<Id>();
    Set<Id> plIds = new Set<Id>();
    Set<Id> vendorIds = new Set<Id>();
    Map<String, List<GFERP__Purchase_Line__c>> plKeyMap = new Map<String, List<GFERP__Purchase_Line__c>>();
    for(GFERP__Purchase_Line__c pl: Trigger.New){
        plIds.add(pl.Id);
        if(pl.GFERP__Item__c != null){
            itmIds.add(pl.GFERP__Item__c );
        }
        if(pl.GFERP__Unit_of_Measure__c != null){
            UOMIds.add(pl.GFERP__Unit_of_Measure__c );
        }
        if(pl.Buy_From_Vendor_Id__c != null){
            vendorIds.add(pl.Buy_From_Vendor_Id__c);
        }
        String key = pl.GFERP__Item__c + '#' + pl.GFERP__Unit_of_Measure__c + '#' + pl.Buy_From_Vendor_Id__c;
        // maintain the PL Map
        if(plKeyMap.get(key) == null){
            plKeyMap.put(key, new List<GFERP__Purchase_Line__c>());
        }
        plKeyMap.get(key).add(pl);
    }
    
    Map<String, GFERP__Purchase_Line__c> lastPLMap = new Map<String, GFERP__Purchase_Line__c>();
    for(GFERP__Purchase_Line__c lastPL : [Select Id, GFERP__Item__c, GFERP__Unit_of_Measure__c, Order_Date__c, GFERP__Qty_Base__c, GFERP__Unit_Cost__c, Unit_Price__c, Buy_From_Vendor_Id__c from GFERP__Purchase_Line__c Where GFERP__Item__c IN: itmIds AND GFERP__Unit_of_Measure__c IN: UOMIds AND Id NOT IN: plIds AND Buy_From_Vendor_Id__c IN: vendorIds ORDER BY Order_Date__c DESC]){
        String key = lastPL.GFERP__Item__c + '#' + lastPL.GFERP__Unit_of_Measure__c + '#' + lastPL.Buy_From_Vendor_Id__c;
        if(plKeyMap.get(key) != null){
        	for(GFERP__Purchase_Line__c pl: plKeyMap.get(key)){
                // If key map exist then date should be less
                if(lastPL.Order_Date__c <= pl.Order_Date__c){
                    if(lastPLMap.get(key + '#' + pl.Order_Date__c) == null){lastPLMap.put(key + '#' + pl.Order_Date__c, lastPL); }        
                }
            }
        }
    }
    system.debug('lastPLMap == ' + lastPLMap);
    for(GFERP__Purchase_Line__c pl: Trigger.New){
        String key = pl.GFERP__Item__c + '#' + pl.GFERP__Unit_of_Measure__c + '#' + pl.Buy_From_Vendor_Id__c + '#' + pl.Order_Date__c;
        if(lastPLMap.get(key) != null){
            GFERP__Purchase_Line__c lastPL = lastPLMap.get(key);
            pl.Previous_Order_Date__c = lastPL.Order_Date__c;
            pl.Previous_Order_Qty__c = lastPL.GFERP__Qty_Base__c;
            pl.Previous_Unit_Cost__c = lastPL.GFERP__Unit_Cost__c;
            pl.Previous_Unit_Price__c = lastPL.Unit_Price__c;
        } else {
            pl.Previous_Order_Date__c = null;
            pl.Previous_Order_Qty__c = null;
            pl.Previous_Unit_Cost__c = null;
            pl.Previous_Unit_Price__c = null;
        }
        
    }
}