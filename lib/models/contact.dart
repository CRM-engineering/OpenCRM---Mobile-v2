class Contact {
  final String id;
  final String firstName;
  final String lastName;
  final String accountName;
  final String title;
  final String department;
  final String phoneWork;
  final String phoneMobile;
  final String email;
  final String website;
  final String street;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String leadSource;
  final String description;
  final String assignedTo;

  const Contact({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.accountName,
    required this.title,
    required this.department,
    required this.phoneWork,
    required this.phoneMobile,
    required this.email,
    required this.website,
    required this.street,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.leadSource,
    required this.description,
    required this.assignedTo,
  });

  String get fullName {
    final value = '$firstName $lastName'.trim();
    return value.isEmpty ? 'Unnamed Contact' : value;
  }
}

class ContactFilter {
  final String leadSource;
  final String department;
  final String sortBy;
  final bool sortAscending;

  const ContactFilter({
    this.leadSource = '',
    this.department = '',
    this.sortBy = 'last_name',
    this.sortAscending = true,
  });

  bool get hasFilters =>
      leadSource.isNotEmpty || department.isNotEmpty;

  ContactFilter copyWith({
    String? leadSource,
    String? department,
    String? sortBy,
    bool? sortAscending,
  }) {
    return ContactFilter(
      leadSource: leadSource ?? this.leadSource,
      department: department ?? this.department,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }
}
