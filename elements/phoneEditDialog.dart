import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../generated/l10n.dart';
import 'package:firebase_auth/firebase_auth.dart' as Auth;
import '../models/user.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import 'package:mvc_pattern/mvc_pattern.dart';
import '../controllers/settings_controller.dart';
import '../../generated/l10n.dart';

// ignore: must_be_immutable

class PhoneEditDialog extends StatefulWidget {
  final User user;
  final VoidCallback onChanged;
  final scaffoldKey;

  PhoneEditDialog({Key key, this.user, this.onChanged, this.scaffoldKey})
      : super(key: key);
  @override
  _PhoneEditDialogState createState() => _PhoneEditDialogState();
}

class _PhoneEditDialogState extends StateMVC<PhoneEditDialog> {
  SettingsController _con;

  _PhoneEditDialogState() : super(SettingsController()) {
    _con = controller;
  }
  String phoneNumber, verificationId;
  String otp, authStatus = "";
  bool isloading = false;
  bool incorrectCode = false;

  void getRegion() async {
    PhoneNumber number =
    await PhoneNumber.getRegionInfoFromPhoneNumber('+965965886688');
    print(
        'number Of Region IS : ===========> ${number.isoCode} : ${number.dialCode} : ${number.phoneNumber}');
  }

  @override
  Widget build(BuildContext context) {
    getRegion();
    return FlatButton(
      onPressed: () {
        showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(builder: (context, setState) {
                return isloading
                    ? SimpleDialog(
                  contentPadding: EdgeInsets.symmetric(horizontal: 20),
                  titlePadding:
                  EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  title: Text(
                    'Enter Code',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(
                        focusedBorder:
                        _buildEnterCodeOutlineInputBorder(),
                        border: _buildEnterCodeOutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        otp = value;
                      },
                    ),
                    incorrectCode
                        ? Text('Inncorrect Code entered !!')
                        : Container(),
                    SizedBox(height: 20),
                    Row(
                      children: <Widget>[
                        MaterialButton(
                          onPressed: () {
                            //verifyPhoneNumber(context);
                            print('hhhhh');
                            setState(() {
                              isloading = false;
                            });
                          },
                          child: Text('resend'),
                        ),
                        MaterialButton(
                          onPressed: () async {
                            bool a = await signIn(otp);
                            if (a == false) {
                              setState(() {
                                incorrectCode = true;
                                isloading = true;
                              });
                            }
                          },
                          child: Text(
                            S.of(context).submit,
                            style: TextStyle(
                                color: Theme.of(context).accentColor),
                          ),
                        ),
                      ],
                      mainAxisAlignment: MainAxisAlignment.end,
                    ),
                    SizedBox(height: 10),
                  ],
                )
                    : SimpleDialog(
                  contentPadding: EdgeInsets.symmetric(horizontal: 20),
                  titlePadding:
                  EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  title: Text(
                    'enter phone ',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  children: <Widget>[
                    InternationalPhoneNumberInput(
                      initialValue: PhoneNumber(
                        isoCode: 'KW',
                        dialCode: '965',
                      ),
                      textStyle:
                      TextStyle(color: Theme.of(context).hintColor),
                      onInputChanged: (PhoneNumber number) {
                        phoneNumber = number.phoneNumber;
                        print(number.phoneNumber);
                      },

                      onInputValidated: (bool value) {
                        print(value);
                      },

                      validator: (input) => input.trim().length < 3
                          ? S.of(context).not_a_valid_phone
                          : null,
// onSaved: (input) => (),

                      selectorConfig: SelectorConfig(
                        selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                        backgroundColor: Colors.white,
                        showFlags: false,
                      ),
                      inputDecoration:
                      getInputDecoration(hintText: widget.user.phone),
                      ignoreBlank: false,
                      autoValidateMode: AutovalidateMode.disabled,
                      selectorTextStyle:
                      TextStyle(color: Theme.of(context).hintColor),

// textFieldController: controller,
//hintText:'+136 269 9765' ,
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: <Widget>[
                        MaterialButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(S.of(context).cancel),
                        ),
                        MaterialButton(
                          onPressed: () {
                            if (widget.user.phone == phoneNumber) {
                              Navigator.pop(context);
                              widget.scaffoldKey.currentState
                                  .showSnackBar(SnackBar(
                                  content: Text(
                                      '${phoneNumber} is Already Exist')));
                            } else {
                              phoneNumber == null
                                  ? null
                                  : verifyPhoneNumber(context).then((_) {
                                setState(() {
                                  // authStatus = "TIMEOUT";
                                  isloading = true;
                                });
                              });
                            }
                          },
                          child: Text(
                            S.of(context).save,
                            style: TextStyle(
                                color: Theme.of(context).accentColor),
                          ),
                        ),
                      ],
                      mainAxisAlignment: MainAxisAlignment.end,
                    ),
                    SizedBox(height: 10),
                  ],
                );
              });
            });
      },
      child: Text(
        S.of(context).edit,
        style: Theme.of(context).textTheme.bodyText2,
      ),
    );
  }

  OutlineInputBorder _buildEnterCodeOutlineInputBorder() {
    return new OutlineInputBorder(
      borderRadius: const BorderRadius.all(
        const Radius.circular(10),
      ),
    );
  }

  InputDecoration getInputDecoration({String hintText, String labelText}) {
    return new InputDecoration(
      hintText: hintText,
      labelText: labelText,
      hintStyle: Theme.of(context).textTheme.bodyText2.merge(
        TextStyle(color: Theme.of(context).focusColor),
      ),
      enabledBorder: UnderlineInputBorder(
          borderSide:
          BorderSide(color: Theme.of(context).hintColor.withOpacity(0.2))),
      focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).hintColor)),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: Theme.of(context).textTheme.bodyText2.merge(
        TextStyle(color: Theme.of(context).hintColor),
      ),
    );
  }

  falseCode() {
    print('dddddddddddddddddddddddddddddd');
    setState(() {
      incorrectCode = true;
    });
  }

  Future<bool> signIn(String otp) async {
    try {
      await Auth.FirebaseAuth.instance
          .signInWithCredential(Auth.PhoneAuthProvider.getCredential(
        verificationId: verificationId,
        smsCode: otp,
      ));
      incorrectCode = false;
      isloading = false;
      widget.user.phone = phoneNumber;
      widget.onChanged();
      Navigator.pop(context);
      return true;

      //currentUser.value.phone=phoneNumber;

      Navigator.pop(context);
    } on Exception catch (_) {
      print(verificationId);
      falseCode();
      print(otp);
      print('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
      return false;
    }
  }

  Future<void> verifyPhoneNumber(BuildContext context) async {
    await Auth.FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 15),
      verificationCompleted: (Auth.AuthCredential authCredential) {
        setState(() {
          authStatus = "Your account is successfully verified";
        });
      },
      verificationFailed: (Auth.FirebaseAuthException authException) {
        setState(() {
          authStatus = "Authentication failed";
          isloading = false;
        });
      },
      codeSent: (String verId, [int forceCodeResent]) {
        verificationId = verId;
        setState(() {
          print('OTP has been successfully send');
          authStatus = "OTP has been successfully send";
          isloading = true;
        });
        //otpDialogBox(context).then((value) {});
      },
      codeAutoRetrievalTimeout: (String verId) {
        verificationId = verId;
        setState(() {
          authStatus = "TIMEOUT";
          isloading = false;
        });
      },
    );
  }

  Widget enterCode() {
    return SimpleDialog(
      contentPadding: EdgeInsets.symmetric(horizontal: 20),
      titlePadding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      title: Text(
        'Enter Code',
        style: Theme.of(context).textTheme.headline4,
      ),
      children: <Widget>[
        TextFormField(
          decoration: InputDecoration(
            border: new OutlineInputBorder(
              borderRadius: const BorderRadius.all(
                const Radius.circular(10),
              ),
            ),
          ),
          onChanged: (value) {
            otp = value;
          },
        ),
        incorrectCode ? Text('Inncorrect Code entered !!') : Container(),
        SizedBox(height: 20),
        Row(
          children: <Widget>[
            MaterialButton(
              onPressed: () {
                //verifyPhoneNumber(context);
                print('hhhhh');
                setState(() {
                  incorrectCode = false;
                });
              },
              child: Text('resend'),
            ),
            MaterialButton(
              onPressed: () async {
                bool a = await signIn(otp);
                if (a == false) {
                  setState(() {
                    incorrectCode = true;
                  });
                }
              },
              child: Text(
                S.of(context).submit,
                style: TextStyle(color: Theme.of(context).accentColor),
              ),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.end,
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
