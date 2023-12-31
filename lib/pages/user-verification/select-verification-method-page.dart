import 'package:flutter/material.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/blocking-loading-page.dart';
import 'package:gigachat/pages/user-verification/verification-code-page.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/util/contact-method.dart';
import 'package:gigachat/widgets/auth/auth-app-bar.dart';
import 'package:gigachat/widgets/text-widgets/page-description.dart';
import 'package:gigachat/widgets/auth/auth-footer.dart';
import 'package:gigachat/widgets/text-widgets/page-title.dart';

const String CONFIRMATION_METHOD_TITLE =
    "Where should we send a confirmation code?";
const String CONFIRMATION_METHOD_DESCRIPTION =
    "Before you can change your password,"
    " we need to make sure it's really you \n \nStart by choosing where to send a confirmation code";

///This is where the user choose the verification method (what email to send the verification code to)
class VerificationMethodPage extends StatefulWidget {
  String pageRoute = "/test";
  List<ContactMethod> methods;
  bool isLogged;

  VerificationMethodPage({super.key, required this.methods, required this.isLogged});

  @override
  State<VerificationMethodPage> createState() => _VerificationMethodPageState();
}

class _VerificationMethodPageState extends State<VerificationMethodPage> {
  late List<ContactMethod> methods;
  ContactMethod? selectedMethod;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    methods = widget.methods;
    selectedMethod = methods[0];
  }

  void _requestVerify(ContactMethod m) async {
    setState(() {
      _loading = true;
    });

    Auth auth = Auth.getInstance(context);

    auth.forgotPassword(
      m ,
      success: (res) {
        setState(() {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => VerificationCodePage(
                isLogged: widget.isLogged,
                isRegister: false,
                isVerify: false,
                method: m,
              ),
            ),
          );
        });
      },
      error: (res) {
        setState(() {
          _loading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const BlockingLoadingPage();
    }

    return Scaffold(
      appBar: AuthAppBar(
        context,
        leadingIcon: IconButton(
          onPressed: () {
            widget.isLogged? Navigator.pop(context) :
            Navigator.popUntil(context, ModalRoute.withName('/')
            );
          },
          icon: widget.isLogged? const Icon(Icons.arrow_back): const Icon(Icons.close),
        ),
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 600,
          ),
          child: Padding(
            padding: const EdgeInsets.all(LOGIN_PAGE_PADDING),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PageTitle(title: CONFIRMATION_METHOD_TITLE),
                const SizedBox(height: 20),
                const PageDescription(
                    description: CONFIRMATION_METHOD_DESCRIPTION),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: methods
                      .map((method) => RadioListTile(
                            title: Text(method.title,
                                style: contactTextStyle()),
                            subtitle: Text(method.disc,
                                style: contactTextStyle()),
                            toggleable: false,
                            activeColor: Colors.blue,
                            contentPadding: const EdgeInsets.all(0),
                            groupValue: selectedMethod,
                            value: method,
                            controlAffinity: ListTileControlAffinity.trailing,
                            onChanged: (change) {
                              setState(() {
                                selectedMethod = change;
                              });
                            },
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: AuthFooter(
        rightButtonLabel: "Next",
        disableRightButton: false,
        onRightButtonPressed: (){
          _requestVerify(selectedMethod!);
        },

        leftButtonLabel: "",
        onLeftButtonPressed: (){},
        showLeftButton: false,
      )
    );
  }
}

TextStyle contactTextStyle() {
  return const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 18,
  );
}
