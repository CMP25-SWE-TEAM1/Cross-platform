import 'package:flutter/material.dart';
import 'package:gigachat/pages/home/home-page-tab.dart';
import 'package:gigachat/pages/home/pages/explore/subPages/explore-setting-page.dart';
import 'package:gigachat/pages/home/widgets/home-app-bar.dart';
import 'package:gigachat/pages/search/search.dart';
import 'package:gigachat/widgets/feed-component/feed-controller.dart';
import 'package:gigachat/widgets/trends/trends-tab.dart';

/// the Trends home page tab
/// it defined how the trends page should
/// look like for the home page
class Explore with HomePageTab {
  @override
  List<AppBarAction> getActions(BuildContext context) {
    return [
      AppBarAction(icon: Icons.settings, onClick: () => {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SettingPage(),
          ),
        )
      })
    ];
  }

  @override
  AppBarSearch? getSearchBar(BuildContext context) {
    return AppBarSearch(hint: "Search", onClick: () {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return const SearchPage();
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var tween = Tween(begin: 0.0, end: 1.0);
            var fadeAnimation = tween.animate(animation);
            return FadeTransition(
              opacity: fadeAnimation,
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  AppBarTabs? getTabs(BuildContext context) {
    return AppBarTabs(tabs: ["Trending"], indicatorSize: TabBarIndicatorSize.label, tabAlignment: TabAlignment.center);
  }

  @override
  String? getTitle(BuildContext context) {
    return null;
  }

  @override
  List<Widget>? getTabsWidgets(BuildContext context,{FeedController? feedController}) {
    return const <Widget>[
      TrendsTab()
    ];
  }

  @override
  Widget? getPage(BuildContext context) {
    //if I didn't use tabs .. this will be called instead of getTabsWidgets()
    return Placeholder();
  }

  @override
  bool isAppBarPinned(BuildContext context) {
    return true;
  }

}


/// a trends list item, it takes 3 parameters
/// [place] which the the location of this trend
/// [trendString] which the text or the trending word
/// [postsNumbers] which is the number or score this trend has
class TrendItem extends StatelessWidget { // item for each notification
  final String place;
  final String trendString;
  final String postsNumbers;


  TrendItem({
    required this.place,
    required this.trendString,
    required this.postsNumbers,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$place . Trending',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          SizedBox(height: 5),
          Text('$trendString',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              )),
          SizedBox(height: 5),
          Text('$postsNumbers posts',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
    ]);
  }
}

/// preview , not used anymore
class Trending extends StatelessWidget {
  const Trending({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.all(20),
          child: ListView(
            children: [
              TrendItem(
                place: '1',
                trendString: 'Midterm_Exams',
                postsNumbers: '15k',
              ),
              SizedBox(height: 15),
              TrendItem(
                place: '2',
                trendString: 'Final_Exams',
                postsNumbers: '19k',
              ),

            ],
          ),
        ),
      ),
    );
  }
}


/// this page displays an empty message for the user
/// when this is no content to display
class NothingYet extends StatelessWidget {
  const NothingYet({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/done.png',
          height: 150, // Adjust the height as needed
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        SizedBox(height: 40),
        Text(
          'Nothing to see here — yet',
          style: TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10),
        Text(
          "why don't you go touch some grass till someone do something.",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

