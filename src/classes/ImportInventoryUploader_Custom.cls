public class ImportInventoryUploader_Custom {
    public string nameFile { get; set; }
    public Blob contentFile { get; set; }
    String[] filelines = new String[]{};
    List<GFCON__Import_Inventory2__c> ImportInventoryList;

    public ImportInventoryUploader_Custom(ApexPages.StandardSetController controller) {
        
    }
    public Pagereference SelectFileAndRead(){
        nameFile = blobToString(contentFile, 'ISO-8859-1');
        return ReadFile();
    }
    public Pagereference ReadFile() {
        try {
            Map<String, GFERP__Item__c> itemMap = new Map<String, GFERP__Item__c>();
            for (GFERP__Item__c theItem : [
                    Select Id, Name, GFERP__Lot_Tracked__c, GFERP__Item_Type__c, GFERP__Description__c, GFERP__Standard_Base_Cost__c, GFERP__Average_Base_Cost__c, GFERP__Base_Unit_of_Measure__c, GFERP__Base_Unit_of_Measure__r.Name
                    FROM GFERP__Item__c
                    ORDER BY CreatedDate ASC
                    LIMIT 50000
            ]) {
                itemMap.put(theItem.Name.toUpperCase(), theItem);
            }
            
            Map<String, GFERP__Warehouse__c > warehouseMap = new Map<String, GFERP__Warehouse__c >();
            for (GFERP__Warehouse__c theWarehouse : [Select Name, GFERP__Ship_Bin__c, GFERP__Ship_Bin__r.Name FROM GFERP__Warehouse__c ORDER BY CreatedDate ASC LIMIT 50000]) {
                warehouseMap.put(theWarehouse.Name.toUpperCase(), theWarehouse);
            }

            //Now sepatate every row of the excel file
            filelines = nameFile.split('\n');

            //Iterate through every line and create a Import_EDI_Sales_Orders record for each row
            ImportInventoryList = new List<GFCON__Import_Inventory2__c>();
            for (Integer i = 1; i < filelines.size(); i++) {
                String[] inputvalues = new String[]{};

                string fileLine = filelines[i];
                fileLine = parseCSV(fileLine);
                for (String column : fileLine.split(',')) {
                    column = column.replaceAll(':quotes:', '').replaceAll(':comma:', ',');
                    inputvalues.add(column);
                }
                GFCON__Import_Inventory2__c importInv = new GFCON__Import_Inventory2__c();
                importInv.GFCON__Error_Text__c = '';
                importInv.GFCON__Warehouse__c = inputvalues[0];
                importInv.GFCON__Item__c = inputvalues[1];
                importInv.GFCON__Quantity__c = decimal.valueOf(inputvalues[2].trim());
                if (warehouseMap.containsKey(inputvalues[0].toUpperCase())) {
                    importInv.GFCON__Bin__c = warehouseMap.get(inputvalues[0].toUpperCase()).GFERP__Ship_Bin__r.Name;
                } else {
                    importInv.GFCON__Error_Text__c += 'Warehouse does not exist: '+inputvalues[0]+'.\n';
                }
                importInv.GFCON__Item_Lot__c = '1234';
                if(itemMap.containsKey(inputvalues[1].toUpperCase())){
                    GFERP__Item__c theItem = itemMap.get(inputvalues[1].toUpperCase());
                    if (theItem.GFERP__Average_Base_Cost__c != 0) {
                        importInv.GFCON__Unit_Cost__c = theItem.GFERP__Average_Base_Cost__c;
                    } else {
                        importInv.GFCON__Unit_Cost__c = theItem.GFERP__Standard_Base_Cost__c;
                    }
                    importInv.GFCON__Unit_of_Measure__c = theItem.GFERP__Base_Unit_of_Measure__r.Name;
                } else {
                    importInv.GFCON__Error_Text__c = 'Item does not exist: '+inputvalues[1]+ '.\n';
                }
               
                importInv.GFCON__Lot_Manufacture_Date__c = date.today();
                Date edate = Date.parse('12/31/2099');
                importInv.GFCON__Lot_Expiration_Date__c = edate;
                ImportInventoryList.add(importInv);
            }
        } catch (Exception e) {
            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR, 'An error has occured reading the CSV file: ' + e.getMessage());
            ApexPages.addMessage(errormsg);
            return null;
        }
        try {
            insert ImportInventoryList;
            string strMsg = 'File has been imported successfully and ';
            strMsg += ImportInventoryList.size() + ' lines have been created.';
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Info, strMsg));
        } catch (Exception e) {
            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR, 'An error has occured inserting the records' + e.getMessage());
            ApexPages.addMessage(errormsg);
        }
        return null;
    }

    public List<GFCON__Import_Inventory2__c> getImportInventoryList() {
        if (ImportInventoryList != NULL)
            if (ImportInventoryList.size() > 0){
                if(ImportInventoryList.size()>100){
                    List<GFCON__Import_Inventory2__c> limitedList = new List<GFCON__Import_Inventory2__c>();
                    for(Integer i = 0; i < 100; i++){
                        limitedList.add(ImportInventoryList[i]);
                    }
                    return limitedList;
                }else{
                    return ImportInventoryList;
                }
            } else{
                return null;
            }
        else{
            return null;
        }
    }
    /**
    This function convers the input CSV file in BLOB format into a string
    @param input    Blob data representing correct string in @inCharset encoding
    @param inCharset    encoding of the Blob data (for example 'ISO 8859-1')
    */
    public static String blobToString(Blob input, String inCharset) {
        String hex = EncodingUtil.convertToHex(input);
        System.assertEquals(0, hex.length() & 1);
        final Integer bytesCount = hex.length() >> 1;
        String[] bytes = new String[bytesCount];
        for (Integer i = 0; i < bytesCount; ++i)
            bytes[i] = hex.mid(i << 1, 2);
        return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), inCharset);
    }

    public pagereference returnToList() {
        return new ApexPages.Action('{!List}').invoke();
    }

    public string parseCSV(string pCSVLine) {
        Integer startIndex;
        Integer endIndex;

        while (pCSVLine.indexOf('"') > -1) {

            if (startIndex == null) {
                startIndex = pCSVLine.indexOf('"');
                pCSVLine = pCSVLine.substring(0, startIndex) + ':quotes:' + pCSVLine.substring(startIndex + 1, pCSVLine.length());
            } else {
                if (endIndex == null) {
                    endIndex = pCSVLine.indexOf('"');
                    pCSVLine = pCSVLine.substring(0, endIndex) + ':quotes:' + pCSVLine.substring(endIndex + 1, pCSVLine.length());
                }
            }

            if (startIndex != null && endIndex != null) {
                String sub = pCSVLine.substring(startIndex, endIndex);
                sub = sub.replaceAll(',', ':comma:');
                pCSVLine = pCSVLine.substring(0, startIndex) + sub + pCSVLine.substring(endIndex, pCSVLine.length());
                startIndex = null;
                endIndex = null;
            }
        }
        System.debug('pCSVLine:::' + pCSVLine);

        return pCSVLine;
    }
    
}