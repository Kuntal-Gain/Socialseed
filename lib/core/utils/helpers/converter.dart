/// Converts a String to its corresponding Enum value.
///
/// [values] - Typically the static `.values` list from the Enum (e.g., `Color.values`).
/// [value] - The raw string name to search for.
/// [fallback] - The value to return if [value] is null or no match is found.
///
/// Example: `enumFromString(Status.values, 'active', Status.unknown)`
T enumFromString<T extends Enum>(
  Iterable<T> values,
  String? value,
  T fallback,
) {
  // Return the default immediately if the input string is null
  if (value == null) return fallback;

  return values.firstWhere(
    // Compares the .name property of the enum (e.g., 'red') to the input string
    (e) => e.name == value,
    // If the string doesn't exist in the enum, return the fallback
    orElse: () => fallback,
  );
}

/// Extracts the string representation of an Enum value.
///
/// This utilizes the built-in [EnumName.name] extension.
/// Example: `enumToString(Status.pending)` returns "pending".
String enumToString(Enum value) {
  return value.name;
}
