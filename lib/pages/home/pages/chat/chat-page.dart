import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gigachat/api/api.dart';
import 'package:gigachat/api/chat-class.dart';
import 'package:gigachat/api/chat-requests.dart';
import 'package:gigachat/api/media-class.dart';
import 'package:gigachat/api/media-requests.dart';
import 'package:gigachat/api/tweet-data.dart';
import 'package:gigachat/api/user-class.dart';
import 'package:gigachat/pages/home/pages/chat/chat-info-page.dart';
import 'package:gigachat/pages/home/pages/chat/widgets/chat-item.dart';
import 'package:gigachat/pages/home/pages/chat/widgets/chat-list-item.dart';
import 'package:gigachat/pages/home/pages/chat/widgets/message-input-area.dart';
import 'package:gigachat/pages/loading-page.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/providers/web-socks-provider.dart';
import 'package:gigachat/util/Toast.dart';
import 'package:gigachat/widgets/PositionRetainedScrollPhysics.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  static const String pageRoute = "/chat";

  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  final double _sideButtonTrigger   = 150;
  final double _loadMessagesTrigger = 300;
  bool _visiable = false;
  late final StreamSocket _chatSocket;
  bool _ready = false;
  late final User _with;
  final List<ChatMessageObject> _chat = [];
  late final Uuid uuid;

  final GlobalKey editor = GlobalKey();
  final GlobalKey chatList = GlobalKey();
  double _editorHeight = 0;
  final ScrollController _controller = ScrollController();

  bool _loading = false;
  bool _loadingMore = false;
  bool _canLoadMore = true;

  int page = 1;

  void _loadMessages({more = false}) async {
    if (_loading || _loadingMore) {
      return;
    }
    if (more){
      if (!_canLoadMore){
        return;
      }
      _loadingMore = true;
    }else{
      _loading = true;
    }
    setState(() {});

    var res = await Chat.apiGetChatMessages(Auth.getInstance(context).getCurrentUser()!.auth!, _with.mongoID, page, 25); //load the last 25 messages
    if (res.data == null){ /* failed to load */
      if (context.mounted) {
        Toast.showToast(context, "Failed to load messages");
      }
    }else{
      _chat.insertAll(0, res.data!);
      page++;
      if (res.data!.isEmpty){ //no more messages
        _canLoadMore = false;
      }
    }


    setState(() {
      if (_loading){
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _controller.jumpTo(_controller.position.maxScrollExtent);
        });
        _loading = false;
      }else{
        _loadingMore = false;
        if (_controller.offset - _loadMessagesTrigger <= 0){
          _loadMessages(more: true);
        }
      }
    });

  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      //message load
      if (_controller.offset - _loadMessagesTrigger <= 0){
        _loadMessages(more: true);
      }
      //down button trigger
      if (_controller.position.maxScrollExtent - _controller.offset > _sideButtonTrigger){
        if (!_visiable){
          setState(() {
            _visiable = true;
          });
        }
      }else{
        if (_visiable){
          setState(() {
            _visiable = false;
          });
        }
      }
    });
    _chatSocket = WebSocketsProvider.getInstance(context).getStream<Map<String,dynamic>>("receive_message");
    uuid = const Uuid();
    _ready = false;

    WebSocketsProvider.getInstance(context).getStream<Map<String,dynamic>>("failed_to_send_message").stream.listen((ev) {
      print("Error : $ev");
    });

    _chatSocket.stream.listen((event) {
      var data = event;
      if (data["chat_id"] == _with.mongoID || true) { //fixme : the backend doesn't return the right chat room ????
        print("received a message ! $data");
        ChatMessageObject obj = ChatMessageObject();
        User current = Auth().getCurrentUser()!;
        obj.fromMap(data, current.id);
        _handleNewMessage(obj);
      } else {
        print("received a message for another chat id : $data");
      }
      // if (data["type"] == "message"){
      //
      // } else {
      //   _handleMessageDeleted(data["uuid"]);
      // }
    });
  }

  Future<bool> sendMessage(ChatMessageObject m) async {
    User current = Auth.getInstance(context).getCurrentUser()!;
    WebSocketsProvider ws = WebSocketsProvider();
    if (m.media != null){
      //if we have a media, we first try to upload it..
      ApiResponse<List> link = await Media.uploadMedia(current.auth! , [
        UploadFile(path: m.media!.link , type: m.media!.type == MediaType.IMAGE ? "image" : "video" , subtype: m.media!.type == MediaType.IMAGE ? "png" : "mp4")
      ]);
      if (link.data == null || link.data!.isEmpty){
        return false;
      }
      m.media = MediaObject(link: link.data![0], type: m.media!.type);
    }
    var data = m.toMap(current.mongoID, _with.mongoID);
    ws.send("send_message" , data);
    return true;
  }

  void _handleSendMessage(ChatMessageObject m) async {
    m.uuid = uuid.v4();
    m.state = ChatMessageObject.STATE_SENDING;
    _handleNewMessage(m); //mark as sending and send
    if (! await sendMessage(m)){ //failed
      _handleMessageFailed(m);
    }
  }

  void _handleNewMessage(ChatMessageObject m){
    if (m.self){
      if (m.state == ChatMessageObject.STATE_SENDING){
        _chat.add(m);
      } else if (m.state == ChatMessageObject.STATE_SENT){
        int index = _chat.lastIndexWhere((element) => element.uuid == m.uuid);
        if (index == -1){ //didn't find this message (account is open on another phone ?)
          _chat.add(m);
        }else{
          _chat[index].state = ChatMessageObject.STATE_SENT;
        }
      }
    }else{
      _chat.add(m);
    }

    chatList.currentState!.setState(() {
      // update the chat list builder state to make it re-build
    });

    if (_controller.offset == _controller.position.maxScrollExtent){
      Future.delayed(const Duration(milliseconds: 100) , () {
        _controller.animateTo(_controller.position.maxScrollExtent, duration: const Duration(milliseconds: 100), curve: Curves.easeIn);
      });
    }

    // setState(() {
    //
    // });
  }

  void _handleMessageDeleted(String uuid){

  }

  void _handleMessageFailed(ChatMessageObject m){
    int index = _chat.lastIndexWhere((element) => element.uuid == m.uuid);
    if (index == -1){ //didn't find this message (account is open on another phone ?)
      //_chat.add(m); should never happen
    }else{
      _chat[index].state = ChatMessageObject.STATE_FAILED;
    }
    chatList.currentState!.setState(() {
      // update the chat list builder state to make it re-build
    });
  }


  @override
  Widget build(BuildContext context) {
    if (!_ready){
      _ready = true;
      var args = ModalRoute.of(context)!.settings.arguments! as Map;
      _with = args["user"];

      //load the messages
      _loadMessages();
    }

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Row(
              children: [

                IconButton(
                  onPressed: () {
                    //TODO: navigate to the profile page
                  },
                  icon: Container(
                    width: 40,
                    height: 40,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                          _with.iconLink,
                        ),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(50)),
                      border: Border.all(
                        width: 0,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10,),

                TextButton(
                  onPressed: () {
                    //TODO: open a bottom sheet to follow the user
                    showModalBottomSheet(context: context, builder: (_) {
                      return SizedBox(
                        height: 200,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                width: 40,
                                height: 5,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 10,),

                              Text(
                                _with.name,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).textTheme.bodyLarge!.color,
                                ),
                              ),

                              SizedBox(height: 10,),

                              ListTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        _with.iconLink,
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                                    border: Border.all(
                                      width: 0,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  _with.name,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).textTheme.bodyLarge!.color,
                                  ),
                                ),
                                subtitle: Text(
                                  "@${_with.id}",
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),

                                //TODO: REPLACE WITH FOLLOW BUTTON
                                trailing: !_with.isFollowed! ?
                                ElevatedButton(onPressed: () {}, child: Text("Follow")) :
                                OutlinedButton(onPressed: () {}, child: Text("Following")),
                              )
                            ],
                          ),
                        ),
                      );
                    });
                  },
                  child: Text(
                    _with.name,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                )
              ],
            ),
            actions: [
              IconButton(onPressed: () {
                //TODO Implement info
                Navigator.push(context, MaterialPageRoute(builder: (_) => ChatInfoPage(_with)));
              }, icon: const Icon(Icons.info_outline)),
            ],
          ),
          body: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    Expanded(
                      child: StretchingOverscrollIndicator(
                        axisDirection: AxisDirection.down,
                        child: SingleChildScrollView(
                          physics: const PositionRetainedScrollPhysics(),
                          controller: _controller,
                          child: Column(
                            //chat
                            children: [

                              //Header
                              Visibility(
                                visible: _loadingMore,
                                child: const Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: SizedBox(width: 25,height: 25,child: CircularProgressIndicator(),),
                                    )
                                  ],
                                ),
                              ),
                              Visibility(
                                visible: !_canLoadMore,
                                child: Column(
                                  children: [
                                    Container(
                                      width: 70,
                                      height: 70,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle
                                      ),
                                      child: Image.network(_with.iconLink,fit: BoxFit.cover,),
                                    ),

                                    Text(
                                      _with.name,
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 16,
                                      ),
                                    ),

                                    Text(
                                      _with.id,
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 16,
                                      ),
                                    ),

                                    const SizedBox(height: 10,),
                                    Text(
                                      "${_with.followers} Followers",
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 20,),

                                    const Divider(
                                      thickness: 1,
                                    ),
                                  ],
                                ),
                              ),

                              //Messages area
                              ChatColumn(
                                key: chatList,
                                chat: _chat,
                              ),

                              //Input padding
                              SizedBox(
                                height: _editorHeight,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedOpacity(
                opacity: _visiable ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Transform.translate(
                    offset: Offset(-20, -_editorHeight),
                    child: Material(
                      clipBehavior: Clip.antiAlias,
                      color: Theme.of(context).scaffoldBackgroundColor,
                      shape: const CircleBorder(),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_downward_outlined),
                        onPressed: () {
                          _controller.animateTo(_controller.position.maxScrollExtent, duration: Duration(milliseconds: 50 * ((_controller.position.maxScrollExtent - _controller.offset) / 50.0).round()), curve: Curves.fastOutSlowIn);
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  key: editor,
                  padding: const EdgeInsets.all(8.0),
                  child: MessageInputArea(
                    onMessage: (m) {
                      _handleSendMessage(m);
                    },
                    onSizeChange: () {
                      setState(() {

                        _editorHeight = editor.currentContext!.size!.height;
                      });
                    },
                    onOpen: () {
                      Future.delayed(const Duration(milliseconds: 400) , () {
                        _controller.animateTo(_controller.position.maxScrollExtent, duration: Duration(milliseconds: 50 * ((_controller.position.maxScrollExtent - _controller.offset) / 50.0).round()), curve: Curves.fastOutSlowIn);
                      });
                    },
                  ),
                ),
              )
            ],
          ),
        ),
        Visibility(
          visible: _loading,
          child: const LoadingPage(),
        ),
      ],
    );
  }
}

class ChatColumn extends StatefulWidget {
  final List<ChatMessageObject> chat;
  const ChatColumn({super.key , required this.chat});

  @override
  State<ChatColumn> createState() => _ChatColumnState();
}

class _ChatColumnState extends State<ChatColumn> {
  final DateFormat titleFormatter = DateFormat('EEEE, MMMM d');

  @override
  Widget build(BuildContext context) {
    int day = -1;
    return Column(
      children: [
        ...widget.chat.map((e) {
          String? title;
          var time = e.time!;
          if (day != time.day + time.month * 40){
            title =  titleFormatter.format(time);
            day = time.day + time.month * 40;
          }
          return Column(
            children: [
              (title != null) ? Container(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(title , style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                ),
              ) : const SizedBox.shrink(),
              ChatItem(message: e, onLongPress: (m) {

              }, onPress: (m) async {
                if (m.state == ChatMessageObject.STATE_FAILED){ //on failed , resend this thing
                  ChatPageState pageState = context.findAncestorStateOfType<ChatPageState>()!;
                  m.state = ChatMessageObject.STATE_SENDING;
                  pageState.chatList.currentState!.setState(() {});
                  if (! await pageState.sendMessage(m)){ //failed
                    m.state = ChatMessageObject.STATE_FAILED;
                    pageState.chatList.currentState!.setState(() {});
                  }
                }
              }, onSwipe: (m) {}),
            ],
          );
        }).toList(),
      ],
    );
  }
}

