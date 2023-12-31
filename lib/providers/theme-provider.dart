
import 'package:flutter/material.dart';
import 'package:gigachat/pages/home/widgets/tab-indicator.dart';
import 'package:gigachat/providers/local-settings-provider.dart';
import 'package:provider/provider.dart';


/// controls the entire theme of the application
class ThemeProvider extends ChangeNotifier {

  static ThemeProvider getInstance(BuildContext ctx){
    return Provider.of<ThemeProvider>(ctx , listen: false);
  }

  ThemeData _theme;
  String _themeName;

  ThemeData get getTheme {
    return _theme;
  }

  String get getThemeName {
    return _themeName;
  }

  ThemeProvider() : _theme = ThemeData.dark() , _themeName = "dark" {
    init();
  }

  /// initializes the theme form the local files
  void init(){
    _themeName = LocalSettings.instance.getValue(name: "theme", def: "dark")!;
    //now assign the theme based on the name ..
    _updateTheme();
  }

  /// return weather the current theme is dart or not
  bool isDark(){
    return _themeName == "dark";
  }

  /// returns the dark theme data
  ThemeData darkTheme(){
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: Colors.black,
      drawerTheme: ThemeData.dark().drawerTheme.copyWith(
        backgroundColor: Colors.black,
      ),
      inputDecorationTheme: const InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Colors.blueGrey
              )
          )
      ),
      appBarTheme: ThemeData.dark().appBarTheme.copyWith(
        backgroundColor: Colors.black,
        titleTextStyle: const TextStyle(
            color: Colors.white
        ),
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            splashFactory: NoSplash.splashFactory,
            textStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            )
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            side: const BorderSide(
              color: Colors.white,
            )
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.black,
      ),
      tabBarTheme: TabBarTheme(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        labelStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        tabAlignment: TabAlignment.start,
        labelPadding: const EdgeInsets.symmetric(horizontal: 16 ,vertical: 8),
        indicatorSize: TabBarIndicatorSize.label,
        indicator: TabIndicator(),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {TargetPlatform.android: CupertinoPageTransitionsBuilder(),}),
    );
  }

  /// returns the light theme data
  ThemeData lightTheme(){
    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: Colors.white,
      drawerTheme: ThemeData.dark().drawerTheme.copyWith(
        backgroundColor: Colors.white,
      ),
      inputDecorationTheme: const InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Colors.blueGrey
              )
          )
      ),
      appBarTheme: ThemeData.light().appBarTheme.copyWith(
        backgroundColor: Colors.white,
        titleTextStyle: const TextStyle(
            color: Colors.black
        ),
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            splashFactory: NoSplash.splashFactory,
            textStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black,
            side: const BorderSide(
              color: Colors.black,
            )
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
      ),
      tabBarTheme:  TabBarTheme(
        labelColor: Colors.black,
        unselectedLabelColor: Colors.black54,
        labelStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        tabAlignment: TabAlignment.start,
        labelPadding: const EdgeInsets.symmetric(horizontal: 16 ,vertical: 8),
        indicatorSize: TabBarIndicatorSize.label,
        indicator: TabIndicator(),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {TargetPlatform.android: CupertinoPageTransitionsBuilder(),}),

    );
  }


  void _updateTheme(){
    if (_themeName == "dark"){
      _theme = darkTheme();
    }else if (_themeName == "light"){
      _theme = lightTheme();
    }
  }

  /// sets the theme for the entire app
  /// with [theme]
  /// [theme] must be one of :
  /// * "light"
  /// * "dark"
  void setTheme(String theme){
    _themeName = theme;

    LocalSettings settings = LocalSettings.instance;
    settings.setValue(name: "theme", val: theme);
    settings.apply();

    _updateTheme();
    notifyListeners();
  }

}