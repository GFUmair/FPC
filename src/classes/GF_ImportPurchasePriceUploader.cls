/**
 * Created by mumair on 5/6/2024.
 */

public with sharing class GF_ImportPurchasePriceUploader {
    public string nameFile { get; set; }
    public Blob contentFile { get; set; }
    String[] filelines = new String[]{};
    String[] headerNotFoundList;
    public List<HeaderObj> columnList;
    public List<HeaderObj> headerColumnList;
    public Integer orderNoIndex;
    //GFERP__Company_Setup__c theCompanySetup = [SELECT GFERP__Warehouse__r.Name, GFERP__Payment_Term__r.Name, GFERP__Currency__r.Name FROM GFERP__Company_Setup__c LIMIT 1];

    public GF_ImportPurchasePriceUploader(ApexPages.StandardSetController controller) {}

    public void SelectFileAndRead2(){
        try{
            nameFile = blobToString(contentFile, 'ISO-8859-1');
        	ReadFile2();
        }catch (Exception e) {
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'An error has occured reading the CSV file: ' + e.getMessage() + ': ' + e.getLineNumber()));
            system.debug('Error: ' + e.getMessage() + ': ' + e.getLineNumber());
            return;
        }
    }

    public void ReadFile2() {
        String mapKey;
        Map<String, Import_Purchase_Price__c> priceMap = new Map<String, Import_Purchase_Price__c>();
        try {
            //Now sepatate every row of the excel file
            filelines = nameFile.split('\n');
            identifyColumns2(filelines[0]);
            for (Integer i = 1; i < filelines.size(); i++) {
                String[] inputvalues = new String[]{};

                string fileLine = filelines[i];
                if (fileLine.length() == (headerColumnList.size() + columnList.size() + 1)) { // empty row
                    continue;
                }
                fileLine = parseCSV(fileLine);

                for (String column : fileLine.split(',')) {
                    column = column.replaceAll(':quotes:', '').replaceAll(':comma:', ',');
                    inputvalues.add(column);
                }
                mapKey = inputvalues[0] + '#' + inputvalues[1] + '#' + inputvalues[2] + '#' + inputvalues[3] + '#' + inputvalues[4] + '#' + inputvalues[5] + '#' + inputvalues[6];
                if (!priceMap.containsKey(mapKey)) {

                    Import_Purchase_Price__c newPP = new Import_Purchase_Price__c();
                    for (HeaderObj header : headerColumnList) {
                        if (header.fieldAPIName.contains('End_Date') || header.fieldAPIName.contains('Starting_Date')) {
                            if (String.isNotBlank(inputvalues[header.columnIndex])) {
                                newPP.put(header.fieldAPIName, Date.parse(inputvalues[header.columnIndex]));
                            }
                        } else if (header.fieldAPIName.contains('Purchase_Price') || header.fieldAPIName.contains('Minimum_Quantity')) {
                            if (String.isNotBlank(inputvalues[header.columnIndex])) {
                                newPP.put(header.fieldAPIName, Decimal.valueOf(inputvalues[header.columnIndex]));
                            }
                        } else {
                            newPP.put(header.fieldAPIName,inputvalues[header.columnIndex]);
                        }
                    }

                    priceMap.put(mapKey, newPP);
                }


            }

            insert priceMap.values();


        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'An error has occured reading the CSV file: ' + e.getMessage() + ': ' + e.getLineNumber()));
            system.debug('Error: ' + e.getMessage() + ': ' + e.getLineNumber());
            return;
        }
        try {
            string strMsg = 'File has been imported successfully. ' + priceMap.size() + ' Import Purchase Price(s).';
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, strMsg));
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'An error has occured inserting the records: ' + e.getMessage()));
        }
    }

    public void identifyColumns2(string headerLine) {
        columnList = new List<HeaderObj>();
        headerColumnList = new List<HeaderObj>();
        Integer size1 = 0;
        Integer size2 = 0;
        headerNotFoundList = new String[]{};
        String[] columnHeaders = headerLine.split(',');
        Integer headerCount = columnHeaders.size();
        for (Integer i = 0; i < headerCount; i++) {
            size1 = columnList.size() + headerColumnList.size();
            string theHeader = columnHeaders[i].toLowerCase().trim().replace('ï»¿','');
            switch on theHeader {
                when 'account','account__c'{
                    headerColumnList.add(new HeaderObj('Account__c', i));
                    orderNoIndex = i;
                }
                when 'end date','end_date__c' {
                    headerColumnList.add(new HeaderObj('End_Date__c', i));
                    orderNoIndex = i;
                }
                when 'item','item__c' {
                    headerColumnList.add(new HeaderObj('Item__c', i));
                }
                when 'uom', 'unit of measure', 'unit_of_measure__c', 'item_unit_of_measure__c' {
                    headerColumnList.add(new HeaderObj('Unit_of_Measure__c', i));
                }
                when 'minimum quantity', 'Minimum_Quantity__c', 'min quantity' {
                    headerColumnList.add(new HeaderObj('Minimum_Quantity__c', i));
                }
                when 'purchase price', 'purchase_price__c' {
                    headerColumnList.add(new HeaderObj('Purchase_Price__c', i));
                }
                when 'starting_date__c', 'starting date' {
                    headerColumnList.add(new HeaderObj('Starting_Date__c', i));
                }
                when 'currency', 'currency code', 'currency_code__c' {
                    headerColumnList.add(new HeaderObj('Currency_Code__c', i));
                }
            }
            // if no header found
            size2 = columnList.size() + headerColumnList.size();
            if (size1 == size2) {
                headerNotFoundList.add(columnHeaders[i]);
            }
        }
    }


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
        return pCSVLine;
    }

    public class HeaderObj{
        public string fieldAPIName;
        public Integer columnIndex;
        public HeaderObj (string apiName, Integer index) {
            this.fieldAPIName = apiName;
            this.columnIndex = index;
        }
    }
}