/**
 * Created by szhuo on 8/15/2023.
 */

public with sharing class GF_ImportSalesPricesUploader {

    private final ApexPages.StandardController theController;
    public string nameFile { get; set; }
    public Blob contentFile { get; set; }
    String[] filelines = new String[]{
    };
    String[] headerNotFoundList;
    public List<HeaderObj> columnList;
    public List<HeaderObj> headerColumnList;
    public string errMsg { get; set; }
    public Boolean redirectBack { get; set; }
    public static String responseMessage { get; set; }

    public GF_ImportSalesPricesUploader(ApexPages.StandardSetController controller) {
    }

    public GF_ImportSalesPricesUploader(ApexPages.StandardController controller) {
        theController = controller;
        errMsg = '';
    }

    public void SelectFileAndRead2() {
        nameFile = blobToString(contentFile, 'ISO-8859-1');
        ReadFile2();
    }

    public void ReadFile2() {
        List<Import_Sales_Prices__c> GLBEList = new List<Import_Sales_Prices__c>();

        try {
            filelines = nameFile.split('\n');
            identifyColumns2(filelines[0]);
            for (Integer i = 1; i < filelines.size(); i++) {
                String[] inputvalues = new String[]{
                };

                string fileLine = filelines[i];
                if (fileLine.length() == (headerColumnList.size() + columnList.size() + 1)) { // empty row
                    continue;
                }
                fileLine = parseCSV(fileLine);

                for (String column : fileLine.split(',')) {
                    column = column.replaceAll(':quotes:', '').replaceAll(':comma:', ',');
                    inputvalues.add(column);
                }

                Import_Sales_Prices__c newGLBE = new Import_Sales_Prices__c();
                for (HeaderObj header : columnList) {
                    system.debug('header.fieldAPIName == ' + header.fieldAPIName);

                    if (header.fieldAPIName.contains('Item') || header.fieldAPIName.contains('Unit_of_Measure') || header.fieldAPIName.contains('Account') || header.fieldAPIName.contains('Minimum_Quantity')) {
                        if (String.isNotBlank(inputvalues[header.columnIndex])) {
                            system.debug('inputvalues[header.columnIndex] === ' + inputvalues[header.columnIndex]);
                            newGLBE.put(header.fieldAPIName, String.valueOf(inputvalues[header.columnIndex]));
                        }
                    }

                    if (header.fieldAPIName.contains('Starting_Date') || header.fieldAPIName.contains('Ending_Date__c')) {
                        if (String.isNotBlank(inputvalues[header.columnIndex])) {
                            system.debug('inputvalues[header.columnIndex] === ' + inputvalues[header.columnIndex]);
                            newGLBE.put(header.fieldAPIName, Date.parse(inputvalues[header.columnIndex]));
                        }
                    }

                    if (header.fieldAPIName.contains('Sales_Price')) {
                        if (String.isNotBlank(inputvalues[header.columnIndex])) {
                            system.debug('inputvalues[header.columnIndex] === ' + inputvalues[header.columnIndex]);
                            newGLBE.put(header.fieldAPIName, Decimal.valueOf(inputvalues[header.columnIndex]));
                        }
                    }
                }
                GLBEList.add(newGLBE);
            }
            if (GLBEList.Size() > 0)
                insert GLBEList;

        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'An error has occured reading the CSV file: ' + e.getMessage() + ': ' + e.getLineNumber()));
            return;
        }
        try {
            string strMsg = 'File has been imported successfully. ' + GLBEList.size() + ' Import Sales Price(s) have been created.';
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
        headerNotFoundList = new String[]{
        };
        String[] columnHeaders = headerLine.split(',');
        Integer headerCount = columnHeaders.size();
        for (Integer i = 0; i < headerCount; i++) {
            size1 = columnList.size() + headerColumnList.size();
            string theHeader = columnHeaders[i].toLowerCase().trim().replace('ï»¿', '');
            switch on theHeader {
                when 'item' {
                    columnList.add(new HeaderObj('Item__c', i));
                }

                when 'starting date' {
                    columnList.add(new HeaderObj('Starting_Date__c', i));
                }

                when 'sales price' {
                    columnList.add(new HeaderObj('Sales_Price__c', i));
                }

                when 'uom' {columnList.add(new HeaderObj('Unit_of_Measure__c', i));}

                when 'min qty','minimum quantity' {columnList.add(new HeaderObj('Minimum_Quantity__c', i));}

                when 'account' {columnList.add(new HeaderObj('Account__c', i));}

                when 'ending date' {columnList.add(new HeaderObj('Ending_Date__c', i));}

                when 'sales pricing group', 'group' {columnList.add(new HeaderObj('Sales_Pricing_Group__c', i));}
            }
            // if no header found
            size2 = columnList.size() + headerColumnList.size();
            if (size1 == size2) {
                headerNotFoundList.add(columnHeaders[i]);
            }
        }
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

    public class HeaderObj {
        public string fieldAPIName;
        public Integer columnIndex;
        public HeaderObj(string apiName, Integer index) {
            this.fieldAPIName = apiName;
            this.columnIndex = index;
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

    public PageReference returnBack() {
        return theController.view();
    }
}