import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:itis_cards/app.dart';
import 'package:itis_cards/widgets/itis_scaffold.dart';
import 'package:itis_cards/widgets/uni_header.dart';

class ContactsScreen extends StatefulWidget {
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final GlobalKey<ItisScaffoldState> _itisKey = new GlobalKey<ItisScaffoldState>();
  @override
  void initState() {
    App.pushItisScaffoldKey(_itisKey);
    super.initState();
  }

  @override
  void dispose() {
    App.popItisScaffoldKey();
    super.dispose();
  }

  Widget buildBody() {
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return ItisScaffold(
      key: _itisKey,
      backgroundColor: Colors.white,
      body: Stack(fit: StackFit.expand, children: <Widget>[
        UniHeaderWidget(titleLabel: "Контакты"),
        buildBody(),
      ]),
    );
  }
}
