


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/ui/dialog/toast.dart';
import 'package:novel_oversea/core/ui/view/by_text_field.dart';
import 'package:novel_oversea/core/ui/widget/by_text.dart';
import 'package:novel_oversea/core/util/clipboard.dart';
import 'package:novel_oversea/core/util/extentions.dart';
import 'package:novel_oversea/global/ui/colors.dart';
import 'package:novel_oversea/home/create/controller/novel_create_controller.dart';


enum InputType {
  number,  ///数字
  text,  ///文本
  longText, ///长文本
}

class NovelTextInputCell extends StatefulWidget {
  const NovelTextInputCell({
    super.key,
    this.title = '',
    this.max,
    this.min,
    this.type,
    this.hintText,
    this.normalValue = '',
    this.inputValueChanged,
    this.createAction,
  });

  final String? title; ///标题
  final int? max; ///最大字数
  final int? min; ///最小字数
  final InputType? type; ///类型
  final String? hintText; ///提示词
  final String? normalValue; ///初始值
  final Function(String)? inputValueChanged;
  final Function()? createAction; ///AI帮写

  @override
  State<NovelTextInputCell> createState() => _NovelTextInputCellState();
}

class _NovelTextInputCellState extends State<NovelTextInputCell> {
  
  final TextEditingController _controller = TextEditingController();
  String _normalText = '';
  ///输入框字数
  int _inputLength = 0;
  late TextSelection _currentSelection;
  // FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    _currentSelection = _controller.selection;
    _setText();
    super.initState();

    // 监听焦点变化
    // _focusNode.addListener(() {
    //   if(_focusNode.hasFocus){
    //   }
    //   else{
    //   }
    // });
  }

  @override
  void dispose() {
    // _focusNode.dispose(); // 释放资源
    super.dispose();
  }

  void _setText() {
    if (_normalText != widget.normalValue && widget.normalValue!.isNotEmpty) {
      _normalText = widget.normalValue!;
      ///苹果系统默认输入法的问题
      if(_controller.text != _normalText) {
        _controller.text = _normalText;
      }
      _inputLength = _controller.text.length;
      // 3. 恢复光标位置（处理边界情况：如果原位置超出新文本长度，就放在末尾）
      final newPosition = _currentSelection.baseOffset <= _normalText.length
          ? _currentSelection.baseOffset
          : _normalText.length;

      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: newPosition),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if(widget.type == InputType.longText)_setText();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 12.0.w,
        ),
        ByText.text(
            fontSize: 14, textColor: Colors.white, text: widget.title!),
        SizedBox(
          height: 8.0.w,
        ),

        ///输入框高度
        buildTextView(),
        SizedBox(
          height: 16.0.w,
        ),
      ],
    );
  }

  Widget buildTextView() {
    return Container(
      height: widget.type == InputType.longText ? 160.w : 44.w,
      width: double.infinity,
      decoration: BoxDecoration(
          color: ByColor.color2E3038,
          borderRadius: BorderRadius.circular(10.w)),
      child: Stack(
        children: [
          if (widget.type == InputType.longText)
            Positioned(
              left: 12.w,
              bottom: 0,
              height: 40.w,
              child: SizedBox(
                height: 40.w,
                width: 327.w,
                child: Row(
                  children: [
                    ByText.text(
                        fontSize: 12,
                        textColor: ByColor.colorF2,
                        text: '$_inputLength/${widget.max!}'),
                    if (_inputLength > 0)
                      GestureDetector(
                        onTap: () {
                          ClipboardManager.clip(_controller.text);
                        },
                        child: Container(
                          padding: EdgeInsets.only(left: 10.w),
                          child: Image.asset(
                            'assets/me/btn_profile_copy.png',
                            width: 12.w,
                            height: 12.w,),
                        ),
                      ),
                    if (_inputLength > 0)
                      GestureDetector(
                        onTap: () {
                          _controller.clear();
                          setState(() {
                            _inputLength = 0;
                            widget.inputValueChanged?.call('');
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          child: Image.asset(
                            'assets/home/novel/btn_text_clear.png',
                            width: 16.w,
                            height: 16.w,),
                        ),
                      ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        widget.createAction?.call();
                      },
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/home/novel/btn_novel_config_random.png',
                            width: 16.w,
                            height: 16.w,
                          ),
                          SizedBox(width: 4,),
                          ByText.text(
                            text: 'Random Generate',
                            textColor: ByColor.colorC1,
                            fontSize: 12.sp)
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 24.w,
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            left: 12.w,
            right: 12.w,
            top: widget.type == InputType.longText ? 13 : 0,
            bottom: widget.type == InputType.longText ? 40.w : 0,
            child: TextField(
              textAlignVertical: widget.type == InputType.longText
                  ? TextAlignVertical.top
                  : TextAlignVertical.center,
              selectionControls: MaterialTextSelectionControls(),
              maxLines: widget.type == InputType.longText ? null : 1,
              autofocus: false,
              // focusNode: _focusNode,
              scrollController: ScrollController(),
              keyboardType: widget.type == InputType.number
                  ? TextInputType.number
                  : TextInputType.text,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.normal,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                contentPadding: widget.type == InputType.longText ? EdgeInsets.zero : EdgeInsets.fromLTRB(0, 10.w, 0, 10.w),
                isCollapsed: true,
                border: InputBorder.none,
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.normal,
                  color: Colors.white.withAlphaValue(0.3),
                ),
                labelStyle: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.normal,
                  color: Colors.white,
                ),
              ),
              onChanged: (String value) {
                ///如果是数字类型，限制输入的最大长度
                if (widget.type == InputType.number) {
                  try {
                    int num = int.parse(_controller.text);
                    if (num < widget.min!) {
                      num = widget.min!;
                    } else if (num > widget.max!) {
                      num = widget.max!;
                    }
                    _controller.text = '$num';
                  } catch (e) {
                    _controller.text = '${widget.max!}';
                  }
                }

                ///如果是文本类型，限制输入的最大长度
                else if (widget.type == InputType.text ||
                    widget.type == InputType.longText) {
                  if (_controller.text.length > widget.max!) {
                    _controller.text =
                        _controller.text.substring(0, widget.max!);
                  }
                }
                // 1. 保存当前光标位置
                _currentSelection = _controller.selection;

                setState(() {
                  _inputLength = _controller.text.length;
                });

                ///更新输入内容
                widget.inputValueChanged?.call(value);
              },
              controller: _controller,
            ),
          ),
        ],
      ),
    );
  }
}

///章节选择
// ignore: must_be_immutable
class ChapterNumChooseCell extends StatefulWidget {
  ChapterNumChooseCell({
    super.key,
    this.title = 'chapter number',
    this.min = 0,
    this.max = 10,
    this.selectedValue,
    this.isPro = false,
    this.numChanged});

  final String? title; ///标题
  final Function(int)? numChanged;
  final int? min; ///最小数
  final int? max; ///最大数
  int? selectedValue;///当前选择的数量
  final bool isPro; ///是否是专业版

  @override
  State<ChapterNumChooseCell> createState() => _ChapterNumChooseCellState();
}

class _ChapterNumChooseCellState extends State<ChapterNumChooseCell> {

  ///当前选择的章节数
  int _chapterNum = 6;
  final FocusNode _focusNode = FocusNode();
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    // 监听焦点变化
    _focusNode.addListener(() {
      if(_focusNode.hasFocus){

      }
      else{
        handleEditText();
      }
    });
    controller = TextEditingController();
    _chapterNum = widget.selectedValue ?? widget.min!;
    controller.text = '$_chapterNum';
  }

  @override
  void dispose() {
    _focusNode.dispose(); // 释放资源
    super.dispose();
  }

  void handleEditText() {
    // try {
    //   int num = int.parse(controller.text);
    //   if (num < widget.min!) {
    //     num = widget.min!;
    //     Toast.showText(text: '${widget.title}最小为${widget.min}');
    //   } else if (num > widget.max!) {
    //     num = widget.max!;
    //     Toast.showText(text: '${widget.title}最大为${widget.max}');
    //   }
    //   controller.text = '$num';
    //   widget.selectedValue = num;
    //   setState(() {
    //     _chapterNum = num;
    //     widget.numChanged?.call(_chapterNum);
    //   });
    // } catch (e) {
    //   int num = widget.selectedValue!;
    //   controller.text = '$num';
    //   widget.selectedValue = num;
    //   setState(() {
    //     _chapterNum = num;
    //     widget.numChanged?.call(_chapterNum);
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    _chapterNum = widget.selectedValue ?? widget.min!;
    controller.text = '$_chapterNum';
    return SizedBox(
      height: 80.w,
      child: Column(
        children: [
          SizedBox(height: 8.w,),
          Row(
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: 155.w,
                ),
                child: ByText.text(
                    textColor: ByColor.colorF1, text: widget.title!),
              ),
              const Spacer(),
              ByText.text(
                  fontSize: 12.sp,
                  textColor: ByColor.colorF1.withAlphaValue(0.5),
                  // text: '(${widget.min}-${widget.max})'),
                  text: 'Up to ${widget.max}'),
            ],
          ),
          SizedBox(height: 8.w,),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  ///最小章节数
                  if (_chapterNum > widget.min!){
                    widget.selectedValue = widget.selectedValue! - 1;
                    setState(() {
                      _chapterNum --;
                      widget.numChanged?.call(_chapterNum);
                      controller.text = '$_chapterNum';
                    });
                  }
                },
                child: Image.asset(
                  'assets/home/novel/btn_novel_create_minus${_chapterNum == widget.min! ? '_disable' : ''}.png',
                  width: 32.w,
                  height: 32.w,
                ),
              ),
              SizedBox(
                width: 6.w,
              ),
              ///章节显示与输入
              Expanded(
                child: Container(
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: ByColor.color2E3038,
                    borderRadius: BorderRadius.circular(6.w),
                    border: Border.all(
                      width: 1.w,
                      color: const Color(0xFF4D4E56),
                    )
                  ),
                  child: ByTextField(
                    maxLength: 4,
                    align: TextAlign.center,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    // textColor: widget.isPro ? ByColor.colorPro : ByColor.colorC1,
                    textColor: ByColor.colorF1,
                    inputType: TextInputType.number,
                    controller: controller,
                    focusNode: _focusNode,
                    change: (p0) {
                      try {
                        int num = int.parse(p0);
                        _chapterNum = num;
                        widget.selectedValue = _chapterNum;
                        widget.numChanged?.call(_chapterNum);
                      } catch (e) {
                        // throw(e);
                      }
                    },
                  ),
                ),
              ),
              SizedBox(
                width: 6.w,
              ),
              GestureDetector(
                onTap: () {
                  ///最大章节数
                  FocusScope.of(context).unfocus();
                  if (_chapterNum < widget.max!){
                    widget.selectedValue = widget.selectedValue! + 1;
                    setState(() {
                      _chapterNum ++;
                      widget.numChanged?.call(_chapterNum);
                      controller.text = '$_chapterNum';
                    });
                  }
                },
                child: Image.asset(
                  'assets/home/novel/btn_novel_create_add${_chapterNum == widget.max! ? '_disable' : ''}.png',
                  width: 32.w,
                  height: 32.w,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

///角色cell
class RoleCreateCell extends StatefulWidget {
  const RoleCreateCell({
    super.key,
    this.title = 'Role One',
    this.changed,
    this.count = 1,
    this.selectedValue,
    this.textDesc = 'Enter role name',});

  ///标题
  final String? title;
  ///有变化时
  final Function(dynamic)? changed;
  ///标题
  final String? textDesc;
  ///数量
  final int? count;
  ///选择的值
  final List<dynamic>? selectedValue;

  @override
  State<RoleCreateCell> createState() => _RoleCreateCellState();
}

class _RoleCreateCellState extends State<RoleCreateCell> {

  ///当前选择的性别
  List currentIndex = [];
  ///参数
  List params = [];
  ///textfieldList
  List textControllers = [];

  @override
  void initState() {
    super.initState();
    
  }

  void updateParams() {
    params = [];
    currentIndex = [];
    ///默认
    for(int i = 0; i < widget.count!; i++) {
      Map role = widget.selectedValue![i];
      params.add(role);
      
      if(textControllers.length <= i) {
        textControllers.add(TextEditingController(text: role['name']));
      }
      else {
        TextEditingController tc = textControllers[i];
        tc.text = role['name'];
      }
      final sex = role['gender'].first;
      int index = sex == 'male' ? 0 : sex == 'female' ? 1 : 2;
      currentIndex.add(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    updateParams();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 12.w,
        ),
        ByText.text(
                textColor: ByColor.colorF1, text: widget.title!),
        SizedBox(
          height: 12.w,
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: widget.count,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index){
          return Padding(
            padding: EdgeInsets.only(top: index == 0 ? 0 : 6.w, bottom: 6.w),
            child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.w),
              color: ByColor.color2E3038,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 13.w),
              child: Column(
                children: [
                  Row(
                    children: [
                      ByText.text(
                        textColor: ByColor.colorF1, text: 'Gender：'),
                      SizedBox(width: 10.w,),
                      _buildCheckBox('male', 0, index),
                      SizedBox(width: 12.w,),
                      _buildCheckBox('female', 1, index),
                      SizedBox(width: 12.w,),
                      _buildCheckBox('generic', 2, index),
                    ],
                  ),
                  SizedBox(height: 12.w,),
                  Row(
                    children: [
                      ByText.text(
                        textColor: ByColor.colorF1, text: 'Name：'),
                      SizedBox(width: 10.w,),
                      Expanded(child: buildTextView(index)),
                    ],
                  )
                ],
              ),
            ),
                    ),
          );
        }),
        
        SizedBox(
          height: 12.w,
        ),
      ]
    );
  }

  ///输入框
  Widget buildTextView(int index) {
    final controller = textControllers[index];
    final role = params[index];
    return Container(
      height: 40.w,
      width: double.infinity,
      decoration: BoxDecoration(
          color: ByColor.colorBg3,
          borderRadius: BorderRadius.circular(10.w)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.w),
        child: TextField(
          selectionControls: MaterialTextSelectionControls(),
          maxLines: 1,
          autofocus: false,
          // focusNode: FocusNode(),
          scrollController: ScrollController(),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.zero,
            isCollapsed: true,
            border: InputBorder.none,
            hintText: widget.textDesc,
            hintStyle: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.normal,
              color: Colors.white.withAlphaValue(0.3),
            ),
            labelStyle: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.normal,
              color: Colors.white,
            ),
          ),
          onChanged: (String value) {
            ///如果是文本类型，限制输入的最大长度
            if(value.length > 12) {
              controller.text = value.substring(0, 12);
            }
            role['name'] = controller.text;
            widget.changed?.call(params);
          },
          controller: controller,
        ),
      ),
    );
  }

  ///性别选择
  Widget _buildCheckBox(String title, int index, int order) {
    return GestureDetector(
      onTap: () {
        final role = params[order];
        if (currentIndex[order] != index){
          setState(() {
            currentIndex[order] = index;
          });
          final sex = index == 0 ? 'male' : index == 1 ? 'female' : 'other';
          role['gender'] = [sex];
          widget.changed?.call(params);
        }
      },
      child: Container(
        constraints: BoxConstraints(
          minWidth: 40.w,
          minHeight: 24.w
        ),
        child: Row(
          children: [
            Image.asset(
             'assets/global/common/btn_checkbox_${currentIndex[order] == index ? "selected" :'normal'}.png',
              width: 12.w,
              height: 12.w,
            ),
            SizedBox(width: 4.w,),
            ByText.text(textColor: ByColor.colorF1, text: title),
          ],
        ),
      ),
    );
  }
}

///标签cell
// ignore: must_be_immutable
class TagsCreateCell extends StatefulWidget {
  TagsCreateCell({
    super.key,
    this.title = 'city',
    this.tags,
    this.selectMore = false,
    this.expanded = false,
    this.selectStrings,
    this.isPro = false,
    this.selectedItems});

  ///标题
  final String? title;
  ///标签
  final List<String>? tags;
  ///是否能多选
  final bool selectMore;
  ///选中回调
  final Function(List<String>)? selectStrings;
  ///是否默认展开
  final bool? expanded;
  ///是否是专业版
  final bool? isPro;

  ///选中的值
  ///如果有多个选中，则使用多个，根据item.isCheckBox判断
  List<String>? selectedItems = []; 

  @override
  State<TagsCreateCell> createState() => _TagsCreateCellState();
}

class _TagsCreateCellState extends State<TagsCreateCell> {


  ///是否需要收起标签
  bool expandedTags = false;

  ///显示更多的状态
  ///true表示收起状态，可展开
  ///false为展开装填，可收起
  bool _isMoreStatus = false;

  ///是否需要显示更多,标签超过最大高度时显示
  ///如果标签数量过多，超过最大高度时，显示展示更多按钮
  ///如果标签数量少于最大高度时，不显示展示更多按钮
  bool showMore = false;

  ///显示4行，最大高度
  final double _maxTagsHeigth = 182.w;

  late final List<String> tags;

  @override
  void initState() {
    super.initState();

    if(widget.tags!.isNotEmpty){
      tags = widget.tags!;
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          ///如果tag标签过多，超过设置的最大高度时，显示展示更多按钮
          if (renderBox.size.height - 90.w > _maxTagsHeigth) {
            setState(() {
              showMore = true;
              _isMoreStatus = true;
            });
          }
          setState(() {
            ///如果是默认展开，则设置为展开状态
            expandedTags = widget.expanded!;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              ///点击标题，展开与收起
              setState(() {
                expandedTags = !expandedTags;
              });
            },
            child: Row(
              children: [
                Expanded(
                  child: ByText.text(
                      textColor: ByColor.colorF1, text: widget.title!),
                ),
                Image.asset(
                        'assets/home/novel/btn_novel_create_tags_${!expandedTags ? 'expand' : 'normal'}.png',
                        width: 15.w,
                        height: 15.w,
                ),
              ],
            ),
          ),
          if (!expandedTags)
          SizedBox(
            height: 12.w,
          ),
          if (!expandedTags)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    constraints: _isMoreStatus ? BoxConstraints(
                      maxHeight: _maxTagsHeigth,
                    ) : const BoxConstraints(),
                    child: ClipRect(
                      child: Wrap(
                        spacing: 10.w, // 水平间距
                        runSpacing: 12.w, // 垂直间距
                        children: tags.map((text) {
                          return GestureDetector(
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              ///如果是单选
                              if (widget.selectMore == false) {
                                if (widget.selectedItems!.contains(text)) {
                                  // 如果是单选，且已经选中，则不允许重复选择
                                  return;
                                } else {
                                  // 如果是单选，替换元素
                                  setState(() {
                                    if (widget.selectedItems!.isEmpty){
                                      widget.selectedItems!.add(text);
                                      return;
                                    }
                                    widget.selectedItems![0] = text;
                                  });
                                  widget.selectStrings?.call(widget.selectedItems!);
                                }
                              }
      
                              ///多选
                              else {
                                if (widget.selectedItems!.contains(text)) {
                                  if (widget.selectedItems!.length == 1) {
                                    // 如果是多选，且只剩一个元素，则不允许删除
                                    Toast.showText(text: 'Please slect at least one tag');
                                    return;
                                  }
                                  setState(() {
                                    widget.selectedItems!.remove(text);
                                  });
                                  widget.selectStrings?.call(widget.selectedItems!);
                                } else {
                                  // // 如果是多选，添加元素
                                  // if (widget.selectedItems!.length >= widget.item.itemMaxSize!) {
                                  //   Toast.showText(text: '最多只能选择${widget.item.itemMaxSize}个标签');
                                  //   return;
                                  // }
                                  setState(() {
                                    widget.selectedItems!.add(text);
                                  });
                                  widget.selectStrings?.call(widget.selectedItems!);
                                }
                              }
                            },
                            child: _buildTextChip(text),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                if (showMore)
                SizedBox(
                  height: 12.w,
                ),
                if (showMore)
                GestureDetector(
                  onTap: () {
                    ///展示更多
                    setState(() {
                      _isMoreStatus = !_isMoreStatus;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ByText.text(
                          textColor: ByColor.colorF1, text: _isMoreStatus ? 'More' : 'Pick up', fontSize: 13.sp),
                      SizedBox(
                        width: 4.w,
                      ),
                      AnimatedRotation(
                        turns: _isMoreStatus ? 0 : 0.5,
                        duration: const Duration(milliseconds: 0),
                        child: Image.asset(
                          'assets/home/novel/btn_novel_create_tags_more.png',
                          width: 12.w,
                          height: 12.w,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
        ],
      ),
    );
  }

  ///单个标签组件
  Widget _buildTextChip(String text) {
    return Container(
      height: 36.w,
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.w),
      decoration: BoxDecoration(
          color: widget.selectedItems!.contains(text) ? Color(0xFF3E4450) : Color(0xFF2B2E37).withAlphaValue(0.7),
          borderRadius: BorderRadius.circular(8.w),
          // border: widget.selectedItems!.contains(text)
          //     ? Border.all(
          //         color:  widget.isPro! ? ByColor.colorPro : ByColor.colorC1,
          //         width: 1,
          //         style: BorderStyle.solid,
          //       )
          //     : Border.all(
          //         color: Colors.transparent,
          //         width: 1,
          //         style: BorderStyle.solid,
          //       )),
      ),
      child: ByText.text(
          // textColor: widget.selectedItems!.contains(text)
          //     ? widget.isPro! ? ByColor.colorPro : ByColor.colorC1
          //     : ByColor.colorF1,
          fontSize: 13.sp,
          text: text),
    );
  }
}

class CreateResultView extends StatefulWidget {
  const CreateResultView({super.key});

  @override
  State<CreateResultView> createState() => _CreateResultViewState();
}

class _CreateResultViewState extends State<CreateResultView> {

  final NovelCreateController controller = Get.find<NovelCreateController>();
  Rx<bool> isMoreStatus = true.obs;
  @override
  Widget build(BuildContext context) {
    return Obx(() => selectResultView());
  }

  ///选择结果页
  Widget selectResultView() {
    List<String> keys = controller.gettResultDataKeys();
    return Container(
      constraints: const BoxConstraints(maxWidth: double.infinity),
      decoration: BoxDecoration(
          color: ByColor.colorBg2,
          image: DecorationImage(
              alignment: Alignment.topCenter,
              image: AssetImage(
                  'assets/home/novel/icon_novel_result_bg_short.png')),
          borderRadius: BorderRadius.circular(10.w),
          border: Border(
              bottom: BorderSide(color: ByColor.color2E3038, width: 1.w),
              left: BorderSide(color: ByColor.color2E3038, width: 1.w),
              right: BorderSide(color: ByColor.color2E3038, width: 1.w))),
      // border: Border.all(color: ByColor.color2E3038, width: 1.w)),
      child: Padding(
          padding: EdgeInsets.all(12.0.w),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ByText.text(
                    text: 'Choose Result',
                    textColor: ByColor.colorF1,
                    fontSize: 16.sp),
                SizedBox(
                  height: 6.w,
                ),
                // ...controller.selectResult.entries.map((entry) => selectResultCell(entry.key, entry.value))
                for (int i = 0; i < (isMoreStatus.value && keys.length > 6 ? 6 : keys.length); i++)
                  selectResultCell(keys[i], controller.selectResult[keys[i]]),
                if(keys.length > 6)
                SizedBox(height: 6.w,),
                if(keys.length > 6)
                GestureDetector(
                  onTap: () {
                    ///展示更多
                    isMoreStatus.value = !isMoreStatus.value;
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ByText.text(
                          textColor: ByColor.colorF1,
                          text: isMoreStatus.value ? 'More' : 'Pick up',
                          fontSize: 13.sp),
                      SizedBox(
                        width: 4.w,
                      ),
                      AnimatedRotation(
                        turns: isMoreStatus.value ? 0 : 0.5,
                        duration: const Duration(milliseconds: 0),
                        child: Image.asset(
                          'assets/home/novel/btn_novel_create_tags_more.png',
                          width: 12.w,
                          height: 12.w,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )),
    );
  }

  ///选择结果cell
  Widget selectResultCell(String title, String? value) {
    String result = '';
    if(value == null || value.isEmpty) {
      result = '-';
    }
    else {
      result = value;
    }
    return GestureDetector(
      onTap: () {
        controller.scrollToTarget(title);
      },
      child: SizedBox(
        height: 28.w,
        child: Row(
          children: [
            SizedBox(
                width: 100.w,
                child: ByText.text(
                  text: title,
                  textColor: ByColor.colorF2,
                )),
            SizedBox(
              width: 12.w,
            ),
            Container(
                constraints: BoxConstraints(maxWidth: 212.w),
                child: ByText.text(
                    text: result,
                    textColor: ByColor.colorF1,
                    maxLines: 1)),
          ],
        ),
      ),
    );
  }
}