public with sharing class CustomerInventoryCountController {

    Set<Id> selectedIds;
    public Integer selectedCount {get;set;}

    public CustomerInventoryCountController(ApexPages.StandardSetController controller) {
        selectedIds = new Set<Id>();
        selectedCount = 0;
        for (Customer_Inventory_Count__c PC : (Customer_Inventory_Count__c[]) controller.getSelected()) {
            selectedIds.add(PC.Id);
            selectedCount++;
        }
    }

    public PageReference massDelete() {
        try {
            List<Customer_Inventory_Count__c> selectedIIList = [SELECT Id FROM Customer_Inventory_Count__c WHERE Id IN :selectedIds];
            if (selectedIIList.size() > 0) {
                delete selectedIIList;
            }
            return returnBack();
        } catch (exception e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
            return null;
        }
    }

    public Pagereference returnBack() {
        return new ApexPages.Action('{!List}').invoke();
    }
}