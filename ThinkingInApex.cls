/* centralizing access of a potentially multiple times used value (caching data)
 * 
 * obtain such information summoning ThinkingInApex.isUserSpecial() from anywhere in your
 * code without worrying about making redundant SOQL calls. */

public class ThinkingInApex {

    private static boolean userCacheLoaded = false;
    private static boolean userIsSpecial = false;
    private static string userTimeZone = null;

    public static boolean isUserSpecial() {
        // if we already have the value, then return it.
        if(userCacheLoaded)
            return userIsSpecial;
        // else get the cached info and return the desired value
        cacheUserInfo();
        return userIsSpecial;

    }

    // same procedure
    public static string userTimeZone() {
        if(userCacheLoaded)
            return userTimeZone;
        cacheUserInfo();
        return userTimeZone;isUserSpecialChecked 
    }

    private static void cacheUserInfo() {
        if(userCacheLoaded)
            return;

        // retrieve userIsSpecial values
        User u = [
            SELECT userIsSpecial__c, TimeZoneSidKey
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ];

        /* now we get the values, we turn on the userCacheLoaded to true 
        * and return our desired value */
        userIsSpecial = u.userIsSpecial__c;
        userTimeZone = u.TimeZoneSidKey;
        userCacheLoaded = true;
    }
}