import 'package:flutter/material.dart';
import 'package:gigachat/pages/blocking-loading-page.dart';
import 'package:gigachat/pages/forget-password/forget-password.dart';
import 'package:gigachat/pages/home/home.dart';
import 'package:gigachat/pages/login/sub-pages/username-page.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/util/Toast.dart';
import 'package:gigachat/widgets/auth/auth-app-bar.dart';
import 'package:gigachat/widgets/auth/auth-footer.dart';
import 'package:gigachat/widgets/text-widgets/page-title.dart';
import 'package:gigachat/widgets/auth/input-fields/password-input-field.dart';

/// This is where the user enters password after [UsernameLoginPage]
class PasswordLoginPage extends StatefulWidget {
  static const String pageRoute = "/login/password";
  static final passwordFieldKey = GlobalKey<FormFieldState>();
  static const loginButtonKey = "login-password-login-button";

  final String username;

  const PasswordLoginPage({required this.username, super.key});

  @override
  State<PasswordLoginPage> createState() => _LoginPasswordPageState();
}

class _LoginPasswordPageState extends State<PasswordLoginPage> {
  String? password;
  bool isValid = false;
  late bool logInPressed;
  late final Auth authProvider;
  late final Toast toast;

  bool _loading = false;

  void _doLogin() async {
    setState(() {
      _loading = true;
    });

    //print("login : {username: ${widget.username} , password: $password");

    await authProvider.login(
      widget.username,
      password!,
      success: (res) {
        Navigator.popUntil(context, (r) => false);
        Navigator.pushNamed(context, Home.pageRoute);
      },
      error: (res){
        Toast.showToast(context,"Wrong password!",width: 20);
        setState(() {
          _loading = false;
        });
      }
    );
  }

  @override
  void initState() {
    super.initState();
    password = "";
    authProvider = Auth.getInstance(context);
    logInPressed = false;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading){
      return const BlockingLoadingPage();
    }


    return Scaffold(
      appBar: AuthAppBar(
        context,
        leadingIcon: IconButton(
          onPressed: () {
            Navigator.popUntil(context, ModalRoute.withName('/'));
          },
          icon: const Icon(Icons.close),
        ),
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 600,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // page Title
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PageTitle(title: "Enter your password"),

                    // empty space
                    const SizedBox(height: 30),

                    // username input field - disabled -
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 15),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 0.5),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(4)),
                            ),
                            child: Text(
                              widget.username,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // empty space
                    const SizedBox(height: 20),

                    // password field
                    PasswordFormField(
                      passwordKey: PasswordLoginPage.passwordFieldKey,
                      hideBorder: true,
                      onChanged: (value) {
                        setState(() {
                          logInPressed = false;
                          password = value;
                          isValid = value.isNotEmpty;
                        });
                      },
                      validator: (value){
                        return value == null || value.isEmpty ? "" : null;
                      },
                      label: "Password",
                    ),
                  ],
                ),
              ),
              const Expanded(child: SizedBox()),

              AuthFooter(
                rightButtonKey: const Key(PasswordLoginPage.loginButtonKey),
                rightButtonLabel: "Log in",
                disableRightButton: !isValid,
                onRightButtonPressed: _doLogin,

                leftButtonLabel: "Forget password?",
                onLeftButtonPressed: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ForgetPassword(username: widget.username,isLogged: false,)));
                  },
                showLeftButton: true,
              )
            ],
          ),
        ),
      ),
    );
  }
}
