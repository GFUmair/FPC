global class GF_DeleteItemUsageBatchable implements Database.Batchable<sObject> {
    private Integer batchSize;
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        // Retrieve all records to be processed
        String query = 'SELECT Id FROM GFERP__Item_Usage__c ';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext context, List<GFERP__Item_Usage__c> scope) {
        // Process the records in the current batch
        if(scope.size() > 0){
            delete scope;
        }
    }
    
    public void finish(Database.BatchableContext context) {
        // Perform any post-processing tasks here
        GF_ItemUsageUpdatesBatchable p = new GF_ItemUsageUpdatesBatchable();
        database.executeBatch(p);
    }
}