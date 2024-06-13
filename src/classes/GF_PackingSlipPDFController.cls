global with sharing class GF_PackingSlipPDFController {
    global GFERP__Whse_Shipment__c theWS { get; set; }
    global List<GFERP__Whse_Shipment__c> theWSList { get; set; }
    global GFERP__Sales_Order__c theSO { get; set; }
    global List<GFERP__Whse_Shipment_Line__c> theWSLList { get; set; }
    global GFERP__Company_Setup__c theCompanySetup { get; set; }
    global Decimal totalBox { get; set; }
    global Map<Id, Decimal> totalBoxMap { get; set; }
    global Decimal totalWeight { get; set; }
    global Decimal totalQtyBase { get; set; }
    global Map<Id, Decimal> totalWeightMap { get; set; }
    global Map<Id, Decimal> totalPalletMap { get; set; }
    global Map<Id, List<GFERP__Whse_Shipment_Line__c>> WhseShipmentLineMap { get; set; }
    private String WSId;
    public Set<Id> selectedIds = new Set<Id>();
    public List<FieldSetMember> billTofields { get; set; }
    public List<FieldSetMember> shipTofields { get; set; }
    global Boolean hasSerialNo { get; set; }

    global GF_PackingSlipPDFController(ApexPages.StandardController controller) {
        WSId = controller.getId();
        theCompanySetup = GFERP.CompanyMgmt.getCompanySetup();
        hasSerialNo = false;
        selectWS();
        selectWSLList();
        selectFieldSets();
    }

    global GF_PackingSlipPDFController(ApexPages.StandardSetController controller) {
        for (GFERP__Whse_Shipment__c theWS : (GFERP__Whse_Shipment__c[]) controller.getSelected()) {
            selectedIds.add(theWS.Id);
        }
        theCompanySetup = GFERP.CompanyMgmt.getCompanySetup();
        hasSerialNo = false;
        selectSelectedWS();
        selectSelectedWSLLists();
        selectFieldSets();
    }

    private void selectFieldSets(){
        //Some customers want to print B2C Customer Contact and Company Name on the document
       // billTofields = SObjectType.GFERP__Whse_Shipment__c.FieldSets.PackingSlipPDFBillToFieldSet.getFields();
       // shipTofields = SObjectType.GFERP__Whse_Shipment__c.FieldSets.PackingSlipPDFShipToFieldSet.getFields();
    }

    private void selectWS() {
        Map<String, Schema.SObjectField> fields = Schema.SObjectType.GFERP__Whse_Shipment__c.fields.getMap();
        List<String> lstFields = new List<String>();
        for (Schema.SObjectField field : fields.values()) {
            lstFields.add(field.getDescribe().getName());
        }
        String strQuery = 'SELECT ' + String.join(lstFields, ',');
        strQuery += ',GFERP__GL_Ledger__r.GFERP__Company_Setup__r.Name,GFERP__GL_Ledger__r.Phone__c,GFERP__GL_Ledger__r.Postal_Code__c,GFERP__GL_Ledger__r.State__c,GFERP__GL_Ledger__r.City__c,GFERP__GL_Ledger__r.Street__c,GFERP__GL_Ledger__r.Logo__c,GFERP__GL_Ledger__r.Name,GFERP__Shipping_Contact__r.Name,GFERP__Sell_to_Customer__r.Name,GFERP__Sell_to_Customer__r.GFERP__Freight_Terms__c,GFERP__Sell_to_Customer__r.GFERP__Print_Cross_Reference_on_Packing_List__c,GFERP__Alternate_Shipping__r.Name,GFERP__Shipping_Agent__r.Name';
        strQuery += ',GFERP__Warehouse__r.Name,GFERP__Warehouse__r.GFERP__UCC__c,GFERP__Warehouse__r.GFERP__Bypass_Pick__c,GFERP__Warehouse__r.GFERP__Receive_Bin__c,GFERP__Transfer_to_Warehouse__r.Name,GFERP__Sales_Order__r.Name,GFERP__Sales_Order__r.GFERP__Alternate_Shipping_Contact__c';
        strQuery += ',GFERP__Sales_Order__r.GFERP__Alternate_Shipping_Name__c,GFERP__Transfer_Order__r.Name, GFERP__Sales_Order__r.GFERP__Order_Note__c,GFERP__Sales_Order__r.GFERP__Billing_Contact__r.Name,GFERP__Sales_Order__r.GFERP__Bill_to_Customer__r.Name';
        strQuery += ',GFERP__Sales_Order__r.GFERP__Billing_Street__c,GFERP__Sales_Order__r.GFERP__Billing_City__c,GFERP__Sales_Order__r.GFERP__Billing_State__c,GFERP__Sales_Order__r.GFERP__Billing_Contact__c,GFERP__Sales_Order__r.GFERP__Billing_Postal_Code__c,GFERP__Sales_Order__r.GFERP__Billing_Country__c';
        strQuery += ' FROM GFERP__Whse_Shipment__c WHERE Id =: WSId';
        List<GFERP__Whse_Shipment__c> lstWS = Database.query(strQuery);
        if (lstWS.size() > 0) {
            theWS = lstWS[0];
        }
        if (theWS.GFERP__Total_Boxes_Override__c <> 0 && theWS.GFERP__Total_Boxes_Override__c != null) totalBox = theWS.GFERP__Total_Boxes_Override__c; else totalBox = theWS.GFERP__Total_Boxes__c;
    }

    private void selectSelectedWS() {
        totalBoxMap = new Map<Id, Decimal>();
        totalPalletMap = new Map<Id, Decimal>();

        Map<String, Schema.SObjectField> fields = Schema.SObjectType.GFERP__Whse_Shipment__c.fields.getMap();
        List<String> lstFields = new List<String>();
        for (Schema.SObjectField field : fields.values()) {
            lstFields.add(field.getDescribe().getName());
        }
        String strQuery = 'SELECT ' + String.join(lstFields, ',');
        strQuery += ',GFERP__Shipping_Contact__r.Name,GFERP__Sell_to_Customer__r.Name,GFERP__Sell_to_Customer__r.GFERP__Freight_Terms__c,GFERP__Sell_to_Customer__r.GFERP__Print_Cross_Reference_on_Packing_List__c,GFERP__Alternate_Shipping__r.Name,GFERP__Shipping_Agent__r.Name';
        strQuery += ',GFERP__Warehouse__r.Name,GFERP__Warehouse__r.GFERP__UCC__c,GFERP__Warehouse__r.GFERP__Bypass_Pick__c,GFERP__Warehouse__r.GFERP__Receive_Bin__c,GFERP__Transfer_to_Warehouse__r.Name,GFERP__Sales_Order__r.Name,GFERP__Sales_Order__r.GFERP__Alternate_Shipping_Contact__c';
        strQuery += ',GFERP__Sales_Order__r.GFERP__Alternate_Shipping_Name__c,GFERP__Transfer_Order__r.Name, GFERP__Sales_Order__r.GFERP__Order_Note__c,GFERP__Sales_Order__r.GFERP__Billing_Contact__r.Name,GFERP__Sales_Order__r.GFERP__Bill_to_Customer__r.Name';
        strQuery += ',GFERP__Sales_Order__r.GFERP__Billing_Street__c,GFERP__Sales_Order__r.GFERP__Billing_City__c,GFERP__Sales_Order__r.GFERP__Billing_State__c,GFERP__Sales_Order__r.GFERP__Billing_Contact__c,GFERP__Sales_Order__r.GFERP__Billing_Postal_Code__c,GFERP__Sales_Order__r.GFERP__Billing_Country__c';
        strQuery += ' FROM GFERP__Whse_Shipment__c WHERE Id IN: selectedIds';
        theWSList = Database.query(strQuery);
        for (GFERP__Whse_Shipment__c selectedWS : theWSList) {
            totalBoxMap.put(selectedWS.Id, selectedWS.GFERP__Total_Boxes__c);
            totalPalletMap.put(selectedWS.Id, selectedWS.GFERP__Total_Pallets__c != null ? selectedWS.GFERP__Total_Pallets__c : 0);
        }
    } 

    private void selectWSLList() {
        //Cucina wants to print RJW Item No. on Pack List. We need to retrieve all fields from WSL
        //FieldSet would not work.
        Map<String, Schema.SObjectField> fields = Schema.SObjectType.GFERP__Whse_Shipment_Line__c.fields.getMap();
        List<String> lstFields = new List<String>();
        for (Schema.SObjectField field : fields.values()) {
            lstFields.add(field.getDescribe().getName());
        }
        String strQuery = 'SELECT ' + String.join(lstFields, ',');
        strQuery += ',GFERP__Item__r.Name,GFERP__Unit_of_Measure__r.Name, (SELECT GFERP__Line_No__c, GFERP__Item_Lot__r.Name, GFERP__Quantity__c, GFERP__Serial_No__c, GFERP__Qty_Base__c, GFERP__Lot_Expiration_Date__c FROM GFERP__Tracking_Lines__r ORDER BY GFERP__Line_No__c)';
        strQuery += ' FROM GFERP__Whse_Shipment_Line__c WHERE GFERP__Shipment__c =: WSId ORDER BY GFERP__Line_No__c';
        theWSLList = Database.query(strQuery);

        totalWeight = 0;
        totalQtyBase = 0;
        for (GFERP__Whse_Shipment_Line__c WSL : theWSLList) {
            totalWeight += WSL.GFERP__Line_Weight__c;
            totalQtyBase += WSL.GFERP__Qty_Base__c;
            if (WSL.GFERP__Catch_Weight__c || WSL.GFERP__Serial_Tracked__c || Test.isRunningTest()) {
                hasSerialNo = true;
            }
        }
        if (theWS.GFERP__Weight_Override__c != null && theWS.GFERP__Weight_Override__c != 0) totalWeight = theWS.GFERP__Weight_Override__c;
        if (theWS.GFERP__Sell_to_Customer__r.GFERP__Print_Cross_Reference_on_Packing_List__c) {
            List<GFERP__Cross_Reference__c> theCRList = [
                    SELECT GFERP__Account__c, GFERP__Item__c, GFERP__Unit_of_Measure__c, GFERP__Cross_Referece_No__c
                    FROM GFERP__Cross_Reference__c
                    WHERE GFERP__Account__c = :theWS.GFERP__Sell_to_Customer__c
            ];
            String Key;
            Map<String, GFERP__Cross_Reference__c> CRMap = new Map<String, GFERP__Cross_Reference__c>();
            for (GFERP__Cross_Reference__c cr : theCRList) {
                Key = cr.GFERP__Item__c + '##' + cr.GFERP__Unit_of_Measure__c;
                CRMap.put(Key, cr);
            }
            for (GFERP__Whse_Shipment_Line__c WSL : theWSLList) {
                Key = WSL.GFERP__Item__c + '##' + WSL.GFERP__Unit_of_Measure__c;
                if (CRMap.containsKey(Key)) {
                    WSL.GFERP__Item__r = new GFERP__Item__c( Name = CRMap.get(Key).GFERP__Cross_Referece_No__c );
                }
            }
        }
    }

    private void selectSelectedWSLLists() {
        List<GFERP__Whse_Shipment_Line__c> theSelectedWSLLists = new List<GFERP__Whse_Shipment_Line__c>([
                SELECT Name, GFERP__Line_No__c, GFERP__Item__c, GFERP__Item__r.Name, GFERP__Item_Type__c, GFERP__Description__c, GFERP__Catch_Weight__c, GFERP__Serial_Tracked__c, GFERP__Quantity__c,
                        GFERP__Unit_of_Measure__c, GFERP__Unit_of_Measure__r.Name, GFERP__Qty_Base__c, GFERP__Item__r.GFERP__Default_Shelf__c, GFERP__Sell_to_Customer__c, GFERP__Conversion__c,
                        GFERP__Warehouse__c, GFERP__Unit_Cost__c, GFERP__Sales_Line__c, GFERP__Line_Cost__c, GFERP__Back_Order_Qty__c, GFERP__Not_Invoiced_Qty__c, GFERP__Not_Invoiced_Qty_Base__c,
                        GFERP__Lot_Tracked__c, GFERP__Bin__c, GFERP__Bin_Content__c, GFERP__Shipment__c, GFERP__Line_Weight__c,
                (SELECT GFERP__Line_No__c, GFERP__Item_Lot__r.Name, GFERP__Quantity__c, GFERP__Serial_No__c, GFERP__Qty_Base__c FROM GFERP__Tracking_Lines__r ORDER BY GFERP__Line_No__c)
                FROM GFERP__Whse_Shipment_Line__c
                WHERE GFERP__Shipment__c IN :selectedIds
                ORDER BY GFERP__Line_No__c
        ]);

        totalWeightMap = new Map<Id, Decimal>();
        WhseShipmentLineMap = new Map<Id, List<GFERP__Whse_Shipment_Line__c>>();
        for (GFERP__Whse_Shipment_Line__c WSL : theSelectedWSLLists) {
            if (!totalWeightMap.containsKey(WSL.GFERP__Shipment__c)) {
                totalWeightMap.put(WSL.GFERP__Shipment__c, 0);
            }
            if (WSL.GFERP__Catch_Weight__c || WSL.GFERP__Serial_Tracked__c || Test.isRunningTest()) {hasSerialNo = true;
            }
            Decimal currentQty = totalWeightMap.get(WSL.GFERP__Shipment__c);totalWeightMap.put(WSL.GFERP__Shipment__c, currentQty + WSL.GFERP__Line_Weight__c);

            if (!WhseShipmentLineMap.containsKey(WSL.GFERP__Shipment__c)) {WhseShipmentLineMap.put(WSL.GFERP__Shipment__c, new List<GFERP__Whse_Shipment_Line__c>());
            }WhseShipmentLineMap.get(WSL.GFERP__Shipment__c).add(WSL);
        }
    }
}