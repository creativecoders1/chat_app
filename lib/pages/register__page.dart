import 'dart:io';

import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/media_service.dart';
import 'package:chat_app/services/navigation_service.dart';
import 'package:chat_app/widgets/consts.dart';
import 'package:chat_app/widgets/custom_form_field.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../utils.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _registerFormKey = GlobalKey();
  late AuthService _authService;
  String? email, password, name;
  final GetIt _getIt = GetIt.instance;
  late MediaService _mediaService;
  late NavigationService _navigationService;
  File? selectedImage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _mediaService = MediaService();
    _navigationService = _getIt.get<NavigationService>();
    _authService = _getIt.get<AuthService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: true,
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _headerText(context),
                  if (!isLoading) _registerForm(),
                  if (!isLoading) _loginAccountLink(),
                ],
              ),
            ),
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
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
            "Let's, get going ",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          Text(
            'Register an account using the form below',
            // Fixed typo with correct apostrophe
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _registerForm() {
    return Container(
      height: screenHeight(context) * .6,
      margin: EdgeInsets.symmetric(vertical: screenHeight(context) * 0.05),
      child: Form(
          key: _registerFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _pfpSelectionField(),
              CustomFormField(
                  hintText: "Full Name",
                  height: screenHeight(context) * 0.1,
                  validationRegExp: NAME_VALIDATION_REGEX,
                  onSaved: (value) {
                    setState(() {
                      name = value;
                    });
                  }),
              CustomFormField(
                  hintText: "Email",
                  height: screenHeight(context) * 0.1,
                  validationRegExp: EMAIL_VALIDATION_REGEX,
                  onSaved: (value) {
                    setState(() {
                      email = value;
                    });
                  }),
              CustomFormField(
                  hintText: "Password",
                  height: screenHeight(context) * 0.1,
                  validationRegExp: PASSWORD_VALIDATION_REGEX,
                  onSaved: (value) {
                    setState(() {
                      password = value;
                    });
                  }),
              _registerButton()
            ],
          )),
    );
  }

  Widget _pfpSelectionField() {
    return GestureDetector(
      onTap: () async {
        File? file = await _mediaService.getImageFromGallery();
        if (file != null) {
          setState(() {
            selectedImage = file;
          });
        }
      },
      child: CircleAvatar(
          radius: screenWidth(context) * 0.15,
          backgroundImage: selectedImage != null
              ? FileImage(selectedImage!)
              : NetworkImage(PLACEHOLDER_PFP)),
    );
  }

  Widget _registerButton() {
    return SizedBox(
      width: screenWidth(context),
      child: MaterialButton(
        color: Colors.blue,
        onPressed: () async {
          setState(() {
            isLoading = true;
          });
          try {
            if (_registerFormKey.currentState?.validate() ??
                false && selectedImage != null) {
              _registerFormKey.currentState?.save();
              bool result = await _authService.signup(email!, password!);
              if (result) {
                print(result);
              }
            }
          } catch (e) {
            print(e);
          }
          setState(() {
            isLoading = false;
          });
        },
        child: const Text(
          'Register',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _loginAccountLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text("Already have an Account? "),
        GestureDetector(
          onTap: () {
            _navigationService.goBack();
          },
          child: const Text(
            'Login',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        )
      ],
    );
  }
}
