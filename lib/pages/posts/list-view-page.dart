import 'package:flutter/material.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/providers/feed-provider.dart';
import 'package:gigachat/widgets/feed-component/FeedWidget.dart';
import 'package:gigachat/widgets/feed-component/feed-controller.dart';

/// view list of users in a scrollable column
/// these data must be passed in context arguments when navigating
/// [pageTitle] : page title shown in app bar
/// [tweetID] : id of the tweet in case of viewing likers or retweeters to cache data
/// [userID] : id of the user in case of viewing followers or followings
/// [providerFunction]: which api function to call and fetch data
class UserListViewPage extends StatefulWidget {
  static const pageRoute = "/list-view";
  static const feedID = "USER_LIST_FEED/";

  const UserListViewPage({super.key});

  @override
  State<UserListViewPage> createState() => _UserListViewPageState();
}

class _UserListViewPageState extends State<UserListViewPage> {
  late ProviderFunction providerFunction;
  String? pageTitle;
  String? tweetID;
  String? userID;
  late FeedController feedController;
  late bool firstBuild;

  @override
  void initState() {
    firstBuild = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Map<String,dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String,dynamic>;
    pageTitle = args["pageTitle"];
    tweetID = args["tweetID"];
    userID = args["userID"];
    providerFunction = args["providerFunction"];
    String userToken = Auth.getInstance(context).getCurrentUser()!.auth!;


    feedController = FeedProvider.getInstance(context).getFeedControllerById(
        context: context,
        id: UserListViewPage.feedID + providerFunction.toString() + (userID ?? "") + (tweetID ?? ""),
        providerFunction: providerFunction,
        clearData: firstBuild,
    );
    firstBuild = false;

    feedController.setUserToken(userToken);

    return Scaffold(
      appBar: AppBar(
        title: Text(
            pageTitle ?? "",
            style: const TextStyle(fontWeight: FontWeight.bold)
        ),
      ),

      body: BetterFeed(
          removeController: false,
          removeRefreshIndicator: false,
          providerFunction: providerFunction,
          providerResultType: ProviderResultType.USER_RESULT,
          feedController: feedController,
          tweetID: tweetID,
          userId: userID,
      ),
    );
  }
}


