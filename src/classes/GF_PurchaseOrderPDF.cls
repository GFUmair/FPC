global with Sharing class GF_PurchaseOrderPDF {
    global GFERP__Purchase_Order__c thePO { get; set; }
    global List<GFERP__Purchase_Line__c> thePLList { get; set; }
    global GFERP__Company_Setup__c theCompanySetup { get; set; }
    private String POId;
    global Decimal totalDiscount { get; set; }
    global Decimal subtotal { get; set; }
    global Decimal totalTax { get; set; }
    global Decimal totalAmount { get; set; }
    global String shippingName { get; set; }
    global String docTitle { get; set; }
    global List<WrapPL> theWrapPLList { get; set; }
    global Boolean allowToSeeCost { get; set; }
    global List<GFERP__Work_Order__c> theWOList { get; set; }

    global GF_PurchaseOrderPDF(ApexPages.StandardController controller) {
        POId = controller.getId();
        theCompanySetup = GFERP.CompanyMgmt.getCompanySetup();

        selectPO();
        selectPLList();

        allowToSeeCost = Schema.sObjectType.GFERP__Purchase_Line__c.fields.GFERP__Unit_Cost__c.isAccessible();
    }

    private void selectPO() {
        Map<String, Schema.SObjectField> fields = Schema.SObjectType.GFERP__Purchase_Order__c.fields.getMap();
        List<String> lstFields = new List<String>();
        for (Schema.SObjectField field : fields.values()) {
            lstFields.add(field.getDescribe().getName());
        }
        String strQuery = 'SELECT ' + String.join(lstFields, ',');
        strQuery += ',GFERP__GL_Ledger__r.GFERP__Company_Setup__r.Name,GFERP__GL_Ledger__r.Phone__c,GFERP__GL_Ledger__r.Postal_Code__c,GFERP__GL_Ledger__r.State__c,GFERP__GL_Ledger__r.City__c,GFERP__GL_Ledger__r.Street__c,GFERP__GL_Ledger__r.Logo__c,GFERP__GL_Ledger__r.Name,GFERP__Billing_Contact__r.Name,GFERP__Pay_to_Vendor__r.Name,GFERP__Shipping_Contact2__r.Name, GFERP__Sell_to_Customer__r.Name,GFERP__Alternate_Shipping2__r.Name,GFERP__Currency2__r.Name,GFERP__Warehouse__r.Name,' +
                'GFERP__Purchasing_Agent__r.Name,GFERP__Shipping_Agent__r.Name,GFERP__Payment_Term__r.Name,GFERP__Payment_Term__r.GFERP__Description__c,GFERP__Buy_from_Vendor2__r.Name,GFERP__Buy_from_Vendor2__r.GFERP__Print_Cross_Reference_on_PO__c, GFERP__Buy_from_Vendor2__r.GFERP__Freight_Terms__c' ;
        strQuery += ' FROM GFERP__Purchase_Order__c WHERE Id =: POId';
        thePO = Database.query(strQuery);
        totalDiscount = GFERP.CompanyMgmt.halfUpTo2D(thePO.GFERP__Order_Discount__c);
        totalAmount = GFERP.CompanyMgmt.halfUpTo2D(thePO.GFERP__Order_Cost__c);
        totalTax = GFERP.CompanyMgmt.halfUpTo2D(thePO.GFERP__Order_Cost__c);
        //get shipping name
        if (thePO.GFERP__Alternate_Shipping2__c != null) {
            shippingName = thePO.GFERP__Alternate_Shipping2__r.Name;
        } else if (thePO.GFERP__Sell_to_Customer__c != null) {
            shippingName = thePO.GFERP__Sell_to_Customer__r.Name;
        } else {
            shippingName = theCompanySetup.Name;
        }
    }

    private void selectPLList() {
        Map<String, Schema.SObjectField> fields = Schema.SObjectType.GFERP__Purchase_Line__c.fields.getMap();
        List<String> lstFields = new List<String>();
        for (Schema.SObjectField field : fields.values()) {
            lstFields.add(field.getDescribe().getName());
        }
        String strQuery = 'SELECT ' + String.join(lstFields, ',');
        strQuery += ',GFERP__Item__r.Name,GFERP__Unit_of_Measure__r.Name,GFERP__Item__r.GFERP__UPC__c,GFERP__Item__r.GFERP__Brand__c,GFERP__Item__r.GFERP__Lead_Time_Days__c,GFERP__Work_Order__r.Name,GFERP__Work_Order__r.GFERP__Output_Item__r.Name, GFERP__Item__r.GFERP__Description__c';
        strQuery += ',GFERP__Work_Order__r.GFERP__Output_Item__r.GFERP__Description__c,GFERP__Work_Order__r.GFERP__Output_Item__r.GFERP__UPC__c, GFERP__Work_Order__r.GFERP__Output_Item__r.GFERP__Brand__c, GFERP__Work_Order__r.GFERP__Unit_of_Measure__r.Name';
        strQuery += ',GFERP__Work_Order__r.GFERP__Quantity__c,GFERP__Item__r.GFERP__Item_Image__c,GFERP__Item__r.GFERP__Long_Description__c';
        strQuery += ' FROM GFERP__Purchase_Line__c WHERE GFERP__Purchase_Order__c =: POId ORDER BY GFERP__Line_No__c ';
        thePLList = Database.query(strQuery);

        //Select Cross Reference
        List<GFERP__Cross_Reference__c> theCRList = [
                SELECT GFERP__Account__c, GFERP__Item__c, GFERP__Unit_of_Measure__c, GFERP__Cross_Referece_No__c, GFERP__Customer_Item_Description__c
                FROM GFERP__Cross_Reference__c
                WHERE GFERP__Account__c = :thePO.GFERP__Buy_from_Vendor2__c
        ];

        String Key;
        Map<String, GFERP__Cross_Reference__c> CRMap = new Map<String, GFERP__Cross_Reference__c>();
        for (GFERP__Cross_Reference__c cr : theCRList) {
            CRMap.put(cr.GFERP__Item__c + '##' + cr.GFERP__Unit_of_Measure__c, cr);
        }

        Set<Id> WOIds = new Set<Id>();
        theWrapPLList = new List<WrapPL>();
        for (GFERP__Purchase_Line__c PL : thePLList) {
            WrapPL theWrapPL = new WrapPL();
            theWrapPL.item = PL.GFERP__Item__r.Name;
            theWrapPL.description = PL.GFERP__Description__c;
            PL.GFERP__Item__r.GFERP__Description__c = null;
            if (thePO.GFERP__Buy_from_Vendor2__r.GFERP__Print_Cross_Reference_on_PO__c == true) {
                Key = PL.GFERP__Item__c + '##' +PL.GFERP__Unit_of_Measure__c;
                if (CRMap.containsKey(Key)) {
                    theWrapPL.item = CRMap.get(Key).GFERP__Cross_Referece_No__c;
                    PL.GFERP__Item__r.GFERP__Description__c = CRMap.get(Key).GFERP__Cross_Referece_No__c; // use item's description field for storing the vendor no
                    if (CRMap.get(Key).GFERP__Customer_Item_Description__c != null){
                        theWrapPL.description = CRMap.get(Key).GFERP__Customer_Item_Description__c;
                    }
                }
            }
            PL.GFERP__Unit_Cost__c = GFERP.CompanyMgmt.halfUpTo5D(PL.GFERP__Unit_Cost__c);
            PL.GFERP__Discount__c = GFERP.CompanyMgmt.halfUpTo2D(PL.GFERP__Discount__c);
            PL.GFERP__Line_Cost__c = GFERP.CompanyMgmt.halfUpTo2D(PL.GFERP__Line_Cost__c);
            theWrapPL.brand = PL.GFERP__Item__r.GFERP__Brand__c;
            theWrapPL.upc = PL.GFERP__Item__r.GFERP__UPC__c;
            theWrapPL.qty = PL.GFERP__Quantity__c;
            theWrapPL.uom = PL.GFERP__Unit_of_Measure__r.Name;
            theWrapPL.unitCost = PL.GFERP__Unit_Cost__c;
            theWrapPL.discount = PL.GFERP__Discount_Pct__c;
            theWrapPL.lineCost = PL.GFERP__Line_Cost__c;
            if (PL.GFERP__Work_Order__c != null) {
                WOIds.add(PL.GFERP__Work_Order__c);
                theWrapPL.outputItem = PL.GFERP__Work_Order__r.GFERP__Output_Item__r.Name;
                theWrapPL.outputItemBrand = PL.GFERP__Work_Order__r.GFERP__Output_Item__r.GFERP__Brand__c;
                theWrapPL.outputItemDescrip = PL.GFERP__Work_Order__r.GFERP__Output_Item__r.GFERP__Description__c;
                theWrapPL.outputItemUPC = PL.GFERP__Work_Order__r.GFERP__Output_Item__r.GFERP__UPC__c;
                theWrapPL.outputUOM = PL.GFERP__Work_Order__r.GFERP__Unit_of_Measure__r.Name;
                theWrapPL.workOrder = PL.GFERP__Work_Order__r.Name;
            }
            theWrapPLList.add(theWrapPL);
        }

        if (WOIds.size() > 0) {
            theWOList = [
                    Select Name, GFERP__Output_Item__r.Name, GFERP__Output_Item__r.GFERP__Lead_Time_Days__c, GFERP__Description__c, GFERP__Starting_Date_Time__c, GFERP__Ending_Date_Time__c,
                            GFERP__Quantity__c, GFERP__Unit_of_Measure__r.Name, (Select Name, GFERP__Item__c, GFERP__Item__r.Name, GFERP__Description__c,
                            GFERP__Quantity_Per__c, GFERP__Remaining_Qty__c, GFERP__Unit_of_Measure__r.Name, GFERP__Scrap_Pct__c From GFERP__Work_Lines__r Where GFERP__Line_Type__c = 'Formula' ORDER BY GFERP__Line_No__c)
                    From GFERP__Work_Order__c Where Id IN: WOIds
            ];
        }
    }

    public Integer decimalPlaces {
        get {
           // return GFERP.CompanyMgmt.currencyDecimals;
           return 2;
        }
    }

    global class WrapPL {
        global String item { get; set; }
        global String brand { get; set; }
        global String description { get; set; }
        global String upc { get; set; }
        global Decimal qty { get; set; }
        global String uom { get; set; }
        global Decimal unitCost { get; set; }
        global Decimal discount { get; set; }
        global Decimal lineCost { get; set; }
        global String workOrder { get; set; }
        global String outputItem { get; set; }
        global String outputItemBrand { get; set; }
        global String outputItemDescrip { get; set; }
        global String outputItemUPC { get; set; }
        global String outputUOM { get; set; }
    }
}