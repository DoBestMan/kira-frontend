class Strings {
  static const String kiraNetwork = "KIRA Network";
  static const String password = "Password";
  static const String confirmPassword = "Confirm Password";
  static const String accountName = "Account Name";
  static const String login = "Log In";
  static const String logout = "Log Out";
  static const String update = "Update";
  static const String account = "Account";
  static const String deposit = "Deposit";
  static const String withdraw = "Withdraw";
  static const String withdrawal = "Withdrawal";
  static const String depositTransactions = "Deposit Transactions";
  static const String withdrawalTransactions = "Withdrawal Transactions";
  static const String faucetTokens = "Faucet Tokens";
  static const String faucet = "Faucet";
  static const String tokens = "Tokens";
  static const String tokenForFeePayment = "Token For Fee Payment";
  static const String networkStatus = "Network Status";
  static const String customNetwork = "Custom Network";

  static const String search = "Search";
  static const String validators = "Validators";
  static const String blocks = "Latest Blocks";
  static const String network = "Network";
  static const String proposals = "Proposals";
  static const String vote = "Vote";
  static const String cancel = "Cancel";

  static const List<String> navItemTitles = ["Account", "Deposit", "Withdraw", "Network", "Proposals", "Settings"];
  static const String settings = "Settings";
  static const String depositAddress = "Deposit Address";
  static const String withdrawalAddress = "Withdrawal Address";
  static const String passwordExpresIn = "Password expires in (minutes)";
  static const String feeAmount = "Fee Amount";
  static const String rpcURL = "Custom RPC URL";
  static const String availableNetworks = "Available Networks";
  static const String availableAccounts = "Available Accounts";
  static const String memo = "Memo";
  static const String showMnemonic = "Show mnemonic";
  static const String hideMnemonic = "Hide mnemonic";
  static const String currentAccount = "Current account";
  static const String createNewAccount = "Create New Account";
  static const String loginWithMnemonic = "Log in with Mnemonic";
  static const String loginWithKeyFile = "Log in with Key File";

  static const String mnemonicWords = "Mnemonic Words";
  static const String withdrawalAmount = "Amount";
  static const String keyfile = "Key File";
  static const String exportToKeyFile = "Export to Key File";
  static const String import = "Import";
  static const String connect = "Connect";
  static const String copy = "Copy";
  static const String copied = "Copied";
  static const String edit = "Edit";
  static const String finish = "Finish Editing";
  static const String remove = "Remove";
  static const String backToLogin = "Back to Login";
  static const String back = "Back";
  static const String next = "Next";
  static const String generate = "Generate";
  static const String generateAgain = "Generate Again";
  static const String close = "Close";
  static const String select = "Select";
  static const String yes = "Yes";
  static const String no = "No";

  static const String insufficientBalance = "Insufficient balance for this account";
  static const String copyRight = "Copyright @ 2021 KIRA Network";
  static const String passwordBlank = "Password cannot be empty";
  static const String passwordWrong = "Password is wrong";
  static const String passwordDontMatch = "Passwords do not match";
  static const String passwordLengthShort = "Password should be at least 5 letters long";
  static const String passwordConfirm = "Make sure that the passwords match";
  static const String createAccountDescription =
      "Your Public Address has been generated (you may generate additional accounts by clicking Generate Again). Please export and save your Keyfile, copy and store Menmonic words in a safe location. Once complete, please use the Back button to log into your new account.";
  static const String seedPhraseDescription =
      "Your seed phrase is the passsword to access your funds. It is crucial that you back it up and never share it with anyone. We strongly recommend you to store your seed phrase in a safe place now.";
  static const String publicAddress = "Public Address";
  static const String loginDescription = "Please type seed phrases separated by space";
  static const String createAccountError = "Please create an account first";
  static const String loginWithKeyfileDescription = "Please select a key file";
  static const String invalidWithdrawalAddress = "Please specify withdrawal address";
  static const String invalidWithdrawalAmount = "Withdrawal amount is not valid";
  static const String invalidKeyFile = "Please select a valid key file";
  static const String invalidUrl = "URL is not valid";
  static const String invalidExpireTime = "Invalid expire time. Integer only.";
  static const String invalidFeeAmount = "Invalid fee amount. Integer only.";
  static const String invalidCustomRpcURL = "Custom RPC URL should not be empty";
  static const String withdrawalAmountOutOrRange = "Withdrawal amount is out of range";
  static const String accountNameInvalid = "Account name is invalid";
  static const String txHashCopied = "Transaction hash copied";
  static const String senderAddressCopied = "Sender address copied";
  static const String publicAddressCopied = "Public address copied";
  static const String mnemonicWordsCopied = "Mnemonic words copied";
  static const String recipientAddressCopied = "Recipient address copied";
  static const String noAvailableNetworks = "No network";
  static const String networkDescription = "Please select one of the available networks";
  static const String removeAccountDescription = "Please select the account and remove it";
  static const String removeAccountConfirmation = "Are you sure to remove the selected account?";
  static const String editAccountName = "Edit the name of selected account";
  static const String noKeywordInput = "No keyword input";
  static const String invalidRequest = "Invalid request: Please check withdrawal address again";
  static const String transactionSuccess = "Transaction confirmed successfully";
  static const String transactionSubmitted = "Transaction submitted. Please wait...";
  static const String updateSuccess = "Successfully updated";
  static const String dropFile = "Please drop a key file here";
  static const String validatorQuery = "Search validators by address or moniker";
  static const String proposalQuery = "Search proposals by address";
  static const String blockTransactionQuery = "Search blocks or transactions by hash or height";
  static const String voteProposal = "Vote To This Proposal";
  static const String proposalDescription = "Please select one of the available vote options allowed";
  static const String invalidVote = "Invalid vote request: Please contact administrator";
  static const String voteSuccess = "Your vote submitted successfully";
  static const List<String> voteOptions = [
    "VOTE_OPTION_UNSPECIFIED", "VOTE_OPTION_YES", "VOTE_OPTION_ABSTAIN", "VOTE_OPTION_NO", "VOTE_OPTION_NO_WITH_VETO"
  ];
  static const List<String> voteResults = [
    "VOTE_RESULT_UNKNOWN", "VOTE_RESULT_PASSED", "VOTE_RESULT_REJECTED", "VOTE_RESULT_REJECTED_WITH_VETO",
    "VOTE_PENDING", "VOTE_RESULT_QUORUM_NOT_REACHED", "VOTE_RESULT_ENACTMENT"
  ];
  static const List<String> proposalTypes = [
    "/kira.gov.AssignPermissionProposal", "/kira.gov.SetNetworkPropertyProposal",
    "/kira.gov.UpsertDataRegistryProposal", "/kira.gov.SetPoorNetworkMessagesProposal",
    "/kira.staking.ProposalUnjailValidator", "/kira.gov.ProposalUpsertTokenAlias",
    "/kira.gov.ProposalUpsertTokenRates"
  ];
  static const List<String> permissionNames = [
    "Zero", " Set Permissions", "Claim Validator", "Claim Councilor", "Create Set Permissions Proposal",
    "Vote Set Permissions Proposal", "Upsert Token Alias", "Change Transaction Fee", "Upsert Token Rate",
    "Upsert Role", "Upsert Data Registry Proposal", "Vote Upsert Data Registry Proposal",
    "Create Set Network Property Proposal", "Vote Set Network Property Proposal",
    "Create Upsert Token Alias Proposal", "Create Set Poor Network Messages Proposal",
    "Vote Upsert Token Alias Proposal", "Create Upsert Token Rate Proposal",
    "Vote Upsert Token Rate Proposal", "Vote Set Poor Network Messages Proposal",
    "Create Unjail Validator Proposal"
  ];
  static const List<String> permissionValues = [
    "PERMISSION_ZERO", "PERMISSION_SET_PERMISSIONS", "PERMISSION_CLAIM_VALIDATOR",
    "PERMISSION_CLAIM_COUNCILOR", "PERMISSION_CREATE_SET_PERMISSIONS_PROPOSAL",
    "PERMISSION_VOTE_SET_PERMISSIONS_PROPOSAL", "PERMISSION_UPSERT_TOKEN_ALIAS",
    "PERMISSION_CHANGE_TX_FEE", "PERMISSION_UPSERT_TOKEN_RATE", "PERMISSION_UPSERT_ROLE",
    "PERMISSION_UPSERT_DATA_REGISTRY_PROPOSAL", "PERMISSION_VOTE_UPSERT_DATA_REGISTRY_PROPOSAL",
    "PERMISSION_CREATE_SET_NETWORK_PROPERTY_PROPOSAL", "PERMISSION_VOTE_SET_NETWORK_PROPERTY_PROPOSAL",
    "PERMISSION_CREATE_UPSERT_TOKEN_ALIAS_PROPOSAL", "PERMISSION_CREATE_SET_POOR_NETWORK_MESSAGES",
    "PERMISSION_VOTE_UPSERT_TOKEN_ALIAS_PROPOSAL", "PERMISSION_CREATE_UPSERT_TOKEN_RATE_PROPOSAL",
    "PERMISSION_VOTE_UPSERT_TOKEN_RATE_PROPOSAL", "PERMISSION_VOTE_SET_POOR_NETWORK_MESSAGES_PROPOSAL",
    "PERMISSION_CREATE_UNJAIL_VALIDATOR_PROPOSAL",
  ];

  // Image Assets
  static const String logoImage = "assets/images/kira_logo.png";
  static const String logoQRImage = "assets/images/kira_qr_logo.png";
  static const String grayLogoImage = "assets/images/kira_logo_gray.png";
  static const String backgroundImage = "assets/images/background.png";
  static const String keyImage = 'assets/images/key.png';
}
