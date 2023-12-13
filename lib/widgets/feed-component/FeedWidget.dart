import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gigachat/api/tweet-data.dart';
import 'package:gigachat/api/user-class.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/Search/unit-widgets/search-widgets.dart';
import 'package:gigachat/pages/home/pages/explore/explore.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/providers/feed-provider.dart';
import 'package:gigachat/widgets/feed-component/feed-controller.dart';
import 'package:gigachat/widgets/tweet-widget/tweet.dart';
import 'package:provider/provider.dart';

class BetterFeed extends StatefulWidget {
  final bool isScrollable;
  final ProviderFunction providerFunction;
  final ProviderResultType providerResultType;
  final FeedController feedController;
  String? userId,userName, tweetID, keyword;

  BetterFeed({
    super.key,
    required this.isScrollable,
    required this.providerFunction,
    required this.providerResultType,
    required this.feedController,
    this.userId,
    this.userName,
    this.tweetID,
    this.keyword,
  });

  @override
  State<BetterFeed> createState() => _BetterFeedState();
}

class _BetterFeedState extends State<BetterFeed> {
  late FeedController _feedController;
  late Timer timer;
  late ScrollController _scrollController;


  @override
  void initState() {
    _feedController = widget.feedController;
    _feedController.setUserToken(Auth.getInstance(context).getCurrentUser()!.auth);
    timer = Timer(const Duration(seconds: 1), () { });
    _scrollController = ScrollController();
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent)
      {
        await refreshFeed();
        setState(() {});
      }
    });
    super.initState();
  }

  Future<void> refreshFeed() async {
   await _feedController.fetchFeedData(
        username: widget.userId,
        tweetID: widget.tweetID,
        keyword: widget.keyword
    );
  }

  List<Widget>? wrapDataInWidget() {
    switch(widget.providerResultType){
      // The Result Of Searching For User
      case ProviderResultType.USER_RESULT:
        List<User> userResult = _feedController.getCurrentData().cast<User>();
        return userResult.map((User user){
                  return UserResult(user: user);
        }).toList();
      // The Normal View For Tweets
      case ProviderResultType.TWEET_RESULT:
        List<TweetData> tweetResult = _feedController.getCurrentData().cast<TweetData>();
        return tweetResult.map((TweetData tweetData){
                  if(widget.providerFunction == ProviderFunction.PROFILE_PAGE_TWEETS){
                    tweetData.reTweeter = User(name: widget.userName!, id: widget.userId!);
                  }
                  return Tweet(
                    tweetOwner: tweetData.tweetOwner,
                    tweetData: tweetData,
                    isRetweet: tweetData.isRetweeted,
                    isSinglePostView: false,
                    callBackToDelete: (String tweetID){
                      _feedController.deleteTweet(tweetID);
                      setState(() {});
                    },
                  );
        }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedProvider>(
        builder: (_,__,___){
          if (_feedController.isLoading()){
            refreshFeed();
            return const Center(child: CircularProgressIndicator());
          }

          List<Widget>? widgetList = wrapDataInWidget();

          if(widgetList == null || widgetList.isEmpty)
          {
            return RefreshIndicator(
                child: SingleChildScrollView(
                    child: SizedBox(
                        height: 0.5 * MediaQuery.of(context).size.height,
                        child: const NothingYet()
                    )
                ),
                onRefresh: () async {

                }
            );
          }

          return RefreshIndicator(
              onRefresh: () async {},
              child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(children: widgetList!),
              )
          );
        }
    );

  }

}
