import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kira_auth/models/export.dart';
import 'package:kira_auth/config.dart';
import 'package:kira_auth/utils/export.dart';

class ProposalService {
  List<Proposal> proposals = [];

  Future<void> getProposals({String account = ''}) async {
    this.proposals = [];
    List<Proposal> proposalList = [];

    var apiUrl = await loadInterxURL();
    var data = await http.get(apiUrl[0] + "/kira/gov/proposals",
        headers: {'Access-Control-Allow-Origin': apiUrl[1]});

    var bodyData = json.decode(data.body);
    if (!bodyData.containsKey('proposals')) return;
    var proposals = bodyData['proposals'];

    for (int i = 0; i < proposals.length; i++) {
      Proposal proposal = Proposal(
        proposalId: proposals[i]['proposal_id'],
        description: proposals[i]['description'],
        submitTime: proposals[i]['submit_time'] != null ? DateTime.parse(proposals[i]['submit_time']) : null,
        enactmentEndTime:
            proposals[i]['enactment_end_time'] != null ? DateTime.parse(proposals[i]['enactment_end_time']) : null,
        votingEndTime: proposals[i]['voting_end_time'] != null ? DateTime.parse(proposals[i]['voting_end_time']) : null,
        result: proposals[i]['result'] ?? "VOTE_RESULT_UNKNOWN",
        content: ProposalContent.parse(proposals[i]['content']),
      );
      proposal.voteability = await checkVoteability(proposal.proposalId, account);
      proposal.voteResults = await getVoteResult(proposal.proposalId);
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
    var apiUrl = await loadInterxURL();
    var data = await http.get(apiUrl[0] + "/kira/gov/voters/$proposalId",
        headers: {'Access-Control-Allow-Origin': apiUrl[1]});

    var bodyData = json.decode(data.body);
    var actors = bodyData as List<dynamic>;
    var selfActor = actors.firstWhere((voter) => (voter as Map<String, dynamic>)['address'] == account, orElse: () => null);
    return parse(selfActor, actors.length);
  }

  Voteability parse(dynamic jsonData, int count) {
    List<VoteOption> options = [];
    if (jsonData == null) {
      return Voteability(voteOptions: [], whitelistPermissions: [], blacklistPermissions: [], count: count);
    }
    var data = jsonData as Map<String, dynamic>;
    if (data.containsKey("votes")) {
      (data['votes'] as List<dynamic>).forEach((item) {
        options.add(VoteOption.values[Strings.voteOptions.indexOf(item) + 1]);
      });
    }
    var whitelist = (jsonData['permissions']['whitelist'] as List<dynamic>).map((e) => e.toString()).toList();
    var blacklist = (jsonData['permissions']['blacklist'] as List<dynamic>).map((e) => e.toString()).toList();
    return Voteability(voteOptions: options, whitelistPermissions: whitelist, blacklistPermissions: blacklist, count: count);
  }

  Future<Map> getVoteResult(String proposalId) async {
    var apiUrl = await loadInterxURL();
    var data = await http.get(apiUrl[0] + "/kira/gov/votes/$proposalId",
        headers: {'Access-Control-Allow-Origin': apiUrl[1]});

    var bodyData = json.decode(data.body);
    var votes = bodyData as List<dynamic>;
    var counts = new Map<String, double>();
    votes.forEach((element) {
      var index = Strings.voteOptions.indexOf((element as Map<String, dynamic>)['option']) + 1;
      counts[Strings.voteTitles[index]]++;
    });
    /// For testing, dummy vote results TODO - Delete
    counts["Yes"] = 3;
    counts["No"] = 1;
    return counts;
  }
}
