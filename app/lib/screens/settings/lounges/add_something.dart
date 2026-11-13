// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lime_time_app/bloc/user_profile/lounge/add_something/add_something_bloc.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/logics/engines/lounge_engine.dart';
import 'package:lime_time_app/logics/models/lounge/lounge_category.dart';

import 'package:lime_time_app/widgets/buttons/primary_focus_button.dart';
import 'package:lime_time_app/widgets/snackbars/throw_error_snackbar.dart';
import 'package:lime_time_app/widgets/snackbars/throw_happy_snackbar.dart';

class AddToLounge extends StatefulWidget {
  bool modifyMode;
  String? categoryId;
  String? sectionId;
  String? categoryNameController;
  String? categoryDescriptionController;
  String? sectionName;
  String? sectionDescription;
  int? minimumLevelRequired = 0;
  bool? onlyOwnerCanPost = false;
  AddToLounge(
      {super.key,
      this.modifyMode = false,
      this.categoryId,
      this.sectionId,
      this.categoryNameController,
      this.categoryDescriptionController,
      this.sectionName,
      this.sectionDescription,
      this.minimumLevelRequired,
      this.onlyOwnerCanPost});

  @override
  State<AddToLounge> createState() => _AddToLoungeState();
}

class _AddToLoungeState extends State<AddToLounge> {
  Widget _textField(String txt, TextEditingController control,
      TextInputType type, int maxLength) {
    return Container(
        margin: const EdgeInsets.only(top: 0, bottom: 10),
        child: TextField(
          keyboardType: type,
          style: defaultSmallLabel(context),
          controller: control,
          decoration: InputDecoration(
            hintText: txt,
            hintStyle: defaultSmallLabel(context,
                fontColor: Theme.of(context).disabledColor),
          ),
        ));
  }

  Widget _backgroundWrapper(String label, bool isSelected) {
    return AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
        decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.inverseSurface
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20)),
        child: Text(label,
            style: defaultVerySmallLabel(context,
                fontWeight: FontWeight.bold,
                fontColor: isSelected
                    ? Colors.black
                    : Theme.of(context).textTheme.labelSmall!.color)));
  }

  int selectedIndex = 0;

  Widget _buildSectionToggleRow() {
    return Container(
      margin: const EdgeInsets.only(left: 15, right: 10, top: 0),
      child: Row(
        children: [
          InkWell(
              onTap: () {
                setState(() {
                  selectedIndex = 0;
                });
              },
              child: _backgroundWrapper('Category', selectedIndex == 0)),
          const SizedBox(
            width: 4,
          ),
          InkWell(
              onTap: () {
                setState(() {
                  selectedIndex = 1;
                });
              },
              child: _backgroundWrapper('Section', selectedIndex == 1))
        ],
      ),
    );
  }

  TextEditingController categoryNameController = TextEditingController();
  TextEditingController categoryDescriptionController = TextEditingController();

  TextEditingController sectionName = TextEditingController();
  TextEditingController sectionDescription = TextEditingController();
  int minimumLevelRequired = 0;
  bool onlyOwnerCanPost = false;

  AddSomethingBloc addSomethingBloc = AddSomethingBloc();
  List<bool> selectiveArray = [];
  @override
  void initState() {
    categoryNameController.text = widget.categoryNameController ?? "";
    categoryDescriptionController.text =
        widget.categoryDescriptionController ?? "";

    sectionName.text = widget.sectionName ?? "";
    sectionDescription.text = widget.sectionDescription ?? "";

    if (categoryNameController.text.isNotEmpty) {
      selectedIndex = 0;
    } else {
      selectedIndex = 1;
    }

    minimumLevelRequired = widget.minimumLevelRequired ?? 0;
    onlyOwnerCanPost = widget.onlyOwnerCanPost ?? false;

    addSomethingBloc.add(LoadCategories());

    super.initState();
  }

  Widget _buildCategory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Category Name",
          style: defaultSmallLabel(context, fontWeight: FontWeight.bold),
        ),
        _textField("General, Updates, Announcements etc...",
            categoryNameController, TextInputType.text, 120),
        Text(
          "Description",
          style: defaultSmallLabel(context, fontWeight: FontWeight.bold),
        ),
        _textField("What is this about?", categoryDescriptionController,
            TextInputType.text, 300),
        PrimaryFocusButton(
            label: !widget.modifyMode ? 'Create Category' : 'Modify Category',
            callback: () async {
              FocusScopeNode currentFocus = FocusScope.of(context);

              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
              if (categoryNameController.text.isEmpty) {
                throwErrorSnackBar(context, "Channel name can't be empty.");
                return;
              }

              if (categoryDescriptionController.text.isEmpty) {
                throwErrorSnackBar(context, "Description can't be empty.");
                return;
              }

              var data = {
                'token': sessionData!['token'],
                'category_name': categoryNameController.text,
                'category_description': categoryDescriptionController.text
              };

              bool status = false;
              if (widget.modifyMode) {
                data['category_id'] = widget.categoryId;
                status = await LoungeEngine().modifyLoungeCategory(data);
              } else {
                status = await LoungeEngine().createLoungeCategory(data);
              }

              if (status) {
                throwHappySnackBar(context, "Successfully updated.");
                Navigator.pop(context);
              } else {
                throwErrorSnackBar(
                    context, "Couldn't update. Please try again.");
              }
            })
      ],
    );
  }

  LoungeCategory? selectedCategory;
  Widget _buildSection() {
    return BlocConsumer<AddSomethingBloc, AddSomethingState>(
      bloc: addSomethingBloc,
      listener: (context, state) {
        if (state is LoadCategoriesSuccessful) {
          if (selectiveArray.isEmpty) {
            selectiveArray =
                List.generate(state.categories.length, (index) => false);
          }

          if (widget.categoryId != null && widget.categoryId!.isNotEmpty) {
            for (var i in state.categories) {
              if (i.categoryName == widget.categoryId &&
                  selectedCategory == null) {
                setState(() {
                  selectedCategory = i;
                });

                break;
              }
            }
          }
        }
      },
      builder: (context, state) {
        if (state is LoadCategoriesSuccessful) {
          if (state.categories.isEmpty) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: Center(
                child: Text(
                  "You will need to create a category first.",
                  style: defaultSmallLabel(context,
                      fontColor: Theme.of(context).colorScheme.primary),
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Section Name",
                style: defaultSmallLabel(context, fontWeight: FontWeight.bold),
              ),
              _textField("General, Updates, Announcements etc...", sectionName,
                  TextInputType.text, 120),
              Text(
                "Description",
                style: defaultSmallLabel(context, fontWeight: FontWeight.bold),
              ),
              _textField("What is this about?", sectionDescription,
                  TextInputType.text, 300),
              const SizedBox(
                height: 10,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Minimum Level Required",
                          style: defaultSmallLabel(context,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Members below this level cannot view and post in this section.",
                          style: defaultSmallLabel(context,
                              fontColor: Theme.of(context).hintColor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Row(
                    children: [
                      Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(5)),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              if (minimumLevelRequired > 0) {
                                minimumLevelRequired -= 1;
                              }
                            });
                          },
                          child: const Center(
                            child: Icon(Icons.remove),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        minimumLevelRequired.toString(),
                        style: defaultLabelText(context,
                            fontColor: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(5)),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              minimumLevelRequired += 1;
                            });
                          },
                          child: const Center(
                            child: Icon(Icons.add),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Others can post",
                          style: defaultSmallLabel(context,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Turning this off means only you can create a post within this section.",
                          style: defaultSmallLabel(context,
                              fontColor: Theme.of(context).hintColor),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: onlyOwnerCanPost,
                    onChanged: (bool value) {
                      setState(() {
                        onlyOwnerCanPost = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              if (widget.categoryId == null)
                Text(
                  "To which category?",
                  style:
                      defaultSmallLabel(context, fontWeight: FontWeight.bold),
                ),
              if (widget.categoryId == null)
                const SizedBox(
                  height: 5,
                ),
              if (widget.categoryId == null)
                Wrap(
                  direction: Axis.horizontal,
                  spacing: 5,
                  children: state.categories
                      .map((i) => InkWell(
                            onTap: () {
                              selectiveArray = List.generate(
                                  state.categories.length, (index) => false);
                              setState(() {
                                selectiveArray[state.categories.indexOf(i)] =
                                    true;
                                selectedCategory = i;
                              });
                            },
                            child: _backgroundWrapper(i.categoryName!,
                                selectiveArray[state.categories.indexOf(i)]),
                          ))
                      .toList(),
                ),
              const SizedBox(
                height: 30,
              ),
              PrimaryFocusButton(
                  label:
                      !widget.modifyMode ? 'Create Section' : "Modify Section",
                  callback: () async {
                    FocusScopeNode currentFocus = FocusScope.of(context);

                    if (!currentFocus.hasPrimaryFocus) {
                      currentFocus.unfocus();
                    }
                    if (sectionName.text.isEmpty) {
                      throwErrorSnackBar(
                          context, "Section name can't be empty.");
                      return;
                    }

                    if (sectionDescription.text.isEmpty) {
                      throwErrorSnackBar(
                          context, "Section description can't be empty.");
                      return;
                    }

                    var selectedIndex = selectiveArray.indexOf(true);
                    if (selectedIndex == -1 && widget.categoryId == null) {
                      throwErrorSnackBar(context,
                          "Select a category to create this section in.");
                      return;
                    }

                    var data = {
                      'token': sessionData!['token'],
                      'section_name': sectionName.text,
                      'section_description': sectionDescription.text,
                      'category_id': selectedCategory!.id,
                      'minimum_level_required': minimumLevelRequired,
                      'only_owner_can_post': onlyOwnerCanPost
                    };
                    bool status = false;
                    if (widget.modifyMode) {
                      data['section_id'] = widget.sectionId;
                      status = await LoungeEngine().modifyLoungeSection(data);
                    } else {
                      status = await LoungeEngine().createLoungeSection(data);
                    }

                    if (status) {
                      throwHappySnackBar(context, "Successfully updated.");
                      Navigator.pop(context);
                    } else {
                      throwErrorSnackBar(
                          context, "Couldn't update. Please try again.");
                    }
                  })
            ],
          );
        }
        return Container();
      },
    );
  }

  Widget _buildSecondarySection() {
    List<Widget> secondarySections = [_buildCategory(), _buildSection()];
    return Container(
      margin: const EdgeInsets.only(left: 15, right: 10, top: 10),
      child: secondarySections[selectedIndex],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).canvasColor.withOpacity(0.9),
        surfaceTintColor: Theme.of(context).canvasColor.withOpacity(0.9),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
        title: Text(
          widget.modifyMode ? "Modify " : "Add to Lounge",
          style: defaultLabelText(context, fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2.0),
            child: Container(
              color: Theme.of(context).dividerColor,
              height: 1.0,
            )),
      ),
      body: ListView(
        children: [
          !widget.modifyMode ? _buildSectionToggleRow() : Container(),
          _buildSecondarySection()
        ],
      ),
    );
  }
}
