public with sharing class MonthEndReconciliationExportExcel_Custom {
    private ApexPages.StandardSetController standardSetController = null;
    public String CompanyName { get; set; }
    public List<GLAccountLine> GLALines { get; set; }
    public GFCON__Import_Sales_Order__c theISO { get; set; } // take Requested_Delivery_Date__c as end date input
    public String theStartDate { get; set; }
    public String theEndDate { get; set; }
    public String theSelectedDate { get; set; }
    public Decimal totalOpenBalance { get; set; }
    public Decimal totalChanges { get; set; }
    public Decimal totalunadjustedBalance { get; set; }
    public Decimal totalAdjustmentLocal { get; set; }
    public Decimal totalAdjustmentVendor { get; set; }
    public Decimal totalAdjustmentCustomer { get; set; }
    public Decimal totalAdjustedBalance { get; set; }
    public Decimal totalGFChanges { get; set; }
    public Decimal totalChangesPostedInQB { get; set; }
    public Decimal totalEndOfMonthAdjEntries { get; set; }
    public Id accountAR;
    public Id accountAP;
    public Id accountAAP;
    public Id accountGoods;
    public Id accountSales;
    public Id accountCOGS;
    public Id accountIA;
    public Boolean noError { get; set; }

    public MonthEndReconciliationExportExcel_Custom(ApexPages.StandardSetController controller) {
        standardSetController = controller;
        String pageName = getVFPageName();
        if (pageName == 'MonthEndReconciliationExportExcel' || Test.isRunningTest()) {
            String endDateString = ApexPages.CurrentPage().getParameters().get('endDate');
            if (String.isNotBlank(endDateString)) {
                theSelectedDate = endDateString;
                Date selectedDate = Date.parse(endDateString);
                Date startDate = selectedDate.toStartOfMonth();
                Date endDate = selectedDate.addMonths(1).toStartOfMonth().addDays(-1);
                theStartDate = startDate.month() + '/' + startDate.day() + '/' + startDate.year();
                theEndDate = endDate.month() + '/' + endDate.day() + '/' + endDate.year();
                selectGLAccounts();
                generateReport();
            }
        } else if (pageName == 'MonthEndReconciliationConfirmation') {
            Date theLastDayOfTheLastMonth = Date.today().toStartOfMonth().addDays(-1);
            theISO = new GFCON__Import_Sales_Order__c( GFCON__Requested_Delivery_Date__c = theLastDayOfTheLastMonth );
        }
    }

    public string getVFPageName() {
        if (Test.isRunningTest()) return null;
        String pageName = ApexPages.CurrentPage().getUrl();
        pageName = pageName.replaceFirst('/apex/', '');
        pageName = EncodingUtil.urlEncode(pageName, 'UTF-8');
        string[] pageNameExtra = pageName.split('%3F', 0);
        pageName = pageNameExtra[0];
        return pageName;
    }
    public decimal zeroIfNull(decimal num) {
        if (num == null) num = 0;
        return num;
    }

    public void selectAccountSalesAndCOGS() {
        noError = true;
        if (theISO.GFCON__Requested_Delivery_Date__c != null) {
            Date theLastDayOftheMonth = theISO.GFCON__Requested_Delivery_Date__c.addMonths(1).toStartOfMonth().addDays(-1);
            if (theISO.GFCON__Requested_Delivery_Date__c != theLastDayOftheMonth) {
                noError = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a month end date.'));
            }
        } else {
            noError = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a month end date.'));
        }
    }

    public void selectGLAccounts() {
        GFERP__Company_Setup__c companySetup = [SELECT Name, GFERP__Account_AP__c, GFERP__Account_AR__c, GFERP__Account_Finished_Good_Inventory__c,
                GFERP__Account_Subassembly_Inventory__c, GFERP__Account_Raw_Material_Inventory__c, Account_Accrued_AP_Id__c, GFERP__Account_Inventory_Adjustment__c,
                Account_Default_Sales_Id__c, Account_Default_COGS_Id__c
        FROM GFERP__Company_Setup__c LIMIT 1];
        CompanyName = companySetup.Name;
        accountAR = companySetup.GFERP__Account_AR__c;
        accountAP = companySetup.GFERP__Account_AP__c;
        accountAAP = companySetup.Account_Accrued_AP_Id__c;
        accountGoods = companySetup.GFERP__Account_Finished_Good_Inventory__c;
        accountSales = companySetup.Account_Default_Sales_Id__c;
        accountCOGS = companySetup.Account_Default_COGS_Id__c;
        accountIA = companySetup.GFERP__Account_Inventory_Adjustment__c;
    }

    public void generateReport() {
        GLALines = new List<GLAccountLine>();
        Map<Id, Decimal> GLBeginAmountMap = new Map<Id, Decimal>();
        Map<Id, Decimal> GLChangedAmountMap = new Map<Id, Decimal>();
        Date startDate = Date.parse(theStartDate);
        Date endDate = Date.parse(theEndDate);
        //beg balance
        List<AggregateResult> results1 = [
                SELECT SUM(GFERP__Amount__c) amount, GFERP__GL_Account__c GLAccount FROM GFERP__GL_Entry__c
                WHERE GFERP__Correction__c = false AND GFERP__Posting_Date__c <: startDate GROUP BY GFERP__GL_Account__c
        ];     
        for (AggregateResult result : results1) {
            Id GLAId = (Id)result.get('GLAccount');
            Decimal GLAmount = (Decimal)result.get('amount');
            GLBeginAmountMap.put(GLAId, GLAmount);
        }
        //changes
        List<AggregateResult> results2 = [
                SELECT SUM(GFERP__Amount__c) amount, GFERP__GL_Account__c GLAccount FROM GFERP__GL_Entry__c
                WHERE GFERP__Correction__c = false AND GFERP__Posting_Date__c <=: endDate AND GFERP__Posting_Date__c >=: startDate GROUP BY GFERP__GL_Account__c
        ];
        for (AggregateResult result : results2) {
            Id GLAId = (Id)result.get('GLAccount');
            Decimal GLAmount = (Decimal)result.get('amount');
            GLChangedAmountMap.put(GLAId, GLAmount);
        }
        //beg adjustments
        Decimal begAdjustment1Local = 0;
        Decimal begAdjustment2Vendor = 0;
        Decimal begAdjustment3Customer = 0;
        
        //beg local expected cost
        List<AggregateResult> begresults3V1 = [
                SELECT SUM(GFERP__Expected_Cost__c) amount FROM GFERP__Cost_Entry__c
                WHERE GFERP__Correction__c = false AND GFERP__Posting_Date__c <: startDate 
                AND FPC_Local_Warehouse__c = true
        ];
        for (AggregateResult result : begresults3V1) {
            begAdjustment1Local += (Decimal)result.get('amount');
        }
        //beg vendor invoice cost
        List<AggregateResult> begresults3V2 = [
                SELECT SUM(GFERP__Invoiced_Cost__c) amount FROM GFERP__Cost_Entry__c
                WHERE GFERP__Correction__c = false AND GFERP__Posting_Date__c <: startDate 
                AND FPC_Vendor_Warehouse__c = true
        ];
        for (AggregateResult result : begresults3V2) {
            begAdjustment2Vendor += (Decimal)result.get('amount');
        }
        //beg customer invoice cost
        List<AggregateResult> begresults3V3 = [
                SELECT SUM(GFERP__Invoiced_Cost__c) amount FROM GFERP__Cost_Entry__c
                WHERE GFERP__Correction__c = false AND GFERP__Posting_Date__c <: startDate 
                AND FPC_Vendor_Warehouse__c = false AND FPC_Local_Warehouse__c = false
        ];
        for (AggregateResult result : begresults3V3) {
            begAdjustment3Customer += (Decimal)result.get('amount');
        }

        //adjustments
        Decimal totalAdjustment1Local = 0;
        Decimal totalAdjustment2Vendor = 0;
        Decimal totalAdjustment3Customer = 0;
        
        //local expected cost
        List<AggregateResult> results3V1 = [
                SELECT SUM(GFERP__Expected_Cost__c) amount FROM GFERP__Cost_Entry__c
                WHERE GFERP__Correction__c = false AND GFERP__Posting_Date__c <=: endDate AND GFERP__Posting_Date__c >=: startDate 
                AND FPC_Local_Warehouse__c = true
        ];
        for (AggregateResult result : results3V1) {
            totalAdjustment1Local += (Decimal)result.get('amount');
        }            
        //vendor invoice cost
        List<AggregateResult> results3V2 = [
                SELECT SUM(GFERP__Invoiced_Cost__c) amount FROM GFERP__Cost_Entry__c
                WHERE GFERP__Correction__c = false AND GFERP__Posting_Date__c <=: endDate AND GFERP__Posting_Date__c >=: startDate 
                AND FPC_Vendor_Warehouse__c = true 
        ];
        for (AggregateResult result : results3V2) {
            totalAdjustment2Vendor += (Decimal)result.get('amount');
        }
        //customer invoice cost
        List<AggregateResult> results3V3 = [
                SELECT SUM(GFERP__Invoiced_Cost__c) amount FROM GFERP__Cost_Entry__c
                WHERE GFERP__Correction__c = false AND (GFERP__Posting_Date__c <=: endDate AND GFERP__Posting_Date__c >=: startDate)
                AND (FPC_Vendor_Warehouse__c = false AND FPC_Local_Warehouse__c = false)
        ];
        SYSTEM.debug('183/start' + startDate + 'end' + endDate);
        for (AggregateResult result : results3V3) {
            totalAdjustment3Customer += (Decimal)result.get('amount');
        }
        //total AR
        List<AggregateResult> results4 = [SELECT SUM(GFERP__Invoice_Amt_Incl_Tax__c) totalAmount FROM GFERP__Sales_Invoice__c WHERE GFERP__Document_Status__c = 'Posted' AND GFERP__Posting_Date__c <=: endDate];
        Decimal totalReceivableAmount = (Decimal)results4[0].get('totalAmount');
        //total AP
        List<AggregateResult> results5 = [SELECT SUM(GFERP__Invoice_Cost__c) totalAmount FROM GFERP__Purchase_Invoice__c WHERE GFERP__Document_Status__c = 'Posted' AND GFERP__Posting_Date__c <=: endDate];
        Decimal totalPayableAmount = (Decimal)results5[0].get('totalAmount') * -1;

        //total inventory 
        Decimal totalInventoryAll = 0;
        //List<AggregateResult> results6V2 = [
        //        SELECT SUM(GFERP__Inventory_Value__c) totalValue FROM GFERP__Cost_Entry__c WHERE GFERP__Correction__c = false 
        //        AND GFERP__Posting_Date__c <=: endDate
        //        AND FPC_Local_Warehouse__c = true
        //];
        for (AggregateResult result : [
                SELECT SUM(GFERP__Inventory_Value__c) totalValue FROM GFERP__Cost_Entry__c WHERE GFERP__Correction__c = false 
                AND GFERP__Posting_Date__c <=: endDate
                AND FPC_Local_Warehouse__c = true
        ]) {
            totalInventoryAll += (Decimal)result.get('totalValue');
        }
        //total local expected cost
        Decimal totalExpectedCost = 0;
        //List<AggregateResult> results7V2 = [
        //        SELECT SUM(GFERP__Expected_Cost__c) amount FROM GFERP__Cost_Entry__c
        //        WHERE GFERP__Correction__c = false AND GFERP__Posting_Date__c <=: endDate
        //        AND FPC_Local_Warehouse__c = true
        //];
        for (AggregateResult result : [
                SELECT SUM(GFERP__Expected_Cost__c) amount FROM GFERP__Cost_Entry__c
                WHERE GFERP__Correction__c = false AND GFERP__Posting_Date__c <=: endDate
                AND FPC_Local_Warehouse__c = true
        ]) {
            totalExpectedCost += (Decimal)result.get('amount');
        }
        //total vendor invoice cost
        Decimal totalVendorInvoiceCost = 0;
        //List<AggregateResult> results8V2 = [
        //        SELECT SUM(GFERP__Invoiced_Cost__c) amount FROM GFERP__Cost_Entry__c
        //        WHERE GFERP__Correction__c = false AND GFERP__Posting_Date__c <=: endDate
        //        AND FPC_Vendor_Warehouse__c = true 
        //];
        for (AggregateResult result : [
                SELECT SUM(GFERP__Invoiced_Cost__c) amount FROM GFERP__Cost_Entry__c
                WHERE GFERP__Correction__c = false AND GFERP__Posting_Date__c <=: endDate
                AND FPC_Vendor_Warehouse__c = true 
        ]) {
            totalVendorInvoiceCost += (Decimal)result.get('amount');
        }

        Decimal totalReceivable = 0;
        Decimal totalPayable = 0;
        List<GFERP__GL_Account__c> GLAccounts = [SELECT Name, GFERP__Amount__c, GFERP__Description__c, GFERP__Entry_Count__c FROM GFERP__GL_Account__c 
                                                 WHERE (GFERP__Entry_Count__c != 0 OR Do_Not_Reconcile__c != true) ORDER BY Name];
        for (GFERP__GL_Account__c GLA : GLAccounts) {
            GLAccountLine newGLLine = new GLAccountLine();
            newGLLine.GLId = GLA.Id;
            newGLLine.GLAccount = GLA.Name;
            newGLLine.GLAccountDescription = GLA.GFERP__Description__c;

            // open balance
            if (GLBeginAmountMap.containsKey(GLA.Id)) {
                newGLLine.openBalance = GLBeginAmountMap.get(GLA.Id);
            } else {
                newGLLine.openBalance = 0;
            }
            if (accountGoods == GLA.Id){
                newGLLine.openBalance = newGLLine.openBalance + begAdjustment1Local - begAdjustment2Vendor - begAdjustment3Customer;
            }
            system.debug('scott237');
            if (GLA.Id == accountAAP) {
                system.debug('scott239');
                //newGLLine.openBalance = newGLLine.openBalance - begAdjustment1Local + begAdjustment2Vendor;
                newGLLine.openBalance = - begAdjustment1Local + begAdjustment2Vendor;
            }
            if (GLA.Id == accountIA) {
                newGLLine.openBalance = newGLLine.openBalance + begAdjustment3Customer;
            }

            // changes
            if (GLChangedAmountMap.containsKey(GLA.Id)) {
                newGLLine.changes = GLChangedAmountMap.get(GLA.Id);
            } else {
                newGLLine.changes = 0;
            }

            // unadjusted balance
            newGLLine.unadjustedBalance = newGLLine.openBalance + newGLLine.changes;

            // adjustments
            if (GLA.Id == accountGoods) {
                newGLLine.adjustments = totalAdjustment1Local;
                newGLLine.adjustmentsVendor = totalAdjustment2Vendor * -1;
                newGLLine.adjustmentsCustomer = totalAdjustment3Customer * -1;
            } else if (GLA.Id == accountAAP) {
                newGLLine.adjustments = totalAdjustment1Local * -1;
                newGLLine.adjustmentsVendor = totalAdjustment2Vendor;
            } else if (GLA.Id == accountIA) {
                newGLLine.adjustmentsCustomer = totalAdjustment3Customer;
            } else {
                newGLLine.adjustments = 0;
            }

            // adjusted balance
            newGLLine.adjustedBalance =  newGLLine.unadjustedBalance + zeroIfNull(newGLLine.adjustments) + zeroIfNull(newGLLine.adjustmentsVendor) + 
                zeroIfNull(newGLLine.adjustmentsCustomer);

            // goldfinch changes
            newGLLine.GFChanges = newGLLine.changes + zeroIfNull(newGLLine.adjustments) + zeroIfNull(newGLLine.adjustmentsVendor) + 
                zeroIfNull(newGLLine.adjustmentsCustomer);

            // supporting reports
            if (GLA.Id == accountAR) {
                newGLLine.supportingReports = zeroIfNull(totalReceivableAmount);
                newGLLine.difference = newGLLine.adjustedBalance - newGLLine.supportingReports;
                newGLLine.changesPostedInQB = newGLLine.GFChanges;
                totalReceivable = newGLLine.changesPostedInQB;
            } else if (GLA.Id == accountAP) {
                newGLLine.supportingReports = zeroIfNull(totalPayableAmount);
                newGLLine.difference = newGLLine.adjustedBalance - newGLLine.supportingReports;
                newGLLine.changesPostedInQB = newGLLine.GFChanges;
                totalPayable = newGLLine.changesPostedInQB;
            } else if (GLA.Id == accountGoods) {
                newGLLine.supportingReports = totalInventoryAll;
                newGLLine.difference = newGLLine.adjustedBalance- newGLLine.supportingReports;
            } else if (GLA.Id == accountAAP) {
                newGLLine.supportingReports = -totalExpectedCost + totalVendorInvoiceCost;
                newGLLine.difference = newGLLine.adjustedBalance - newGLLine.supportingReports;
            }

            GLALines.add(newGLLine);
        }
        for (GLAccountLine GLALine : GLALines) {
            // changes posted in QB
            if (accountSales == GLALine.GLId) {
                GLALine.changesPostedInQB = totalReceivable * -1;
            }
            if (accountCOGS == GLALine.GLId) {
                GLALine.changesPostedInQB = totalPayable * -1;
            }
            // end of month adj. entries
            GLALine.endOfMonthAdjEntries = GLALine.GFChanges - zeroIfNull(GLALine.changesPostedInQB);
            
            // inventory account
            if (GLALine.GLId == accountGoods) {
                GLALine.supportingReports = totalInventoryAll;
                GLALine.difference = GLALine.adjustedBalance- GLALine.supportingReports;
            }
        }
        totalOpenBalance = 0.0;
        totalChanges = 0.0;
        totalunadjustedBalance = 0.0;
        totalAdjustmentLocal = 0.0;
        totalAdjustmentVendor = 0.0;
        totalAdjustmentCustomer = 0.0;
        totalAdjustedBalance = 0.0;
        totalGFChanges = 0.0;
        totalChangesPostedInQB = 0.0;
        totalEndOfMonthAdjEntries = 0.0;
        for (GLAccountLine GLALine : GLALines) {
            totalOpenBalance += zeroIfNull(GLALine.openBalance);
            totalChanges += zeroIfNull(GLALine.changes);
            totalunadjustedBalance += zeroIfNull(GLALine.unadjustedBalance);
            totalAdjustmentLocal += zeroIfNull(GLALine.adjustments);
            totalAdjustmentVendor += zeroIfNull(GLALine.adjustmentsVendor);
            totalAdjustmentCustomer += zeroIfNull(GLALine.adjustmentsCustomer);
            totalAdjustedBalance += zeroIfNull(GLALine.adjustedBalance);
            totalGFChanges += zeroIfNull(GLALine.GFChanges);
            totalChangesPostedInQB += zeroIfNull(GLALine.changesPostedInQB);
            totalEndOfMonthAdjEntries += zeroIfNull(GLALine.endOfMonthAdjEntries);
        }
    }

    public pagereference returnBackToList() {
        return new ApexPages.Action('{!List}').invoke();
    }

    public class GLAccountLine {
        public Id GLId;
        public String GLAccount { get ;set; }
        public String GLAccountDescription { get ;set; }
        public Decimal openBalance { get ;set; }
        public Decimal changes { get ;set; }
        public Decimal unadjustedBalance { get ;set; }
        public Decimal adjustments { get ;set; }
        public Decimal adjustmentsVendor { get ;set; }
        public Decimal adjustmentsCustomer { get ;set; }
        public Decimal adjustedBalance { get ;set; }
        public Decimal supportingReports { get ;set; }
        public Decimal difference { get ;set; }
        public Decimal GFChanges { get ;set; }
        public Decimal changesPostedInQB { get ;set; }
        public Decimal endOfMonthAdjEntries { get ;set; }
    }
}