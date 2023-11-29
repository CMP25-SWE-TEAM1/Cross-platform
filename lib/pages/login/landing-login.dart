import 'package:flutter/material.dart';
import 'package:gigachat/pages/login/sub-pages/username-page.dart';
import 'package:gigachat/pages/register/landing-register.dart';
import 'package:gigachat/widgets/auth/auth-app-bar.dart';
import 'package:google_fonts/google_fonts.dart';


class LandingLoginPage extends StatelessWidget {
  const LandingLoginPage({Key? key}) : super(key: key);
  static const pageRoute = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AuthAppBar(context, leadingIcon: null, showDefault: false),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(35,35,35,100),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 150,),
              const Text(
                "Welcome back! Log in to see the the latest.",
                style: TextStyle(
                    fontSize: 31,
                    fontWeight: FontWeight.bold
                ),
              ),

              const SizedBox(height: 50,),

              ElevatedButton(
                onPressed: (){
                  // TODO: Authenticate Using Google
                },
                style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    )
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        width: 25,
                        height: 25,
                        child: Image.asset('assets/google-logo-icon.png')
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10,horizontal: 8),
                      child: Text(
                        "Continue with Google",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.blueGrey,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text("or"),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.blueGrey,
                    ),
                  ),
                ],
              ),

              ElevatedButton(
                onPressed: (){
                  Navigator.pushNamed(context, UsernameLoginPage.pageRoute);
                },

                style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    )
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    "Log in",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 35),
        child: SizedBox(
          height: 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      "Don't have an account? ",style: TextStyle(color: Colors.blueGrey),
                    ),
                    GestureDetector(
                      onTap: (){
                        Navigator.pushNamed(context, LandingRegisterPage.pageRoute);
                      },
                      child: Text("Sign up",
                        style: GoogleFonts.dmSans(
                            textStyle: const TextStyle(color: Colors.blue)
                        ),
                      ),
                    )
                  ],
                ),
              ]
          ),
        ),
      ),
    );
  }
}
