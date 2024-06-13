global with sharing class GF_SalesOrderPDF {

    global GFERP__Sales_Order__c theSO { get; set; }
    global List<GFERP__Sales_Line__c> theSLList {get; set;}
    global GFERP__Company_Setup__c theCompanySetup {get; set;}
    public String orderId;
    global Decimal totalDiscount {get; set;}
    global Decimal totalQty {get; set;}
    global Decimal totalWeight {get; set;}
    global Decimal subtotal {get; set;}
    global Decimal totalTax {get; set;}
    global Decimal totalAmount {get; set;}
    global String docTitle {get; set;}
    Set<Id> selectedSOIds;
    public List<WrapSO> theWrapSOList { get; set; }
    private WrapSO theWrapSO;
    public List<GFERP__Sales_Order__c> selectedSOList;
    public List<GFERP__Sales_Line__c> selectedSLList;
    public List<FieldSetMember> billTofields { get; set; }
    public List<FieldSetMember> shipTofields { get; set; }

    global GF_SalesOrderPDF(ApexPages.StandardSetController controller) {
        selectedSOIds = new Set<Id>();

        String orderId = ApexPages.currentPage().getParameters().get('id');
        selectedSOList = new List<GFERP__Sales_Order__c>();
        if (String.isEmpty(orderId)) {
            for (GFERP__Sales_Order__c theSO : (GFERP__Sales_Order__c[]) controller.getSelected()) {
                selectedSOIds.add(theSO.Id);
            }
        } else {
            selectedSOIds.add(orderId);
        }

        theCompanySetup = GFERP.CompanyMgmt.getCompanySetup();

        fieldsetsInit();
        selectSelectedSO();
        selectSelectedSLList();
    }

    global GF_SalesOrderPDF(ApexPages.StandardController controller) {

        orderId = controller.getId();
        theCompanySetup = GFERP.CompanyMgmt.getCompanySetup();
        
        fieldsetsInit();
        selectSO();
        selectSLList();

        selectedSOIds = new Set<Id>();
        selectedSOIds.add(orderId);
        selectSelectedSO();
        selectSelectedSLList();
    }


    public void fieldsetsInit() {
        //Some customers want to print B2C Customer Contact and Company Name on the document
       // billTofields = SObjectType.GFERP__Sales_Order__c.fieldSets.PDFHeaderBillToFieldSet.getFields();
       // shipTofields = SObjectType.GFERP__Sales_Order__c.fieldSets.PDFHeaderShipToFieldSet.getFields();
    }

    global PageReference init() {
        if (theSO.GFERP__Return_Order__c == true) {
            PageReference RMAPage = new PageReference('/apex/RMA?Id=' + theSO.Id);
            RMAPage.setRedirect(true);
            return RMAPage;
        } else {
            return null;
        }
    }

    private void selectSelectedSO() {
        Map<String, Schema.SObjectField> fields = Schema.SObjectType.GFERP__Sales_Order__c.fields.getMap();
        List<String> lstFields = new List<String>();
        for (Schema.SObjectField field : fields.values()) {
            lstFields.add(field.getDescribe().getName());
        }

        String strQuery = 'SELECT ' + String.join(lstFields, ',');
        strQuery += ',GFERP__Sell_to_Customer__r.Name,GFERP__Shipping_Contact__r.FirstName,GFERP__Shipping_Contact__r.LastName,GFERP__Shipping_Contact__r.Name,' +
                    'GFERP__Warehouse__r.Name,GFERP__Warehouse__r.GFERP__Is_3PL__c,GFERP__Sales_Rep__r.Name,GFERP__Shipping_Agent__r.Name,GFERP__Currency__r.Name,GFERP__Bill_to_Customer__r.Name,' +
                    'GFERP__Billing_Contact__r.FirstName,GFERP__Billing_Contact__r.LastName,GFERP__Billing_Contact__r.Name,GFERP__Alternate_Shipping__r.Name,GFERP__Payment_Term__r.Name,GFERP__Payment_Term__r.GFERP__Description__c,GFERP__Tax_Area__r.Name';
        strQuery += ' FROM GFERP__Sales_Order__c WHERE Id IN : selectedSOIds';
        selectedSOList = Database.query(strQuery);
    }

    private void selectSelectedSLList() {

        Map<String, Schema.SObjectField> fields = Schema.SObjectType.GFERP__Sales_Line__c.fields.getMap();
        List<String> lstFields = new List<String>();
        for (Schema.SObjectField field : fields.values()) {
            lstFields.add(field.getDescribe().getName());
        }
        String strQuery = 'SELECT ' + String.join(lstFields, ',');
        strQuery += ',GFERP__Item__r.Name,GFERP__Item__r.GFERP__Long_Description__c,GFERP__Unit_of_Measure__r.Name, GFERP__Unit_of_Measure__r.GFERP__Weight__c,GFERP__Unit_of_Measure__r.GFERP__GTIN__c,GFERP__Cross_Reference__r.GFERP__Cross_Referece_No__c';
        strQuery += ' FROM GFERP__Sales_Line__c WHERE GFERP__Sales_Order__c IN : selectedSOIds ORDER BY GFERP__Line_No__c';
        selectedSLList = Database.query(strQuery);

        for (GFERP__Sales_Line__c objSL : selectedSLList) {
            objSL.GFERP__Unit_Price__c = GFERP.CompanyMgmt.halfUpTo2D(objSL.GFERP__Unit_Price__c);
            objSL.GFERP__Discount__c = GFERP.CompanyMgmt.halfUpTo2D(objSL.GFERP__Discount__c);
            objSL.GFERP__Line_Amount__c = GFERP.CompanyMgmt.halfUpTo2D(objSL.GFERP__Line_Amount__c);
        }
    }

    private void selectSO() {
        Map<String, Schema.SObjectField> fields = Schema.SObjectType.GFERP__Sales_Order__c.fields.getMap();
        List<String> lstFields = new List<String>();
        for (Schema.SObjectField field : fields.values()) {
            lstFields.add(field.getDescribe().getName());
        }
        String strQuery = 'SELECT ' + String.join(lstFields, ',');
        strQuery += ',GFERP__GL_Ledger__r.Company_Name__c,GFERP__GL_Ledger__r.GFERP__Company_Setup__r.Name,GFERP__GL_Ledger__r.Phone__c,GFERP__GL_Ledger__r.Logo__c,GFERP__GL_Ledger__r.Postal_Code__c,GFERP__GL_Ledger__r.State__c,GFERP__GL_Ledger__r.City__c,GFERP__GL_Ledger__r.Street__c,GFERP__GL_Ledger__r.Name,GFERP__Sell_to_Customer__r.Name,GFERP__Shipping_Contact__r.FirstName,GFERP__Shipping_Contact__r.LastName,GFERP__Shipping_Contact__r.Name,' +
                    'GFERP__Warehouse__r.Name,GFERP__Warehouse__r.GFERP__Is_3PL__c,GFERP__Sales_Rep__r.Name,GFERP__Shipping_Agent__r.Name,GFERP__Currency__r.Name,GFERP__Bill_to_Customer__r.Name,' +
                    'GFERP__Billing_Contact__r.FirstName,GFERP__Billing_Contact__r.LastName,GFERP__Billing_Contact__r.Name,GFERP__Alternate_Shipping__r.Name,GFERP__Payment_Term__r.Name,GFERP__Payment_Term__r.GFERP__Description__c,GFERP__Tax_Area__r.Name';
        strQuery += ' FROM GFERP__Sales_Order__c WHERE Id =: orderId';
        theSO = Database.query(strQuery); 

        totalDiscount = theSO.GFERP__Order_Discount__c.setScale(2, RoundingMode.HALF_UP);
        subtotal = theSO.GFERP__Order_Amount__c.setScale(2, RoundingMode.HALF_UP);
        totalTax = theSO.GFERP__Order_Tax__c.setScale(2, RoundingMode.HALF_UP);
        totalAmount = theSO.GFERP__Order_Amt_Incl_Tax2__c.setScale(2, RoundingMode.HALF_UP);
        totalQty= theSO.GFERP__Order_Quantity__c.setScale(2, RoundingMode.HALF_UP);
        docTitle = theSO.GFERP__Return_Order__c ? 'Return Authorization' : 'SALES ORDER';
    }

    private void selectSLList() {
        Map<String, Schema.SObjectField> fields = Schema.SObjectType.GFERP__Sales_Line__c.fields.getMap();
        List<String> lstFields = new List<String>();
        for (Schema.SObjectField field : fields.values()) {
            lstFields.add(field.getDescribe().getName());
        }
        String strQuery = 'SELECT ' + String.join(lstFields, ',');
        strQuery += ',GFERP__Item__r.Name,GFERP__Item__r.GFERP__Long_Description__c,GFERP__Unit_of_Measure__r.Name, GFERP__Unit_of_Measure__r.GFERP__Weight__c,GFERP__Unit_of_Measure__r.GFERP__GTIN__c,GFERP__Cross_Reference__r.GFERP__Cross_Referece_No__c';
        strQuery += ' FROM GFERP__Sales_Line__c WHERE GFERP__Sales_Order__c =: orderId ORDER BY GFERP__Line_No__c';
        theSLList = Database.query(strQuery);

        totalWeight = 0;
        for (GFERP__Sales_Line__c SL : theSLList) {
            SL.GFERP__Unit_Price__c = GFERP.CompanyMgmt.halfUpTo2D(SL.GFERP__Unit_Price__c);
            SL.GFERP__Discount__c = GFERP.CompanyMgmt.halfUpTo2D(SL.GFERP__Discount__c);
            SL.GFERP__Line_Amount__c = GFERP.CompanyMgmt.halfUpTo2D(SL.GFERP__Line_Amount__c);
            if (SL.GFERP__Item_Type__c == 'Inventory'){
                // It is confusing on the print out to show only inventory qty
                //totalQty += companyMgmt.halfUpTo2D(SL.Quantity__c);
                totalWeight += GFERP.CompanyMgmt.halfUpTo2D(SL.GFERP__Quantity__c) * GFERP.CompanyMgmt.halfUpTo2D(SL.GFERP__Unit_of_Measure__r.GFERP__Weight__c);
            }
        }
    }

    global class WrapSO {
        global GFERP__Sales_Order__c theSO { get; set; }
        global List<GFERP__Sales_Line__c> theSLList { get; set; }
        public Decimal totalDiscount1 { get; set; }
        public Decimal subtotal1 { get; set; }
        public Decimal totalTax1 { get; set; }
        public Decimal totalAmount1 { get; set; }
        public Decimal totalQty1 { get; set; }
        public String docTitle1 { get; set; }
        public WrapSO(GFERP__Sales_Order__c SO, Decimal totalDiscount1, Decimal subtotal1, Decimal totalTax1,
                Decimal totalAmount1, Decimal totalQty1, String docTitle1, List<GFERP__Sales_Line__c> theSLList) {
            this.theSO = SO;
            this.totalDiscount1 = totalDiscount1;
            this.subtotal1 = subtotal1;
            this.totalTax1 = totalTax1;
            this.totalAmount1 = totalAmount1;
            this.totalQty1 = totalQty1;
            this.docTitle1 = docTitle1;
            this.theSLList = theSLList;
        }
    }

    global List<WrapSO> getSOSLList() {
        List<GFERP__Sales_Line__c> theSLList;

        theWrapSOList = new List<WrapSO>();
        for (GFERP__Sales_Order__c SO : selectedSOList) {
            totalDiscount = SO.GFERP__Order_Discount__c.setScale(2, RoundingMode.HALF_UP);
            subtotal = SO.GFERP__Order_Amount__c.setScale(2, RoundingMode.HALF_UP);
            totalTax = SO.GFERP__Order_Tax__c.setScale(2, RoundingMode.HALF_UP);
            totalAmount = SO.GFERP__Order_Amt_Incl_Tax2__c.setScale(2, RoundingMode.HALF_UP);
            totalQty = SO.GFERP__Order_Quantity__c.setScale(2, RoundingMode.HALF_UP);
            docTitle = SO.GFERP__Return_Order__c ? 'Return Authorization' : 'SALES ORDER';

            theSLList = new List<GFERP__Sales_Line__c>();
            for (GFERP__Sales_Line__c SL : selectedSLList) {
                if (SL.GFERP__Sales_Order__c == SO.Id) {
                    theSLList.add(SL);
                }
            }
            theWrapSO = new WrapSO(SO, totalDiscount, subtotal, totalTax, totalAmount, totalQty, docTitle, theSLList);
            theWrapSOList.add(theWrapSO);
        }
        return theWrapSOList;
    }
}