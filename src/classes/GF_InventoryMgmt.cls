/**
 * Created by zon cheng on 8/4/2023.
 */

public with sharing class GF_InventoryMgmt {

    @Future
    public static void calculateOnHands(Set<Id> itemIds) {

        Map<Id, GFERP__Item__c> items = new Map<Id, GFERP__Item__c>();
        for (Id itemId : itemIds) {
            items.put(itemId, new GFERP__Item__c(
                    Id = itemId, GW_OH__c = 0, Customer_OH__c = 0, SJP_OH__c = 0, KG_OH__c = 0, BMSI_OH__c = 0, Local_Weeks_OH__c = 0, Projected_Weekly_Usage__c = 0, Shipped_Last_Week__c = 0, On_PO__c = 0, Total_Weeks_Available__c = 0,
                    Next_16_Weeks__c = 0, Average_16_week_usage__c = 0, Total_OH__c = 0, Vendor_OH__c = 0
            ));
        }

        List<AggregateResult> results = [SELECT SUM(GFERP__Qty_Base__c) totalQty, GFERP__Item__c itemId FROM GFERP__Bin_Content__c WHERE GFERP__Item__c IN: itemIds AND GFERP__Warehouse__r.FPC_Local_Warehouse__c = true GROUP BY GFERP__Item__c];
        for (AggregateResult result : results) {
            Id itemId = (Id)result.get('itemId');
            items.get(itemId).GW_OH__c = (Decimal)result.get('totalQty');
        }

        List<AggregateResult> results1 = [SELECT SUM(GFERP__Qty_Base__c) totalQty, GFERP__Item__c itemId FROM GFERP__Bin_Content__c WHERE GFERP__Item__c IN: itemIds AND GFERP__Warehouse__r.Owned_By_Customer__c != null GROUP BY GFERP__Item__c];
        for (AggregateResult result : results1) {
            Id itemId = (Id)result.get('itemId');
            items.get(itemId).Customer_OH__c = (Decimal)result.get('totalQty');
        }

        List<AggregateResult> results2 = [SELECT SUM(GFERP__Qty_Base__c) totalQty, GFERP__Item__c itemId FROM GFERP__Bin_Content__c WHERE GFERP__Item__c IN: itemIds AND GFERP__Warehouse__r.FPC_Vendor_Warehouse__c = true GROUP BY GFERP__Item__c];
        for (AggregateResult result : results2) {
            Id itemId = (Id)result.get('itemId');
            items.get(itemId).Vendor_OH__c = (Decimal)result.get('totalQty');
        }

        List<AggregateResult> results3 = [SELECT SUM(GFERP__Qty_Base__c) totalQty, GFERP__Item__c itemId FROM GFERP__Bin_Content__c WHERE GFERP__Item__c IN: itemIds AND GFERP__Warehouse__r.SJP_Warehouse__c = true GROUP BY GFERP__Item__c];
        for (AggregateResult result : results3) {
            Id itemId = (Id)result.get('itemId');
            items.get(itemId).SJP_OH__c = (Decimal)result.get('totalQty');
        }

        List<AggregateResult> results4 = [SELECT SUM(GFERP__Qty_Base__c) totalQty, GFERP__Item__c itemId FROM GFERP__Bin_Content__c WHERE GFERP__Item__c IN: itemIds AND GFERP__Warehouse__r.KG_Warehouse__c = true GROUP BY GFERP__Item__c];
        for (AggregateResult result : results4) {
            Id itemId = (Id)result.get('itemId');
            items.get(itemId).KG_OH__c = (Decimal)result.get('totalQty');
        }

        List<AggregateResult> results5 = [SELECT SUM(GFERP__Qty_Base__c) totalQty, GFERP__Item__c itemId FROM GFERP__Bin_Content__c WHERE GFERP__Item__c IN: itemIds AND GFERP__Warehouse__r.BMSI_Warehouse__c = true GROUP BY GFERP__Item__c];
        for (AggregateResult result : results5) {
            Id itemId = (Id)result.get('itemId');
            items.get(itemId).BMSI_OH__c = (Decimal)result.get('totalQty');
        }

        List<AggregateResult> results6 = [SELECT SUM(GFERP__Qty_Base__c) totalQty, GFERP__Item__c itemId FROM GFERP__Bin_Content__c WHERE GFERP__Item__c IN: itemIds AND GFERP__Warehouse__r.PW_Warehouse__c = true GROUP BY GFERP__Item__c];
        for (AggregateResult result : results6) {
            Id itemId = (Id)result.get('itemId');
            items.get(itemId).PW_OH__c = (Decimal)result.get('totalQty');
        }

        List<AggregateResult> resultsTransit = [SELECT SUM(GFERP__Qty_Base__c) totalQty, GFERP__Item__c itemId FROM GFERP__Bin_Content__c WHERE GFERP__Item__c IN: itemIds AND GFERP__Warehouse__r.GFERP__Use_As_In_Transit__c = true GROUP BY GFERP__Item__c];
        for (AggregateResult result : resultsTransit) {
            Id itemId = (Id)result.get('itemId');
            items.get(itemId).In_Transit__c = (Decimal)result.get('totalQty');
        }

        List<AggregateResult> results7 = [SELECT SUM(GFERP__Qty_Base__c) totalQty, GFERP__Item__c itemId FROM GFERP__Bin_Content__c WHERE GFERP__Item__c IN: itemIds GROUP BY GFERP__Item__c];
        for (AggregateResult result : results7) {
            Id itemId = (Id)result.get('itemId');
            items.get(itemId).Total_OH__c = (Decimal)result.get('totalQty');
        }

        Map<Id, Decimal> localWeekOHMap = new Map<Id, Decimal>();
        List<AggregateResult> results8 = [
                SELECT SUM(GFERP__Qty_Base__c) totalQty, GFERP__Item__c itemId FROM GFERP__Item_Ledger_Entry__c
                WHERE GFERP__Item__c IN: itemIds AND GFERP__Warehouse__r.FPC_Local_Warehouse__c = true AND GFERP__Correction__c = FALSE AND GFERP__Quantity__c < 0 GROUP BY GFERP__Item__c
        ];
        for (AggregateResult result : results8) {
            Id itemId = (Id)result.get('itemId');
            Decimal onHand = (Decimal)result.get('totalQty');
            localWeekOHMap.put(itemId, onHand);
        }

        List<AggregateResult> shippedLastYearResults = [
                SELECT GFERP__Item__c itemId, SUM(GFERP__Qty_Base__c) shippedLastYear FROM GFERP__Item_Ledger_Entry__c
                WHERE GFERP__Posting_Date__c < TODAY AND GFERP__Posting_Date__c >: Date.today().addYears(-1) AND GFERP__Item__c IN: itemIds AND GFERP__Document_Type__c = 'Shipment' AND GFERP__Correction__c = FALSE GROUP BY GFERP__Item__c
        ];

        Map<Id, Decimal> shippedLastYearMap = new Map<Id, Decimal>();
        for (AggregateResult result : shippedLastYearResults) {
            Id itemId = (Id)result.get('itemId');
            Decimal shippedLastYear = (-1)*((Decimal)result.get('shippedLastYear')).setScale(2);
            shippedLastYearMap.put(itemId, shippedLastYear);

            if (localWeekOHMap.containsKey(itemId)) {
                localWeekOHMap.put(itemId, localWeekOHMap.get(itemId) + shippedLastYear);
            } else {
                localWeekOHMap.put(itemId, shippedLastYear);
            }
        }

        for (Id itemId : localWeekOHMap.keySet()) {
            Decimal localWeekOH = localWeekOHMap.get(itemId) / 52;
            items.get(itemId).Local_Weeks_OH__c = localWeekOH;
        }

        // Weekly average of the next 4 weeks based on last year, all customers
        Date nextWeekDate = Date.today().addDays(7);
        String nextWeekNoString = DateTime.newInstanceGmt(Date.newInstance(nextWeekDate.year(), nextWeekDate.month(), nextWeekDate.day()), Time.NewInstance(12,0,0,0)).format('w');
        Integer weekNo1 = Integer.valueOf(nextWeekNoString);
//
//        Map<Id, Decimal> countMap1 = new Map<Id, Decimal>();
//        List<AggregateResult> theCICList1 = [
//                SELECT SUM(Count_Qty__c) totalQty, Item_No__c itemId FROM Customer_Inventory_Count__c WHERE Item_No__c IN: itemIds AND WEEK_IN_YEAR(Week_End_Date__c) =: weekNo1 AND Week_End_Date__c = LAST_YEAR GROUP BY Item_No__c
//        ];
//        for (AggregateResult result : theCICList1) {
//            Id itemId = (Id)result.get('itemId');
//            Decimal theCount = (Decimal)result.get('totalQty');
//            countMap1.put(itemId, theCount);
//        }
//
//        Integer weekNo2 = weekNo1 + 1;
//        Map<Id, Decimal> countMap2 = new Map<Id, Decimal>();
//        Map<Id, Decimal> weekUsageMap1 = new Map<Id, Decimal>();
//        List<AggregateResult> theCICList2 = [
//                SELECT SUM(Count_Qty__c) totalQty, Item_No__c itemId FROM Customer_Inventory_Count__c WHERE Item_No__c IN: itemIds AND WEEK_IN_YEAR(Week_End_Date__c) =: weekNo2 AND Week_End_Date__c = LAST_YEAR GROUP BY Item_No__c
//        ];
//        for (AggregateResult result : theCICList2) {
//            Id itemId = (Id)result.get('itemId');
//            Decimal theCount = (Decimal)result.get('totalQty');
//            countMap2.put(itemId, theCount);
//            Decimal usage = countMap1.containsKey(itemId) ? countMap1.get(itemId) - theCount : 0;
//            weekUsageMap1.put(itemId, usage);
//        }
//
//        Integer weekNo3 = weekNo2 + 1;
//        Map<Id, Decimal> countMap3 = new Map<Id, Decimal>();
//        Map<Id, Decimal> weekUsageMap2 = new Map<Id, Decimal>();
//        List<AggregateResult> theCICList3 = [
//                SELECT SUM(Count_Qty__c) totalQty, Item_No__c itemId FROM Customer_Inventory_Count__c WHERE Item_No__c IN: itemIds AND WEEK_IN_YEAR(Week_End_Date__c) =: weekNo3 AND Week_End_Date__c = LAST_YEAR GROUP BY Item_No__c
//        ];
//        for (AggregateResult result : theCICList3) {
//            Id itemId = (Id)result.get('itemId');
//            Decimal theCount = (Decimal)result.get('totalQty');
//            countMap3.put(itemId, theCount);
//            Decimal usage = countMap2.containsKey(itemId) ? countMap2.get(itemId) - theCount : 0;
//            weekUsageMap2.put(itemId, usage);
//        }
//
//        Integer weekNo4 = weekNo3 + 1;
//        Map<Id, Decimal> countMap4 = new Map<Id, Decimal>();
//        Map<Id, Decimal> weekUsageMap3 = new Map<Id, Decimal>();
//        List<AggregateResult> theCICList4 = [
//                SELECT SUM(Count_Qty__c) totalQty, Item_No__c itemId FROM Customer_Inventory_Count__c WHERE Item_No__c IN: itemIds AND WEEK_IN_YEAR(Week_End_Date__c) =: weekNo4 AND Week_End_Date__c = LAST_YEAR GROUP BY Item_No__c
//        ];
//        for (AggregateResult result : theCICList4) {
//            Id itemId = (Id)result.get('itemId');
//            Decimal theCount = (Decimal)result.get('totalQty');
//            countMap4.put(itemId, theCount);
//            Decimal usage = countMap3.containsKey(itemId) ? countMap3.get(itemId) - theCount : 0;
//            weekUsageMap3.put(itemId, usage);
//        }
//
//        Integer weekNo5 = weekNo4 + 1;
//        Map<Id, Decimal> weekUsageMap4 = new Map<Id, Decimal>();
//        List<AggregateResult> theCICList5 = [
//                SELECT SUM(Count_Qty__c) totalQty, Item_No__c itemId FROM Customer_Inventory_Count__c WHERE Item_No__c IN: itemIds AND WEEK_IN_YEAR(Week_End_Date__c) =: weekNo5 AND Week_End_Date__c = LAST_YEAR GROUP BY Item_No__c
//        ];
//        for (AggregateResult result : theCICList5) {
//            Id itemId = (Id)result.get('itemId');
//            Decimal theCount = (Decimal)result.get('totalQty');
//            Decimal usage = countMap4.containsKey(itemId) ? countMap4.get(itemId) - theCount : 0;
//            weekUsageMap4.put(itemId, usage);
//        }
//        for (Id itemId : itemIds) {
//            Decimal usage = 0;
//            if (weekUsageMap1.containsKey(itemId)) {
//                usage += weekUsageMap1.get(itemId);
//            }
//            if (weekUsageMap2.containsKey(itemId)) {
//                usage += weekUsageMap2.get(itemId);
//            }
//            if (weekUsageMap3.containsKey(itemId)) {
//                usage += weekUsageMap3.get(itemId);
//            }
//            if (weekUsageMap4.containsKey(itemId)) {
//                usage += weekUsageMap4.get(itemId);
//            }
//            items.get(itemId).Projected_Weekly_Usage__c = usage / 4;
//        }

        /** Next 4 weeks, from previous year **/
        Integer next4Weeks = weekNo1 + 4;
        List<AggregateResult> shippedNext4WeeksResults = [
                SELECT GFERP__Item__c itemId, SUM(GFERP__Qty_Base__c) shippedNext4Weeks FROM GFERP__Item_Ledger_Entry__c
                WHERE WEEK_IN_YEAR(GFERP__Posting_Date__c) >=: weekNo1 AND WEEK_IN_YEAR(GFERP__Posting_Date__c) <=: next4Weeks AND GFERP__Posting_Date__c = LAST_YEAR AND GFERP__Item__c IN: itemIds AND GFERP__Document_Type__c = 'Shipment' AND GFERP__Correction__c = FALSE GROUP BY GFERP__Item__c
        ];

        Map<Id, Decimal> shippedNext4WeekMap = new Map<Id, Decimal>(); //
        for (AggregateResult result : shippedNext4WeeksResults) {
            Id itemId = (Id)result.get('itemId');
            Decimal shippedNext4Weeks = (-1)*((Decimal)result.get('shippedNext4Weeks')).setScale(2);
            shippedNext4WeekMap.put(itemId, shippedNext4Weeks);
        }
        List<AggregateResult> next4WeeksResults = [
                SELECT SUM(Week_Usage__c) totalQty, Item_No__c itemId FROM Customer_Inventory_Count__c
                WHERE Item_No__c IN: itemIds AND WEEK_IN_YEAR(Week_End_Date__c) >=: weekNo1 AND WEEK_IN_YEAR(Week_End_Date__c) <=: next4Weeks AND Week_End_Date__c = LAST_YEAR GROUP BY Item_No__c
        ];
        for (AggregateResult result : next4WeeksResults) {
            Id itemId = (Id)result.get('itemId');
            Decimal shippedQty = ((Decimal)result.get('totalQty')).setScale(2);
            if (shippedNext4WeekMap.containsKey(itemId)) {
                shippedQty = shippedQty + shippedNext4WeekMap.get(itemId);
            }
            items.get(itemId).Projected_Weekly_Usage__c = shippedQty / 4;
        }


        /** Shipped last week**/
        Integer lastWeekNo = Integer.valueOf(nextWeekNoString) - 2;
        List<AggregateResult> shippedLastWeekResults = [
                SELECT GFERP__Item__c itemId, SUM(GFERP__Qty_Base__c) shippedLastWeek FROM GFERP__Item_Ledger_Entry__c
                WHERE WEEK_IN_YEAR(GFERP__Posting_Date__c) =: lastWeekNo AND GFERP__Posting_Date__c = THIS_YEAR AND GFERP__Document_Type__c = 'Shipment'
                AND GFERP__Correction__c = FALSE AND GFERP__Item__c IN: itemIds
                GROUP BY GFERP__Item__c
        ];

        for (AggregateResult result : shippedLastWeekResults) {
            Id itemId = (Id)result.get('itemId');
            items.get(itemId).Shipped_Last_Week__c = (-1)*((Decimal)result.get('shippedLastWeek')).setScale(2);
        }

        /** Average Weekly Usage **/
        List<AggregateResult> beginResultsYear = [
                SELECT GFERP__Item__c itemId, SUM(GFERP__Qty_Base__c) beginCount FROM GFERP__Item_Ledger_Entry__c
                WHERE Customer_Inventory__c = true AND GFERP__Posting_Date__c <=: Date.today().addYears(-1) AND GFERP__Correction__c = FALSE
                AND GFERP__Item__c IN: itemIds
                GROUP BY GFERP__Item__c
        ];
        Map<Id, Decimal> beginYearCountMap = new Map<Id, Decimal>();
        for (AggregateResult result : beginResultsYear) {
            Id itemId = (Id)result.get('itemId');
            Decimal beginCount = ((Decimal)result.get('beginCount')).setScale(2);
            beginYearCountMap.put(itemId, beginCount);
        }

        List<AggregateResult> endResultsYear = [
                SELECT GFERP__Item__c itemId, SUM(GFERP__Qty_Base__c) endCount FROM GFERP__Item_Ledger_Entry__c
                WHERE Customer_Inventory__c = true AND GFERP__Posting_Date__c <= TODAY AND GFERP__Correction__c = FALSE
                AND GFERP__Item__c IN: itemIds
                GROUP BY GFERP__Item__c
        ];
        Map<Id, Decimal> endYearCountMap = new Map<Id, Decimal>();
        for (AggregateResult result : endResultsYear) {
            Id itemId = (Id)result.get('itemId');
            Decimal beginCount = ((Decimal)result.get('endCount')).setScale(2);
            endYearCountMap.put(itemId, beginCount);
        }

        for (Id itemId : itemIds) {
            Decimal beginCountYear = beginYearCountMap.containsKey(itemId) ? beginYearCountMap.get(itemId) : 0;
            Decimal endCountYear = endYearCountMap.containsKey(itemId) ? endYearCountMap.get(itemId) : 0;
            Decimal shippedLastYear = shippedLastYearMap.containsKey(itemId) ? shippedLastYearMap.get(itemId) : 0;
            //This calculation does not work if you post initial inventory by using positive adjustment instead of Whse. Receipt.
            if ((beginCountYear - endCountYear + shippedLastYear) / 52 > 0) {
                items.get(itemId).Average_Weekly_Usage__c = (beginCountYear - endCountYear + shippedLastYear) / 52;
            } else {
                items.get(itemId).Average_Weekly_Usage__c = 0;
            }
        }

        /** On PO **/
        List<AggregateResult> onPOResults = [
                SELECT SUM(GFERP__O_S_Qty_Base__c) totalQty, GFERP__Item__c itemId FROM GFERP__Purchase_Line__c
                WHERE GFERP__Item__c IN: itemIds AND GFERP__O_S_Qty_Base__c > 0 AND GFERP__Closed__c = FALSE
                GROUP BY GFERP__Item__c
        ];
        for (AggregateResult result : onPOResults) {
            Id itemId = (Id)result.get('itemId');
            Decimal totalQty = ((Decimal)result.get('totalQty')).setScale(2);
            items.get(itemId).On_PO__c = totalQty;
        }

        Map<Id, Decimal> onVendorMap = new Map<Id, Decimal>();
        List<AggregateResult> vendorWhseResults = [
                SELECT GFERP__Item__c itemId, SUM(GFERP__Qty_Base__c) totalQty
                FROM GFERP__Item_Ledger_Entry__c WHERE GFERP__Warehouse__r.FPC_Vendor_Warehouse__c = true AND GFERP__Correction__c = FALSE AND GFERP__Item__c IN: itemIds GROUP BY GFERP__Item__c
        ];
        for (AggregateResult result : vendorWhseResults) {
            Id itemId = (Id)result.get('itemId');
            Decimal totalQty = ((Decimal)result.get('totalQty')).setScale(2);
            onVendorMap.put(itemId, totalQty);
        }

        for (GFERP__Item__c item : items.values()) {
            if (item.Average_Weekly_Usage__c > 0) {
                Decimal onVendor = onVendorMap.containsKey(item.Id) ? onVendorMap.get(item.Id) : 0;
                Decimal weeksAvailTotalStandard = ((item.GW_OH__c + onVendor + item.On_PO__c) / item.Average_Weekly_Usage__c).setScale(2);
                if (weeksAvailTotalStandard - weeksAvailTotalStandard.intValue() > 0.0) {
                    item.Total_Weeks_Available__c = weeksAvailTotalStandard;
                } else {
                    item.Total_Weeks_Available__c = weeksAvailTotalStandard.intValue();
                }
            }
        }


        Date firstDateOfTheYear = Date.newInstance(Date.today().year(), 1, 1);
        List<AggregateResult> beginYearResults = [
                SELECT GFERP__Item__c itemId, SUM(GFERP__Qty_Base__c) beginCount FROM GFERP__Item_Ledger_Entry__c
                WHERE Customer_Inventory__c = true AND GFERP__Posting_Date__c <=: firstDateOfTheYear AND GFERP__Correction__c = FALSE AND GFERP__Item__c IN: itemIds
                GROUP BY GFERP__Item__c
        ];
        Map<Id, Decimal> beginYearMap = new Map<Id, Decimal>();
        for (AggregateResult result : beginYearResults) {
            Id itemId = (Id)result.get('itemId');
            Decimal beginCount = ((Decimal)result.get('beginCount')).setScale(2);
            beginYearMap.put(itemId, beginCount);
        }

        List<AggregateResult> endYearResults = [
                SELECT GFERP__Item__c itemId, SUM(GFERP__Qty_Base__c) endCount FROM GFERP__Item_Ledger_Entry__c
                WHERE Customer_Inventory__c = true AND GFERP__Posting_Date__c <= TODAY AND GFERP__Correction__c = FALSE AND GFERP__Item__c IN: itemIds
                GROUP BY GFERP__Item__c
        ];
        Map<Id, Decimal> endYearMap = new Map<Id, Decimal>();
        for (AggregateResult result : endYearResults) {
            Id itemId = (Id)result.get('itemId');
            Decimal beginCount = ((Decimal)result.get('endCount')).setScale(2);
            endYearMap.put(itemId, beginCount);
        }

        List<AggregateResult> shippedThisYearResults = [
                SELECT GFERP__Item__c itemId, SUM(GFERP__Qty_Base__c) shippedThisYear FROM GFERP__Item_Ledger_Entry__c
                WHERE GFERP__Posting_Date__c = THIS_YEAR AND GFERP__Item__c IN: itemIds AND GFERP__Document_Type__c = 'Shipment' AND GFERP__Correction__c = FALSE GROUP BY GFERP__Item__c
        ];

        Map<Id, Decimal> shippedThisYearMap = new Map<Id, Decimal>();
        for (AggregateResult result : shippedThisYearResults) {
            Id itemId = (Id)result.get('itemId');
            Decimal shippedThisYear = (-1)*((Decimal)result.get('shippedThisYear')).setScale(2);
            shippedThisYearMap.put(itemId, shippedThisYear);
        }

        for (GFERP__Item__c item : items.values()) {
            Decimal beginYear = beginYearMap.containsKey(item.Id) ? beginYearMap.get(item.Id) : 0;
            Decimal endYear = endYearMap.containsKey(item.Id) ? endYearMap.get(item.Id) : 0;
            Decimal shippedThisYear = shippedThisYearMap.containsKey(item.Id) ? shippedThisYearMap.get(item.Id) : 0;
            item.Usage_YTD__c = beginYear - endYear + shippedThisYear;
        }

        /** Next 16 week, from previous year **/
        Integer next16Weeks = weekNo1 + 15;
        List<AggregateResult> shippedNext16WeeksResults = [
                SELECT GFERP__Item__c itemId, SUM(GFERP__Qty_Base__c) shippedNext16Weeks FROM GFERP__Item_Ledger_Entry__c
                WHERE WEEK_IN_YEAR(GFERP__Posting_Date__c) >=: weekNo1 AND WEEK_IN_YEAR(GFERP__Posting_Date__c) <=: next16Weeks AND GFERP__Posting_Date__c = LAST_YEAR AND GFERP__Item__c IN: itemIds AND GFERP__Document_Type__c = 'Shipment' AND GFERP__Correction__c = FALSE GROUP BY GFERP__Item__c
        ];

        Map<Id, Decimal> shippedNext16WeekMap = new Map<Id, Decimal>(); //
        for (AggregateResult result : shippedNext16WeeksResults) {
            Id itemId = (Id)result.get('itemId');
            Decimal shipped16NextWeeks = (-1)*((Decimal)result.get('shippedNext16Weeks')).setScale(2);
            shippedNext16WeekMap.put(itemId, shipped16NextWeeks);
        }
        List<AggregateResult> next16WeeksResults = [
                SELECT SUM(Week_Usage__c) totalQty, Item_No__c itemId FROM Customer_Inventory_Count__c
                WHERE Item_No__c IN: itemIds AND WEEK_IN_YEAR(Week_End_Date__c) >=: weekNo1 AND WEEK_IN_YEAR(Week_End_Date__c) <=: next16Weeks AND Week_End_Date__c = LAST_YEAR GROUP BY Item_No__c
        ];
        for (AggregateResult result : next16WeeksResults) {
            Id itemId = (Id)result.get('itemId');
            Decimal shippedQty = ((Decimal)result.get('totalQty')).setScale(2);
            if (shippedNext16WeekMap.containsKey(itemId)) {
                shippedQty = shippedQty + shippedNext16WeekMap.get(itemId);
            }
            items.get(itemId).Next_16_Weeks__c = shippedQty;
        }

        /** Average 16 week usage **/
        Date startOfWeek = Date.today().toStartOfWeek();
        Date last16Weeks = Date.today().toStartOfWeek().addDays(-112); // last 16 weeks
        List<AggregateResult> last16WeeksResults = [
                SELECT GFERP__Item__c itemId, SUM(GFERP__Qty_Base__c) shipped16Weeks FROM GFERP__Item_Ledger_Entry__c
                WHERE GFERP__Posting_Date__c >=: last16Weeks AND GFERP__Posting_Date__c <: startOfWeek AND GFERP__Item__c IN: itemIds AND GFERP__Document_Type__c = 'Shipment' AND GFERP__Correction__c = FALSE GROUP BY GFERP__Item__c
        ];
        Map<Id, Decimal> shippedLast16WeekMap = new Map<Id, Decimal>();
        for (AggregateResult result : last16WeeksResults) {
            Id itemId = (Id)result.get('itemId');
            Decimal shipped16Weeks = (-1)*((Decimal)result.get('shipped16Weeks')).setScale(2);
            shippedLast16WeekMap.put(itemId, shipped16Weeks);
        }

        List<AggregateResult> last16WeekUsageResults = [
                SELECT SUM(Week_Usage__c) totalQty, Item_No__c itemId FROM Customer_Inventory_Count__c
                WHERE Item_No__c IN: itemIds AND Week_End_Date__c >=: last16Weeks AND Week_End_Date__c <=: startOfWeek GROUP BY Item_No__c
        ];
        for (AggregateResult result : last16WeekUsageResults) {
            Id itemId = (Id)result.get('itemId');
            Decimal shippedQty = ((Decimal)result.get('totalQty')).setScale(2);
            if (shippedLast16WeekMap.containsKey(itemId)) {
                shippedQty = shippedQty + shippedLast16WeekMap.get(itemId);
            }
            items.get(itemId).Average_16_week_usage__c = shippedQty / 16;
        }

        Date lastDayofWeekOfInterest = Date.today().toStartOfWeek().addDays(6);

        List<Customer_Inventory_Count__c> beginInventory = [
                SELECT Item_No__c, Week_End_Date__c, Count_Qty__c
                FROM Customer_Inventory_Count__c
                WHERE Week_End_Date__c <=: lastDayofWeekOfInterest.addDays(-7) AND Week_End_Date__c >: lastDayofWeekOfInterest.addDays(-14) AND Item_No__c IN: itemIds
        ];
//        List<Interplant_Transfer__c> transferOut = [
//                SELECT Item__c, From_Customer__c, To_Customer__c, Transfer_Date__c, Quantity__c
//                FROM Interplant_Transfer__c
//                WHERE Transfer_Date__c <=: lastDayofWeekOfInterest AND Transfer_Date__c >: lastDayofWeekOfInterest.addDays(-7)
//        ];

        Map<Id, Map<String, Decimal>> itemLineMap = new Map<Id, Map<String, Decimal>>();
        for (Id itemId : itemIds) {
            itemLineMap.put(itemId, new Map<String, Decimal>());
            itemLineMap.get(itemId).put('beginCount', 0);
            itemLineMap.get(itemId).put('endCount', 0);
            itemLineMap.get(itemId).put('transferQty', 0);
        }

        for (Customer_Inventory_Count__c result : beginInventory) {
            Id itemId = result.Item_No__c;
            Decimal beginCount1 = result.Count_Qty__c.setScale(2);
            if (itemLineMap.containsKey(itemId)) {
                Decimal currentQty = itemLineMap.get(itemId).get('beginCount');
                if(beginCount1 - beginCount1.intValue() > 0.0){
                    itemLineMap.get(itemId).put('beginCount', currentQty + beginCount1);
                } else {
                    itemLineMap.get(itemId).put('beginCount', currentQty + beginCount1.intValue());
                }
            }
        }
//        for (Interplant_Transfer__c result : transferOut) {
//            if (itemLineMap.containsKey(result.Item__c)) {
//                Decimal transferQty = result.Quantity__c.setScale(2);
//                Decimal currentQty = itemLineMap.get(result.Item__c).get('transferQty');
//                itemLineMap.get(result.Item__c).put('transferQty', currentQty - transferQty);
//            }
//        }

        List<Customer_Inventory_Count__c> endInventory = [
                SELECT Item_No__c, Week_End_Date__c, Count_Qty__c
                FROM Customer_Inventory_Count__c
                WHERE Week_End_Date__c <=: lastDayofWeekOfInterest AND Week_End_Date__c >: lastDayofWeekOfInterest.addDays(-7) AND Item_No__c IN: itemIds
        ];
        for (Customer_Inventory_Count__c result : endInventory) {
            Id itemId = result.Item_No__c;
            Decimal endCount1 = result.Count_Qty__c.setScale(2);
            if(itemLineMap.containsKey(itemId)){
                Decimal currentQty = itemLineMap.get(itemId).get('endCount');
                if(endCount1 - endCount1.intValue() > 0.0){
                    itemLineMap.get(itemId).put('endCount', currentQty + endCount1);
                } else {
                    itemLineMap.get(itemId).put('endCount', currentQty + endCount1.intValue());
                }
            }
        }
        for (Id itemId : itemLineMap.keySet()) {
            items.get(itemId).Actual_Week_Usage__c = itemLineMap.get(itemId).get('beginCount') - itemLineMap.get(itemId).get('endCount') + items.get(itemId).Shipped_Last_Week__c;
        }

        update items.values();
    }

    @Future
    public static void updatePreviousPLQuantity(Set<Id> PLIds) {
        Map<Id, GFERP__Item__c> itemList = new Map<Id, GFERP__Item__c>();
        List<GFERP__Purchase_Line__c> PLList = [SELECT GFERP__Item__c, GFERP__Quantity__c FROM GFERP__Purchase_Line__c WHERE Id IN: PLIds];
        for (GFERP__Purchase_Line__c PL : PLList) {
            itemList.put(PL.GFERP__Item__c, new GFERP__Item__c(Id = PL.GFERP__Item__c, Previous_PO_Quantity__c = PL.GFERP__Quantity__c));
        }
        update itemList.values();
    }
}