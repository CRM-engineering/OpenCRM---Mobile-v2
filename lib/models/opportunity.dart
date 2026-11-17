class Opportunity {
  final String id;
  final String name;
  final String accountName;
  final double amount;
  final int probability;
  final String salesStage;
  final String expectedCloseDate;
  final String type;
  final String leadSource;
  final String nextStep;
  final String description;
  final String assignedTo;

  const Opportunity({
    required this.id,
    required this.name,
    required this.accountName,
    required this.amount,
    required this.probability,
    required this.salesStage,
    required this.expectedCloseDate,
    required this.type,
    required this.leadSource,
    required this.nextStep,
    required this.description,
    this.assignedTo = '',
  });

  double get weightedAmount => amount * (probability / 100);
}

class OpportunityFilter {
  final String salesStage;
  final String assignedTo;
  final String dateFrom;
  final String dateTo;
  final String sortBy;
  final bool sortAscending;

  const OpportunityFilter({
    this.salesStage = '',
    this.assignedTo = '',
    this.dateFrom = '',
    this.dateTo = '',
    this.sortBy = 'date_closed',
    this.sortAscending = true,
  });

  bool get hasFilters =>
      salesStage.isNotEmpty ||
      assignedTo.isNotEmpty ||
      dateFrom.isNotEmpty ||
      dateTo.isNotEmpty;

  OpportunityFilter copyWith({
    String? salesStage,
    String? assignedTo,
    String? dateFrom,
    String? dateTo,
    String? sortBy,
    bool? sortAscending,
  }) {
    return OpportunityFilter(
      salesStage: salesStage ?? this.salesStage,
      assignedTo: assignedTo ?? this.assignedTo,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }
}
