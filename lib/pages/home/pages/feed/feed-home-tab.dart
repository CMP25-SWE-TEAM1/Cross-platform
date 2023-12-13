
import 'package:flutter/material.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/create-post/create-post-page.dart';
import 'package:gigachat/pages/home/home-page-tab.dart';
import 'package:gigachat/pages/home/home.dart';
import 'package:gigachat/pages/home/widgets/FloatingActionMenu.dart';
import 'package:gigachat/pages/home/widgets/home-app-bar.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/providers/feed-provider.dart';
import 'package:gigachat/widgets/feed-component/FeedWidget.dart';
import 'package:gigachat/widgets/feed-component/feed-controller.dart';
import 'package:provider/provider.dart';

class FeedHomeTab with HomePageTab {

  @override
  List<AppBarAction> getActions(BuildContext context) {
    return [];
  }

  @override
  int getInitialTab(BuildContext context) {
    return 0;
  }

  @override
  int getNotificationsCount(BuildContext context) {
    return 0;
  }

  @override
  AppBarSearch? getSearchBar(BuildContext context) {
    return null;
  }

  @override
  AppBarTabs? getTabs(BuildContext context) {
    return AppBarTabs(tabs: ["For you" , "Following"], indicatorSize: TabBarIndicatorSize.label, tabAlignment: TabAlignment.center);
  }

  @override
  List<Widget>? getTabsWidgets(BuildContext context,{FeedController? feedController}) {
    if (Auth.getInstance(context).isLoggedIn){
      FeedProvider feedProvider = FeedProvider.getInstance(context);
      FeedController homeFeedController =
          feedProvider.getFeedControllerById(
              context: context,
              id: Home.feedID,
              providerFunction: ProviderFunction.NONE,
              clearData: false
          );
      return [
        BetterFeed(
                isScrollable: true,
                providerFunction: ProviderFunction.HOME_PAGE_TWEETS,
                providerResultType: ProviderResultType.TWEET_RESULT,
                feedController: feedController ?? homeFeedController
        ),
       BetterFeed(
                  isScrollable: true,
                  providerFunction: ProviderFunction.HOME_PAGE_TWEETS,
                  providerResultType: ProviderResultType.TWEET_RESULT,
                  feedController: feedController ?? homeFeedController
       ),

      ];
    }
    return const [
      Padding(
        padding: EdgeInsets.all(32.0),
        child: Text("Login to view :)"),
      ),
      Padding(
        padding: EdgeInsets.all(32.0),
        child: Text("Login to view :)"),
      ),
    ];
  }

  @override
  Widget? getPage(BuildContext context) {
    return null; //will never be called since taps is not null
  }

  @override
  Widget? getFloatingActionButton(BuildContext context) {
    return FloatingActionMenu(
      icon: const Icon(Icons.add,color: Colors.white,),
      tappedIcon: const Icon(Icons.post_add_rounded,color: Colors.white,),
      title: const Padding(
        padding: EdgeInsets.only(right: 25),
        child: Text(
          "Post" ,
          style: TextStyle(
            fontSize: 22,
            color: Colors.white,
          ),
        ),
      ),
      onTab: () async {
        Navigator.pushNamed(context, CreatePostPage.pageRoute , arguments: {});
      } ,
      items: [
        FloatingActionMenuItem(
          icon: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              splashRadius: 25,
              color: Colors.blue,
              icon: const Icon(Icons.photo_camera_back_outlined),
              onPressed: () {
                print("that worked !");
              },
            ),
          ),
          title: const Padding(
            padding: EdgeInsets.only(right: 25),
            child: Text(
              "Photos" ,
              style: TextStyle(
                fontSize: 22,
                color: Colors.white,
              ),
            ),
          ),
        ),
        FloatingActionMenuItem(
          icon: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              splashRadius: 25,
              color: Colors.blue,
              icon: const Icon(Icons.mic_rounded),
              onPressed: () {
                print("that worked !");
              },
            ),
          ),
          title: const Padding(
            padding: EdgeInsets.only(right: 25),
            child: Text(
              "Spaces" ,
              style: TextStyle(
                fontSize: 22,
                color: Colors.white,
              ),
            ),
          ),
        ),

        FloatingActionMenuItem(
          icon: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              splashRadius: 25,
              color: Colors.blue,
              icon: const Icon(Icons.camera_outlined),
              onPressed: () {
                print("that worked !");
              },
            ),
          ),
          title: const Padding(
            padding: EdgeInsets.only(right: 25),
            child: Text(
              "GoLive" ,
              style: TextStyle(
                fontSize: 22,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}