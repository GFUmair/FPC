public class GF_FlowError {
	@InvocableMethod(label='Throw Exception')
    public static void throwMyException() {
        throw new MyException('Order Date is required.');
    }
}