

class CreditsBean {
  String? datetime;
  String? itemDesc;
  int? wordsNum;
  String? createAt;
  int? userWords;

  CreditsBean({
    this.datetime,
    this.itemDesc,
    this.wordsNum,
    this.createAt,
    this.userWords,
  });

  factory CreditsBean.fromJson(Map<String, dynamic> json) {
    return CreditsBean(
      datetime: json['date'],
      itemDesc: json['des'],
      wordsNum: json['words'],
      createAt: json['created_at'],
      userWords: json['user_words'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'date': datetime,
      'des': itemDesc,  
      'words': wordsNum,
      'created_at': createAt,
      'user_words': userWords,
    };
  }
}