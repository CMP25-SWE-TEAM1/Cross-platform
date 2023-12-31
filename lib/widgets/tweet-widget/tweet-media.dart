import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gigachat/api/media-class.dart';
import 'package:gigachat/api/tweet-data.dart';
import 'package:gigachat/widgets/single-frame-video-player.dart';
import 'package:gigachat/widgets/feed-component/feed-controller.dart';
import 'full-screen-tweet.dart';

/// UI Representation of the tweet media widget
/// [tweetData] data of the tweet carrying these media
/// [parentFeed] the parent carrying the tweet
class TweetMedia extends StatelessWidget {
  final TweetData tweetData;
  final FeedController? parentFeed;

  const TweetMedia({super.key, required this.tweetData, required this.parentFeed});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    List<MediaData> mediaList = tweetData.media!;
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.elliptical(40,20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: StaggeredGrid.count(
            crossAxisCount: mediaList.length > 1 ? 2 : 1,
            crossAxisSpacing: 0,
            mainAxisSpacing: 0,
            children: List.generate(mediaList.length, (index) => index)
                .map((index) {
              int mainCount = 1;
              int crossCount = 1;
              if (index == 0 && mediaList.length <= 3){
                mainCount = mediaList.length > 1 ? 2 : 1;
              }
              if (index == 1 && mediaList.length == 2){
                mainCount = 2;
              }
              return StaggeredGridTile.count(
                mainAxisCellCount: mainCount,
                crossAxisCellCount: crossCount,
                child: mediaEntity(context, index),
              );
            }).toList()
        ),
      ),
    );
  }

  /// returns the correct ui representation of the media data and place a hero for the images
  /// for transitions
  /// [context] parent widget buildContext
  /// [index] the index of the image in the media list
  Widget mediaEntity(context, index){
    List<MediaData> mediaList = tweetData.media!;
    MediaData imageData = mediaList[index];
    return GestureDetector(
      onTap: (){
        Navigator.pushNamed(context, FullScreenImage.pageRoute,
            arguments: {
              "tweetData": tweetData,
              "index" : index,
              "parentFeed":parentFeed
            });
      },
      child: Hero(
          tag: mediaList[index].tag!,
          child:
          imageData.mediaType == MediaType.VIDEO ?
          SingleFrameVideoPlayer(
            videoUrl: mediaList[index].mediaUrl,
            tag: mediaList[index].tag!,
          )
              :
          Image.network(mediaList[index].mediaUrl,fit: BoxFit.cover)
      ),
    );

  }
}

