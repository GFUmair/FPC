/**
 * Created by mumair on 5/6/2024.
 */

public with sharing class GF_ImportPurchasePriceController {

    private final ApexPages.StandardSetController theController;
    private List<Import_Purchase_Price__c> theImportPPList;
    Set<Id> selectedIds;
    public Integer POCount { get; set; }
    public String errMsg { get; set; }
    public String pageName;
    public Map<String, Decimal> mapPurchaseTax = new Map<String, Decimal>();

    public GF_ImportPurchasePriceController(ApexPages.StandardSetController controller) {
        errMsg = '';
        theController = controller;
        selectedIds = new Set<Id>();
        for (Import_Purchase_Price__c SO : (Import_Purchase_Price__c[]) theController.getSelected()) {
            selectedIds.add(SO.Id);
        }
        if (selectedIds.size() != 0) {
            theImportPPList = [SELECT Id, Name FROM Import_Purchase_Price__c WHERE Processed__c = false AND Id IN: selectedIds];
            if (theImportPPList.size() == 0) {
                errMsg = 'There is nothing to process.';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errMsg));
            }
        } else {
            errMsg = 'Please select at least one record to process.';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errMsg));
        }
        POCount = selectedIds.size();
        pageName = getVFPageName();
    }

    public static string getVFPageName() {
        //In Production sytem, all VFs has GFERP__
        //need to add Misc.GetNameSpace() to the source class
        if (Test.isRunningTest()) return null;
        String pageName = ApexPages.CurrentPage().getUrl();
        pageName = pageName.replaceFirst('/apex/', '');
        pageName = EncodingUtil.urlEncode(pageName, 'UTF-8');
        string[] pageNameExtra = pageName.split('%3F', 0);
        pageName = pageNameExtra[0];
        return pageName;
    }

    public void importPurchaseOrder() {

        Savepoint sp = Database.setSavepoint();
        try {
            //retrieve all the record put in map which contains string that is Name and object itself
            Map<String, GFERP__Item__c> itemMap = new Map<String, GFERP__Item__c>();
            Map<String, Account> vendorMap = new Map<String, Account>();
            Map<String, GFERP__Item_Unit_of_Measure__c> UomMap = new Map<String, GFERP__Item_Unit_of_Measure__c>();
            Map<String, GFERP__Currency__c> currencyMap = new Map<String, GFERP__Currency__c>();
            Map<String, Import_Purchase_Price__c> purchasePriceMap = new Map<String, Import_Purchase_Price__c>();

            Set<String> accNames = new Set<String>();
            Set<String> orderSourceSet = new Set<String>();
            string key;

            Map<String, SObjectField> fields = Schema.SObjectType.Import_Purchase_Price__c.fields.getMap();
            List<String> lstFields = new List<String>();
            for (SObjectField field : fields.values()) {
                lstFields.add(field.getDescribe().getName());
            }
            String strQuery = 'SELECT ' + String.join(lstFields, ',');
            strQuery += ' FROM Import_Purchase_Price__c WHERE Id IN: selectedIds LIMIT 100';
            theImportPPList = Database.query(strQuery);
            Set<String> itemNames = new Set<String>();
            Set<String> salesOrders = new Set<String>();
            for (Import_Purchase_Price__c IPP : theImportPPList) {
                if (String.isNotBlank(IPP.Item__c)) {
                    itemNames.add(IPP.Item__c);
                }
                if (string.isNotEmpty(IPP.Account__c)) {
                    accNames.add(IPP.Account__c);
                }
            }

//            Map<Id, GFERP__Item__c> itemIdMap = new Map<Id, GFERP__Item__c>();
            for (GFERP__Item__c item : [SELECT Name FROM GFERP__Item__c Where Name IN :itemNames]) {
                itemMap.put(item.Name.toUpperCase(), item);
            }

            List<String> taxAreaNames = new List<String>();
            for (Account account : [SELECT Name, GFERP__Tax_Area__c, GFERP__Tax_Area__r.Name, GFERP__Tax_Liable__c, GFERP__Payment_Term__c FROM Account WHERE Name in :accNames]) {
                vendorMap.put(account.Name.toUpperCase(), account);
            }

            for (GFERP__Currency__c curr : [SELECT Name FROM GFERP__Currency__c LIMIT 10000]) {
                currencyMap.put(curr.Name.toUpperCase(), curr);
            }

            Map<Id, GFERP__Cross_Reference__c> theCRIdMap = new Map<Id, GFERP__Cross_Reference__c>();
            Set<Id> crossReferenceItemId = new Set<Id>();
            Map<string, GFERP__Cross_Reference__c> theCRMap = new Map<string, GFERP__Cross_Reference__c>();
            for (GFERP__Cross_Reference__c theCR : [
                SELECT Name, GFERP__Unit_Of_Measure__c, GFERP__Item__c, GFERP__Item__r.Name, GFERP__Cross_Referece_No__c,
                    GFERP__Item__r.GFERP__Item_Type__c, GFERP__Item__r.GFERP__Outbound_Freight__c, GFERP__Item__r.GFERP__Description__c,
                    GFERP__Account__c, GFERP__Unit_of_Measure__r.Name, GFERP__Unit_of_Measure__r.GFERP__Conversion__c, GFERP__Item__r.GFERP__Lot_Tracked__c,
                    GFERP__Item__r.GFERP__Tax_Group__c
                FROM GFERP__Cross_Reference__c
                WHERE GFERP__Unit_Of_Measure__c != null AND GFERP__Blocked__c = FALSE AND GFERP__Cross_Referece_No__c IN: itemNames
            ]) {
                key = theCR.GFERP__Cross_Referece_No__c.toUpperCase() + '##' + theCR.GFERP__Account__c;
                theCRMap.put(key, theCR);
                theCRIdMap.put(theCR.Id, theCR);
                crossReferenceItemId.add(theCR.GFERP__Item__c);
            }

            for (GFERP__Item_Unit_of_Measure__c UOM : [SELECT Name, GFERP__Item__c, GFERP__Unit_of_Measure__c, GFERP__Conversion__c FROM GFERP__Item_Unit_of_Measure__c WHERE GFERP__Item__r.Name IN:itemNames OR GFERP__Item__c IN :crossReferenceItemId]) {
                Key = UOM.Name.toUpperCase() + '##' + UOM.GFERP__Item__c;
                UomMap.put(Key, UOM);
            }

            Integer errorCount = 0;
            Map<String, Import_Purchase_Price__c> duplicateIPP = new Map<String, Import_Purchase_Price__c>();
            for (Import_Purchase_Price__c theImportPP : theImportPPList) {
                theImportPP.Error_Text__c = '';
                if (theImportPP.Processed__c) {
                    errorCount += 1;
                    theImportPP.Error_Text__c += 'This record is processed.\n';
                }

                //check customer account
                if (string.isNotEmpty(theImportPP.Account__c)) {
                    if (vendorMap.containsKey(theImportPP.Account__c.toUpperCase())) {
                        theImportPP.Id_Account__c = vendorMap.get(theImportPP.Account__c.toUpperCase()).Id;
                    } else {
                        errorCount += 1;
                        theImportPP.Error_Text__c += 'Account does not exist: ' + theImportPP.Account__c + '.\n';
                    }
                } else {
                    errorCount += 1;
                    theImportPP.Error_Text__c += 'Account is required.\n';
                }

                if (string.isNotEmpty(theImportPP.Currency_Code__c)) {
                    if (currencyMap.containsKey(theImportPP.Currency_Code__c.toUpperCase())) {
                        theImportPP.Id_Currency_Code__c = currencyMap.get(theImportPP.Currency_Code__c.toUpperCase()).Id;
                    } else {
                        errorCount += 1;
                        theImportPP.Error_Text__c += 'Currency Code does not exist: ' + theImportPP.Account__c + '.\n';
                    }
                } else {
                    errorCount += 1;
                    theImportPP.Error_Text__c += 'Currency Code is required.\n';
                }


                // check Item
                if (String.isNotBlank(theImportPP.Item__c)) {
                    Key = theImportPP.Item__c.toUpperCase();
                    if (itemMap.containsKey(Key)) {
                        theImportPP.Id_Item__c = itemMap.get(Key).Id;
                        theImportPP.Id_Item__r = itemMap.get(Key);
                        if (String.isNotBlank(theImportPP.Unit_of_Measure__c)) {
                            key = theImportPP.Unit_of_Measure__c.toUpperCase() + '##' + theImportPP.Id_Item__c;
                            if (UomMap.containsKey(key)) {theImportPP.Item_Unit_of_Measure__c = UomMap.get(key).Id;
                            } else {
                                errorCount += 1;
                                theImportPP.Error_Text__c += 'Unit of Measure [' + theImportPP.Unit_of_Measure__c + '] does not exist for item [' + theImportPP.Item__c + '].\n';
                            }
                        } else {
                            errorCount += 1;
                            theImportPP.Error_Text__c += 'Unit of Measure cannot be empty.\n';
                        }
                    }
                } else {
                    errorCount += 1;
                    theImportPP.Error_Text__c += 'Item is required.\n';
                }

                if (theImportPP.Minimum_Quantity__c == null || theImportPP.Minimum_Quantity__c == 0.0) {
                    errorCount += 1;
                    theImportPP.Error_Text__c += 'Please enter a minimum quantity.\n';
                }
                if (theImportPP.Purchase_Price__c == null || theImportPP.Purchase_Price__c <= 0.0) {
                    errorCount += 1;
                    theImportPP.Error_Text__c += 'Price can not be 0 or negative.\n';
                }
                if (theImportPP.Starting_Date__c == null || theImportPP.Starting_Date__c <= system.today()) {
                    errorCount += 1;
                    theImportPP.Error_Text__c += 'You can’t update a purchase price that starts in the past.\n';
                }
                if (theImportPP.End_Date__c == null) {
                    errorCount += 1;
                    theImportPP.Error_Text__c += 'End Date cannot be empty.\n';
                }
                if (theImportPP.End_Date__c <= theImportPP.Starting_Date__c) {
                    errorCount += 1;
                    theImportPP.Error_Text__c += 'End Date cannot be smaller than or equal to Start Date.\n';
                }

                String dupKey = theImportPP.Account__c + '#' + theImportPP.Item__c + '#' + theImportPP.Minimum_Quantity__c + '#' + theImportPP.Purchase_Price__c + '#' + theImportPP.Starting_Date__c + '#' + theImportPP.End_Date__c + '#' + theImportPP.Unit_of_Measure__c + '#' + theImportPP.Currency_Code__c;
                if(duplicateIPP.get(dupKey) != null) {
                    errorCount += 1;
                    theImportPP.Error_Text__c += 'This Purchase Price is a duplicate with [' + duplicateIPP.get(dupKey).name + '].\n';
                    duplicateIPP.get(dupKey).Error_Text__c += 'This Purchase Price is a duplicate with [' + theImportPP.name + '].\n';
                } else {
                    duplicateIPP.put(dupKey, theImportPP);
                }
            }

            Set<Id> itemIdSet = new Set<Id>();
            Set<Id> uomIdSet = new Set<Id>();
            Set<Id> accountIdSet = new Set<Id>();
            Set<Decimal> minQtySet = new Set<Decimal>();
            Set<Decimal> PPSet = new Set<Decimal>();
            Set<Date> sDateSet = new Set<Date>();
            Set<Date> eDateSet = new Set<Date>();
            for (Import_Purchase_Price__c importPP : theImportPPList) {
                if (string.isEmpty(importPP.Error_Text__c)) {
                    itemIdSet.add(importPP.Id_Item__c);
                    accountIdSet.add(importPP.Id_Account__c);
                    uomIdSet.add(importPP.Item_Unit_of_Measure__c);
                    PPSet.add(importPP.Purchase_Price__c);
                    minQtySet.add(importPP.Minimum_Quantity__c);
                    eDateSet.add(importPP.End_Date__c);
                    sDateSet.add(importPP.Starting_Date__c);
                }
            }

            Map<String, GFERP__Purchase_Price__c> duplicatePP = new Map<String, GFERP__Purchase_Price__c>();
            Map<String, GFERP__Purchase_Price__c> existingPP = new Map<String, GFERP__Purchase_Price__c>();
            for(GFERP__Purchase_Price__c pp : [
                                                SELECT Id, Name, GFERP__Account__c, GFERP__Ending_Date__c, GFERP__Starting_Date__c, GFERP__Minimum_Quantity__c, GFERP__Item__c, GFERP__Unit_Cost__c, GFERP__Unit_of_Measure__c, GFERP__Currency2__c
                                                FROM GFERP__Purchase_Price__c
                                                WHERE
                                                    GFERP__Account__c IN:accountIdSet
                                                    AND GFERP__Ending_Date__c IN: eDateSet
                                                    AND GFERP__Starting_Date__c IN:sDateSet
                                                    AND GFERP__Item__c IN: itemIdSet
                                                    AND GFERP__Minimum_Quantity__c IN: minQtySet
                                                    AND GFERP__Unit_Cost__c IN: PPSet
                                                    AND GFERP__Unit_of_Measure__c IN: uomIdSet
            ]){
                String key1 = pp.GFERP__Account__c + '#' + pp.GFERP__Ending_Date__c + '#' + pp.GFERP__Starting_Date__c + '#' + pp.GFERP__Item__c + '#' + pp.GFERP__Minimum_Quantity__c + '#' + pp.GFERP__Unit_Cost__c + '#' + pp.GFERP__Unit_of_Measure__c;
                duplicatePP.put(key1, pp);
            }

            for(GFERP__Purchase_Price__c pp : [
                                                SELECT Id, Name, GFERP__Account__c, GFERP__Ending_Date__c, GFERP__Starting_Date__c, GFERP__Minimum_Quantity__c, GFERP__Item__c, GFERP__Unit_Cost__c, GFERP__Unit_of_Measure__c, GFERP__Currency2__c
                                                FROM GFERP__Purchase_Price__c
                                                WHERE
                                                    GFERP__Account__c IN:accountIdSet
                                                    AND GFERP__Item__c IN: itemIdSet
                                                    AND GFERP__Minimum_Quantity__c IN: minQtySet
                                                    //AND GFERP__Unit_Cost__c IN: PPSet
                                                    AND GFERP__Unit_of_Measure__c IN: uomIdSet
            ]){
                String key1 = pp.GFERP__Account__c + '#' + pp.GFERP__Item__c + '#' + pp.GFERP__Minimum_Quantity__c /*+ '#' + pp.GFERP__Unit_Cost__c*/ + '#' + pp.GFERP__Unit_of_Measure__c + '#' + pp.GFERP__Currency2__c;
                system.debug('key1 == ' + key1);
                //String key1 = pp.GFERP__Item__c + '#' + pp.GFERP__Minimum_Quantity__c + pp.GFERP__Unit_of_Measure__c;
                existingPP.put(key1, pp);
            }

            for (Import_Purchase_Price__c importPP : theImportPPList) {
                if (string.isEmpty(importPP.Error_Text__c)) {
                    String key2 = importPP.Id_Account__c + '#' + importPP.End_Date__c + '#' + importPP.Starting_Date__c + '#' + importPP.Id_Item__c + '#' + importPP.Minimum_Quantity__c + '#' + importPP.Purchase_Price__c + '#' + importPP.Item_Unit_of_Measure__c;
                    if(duplicatePP.get(key2) != null) {
                        errorCount += 1;
                        importPP.Error_Text__c += 'This Purchase Price is a duplicate with [' + duplicatePP.get(key2).name + '].\n';
                    }
                }
            }
            GFERP.CompanyMgmt.systemCall = true;

            update theImportPPList;

            Integer successCount = 0;
            Integer failCount = 0;

            List<GFERP__Purchase_Price__c> newPPList = new List<GFERP__Purchase_Price__c>();
            Map<Id, List<GFERP__Purchase_Invoice_Line__c>> newPILMap = new Map<Id, List<GFERP__Purchase_Invoice_Line__c>>();
            Map<Id, List<GFERP__Purchase_Invoice_Line__c>> newAssignLines = new Map<Id, List<GFERP__Purchase_Invoice_Line__c>>();
            for (Import_Purchase_Price__c importPP : theImportPPList) {
                if (string.isEmpty(importPP.Error_Text__c)) {
                    String key2 = importPP.Id_Account__c + '#' + importPP.Id_Item__c + '#' + importPP.Minimum_Quantity__c /*+ '#' + importPP.Purchase_Price__c*/ + '#' + importPP.Item_Unit_of_Measure__c + '#' + importPP.Id_Currency_Code__c;
                    system.debug('key2 == ' + key2);
                    //String key2 = importPP.Id_Item__c + '#' + importPP.Minimum_Quantity__c + '#' + importPP.Item_Unit_of_Measure__c;
                    GFERP__Purchase_Price__c newPP = new GFERP__Purchase_Price__c();
                    if(existingPP.get(key2) != null && existingPP.get(key2).GFERP__Starting_Date__c <= importPP.Starting_Date__c && existingPP.get(key2).GFERP__Ending_Date__c >= importPP.Starting_Date__c) {
                        newPP = existingPP.get(key2);
                        newPP.GFERP__Ending_Date__c = importPP.Starting_Date__c.addDays(-1);
                        newPPList.add(newPP);
                    } //else {
                        newPP = new GFERP__Purchase_Price__c(
                            GFERP__Account__c = importPP.Id_Account__c,
                            GFERP__Currency2__c = (currencyMap.get('USD') != null? currencyMap.get('USD').Id: null),
                            GFERP__Ending_Date__c = importPP.End_Date__c,
                            GFERP__Item__c = importPP.Id_Item__c,
                            GFERP__Minimum_Quantity__c = importPP.Minimum_Quantity__c,
                            GFERP__Starting_Date__c = importPP.Starting_Date__c,
                            GFERP__Unit_Cost__c = importPP.Purchase_Price__c,
                            GFERP__Unit_of_Measure__c = importPP.Item_Unit_of_Measure__c,
                            Import_Purchase_Price__c = importPP.Id
                        );
                        importPP.Processed__c = true;
                    //}
                    newPPList.add(newPP);
                    successCount += 1;
                } else {
                    failCount += 1;
                }
            }

            upsert newPPList;
            update theImportPPList;
            if (failCount > 0) {
                errMsg = 'You must fix ' + errorCount + ' error(s) for ' + failCount + ' Import Purchase Price(s).';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errMsg));
            }
            if (successCount > 0) {
                errMsg = successCount + ' Purchase Price(s) Created.';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, errMsg));
            }
        } catch (Exception e) {
            Database.rollback(sp);
            errMsg = e.getMessage();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errMsg + ': ' + e.getLineNumber()));
        }
    }

    public PageReference returnBack() {
        return new ApexPages.Action('{!List}').invoke();
    }

    public PageReference massDelete() {
        List<Import_Purchase_Price__c> selectedIIList = [SELECT Id FROM Import_Purchase_Price__c WHERE Id IN :selectedIds];
        if (selectedIIList.size() > 0) {
            delete selectedIIList;
        }
        return returnBack();
    }
}