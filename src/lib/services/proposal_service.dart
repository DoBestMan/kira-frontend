import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kira_auth/models/export.dart';
import 'package:kira_auth/config.dart';

class ProposalService {
  List<Proposal> proposals = [];

  Future<void> getProposals({int proposalId = 0}) async {
    this.proposals = [];
    List<Proposal> proposalList = [];

    String apiUrl = await loadInterxURL();
    var data = await http.get(apiUrl + "/kira/gov/proposals" + (proposalId > 0 ? "/$proposalId" : ""));

    var bodyData = json.decode(data.body);
    if (!bodyData.containsKey('proposals')) return;
    var proposals = bodyData['proposals'];

    for (int i = 0; i < proposals.length; i++) {
      Proposal proposal = Proposal(
        proposalId: proposals[i]['proposal_id'],
        submitTime: proposals[i]['submit_time'] != null ? DateTime.parse(proposals[i]['submit_time']) : null,
        enactmentEndTime: proposals[i]['enactment_end_time'] != null ? DateTime.parse(proposals[i]['enactment_end_time']) : null,
        votingEndTime: proposals[i]['voting_end_time'] != null ? DateTime.parse(proposals[i]['voting_end_time']) : null,
        result: proposals[i]['result'] ?? "VOTE_PENDING",
        content: ProposalContent.parse(proposals[i]['content']),
      );
      proposalList.add(proposal);
    }
    proposalList.sort((a, b) => a.proposalId.compareTo(b.proposalId));
    this.proposals = proposalList;
  }

  Future<void> voteProposal(String proposalId, int type) async {
    String apiUrl = await loadInterxURL();
    var data = await http.post(apiUrl + "/kira/gov/proposals/$proposalId");
  }
}
