import 'package:flushbar/flushbar.dart';
import 'package:flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_drf/localization.dart';
import 'package:flutter_drf/models/user_model.dart';
import 'package:flutter_drf/utils/bubble_indication_painter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:validators/sanitizers.dart';
import 'package:validators/validators.dart';

class SigninPage extends StatefulWidget {
  SigninPage({Key key}) : super(key: key);

  @override
  _SigninPageState createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final FocusNode focusNodeEmailLogin = FocusNode();
  final FocusNode focusNodePasswordLogin = FocusNode();

  final FocusNode focusNodePassword = FocusNode();
  final FocusNode focusNodePasswordConfirmation = FocusNode();
  final FocusNode focusNodeEmail = FocusNode();
  final FocusNode focusNodeName = FocusNode();

  final FocusNode focusNodeForgot = FocusNode();

  TextEditingController loginEmailController = TextEditingController();
  TextEditingController loginPasswordController = TextEditingController();

  bool _obscureTextLogin = true;
  bool _obscureTextSignup = true;
  bool _obscureTextSignupConfirm = true;

  TextEditingController signupEmailController = TextEditingController();
  TextEditingController signupNameController = TextEditingController();
  TextEditingController signupPasswordController = TextEditingController();
  TextEditingController signupConfirmPasswordController = TextEditingController();

  TextEditingController forgotPasswordController = TextEditingController();

  PageController _pageController;

  final _signinFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();
  final _forgotFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<UserModel>(builder: (context, child, model) {
      return Scaffold(
        resizeToAvoidBottomPadding: false,
        key: _scaffoldKey,
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowGlow();
          },
          child: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height >= 775.0 ? MediaQuery.of(context).size.height : 775.0,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Text(
                    ScopedModelLocalizations().welcometext,
                    style: Theme.of(context).textTheme.headline,
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 5.0),
                    child: _buildMenuBar(context),
                  ),
                  Expanded(
                    flex: 2,
                    child: PageView(
                      controller: _pageController,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 0.0, bottom: 0.0, left: 25.0, right: 25.0),
                          child: ConstrainedBox(
                            constraints: BoxConstraints.expand(),
                            child: Form(key: _signinFormKey, child: _buildSignIn(context, model)),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 0.0, bottom: 0.0, left: 25.0, right: 25.0),
                          child: ConstrainedBox(
                            constraints: BoxConstraints.expand(),
                            child: Form(key: _signupFormKey, child: _buildSignUp(context, model)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    focusNodePassword.dispose();
    focusNodeEmail.dispose();
    focusNodeName.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _pageController = PageController();
  }

  void showInSnackBar(UserModel model) {
    FocusScope.of(context).requestFocus(FocusNode());
    _scaffoldKey.currentState?.removeCurrentSnackBar();
    Flushbar errorflush = FlushbarHelper.createError(
      message: model.errMessage,
      duration: Duration(seconds: 5),
    );
//    errorflush.show(context);
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: errorflush,
      duration: Duration(seconds: 5),
    ));
    model.errMessageNull = true;
  }

  Widget _buildMenuBar(BuildContext context) {
    return Container(
      width: 400.0,
      height: 50.0,
      transform: Matrix4.translationValues(0.0, 20.0, 0.0),
      child: CustomPaint(
        painter: TabIndicationPainter(pageController: _pageController),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: FlatButton(
                onPressed: _onSignInButtonPress,
                child: Text(
                  ScopedModelLocalizations().existing,
                  style: Theme.of(context).textTheme.subhead,
                ),
              ),
            ),
            Expanded(
              child: FlatButton(
                onPressed: _onSignUpButtonPress,
                child: Text(
                  ScopedModelLocalizations().textnew,
                  style: Theme.of(context).textTheme.subhead,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignIn(BuildContext context, UserModel model) {
    if (model.errMessage != null) {
      showInSnackBar(model);
    }
    return Container(
      padding: EdgeInsets.only(top: 23.0),
      child: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.topCenter,
            overflow: Overflow.visible,
            children: <Widget>[
              Card(
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Container(
                  width: 400.0,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 15.0, bottom: 10.0, left: 25.0, right: 25.0),
                        child: TextFormField(
                          focusNode: focusNodeEmailLogin,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (term) {
                            focusNodeEmailLogin.unfocus();
                            FocusScope.of(context).requestFocus(focusNodePasswordLogin);
                          },
                          controller: loginEmailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              MdiIcons.email,
                              size: 24.0,
                            ),
                            hintText: ScopedModelLocalizations().emailaddress,
                            hintStyle: TextStyle(fontSize: 17.0),
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return ScopedModelLocalizations().emptyvalue;
                            }
                            if (!isEmail(trim(value))) {
                              return ScopedModelLocalizations().validemail;
                            }
                          },
                        ),
                      ),
                      Container(width: 250.0, height: 1.0, color: Colors.grey[600]),
                      Padding(
                        padding: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 25.0, right: 25.0),
                        child: TextFormField(
                          focusNode: focusNodePasswordLogin,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (term) {
                            focusNodePasswordLogin.unfocus();
                          },
                          controller: loginPasswordController,
                          obscureText: _obscureTextLogin,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              MdiIcons.lock,
                              size: 24.0,
                            ),
                            hintText: ScopedModelLocalizations().password,
                            hintStyle: TextStyle(fontSize: 17.0),
                            suffixIcon: GestureDetector(
                              onTap: _toggleLogin,
                              child: Icon(
                                MdiIcons.eye,
                                size: 20.0,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return ScopedModelLocalizations().emptyvalue;
                            }
                            if (!isLength(value, 6)) {
                              return ScopedModelLocalizations().validpassword;
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 25.0, right: 25.0),
                        child: RaisedButton(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 42.0),
                            child: Text(
                              ScopedModelLocalizations().login,
                            ),
                          ),
                          onPressed: () {
                            if (_signinFormKey.currentState.validate()) {
                              model.loginWithEmailAndPassword(
                                  trim(loginEmailController.text), loginPasswordController.text);
                            }
                          },
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: FlatButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(ScopedModelLocalizations().forgotpassword),
                          actions: <Widget>[
                            FlatButton(
                              child: Text(ScopedModelLocalizations().cancel),
                              onPressed: () => Navigator.pop(context, 'Cancel'),
                            ),
                            FlatButton(
                              child: Text(ScopedModelLocalizations().sendemail),
                              onPressed: () {
                                if (_forgotFormKey.currentState.validate()) {
                                  model.sendPasswordResetEmail(trim(forgotPasswordController.text));
                                }
                                Navigator.pop(context, 'SendEmail');
                                FlushbarHelper.createInformation(
                                        message: ScopedModelLocalizations().checkemail, duration: Duration(seconds: 5))
                                    .show(context);
                              },
                            ),
                          ],
                          content: Form(
                            key: _forgotFormKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    focusNode: focusNodeForgot,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (term) {
                                      focusNodeForgot.unfocus();
                                    },
                                    controller: forgotPasswordController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      icon: Icon(
                                        MdiIcons.email,
                                        size: 24.0,
                                      ),
                                      hintText: ScopedModelLocalizations().emailaddress,
                                      hintStyle: TextStyle(fontSize: 17.0),
                                    ),
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return ScopedModelLocalizations().emptyvalue;
                                      }
                                      if (!isEmail(trim(value))) {
                                        return ScopedModelLocalizations().validemail;
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      });
                },
                child: Text(
                  ScopedModelLocalizations().forgotpassword,
                  style: TextStyle(decoration: TextDecoration.underline, fontSize: 16.0),
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUp(BuildContext context, UserModel model) {
    return Container(
      padding: EdgeInsets.only(top: 23.0),
      child: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.topCenter,
            overflow: Overflow.visible,
            children: <Widget>[
              Card(
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Container(
                  width: 400.0,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 25.0, right: 25.0),
                        child: TextFormField(
                            focusNode: focusNodeName,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (term) {
                              focusNodeName.unfocus();
                              FocusScope.of(context).requestFocus(focusNodeEmail);
                            },
                            controller: signupNameController,
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              icon: Icon(
                                MdiIcons.accountCircle,
                                size: 24.0,
                              ),
                              hintText: ScopedModelLocalizations().name,
                              hintStyle: TextStyle(fontSize: 17.0),
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return ScopedModelLocalizations().emptyvalue;
                              }
                            }),
                      ),
                      Container(width: 250.0, height: 1.0, color: Colors.grey[600]),
                      Padding(
                        padding: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 25.0, right: 25.0),
                        child: TextFormField(
                            focusNode: focusNodeEmail,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (term) {
                              focusNodeEmail.unfocus();
                              FocusScope.of(context).requestFocus(focusNodePassword);
                            },
                            controller: signupEmailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              icon: Icon(
                                MdiIcons.email,
                                size: 24.0,
                              ),
                              hintText: ScopedModelLocalizations().emailaddress,
                              hintStyle: TextStyle(fontSize: 17.0),
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return ScopedModelLocalizations().emptyvalue;
                              }
                              if (!isEmail(trim(value))) {
                                return ScopedModelLocalizations().validemail;
                              }
                            }),
                      ),
                      Container(width: 250.0, height: 1.0, color: Colors.grey[600]),
                      Padding(
                        padding: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 25.0, right: 25.0),
                        child: TextFormField(
                            focusNode: focusNodePassword,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (term) {
                              focusNodePassword.unfocus();
                              FocusScope.of(context).requestFocus(focusNodePasswordConfirmation);
                            },
                            controller: signupPasswordController,
                            obscureText: _obscureTextSignup,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              icon: Icon(
                                MdiIcons.lock,
                                size: 24.0,
                              ),
                              hintText: ScopedModelLocalizations().password,
                              hintStyle: TextStyle(fontSize: 17.0),
                              suffixIcon: GestureDetector(
                                onTap: _toggleSignup,
                                child: Icon(
                                  MdiIcons.eye,
                                  size: 20.0,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return ScopedModelLocalizations().emptyvalue;
                              }
                              if (!isLength(value, 6)) {
                                return ScopedModelLocalizations().validpassword;
                              }
                            }),
                      ),
                      Container(width: 250.0, height: 1.0, color: Colors.grey[600]),
                      Padding(
                        padding: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 25.0, right: 25.0),
                        child: TextFormField(
                            focusNode: focusNodePasswordConfirmation,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (term) {
                              focusNodePasswordConfirmation.unfocus();
                            },
                            controller: signupConfirmPasswordController,
                            obscureText: _obscureTextSignupConfirm,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              icon: Icon(
                                MdiIcons.lock,
                                size: 24.0,
                              ),
                              hintText: ScopedModelLocalizations().confirmation,
                              hintStyle: TextStyle(fontSize: 17.0),
                              suffixIcon: GestureDetector(
                                onTap: _toggleSignupConfirm,
                                child: Icon(
                                  MdiIcons.eye,
                                  size: 20.0,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return ScopedModelLocalizations().emptyvalue;
                              }
                              if (!isLength(value, 6)) {
                                return ScopedModelLocalizations().validpassword;
                              }
                              if (value != signupPasswordController.text) {
                                return ScopedModelLocalizations().matchpassword;
                              }
                            }),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 25.0, right: 25.0),
                        child: RaisedButton(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 42.0),
                            child: Text(
                              ScopedModelLocalizations().signup,
                            ),
                          ),
                          onPressed: () {
                            if (_signupFormKey.currentState.validate()) {
                              model.createUserWithEmailAndPassword(signupNameController.text,
                                  trim(signupEmailController.text), signupPasswordController.text);
                            }
                          },
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onSignInButtonPress() {
    _pageController.animateToPage(0, duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  void _onSignUpButtonPress() {
    _pageController?.animateToPage(1, duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  void _toggleLogin() {
    setState(() {
      _obscureTextLogin = !_obscureTextLogin;
    });
  }

  void _toggleSignup() {
    setState(() {
      _obscureTextSignup = !_obscureTextSignup;
    });
  }

  void _toggleSignupConfirm() {
    setState(() {
      _obscureTextSignupConfirm = !_obscureTextSignupConfirm;
    });
  }
}
