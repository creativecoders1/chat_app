import 'package:chat_app/utils.dart';
import 'package:chat_app/widgets/consts.dart';
import 'package:chat_app/widgets/custom_form_field.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../services/alert_service.dart';
import '../services/auth_service.dart';
import '../services/navigation_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GetIt _getIt = GetIt.instance;
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;
  String email = '';
  String password = '';

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = AlertService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildUI(context),
    );
  }

  Widget _buildUI(BuildContext context) {
    return SafeArea(
        child: Padding(
      padding: const EdgeInsets.only(left: 15.0, top: 30.0, right: 15),
      child: Column(
        children: [_headerText(context), _loginForm(context)],
      ),
    ));
  }

  Widget _loginForm(BuildContext context) {
    return Expanded(
      child: Center(
        child: Container(
          height: screenHeight(context) * .4,
          margin: EdgeInsets.symmetric(vertical: screenHeight(context) * 0.05),
          child: Form(
            key: _loginFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomFormField(
                  hintText: 'Email',
                  height: screenHeight(context) * 0.1,
                  validationRegExp: EMAIL_VALIDATION_REGEX,
                  onSaved: (value) {
                    email = value ?? ''; // Ensure email is non-null
                  },
                ),
                CustomFormField(
                  hintText: 'Password',
                  height: screenHeight(context) * .1,
                  validationRegExp: PASSWORD_VALIDATION_REGEX,
                  obscureText: true,
                  onSaved: (value) {
                    password = value ?? ''; // Ensure password is non-null
                  },
                ),
                _loginButton(context),
                _createAnAccountLink()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerText(BuildContext context) {
    return SizedBox(
      width: screenWidth(context),
      child: const Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hi, welcome back!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          Text(
            'Hello again, you\'ve been missed', // Fixed typo with correct apostrophe
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _loginButton(BuildContext context) {
    return SizedBox(
      width: screenWidth(context),
      child: MaterialButton(
        onPressed: () async {
          if (_loginFormKey.currentState?.validate() ?? false) {
            _loginFormKey.currentState?.save();
            bool result = await _authService.login(email, password);
            if (result) {
              _navigationService.pushReplacementNamed('/home');
            } else {
              _alertService.showToast(
                  text: "Failed to login, Please try again!",
                  icon: Icons.error);
            }
          }
        },
        color: Colors.blue,
        child: const Text(
          'Login',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _createAnAccountLink() {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text("Don't have an Account? "),
          GestureDetector(
            onTap: () {
              _navigationService.pushNamed('/register');
            },
            child: const Text(
              'Sign Up',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          )
        ],
      ),
    );
  }
}
