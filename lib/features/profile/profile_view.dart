import 'package:expensive/core/utils/app_colors.dart';
import 'package:expensive/core/utils/app_toast.dart';
import 'package:expensive/core/utils/app_fonts.dart';
import 'package:expensive/core/utils/app_space.dart';
import 'package:expensive/core/utils/responsive_helper.dart';
import 'package:expensive/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expensive/features/auth/presentation/bloc/auth_event.dart';
import 'package:expensive/features/profile/bloc/profile_bloc.dart';
import 'package:expensive/features/profile/bloc/profile_event.dart';
import 'package:expensive/features/profile/bloc/profile_state.dart';
import 'package:expensive/features/profile/widgets/profile_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _limitController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(LoadProfileEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          "Profile & Settings",
          style: AppFontStyle.large.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            _nicknameController.text = state.nickname;
            // Removed _limitController.text pre-fill as per user request
            if (state.message != null && state.message?.isNotEmpty == true) {
              ShowToast.showCustomToast(context, state.message!);
            }
          }
          if (state is ProfileError) {
            ShowToast.showCustomToast(context, state.message, isError: true);
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const ProfileShimmer();
          } else if (state is ProfileLoaded) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final padding = ResponsiveHelper.getResponsivePaddingHV(
                  constraints,
                  20,
                  20,
                );
                return SingleChildScrollView(
                  padding: padding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(
                        "NICKNAME",
                        constraints,
                      ).animate().fadeIn(duration: 400.ms),
                      _buildNicknameSection(state.nickname, constraints)
                          .animate()
                          .fadeIn(delay: 100.ms, duration: 600.ms)
                          .moveY(begin: 20, end: 0, curve: Curves.easeOutQuad),
                      AppSpacing.h(
                        ResponsiveHelper.getResponsiveHeight(constraints, 25),
                      ),
                      _buildSectionTitle(
                        "ALERT LIMIT (₹)",
                        constraints,
                      ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                      _buildLimitSection(state.budgetLimit, constraints)
                          .animate()
                          .fadeIn(delay: 300.ms, duration: 600.ms)
                          .moveY(begin: 20, end: 0, curve: Curves.easeOutQuad),
                      AppSpacing.h(
                        ResponsiveHelper.getResponsiveHeight(constraints, 25),
                      ),
                      _buildSectionTitle(
                        "CATEGORIES",
                        constraints,
                      ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
                      _buildCategoryManagement(state.categories, constraints)
                          .animate()
                          .fadeIn(delay: 500.ms, duration: 600.ms)
                          .moveY(begin: 20, end: 0, curve: Curves.easeOutQuad),
                      AppSpacing.h(
                        ResponsiveHelper.getResponsiveHeight(constraints, 25),
                      ),
                      _buildSectionTitle(
                        "CLOUD SYNC",
                        constraints,
                      ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
                      _buildCloudSyncSection(state.isSyncing, constraints)
                          .animate()
                          .fadeIn(delay: 700.ms, duration: 600.ms)
                          .moveY(begin: 20, end: 0, curve: Curves.easeOutQuad),
                      AppSpacing.h(
                        ResponsiveHelper.getResponsiveHeight(constraints, 25),
                      ),
                      _buildLogoutButton(constraints)
                          .animate()
                          .fadeIn(delay: 800.ms, duration: 600.ms)
                          .moveY(begin: 20, end: 0, curve: Curves.easeOutQuad),
                      AppSpacing.h(100),
                    ],
                  ),
                );
              },
            );
          } else if (state is ProfileError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, BoxConstraints constraints) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: AppFontStyle.medium.copyWith(
          color: AppColors.kWhite,
          fontSize: ResponsiveHelper.getResponsiveFontSize(constraints, 12),
        ),
      ),
    );
  }

  Widget _buildNicknameSection(
    String currentNickname,
    BoxConstraints constraints,
  ) {
    return Container(
      padding: ResponsiveHelper.getResponsivePaddingHV(constraints, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.kBlack,
        border: Border.all(color: AppColors.kWhite.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              currentNickname,
              style: AppFontStyle.medium.copyWith(
                color: Colors.white,
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  constraints,
                  18,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _showEditNicknameDialog(currentNickname),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.kBlack,
                border: Border.all(color: AppColors.kWhite.withOpacity(0.4)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.edit,
                color: Colors.white,
                size: ResponsiveHelper.getResponsiveIconSize(constraints, 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLimitSection(double currentLimit, BoxConstraints constraints) {
    return Container(
      padding: ResponsiveHelper.getResponsivePaddingHV(constraints, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.kBlack,
        border: Border.all(color: AppColors.kWhite.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _limitController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      constraints,
                      16,
                    ),
                  ),
                  decoration: InputDecoration(
                    hintText: "Amount (₹)",
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.grey[900],
                    contentPadding: ResponsiveHelper.getResponsivePaddingHV(
                      constraints,
                      12,
                      12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  final limit =
                      double.tryParse(_limitController.text) ?? 1000.0;
                  context.read<ProfileBloc>().add(SetBudgetLimitEvent(limit));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: ResponsiveHelper.getResponsivePaddingHV(
                    constraints,
                    20,
                    15,
                  ),
                ),
                child: Text(
                  "Set",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      constraints,
                      14,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "Current Limit: ₹${currentLimit.toStringAsFixed(0)}",
            style: AppFontStyle.medium.copyWith(
              color: Colors.white54,
              fontSize: ResponsiveHelper.getResponsiveFontSize(constraints, 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryManagement(List categories, BoxConstraints constraints) {
    return Container(
      padding: ResponsiveHelper.getResponsivePaddingHV(constraints, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.kBlack,
        border: Border.all(color: AppColors.kWhite.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _categoryController,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      constraints,
                      16,
                    ),
                  ),
                  decoration: InputDecoration(
                    hintText: "New category Name",
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.grey[900],
                    contentPadding: ResponsiveHelper.getResponsivePaddingHV(
                      constraints,
                      12,
                      12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  if (_categoryController.text.isNotEmpty) {
                    context.read<ProfileBloc>().add(
                      AddCategoryEvent(_categoryController.text),
                    );
                    _categoryController.clear();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.add,
                    color: AppColors.kWhite,
                    size: ResponsiveHelper.getResponsiveIconSize(
                      constraints,
                      24,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...categories
              .map((cat) => _buildCategoryItem(cat, constraints))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(dynamic cat, BoxConstraints constraints) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            cat.name,
            style: TextStyle(
              color: Colors.white,
              fontSize: ResponsiveHelper.getResponsiveFontSize(constraints, 16),
            ),
          ),
          GestureDetector(
            onTap: () =>
                context.read<ProfileBloc>().add(DeleteCategoryEvent(cat.id)),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.kRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.kRed.withOpacity(0.3)),
              ),
              child: Icon(
                Icons.delete_outline,
                color: AppColors.kRed,
                size: ResponsiveHelper.getResponsiveIconSize(constraints, 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloudSyncSection(bool isSyncing, BoxConstraints constraints) {
    print("Building CloudSyncSection: isSyncing = $isSyncing");
    final bool syncing = isSyncing == true;
    return GestureDetector(
      onTap: syncing
          ? null
          : () => context.read<ProfileBloc>().add(SyncToCloudEvent()),
      child: Container(
        width: double.infinity,
        padding: ResponsiveHelper.getResponsivePaddingHV(constraints, 20, 20),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSyncing ? "Syncing..." : "Sync To Cloud",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        constraints,
                        16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    isSyncing
                        ? "Please wait while we sync your data"
                        : "Sync and update data to the backend",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        constraints,
                        12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isSyncing)
              SizedBox(
                height: ResponsiveHelper.getResponsiveIconSize(constraints, 30),
                width: ResponsiveHelper.getResponsiveIconSize(constraints, 30),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            else
              Icon(
                Icons.cloud_upload_outlined,
                color: Colors.white,
                size: ResponsiveHelper.getResponsiveIconSize(constraints, 30),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BoxConstraints constraints) {
    return Container(
      width: double.infinity,
      padding: ResponsiveHelper.getResponsivePaddingHV(constraints, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.kBlack,
        border: Border.all(color: AppColors.kWhite.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: TextButton.icon(
          onPressed: () => _showLogoutConfirmationDialog(),
          icon: Icon(
            Icons.power_settings_new,
            color: AppColors.kRed,
            size: ResponsiveHelper.getResponsiveIconSize(constraints, 20),
          ),
          label: Text(
            "Log Out",
            style: TextStyle(
              color: AppColors.kRed,
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveHelper.getResponsiveFontSize(constraints, 14),
            ),
          ),
        ),
      ),
    );
  }

  void _showEditNicknameDialog(String current) {
    _nicknameController.text = current;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          "Update Nickname",
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: _nicknameController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Nickname",
            hintStyle: TextStyle(color: Colors.white38),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              context.read<ProfileBloc>().add(
                UpdateNicknameEvent(_nicknameController.text),
              );
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Confirm Logout",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Are you sure you want to log out of your account?",
          style: TextStyle(color: Colors.white70),
        ),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(LogoutEvent());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.kRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}
