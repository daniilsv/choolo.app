import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:itis_cards/models/user.dart';
import 'package:itis_cards/services/accounts.dart';
import 'package:itis_cards/widgets/form_input_field.dart';

class AccountsEdit extends StatefulWidget {
  final User user;
  AccountsEdit({Key key, this.user}) : super(key: key);
  _AccountsEditState createState() => _AccountsEditState();
}

class _AccountsEditState extends State<AccountsEdit> {
  Widget buildAccounts() {
    List<Widget> accounts = <Widget>[];
    widget.user.accounts.socials.forEach((k, v) {
      if (v is bool || (v as String).isNotEmpty)
        accounts.add(FormInputField(
          initialValue: v is bool ? "" : v ?? "",
          hint: Accounts.socials[k]["hint"],
          onSaved: (_) {
            if (!(widget.user.accounts.socials[k] is bool) && (_ as String).isNotEmpty)
              widget.user.accounts.socials[k] = _;
            else
              widget.user.accounts.socials.remove(k);
          },
          icon: Icon(Accounts.socials[k]["icon"], size: 36.0),
        ));
    });
    widget.user.accounts.messengers.forEach((k, v) {
      if (v is bool || (v as String).isNotEmpty)
        accounts.add(FormInputField(
          initialValue: v is bool ? "" : v ?? "",
          hint: Accounts.messengers[k]["hint"],
          onSaved: (_) {
            if (!(widget.user.accounts.messengers[k] is bool) && (_ as String).isNotEmpty)
              widget.user.accounts.messengers[k] = _;
            else
              widget.user.accounts.messengers.remove(k);
          },
          icon: Icon(Accounts.messengers[k]["icon"], size: 36.0),
        ));
    });
    return Column(children: accounts);
  }

  Widget buildPendingIcons() {
    List<Widget> icons = <Widget>[];
    Accounts.socials.forEach((k, v) {
      if (widget.user.accounts.socials.containsKey(k) &&
          (widget.user.accounts.socials[k] is bool || (widget.user.accounts.socials[k] as String).isNotEmpty)) return;
      icons.add(InkWell(
        child: Icon(v["icon"], size: 36.0),
        onTap: () => setState(() => widget.user.accounts.socials[k] = true),
      ));
    });
    Accounts.messengers.forEach((k, v) {
      if (widget.user.accounts.messengers.containsKey(k) &&
          (widget.user.accounts.messengers[k] is bool || (widget.user.accounts.messengers[k] as String).isNotEmpty))
        return;
      icons.add(InkWell(
        child: Icon(v["icon"], size: 36.0),
        onTap: () => setState(() => widget.user.accounts.messengers[k] = true),
      ));
    });
    return Padding(
        padding: EdgeInsets.only(top: 18.0),
        child: Wrap(
          spacing: 16.0,
          runSpacing: 16.0,
          children: icons,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        buildAccounts(),
        buildPendingIcons(),
      ],
    );
  }
}
