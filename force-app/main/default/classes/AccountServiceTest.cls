/**
 * @description Comprehensive test class for AccountService.
 *              Covers all validation rules, error codes, both public methods,
 *              the @InvocableMethod entry point, and bulk scenarios.
 *
 * @author      Appnigma AI
 * @since       2025
 */
@isTest(SeeAllData=false)
private class AccountServiceTest {

    // ─────────────────────────────────────────────────────────────────────────
    // validatePhone — Valid inputs
    // ─────────────────────────────────────────────────────────────────────────

    @isTest
    static void testValidPhone_NationalDashes() {
        Test.startTest();
        AccountService.ValidationResult result =
            AccountService.validatePhone('415-555-1234');
        Test.stopTest();

        System.assertEquals(true,            result.isValid,         'National dashes format should be valid');
        System.assertEquals('+14155551234',  result.normalisedPhone, 'Should normalise to E.164');
        System.assertEquals(null,            result.errorCode,       'No error code expected for valid number');
        System.assertEquals(null,            result.errorMessage,    'No error message expected for valid number');
    }

    @isTest
    static void testValidPhone_Parentheses() {
        Test.startTest();
        AccountService.ValidationResult result =
            AccountService.validatePhone('(415) 555-1234');
        Test.stopTest();

        System.assertEquals(true,           result.isValid,         'Parentheses format should be valid');
        System.assertEquals('+14155551234', result.normalisedPhone, 'Should normalise to E.164');
    }

    @isTest
    static void testValidPhone_E164() {
        Test.startTest();
        AccountService.ValidationResult result =
            AccountService.validatePhone('+14155551234');
        Test.stopTest();

        System.assertEquals(true,           result.isValid,         'E.164 format should be valid');
        System.assertEquals('+14155551234', result.normalisedPhone, 'E.164 input should round-trip correctly');
    }

    @isTest
    static void testValidPhone_WithCountryCode() {
        Test.startTest();
        AccountService.ValidationResult result =
            AccountService.validatePhone('14155551234');
        Test.stopTest();

        System.assertEquals(true,           result.isValid,         '11-digit number with leading 1 should be valid');
        System.assertEquals('+14155551234', result.normalisedPhone, 'Should strip leading 1 and normalise to E.164');
    }

    @isTest
    static void testValidPhone_DotsFormat() {
        Test.startTest();
        AccountService.ValidationResult result =
            AccountService.validatePhone('415.555.1234');
        Test.stopTest();

        System.assertEquals(true,           result.isValid,         'Dot-separated format should be valid');
        System.assertEquals('+14155551234', result.normalisedPhone, 'Should normalise to E.164');
    }

    @isTest
    static void testValidPhone_PlainTenDigits() {
        Test.startTest();
        AccountService.ValidationResult result =
            AccountService.validatePhone('4155551234');
        Test.stopTest();

        System.assertEquals(true,           result.isValid,         'Plain 10-digit number should be valid');
        System.assertEquals('+14155551234', result.normalisedPhone, 'Should normalise to E.164');
    }

    // ─────────────────────────────────────────────────────────────────────────
    // validatePhone — Invalid inputs
    // ─────────────────────────────────────────────────────────────────────────

    @isTest
    static void testInvalidPhone_Blank() {
        Test.startTest();
        AccountService.ValidationResult result =
            AccountService.validatePhone('');
        Test.stopTest();

        System.assertEquals(false,       result.isValid,      'Blank string should be invalid');
        System.assertEquals('PHONE-001', result.errorCode,    'Blank input should return PHONE-001');
        System.assertEquals('Phone number cannot be blank.', result.errorMessage,
            'Error message should match PHONE-001 definition');
        System.assertEquals(null,        result.normalisedPhone, 'No normalised phone expected for invalid result');
    }

    @isTest
    static void testInvalidPhone_Null() {
        Test.startTest();
        AccountService.ValidationResult result =
            AccountService.validatePhone(null);
        Test.stopTest();

        System.assertEquals(false,       result.isValid,   'Null input should be invalid');
        System.assertEquals('PHONE-001', result.errorCode, 'Null input should return PHONE-001');
        System.assertEquals('Phone number cannot be blank.', result.errorMessage,
            'Error message should match PHONE-001 definition');
    }

    @isTest
    static void testInvalidPhone_TooShort() {
        Test.startTest();
        AccountService.ValidationResult result =
            AccountService.validatePhone('41555512');
        Test.stopTest();

        System.assertEquals(false,       result.isValid,   '8-digit number should be invalid');
        System.assertEquals('PHONE-003', result.errorCode, 'Too-short number should return PHONE-003');
        System.assertEquals('Phone number must be 10 digits.', result.errorMessage,
            'Error message should match PHONE-003 definition');
    }

    @isTest
    static void testInvalidPhone_TooLong() {
        Test.startTest();
        AccountService.ValidationResult result =
            AccountService.validatePhone('415555123456');
        Test.stopTest();

        System.assertEquals(false,       result.isValid,   '12-digit number should be invalid');
        System.assertEquals('PHONE-003', result.errorCode, 'Too-long number should return PHONE-003');
        System.assertEquals('Phone number must be 10 digits.', result.errorMessage,
            'Error message should match PHONE-003 definition');
    }

    @isTest
    static void testInvalidPhone_BadAreaCode() {
        Test.startTest();
        AccountService.ValidationResult result =
            AccountService.validatePhone('0155551234');
        Test.stopTest();

        System.assertEquals(false,       result.isValid,   'Area code starting with 0 should be invalid');
        System.assertEquals('PHONE-004', result.errorCode, 'Bad area code should return PHONE-004');
        System.assertEquals('Area code cannot start with 0 or 1.', result.errorMessage,
            'Error message should match PHONE-004 definition');
    }

    @isTest
    static void testInvalidPhone_BadAreaCode_StartsWithOne() {
        Test.startTest();
        AccountService.ValidationResult result =
            AccountService.validatePhone('1155551234');
        Test.stopTest();

        System.assertEquals(false,       result.isValid,   'Area code starting with 1 should be invalid');
        System.assertEquals('PHONE-004', result.errorCode, 'Area code starting with 1 should return PHONE-004');
    }

    @isTest
    static void testInvalidPhone_BadExchange() {
        Test.startTest();
        AccountService.ValidationResult result =
            AccountService.validatePhone('4150551234');
        Test.stopTest();

        System.assertEquals(false,       result.isValid,   'Exchange code starting with 0 should be invalid');
        System.assertEquals('PHONE-005', result.errorCode, 'Bad exchange code should return PHONE-005');
        System.assertEquals('Exchange code cannot start with 0 or 1.', result.errorMessage,
            'Error message should match PHONE-005 definition');
    }

    @isTest
    static void testInvalidPhone_BadExchange_StartsWithOne() {
        Test.startTest();
        AccountService.ValidationResult result =
            AccountService.validatePhone('4151551234');
        Test.stopTest();

        System.assertEquals(false,       result.isValid,   'Exchange code starting with 1 should be invalid');
        System.assertEquals('PHONE-005', result.errorCode, 'Exchange code starting with 1 should return PHONE-005');
    }

    // ─────────────────────────────────────────────────────────────────────────
    // validateAndNormalise — throws on failure, returns on success
    // ─────────────────────────────────────────────────────────────────────────

    @isTest
    static void testValidateAndNormalise_Returns() {
        Test.startTest();
        String normalised = AccountService.validateAndNormalise('(415) 555-1234');
        Test.stopTest();

        System.assertEquals('+14155551234', normalised,
            'validateAndNormalise should return E.164 string for valid input');
    }

    @isTest
    static void testValidateAndNormalise_Throws() {
        Boolean exceptionThrown = false;
        String  capturedCode    = null;

        Test.startTest();
        try {
            AccountService.validateAndNormalise('not-a-phone');
        } catch (AccountService.PhoneValidationException ex) {
            exceptionThrown = true;
            capturedCode    = ex.errorCode;
        }
        Test.stopTest();

        System.assertEquals(true, exceptionThrown,
            'PhoneValidationException should be thrown for invalid input');
        System.assertNotEquals(null, capturedCode,
            'Exception should carry a non-null errorCode');
    }

    @isTest
    static void testValidateAndNormalise_ThrowsOnNull() {
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            AccountService.validateAndNormalise(null);
        } catch (AccountService.PhoneValidationException ex) {
            exceptionThrown = true;
            System.assertEquals('PHONE-001', ex.errorCode,
                'Null input should produce PHONE-001 on the exception');
        }
        Test.stopTest();

        System.assertEquals(true, exceptionThrown,
            'PhoneValidationException should be thrown for null input');
    }

    // ─────────────────────────────────────────────────────────────────────────
    // validatePhoneList (@InvocableMethod) — bulk scenarios
    // ─────────────────────────────────────────────────────────────────────────

    @isTest
    static void testInvocable_BulkList() {
        // Build a list of 200 inputs: alternating valid and invalid
        List<String> inputs = new List<String>();
        for (Integer i = 0; i < 200; i++) {
            if (Math.mod(i, 2) == 0) {
                inputs.add('415-555-' + String.valueOf(1000 + i).substring(0, 4));
            } else {
                inputs.add('000-000-0000'); // invalid — bad area code
            }
        }

        Test.startTest();
        List<AccountService.ValidationResult> results =
            AccountService.validatePhoneList(inputs);
        Test.stopTest();

        System.assertEquals(200, results.size(),
            'Should return exactly one result per input');

        // Even indices should be valid, odd indices should be invalid
        for (Integer i = 0; i < results.size(); i++) {
            if (Math.mod(i, 2) == 0) {
                System.assertEquals(true, results[i].isValid,
                    'Even-index result at position ' + i + ' should be valid');
            } else {
                System.assertEquals(false, results[i].isValid,
                    'Odd-index result at position ' + i + ' should be invalid');
            }
        }
    }

    @isTest
    static void testInvocable_EmptyList() {
        Test.startTest();
        List<AccountService.ValidationResult> results =
            AccountService.validatePhoneList(new List<String>());
        Test.stopTest();

        System.assertEquals(0, results.size(),
            'Empty input list should return empty result list');
    }

    @isTest
    static void testInvocable_NullList() {
        Test.startTest();
        List<AccountService.ValidationResult> results =
            AccountService.validatePhoneList(null);
        Test.stopTest();

        System.assertEquals(0, results.size(),
            'Null input list should return empty result list without throwing');
    }

    @isTest
    static void testInvocable_SingleValidEntry() {
        Test.startTest();
        List<AccountService.ValidationResult> results =
            AccountService.validatePhoneList(new List<String>{ '+14155551234' });
        Test.stopTest();

        System.assertEquals(1,              results.size(),              'Should return one result');
        System.assertEquals(true,           results[0].isValid,          'Single valid entry should pass');
        System.assertEquals('+14155551234', results[0].normalisedPhone,  'Should return correct E.164 number');
    }
}
