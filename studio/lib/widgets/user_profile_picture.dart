import 'package:code_arrow_creator_studio/engines/media_urls.dart';
import 'package:code_arrow_creator_studio/engines/models/user_profile.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class UserProfilePicture extends StatefulWidget {
  final double radius;
  final UserProfile userObj;
  const UserProfilePicture({super.key, required this.radius, required this.userObj});

  @override
  State<UserProfilePicture> createState() => _UserProfilePictureState();
}

class _UserProfilePictureState extends State<UserProfilePicture> {
  MultipartFile? userProfilePicture;
  FilePickerResult? userProfilePictureResult;

  bool _isLoading = false;

  void _selectDPCallback() async {
    setState(() {
      _isLoading = true;
    });
    userProfilePictureResult = await FilePicker.platform.pickFiles(type: FileType.image);
    if (userProfilePictureResult != null) {
      userProfilePicture = MultipartFile.fromBytes(userProfilePictureResult!.files.first.bytes!);
    } else {
      // User canceled the picker
    }
    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildChild() {
    if (userProfilePictureResult != null) {
      return SizedBox(
        height: widget.radius * 1.95,
        width: widget.radius * 1.95,
        child: ClipOval(
            child: Image.memory(
          userProfilePictureResult!.files.first.bytes!,
          fit: BoxFit.fill,
        )),
      );
    }
    if (widget.userObj.profilePicture != null) {
      return SizedBox(
        height: widget.radius * 1.95,
        width: widget.radius * 1.95,
        child: ClipOval(
            child: Image.network(
          profilePictureUrl(widget.userObj.userName),
          fit: BoxFit.fill,
        )),
      );
    }
    return Icon(
      Icons.person,
      size: widget.radius,
      color: Theme.of(context).colorScheme.primary,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _selectDPCallback();
      },
      child: CircleAvatar(
        radius: widget.radius,
        backgroundColor: Theme.of(context).disabledColor,
        child: CircleAvatar(radius: widget.radius - 1.5, backgroundColor: Theme.of(context).canvasColor, child: _buildChild()),
      ),
    );
  }
}
