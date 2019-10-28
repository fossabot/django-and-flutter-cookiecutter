import 'package:flushbar/flushbar.dart';
import 'package:flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_drf/localization.dart';
import 'package:flutter_drf/models/user_model.dart';
import 'package:flutter_drf/pages/signin_page.dart';
import 'package:flutter_drf/widgets/app_bar.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HomeScreenState();
  }
}

class HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _pageToDisplay(BuildContext context, UserModel model) {
    if (model.errMessage != null) {
      showInSnackBar(model);
    }
    if (model.isLoading) {
      return _loadingView;
    } else if (!model.isLoading && model.token == null) {
      return SigninPage();
    } else {
      return _homeView(model);
    }
  }

  Widget get _loadingView {
    return Center(
      child: SpinKitHourGlass(color: Colors.white),
    );
  }

  Widget _homeView(UserModel model) {
    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height >= 775.0 ? MediaQuery.of(context).size.height : 775.0,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Text(
                ScopedModelLocalizations().welcome,
                style: Theme.of(context).textTheme.headline,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showInSnackBar(UserModel model) {
    FocusScope.of(context).requestFocus(FocusNode());
    _scaffoldKey.currentState?.removeCurrentSnackBar();
    Flushbar errorflush = FlushbarHelper.createError(
      message: model.errMessage,
      duration: Duration(seconds: 8),
    );
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: errorflush,
      duration: Duration(seconds: 8),
    ));
    model.errMessageNull = true;
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<UserModel>(builder: (context, child, model) {
      return Scaffold(
        appBar: scopedAppBar(model),
        key: _scaffoldKey,
        body: Stack(
          children: <Widget>[_pageToDisplay(context, model)],
        ),
      );
    });
  }
}
