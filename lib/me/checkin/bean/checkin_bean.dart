/*
 * @Author: duncy
 * @Date: 2026-01-28 14:53:20
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-02-09 14:05:11
 * @FilePath: /novel_oversea/lib/me/checkin/bean/checkin_bean.dart
 * @Description: 
 */


class CheckinTaskBean {
  int id;
  String? type;
  String? name;
  String? desc;
  String? rewardsType;
  int? rewardsValue;
  String? icon;
  int? status;
  int? progress;
  int? maxProgress;
  int? completeCount;
  int? claimStatus;
  CheckinTaskConfig? config;
  CheckinFrequency? frequency;

  CheckinTaskBean({
    required this.id,
    this.type,
    this.name,
    this.desc,
    this.rewardsType,
    this.rewardsValue,
    this.icon,
    this.status,
    this.progress,
    this.maxProgress,
    this.completeCount,
    this.claimStatus,
    this.config,
    this.frequency
  });

  factory CheckinTaskBean.fromJson(Map<String, dynamic> json) {
    return CheckinTaskBean(
      id: json['id'],
      type: json['task_type'],
      name: json['task_name'],
      desc: json['task_desc'],
      rewardsType: json['rewards_type'],
      rewardsValue: json['reward_value'],
      icon: json['task_icon'],
      status: json['status'],
      progress: json['progress'],
      maxProgress: json['max_progress'],
      completeCount: json['complete_count'],
      claimStatus: json['claim_status'],
      config: CheckinTaskConfig.fromJson(json['task_config']),
      frequency: CheckinFrequency.fromJson(json['frequency']),
    );
  }
}

class CheckinTaskConfig {
  int? cycleDays;
  List <dynamic>? rewards;
  int? rewardWords;

  CheckinTaskConfig({
    this.cycleDays,
    this.rewards,
    this.rewardWords
  });

  factory CheckinTaskConfig.fromJson(Map<String, dynamic> json) {
    return CheckinTaskConfig(
      cycleDays: json['cycle_days'],
      rewardWords: json['reward_words'],
      rewards: (json['rewards'] ?? []).map((e) => CheckinRewards.fromJson(e)).toList(),
    );
  }
}

class CheckinRewards {
  int reward;
  bool claim;
  String name;

  CheckinRewards({
    required this.reward,
    required this.claim,
    required this.name,
  });

  factory CheckinRewards.fromJson(Map<String, dynamic> json) {
    return CheckinRewards(
      reward: json['reward'],
      claim: json['claim_status'] != 1,
      name: json['name'],
    );
  }
}

class CheckinFrequency {
  String? type;
  int? limit;

  CheckinFrequency({
    this.limit,
    this.type
  });

  factory CheckinFrequency.fromJson(Map<String, dynamic> json) {
    return CheckinFrequency(
      type: json['type'],
      limit: json['limit'],
    );
  }
}

class CheckinStats {
  bool? signed;
  int? currentStreak;

  CheckinStats({
    this.currentStreak,
    this.signed
  });

  factory CheckinStats.fromJson(Map<String, dynamic> json) {
    return CheckinStats(
      signed: json['has_signed_today'] ?? false,
      currentStreak: json['current_streak'],
    );
  }
}