public class GF_ImportSalesPriceController {
    private final ApexPages.StandardSetController theController;
    public Static String errMsg { get; set; }
    public List<Import_Sales_Prices__c> theIMPSPList { get; set; }
    public GFERP__Company_Setup__c companyList { get; set; }
    public Set<Id> selectedIds;

    public GF_ImportSalesPriceController(ApexPages.StandardSetController controller) {
        theController = controller;
        selectedIds = new Set<Id>();
        errMsg = '';

        for (Import_Sales_Prices__c ISP1 : (Import_Sales_Prices__c[]) theController.getSelected()) {
            selectedIds.add(ISP1.Id);

        }

        theIMPSPList = [
                SELECT Id,Account__c, Ending_Date__c,Item__c, Minimum_Quantity__c, Sales_Price__c, Item_Id__c,Unit_of_Measure_Id__c,
                        Sales_Pricing_Group__c, Starting_Date__c, Unit_of_Measure__c, Pricing_Type__c,Currency__c, Processed__c
                FROM Import_Sales_Prices__c
                WHERE Id IN:selectedIds
        ];
        companyList = [Select Name, GFERP__Currency__c from GFERP__Company_Setup__c];

        system.debug('theIMPSPList == ' + theIMPSPList);
        if (selectedIds.size() == 0) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please select at least one Import Sales Price'));
            return;
        }

        if (selectedIds.size() > 0) {
            system.debug('selectedIds == ' + selectedIds);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Are you sure to create ' + selectedIds.size() + ' Sales Price(s)'));
        }
    }


    public void createSP() {
        Integer errNo = 0;
        Date earliestDate;

        try {
            List<String> uomNameList = new List<String>();
            List<String> itmNameList = new List<String>();
            Map<String, GFERP__Item__c> itmMap = new Map<String, GFERP__Item__c>();
            Map<String, GFERP__Item_Unit_of_Measure__c> uomMap = new Map<String, GFERP__Item_Unit_of_Measure__c>();
            //first step error checking
            for (Import_Sales_Prices__c ISP : theIMPSPList) {
                if (earliestDate == null || earliestDate > ISP.Starting_Date__c){
                    earliestDate = ISP.Starting_Date__c;
                }

                ISP.Error_Text__c = '';

                if (ISP.Processed__c) {
                    ISP.Error_Text__c = 'Sales Price is processed already./';
                    errNo++;
                }

                if (ISP.Sales_Price__c == 0) {
                    ISP.Error_Text__c = 'Sales price cannot be 0./';
                    errNo++;
                }

                if (ISP.Starting_Date__c == null) {
                    ISP.Error_Text__c = 'Start date cannot be blank./';
                    errNo++;
                }

                /*if (ISP.Starting_Date__c < Date.today()) {
                    ISP.Error_Text__c = 'Start date must be greater than today./';
                    errNo++;
                }*/
                if (String.isNotEmpty(ISP.item__c)) {
                    itmNameList.add(ISP.item__c);
                } else {
                    ISP.Error_Text__c = 'Item is empty./';
                    errNo++;
                }

                if (String.isNotEmpty(ISP.Unit_of_Measure__c)) {
                    uomNameList.add(ISP.Unit_of_Measure__c);
                } else {
                    ISP.Error_Text__c = 'UOM is empty./';
                    errNo++;
                }

                //if (ISP.Ending_Date__c == null) {
                //    ISP.Error_Text__c = 'End Date is empty.';
                //    errNo++;
                //}

                //if (ISP.Minimum_Quantity__c == null) {
                //    ISP.Error_Text__c = 'Quantity is empty.';
                //    errNo++;
                //}
            }

            for (GFERP__Item__c tempItm : [Select Id, Name from GFERP__Item__c where Name IN:itmNameList]) {
                itmMap.put(tempItm.Name, tempItm);
            }
            for (GFERP__Item_Unit_of_Measure__c tempUOM : [Select Id, Name,GFERP__Item__c from GFERP__Item_Unit_of_Measure__c where Name IN:uomNameList AND GFERP__Item__r.Name IN :itmNameList]) {
                uomMap.put(tempUOM.GFERP__Item__c + '#' + tempUOM.Name, tempUOM);
            }

            List<GFERP__Sales_Price2__c> newSPList = new List<GFERP__Sales_Price2__c>();
            List<GFERP__Sales_Price2__c> udpatedSPList = new List<GFERP__Sales_Price2__c>();
            Map<Id, GFERP__Sales_Price2__c> updatedMapSP = new Map<Id, GFERP__Sales_Price2__c>();
            Map<String, list<GFERP__Sales_Price2__c>> lastSPMap = new Map<String, list<GFERP__Sales_Price2__c>>();

            //What is the smallest
            //Look all open Sales Prices with the same Item, UOM,
            for (GFERP__Sales_Price2__c lastSP : [Select Id, Name, GFERP__Starting_Date__c, GFERP__Ending_Date__c, GFERP__Item__c, GFERP__Unit_of_Measure__c
                From GFERP__Sales_Price2__c WHERE GFERP__Item__r.Name IN:itmNameList AND GFERP__Unit_of_Measure__r.Name IN:uomNameList
                AND GFERP__Ending_Date__c >=: earliestDate
                AND GFERP__Starting_Date__c <=: earliestDate]) {

                //ORDER BY GFERP__Starting_Date__c DESC]) {  //not important
                if (lastSPMap.get(lastSP.GFERP__Item__c + '#' + lastSP.GFERP__Unit_of_Measure__c) == null){
                    lastSPMap.put(lastSP.GFERP__Item__c + '#' + lastSP.GFERP__Unit_of_Measure__c, new List<GFERP__Sales_Price2__c>());
                }
                lastSPMap.get(lastSP.GFERP__Item__c + '#' + lastSP.GFERP__Unit_of_Measure__c).add(lastSP);
            }

            //2nd step error checking
            for (Import_Sales_Prices__c ISP : theIMPSPList) {
                if (itmMap.get(ISP.item__c) != null) {
                    ISP.Item_Id__c = itmMap.get(ISP.item__c).Id;
                } else {
                    ISP.Error_Text__c = 'Item is not found./';
                    errNo++;
                }

                if (uomMap.get(ISP.Item_Id__c + '#' + ISP.Unit_of_Measure__c) != null) {
                    ISP.Unit_of_Measure_Id__c = uomMap.get(ISP.Item_Id__c + '#' + ISP.Unit_of_Measure__c).Id;
                } else {
                    ISP.Error_Text__c = 'UOM is not found./';
                    errNo++;
                }

            }

            //if (theIMPSPList.size() > 0) {
            update theIMPSPList;
            //}
            if (errNo > 0) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'You must fix ' + errNo +' error(s) before you continue!'));
                return;
            } else {
                // Map for smallest date
                Map<String, Date> earliestDateMap = new Map<String, Date>();
                for (Import_Sales_Prices__c ISP : theIMPSPList) {
                    if(earliestDateMap.get(ISP.Item_Id__c + '#' + ISP.Unit_of_Measure_Id__c) == null){
                        earliestDateMap.put(ISP.Item_Id__c + '#' + ISP.Unit_of_Measure_Id__c, ISP.Starting_Date__c);
                    }else if(earliestDateMap.get(ISP.Item_Id__c + '#' + ISP.Unit_of_Measure_Id__c) > ISP.Starting_Date__c){
                        earliestDateMap.put(ISP.Item_Id__c + '#' + ISP.Unit_of_Measure_Id__c, ISP.Starting_Date__c);
                    }
                }
                //start process data if there is no error
                for (Import_Sales_Prices__c ISP : theIMPSPList) {
                    //update existing open sales prices.
                    //change the Ending Date to the new SP’s Starting Date - 1,
                    if (lastSPMap.get(ISP.Item_Id__c + '#' + ISP.Unit_of_Measure_Id__c) != null) {
                        earliestDate = earliestDateMap.get(ISP.Item_Id__c + '#' + ISP.Unit_of_Measure_Id__c);
                        for (GFERP__Sales_Price2__c theOldSP : lastSPMap.get(ISP.Item_Id__c + '#' + ISP.Unit_of_Measure_Id__c)) {
                            if (theOldSP.GFERP__Starting_Date__c < earliestDate) {
                                //theOldSP.GFERP__Ending_Date__c = (earliestDate != null? earliestDate.addDays(-1) : ISP.Starting_Date__c.addDays(-1));
                                theOldSP.GFERP__Ending_Date__c = earliestDate.addDays(-1);
                                //updpatedSPList.add(theOldSP);
                                updatedMapSP.put(theOldSP.Id, theOldSP);
                            }
                        }
                    }
                    //insert new SP
                    GFERP__Sales_Price2__c newSP = new GFERP__Sales_Price2__c();
                    newSP.GFERP__Item__c = ISP.Item_Id__c;
                    newSP.GFERP__Unit_of_Measure__c = ISP.Unit_of_Measure_Id__c;
                    newSP.GFERP__Sales_Price__c = ISP.Sales_Price__c;
                    newSP.GFERP__Starting_Date__c = ISP.Starting_Date__c;
                    newSP.GFERP__Currency__c = companyList.GFERP__Currency__c;
                    newSP.GFERP__Minimum_Quantity__c = 1;
                    newSP.GFERP__Ending_Date__c = Date.newInstance(2030, 12, 31);
                    newSPList.add(newSP);

                    //update processed flag
                    ISP.Processed__c = true;
                }

                //update existing open SP
                if (updatedMapSP.size() > 0) {
                    //update udpatedSPList;
                    update updatedMapSP.values();
                }
                //insert new SP
                if (newSPList.size() > 0) {
                    insert newSPList;
                }
                //update import sales prices
                update theIMPSPList;

                if (selectedIds.size() > 0) {
                    errMsg = selectedIds.size() + ' Sales Price(s) are successfully created.';
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, errMsg));
                }

            }

        } catch (Exception e) {
            system.debug('error ==== ' + e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'An error has occured creating Sales Price records: ' + e.getMessage() + ': ' + e.getLineNumber()));
            return;
        }
    }

    public PageReference returnBack() {
        return new ApexPages.Action('{!List}').invoke();
    }

    public pagereference massDelete() {
        try {
            List<Import_Sales_Prices__c> selectedISPList = [
                    SELECT Id
                    FROM Import_Sales_Prices__c
                    WHERE Id IN :selectedIds
            ];
            delete selectedISPList;
            return returnBack();
        } catch (exception e) {
            errMsg = e.getMessage();
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errMsg));
            return null;
        }
    }
}