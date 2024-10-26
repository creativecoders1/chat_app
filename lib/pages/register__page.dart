import 'dart:io';

import 'package:chat_app/models/user_profile.dart';
import 'package:chat_app/services/alert_service.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/database_services.dart';
import 'package:chat_app/services/media_service.dart';
import 'package:chat_app/services/navigation_service.dart';
import 'package:chat_app/services/storage_services.dart';
import 'package:chat_app/widgets/consts.dart';
import 'package:chat_app/widgets/custom_form_field.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../utils.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _registerFormKey = GlobalKey();
  final GetIt _getIt = GetIt.instance;

  late AuthService _authService;
  late MediaService _mediaService;
  late NavigationService _navigationService;
  late StorageService _storageService;
  late DatabaseService _databaseService;
  late AlertService _alertService;

  String? email, password, name;
  File? selectedImage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _mediaService = MediaService();
    _navigationService = _getIt.get<NavigationService>();
    _authService = _getIt.get<AuthService>();
    _storageService = StorageService();
    _databaseService = DatabaseService();
    _alertService = AlertService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Let's, get going",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          Text(
            'Register an account using the form below',
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
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _pfpSelectionField(),
            CustomFormField(
              hintText: "Full Name",
              height: screenHeight(context) * 0.1,
              validationRegExp: NAME_VALIDATION_REGEX,
              onSaved: (value) => name = value,
            ),
            CustomFormField(
              hintText: "Email",
              height: screenHeight(context) * 0.1,
              validationRegExp: EMAIL_VALIDATION_REGEX,
              onSaved: (value) => email = value,
            ),
            CustomFormField(
              hintText: "Password",
              height: screenHeight(context) * 0.1,
              validationRegExp: PASSWORD_VALIDATION_REGEX,
              onSaved: (value) => password = value,
            ),
            _registerButton(),
          ],
        ),
      ),
    );
  }

  Widget _pfpSelectionField() {
    return GestureDetector(
      onTap: () async {
        File? file = await _mediaService.getImageFromGallery();
        if (file != null) {
          setState(() => selectedImage = file);
        }
      },
      child: CircleAvatar(
        radius: screenWidth(context) * 0.15,
        backgroundImage: selectedImage != null
            ? FileImage(selectedImage!)
            : NetworkImage(PLACEHOLDER_PFP) as ImageProvider,
      ),
    );
  }

  Widget _registerButton() {
    return SizedBox(
      width: screenWidth(context),
      child: MaterialButton(
        color: Colors.blue,
        onPressed: () async {
          if (_registerFormKey.currentState?.validate() ?? false) {
            if (selectedImage == null) {
              _alertService.showToast(
                  text: "Please select a profile picture", icon: Icons.error);
              return;
            }

            setState(() => isLoading = true);

            try {
              _registerFormKey.currentState?.save();
              bool result = await _authService.signup(email!, password!);
              if (result) {
                String? pfpURL = await _storageService.uploadUserPfp(
                    file: selectedImage!, uid: _authService.user!.uid);
                if (pfpURL != null) {
                  await _databaseService.createUserProfile(
                    userProfile: UserProfile(
                      uid: _authService.user!.uid,
                      name: name,
                      pfpURL: pfpURL,
                    ),
                  );
                  _alertService.showToast(
                      text: "User registered successfully", icon: Icons.check);
                  _navigationService.pushReplacementNamed('/home');
                }
              } else {
                _alertService.showToast(
                    text: "Registration failed. User Already exists.",
                    icon: Icons.error);
              }
            } catch (e) {
              print(e);
              _alertService.showToast(
                  text: "An error occurred. Please try again later.",
                  icon: Icons.error);
            }

            setState(() => isLoading = false);
          }
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
      children: [
        const Text("Already have an Account? "),
        GestureDetector(
          onTap: _navigationService.goBack,
          child: const Text(
            'Login',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}
