// To parse this JSON data, do
//
//     final vipTypeBean = vipTypeBeanFromJson(jsonString);

import 'dart:convert';

VipTypeBean vipTypeBeanFromJson(String str) =>
    VipTypeBean.fromJson(json.decode(str));

String vipTypeBeanToJson(VipTypeBean data) => json.encode(data.toJson());

class VipTypeBean {
  String id;
  String appleVipId;
  String money;
  String? firstCheapMoney;
  String? crossedMoney;
  String des;
  String title;
  String? illustrate;
  int? isDefault;
  int? isAgreement;
  int? isOpenWeb;
  String? webDes;
  String? dayMoney;
  String? monthMoney;
  String? integralMoney; ///积分价格
  String? wordsPackMoney; ///字数包价格
  int? vipDialogStyle; ///新用户返回拦截弹窗样式
  DateTime? vipEndTime;
  int? day;
  int? isFirstFree;
  int? integral;
  int? wordsPack; ///套餐赠送字数
  String? subscribePeriodDes;
  int? isSubscribe;
  String? pagePath;
  String? subscribeMoney;
  int? subscribeIntegral;
  String? subscribeVipEndTime;
  int? vipLevel;
  int? vipListStyle;
  int? orderNum;
  String? buttonTitle;
  String? mark;
  String? originalPrice;
  int? giftWords;
  bool? isMostSelected;
  List<String>? showArea;
  String? localPrice;
  String? discountLocalPrice;
  String? localSymbol;
  List<String>? boldArea;

  VipTypeBean({
    required this.id,
    required this.appleVipId,
    required this.money,
    required this.firstCheapMoney,
    required this.crossedMoney,
    required this.des,
    required this.title,
    required this.illustrate,
    required this.isDefault,
    required this.isAgreement,
    required this.isOpenWeb,
    required this.webDes,
    required this.dayMoney,
    required this.monthMoney,
    required this.vipEndTime,
    required this.day,
    required this.isFirstFree,
    required this.integral,
    required this.wordsPack,
    required this.subscribePeriodDes,
    required this.isSubscribe,
    required this.pagePath,
    required this.subscribeMoney,
    required this.subscribeIntegral,
    required this.subscribeVipEndTime,
    required this.vipLevel,
    required this.vipListStyle,
    required this.orderNum,
    required this.buttonTitle,
    required this.mark,
    this.integralMoney,
    this.wordsPackMoney,
    this.originalPrice,
    this.giftWords,
    this.isMostSelected,
    this.vipDialogStyle,
    this.localPrice,
    this.discountLocalPrice,
    this.localSymbol,
    this.showArea,
    this.boldArea,
  });

  factory VipTypeBean.fromJson(Map<String, dynamic> json) => VipTypeBean(
        id: json["id"].toString(),
        appleVipId: json["apple_vip_id"],
        money: json["money"].toString(),
        firstCheapMoney: json["first_cheap_money"].toString(),
        crossedMoney: json["crossed_money"],
        des: json["des"],
        title: json["title"],
        illustrate: json["illustrate"],
        isDefault: json["is_default"],
        isAgreement: json["is_agreement"],
        isOpenWeb: json["is_open_web"],
        webDes: json["web_des"],
        dayMoney: json["day_money"],
        monthMoney: json["month_money"],
        integralMoney: json["integral_money"] ?? '',
        wordsPackMoney: json["words_pack_money"] ?? '',
        vipEndTime: DateTime.parse(json["vip_end_time"]),
        day: json["day"],
        isFirstFree: json["is_first_free"],
        integral: json["integral"],
        wordsPack: json['words_pack'],
        subscribePeriodDes: json["subscribe_period_des"],
        isSubscribe: json["is_subscribe"],
        pagePath: json["page_path"],
        subscribeMoney: json["subscribe_money"],
        subscribeIntegral: json["subscribe_integral"],
        subscribeVipEndTime: json["subscribe_vip_end_time"],
        vipLevel: json["vip_level"] ?? 0,
        vipListStyle: json["vip_list_style"],
        orderNum: json["order_num"],
        buttonTitle: json["button_title"],
        mark: json["mark"],
        originalPrice: json["original_price"],
        giftWords: json["gift_words"],
        vipDialogStyle: json['new_user_vip_list_style'] ?? 0,
        isMostSelected: json["is_most_selected"] == 1,
        showArea: json["show_area"] != null
            ? List<String>.from(json["show_area"].map((x) => x.toString()))
            : null,
        localPrice: json["local_price"] ?? '',
        discountLocalPrice: json["discount_local_price"] ?? '',
        localSymbol: json['local_symbol'] ?? '',
        boldArea: json["bold_area"] != null
            ? List<String>.from(json["bold_area"].map((x) => x.toString()))
            : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "apple_vip_id": appleVipId,
        "money": money,
        "first_cheap_money": firstCheapMoney,
        "crossed_money": crossedMoney,
        "des": des,
        "title": title,
        "illustrate": illustrate,
        "is_default": isDefault,
        "is_agreement": isAgreement,
        "is_open_web": isOpenWeb,
        "web_des": webDes,
        "day_money": dayMoney,
        "month_money": monthMoney,
        "vip_end_time": vipEndTime?.toIso8601String(),
        "day": day,
        "is_first_free": isFirstFree,
        "integral": integral,
        'words_pack': wordsPack,
        "subscribe_period_des": subscribePeriodDes,
        "is_subscribe": isSubscribe,
        "page_path": pagePath,
        "subscribe_money": subscribeMoney,
        "subscribe_integral": subscribeIntegral,
        "subscribe_vip_end_time": subscribeVipEndTime,
        "vip_level": vipLevel,
        "vip_list_style": vipListStyle,
        "order_num": orderNum,
        "button_title": buttonTitle,
        "mark": mark,
        "original_price": originalPrice,
        "gift_words": giftWords,
        "is_most_selected": isMostSelected == true ? 1 : 0,
        'new_user_vip_list_style': vipDialogStyle,
        'local_price': localPrice,
        'discount_local_price': discountLocalPrice,
        'local_symbol': localSymbol,
      };
}
