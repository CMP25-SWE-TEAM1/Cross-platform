import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gigachat/Globals.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/create-post/widgets/post-media-view.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/widgets/gallery/gallery.dart';
import 'package:photo_manager/photo_manager.dart';


///
/// Since creating a tweet can actually have more than one tweet, this widget is responsible
/// for handling only one tweet editing , including :
/// * Adding media
/// * Adding Text
/// * Removing media
///
class PostEditor extends StatefulWidget {
  bool active;
  bool multi;
  bool muteable;
  int maxImageHeight = 0; //0 = Adaptive , 1 = min
  void Function(bool) onFocus;
  void Function() onRemove;
  void Function() onTextChanged;

  PostEditor({
    super.key,
    required this.active,
    required this.multi,
    required this.muteable,
    required this.onFocus,
    required this.onRemove,
    required this.onTextChanged,
    required this.maxImageHeight,
  });


  @override
  State<PostEditor> createState() => PostEditorState();
}

class PostEditorState extends State<PostEditor> with TickerProviderStateMixin {
  List<TypedEntity> media = [];
  TextEditingController controller = TextEditingController();
  FocusNode node = FocusNode();
  bool _removed = false;
  final int _animationDur = 200;

  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: _animationDur),
  );
  late final AnimationController _slide = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: _animationDur),
  );
  late final Animation<double> _opacity;
  late final Animation<double> _size;


  void initAnim() async {
    _slide.forward(from: 1); //snap to end
    //await Future.delayed(Duration(milliseconds: _animationDur));
    _fade.forward();
  }

  @override
  void initState() {
    super.initState();
    node.addListener(() {
      if (Platform.isAndroid) { //on windows its really bad ..
        widget.onFocus(node.hasFocus);
      }
    });

    controller.addListener(widget.onTextChanged);

    _opacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_fade);

    _size = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_slide);
    initAnim();

    node.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    Auth auth = Auth.getInstance(context);

    double ihm = Globals.HomeScreenWidth - 40 - 8 * 2;
    double iVm = Globals.HomeScreenWidth - 40 - 8 * 2;
    if (widget.maxImageHeight == 1 || media.length > 1){
      ihm = ihm / 2;
    }

    int index = 0;

    return AnimatedOpacity(
      opacity: widget.active || !widget.muteable ? 1 : 0.8,
      duration: Duration(milliseconds: _animationDur),
      child: FadeTransition(
        opacity: _opacity,
        child: SizeTransition(
          sizeFactor: _size,
          child: GestureDetector(
            behavior: _removed ? HitTestBehavior.opaque : HitTestBehavior.translucent,
            onTap: () {
              widget.onFocus(true);
            },
            child: IntrinsicHeight(
              child: Stack(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(auth.getCurrentUser()!.iconLink),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: const BorderRadius.all(Radius.circular(50)),
                            border: Border.all(
                              width: 0,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: widget.multi,
                        child: const Expanded(
                          child: VerticalDivider(
                            width: 10,
                            thickness: 2,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 4 , left: 40 + 8 * 2),
                        child: TextField(
                          focusNode: node,
                          controller: controller,
                          onChanged: (str){
                            if(controller.text.length > MAX_POST_LENGTH){
                              setState(() {

                              });
                            }
                          },
                          //maxLength: MAX_POST_LENGTH.toInt(),
                          maxLines: null,
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                          decoration: const InputDecoration(
                            hintText: "What's happening ?",
                            counterText: "",
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(width: 0 , color: Colors.transparent),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(width: 0 , color: Colors.transparent),
                            ),
                            disabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(width: 0 , color: Colors.transparent),
                            ),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(width: 0 , color: Colors.transparent),

                            ),

                          ),
                        ),
                      ),
                      const SizedBox(width: 1,height: 5,),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(width: 40 + 8,height: 1,),
                                ...
                                media.map((e){
                                  int i = index++;
                                  return Container(
                                    alignment: Alignment.centerLeft,
                                    constraints: BoxConstraints(maxWidth: e.type == AssetType.image ? ihm : iVm),
                                    child: Stack(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(Radius.circular(15)),
                                            border: Border.all(
                                              width: 0,
                                            ),
                                          ),
                                          clipBehavior: Clip.antiAlias,
                                          child: SizedBox(
                                            child: PostMediaView(
                                              width: e.type == AssetType.image ? ihm : iVm,
                                              media: e,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          right: 20,
                                          top: 20,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: const BorderRadius.all(Radius.circular(9999)),
                                              border: Border.all(
                                                width: 0,
                                              ),
                                              color: Colors.black87,
                                            ),
                                            child: IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  print("removing : $i");
                                                  media.removeAt(i);
                                                });
                                              } ,
                                              splashRadius: 15,
                                              icon: Transform.scale(
                                                scale: 2.5,
                                                child: const Icon(
                                                  Icons.close,
                                                  size: 10,
                                                  fill: 1,
                                                  weight: 5,
                                                ),
                                              ),
                                              color: Colors.white,
                                              constraints: const BoxConstraints(maxWidth: 30 , maxHeight: 30),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 1,height: 25,),
                    ],
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Visibility(
                      visible: widget.active && controller.text.isEmpty && widget.muteable,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: IconButton(
                          onPressed: () async {
                            _removed = true;
                            _fade.reverse();
                            await Future.delayed(Duration(milliseconds: _animationDur));
                            _slide.reverse();
                            await Future.delayed(Duration(milliseconds: _animationDur));
                            widget.onRemove();
                          },
                          icon: const Icon(Icons.close),
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
