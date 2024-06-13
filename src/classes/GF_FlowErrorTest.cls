@isTest
public class GF_FlowErrorTest {
    @isTest
    static void testThrowMyException() {
        Test.startTest();
        try {
            GF_FlowError.throwMyException();
            System.assert(false, 'Expected exception was not thrown.');
        } catch (MyException ex) {
            System.assertEquals('Order Date is required.', ex.getMessage());
        }
        Test.stopTest();
    }
}