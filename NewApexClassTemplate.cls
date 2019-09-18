public class NewApexClassTemplate {

    /* to be sure my trigger or class just runs once as long as it belongs to the same 
     * context */
    public static boolean firstcall = false;

    // if not false, hence true
    if(!myclass.firstcall) {
        // First call into class
        myclass.firstcall = true;
    } else {
        // Subsequent call into class
    }
}