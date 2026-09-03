


class NovelBean {
  int? id; ///小说id
  String? title; ///小说标题
  String? streamTaskID; ///灵感输出任务ID
  String? streamURL; ///长链接地址
  String? contentStreamURL; ///正文长链接地址
  String? contentStreamTaskID; ///正文长链接任务ID
  int? index; ///顺序
  /*
  长文、短文
    1=已提交 
    2=灵感生成中
    3=灵感生成失败
    4=灵感生成完成
    5=大纲生成中
    6=大纲生成失败
    7=大纲生成成功 
    8=正文生成中【包含细纲生成，正文生成】
    9=暂停中  ///已废弃，用pauseStatus替换
    10=生成完成
  短故事
    1=已提交
    2=灵感生成中
    3=灵感生成失败
    4=灵感生成成功
    5=正文生成中
    6=正文生成失败
    7=正文生成成功
   */
  int? stage; ///小说生成阶段
  //细纲总阶段 1=未开始 | 2=生成中 | 3=等待中 | 4=有失败 | 5=已完结
  int? chapterStage; ///细纲生成阶段
  //正文总阶段 1=未开始 | 2=生成中 | 3=等待中 | 4=有失败 | 5=已完结
  int? contentStage; ///正文生成阶段
  String? createTime; ///创建时间
  int? chaptersNum; ///当前小说将会生成的章节数量
  int? words; ///小说字数
  int? realityWords; ///小说实际字数
  String? introduce; ///小说简介
  Map? params; ///小说提交时的参数
  List? tags; ///小说标签
  String? cover; ///封面图
  int? generateChapters; ///生成的章节数
  int? pauseStatus; ///暂停状态 1暂停 2未暂停 3暂停中
  int? continueWords; ///恢复生成小说时需要的字数
  String? func; ///小说类型，长文，短文，专业版，普通版

  NovelBean({
    this.id,
    this.title,
    this.streamURL,
    this.contentStreamTaskID,
    this.contentStreamURL,
    this.words,
    this.realityWords,
    this.index,
    this.createTime,
    this.stage,
    this.chapterStage,
    this.contentStage,
    this.chaptersNum,
    this.streamTaskID,
    this.introduce,
    this.params,
    this.tags,
    this.cover,
    this.generateChapters,
    this.pauseStatus,
    this.continueWords,
    this.func,
  });

  ///通用小说配置
  factory NovelBean.fromJson(Map<String, dynamic> json) {
    var introduce = '';
    try {introduce = json['details']['introduce'];}
    catch (e){introduce = '';}
    ///短故事小说章节切割
    int chapter = 0;
    try {chapter = int.parse(json['type'].split('_')[2]);}
    catch (e){chapter = 0;}

    ///标签
    var tags = [];
    try {tags = json['details']['tags'];}
    catch (e){tags = [];}
    return NovelBean(
      id: json['id'],
      title: json['title'] ?? '',
      streamURL: json['inspiration_ws_url'],
      contentStreamURL: json['content_ws_url'],
      contentStreamTaskID: json['content_task_id'],
      words: json['words'],
      index: json['index'],
      realityWords: json['reality_words'],
      createTime: json['created_at'],
      stage: json['stage'] ?? 10,
      chapterStage: json['chapter_overview_stage'],
      contentStage: json['content_stage'],
      chaptersNum: chapter == 0 ? json['sub_chapter_count'] : chapter,
      streamTaskID: json['inspiration_task_id'] ?? '',
      tags: tags,
      introduce:  introduce,
      pauseStatus: json['pause_status'],
      generateChapters: json['reality_chapter_count'] ?? 0,
      cover: json['cover'] ?? " ",
      continueWords: json['pause_release_num'] ?? 0,
      func: json["func"]
    );
  }

  ///创作广场配置
  factory NovelBean.fromSquareJson(Map<String, dynamic> json) {
    var introduce = '';
    try {introduce = json['details']['introduce'];}
    catch (e){introduce = '';}
    ///标签
    var tags = [];
    try {tags = json['details']['tags'];}
    catch (e){tags = [];}
    return NovelBean(
      id: json['id'],
      title: json['title'] ?? '',
      streamURL: json['inspiration_ws_url'],
      words: json['words'],
      realityWords: json['reality_words'],
      index: json['index'],
      createTime: json['created_at'],
      stage: json['stage'] ?? 10,
      chapterStage: json['chapter_overview_stage'],
      contentStage: json['content_stage'],
      chaptersNum: json['sub_chapter_count'],
      streamTaskID: json['inspiration_task_id'] ?? '',
      introduce:  introduce,
      tags: tags,
      params: json['details']['sub_params'] ?? {},
      generateChapters: json['reality_chapter_count'] ?? 0,
      pauseStatus: json['pause_status'],
      cover: json['cover'] ?? "",
      func: json['func'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'outline_ws_url': streamURL,
      'words': words,
      'reality_words': realityWords,
      'index': index,
      'created_at': createTime,
      'stage': stage,
      'chapter_overview_stage': chapterStage,
      'content_stage': contentStage,
      'sub_chapter_count': chaptersNum,
      'inspiration_task_id': streamTaskID,
      'introduce': introduce,
      'reality_chapter_count': generateChapters,
      'pause_status': pauseStatus,
      'cover': cover,
      'pause_release_num': continueWords,
       "func":func,
    };
  }
}


///引导页小说
class GuideNovelBean {
  int? id; ///引导小说id
  int? novelID; ///小说ID
  String? title; ///小说标题
  String? topPrompt; ///顶部提示词
  String? bottomPrompt; ///底部提示词
  int? platform; ///顺序 1=七猫 2=番茄
  String? briefContent; ///引导页小说灵感内容
  String? briefTitle; ///引导页小说灵感标题

  GuideNovelBean({
    this.id,
    this.novelID,
    this.title,
    this.topPrompt,
    this.bottomPrompt,
    this.platform,
    this.briefContent,
    this.briefTitle
  });

  factory GuideNovelBean.fromJson(Map<String, dynamic> json) {
    return GuideNovelBean(
      id: json['id'],
      title: json['title'] ?? '',
      novelID: json['novel_id'],
      topPrompt: json['prompt_top'],
      bottomPrompt: json['prompt_bottom'],
      platform: json['platform'],
      briefContent: json['inspiration_info']['inspiration'] ?? '',
      briefTitle: json['inspiration_info']['title'] ?? '',
    );
  }
}