import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gigachat/widgets/bottom-sheet.dart';
import 'package:like_button/like_button.dart';
import 'package:intl/intl.dart';

/// Widget of the tweet interaction button (like, retweet, comment)
/// [icon] : icon to be shown in the button
/// [count] : number to be shown in the button
/// [isLikeButton] : is the button a like button or not
/// [isLiked] : is the parent tweet liked
/// [isRetweet] : is this button a retweet button
/// [isRetweeted] : is the parent tweet retweeted or not
/// [onPressed] : call back function on pressing the button
class TweetActionButton extends StatefulWidget {
  final IconData icon;
  int? count;
  final bool? isLikeButton;
  bool isLiked;
  bool isRetweet;
  bool isRetweeted;
  final Function() onPressed;

  TweetActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.isLikeButton,
    this.count,
    required this.isLiked,
    required this.isRetweet,
    required this.isRetweeted
  });

  @override
  State<TweetActionButton> createState() => _TweetActionButtonState();
}

class _TweetActionButtonState extends State<TweetActionButton> {
  @override
  Widget build(BuildContext context) {
    bool hideCount = widget.count == null;
    widget.count ??= 0;

    return widget.isLikeButton!
        ? Expanded(
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.grey,
                  padding: EdgeInsets.zero,
                  elevation: 0,
                  splashFactory: NoSplash.splashFactory),
              child: LikeButton(
                size: 20,
                likeCount: hideCount ? null : widget.count,
                isLiked: widget.isLiked,
                countDecoration: widget.count != null
                    ? (count, likeCount) {
                        likeCount ??= 0;
                        return likeCount < 9999
                            ? null
                            : Text(NumberFormat.compact().format(likeCount));
                      }
                    : null,
                onTap: (isLiked) async {
                  bool tryLike = await widget.onPressed();
                  print(tryLike);
                  if (tryLike) {
                    widget.isLiked = !isLiked;
                    return Future(() => !isLiked);
                  }
                  else{
                    return null;
                  }
                },
              ),
            ),
          )
        : Expanded(
            child: Center(
            child: TextButton.icon(
                style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: !widget.isRetweet || !widget.isRetweeted
                        ? Colors.grey
                        : Colors.greenAccent,
                    padding: EdgeInsets.zero,
                    elevation: 0,
                    splashFactory: NoSplash.splashFactory
                ),
                onPressed: widget.isRetweet
                    ? () async {
                        showCustomModalSheet(context, [
                          [
                            widget.isRetweeted ? "Undo Repost" : "Repost",
                            FontAwesomeIcons.retweet,
                            () async {
                              bool success = await widget.onPressed();
                              widget.count ??= 0;
                              if (success) {
                                    widget.isRetweeted = !widget.isRetweeted;
                                    widget.count = widget.count! + (widget.isRetweeted == true ? 1 : -1);
                                    setState(() {});
                              }
                            }
                          ],
                          [
                            "Quote",
                            FontAwesomeIcons.pen, () {}
                          ],
                        ]);
                      }
                    : widget.onPressed,
                icon: Icon(widget.icon, size: 20),
                label: Visibility(
                    visible: !hideCount,
                    child: Text(
                      NumberFormat.compact().format(widget.count),
                    ))),
          ));
  }
}
