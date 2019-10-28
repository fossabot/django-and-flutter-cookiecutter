import 'package:flutter/material.dart';
import 'package:flutter_drf/models/user_model.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

Widget scopedAppBar(UserModel model) {
  return AppBar(
    title: Image.asset('images/django.png', fit: BoxFit.contain, height: 40),
    backgroundColor: Colors.grey[900],
    primary: true,
    elevation: 0.0,
    centerTitle: true,
    actions: model.isSignedIn
        ? <Widget>[
            IconButton(
              icon: Icon(MdiIcons.logoutVariant),
              iconSize: 30,
              onPressed: () => model.signout(),
            ),
            Padding(
              padding: EdgeInsets.only(right: 20),
            )
          ]
        : [],
  );
}
