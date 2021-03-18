import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kira_auth/models/export.dart';
import 'package:kira_auth/config.dart';
import 'package:kira_auth/utils/export.dart';

class ProposalService {
  List<Proposal> proposals = [];

  Future<void> getProposals({int proposalId = 0, String account = ''}) async {
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
        result: proposals[i]['result'] ?? "VOTE_RESULT_UNKNOWN",
        content: ProposalContent.parse(proposals[i]['content']),
      );
      proposal.voteability = await checkVoteability(proposal.proposalId, account);
      proposalList.add(proposal);
    }
    final now = DateTime.now();
    var voteables = proposalList.where((p) => p.votingEndTime.difference(now).inSeconds > 0).toList();
    var nonvoteables = proposalList.where((p) => p.votingEndTime.difference(now).inSeconds <= 0).toList();
    voteables.sort((a, b) => b.votingEndTime.compareTo(a.votingEndTime));
    nonvoteables.sort((a, b) => b.enactmentEndTime.compareTo(a.enactmentEndTime));
    voteables.addAll(nonvoteables);
    this.proposals.addAll(voteables);
  }

  Future<Voteability> checkVoteability(String proposalId, String account) async {
    String apiUrl = await loadInterxURL();
    var data = await http.get(apiUrl + "/kira/gov/voters/$proposalId");

    var bodyData = json.decode(data.body);
    var jsonData = (bodyData as List<dynamic>)
        .firstWhere((voter) => (voter as Map<String, dynamic>)['address'] == account, orElse: () => null);
    return parse(jsonData);
  }

  Voteability parse(Map<String, dynamic> jsonData) {
    List<VoteOption> options = [];
    if (jsonData.containsKey("votes")) {
      (jsonData['votes'] as List<dynamic>).forEach((item) {
        var index = Strings.voteOptions.indexOf(item);
        options.add(
            index < 0 ? VoteOption.UNSPECIFIED : VoteOption.values[index]);
      });
    }
    var whitelist = (jsonData['permissions']['whitelist'] as List<dynamic>).map((e) => e.toString()).toList();
    var blacklist = (jsonData['permissions']['blacklist'] as List<dynamic>).map((e) => e.toString()).toList();
    return Voteability(voteOptions: options, whitelistPermissions: whitelist, blacklistPermissions: blacklist);
  }

  Future<void> voteProposal(String proposalId, int type) async {
    String apiUrl = await loadInterxURL();
    await http.post(apiUrl + "/kira/gov/proposals/$proposalId");
  }
}
