import 'dart:convert';
// import 'dart:ui';
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
        address: proposals[i]['address'],
        valkey: proposals[i]['valkey'],
        pubkey: proposals[i]['pubkey'],
        moniker: proposals[i]['moniker'],
        website: proposals[i]['website'] ?? "",
        social: proposals[i]['social'] ?? "",
        identity: proposals[i]['identity'] ?? "",
        commission: double.parse(proposals[i]['commission'] ?? "0"),
        status: proposals[i]['status'],
        rank: proposals[i]['rank'] ?? 0,
        streak: proposals[i]['streak'] ?? 0,
        mischance: proposals[i]['mischance'] ?? 0,
      );
      proposalList.add(proposal);
    }
    proposalList.sort((a, b) => a.rank.compareTo(b.rank));
    this.proposals = proposalList;
  }
}
