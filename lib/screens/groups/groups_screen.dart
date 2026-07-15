import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocket_hisab/helpers/snackbar_helper.dart';
import 'package:pocket_hisab/constants/app_theme.dart';
import 'package:pocket_hisab/controllers/group_controller.dart';
import 'package:pocket_hisab/models/group_model.dart';
import 'package:pocket_hisab/screens/groups/create_group_screen.dart';
import 'package:pocket_hisab/screens/groups/group_detail_screen.dart';
import 'package:pocket_hisab/widgets/custom_appbar.dart';
import 'package:pocket_hisab/widgets/custom_text.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final groupController = Get.put(GroupController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.themeBackground,
      appBar: CustomAppBar(title: "Trips & Groups"),
      body: Obx(() {
        if (groupController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (groupController.groups.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => groupController.fetchAllGroups(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16).copyWith(bottom: 90),
            itemCount: groupController.groups.length,
            itemBuilder: (context, index) {
              final group = groupController.groups[index];
              return _buildGroupCard(group);
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.to(() => const CreateGroupScreen());
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const AppText(
          'New Trip/Group',
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildGroupCard(GroupModel group) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Get.to(
              () =>
                  GroupDetailScreen(groupId: group.id!, groupName: group.name),
            );
          },
          onLongPress: () => _showDeleteDialog(group),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: context.themePrimary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.flight_takeoff_rounded,
                            color: context.themePrimary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              group.name,
                              fontWeight: FontWeight.bold,
                              size: 16,
                            ),
                            const SizedBox(height: 4),
                            AppText(
                              "${group.members.length} members",
                              color: Colors.grey.shade600,
                              size: 12,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flight_takeoff_rounded,
            size: 64,
            color: context.themePrimary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          const AppText(
            "No trips or groups yet",
            fontWeight: FontWeight.bold,
            size: 18,
          ),
          const SizedBox(height: 8),
          AppText(
            "Create a group to split expenses\nwith friends and roommates.",
            size: 14,
            color: Colors.grey.shade600,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(GroupModel group) {
    Get.dialog(
      AlertDialog(
        title: const Text("Delete Trip/Group"),
        content: Text(
          "Are you sure you want to delete '${group.name}'? This will remove all associated expenses and splits.",
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Get.back();
              await groupController.deleteGroup(group.id!);
              showCustomSnackbar("Success", "Trip/Group deleted successfully");
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
