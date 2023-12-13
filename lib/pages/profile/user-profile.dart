
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gigachat/api/account-requests.dart';
import 'package:gigachat/pages/blocking-loading-page.dart';
import 'package:gigachat/pages/home/pages/chat/chat-page.dart';
import 'package:gigachat/pages/home/pages/feed/feed-home-tab.dart';
import 'package:gigachat/pages/profile/edit-profile.dart';
import 'package:gigachat/pages/profile/profile-image-view.dart';
import 'package:gigachat/pages/profile/widgets/app-bar-icon.dart';
import 'package:gigachat/pages/profile/widgets/avatar.dart';
import 'package:gigachat/pages/profile/widgets/banner.dart';
import 'package:gigachat/pages/profile/widgets/interact.dart';
import 'package:gigachat/pages/profile/widgets/tab-bar.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/providers/feed-provider.dart';
import 'package:gigachat/providers/theme-provider.dart';
import 'package:intl/intl.dart';
import '../../api/user-class.dart';
import '../../base.dart';
import '../../util/Toast.dart';
import '../../widgets/feed-component/FeedWidget.dart';
import '../../widgets/feed-component/feed-controller.dart';

class UserProfile extends StatefulWidget {
  final String username;
  final bool isCurrUser;
  static const profileFeed = 'profileFeed';
  const UserProfile({Key? key, required this.username, required this.isCurrUser}) : super(key: key);

  static const pageRoute = '/user-profile';

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> with TickerProviderStateMixin {

  //user details
  late String name;
  late String username;
  late String avatarImageUrl;
  late String bannerImageUrl;
  late String bio;
  late String website;
  String location = "Cairo, Egypt";  //its not a feature so its constant forever, looks cool tho
  late DateTime birthDate;
  late DateTime joinedDate;
  late int following;
  late int followers;
  //only wanted user details
  late bool? isCurrUserBlocked;
  late bool? isWantedUserBlocked;
  late bool? isWantedUserMuted;
  late bool? isWantedUserFollowed;
  late bool? isCurrUser;


  //page details
  bool loading = true;

  late ScrollController scrollController;
  late FeedController feedController;
  late TabController tabController;

  int prevTabIndex = 0;
  List<bool> isLoaded = [true,false,false,false];

  double avatarRadius = 35;
  double showNamePosition = 162;
  double collapsePosition = 80;
  EdgeInsetsGeometry avatarPadding = const EdgeInsets.fromLTRB(8, 122, 0, 0);

  final ValueNotifier<double> scroll = ValueNotifier<double>(0);

  //get user data
  void getData() async {
    setState(() {
      loading = true;
    });
    Auth auth = Auth.getInstance(context);
    var res = widget.isCurrUser? await Account.apiCurrUserProfile(auth.getCurrentUser()!.auth!) :
        await Account.apiUserProfile(auth.getCurrentUser()!.auth!, widget.username);
    User u = res.data!;

    name = u.name;
    username = u.id;
    avatarImageUrl = u.iconLink;
    bannerImageUrl = u.bannerLink;
    birthDate = u.birthDate!;
    joinedDate = u.joinedDate!;
    following = u.following;
    followers = u.followers;
    bio = u.bio;
    website = u.website;
    isCurrUserBlocked = u.isCurrUserBlocked;
    isWantedUserBlocked = u.isWantedUserBlocked;
    isWantedUserMuted = u.isWantedUserMuted;
    isWantedUserFollowed = u.isFollowed;
    isCurrUser = u.isCurrUser;

    scrollController = ScrollController();
    scrollController.addListener(() async {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent)
      {
        await feedController.fetchFeedData(username: username);
        setState(() {});
      }
    });

    if(!context.mounted) return;

    FeedProvider feedProvider = FeedProvider.getInstance(context);
    feedController = feedProvider.getFeedControllerById(
        context: context,
        id: UserProfile.profileFeed + username,
        providerFunction: ProviderFunction.PROFILE_PAGE_TWEETS,
        clearData: false
    );

    feedController.setUserToken(Auth.getInstance(context).getCurrentUser()!.auth);

    setState(() {
      loading = false;
    });
  }

  void onTapBarClick(int index, int durationMS) {
    if(prevTabIndex != index){
      setState(() {
        prevTabIndex = index;
      });
      if(index == 1 && !isLoaded[1]){
        if(scrollController.position.pixels > 315 && bio == ""){
          scrollController.animateTo(315, duration: Duration(milliseconds: durationMS), curve: Curves.easeInOut);
        }
        else if(scrollController.position.pixels > 390 && bio != ""){
          scrollController.animateTo(390, duration: Duration(milliseconds: durationMS), curve: Curves.easeInOut);
        }
        isLoaded[1] = true;
     }
      if(index == 2 && !isLoaded[2]){
        if(scrollController.position.pixels > 315 && bio == ""){
          scrollController.animateTo(315, duration: Duration(milliseconds: durationMS), curve: Curves.easeInOut);
        }
        else if(scrollController.position.pixels > 390 && bio != ""){
          scrollController.animateTo(390, duration: Duration(milliseconds: durationMS), curve: Curves.easeInOut);
        }
        isLoaded[2] = true;
      }
      if(index == 3 && !isLoaded[3]){
        if(scrollController.position.pixels > 315 && bio == ""){
          scrollController.animateTo(315, duration: Duration(milliseconds: durationMS), curve: Curves.easeInOut);
        }
        else if(scrollController.position.pixels > 390 && bio != ""){
          scrollController.animateTo(390, duration: Duration(milliseconds: durationMS), curve: Curves.easeInOut);
        }
        isLoaded[3] = true;
      }
    }
  }

  void onEditProfileClick() async {
    var res = await Navigator.push(context,
        MaterialPageRoute(builder: (context) =>
            EditProfile(
              name: name,
              bannerImageUrl: bannerImageUrl,
              avatarImageUrl: avatarImageUrl,
              bio: bio,
              website: website,
              birthDate: birthDate,
            )
        ));
    if(res != null){
      setState(() {
        name = res["name"];
        bio = res["bio"];
        website = res["website"];
        birthDate = res["birthDate"];
        bannerImageUrl = res["bannerImageUrl"];
        avatarImageUrl = res["avatarImageUrl"];
      });
    }
  }

  void followUser() async {
    bool success = await Account.followUser(Auth.getInstance(context).getCurrentUser()!.auth!, widget.username);
    if(success){
      setState(() {
        isWantedUserFollowed = true;
      });
    }else{
      if(context.mounted){
        Toast.showToast(context, "Action failed. Please try again.");
      }
    }
  }

  void unfollowUser() async {
    bool success = await Account.unfollowUser(Auth.getInstance(context).getCurrentUser()!.auth!, widget.username);
    if(success){
      setState(() {
        isWantedUserFollowed = false;
      });
    }else{
      if(context.mounted){
        Toast.showToast(context, "Action failed. Please try again.");
      }
    }
  }

  void muteUser() async {
    bool success = await Account.muteUser(Auth.getInstance(context).getCurrentUser()!.auth!, widget.username);
    if(success){
      setState(() {
        isWantedUserMuted = true;
        Toast.showToast(context, "You muted @$username.");
      });
    }else{
      if(context.mounted){
        Toast.showToast(context, "Action failed. Please try again.");
      }
    }
  }

  void unmuteUser() async {
    bool success = await Account.unmuteUser(Auth.getInstance(context).getCurrentUser()!.auth!, widget.username);
    if(success){
      setState(() {
        isWantedUserMuted = false;
        Toast.showToast(context, "You unmuted @$username.");
      });
    }else{
      if(context.mounted){
        Toast.showToast(context, "Action failed. Please try again.");
      }
    }
  }

  void blockUser() async {
    showDialog(context: context,
        builder: (context) =>
            AlertDialog(
              content: SizedBox(
                width: 300,
                height: 160,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Block @$username?",style: const TextStyle(fontWeight: FontWeight.bold),),
                    const SizedBox(height: 15,),
                    Text("@$username will no longer be able to follow or message you,"
                        "and you will not see notifications from @$username"),
                    Row(
                      children: [
                        const Expanded(child: SizedBox.shrink()),
                        TextButton(
                          onPressed: (){
                            Navigator.pop(context);
                          },
                          child: Text("Cancel",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                              color: ThemeProvider.getInstance(context).isDark()? Colors.white : Colors.black
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            bool success = await Account.blockUser(Auth.getInstance(context).getCurrentUser()!.auth!, widget.username);
                            if(success){
                              setState(() {
                                isWantedUserBlocked = true;
                                if(context.mounted){
                                  Navigator.pop(context);
                                  Toast.showToast(context, "You blocked @$username.");
                                }
                              });
                            }else{
                              if(context.mounted){
                                Toast.showToast(context, "Action failed. Please try again.");
                              }
                            }
                          },
                          child: Text("Block",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: ThemeProvider.getInstance(context).isDark()? Colors.white : Colors.black
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            )
    );
  }

  void unblockUser() async {
    showDialog(context: context,
        builder: (context) =>
            AlertDialog(
              content: SizedBox(
                width: 300,
                height: 160,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Unblock @$username?",style: const TextStyle(fontWeight: FontWeight.bold),),
                    const SizedBox(height: 15,),
                    const Text("They will be able to follow you and view your posts"),
                    Row(
                      children: [
                        const Expanded(child: SizedBox.shrink()),
                        TextButton(
                          onPressed: (){
                            Navigator.pop(context);
                          },
                          child: Text("Cancel",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: ThemeProvider.getInstance(context).isDark()? Colors.white : Colors.black
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            bool success = await Account.unblockUser(Auth.getInstance(context).getCurrentUser()!.auth!, widget.username);
                            if(success){
                              setState(() {
                                isWantedUserBlocked = false;
                                if(context.mounted){
                                  Navigator.pop(context);
                                  Toast.showToast(context, "You unblocked @$username.");
                                }
                              });
                            }else{
                              if(context.mounted){
                                Toast.showToast(context, "Action failed. Please try again.");
                              }
                            }
                          },
                          child: Text("Unblock",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: ThemeProvider.getInstance(context).isDark()? Colors.white : Colors.black
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            )
    );
  }


  @override
  void initState()  {

    tabController = TabController(length: 4, vsync: this);
    tabController.addListener(() {
      if(!tabController.indexIsChanging){
        int index = tabController.index;
        onTapBarClick(index, 100);
      }
    });

    getData();
    super.initState();
  }

  //TODO: get likes, media, replies
  //TODO: auto add when creating post

  @override
  Widget build(BuildContext context) {

    return loading? const BlockingLoadingPage():
    Scaffold(
      extendBodyBehindAppBar: true,
      body: NotificationListener<ScrollUpdateNotification>(
        onNotification: (notification){
          scroll.value = scrollController.position.pixels;
          return true;
        },
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: Stack(
            children: [
              NestedScrollView(
                controller: scrollController,
                headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    ValueListenableBuilder(
                      valueListenable: scroll,
                      builder: (context,value,_) {
                        return SliverAppBar(
                          pinned: true,
                          expandedHeight: 130,
                          title: value > showNamePosition ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                style: const TextStyle(
                                    fontSize: 23,
                                    color: Colors.white
                                ),
                              ),
                              Text(prevTabIndex == 3? "2 Likes" : "2 Posts",
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ), //TODO: num of posts & likes
                            ],
                          ) : null,
                          backgroundColor: Colors.transparent,
                          leading: ProfileAppBarIcon(
                            toolTip: 'Navigate Up',
                            icon: Icons.arrow_back,
                            onPressed: (){
                              Navigator.pop(context);
                            },
                          ),
                          leadingWidth: 60,
                          actions: (value > showNamePosition
                              && (!widget.isCurrUser && !isCurrUser!)
                              && (isWantedUserFollowed != null && !isWantedUserFollowed!)
                              && (isWantedUserBlocked != null && !isWantedUserBlocked!)) ?
                          <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ProfileInteract(
                                avatarIsVisible: false,
                                avatarImageUrl: avatarImageUrl,
                                isCurrUser: widget.isCurrUser,
                                isHeader: true,
                                onTapEditProfile: onEditProfileClick,
                                onTapFollow: followUser,
                                onTapUnfollow: unfollowUser,
                                isWantedUserFollowed: isWantedUserFollowed,
                                isWantedUserBlocked: isCurrUserBlocked,
                              ),
                            ),
                          ] :
                          <Widget>[
                            Visibility(
                              visible: widget.isCurrUser || (isCurrUser != null && isCurrUser!) || (isCurrUserBlocked != null && !isCurrUserBlocked!),
                              child: ProfileAppBarIcon(
                                icon: Icons.search,
                                onPressed: (){
                                  //TODO: navigate to search page with user filter
                                },
                                toolTip: 'Search',
                              ),
                            ),
                            ProfileAppBarIcon(
                              icon: Icons.more_vert,
                              toolTip: 'Menu',
                              onPressed: () {
                                showMenu(
                                  context: context,
                                  position: const RelativeRect.fromLTRB(6, 5, 5, 0),
                                  items: widget.isCurrUser? <PopupMenuItem>[ //doesn't do anything just for looks :p
                                    PopupMenuItem(
                                      child: const Text("Share"),
                                      onTap: (){},
                                    ),
                                    PopupMenuItem(
                                      child: const Text("Draft"),
                                      onTap: (){},
                                    ),
                                    PopupMenuItem(
                                      child: const Text("Lists you're on"),
                                      onTap: (){},
                                    )
                                  ] : <PopupMenuItem>[
                                    isWantedUserMuted != null && isWantedUserMuted!?
                                    PopupMenuItem(
                                      onTap: unmuteUser,
                                      child: const Text("Unmute"),
                                    ): PopupMenuItem(
                                      onTap: muteUser,
                                      child: const Text("Mute"),
                                    ),
                                    isWantedUserBlocked != null && isWantedUserBlocked!?
                                    PopupMenuItem(
                                      onTap: unblockUser,
                                      child: const Text("Unblock"),
                                    ):
                                    PopupMenuItem(
                                      onTap: blockUser,
                                      child: const Text("Block"),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                          flexibleSpace: value > collapsePosition ? ColorFiltered(
                            colorFilter: const ColorFilter.mode(Colors.black38, BlendMode.darken),
                            child: bannerImageUrl == "" ?
                            Container(color: Colors.blue,) :
                            Image.network(bannerImageUrl,
                              fit: BoxFit.cover,
                              alignment: Alignment.bottomCenter,
                            ),
                          ) :
                          ProfileBanner(
                              bannerImageUrl: bannerImageUrl,
                              onTap:  () async {
                                if(bannerImageUrl != ""){
                                  var res = await Navigator.push(context,
                                      MaterialPageRoute(builder: (context) =>
                                          ProfileImageView(
                                            isCurrUser: widget.isCurrUser || (isCurrUser != null && isCurrUser!),
                                            isProfileAvatar: false,
                                            imageUrl: bannerImageUrl,
                                            avatarImageUrl: avatarImageUrl,
                                            name: name,
                                            birthDate: birthDate,
                                            bio: bio,
                                            website: website,
                                          )
                                      )
                                  );
                                  if(res != null){
                                    setState(() {
                                      name = res["name"];
                                      bio = res["bio"];
                                      website = res["website"];
                                      birthDate = res["birthDate"];
                                      bannerImageUrl = res["bannerImageUrl"];
                                      avatarImageUrl = res["avatarImageUrl"];
                                    });
                                  }
                                }else if(widget.isCurrUser || (isCurrUser != null && isCurrUser!)){
                                  onEditProfileClick();
                                }
                              },
                            ),
                        );
                      }
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ValueListenableBuilder(
                              valueListenable: scroll,
                              builder: (context,value,_) {
                                return Visibility(
                                  visible: widget.isCurrUser || (isCurrUser != null && isCurrUser!)
                                    || (isCurrUserBlocked != null && !isCurrUserBlocked!),
                                  child: ProfileInteract(
                                    avatarIsVisible: value > collapsePosition,
                                    isHeader: false,
                                    avatarImageUrl: avatarImageUrl,
                                    isCurrUser: widget.isCurrUser,
                                    isWantedUserFollowed : isWantedUserFollowed,
                                    isWantedUserBlocked : isWantedUserBlocked,
                                    onTapEditProfile: onEditProfileClick,
                                    onTapDM: (){
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ChatPage()
                                        )
                                      );
                                    }, //TODO: DM user
                                    onTapFollow: followUser,
                                    onTapUnfollow: unfollowUser,
                                    onTapUnblock: unblockUser,
                                  ),
                                );
                              }
                            ),
                            Text(
                              name,
                              style: const TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                            Text("@$username"),
                            bio == "" || (isCurrUserBlocked != null && isCurrUserBlocked!)?
                            const Text("") :
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0,10,0,0),
                              child: SizedBox(
                                  height: 80,
                                  child: Text(bio)
                              ),
                            ),
                            const SizedBox(height: 20,),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 15,),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 5),
                                      child: Text(location),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 10,),
                                Row(
                                  children: [
                                    const Icon(Icons.cake, size: 15,),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 5),
                                      child: Text("Born ${DateFormat.yMMMMd('en_US').format(birthDate )}"),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10,),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.date_range, size: 15,),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 5),
                                      child: Text("Joined ${DateFormat.yMMMMd('en_US').format(joinedDate)}"),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 10,),
                                Row(
                                  children: [
                                    const Icon(CupertinoIcons.link, size: 15,),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 5),
                                      child: Text(website), //TODO: change later (detect urls)
                                    ),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(height: 15,),
                            Visibility(
                              visible: widget.isCurrUser || (isCurrUser != null && isCurrUser!)
                                  || ((isWantedUserBlocked != null && !isWantedUserBlocked!)
                                  && (isCurrUserBlocked != null && !isCurrUserBlocked!)),
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: (){
                                      //TODO: list of Following
                                    },
                                    splashFactory: NoSplash.splashFactory,
                                    child: Row(
                                      children: [
                                        Text(
                                          "$following",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Text(" Following"),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10,),
                                  InkWell(
                                    onTap: (){
                                      //TODO: list of Followers
                                    },
                                    splashFactory: NoSplash.splashFactory,
                                    child: Row(
                                      children: [
                                        Text(
                                          "$followers",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Text(" Followers"),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20,),
                          ],
                        ),
                      )
                    ),
                    SliverVisibility(
                      visible: widget.isCurrUser || (isCurrUser != null && isCurrUser!)
                              || ((isWantedUserBlocked != null && !isWantedUserBlocked!)
                              && (isCurrUserBlocked != null && !isCurrUserBlocked!)),
                      sliver: SliverPersistentHeader(delegate: _SliverAppBarDelegate(
                          Container(
                            color: ThemeProvider.getInstance(context).isDark() ? Colors.black : Colors.white,
                            child: ProfileTabBar(
                              tabController: tabController,
                              onTap: (index){
                                  onTapBarClick(index,10);
                                },
                            ),
                          )
                        ),
                        pinned: true,
                      ),
                    )
                  ];
                },
                body: widget.isCurrUser || (isCurrUser != null && isCurrUser!)
                    || (isWantedUserBlocked != null && !isWantedUserBlocked!)?
                TabBarView(
                  controller: tabController,
                  children: [
                    BetterFeed(
                      removeController: true,
                      providerFunction: ProviderFunction.PROFILE_PAGE_TWEETS,
                      providerResultType: ProviderResultType.TWEET_RESULT,
                      feedController: feedController,
                      userId: username,
                      userName: name,
                    ),
                    BetterFeed(
                      removeController: true,
                      providerFunction: ProviderFunction.PROFILE_PAGE_TWEETS,
                      providerResultType: ProviderResultType.TWEET_RESULT,
                      feedController: feedController,
                      userId: username,
                      userName: name,
                    ),
                    Container(color: Colors.red,child: Center(child: Text("3"),),),
                    Container(color: Colors.red,child: Center(child: Text("4"),),),
                  ],
                ) :
                (isCurrUserBlocked != null && isCurrUserBlocked!) ?
                    Column(
                      children: [
                        const Divider(thickness: 1,height: 1,),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text("You are blocked from following @$username "
                              "and viewing @$username posts."),
                        ),
                        const Divider(thickness: 1,height: 1,),
                      ],
                    ) :
                    Container(
                      height: 300,
                      color: Colors.blueGrey[900],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Divider(thickness: 1,height: 1,),
                          const SizedBox(height: 50,),
                          Text(
                            "@$username is blocked",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                            ),
                          )
                        ],
                      ),
                    )
              ),
              ValueListenableBuilder(
                valueListenable: scroll,
                builder: (context,value,_) {
                  return Visibility(
                    visible: value <= collapsePosition,
                    child: ProfileAvatar(
                      avatarImageUrl: avatarImageUrl,
                      avatarPadding: EdgeInsets.fromLTRB(8 + 0.2 * value, 122 - 0.46 * value, 0, 0),
                      avatarRadius: value < collapsePosition? avatarRadius - 0.2 * value : 20,
                      onTap: () async {
                        var res = await Navigator.push(context,
                            MaterialPageRoute(builder: (context) =>
                                ProfileImageView(
                                    isCurrUser: widget.isCurrUser || (isCurrUser != null && isCurrUser!),
                                    isProfileAvatar: true,
                                    imageUrl: avatarImageUrl,
                                )
                            )
                        );
                        if(res != null){
                          setState(() {
                            avatarImageUrl = res;
                          });
                        }
                      },
                    ),
                  );
                }
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FeedHomeTab().getFloatingActionButton(context),  //TODO: change later
    );
  }
}


class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Container _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => 39;

  @override
  double get maxExtent => 39;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return _tabBar;
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
