

class NovelCreateBean {
  int? id; ///id
  String? key; ///模块标识，用于提交任务时使用的唯一标识
  String? name; ///模块名称

  /* type 字段
    类型，有text，textarea，number，radio，checkbox，radio_array,checkbox_array
    text : 短文本类型
    textarea : 长文本类型
    number : 数字类型
    radio : 单选类型
    checkbox : 复选框类型
    radio_array : 有下级分类的多选，意思就是当前分组下面有多个子分组，但是多个子分组中的选项对于父级分组来说是单选，就是说A子分组选择了，就不能选择B子分组，选了B子分组，就不能选A子分组
    checkbox_array : 和radio_array类似，只是说既可以选择A子分组，也可以选择B子分组
    radio_array和checkbox_array分组下面的子分组，可以是text，textarea，number，radio，checkbox中的任何一种
  */
  String? type;

  /*
    style字段
    风格样式

    text ：
    1 ： 文本框默认样式
    textarea
    11 ：多行文本框默认样式
    number
    21 ： 数字输入框默认样式
    22 ： "数字输入框样式 - 带加减按钮
    radio
    31 ：单选按钮默认样式 - 圆形
    32 ：单选按钮默认样式 - 标签
    checkbox
    41 ： 复选框默认样式 - 方框勾选
    42 ： 复选框默认样式 - 标签
    radio_array
    51 ： 单选组样式 - 默认
    checkbox_array
    61 ： 复选组样式 - 默认
  */
  int? style; ///创建样式
  
  /*
    min 字段
    最小长度或值
    如果type=text或者textarea，则表示最小输入字数，
    type=number表示最小数字，
    type=radio或checkbox表示最少选择的选项，但是=radio的时候固定为1，
    type=radio_array或者checkbox_array表示最少可以选择的子分组数量，如果为radio_array的时候固定为1
  */
  int? min; //最小长度或值

  /*
    max 字段
    和min字段相反，但是当type=radio或者radio_array的时候固定为1
  */
  int? max; //最大长度或值
  String? placeholder; ///提示词
  String? normal; ///默认值
  Map<String, dynamic>? items; ///子标签
  List<NovelCreateBean>? modules; ///子模块
  int? isAddition; ///内容是否可以动态添加的字段
  int? isRequire; ///是否必须字段
  dynamic selectedValue; //当前选择的值

  NovelCreateBean ({
    this.id,
    this.key,
    this.name,
    this.type,
    this.style,
    this.min,
    this.max,
    this.placeholder,
    this.normal,
    this.items,
    this.modules,
    this.isAddition,
    this.isRequire,
    this.selectedValue,
  });
  

  factory NovelCreateBean.fromJson(Map<String, dynamic> json) {
    dynamic itemMap = json['items'];
    if (itemMap is List){
      itemMap =  <String, String>{};
    }
    return NovelCreateBean(
      id: json['id'],
      key: json['key'],
      name: json['name'],
      type: json['type'],
      style: json['style'],
      min: json['min'],
      max: json['max'],
      placeholder: json['placeholder'],
      normal: '${json['default']}',
      isAddition: json['is_addition'],
      isRequire: json['is_require'],
      items: itemMap,
      modules: json["children"] == null
            ? []
            : List<NovelCreateBean>.from(json['children'].map(
            (ele) => NovelCreateBean.fromJson(ele))
            )
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'name': name,
      'type': type,
      'max': max,
      'style': style,
      'min': min,
      'placeholder': placeholder,
      'default': normal,
      'is_addition': isAddition,
      'is_require': isRequire,
      "items": items,
      "children": modules == null ? [] : List<dynamic>.from(modules!.map((x) => x)),
    };
  }

}