import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:itis_cards/app.dart';
import 'package:itis_cards/models/config.dart';
import 'package:itis_cards/models/user.dart';
import 'package:itis_cards/screens/user/widgets/accounts_edit.dart';
import 'package:itis_cards/services/query.dart';
import 'package:itis_cards/styles/style.dart';
import 'package:itis_cards/widgets/itis_scaffold.dart';
import 'package:image_picker/image_picker.dart';
import 'package:itis_cards/widgets/form_input_field.dart';
import 'package:itis_cards/widgets/masked_text.dart';
import 'package:itis_cards/widgets/network_image.dart';

//! unchecked
class ContactScreen extends StatefulWidget {
  final int id;
  ContactScreen({this.id});
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final GlobalKey<ItisScaffoldState> _itisKey = GlobalKey<ItisScaffoldState>();
  User user;
  MaskedTextController phoneController;
  PageController photosController;

  @override
  void initState() {
    User.getById(widget.id).then((_user) {
      user = _user;
      photosController = PageController(
        initialPage: user.photos.length == 0 ? 0 : user.photos.length - 1,
        keepPage: false,
        viewportFraction: 0.5,
      );
      phoneController = MaskedTextController(text: user.phone, mask: "+7 (000) 000-00-00");
      setState(() {});
    });
    App.pushItisScaffoldKey(_itisKey);
    super.initState();
  }

  @override
  void dispose() {
    photosController.dispose();
    App.popItisScaffoldKey();
    super.dispose();
  }

  openPhoto(int photoIndex) {
    showDialog<ImageSource>(
        context: context,
        builder: (context) {
          return Container(
            color: Colors.black,
            child: PageView.builder(
              controller: PageController(initialPage: photoIndex),
              reverse: true,
              onPageChanged: (_) => photosController.jumpToPage(_),
              itemCount: user.photos.length,
              itemBuilder: (context, index) => photoBuilder(index, true),
            ),
          );
        });
  }

  buildPhotosCarousel() {
    Size size = MediaQuery.of(context).size;
    return Positioned(
      top: 10.0,
      height: size.height * .3,
      child: Container(
        width: size.width,
        height: size.height * .3,
        child: PageView.builder(
          controller: photosController,
          reverse: true,
          itemCount: user.photos == null ? 0 : user.photos.length,
          itemBuilder: (context, index) => photoBuilder(index),
        ),
      ),
    );
  }

  photoBuilder(int index, [bool isOverlay = false]) {
    Size size = MediaQuery.of(context).size;
    if (isOverlay)
      return NetworkImageView(
        image: CachedNetworkImage(
          Query.hrefTo(user.photos[index]),
          header: {"auth_token": Config.token},
        ),
        fallbackWidget: Icon(Icons.account_circle, color: Colors.white),
      );
    return AnimatedBuilder(
      animation: photosController,
      builder: (context, child) {
        double value = 1.0;
        if (photosController.position.haveDimensions) {
          value = photosController.page - index;
          value = (1 - (value.abs() * .5)).clamp(0.0, 1.0);
        } else {
          value = index == user.photos.length - 1 ? 1.0 : 0.5;
        }
        return Center(
          child: SizedBox(
            width: Curves.easeOut.transform(value) * size.width * .45,
            height: Curves.easeOut.transform(value) * size.width * .45,
            child: child,
          ),
        );
      },
      child: InkWell(
        onTap: () {
          openPhoto(index);
        },
        child: NetworkImageView(
          image: CachedNetworkImage(
            Query.hrefTo(user.photos[index]),
            header: {"auth_token": Config.token},
          ),
          fallbackWidget: Icon(Icons.account_circle, color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    List<Widget> body = [];
    Widget topWidget = Container(
      margin: EdgeInsets.only(bottom: 20.0),
      child: Stack(
        children: <Widget>[
          ClipPath(
            clipper: PhotosLeftClipper(),
            child: Container(
              width: size.width * .5,
              height: size.height * .4,
              color: StyleColors.primaryDark,
            ),
          ),
          ClipPath(
            clipper: PhotosRightClipper(),
            child: Container(
              width: size.width,
              height: size.height * .4,
              color: StyleColors.secondary,
            ),
          ),
          buildPhotosCarousel(),
        ],
      ),
    );
    body.add(FormInputField(
      initialValue: User.local.name.first,
      textColor: StyleColors.primaryDark,
      fontSize: 36.0,
      textAlign: TextAlign.center,
      hint: "Имя",
      hintColor: StyleColors.primaryDark,
      hintSize: 36.0,
      onSaved: (_) {
        User.local.name.first = _;
      },
    ));
    body.add(FormInputField(
      initialValue: User.local.name.second,
      textColor: StyleColors.primaryDark,
      fontSize: 36.0,
      textAlign: TextAlign.center,
      hint: "Фамилия",
      hintColor: StyleColors.primaryDark,
      hintSize: 36.0,
      onSaved: (_) {
        User.local.name.second = _;
      },
    ));
    body.add(SizedBox(
      height: 40.0,
      width: size.width,
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.center,
        child: Text(
          phoneController.text,
          style: TextStyle(color: Color(0xff999999), fontSize: 24.0),
          textAlign: TextAlign.center,
        ),
      ),
    ));
    body.add(FormInputField(
      initialValue: User.local.company.title,
      textColor: StyleColors.primaryDark,
      fontSize: 30.0,
      hint: "Компания",
      hintColor: StyleColors.primaryDark,
      hintSize: 30.0,
      onSaved: (_) {
        User.local.company.title = _;
      },
    ));
    body.add(FormInputField(
      initialValue: User.local.company.job,
      textColor: StyleColors.primaryLight,
      hint: "Должность",
      hintColor: StyleColors.primaryLight,
      onSaved: (_) {
        User.local.company.job = _;
      },
    ));

    body.add(FormInputField(
      initialValue: User.local.bio,
      textColor: StyleColors.primaryDark,
      fontSize: 16.0,
      maxLines: 5,
      hint: "Биография",
      hintColor: StyleColors.primaryDark,
      hintSize: 16.0,
      onSaved: (_) {
        User.local.bio = _;
      },
    ));
    body.add(AccountsEdit(
      user: User.local,
    ));

    return ItisScaffold(
      key: _itisKey,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          topWidget,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 36.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: body,
            ),
          ),
        ]),
      ),
    );
  }
}

class PhotosLeftClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path p = Path();
    p.moveTo(0, 0);
    p.lineTo(size.width, 0);
    p.lineTo(size.width, size.height);
    p.lineTo(0, size.height * .8);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class PhotosRightClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path p = Path();
    p.moveTo(size.width, 0);
    p.lineTo(size.width * .4, 0);
    p.lineTo(size.width * .5, size.height);
    p.lineTo(size.width, size.height * .8);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
