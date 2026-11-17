import '../models/lead.dart';
import 'suitecrm_client.dart';

class LeadService {
  final SuiteCRMClient _client = SuiteCRMClient();

  Future<List<Lead>> getLeads({
    String search = '',
    int offset = 0,
    int maxResults = 25,
    LeadFilter? filter,
    bool myStatsOnly = false,
  }) => _client.getLeadList(
        search: search,
        offset: offset,
        maxResults: maxResults,
        filter: filter,
        myStatsOnly: myStatsOnly,
      );

  Future<int> getLeadCount({
    String search = '',
    LeadFilter? filter,
    bool myStatsOnly = false,
  }) => _client.getLeadCount(search: search, filter: filter, myStatsOnly: myStatsOnly);

  Future<bool> createLead(Lead lead) => _client.createLead(lead);

  Future<bool> updateLead(Lead lead) => _client.updateLead(lead);

  Future<bool> deleteLead(String id) => _client.deleteLead(id);
}
