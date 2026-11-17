import '../models/opportunity.dart';
import 'suitecrm_client.dart';

class OpportunityService {
  final SuiteCRMClient _client = SuiteCRMClient();

  Future<List<Opportunity>> getOpportunities({
    String search = '',
    int offset = 0,
    int maxResults = 25,
    OpportunityFilter? filter,
    bool myStatsOnly = false,
  }) {
    return _client.getOpportunityList(
      search: search,
      offset: offset,
      maxResults: maxResults,
      filter: filter,
      myStatsOnly: myStatsOnly,
    );
  }

  Future<int> getOpportunityCount({
    String search = '',
    OpportunityFilter? filter,
    bool myStatsOnly = false,
  }) {
    return _client.getOpportunityCount(
      search: search,
      filter: filter,
      myStatsOnly: myStatsOnly,
    );
  }

  Future<double> getTotalOpportunityValue() {
    return _client.getTotalOpportunityValue();
  }

  Future<bool> createOpportunity({
    required String name,
    required String accountName,
    required String amount,
    required String salesStage,
    required String probability,
    required String dateClosed,
    required String type,
    required String leadSource,
    required String nextStep,
    required String description,
    String assignedTo = '',
  }) {
    return _client.createOpportunity(
      name: name,
      accountName: accountName,
      amount: amount,
      salesStage: salesStage,
      probability: probability,
      dateClosed: dateClosed,
      type: type,
      leadSource: leadSource,
      nextStep: nextStep,
      description: description,
      assignedTo: assignedTo,
    );
  }

  Future<bool> updateOpportunity({
    required String id,
    required String name,
    required String accountName,
    required String amount,
    required String salesStage,
    required String probability,
    required String dateClosed,
    required String type,
    required String leadSource,
    required String nextStep,
    required String description,
    String assignedTo = '',
  }) {
    return _client.updateOpportunity(
      id: id,
      name: name,
      accountName: accountName,
      amount: amount,
      salesStage: salesStage,
      probability: probability,
      dateClosed: dateClosed,
      type: type,
      leadSource: leadSource,
      nextStep: nextStep,
      description: description,
      assignedTo: assignedTo,
    );
  }
}
