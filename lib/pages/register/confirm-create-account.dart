import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gigachat/providers/theme-provider.dart';
import 'package:google_fonts/google_fonts.dart';
class ConfirmCreateAccount extends StatelessWidget {
  const ConfirmCreateAccount({Key? key}) : super(key: key);
  static const pageRoute = '/confirm-create-account';
  @override
  Widget build(BuildContext context) {

    Map accountData = ModalRoute.of(context)!.settings.arguments as Map;

    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 40,
          elevation: 0,
          centerTitle: true,
          title: SizedBox(
            height: 40,
            width: 40,
            child: Image.asset(
              ThemeProvider.getInstance(context).isDark() ? 'assets/giga-chat-logo-dark.png' : 'assets/giga-chat-logo-light.png',
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Create your account",
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0,10,0,50),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: accountData["Name"],
                        readOnly: true,
                        onTap: (){
                          Navigator.pop(context,"Name tapped"); //return back to create account with name in focus
                        },
                        decoration:  const InputDecoration(
                          labelText: "Name",
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.check_circle_sharp,color: CupertinoColors.systemGreen,),
                        ),
                      ),
                      const SizedBox(height: 24,),
                      TextFormField(
                        controller: accountData["Email"],
                        readOnly: true,
                        onTap: (){
                          Navigator.pop(context,"Email tapped"); //return back to create account with email in focus
                        },
                        decoration: const InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.check_circle_sharp,color: CupertinoColors.systemGreen,),
                        ),
                      ),
                      const SizedBox(height: 24,),
                      TextFormField(
                        controller: accountData["DOB"],
                        readOnly: true,
                        onTap: (){
                          Navigator.pop(context,"DOB tapped");  //return back to create account with date in focus
                        },
                        decoration: const InputDecoration(
                          labelText: "Date of birth",
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.check_circle_sharp,color: CupertinoColors.systemGreen,),
                        ),
                      ),
                      const SizedBox(height: 100,),
                      RichText(
                        text:  TextSpan(
                          text: "By signing up, you agree to the ", style: GoogleFonts.dmSans(
                            textStyle: const TextStyle(color: Colors.blueGrey)
                          ),
                          children: [
                            TextSpan(text: "Terms of Service ",style: GoogleFonts.dmSans(
                              textStyle: const TextStyle(color: Colors.blue)
                            )),
                            TextSpan(text: "and ",style: GoogleFonts.dmSans(
                                textStyle: const TextStyle(color: Colors.blueGrey)
                            )),
                            TextSpan(text: "Privacy Policy",style: GoogleFonts.dmSans(
                                textStyle: const TextStyle(color: Colors.blue)
                            )),
                            TextSpan(text: ", including ",style: GoogleFonts.dmSans(
                                textStyle: const TextStyle(color: Colors.blueGrey)
                            )),
                            TextSpan(text: "Cookie Use",style: GoogleFonts.dmSans(
                                textStyle: const TextStyle(color: Colors.blue)
                            )),
                            TextSpan(text: ". Gigachat may use your contact information,"
                                " including your email address and phone number for purposes outlined"
                                " in our Privacy Policy, like keeping your account secure and personalizing our services, including ads. ",
                                style: GoogleFonts.dmSans(
                                    textStyle: const TextStyle(color: Colors.blueGrey)
                                )),
                            TextSpan(text: "Learn More",style: GoogleFonts.dmSans(
                                textStyle: const TextStyle(color: Colors.blue)
                            )),
                            TextSpan(text: ". Others will be able to find you by email or phone number, when provided, "
                                "unless you choose otherwise ",style: GoogleFonts.dmSans(
                                textStyle: const TextStyle(color: Colors.blueGrey)
                            )),
                            TextSpan(text: "here.",style: GoogleFonts.dmSans(
                                textStyle: const TextStyle(color: Colors.blue)
                            )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10,),
                      SizedBox(
                        height: 40,
                        child: TextButton(
                            onPressed: (){
                              Navigator.pop(context,"Confirmed");  //user confirmed his inputs
                            },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(20)),
                                ),
                          ),
                            child: const Text("Sign up",
                              style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                            ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}
