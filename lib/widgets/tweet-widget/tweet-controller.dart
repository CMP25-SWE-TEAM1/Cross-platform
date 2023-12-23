import 'package:flutter/material.dart';
import 'package:gigachat/api/tweet-data.dart';
import 'package:gigachat/api/tweets-requests.dart';
import 'package:gigachat/api/user-class.dart';
import 'package:gigachat/pages/create-post/create-post-page.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/util/Toast.dart';
import 'package:gigachat/widgets/feed-component/feed-controller.dart';

Future<bool> toggleLikeTweet(BuildContext context,String? token,TweetData tweetData) async {
  if (token == null) {
    Navigator.popUntil(context, (route) => route.isFirst);
    return false;
  }

  bool isLikingTweet = !tweetData.isLiked;
  try {
    bool success = isLikingTweet ?
    await Tweets.likeTweetById(token, tweetData.id) :
    await Tweets.unlikeTweetById(token, tweetData.id);

    if (success) {
      tweetData.isLiked = isLikingTweet;
      tweetData.likesNum += tweetData.isLiked ? 1 : -1;
    }
    return success;
  }
  catch(e){
    if (context.mounted) {
      Toast.showToast(context, e.toString());
    }
    return false;
  }
}


Future<bool> toggleRetweetTweet(String? token,TweetData tweetData) async {
  if (token == null){
    return false;
  }

  bool isRetweeting = !tweetData.isRetweeted;
  bool success = isRetweeting ?
  await Tweets.retweetTweetById(token, tweetData.id) :
  await Tweets.unretweetTweetById(token, tweetData.id);
  if (success)
  {
    tweetData.isRetweeted = isRetweeting;
    tweetData.repostsNum += tweetData.isRetweeted ? 1 : -1;
  }
  return success;
}

bool canBeAppended(String tweetID, String parentFeedId, String currentUserId){
  List<String> splittedPath = parentFeedId.split("/");
  if (splittedPath.length > 1 && (splittedPath[1] == tweetID || splittedPath[1] == currentUserId)){
    return true;
  }
  else{
    return false;
  }

}

Future<int> commentTweet(BuildContext context, TweetData tweetData, FeedController? targetFeed) async {
  User currentUser = Auth.getInstance(context).getCurrentUser()!;
  dynamic retArguments = await Navigator.pushNamed(context, CreatePostPage.pageRoute , arguments: {
    "reply" : tweetData,
  });
  if(retArguments["success"] != null && retArguments["success"] == true){
    tweetData.repliesNum += 1;
    List<TweetData> tweets = retArguments["tweets"];
    if(targetFeed != null && canBeAppended(tweetData.id, targetFeed.id, currentUser.id)) {
      Map<String, TweetData> mappedTweets = {};
      for (TweetData tweetData in tweets) {
        mappedTweets.putIfAbsent(tweetData.id, () => tweetData);
      }
      targetFeed.appendToLast(mappedTweets);
    }
  }
  return tweetData.repliesNum;
}
