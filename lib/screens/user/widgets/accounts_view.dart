import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:itis_cards/models/user.dart';
import 'package:itis_cards/services/accounts.dart';

class AccountsView extends StatefulWidget {
  final User user;
  AccountsView({Key key, this.user}) : super(key: key);
  _AccountsViewState createState() => _AccountsViewState();
}

class _AccountsViewState extends State<AccountsView> {
  Widget buildAccounts() {
    List<Widget> accounts = <Widget>[];
    widget.user.accounts.socials.forEach((k, v) {
      if ((v as String).isNotEmpty)
        accounts.add(Row(
          children: <Widget>[
            Icon(Accounts.socials[k]["icon"], size: 36.0),
            Container(
              constraints: BoxConstraints.expand(height: 36.0),
              child: FittedBox(
                fit: BoxFit.cover,
                alignment: Alignment.centerLeft,
                child: Text(v),
              ),
            ),
          ],
        ));
    });

    widget.user.accounts.messengers.forEach((k, v) {
      if ((v as String).isNotEmpty)
        accounts.add(Row(
          children: <Widget>[
            Icon(Accounts.messengers[k]["icon"], size: 36.0),
            Container(
              constraints: BoxConstraints.expand(height: 36.0),
              child: FittedBox(
                fit: BoxFit.cover,
                alignment: Alignment.centerLeft,
                child: Text(v),
              ),
            ),
          ],
        ));
    });
    return Column(children: accounts);
  }

  @override
  Widget build(BuildContext context) {
    return buildAccounts();
  }
}
