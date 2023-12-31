import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/providers/theme-provider.dart';
import 'package:gigachat/widgets/feed-component/FeedWidget.dart';
import 'package:gigachat/widgets/feed-component/feed-controller.dart';


/// page to view the result of the search
/// the result can be both users and tweets
/// consists of two feeds, one for the result of searching for users and one for searching for the tweets
/// if the search data consists of one tag it will be searched as trend search
/// else will match the given keyword directly
/// data is passed in context arguments using [keyword] key
class SearchResultPage extends StatefulWidget {
  static const String pageRoute = "/search/result";
  static const String userSearchFeed = "userSearchFeed";
  static const String tweetSearchFeed = "tweetSearchFeed";
  const SearchResultPage({super.key});

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  late FeedController latestFeedController;
  late FeedController userFeedController;

  @override
  void initState() {
    latestFeedController = FeedController(
        context,
        id: SearchResultPage.tweetSearchFeed,
        providerFunction: ProviderFunction.SEARCH_TWEETS
    );
    userFeedController = FeedController(
        context,
        id: SearchResultPage.userSearchFeed,
        providerFunction: ProviderFunction.SEARCH_USERS
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    latestFeedController.setUserToken(Auth.getInstance(context).getCurrentUser()!.auth);
    userFeedController.setUserToken(Auth.getInstance(context).getCurrentUser()!.auth);
    Map<String,dynamic> arguments = ModalRoute.of(context)!.settings.arguments as Map<String,dynamic>;
    String keyword = arguments["keyword"];
    bool isDarkMode = ThemeProvider.getInstance(context).isDark();
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: Row(
            children: [
              Expanded(child: FilledButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                style: FilledButton.styleFrom(
                  foregroundColor: isDarkMode ? null : Colors.black,
                  backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[200],
                  alignment: Alignment.centerLeft,
                ),
                child: Text(keyword),

              )),
              IconButton(
                  onPressed: (){},
                  splashRadius: 20,
                  icon: const Icon(FontAwesomeIcons.sliders,size: 20,)
              ),
              IconButton(
                  onPressed: (){},
                  icon: const Icon(Icons.more_vert,size: 20,)
              ),

            ],
          ),
          bottom: const TabBar(
            tabAlignment: TabAlignment.start,
            isScrollable: true,
            tabs: <Widget>[
              Tab(text: "Top"),
              Tab(text: "People"),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            BetterFeed(
                providerFunction: ProviderFunction.SEARCH_TWEETS,
                providerResultType: ProviderResultType.TWEET_RESULT,
                feedController: latestFeedController,
                keyword: keyword,
                removeController: false,
                removeRefreshIndicator: false,
            ),
            BetterFeed(
                providerFunction: ProviderFunction.SEARCH_USERS,
                providerResultType: ProviderResultType.USER_RESULT,
                feedController: userFeedController,
                keyword: keyword,
                removeController: false,
                removeRefreshIndicator: false,
                filterBlockedUsers: true,
            ),
          ],
        ),
      ),
    );
  }
}
