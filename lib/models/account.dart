class Account {
  final String id;
  final String name;
  final String officePhone;
  final String fax;
  final String website;
  final String email;
  final String billingStreet;
  final String billingCity;
  final String billingState;
  final String billingPostalCode;
  final String billingCountry;
  final String shippingStreet;
  final String shippingCity;
  final String shippingState;
  final String shippingPostalCode;
  final String shippingCountry;
  final String type;
  final String industry;
  final String annualRevenue;
  final String employees;
  final String description;
  final String assignedTo;

  const Account({
    required this.id,
    required this.name,
    required this.officePhone,
    required this.fax,
    required this.website,
    required this.email,
    required this.billingStreet,
    required this.billingCity,
    required this.billingState,
    required this.billingPostalCode,
    required this.billingCountry,
    required this.shippingStreet,
    required this.shippingCity,
    required this.shippingState,
    required this.shippingPostalCode,
    required this.shippingCountry,
    required this.type,
    required this.industry,
    required this.annualRevenue,
    required this.employees,
    required this.description,
    required this.assignedTo,
  });
}

class AccountFilter {
  final String type;
  final String industry;
  final String assignedTo;
  final String sortBy;
  final bool sortAscending;

  const AccountFilter({
    this.type = '',
    this.industry = '',
    this.assignedTo = '',
    this.sortBy = 'name',
    this.sortAscending = true,
  });

  bool get hasFilters =>
      type.isNotEmpty ||
      industry.isNotEmpty ||
      assignedTo.isNotEmpty;

  AccountFilter copyWith({
    String? type,
    String? industry,
    String? assignedTo,
    String? sortBy,
    bool? sortAscending,
  }) {
    return AccountFilter(
      type: type ?? this.type,
      industry: industry ?? this.industry,
      assignedTo: assignedTo ?? this.assignedTo,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }
}
