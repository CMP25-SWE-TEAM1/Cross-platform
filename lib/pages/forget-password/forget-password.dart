import 'package:flutter/material.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/forget-password/confirm-email.dart';
import 'package:gigachat/services/input-validations.dart';
import 'package:gigachat/util/contact-method.dart';
import 'package:gigachat/widgets/auth/auth-app-bar.dart';
import 'package:gigachat/widgets/text-widgets/page-description.dart';
import 'package:gigachat/widgets/auth/auth-footer.dart';
import 'package:gigachat/widgets/text-widgets/page-title.dart';
import 'package:gigachat/widgets/auth/input-fields/username-input-field.dart';
import '../user-verification/select-verification-method-page.dart';

List<ContactMethod> getUserContactMethods(String email) {
  // TODO: move this function to Auth provider
  // TODO: email must be hidden by stars
  return [
    ContactMethod(contactWay: "Send an email to", contactTarget: email),
    ContactMethod(contactWay: "Send an email to", contactTarget: email),
    ContactMethod(contactWay: "Send an email to", contactTarget: email),
    ContactMethod(contactWay: "Send an email to", contactTarget: email),
    ContactMethod(contactWay: "Send an email to", contactTarget: email),
    ContactMethod(contactWay: "Send an email to", contactTarget: email),
    ContactMethod(contactWay: "Send an email to", contactTarget: email),
  ];
}

const String FORGET_PASSWORD_DESCRIPTION = "Enter the email, phone number, or "
    "username associated with your account to change the password.";

class ForgetPassword extends StatefulWidget {
  static const String pageRoute = "/forget-password";

  String? username;

  ForgetPassword({super.key, this.username});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  late String email;
  late bool valid;

  @override
  void initState() {
    super.initState();
    email = widget.username ?? "";
    valid = email.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AuthAppBar(
        context,
        leadingIcon: IconButton(
          onPressed: () {
            Navigator.popUntil(context, ModalRoute.withName('/'));
          },
          icon: Icon(Icons.close),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(LOGIN_PAGE_PADDING),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageTitle(title: "Find your GIGACHAT account"),
            const SizedBox(height: 10),
            const PageDescription(description: FORGET_PASSWORD_DESCRIPTION),
            const SizedBox(height: 20),
            TextDataFormField(
                onChange: (value) {
                  setState(() {
                    email = value;
                    valid = value.isNotEmpty;
                  });
                },
                value: email),
            const Expanded(child: SizedBox()),

            AuthFooter(
              rightButtonLabel: "Next",
              disableRightButton: !valid,
              onRightButtonPressed: (){
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                      InputValidations.isValidEmail(email) == null
                          ? VerificationMethodPage(
                          methods: getUserContactMethods(email))
                          : ConfirmEmailPage(username: email)));

              },

              leftButtonLabel: "",
              onLeftButtonPressed: (){},
              showLeftButton: false,
            )
          ],
        ),
      ),
    );
  }
}
