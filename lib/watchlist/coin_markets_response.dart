class CoinMarketsResponse {
  List<Data> data;
  int timestamp;

  CoinMarketsResponse({this.data, this.timestamp});

  CoinMarketsResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = new List<Data>();
      json['data'].forEach((v) {
        data.add(new Data.fromJson(v));
      });
    }
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    data['timestamp'] = this.timestamp;
    return data;
  }
}

class Data {
  String exchangeId;
  String baseId;
  String quoteId;
  String baseSymbol;
  String quoteSymbol;
  String volumeUsd24Hr;
  String priceUsd;
  String volumePercent;

  Data(
      {this.exchangeId,
      this.baseId,
      this.quoteId,
      this.baseSymbol,
      this.quoteSymbol,
      this.volumeUsd24Hr,
      this.priceUsd,
      this.volumePercent});

  Data.fromJson(Map<String, dynamic> json) {
    exchangeId = json['exchangeId'];
    baseId = json['baseId'];
    quoteId = json['quoteId'];
    baseSymbol = json['baseSymbol'];
    quoteSymbol = json['quoteSymbol'];
    volumeUsd24Hr = json['volumeUsd24Hr'];
    priceUsd = json['priceUsd'];
    volumePercent = json['volumePercent'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['exchangeId'] = this.exchangeId;
    data['baseId'] = this.baseId;
    data['quoteId'] = this.quoteId;
    data['baseSymbol'] = this.baseSymbol;
    data['quoteSymbol'] = this.quoteSymbol;
    data['volumeUsd24Hr'] = this.volumeUsd24Hr;
    data['priceUsd'] = this.priceUsd;
    data['volumePercent'] = this.volumePercent;
    return data;
  }
}
