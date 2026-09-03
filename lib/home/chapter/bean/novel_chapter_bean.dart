/*
 * @Author: cold-x
 * @Date: 2025-06-25 17:37:37
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-07-14 11:30:15
 * @FilePath: /fastcreationmaster/lib/home/long_novel/bean/novel_chapter_bean.dart
 * @Description: 
 */



class ChapterBean {
  int? id; ///章节id
  int? novelID; ///小说id
  int? outlineID; ///大纲id
  String? title; ///章节标题
  String? streamURL; ///长链接地址
  int? index; ///章节顺序
  /*
    1=已提交章节概要任务
    2=章节概要生成中
    3=章节概要生成成功
    4=已提交章节内容任务
    5=章节内容生成中
    6=章节内容生成成功
    7=小说内容生成失败
    8=字数不够生成失败
    9=章节已暂停
   */
  int? stage; ///章节生成阶段
  String? createTime; ///创建时间
  String? introduce; ///当前章节介绍
  int? words; ///章节细纲预计字数
  int? predictWords; ///章节预计字数
  String? chapterStreamTaskID; ///章节细纲流式输出任务ID
  String? novelStreamTaskID; ///章节正文流式输出任务ID
  String? content; ///章节内容
  String? novelContent; ///章节内容
  bool? isFailed; ///细纲是否生成失败
  int? preID; ///前一章ID
  int? nextID; ///下一章ID
  int? nextStage; ///下一章状态

  ChapterBean({
    this.id,
    this.title,
    this.outlineID,
    this.novelID,
    this.streamURL,
    this.words,
    this.predictWords,
    this.index,
    this.createTime,
    this.stage,
    this.introduce,
    this.chapterStreamTaskID,
    this.novelStreamTaskID,
    this.content,
    this.novelContent,
    this.isFailed,
    this.nextID,
    this.preID,
    this.nextStage,
  });

  factory ChapterBean.fromJson(Map<String, dynamic> json) {
    return ChapterBean(
      id: json['id'],
      outlineID: json['outline_id'],
      title: json['chapter_overview_title'] ?? '',
      novelID: json['ai_novel_id'],
      streamURL: json['content_overview_ws_url'] ?? json['chapter_overview_ws_url'],
      words: json['chapter_content_words'],
      predictWords: json['chapter_content_pre_deduct_wp'],
      index: json['index'],
      createTime: json['created_at'] != null ? json['created_at'].split(' ')[0] : '',
      stage: json['stage'] ?? 6,
      introduce: json['introduce'],
      chapterStreamTaskID: json['outline_to_chapter_overview_task_id'] ?? '',
      novelStreamTaskID: json['chapter_content_task_id'] ?? '',
      content: json['chapter_overview_content'] ?? '',
      novelContent: json['chapter_content'] ??'',
      isFailed: json['is_failed'] ?? false,
      preID: json['pre_id'],
      nextID: json['next_id'],
      nextStage: json['next_stage'] ?? 6,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'outline_id': outlineID,
      'chapter_overview_title': title,
      'ai_novel_id': novelID,
      'content_overview_ws_url': streamURL,
      'chapter_content_words': words,
      'chapter_content_pre_deduct_wp': predictWords,
      'index': index,
      'created_at': createTime,
      'stage': stage,
      'introduce': introduce,
      'outline_to_chapter_overview_task_id': chapterStreamTaskID,
      'chapter_content_task_id': novelStreamTaskID,
      'chapter_overview_content': content,
      'chapter_content': novelContent,
      'is_failed': isFailed,
      'pre_id': preID,
      'next_id': nextID,
      'next_stage': nextStage
    };
  }
}