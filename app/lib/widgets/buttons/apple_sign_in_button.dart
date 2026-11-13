import 'package:lime_time_app/logics/engines/media_urls.dart';
import 'package:flutter/material.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AppleSignInButton extends StatelessWidget {
  const AppleSignInButton({super.key});

  Future<void> signInWithApple() async {
    try {
      // Request an authorization credential
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: 'gg.hazel.limelight',
          redirectUri: Uri.parse(
            appleCallbackUrl,
          ),
        ),
      );

      // Send the credential to your backend server

      final response = await http.post(
        Uri.parse(
            appleIdTokenValidationUrl), // Replace with your backend endpoint
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'token': credential
              .identityToken, // The identity token for backend verification
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 200) {
          // Successfully logged in
        } else {
          // Handle errors from your backend
        }
      } else {}
    } catch (error) {}
  }

  @override
  Widget build(BuildContext context) {
    int height = 40;
    double fontSize = height * 0.43;
    double appleIconSizeScale = 28 / 44;

    return Container(
      height: 40,
      padding: const EdgeInsets.only(top: 8, bottom: 8, left: 15, right: 15),
      margin: const EdgeInsets.only(top: 5, left: 5, bottom: 5),
      width: double.infinity,
      decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor, width: 2),
          borderRadius: BorderRadius.circular(8)),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: appleIconSizeScale * height,
              height: appleIconSizeScale * height + 2,
              padding: EdgeInsets.only(
                // Properly aligns the Apple icon with the text of the button
                bottom: (4 / 44) * height,
              ),
              child: Center(
                child: SizedBox(
                  width: fontSize * (25 / 31),
                  height: fontSize,
                  child: CustomPaint(
                    painter: AppleLogoPainter(
                      color: Theme.of(context).colorScheme.inverseSurface,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 13,
            ),
            Text(
              "Continue via Apple",
              style: defaultSmallLabel(context,
                  fontColor: Theme.of(context).colorScheme.inverseSurface,
                  fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}
