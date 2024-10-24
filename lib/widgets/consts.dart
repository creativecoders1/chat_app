// Email validation regex
final RegExp EMAIL_VALIDATION_REGEX =
    RegExp(r"^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$");

// Password validation regex: Must contain at least one digit, one lowercase letter, and one uppercase letter, with a length of 8 or more
final RegExp PASSWORD_VALIDATION_REGEX =
    RegExp(r"(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,}$");

// Name validation regex: Accepts capital and accented letters along with hyphens, spaces, and certain punctuation
final RegExp NAME_VALIDATION_REGEX =
    RegExp(r"\b([A-Za-zÀ-ÿ][-,'a-zA-ZÀ-ÿ. ]+)*\b");

// Placeholder for profile picture URL
final String PLACEHOLDER_PFP =
    "https://t3.ftcdn.net/jpg/05/16/27/58/360_F_516275801_f3Fsp17x6HQK0xQgDQEELOTUER04SsWV.jpg";
