class TokenHistory {
  Data data;
  bool error;
  Null errorMessage;
  Null errorCode;

  TokenHistory({this.data, this.error, this.errorMessage, this.errorCode});

  TokenHistory.fromJson(Map<String, dynamic> json, String contractAddress) {
    data = json['data'] != null
        ? new Data.fromJson(json['data'], contractAddress)
        : null;
    error = json['error'];
    errorMessage = json['error_message'];
    errorCode = json['error_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    data['error'] = this.error;
    data['error_message'] = this.errorMessage;
    data['error_code'] = this.errorCode;
    return data;
  }
}

class Data {
  String address;
  String updatedAt;
  String nextUpdateAt;
  String quoteCurrency;
  int chainId;
  List<TransferInfo> transferInfo;
  Pagination pagination;

  Data(
      {this.address,
      this.updatedAt,
      this.nextUpdateAt,
      this.quoteCurrency,
      this.chainId,
      this.transferInfo,
      this.pagination});

  Data.fromJson(Map<String, dynamic> json, String contractAddress) {
    address = json['address'];
    updatedAt = json['updated_at'];
    nextUpdateAt = json['next_update_at'];
    quoteCurrency = json['quote_currency'];
    chainId = json['chain_id'];
    if (json['items'] != null) {
      transferInfo = new List<TransferInfo>();
      json['items'].forEach((v) {
        transferInfo.add(new TransferInfo.fromJson(v, contractAddress));
      });
    }
    pagination = json['pagination'] != null
        ? new Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address'] = this.address;
    data['updated_at'] = this.updatedAt;
    data['next_update_at'] = this.nextUpdateAt;
    data['quote_currency'] = this.quoteCurrency;
    data['chain_id'] = this.chainId;
    if (this.transferInfo != null) {
      data['items'] = this.transferInfo.map((v) => v.toJson()).toList();
    }
    if (this.pagination != null) {
      data['pagination'] = this.pagination.toJson();
    }
    return data;
  }
}

class TransferInfo {
  String blockSignedAt;
  String txHash;
  int txOffset;
  bool successful;
  String fromAddress;
  Null fromAddressLabel;
  String toAddress;
  Null toAddressLabel;
  String value;
  Null valueQuote;
  int gasOffered;
  int gasSpent;
  int gasPrice;
  double gasQuote;
  double gasQuoteRate;
  List<Transfers> transfers;

  TransferInfo(
      {this.blockSignedAt,
      this.txHash,
      this.txOffset,
      this.successful,
      this.fromAddress,
      this.fromAddressLabel,
      this.toAddress,
      this.toAddressLabel,
      this.value,
      this.valueQuote,
      this.gasOffered,
      this.gasSpent,
      this.gasPrice,
      this.gasQuote,
      this.gasQuoteRate,
      this.transfers});

  TransferInfo.fromJson(Map<String, dynamic> json, String contractAddress) {
    blockSignedAt = json['block_signed_at'];
    txHash = json['tx_hash'];
    txOffset = json['tx_offset'];
    successful = json['successful'];
    fromAddress = json['from_address'];
    fromAddressLabel = json['from_address_label'];
    toAddress = json['to_address'];
    toAddressLabel = json['to_address_label'];
    value = json['value'];
    valueQuote = json['value_quote'];
    gasOffered = json['gas_offered'];
    gasSpent = json['gas_spent'];
    gasPrice = json['gas_price'];
    gasQuote = json['gas_quote'];
    gasQuoteRate = json['gas_quote_rate'];
    if (json['log_events'] != null) {
      transfers = new List<Transfers>();
      json['log_events'].forEach((v) {
        if (v['sender_address'] == contractAddress &&
            v['decoded']['name'] == 'Transfer') {
          transfers.add(new Transfers.fromJson(v));
        }
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['block_signed_at'] = this.blockSignedAt;
    data['tx_hash'] = this.txHash;
    data['tx_offset'] = this.txOffset;
    data['successful'] = this.successful;
    data['from_address'] = this.fromAddress;
    data['from_address_label'] = this.fromAddressLabel;
    data['to_address'] = this.toAddress;
    data['to_address_label'] = this.toAddressLabel;
    data['value'] = this.value;
    data['value_quote'] = this.valueQuote;
    data['gas_offered'] = this.gasOffered;
    data['gas_spent'] = this.gasSpent;
    data['gas_price'] = this.gasPrice;
    data['gas_quote'] = this.gasQuote;
    data['gas_quote_rate'] = this.gasQuoteRate;
    if (this.transfers != null) {
      data['log_events'] = this.transfers.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Transfers {
  String blockSignedAt;
  int blockHeight;
  int txOffset;
  int logOffset;
  String txHash;
  Null nRawLogTopicsBytes;
  List<String> rawLogTopics;
  int senderContractDecimals;
  String senderName;
  String senderContractTickerSymbol;
  String senderAddress;
  Null senderAddressLabel;
  String senderLogoUrl;
  String rawLogData;
  Decoded decoded;

  Transfers(
      {this.blockSignedAt,
      this.blockHeight,
      this.txOffset,
      this.logOffset,
      this.txHash,
      this.nRawLogTopicsBytes,
      this.rawLogTopics,
      this.senderContractDecimals,
      this.senderName,
      this.senderContractTickerSymbol,
      this.senderAddress,
      this.senderAddressLabel,
      this.senderLogoUrl,
      this.rawLogData,
      this.decoded});

  Transfers.fromJson(Map<String, dynamic> json) {
    blockSignedAt = json['block_signed_at'];
    blockHeight = json['block_height'];
    txOffset = json['tx_offset'];
    logOffset = json['log_offset'];
    txHash = json['tx_hash'];
    nRawLogTopicsBytes = json['_raw_log_topics_bytes'];
    rawLogTopics = json['raw_log_topics'].cast<String>();
    senderContractDecimals = json['sender_contract_decimals'];
    senderName = json['sender_name'];
    senderContractTickerSymbol = json['sender_contract_ticker_symbol'];
    senderAddress = json['sender_address'];
    senderAddressLabel = json['sender_address_label'];
    senderLogoUrl = json['sender_logo_url'];
    rawLogData = json['raw_log_data'];
    decoded =
        json['decoded'] != null ? new Decoded.fromJson(json['decoded']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['block_signed_at'] = this.blockSignedAt;
    data['block_height'] = this.blockHeight;
    data['tx_offset'] = this.txOffset;
    data['log_offset'] = this.logOffset;
    data['tx_hash'] = this.txHash;
    data['_raw_log_topics_bytes'] = this.nRawLogTopicsBytes;
    data['raw_log_topics'] = this.rawLogTopics;
    data['sender_contract_decimals'] = this.senderContractDecimals;
    data['sender_name'] = this.senderName;
    data['sender_contract_ticker_symbol'] = this.senderContractTickerSymbol;
    data['sender_address'] = this.senderAddress;
    data['sender_address_label'] = this.senderAddressLabel;
    data['sender_logo_url'] = this.senderLogoUrl;
    data['raw_log_data'] = this.rawLogData;
    if (this.decoded != null) {
      data['decoded'] = this.decoded.toJson();
    }
    return data;
  }
}

class Decoded {
  String name;
  String signature;
  List<Params> params;

  Decoded({this.name, this.signature, this.params});

  Decoded.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    signature = json['signature'];
    if (json['params'] != null) {
      params = new List<Params>();
      json['params'].forEach((v) {
        params.add(new Params.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['signature'] = this.signature;
    if (this.params != null) {
      data['params'] = this.params.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Params {
  String name;
  String type;
  bool indexed;
  bool decoded;
  String value;

  Params({this.name, this.type, this.indexed, this.decoded, this.value});

  Params.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    type = json['type'];
    indexed = json['indexed'];
    decoded = json['decoded'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['type'] = this.type;
    data['indexed'] = this.indexed;
    data['decoded'] = this.decoded;
    data['value'] = this.value;
    return data;
  }
}

class Pagination {
  bool hasMore;
  int pageNumber;
  int pageSize;
  int totalCount;

  Pagination({this.hasMore, this.pageNumber, this.pageSize, this.totalCount});

  Pagination.fromJson(Map<String, dynamic> json) {
    hasMore = json['has_more'];
    pageNumber = json['page_number'];
    pageSize = json['page_size'];
    totalCount = json['total_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['has_more'] = this.hasMore;
    data['page_number'] = this.pageNumber;
    data['page_size'] = this.pageSize;
    data['total_count'] = this.totalCount;
    return data;
  }
}
