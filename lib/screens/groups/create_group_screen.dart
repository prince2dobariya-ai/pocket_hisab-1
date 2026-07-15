import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocket_hisab/helpers/snackbar_helper.dart';
import 'package:pocket_hisab/constants/app_theme.dart';
import 'package:pocket_hisab/controllers/group_controller.dart';
import 'package:pocket_hisab/controllers/person_controller.dart';
import 'package:pocket_hisab/widgets/custom_appbar.dart';
import 'package:pocket_hisab/widgets/custom_button.dart';
import 'package:pocket_hisab/widgets/custom_text.dart';
import 'package:pocket_hisab/widgets/custome_textform_filed.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final groupCtrl = Get.find<GroupController>();
  final personCtrl = Get.isRegistered<PersonController>()
      ? Get.find<PersonController>()
      : Get.put(PersonController());

  final _nameController = TextEditingController();
  final List<TextEditingController> _memberControllers = [
    TextEditingController(text: 'You'),
    TextEditingController(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.themeBackground,
      appBar: CustomAppBar(title: "New Trip / Group"),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomTextField(
              controller: _nameController,
              labelText: "Group Name",
              hintText: "e.g., Goa Trip, Roommates",
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: AppText("Members", fontWeight: FontWeight.bold, size: 16),
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _memberControllers.length + 1,
              itemBuilder: (context, index) {
                if (index == _memberControllers.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _memberControllers.add(TextEditingController());
                        });
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text("Add Member"),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return const Iterable<String>.empty();
                            }
                            return personCtrl.persons
                                .map((p) => p.personName)
                                .where(
                                  (name) => name.toLowerCase().contains(
                                    textEditingValue.text.toLowerCase(),
                                  ),
                                );
                          },
                          onSelected: (String selection) {
                            _memberControllers[index].text = selection;
                          },
                          fieldViewBuilder:
                              (
                                context,
                                controller,
                                focusNode,
                                onFieldSubmitted,
                              ) {
                                if (controller.text.isEmpty &&
                                    _memberControllers[index].text.isNotEmpty) {
                                  controller.text =
                                      _memberControllers[index].text;
                                }
                                return CustomTextField(
                                  controller: controller,
                                  focusNode: focusNode,
                                  hintText: "Member name",
                                  labelText: "Member name",
                                  readOnly: index == 0,
                                  onChange: (val) {
                                    _memberControllers[index].text = val;
                                  },
                                );
                              },
                        ),
                      ),
                      if (index > 0)
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _memberControllers.removeAt(index);
                            });
                          },
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: Colors.red,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: 52,
            child: CustomButton(
              onTap: () async {
                if (_nameController.text.trim().isEmpty) {
                  showCustomSnackbar("Error", "Please enter a group name");
                  return;
                }

                List<String> validNames = _memberControllers
                    .map((c) => c.text.trim())
                    .where((name) => name.isNotEmpty)
                    .toList();

                if (validNames.length < 2) {
                  showCustomSnackbar("Error", "Please add at least 2 members");
                  return;
                }

                await groupCtrl.createGroup(
                  _nameController.text.trim(),
                  validNames,
                );

                Get.back();
                showCustomSnackbar("Success", "Group created successfully");
              },
              title: "Create Group",
            ),
          ),
        ),
      ),
    );
  }
}
