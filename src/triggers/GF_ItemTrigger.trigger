trigger GF_ItemTrigger on GFERP__Item__c (after update) {
    if (!system.isFuture()) {
         GF_InventoryMgmt.calculateOnHands(Trigger.newMap.keySet());
    }
}