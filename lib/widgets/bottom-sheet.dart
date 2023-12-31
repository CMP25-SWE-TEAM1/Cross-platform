import 'package:flutter/material.dart';
import 'package:gigachat/providers/theme-provider.dart';

/// shows a bottom draggable sheet that contains buttons for user to interact with
/// [context] : buildContext of the parent widget
/// [buttons] : list of lists each list contains three elements ["button text", "button icon", "button callback"]
void showCustomModalSheet(BuildContext context, List<List> buttons) async {
  showModalBottomSheet(
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))
    ),
    context: context,
    builder: (context) => buildSheet(context, buttons),
  );
}

/// makes the column inside the sheet
/// [context] : buildContext of the parent widget
/// [sheetData] : list of lists each list contains three elements ["button text", "button icon", "button callback"]
Widget buildSheet(BuildContext context,List<List> sheetData,) {
  List<Widget> bottomSheetData = sheetData.map((pair) => pair.isEmpty ?
  Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15),
    child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: const Divider(
          color: Colors.grey,
          height: 3,
          thickness: 0.5,
        )
    ),
  ) :
  modalSheetButton(context, pair[0], pair[1],pair[2])).toList();
  return SizedBox(
    width: double.infinity,
    child: ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0,10,0,0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: bottomSheetData,
        ),
      ),
    ),
  );
}


/// build sheet's button
/// [context] : buildContext of the parent widget
/// [content] : text to be written inside the button
/// [icon]    : icon on the leftmost of the button
/// [callbackFunction] : call back function when the button pressed
Widget modalSheetButton(BuildContext context,String content, IconData icon, void Function()? callbackFunction)
{
  bool isDarkMode = ThemeProvider.getInstance(context).isDark();
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Expanded(
        child: TextButton.icon(
          style: TextButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: isDarkMode ? Colors.white : Colors.black,
              elevation: 0,
              padding: const EdgeInsets.all(15),
              alignment: Alignment.centerLeft
          ),
          onPressed: (){
            if (callbackFunction != null) callbackFunction();
            Navigator.pop(context);
          },
          icon: Icon(icon),
          label: Text(content),
        ),
      ),
    ],
  );
}