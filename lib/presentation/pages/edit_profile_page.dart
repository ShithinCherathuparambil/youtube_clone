import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_picker/image_picker.dart';
import 'package:youtube_clone/l10n/app_localizations.dart';
import '../bloc/profile/profile_cubit.dart';

class EditProfilePage extends StatefulWidget {
  static const route = '/edit-profile';
  final String currentName;
  final String currentHandle;
  final String? currentImagePath;

  const EditProfilePage({
    super.key,
    required this.currentName,
    required this.currentHandle,
    this.currentImagePath,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormBuilderState>();
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    _selectedImagePath = widget.currentImagePath;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImagePath = image.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editProfile),
        actions: [
          TextButton(
            onPressed: () {
              if (_formKey.currentState?.saveAndValidate() ?? false) {
                final values = _formKey.currentState!.value;
                context.read<ProfileCubit>().updateProfile(
                  name: values['name'],
                  handle: values['handle'],
                  profileImagePath: _selectedImagePath,
                );
                Navigator.pop(context);
              }
            },
            child: Text(
              l10n.save,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50.r,
                    backgroundImage: _selectedImagePath != null
                        ? FileImage(File(_selectedImagePath!)) as ImageProvider
                        : const NetworkImage(
                            'https://picsum.photos/id/1027/200/200',
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),
            FormBuilder(
              key: _formKey,
              initialValue: {
                'name': widget.currentName,
                'handle': widget.currentHandle,
              },
              child: Column(
                children: [
                  FormBuilderTextField(
                    name: 'name',
                    decoration: InputDecoration(
                      labelText: l10n.name,
                      border: const OutlineInputBorder(),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.minLength(2),
                    ]),
                  ),
                  SizedBox(height: 16.h),
                  FormBuilderTextField(
                    name: 'handle',
                    decoration: InputDecoration(
                      labelText: l10n.handle,
                      border: const OutlineInputBorder(),
                      prefixText: '@',
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.minLength(3),
                    ]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
