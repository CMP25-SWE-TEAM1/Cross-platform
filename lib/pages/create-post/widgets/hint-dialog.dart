import 'package:flutter/material.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/providers/local-settings-provider.dart';

class HintDialog extends StatefulWidget {
  const HintDialog({super.key});

  @override
  State<HintDialog> createState() => _HintDialogState();
}

class _HintDialogState extends State<HintDialog> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 160 , horizontal: CREATE_POST_POPUP_PADDING),
        child: Center(
          child: Container(
            alignment: Alignment.topCenter,
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(25),
                bottom: Radius.circular(25),
              ),
            ),
            padding: EdgeInsets.zero,
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            width: width - CREATE_POST_POPUP_PADDING * 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  "assets/create-post-popup.jpg",
                  fit: BoxFit.cover,
                ),

                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Photos, videos, and GIFs - in one post" ,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "We are testing a feature that lets you add multiple types of media to a single post. Go ahead, mix things up." ,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 20,
                    ),
                  ),
                ),

                const Expanded(child: SizedBox()),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25))
                      )
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      LocalSettings.getInstance(context).setValue(name: "create-post-popup", val: false);
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40 , vertical: 10),
                      child: Text(
                        "Got it",
                        style: TextStyle(
                          fontSize: 30,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.black54,
    );
  }
}
