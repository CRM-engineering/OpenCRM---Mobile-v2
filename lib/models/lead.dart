class Lead {
  final String id;
  final String firstName;
  final String lastName;
  final String accountName;
  final String title;
  final String phoneWork;
  final String phoneMobile;
  final String email;
  final String website;
  final String street;
  final String suburb;
  final String city;
  final String province;
  final String postalCode;
  final String country;
  final String description;
  final String status;
  final String leadSource;
  final String assignedTo;
  final String dateCreated;

  const Lead({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.accountName,
    required this.title,
    required this.phoneWork,
    required this.phoneMobile,
    required this.email,
    required this.website,
    required this.street,
    required this.suburb,
    required this.city,
    required this.province,
    required this.postalCode,
    required this.country,
    required this.description,
    required this.status,
    required this.leadSource,
    required this.assignedTo,
    required this.dateCreated,
  });

  String get fullName => [firstName, lastName]
      .where((value) => value.trim().isNotEmpty)
      .join(' ');
}

class LeadFilter {
  final String status;
  final String leadSource;
  final String assignedTo;
  final String dateFrom;
  final String dateTo;
  final String sortBy;
  final bool sortAscending;

  const LeadFilter({
    this.status = '',
    this.leadSource = '',
    this.assignedTo = '',
    this.dateFrom = '',
    this.dateTo = '',
    this.sortBy = 'date_created',
    this.sortAscending = false,
  });

  bool get hasFilters => status.isNotEmpty ||
      leadSource.isNotEmpty ||
      assignedTo.isNotEmpty ||
      dateFrom.isNotEmpty ||
      dateTo.isNotEmpty;

  LeadFilter copyWith({
    String? status,
    String? leadSource,
    String? assignedTo,
    String? dateFrom,
    String? dateTo,
    String? sortBy,
    bool? sortAscending,
  }) => LeadFilter(
        status: status ?? this.status,
        leadSource: leadSource ?? this.leadSource,
        assignedTo: assignedTo ?? this.assignedTo,
        dateFrom: dateFrom ?? this.dateFrom,
        dateTo: dateTo ?? this.dateTo,
        sortBy: sortBy ?? this.sortBy,
        sortAscending: sortAscending ?? this.sortAscending,
      );
}
