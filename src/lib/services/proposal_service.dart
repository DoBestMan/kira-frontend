import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kira_auth/models/export.dart';
import 'package:kira_auth/config.dart';

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
        enactmentEndTime:
            proposals[i]['enactment_end_time'] != null ? DateTime.parse(proposals[i]['enactment_end_time']) : null,
        votingEndTime: proposals[i]['voting_end_time'] != null ? DateTime.parse(proposals[i]['voting_end_time']) : null,
        result: proposals[i]['result'] ?? "VOTE_PENDING",
        content: ProposalContent.parse(proposals[i]['content']),
      );
      proposal.voteOptions.addAll(await checkVoteability(proposal.proposalId, account));
      proposalList.add(proposal);
    }
    final now = DateTime.now();
    proposalList.sort((a, b) => a.votingEndTime
        .difference(now)
        .compareTo(b.votingEndTime.difference(now))
        .compareTo(a.proposalId.compareTo(b.proposalId)));
    this.proposals = proposalList;
  }

  Future<List<VoteType>> checkVoteability(String proposalId, String account) async {
    String apiUrl = await loadInterxURL();
    var data = await http.get(apiUrl + "/kira/gov/voters/$proposalId");

    var bodyData = json.decode(data.body);
    var voteability = (bodyData as List<dynamic>)
        .firstWhere((voter) => (voter as Map<String, dynamic>)['address'] == account, orElse: () => null);
    return parse(voteability == null ? List.empty() : voteability['votes']);
  }

  List<VoteType> parse(List<String> items) {
    List<VoteType> types = [];
    items.forEach((item) {
      var type;
      switch (item) {
        case "VOTE_OPTION_YES":
          type = VoteType.YES;
          break;
        case "VOTE_OPTION_ABSTAIN":
          type = VoteType.ABSTAIN;
          break;
        case "VOTE_OPTION_NO":
          type = VoteType.NO;
          break;
        case "VOTE_OPTION_NO_WITH_VETO":
          type = VoteType.NO_WITH_VETO;
          break;
        default:
          type = VoteType.UNSPECIFIED;
          break;
      }
      types.add(type);
    });
    if (types.isEmpty) {
      types.add(VoteType.YES);
      types.add(VoteType.ABSTAIN);
      types.add(VoteType.NO);
    }
    return types;
  }

  Future<void> voteProposal(String proposalId, int type) async {
    String apiUrl = await loadInterxURL();
    await http.post(apiUrl + "/kira/gov/proposals/$proposalId");
  }
}
