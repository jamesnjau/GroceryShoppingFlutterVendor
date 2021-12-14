import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:grocery_vendor/providers/auth_provider.dart';
import 'package:grocery_vendor/screens/login_screen.dart';
import 'package:provider/provider.dart';

class ResetPassword extends StatefulWidget {
  static const String id = 'reset-screen';
  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _formKey = GlobalKey<FormState>();
  var _emailTextController = TextEditingController();
  late String email;
  bool _loading = false;
  @override
  Widget build(BuildContext context) {
    final _authData = Provider.of<AuthProvider>(context);
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'images/logo.png',
                  height: 250,
                ),
                SizedBox(
                  height: 20,
                ),
                RichText(
                    text: TextSpan(text: '', children: [
                  TextSpan(
                      text: 'Forgot password',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.red)),
                  TextSpan(
                      text:
                          ' provide us your registered email we will send you an email to reset password',
                      style: TextStyle(color: Colors.red, fontSize: 12))
                ])),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _emailTextController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter Email';
                    }
                    final bool _isvalid =
                        EmailValidator.validate(_emailTextController.text);
                    if (!_isvalid) {
                      return 'Invalid email format';
                    }
                    setState(() {
                      email = value;
                    });
                    return null;
                  },
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email_outlined),
                    labelText: 'Email',
                    contentPadding: EdgeInsets.zero,
                    enabledBorder: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            width: 2, color: Theme.of(context).primaryColor)),
                    focusColor: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    FlatButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _loading = true;
                            });
                            _authData.resetPassword(email);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    'Check your Email ${_emailTextController.text} for reset link.')));
                          }
                          Navigator.pushReplacementNamed(
                              context, LoginScreen.id);
                        },
                        color: Theme.of(context).primaryColor,
                        child: _loading
                            ? LinearProgressIndicator()
                            : Text(
                                'Reset Password',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
