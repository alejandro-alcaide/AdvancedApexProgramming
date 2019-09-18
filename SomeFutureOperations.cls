// this future operations are done to maintain Data accross Trigger invocations
public class SomeFutureOperations {

    // use this flag to indicate that a future call has been made
    private static boolean futureCallCalled = false;

    public static void doFutureCall() {
        // if futureCallCalled is already flagged or SF knows that this is a future call
        if(futureCallCalled || System.isFuture())
            return;
        // else mark futureCallCalled as true and do the actual call
        futureCallCalled = true;
        actualFutureCall();
        }
    }

    @future
    private static void actualFutureCall() {
        // Actual async code here
        System.debug('actualFutureCall async operation');
    }
}