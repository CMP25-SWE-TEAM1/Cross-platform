import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gigachat/api/trend-data.dart';
import 'package:gigachat/api/tweet-data.dart';
import 'package:gigachat/api/user-class.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/Search/unit-widgets/search-widgets.dart';
import 'package:gigachat/pages/create-post/create-post-page.dart';
import 'package:gigachat/pages/home/pages/explore/explore.dart';
import 'package:gigachat/pages/home/pages/internal-home-page.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/providers/feed-provider.dart';
import 'package:gigachat/widgets/feed-component/feed-controller.dart';
import 'package:gigachat/widgets/trends/trend-widget.dart';
import 'package:gigachat/widgets/tweet-widget/tweet.dart';
import 'package:provider/provider.dart';

/// BetterFeed is a class that is responsible for making the pagination effect
/// it is also responsible for displaying the fetched data into its target ui widget
/// [removeController] : boolean to decide whether the scrollController will be created internally or will be following the parent controller
/// [removeRefreshIndicator] : boolean to decide whether the feed should support refreshing or not
/// [providerFunction] : selects the api endpoint function to fetch the desired data for the feed to show
/// [providerResultType] : type of ui widget to display the given data endpoint
/// [feedController] : controller that is responsible for fetching the data for the feed and caching it
/// [cancelNavigationToUserProfile] : boolean to decide weather the tweet inside this feed should stop navigating to the user profile
/// [filterBlockedUsers] : boolean to filter out the blocked users from being shown inside the feed (used in filtering search results)
/// [userId] : optional parameter to refer to the correct user when dealing with the user-related tweets or lists
/// [userName] : optional parameter to refer to the name of the user of the parameter [userId]
/// [tweetID] : optional parameter to refer to the tweet the is being handled (EX: get replies for some tweet)
/// [keyword] : optional parameter to refer to the keyword being searched
/// [mainTweetForComments] : optional parameter to refer to the main tweet in post view page (to make the tweet looks different)
class BetterFeed extends StatefulWidget {
  final bool removeController;
  final bool removeRefreshIndicator;
  final ProviderFunction providerFunction;
  final ProviderResultType providerResultType;
  final FeedController feedController;
  final bool? cancelNavigationToUserProfile;
  final bool filterBlockedUsers;
  final String? userId,userName, tweetID, keyword;
  final TweetData? mainTweetForComments;

  const BetterFeed({
    super.key,
    required this.removeController,
    required this.removeRefreshIndicator,
    required this.providerFunction,
    required this.providerResultType,
    required this.feedController,
    this.userId,
    this.userName,
    this.tweetID,
    this.keyword,
    this.cancelNavigationToUserProfile = false,
    this.mainTweetForComments,
    this.filterBlockedUsers = false,
  });

  @override
  State<BetterFeed> createState() => _BetterFeedState();
}

class _BetterFeedState extends State<BetterFeed> {
  late FeedController _feedController;
  late Timer timer;
  ScrollController? _scrollController;

  /// Refreshes the feed to follow any occurred updates happened
  Future<void> refreshFeed() async {
   await _feedController.fetchFeedData(
        username: widget.userId,
        tweetID: widget.tweetID,
        keyword: widget.keyword,
        mainTweet: widget.mainTweetForComments
    );
   try {
     if (context.mounted) {
       setState(() {});
     }
   } catch(e){
     if (kDebugMode) {
       print("Handled");
     }
   }
  }


  /// Navigates to add post page and recieve a tweet if it was added it adds it back to the comments feed data
  Future<void> addComment(BuildContext context,TweetData tweetData) async {
    dynamic retArguments = await Navigator.pushNamed(context, CreatePostPage.pageRoute , arguments: {
      "reply" : tweetData,
    });

    if(retArguments["success"] != null && retArguments["success"] == true){

      List<TweetData> tweetList = retArguments["tweets"];
      if(
      widget.providerFunction == ProviderFunction.GET_TWEET_COMMENTS
      &&
      widget.tweetID! == tweetData.id
      ){
        Map<String,TweetData> mappedTweets = {};
        for (TweetData tweetData in tweetList){
          mappedTweets.putIfAbsent(tweetData.id, () => tweetData);
        }
        _feedController.appendToBegin(mappedTweets);
      }

      tweetData.repliesNum += 1;
      setState(() {});
    }
  }

  /// makes a Tweet widget from given tweet data
  /// [tweetData] : data of the tweet to be shown
  /// [currentUser] : currently logged in user data
  /// [isSinglePostView] : boolean to show the tweet in special form if it was the main tweet to be shown in comments
  /// [addVerticalDivider] : adds vertical divier below user avatar
  /// [cancellationPosition] : if true it will stop navigating to the [currentUser] profile when pressing the avatar
  /// [sameUser] : true if tweet owner is the same as the current user
  /// return a Tweet Widget of the passed data
  Tweet makeTweetFromData({
    required TweetData tweetData,
    required User currentUser,
    required bool isSinglePostView,
    required bool addVerticalDivider,
    required bool cancellationPosition,
    required bool sameUser
  }){
        return Tweet(
        tweetOwner: tweetData.tweetOwner,
        tweetData: tweetData,
        isRetweet: tweetData.isRetweeted,
        isSinglePostView: isSinglePostView,
        callBackToDelete: (String tweetID){
          _feedController.deleteTweet(tweetID);
          setState(() {});
        },
        showVerticalDivider: addVerticalDivider,
        deleteOnUndoRetweet: widget.providerFunction == ProviderFunction.PROFILE_PAGE_TWEETS && (widget.userId! == currentUser.id),
        onCommentButtonClicked: () => addComment(context, tweetData),
        parentFeed: _feedController,
        cancelSameUserNavigation: cancellationPosition && sameUser
      );
  }


  /// convert data to widgets to be shown
  List<Widget>? wrapDataInWidget() {
    switch(widget.providerResultType){
      // The Result Of Searching For User
      case ProviderResultType.USER_RESULT:
        return wrapDataInUserWidgets();
      // The Normal View For Tweets
      case ProviderResultType.TWEET_RESULT:
        return wrapDataInTweetWidgets();
      case ProviderResultType.TREND_RESULT:
        return wrapDataInTrendWidgets();
    }
  }

  /// wraps feed controller current data into UserResult Widget
  List<Widget>? wrapDataInUserWidgets(){
    List<User> userResult = _feedController.getCurrentData().cast<User>();
    if (widget.filterBlockedUsers){
      userResult.removeWhere((User user) => user.isWantedUserBlocked ?? false);
    }
    return userResult.map((User user){
      return UserResult(user: user, disableFollowButton: false);
    }).toList();
  }

  /// wraps feed controller current data into Tweet Widget
  List<Widget>? wrapDataInTweetWidgets(){
    List<TweetData> tweetResult = _feedController.getCurrentData().cast<TweetData>();
    bool addVerticalDivider = true;
    List<Tweet> resultWidgets = [];
    for (TweetData tweetData in tweetResult){
      if(widget.providerFunction == ProviderFunction.PROFILE_PAGE_TWEETS){
        tweetData.reTweeter = User(name: widget.userName!, id: widget.userId!);
      }
      User currentUser = Auth.getInstance(context).getCurrentUser()!;

      bool cancellationPosition = (widget.providerFunction == ProviderFunction.PROFILE_PAGE_TWEETS || widget.cancelNavigationToUserProfile != null);
      bool sameUser = tweetData.tweetOwner.id == currentUser.id;
      bool isSinglePostView = widget.providerFunction == ProviderFunction.GET_TWEET_COMMENTS && tweetData.id == widget.mainTweetForComments!.id;

      addVerticalDivider &= (!isSinglePostView && widget.providerFunction == ProviderFunction.GET_TWEET_COMMENTS);

      resultWidgets.add(
          makeTweetFromData(
              tweetData: tweetData,
              isSinglePostView: isSinglePostView,
              addVerticalDivider: addVerticalDivider || (tweetData.replyTweet != null && widget.providerFunction == ProviderFunction.GET_TWEET_COMMENTS),
              cancellationPosition: cancellationPosition,
              sameUser: sameUser,
              currentUser: currentUser
          ));

      if (tweetData.replyTweet != null &&
          widget.providerFunction == ProviderFunction.GET_TWEET_COMMENTS &&
          !isSinglePostView){

        resultWidgets.add(
            makeTweetFromData(
                tweetData: tweetData.replyTweet!,
                isSinglePostView: false,
                addVerticalDivider: false,
                cancellationPosition: cancellationPosition,
                sameUser: sameUser,
                currentUser: currentUser
            ));
      }
    }
    return resultWidgets;
  }

  /// wraps feed controller current data into Trend Widgets
  List<Widget>? wrapDataInTrendWidgets(){
    List<TrendData> trendResult = _feedController.getCurrentData().cast<TrendData>();
    return trendResult.map((trendData) => TrendWidget(trendData: trendData)).toList();
  }

  @override
  void initState() {
    super.initState();
    _feedController = widget.feedController;
    _feedController.fetchingMoreData = false;
    _feedController.setUserToken(Auth.getInstance(context).getCurrentUser()!.auth);
    timer = Timer(const Duration(seconds: 1), () { });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (InternalHomePage.getScrollGlobalKey(context) == null){
        _scrollController = ScrollController();
      }
      else{
        _scrollController = InternalHomePage.getScrollGlobalKey(context)!.currentState!.innerController;
      }
      _scrollController!.addListener(() async {
        if (_scrollController!.position.pixels == _scrollController!.position.maxScrollExtent)
        {
          _feedController.fetchingMoreData = true;
          if (context.mounted) {
            setState(() {});
          }
          await refreshFeed();
          _feedController.fetchingMoreData = false;

          if (context.mounted) {
            setState(() {});
          }
        }
      });
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedProvider>(
        builder: (_,__,___){

          if (_feedController.isLoading()){
            refreshFeed();
            return SizedBox(
                height: MediaQuery.of(context).size.height,
                child: const Center(child: CircularProgressIndicator())
            );
          }

          List<Widget>? widgetList = wrapDataInWidget();

          Widget finalWidget = Container();

          if(widgetList == null || widgetList.isEmpty)
          {
            finalWidget = SingleChildScrollView(
                child: SizedBox(
                    height: 0.8 * MediaQuery.of(context).size.height,
                    child: const NothingYet()
                )
            );
          }
          else{
            finalWidget = SingleChildScrollView(
              controller: widget.removeController == true ? null : _scrollController,
              child: Column(
                  children: [
                    ...widgetList,
                    Visibility(visible: _feedController.fetchingMoreData, child: const CircularProgressIndicator()),
                    const SizedBox(height: 10,)
                  ]
              ),
            );
          }

          finalWidget = widget.removeRefreshIndicator ? finalWidget :
              RefreshIndicator(
                  child: finalWidget,
                  onRefresh: () async {
                    _feedController.resetFeed();
                    setState(() {});
                  }
              );
          return finalWidget;
        }
    );

  }

}
