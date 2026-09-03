/*
 * @Author: duncy
 * @Date: 2025-09-25 10:13:17
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-09-25 10:13:29
 * @FilePath: /novel_oversea/lib/home/core/bean/words_bean.dart
 * @Description: 
 */



class WordsBean {
  int? total; ///小说总字数
  int? brief; ///小说灵感字数
  int? outline; ///单一大纲字数
  int? outlineTotal; ///大纲总字数
  int? chapter; ///单一细纲字数
  int? chapterTotal; ///细纲总字数
  int? novel; ///单一正文字数
  int? novelTotal; ///正文总字数
  int? introduce; ///小说简介
  int? briefThinking; ///灵感思考字数

  WordsBean({
    this.total,
    this.brief,
    this.outline,
    this.novelTotal,
    this.outlineTotal,
    this.chapterTotal,
    this.chapter,
    this.novel,
    this.introduce,
    this.briefThinking,
  });

  factory WordsBean.fromJson(Map<String, dynamic> json) {
    return WordsBean(
      total: json['tw'] ?? 0,
      brief: json['iw'] ?? 0,
      outline: json['bow'] ?? 0,
      novelTotal: json['ctw'] ?? 0,
      outlineTotal: json['botw'] ?? 0,
      chapterTotal: json['otw'] ?? 0,
      chapter: json['ow'] ?? 0,
      novel: json['cw'] ?? 0,
      introduce: json['inw'] ?? 0,
      briefThinking: json['itw'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'tw': total,
      'iw': brief,
      'bow': outline,
      'ctw': novelTotal,
      'botw': outlineTotal,
      'otw': chapterTotal,
      'ow': chapter,
      'cw': novel,
      'inw': introduce,
      'itw': briefThinking,
    };
  }
}