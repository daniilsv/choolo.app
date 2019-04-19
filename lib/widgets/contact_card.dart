import 'package:flutter/material.dart';
import 'package:itis_cards/models/config.dart';
import 'package:itis_cards/models/user.dart';
import 'package:itis_cards/services/connection.dart';
import 'package:itis_cards/services/query.dart';
import 'package:itis_cards/styles/style.dart';
import 'package:itis_cards/widgets/choolo_icons.dart';
import 'package:itis_cards/widgets/form_input_field.dart';
import 'package:itis_cards/widgets/network_image.dart';

class ContactCard extends StatefulWidget {
  final User user;
  final Map<String, dynamic> userMap;
  final bool isNew;

  ContactCard({this.user, this.userMap, this.isNew = false});

  ContactCardState createState() => ContactCardState();
}

class ContactCardState extends State<ContactCard> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String comment;

  accept() async {
    final FormState form = _formKey.currentState;
    form.save();
    Connection.send("contact.accept", {
      "id": widget.userMap != null ? widget.userMap["user"]["id"] : widget.user.id,
      "comment": comment ?? "",
      "source": widget.userMap["source"],
    });
  }

  reject() {}

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    print(widget.user);
    if (widget.userMap != null) {
      Map<String, dynamic> user = widget.userMap["user"] as Map<String, dynamic>;
      List<Widget> rightBody = <Widget>[
        Padding(
          padding: EdgeInsets.only(bottom: 16.0),
          child: SizedBox(
            height: 60.0,
            width: size.width * 0.45,
            child: FittedBox(
              fit: BoxFit.contain,
              alignment: Alignment.centerLeft,
              child: Text(
                user["name"]["first"] + (user["name"]["second"] != null ? "\n" + user["name"]["second"] : ""),
                style: TextStyle(color: StyleColors.primaryDark, fontSize: 24.0),
              ),
            ),
          ),
        ),
      ];
      if (user.containsKey("company") && user["company"]["title"] != null)
        rightBody.add(SizedBox(
          height: 30.0,
          width: size.width * 0.5,
          child: FittedBox(
            fit: BoxFit.contain,
            alignment: Alignment.centerLeft,
            child: Text(
              user["company"]["title"],
              style: TextStyle(color: StyleColors.primaryDark),
            ),
          ),
        ));
      if (user.containsKey("company") && user["company"]["job"] != null)
        rightBody.add(SizedBox(
          height: 30.0,
          width: size.width * 0.5,
          child: FittedBox(
            fit: BoxFit.contain,
            alignment: Alignment.centerLeft,
            child: Text(
              user["company"]["job"],
              style: TextStyle(color: StyleColors.primaryDark),
            ),
          ),
        ));

      List<Widget> body = <Widget>[
        Positioned(
          top: 15.0,
          left: 15.0,
          child: Container(
            constraints: BoxConstraints(maxWidth: size.width * .27, maxHeight: size.width * .27),
            child: NetworkImageView(
              image: CachedNetworkImage(
                Query.hrefTo(user["photo"] == null ? "" : user["photo"]),
                header: {"auth_token": Config.token},
              ),
              fallbackWidget: Icon(Icons.account_circle, color: StyleColors.secondary),
            ),
          ),
        ),
        Positioned(
          top: 15.0,
          left: size.width * .35,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: rightBody),
        ),
        Positioned(
          left: 15.0,
          bottom: 55.0,
          child: Row(
            children: <Widget>[
              Icon(ChooloIcons.edit_cursor, size: 34.0, color: StyleColors.primaryLight),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: FormInputField(
                  initialValue: comment ?? "",
                  fontSize: 20.0,
                  textColor: StyleColors.primaryLight,
                  hint: "Комментарий",
                  hintSize: 24.0,
                  hintColor: StyleColors.primaryLight,
                  onSaved: (_) => comment = _,
                ),
              ),
            ],
          ),
        ),
        buildButtonsRow(),
      ];
      return Container(
        padding: EdgeInsets.all(16.0),
        height: 300.0,
        child: Material(
          type: MaterialType.card,
          elevation: 5.0,
          child: Form(key: _formKey, child: Stack(children: body)),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Material(
        type: MaterialType.card,
        elevation: 5.0,
        color: StyleColors.white,
        child: Container(
          height: 160.0,
          child: Column(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 150.0, maxHeight: 150.0),
                        child: NetworkImageView(
                          image: CachedNetworkImage(Query.hrefTo("uploads/${User.local.id}.png"),
                              header: {"auth_token": Config.token}),
                          fallbackWidget: Icon(Icons.account_circle, color: Colors.indigo),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: <Widget>[
                            Text(widget.user.name.first,
                                style: (TextStyle(
                                  fontSize: 30.0,
                                  color: Color.fromARGB(255, 55, 55, 55),
                                ))),
                            Text(widget.user.name.second,
                                style: (TextStyle(
                                  fontSize: 30.0,
                                  color: Color.fromARGB(255, 55, 55, 55),
                                ))),
                            Text(widget.user.company.title ?? "no data",
                                style: (TextStyle(
                                  fontSize: 20.0,
                                  color: Color.fromARGB(255, 55, 55, 55),
                                ))),
                            Text(widget.user.company.job ?? "no data",
                                style: (TextStyle(
                                  fontSize: 20.0,
                                  color: Color.fromARGB(255, 55, 55, 55),
                                ))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  widget.isNew
                      ? Flex(
                          direction: Axis.horizontal,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Flexible(
                              fit: FlexFit.tight,
                              flex: 1,
                              child: FlatButton(
                                onPressed: null,
                                child: Text(
                                  "Отклонить",
                                  style: (TextStyle(
                                    fontSize: 24.0,
                                    color: Color.fromARGB(255, 55, 55, 55),
                                  )),
                                ),
                              ),
                            ),
                            Flexible(
                              fit: FlexFit.tight,
                              flex: 1,
                              child: FlatButton(
                                onPressed: null,
                                child: Text(
                                  "Принять",
                                  style: (TextStyle(
                                    fontSize: 24.0,
                                    color: Color.fromARGB(255, 55, 55, 55),
                                  )),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildButtonsRow() {
    Size size = MediaQuery.of(context).size;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        constraints: BoxConstraints.expand(height: size.height * .07),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Flexible(
              child: InkWell(
                onTap: reject,
                child: Container(
                  constraints: BoxConstraints.expand(),
                  alignment: Alignment.center,
                  child: Text(
                    "Отклонить",
                    style: new TextStyle(color: Color(0xff555555), fontSize: 24.0),
                  ),
                ),
              ),
            ),
            Flexible(
              child: InkWell(
                onTap: accept,
                child: Container(
                  constraints: BoxConstraints.expand(),
                  alignment: Alignment.center,
                  child: Text(
                    "Принять",
                    style: new TextStyle(color: Color(0xff555555), fontSize: 24.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
