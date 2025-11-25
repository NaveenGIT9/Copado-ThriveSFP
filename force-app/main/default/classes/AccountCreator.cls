/**
 * @description Utility class to handle the creation and insertion of Account records.
 */
public with sharing class AccountCreator {
    // --- New Method Added at the START ---
    /**
     * @description Counts the total number of Account records currently in the organization.
     * @return The count of all Account records.
     */
    public static Integer countExistingAccounts() {
        // Query to count all Accounts. Using COUNT() for efficiency.
        return [SELECT COUNT() FROM Account];
    }
    // ------------------------------------

    /**
     * @description Creates and inserts Account records based on a list of names.
     * @param accountNames A list of strings, where each string is the name for a new Account.
     * @return A list of the inserted Account records.
     */
    public static List<Account> createNewAccounts(List<String> accountNames) {
        
        // Check for empty or null input list to prevent DML errors.
        if (accountNames == null || accountNames.isEmpty()) {
            System.debug('Account names list is null or empty. Skipping insertion.');
            return new List<Account>();
        }

        List<Account> accountsToInsert = new List<Account>();

        // Loop through the list of names and create new Account objects.
        for (String accName : accountNames) {
            Account newAccount = new Account(
                Name = accName,
                // Set a default Industry for demonstration purposes
                Industry = 'Technology',
                NumberOfEmployees = 100 
            );
            accountsToInsert.add(newAccount);
        }

        System.debug('Attempting to insert ' + accountsToInsert.size() + ' Accounts.');

        // Perform the DML operation
        try {
            insert accountsToInsert;
            System.debug('Successfully inserted accounts.');
        } catch (DmlException e) {
            // Handle any potential DML exceptions
            System.debug('DML Error inserting accounts: ' + e.getMessage());
            // Optionally, re-throw a custom exception
            throw new AccountCreationException('Failed to insert accounts due to: ' + e.getMessage());
        }

        return accountsToInsert;
    }
    // --- New Method Added in the MIDDLE ---
    /**
    
    // Custom exception class for better error handling visibility.
    public class AccountCreationException extends Exception {}
}