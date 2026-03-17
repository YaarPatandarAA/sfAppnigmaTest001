/**
 * AccountService
 *
 * Service class providing utility methods for Account-related operations,
 * including phone number validation and normalisation.
 *
 * Designed for use in triggers, flows (@InvocableMethod), and LWC (@AuraEnabled).
 */
public with sharing class AccountService {

    // ─── Constants ────────────────────────────────────────────────────────────

    /** Matches a clean 10-digit US phone number after stripping non-numeric chars.
     *  Area code and exchange code must each start with 2-9. */
    private static final Pattern PHONE_PATTERN =
        Pattern.compile('^[2-9]\\d{2}[2-9]\\d{6}$');

    // ─── Inner Classes ────────────────────────────────────────────────────────

    /**
     * Holds the outcome of a phone validation call.
     * @AuraEnabled on each property allows direct use in LWC via Apex wire/imperative calls.
     */
    public class ValidationResult {
        @AuraEnabled public Boolean isValid       { get; set; }
        @AuraEnabled public String  normalisedPhone { get; set; }  // null if invalid
        @AuraEnabled public String  errorCode     { get; set; }    // e.g. 'PHONE-003'
        @AuraEnabled public String  errorMessage  { get; set; }    // human-readable

        public ValidationResult() {
            this.isValid        = false;
            this.normalisedPhone = null;
            this.errorCode      = null;
            this.errorMessage   = null;
        }
    }

    /**
     * Thrown by validateAndNormalise() when the phone number is invalid.
     * Catch specifically with: catch (AccountService.PhoneValidationException e)
     */
    public class PhoneValidationException extends Exception {
        public String errorCode { get; set; }
    }

    // ─── Public Methods ───────────────────────────────────────────────────────

    /**
     * Validates a phone number string. Never throws — always returns a ValidationResult.
     * Safe to call from triggers, batch jobs, and any bulk context.
     *
     * @param rawPhone  The raw phone string to validate (e.g. "(415) 555-1234")
     * @return          ValidationResult with isValid, normalisedPhone, errorCode, and errorMessage
     */
    public static ValidationResult validatePhone(String rawPhone) {
        ValidationResult result = new ValidationResult();

        // Step 1 — Null / blank check
        if (String.isBlank(rawPhone)) {
            result.errorCode    = 'PHONE-001';
            result.errorMessage = 'Phone number cannot be blank.';
            return result;
        }

        // Step 2 — Strip non-numeric characters (spaces, dashes, dots, parens, +)
        String digits = rawPhone.replaceAll('[^0-9]', '');

        // Step 3 — Strip leading country code (remove leading "1" if 11 digits)
        if (digits.length() == 11 && digits.startsWith('1')) {
            digits = digits.substring(1);
        }

        // Step 4 — Length check (must be exactly 10 digits)
        if (digits.length() != 10) {
            result.errorCode    = 'PHONE-003';
            result.errorMessage = 'Phone number must be 10 digits.';
            return result;
        }

        // Step 5 — Area code check (first digit must not be 0 or 1)
        String areaCodeFirstDigit = digits.substring(0, 1);
        if (areaCodeFirstDigit == '0' || areaCodeFirstDigit == '1') {
            result.errorCode    = 'PHONE-004';
            result.errorMessage = 'Area code cannot start with 0 or 1.';
            return result;
        }

        // Step 6 — Exchange code check (fourth digit must not be 0 or 1)
        String exchangeFirstDigit = digits.substring(3, 4);
        if (exchangeFirstDigit == '0' || exchangeFirstDigit == '1') {
            result.errorCode    = 'PHONE-005';
            result.errorMessage = 'Exchange code cannot start with 0 or 1.';
            return result;
        }

        // Step 7 — Final regex validation and normalisation to E.164
        Matcher m = PHONE_PATTERN.matcher(digits);
        if (!m.matches()) {
            result.errorCode    = 'PHONE-003';
            result.errorMessage = 'Phone number must be 10 digits.';
            return result;
        }

        result.isValid         = true;
        result.normalisedPhone = '+1' + digits;
        return result;
    }

    /**
     * Validates and returns the normalised E.164 phone number.
     * Throws PhoneValidationException on failure.
     * Use when the caller wants fail-fast behaviour (e.g. a single-record API endpoint).
     *
     * @param rawPhone  The raw phone string to validate
     * @return          Normalised phone string in E.164 format (+1XXXXXXXXXX)
     * @throws          PhoneValidationException if the number is invalid
     */
    public static String validateAndNormalise(String rawPhone) {
        ValidationResult result = validatePhone(rawPhone);
        if (!result.isValid) {
            PhoneValidationException ex = new PhoneValidationException(result.errorMessage);
            ex.errorCode = result.errorCode;
            throw ex;
        }
        return result.normalisedPhone;
    }

    /**
     * Invocable entry point for Flow and Process Builder.
     * Accepts a list of raw phone strings, returns a list of ValidationResult.
     *
     * @param rawPhones  List of raw phone strings to validate
     * @return           List of ValidationResult (one per input, in the same order)
     */
    @InvocableMethod(
        label='Validate Phone Numbers'
        description='Validates and normalises US phone number strings. Returns a ValidationResult for each input.'
    )
    public static List<ValidationResult> validatePhoneList(List<String> rawPhones) {
        List<ValidationResult> results = new List<ValidationResult>();
        for (String rawPhone : rawPhones) {
            results.add(validatePhone(rawPhone));
        }
        return results;
    }
}
