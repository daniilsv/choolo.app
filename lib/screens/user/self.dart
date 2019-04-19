import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:itis_cards/app.dart';
import 'package:itis_cards/models/config.dart';
import 'package:itis_cards/models/user.dart';
import 'package:itis_cards/screens/user/widgets/accounts_edit.dart';
import 'package:itis_cards/services/connection.dart';
import 'package:itis_cards/services/query.dart';
import 'package:itis_cards/services/utils.dart';
import 'package:itis_cards/styles/style.dart';
import 'package:itis_cards/widgets/itis_scaffold.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:itis_cards/widgets/form_input_field.dart';
import 'package:itis_cards/widgets/masked_text.dart';
import 'package:itis_cards/widgets/network_image.dart';

class UserScreen extends StatefulWidget {
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final GlobalKey<ItisScaffoldState> _itisKey = GlobalKey<ItisScaffoldState>();
  MaskedTextController phoneController;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isAutovalidate = false;
  bool isChanged = false;

  PageController photosController;

  @override
  void initState() {
    App.pushItisScaffoldKey(_itisKey);
    photosController = PageController(
      initialPage: User.local.photos.length == 0 ? 0 : User.local.photos.length - 1,
      keepPage: false,
      viewportFraction: 0.5,
    );
    phoneController = MaskedTextController(text: User.local.phone, mask: "+7 (000) 000-00-00");
    super.initState();
  }

  @override
  void dispose() {
    photosController.dispose();
    App.popItisScaffoldKey();
    super.dispose();
  }

  saveProfile() async {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      setState(() {
        isAutovalidate = true;
      });
      Utils.showInSnackBar(_itisKey, 'Please fix the errors in red before submitting.');
    } else {
      User prevUser = User.local;
      form.save();
      Connection.listen("user.edit", (_) {
        User.fromJson(_).toDataBase().then((_) {
          Navigator.of(context).pop(true);
        });
        return true;
      });
      Connection.send("user.edit", User.local.toJson());
    }
  }

  Widget buildSaveCancelRow(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      constraints: BoxConstraints.expand(height: size.height * .07),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          InkWell(
            onTap: () {
              Navigator.of(context).pop(false);
            },
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(left: size.width * .1),
              child: Text(
                "Отмена",
                style: new TextStyle(color: Color(0xff999999), fontSize: 27.0),
              ),
            ),
          ),
          InkWell(
            onTap: saveProfile,
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(right: size.width * .1),
              child: Text(
                "Сохранить",
                style: new TextStyle(color: Color(0xff555555), fontSize: 27.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop() async {
    return isChanged
        ? showModalBottomSheet<bool>(
            context: context,
            builder: buildSaveCancelRow,
          )
        : true;
  }

  selectNewPhoto() async {
    var source = await showDialog<ImageSource>(
        context: context,
        builder: (context) {
          return Center(
            child: Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey, width: 2.0),
                borderRadius: BorderRadius.all(Radius.circular(16.0)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  FlatButton(
                    child: Text("Из галереи"),
                    onPressed: () => Navigator.pop(context, ImageSource.gallery),
                  ),
                  FlatButton(
                    child: Text("Сделать снимок"),
                    onPressed: () => Navigator.pop(context, ImageSource.camera),
                  ),
                ],
              ),
            ),
          );
        });
    if (source == null) return;
    File _imageFile = await ImagePicker.pickImage(source: source);
    _imageFile = await ImageCropper.cropImage(
      sourcePath: _imageFile.path,
      ratioX: 1.0,
      ratioY: 1.0,
      maxWidth: 512,
      maxHeight: 512,
      toolbarTitle: 'Crop',
      toolbarColor: StyleColors.accent,
    );
    Query.sendFile("user/photo", "photo", _imageFile).then((_) {
      if (_['error'] != false) return;
      if (User.local.photos == null) User.local.photos = [];
      setState(() {
        User.local.photos.add(_['path']);
      });
    });
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
              itemCount: User.local.photos.length,
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
          itemCount: User.local.photos == null ? 1 : User.local.photos.length + 1,
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
          Query.hrefTo(User.local.photos[index]),
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
          value = index == User.local.photos.length - 1 ? 1.0 : 0.5;
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
          if (User.local.photos == null || index == User.local.photos.length)
            selectNewPhoto();
          else
            openPhoto(index);
        },
        child: User.local.photos == null || index == User.local.photos.length
            ? Container(
                color: Colors.white,
                child: Center(
                  child: Icon(Icons.add_a_photo, size: 48.0, color: Color(0xff222222)),
                ),
              )
            : NetworkImageView(
                image: CachedNetworkImage(
                  Query.hrefTo(User.local.photos[index]),
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

    List<Widget> body = [];
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
    return WillPopScope(
      onWillPop: _onWillPop,
      child: ItisScaffold(
        key: _itisKey,
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            autovalidate: isAutovalidate,
            onChanged: () => isChanged = true,
            child: Column(children: <Widget>[
              topWidget,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 36.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: body,
                ),
              ),
              buildSaveCancelRow(context),
            ]),
          ),
        ),
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
