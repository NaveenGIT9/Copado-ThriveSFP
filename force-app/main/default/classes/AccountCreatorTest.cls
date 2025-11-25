/**
 * @description Test class for the AccountCreator utility.
 */
@IsTest
private class AccountCreatorTest {

    private static final String TEST_ACCOUNT_NAME_1 = 'Test Account A';
    private static final String TEST_ACCOUNT_NAME_2 = 'Test Account B';

    /**
     * @description Test case to verify successful creation and insertion of multiple accounts.
     */
    @IsTest
    static void testSuccessfulAccountCreation() {
        
        // 1. Prepare Test Data
        List<String> names = new List<String>{
            TEST_ACCOUNT_NAME_1,
            TEST_ACCOUNT_NAME_2,
            'Another Test Account'
        };

        // 2. System Assertion (Pre-check)
        // Verify that no accounts exist before the call
        System.assertEquals(0, [SELECT count() FROM Account WHERE Name IN :names], 
                            'Pre-check failed: No accounts should exist yet.');

        // 3. Call the Method Under Test (MUT)
        Test.startTest();
        List<Account> insertedAccounts = AccountCreator.createNewAccounts(names);
        Test.stopTest();

        // 4. System Assertions (Post-check)
        // Check the size of the returned list
        System.assertEquals(3, insertedAccounts.size(), 'Expected 3 accounts to be returned.');
        
        // Check the database for the inserted records
        List<Account> queriedAccounts = [SELECT Id, Name FROM Account WHERE Name IN :names];
        System.assertEquals(3, queriedAccounts.size(), 'Expected 3 accounts to be inserted into the database.');
        
        // Verify a specific record property (optional but good practice)
        System.assertNotEquals(null, insertedAccounts[0].Id, 'The first inserted account should have an Id.');
    }

    /**
     * @description Test case to verify graceful handling of null/empty input list.
     */
    @IsTest
    static void testEmptyAccountList() {
        
        // 1. Prepare Test Data (Null and Empty list)
        List<String> nullNames = null;
        List<String> emptyNames = new List<String>();

        // 2. Call the Method Under Test (MUT)
        Test.startTest();
        List<Account> nullResult = AccountCreator.createNewAccounts(nullNames);
        List<Account> emptyResult = AccountCreator.createNewAccounts(emptyNames);
        Test.stopTest();

        // 3. System Assertions
        System.assert(nullResult.isEmpty(), 'Result should be an empty list for null input.');
        System.assert(emptyResult.isEmpty(), 'Result should be an empty list for empty input.');
    }
    
    /**
     * @description Test case to verify custom exception handling.
     */
    @IsTest
    static void testExceptionHandling() {
        
        // Create an excessively long name (> 255 chars) to trigger a database validation error.
        String invalidName = 'A'.repeat(300); 
        List<String> names = new List<String>{invalidName};

        // We expect the custom exception to be thrown
        Boolean exceptionCaught = false;

        Test.startTest();
        try {
            AccountCreator.createNewAccounts(names);
        } catch (AccountCreator.AccountCreationException e) {
            exceptionCaught = true;
            // CORRECTED ASSERTION: The standard DML error for string length limit is usually 'STRING_TOO_LONG'.
            System.assert(e.getMessage().contains('STRING_TOO_LONG'), 'Error message should indicate a string length failure.');
        }
        Test.stopTest();

        System.assert(exceptionCaught, 'Expected AccountCreationException was not thrown.');
    }
}