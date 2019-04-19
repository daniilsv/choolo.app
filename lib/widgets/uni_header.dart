import 'package:flutter/material.dart';
import 'package:itis_cards/models/config.dart';
import 'package:itis_cards/models/user.dart';
import 'package:itis_cards/routes.dart';
import 'package:itis_cards/services/query.dart';
import 'package:itis_cards/styles/style.dart';
import 'package:itis_cards/widgets/choolo_icons.dart';
import 'package:itis_cards/widgets/network_image.dart';
import 'package:itis_cards/widgets/number.dart';

typedef void ClickCallback();

class UniHeaderWidget extends StatelessWidget {
  final int number;
  final ClickCallback numberCallback;
  final IconData repeatIcon;
  final ClickCallback repeatCallback;
  final bool needContacts;
  final bool needEvents;
  final String titleLabel;
  final bool needBack;

  UniHeaderWidget({
    this.needContacts = false,
    this.needEvents = false,
    this.number,
    this.numberCallback,
    this.repeatIcon,
    this.repeatCallback,
    this.titleLabel,
    this.needBack = false,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var body = <Widget>[];

    body.add(ClipPath(
      clipper: BackClipper(),
      child: Container(
        width: size.width,
        height: size.height * .25,
        color: StyleColors.primaryDark,
      ),
    ));

    body.add(Positioned(
      top: 18.0,
      left: 18.0,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: size.width * .27, maxHeight: size.width * .27),
        child: NetworkImageView(
          image: CachedNetworkImage(
            Query.hrefTo((User.local.photos == null || User.local.photos.length == 0 ? [""] : User.local.photos).last),
            header: {"auth_token": Config.token},
          ),
          fallbackWidget: Icon(Icons.account_circle, color: Colors.white),
        ),
      ),
    ));

    body.add(Positioned(
      top: 18.0,
      left: size.width * .34,
      width: needBack ? size.width * 0.5 : size.width * 0.6,
      child: SizedBox(
        height: 60.0,
        width: needBack ? size.width * 0.5 : size.width * 0.6,
        child: FittedBox(
          fit: BoxFit.contain,
          alignment: Alignment.centerLeft,
          child: Text(
            User.local.name.first + (User.local.name.second != null ? "\n" + User.local.name.second : ""),
            style: TextStyle(color: Colors.white, fontSize: 24.0),
          ),
        ),
      ),
    ));

    body.add(ClipPath(
      clipper: BackClipper(),
      child: InkWell(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: () {
          Routes.navigateTo(context, "/user");
        },
        child: Container(
          width: size.width,
          height: size.height * .25,
        ),
      ),
    ));

    if (needContacts)
      body.add(Positioned(
        top: size.width * .20,
        right: 18.0,
        child: IconButton(
          padding: EdgeInsets.all(0.0),
          iconSize: 36.0,
          icon: Icon(ChooloIcons.contacts, color: Colors.black),
          onPressed: () {
            Routes.navigateTo(context, "/contacts");
          },
        ),
      ));

    if (needEvents)
      body.add(Positioned(
        top: size.width * .34,
        right: 18.0,
        child: IconButton(
            padding: EdgeInsets.all(0.0),
            iconSize: 36.0,
            icon: Icon(ChooloIcons.events, color: Colors.black),
            onPressed: null),
      ));

    if (number != null)
      body.add(Positioned(
        top: size.width * .27,
        right: 15.0 + 80.0,
        child: NumberWidget(number.toString(), 60.0),
      ));

    if (repeatIcon != null)
      body.add(Positioned(
        top: size.width * .27,
        right: 18.0,
        child: IconButton(
          padding: EdgeInsets.all(0.0),
          iconSize: 60.0,
          icon: Icon(repeatIcon, color: Colors.black),
          onPressed: repeatCallback,
        ),
      ));

    if (titleLabel != null)
      body.add(Positioned(
        top: size.height * .2,
        right: 18.0,
        child: Text(titleLabel, style: TextStyle(color: Colors.black, fontSize: 27.0)),
      ));

    if (needBack)
      body.add(Positioned(
        top: 24.0,
        right: 18.0,
        child: IconButton(
          padding: EdgeInsets.all(0.0),
          iconSize: 30.0,
          icon: Icon(ChooloIcons.cross, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
      ));
    return Stack(
      children: body,
    );
  }
}

class BackClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path p = Path();
    p.moveTo(0, 0);
    p.lineTo(size.width, 0);
    p.lineTo(size.width, size.height * .4);
    p.lineTo(0, size.height);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
