global class GF_ItemUsageUpdatesSchedulable implements Schedulable{
    global void execute(SchedulableContext ctx) {
        GF_DeleteItemUsageBatchable p = new GF_DeleteItemUsageBatchable();
        database.executeBatch(p);
      /*GF_ItemUsageUpdatesBatchable p = new GF_ItemUsageUpdatesBatchable();
        database.executeBatch(p);*/
   }   
}