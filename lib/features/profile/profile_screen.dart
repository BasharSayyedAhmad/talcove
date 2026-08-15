// lib/features/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:talcove/core/constants/auth_method.dart';
import 'package:talcove/core/utils/validators.dart';
import 'package:talcove/features/providers/auth_provider.dart';
import 'package:talcove/generated/l10n.dart';
import 'package:talcove/shared/widgets/app_snackbar.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _avatarController;
  late final Animation<double> _avatarScale;
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    _avatarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _avatarScale = CurvedAnimation(
      parent: _avatarController,
      curve: Curves.elasticOut,
    );
    _avatarController.forward();
  }

  @override
  void dispose() {
    _avatarController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final colorScheme = Theme.of(context).colorScheme;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ImageSourceSheet(),
    );
    if (source == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 800,
    );
    if (picked == null) return;

    setState(() => _pickedImage = File(picked.path));

    ref.read(authNotifierProvider.notifier).updatePhoto(picked.path);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: colorScheme.primary,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: _ProfileHeader(
                colorScheme: colorScheme,
                isDark: isDark,
                pickedImage: _pickedImage,
                photoUrl: user?.photoUrl,
                userName: user?.userName ?? '',
                avatarScale: _avatarScale,
                onPickImage: _pickImage,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel(
                        label: 'Personal Info',
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(height: 12),

                      _InfoCard(
                        colorScheme: colorScheme,
                        isDark: isDark,
                        children: [
                          _InfoTile(
                            icon: Icons.person_outline_rounded,
                            label: S.of(context).firstName,
                            value: user?.firstName?.isNotEmpty == true
                                ? user!.firstName!
                                : S.of(context).notProvided,
                            isEditable: true,
                            onEdit: () => _showEditDialog(
                              title: S.of(context).editFirstName,
                              initialValue: user?.firstName ?? '',
                              keyboardType: TextInputType.name,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return "هذا الحقل مطلوب";
                                }
                                return null;
                              },
                              onSave: (v) => ref
                                  .read(authNotifierProvider.notifier)
                                  .updateFirstLastName(fName: v),
                            ),
                            colorScheme: colorScheme,
                          ),
                          _Separator(colorScheme: colorScheme),

                          _InfoTile(
                            icon: Icons.person_outline_rounded,
                            label: S.of(context).lastName,
                            value: user?.lastName?.isNotEmpty == true
                                ? user!.lastName!
                                : S.of(context).notProvided,
                            isEditable: true,
                            onEdit: () => _showEditDialog(
                              title: S.of(context).editLastName,
                              initialValue: user?.lastName ?? '',
                              keyboardType: TextInputType.name,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return "هذا الحقل مطلوب";
                                }
                                return null;
                              },
                              onSave: (v) => ref
                                  .read(authNotifierProvider.notifier)
                                  .updateFirstLastName(lName: v),
                            ),
                            colorScheme: colorScheme,
                          ),
                          _Separator(colorScheme: colorScheme),
                          _InfoTile(
                            icon: Icons.person_outline_rounded,
                            label: S.of(context).UserName,
                            value: user?.userName ?? '',
                            isEditable: false,
                            onEdit: () {},
                            colorScheme: colorScheme,
                          ),

                          _Separator(colorScheme: colorScheme),
                          _InfoTile(
                            icon: Icons.email_outlined,
                            label: S.of(context).email,
                            value: user?.email?.isNotEmpty == true
                                ? user!.email!
                                : S.of(context).notProvided,
                            isEditable:
                                authState.authMethod ==
                                AuthMethod.userNameAndPassword,
                            onEdit: () => _showEditDialog(
                              title: S.of(context).editEmail,
                              initialValue: user?.email ?? '',
                              keyboardType: TextInputType.emailAddress,
                              validator: (val) =>
                                  Validators.email(context, val),
                              onSave: (v) => ref
                                  .read(authNotifierProvider.notifier)
                                  .updateEmail(v),
                            ),
                            colorScheme: colorScheme,
                          ),
                          _Separator(colorScheme: colorScheme),
                          _InfoTile(
                            icon: Icons.phone_outlined,
                            label: S.of(context).phoneNumber,
                            value: user?.phoneNumber?.isNotEmpty == true
                                ? user!.phoneNumber!
                                : S.of(context).notProvided,

                            onEdit: () => _showEditDialog(
                              validator: (val) =>
                                  Validators.phone(context, val),
                              title: S.of(context).editPhone,
                              initialValue: user?.phoneNumber ?? '',
                              keyboardType: TextInputType.phone,
                              onSave: (v) => ref
                                  .read(authNotifierProvider.notifier)
                                  .updatePhoneNumber(v),
                            ),
                            colorScheme: colorScheme,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                if (authState.isLoading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.25),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog({
    required String title,
    required String initialValue,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
    required Function(String) onSave,
  }) {
    final controller = TextEditingController(text: initialValue);
    final formKey = GlobalKey<FormState>();
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: validator,
            autofocus: true,
            style: TextStyle(color: colorScheme.onSurface),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              S.of(context).cancel,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx);
                onSave(controller.text.trim());
              }
            },
            child: Text(S.of(context).save),
          ),
        ],
      ),
    );
  }

  Future<void> _updateField(String field, String value) async {
    AppSnackBar.show(context, message: '$field updated successfully');
  }
}

class _ProfileHeader extends StatelessWidget {
  final ColorScheme colorScheme;
  final bool isDark;
  final File? pickedImage;
  final String? photoUrl;
  final String userName;
  final Animation<double> avatarScale;
  final VoidCallback onPickImage;

  const _ProfileHeader({
    required this.colorScheme,
    required this.isDark,
    required this.pickedImage,
    required this.photoUrl,
    required this.userName,
    required this.avatarScale,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: !isDark
              ? [colorScheme.primary, colorScheme.tertiary]
              : const [
                  Color.fromARGB(255, 26, 35, 126),
                  Color.fromARGB(255, 57, 73, 171),
                ],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            // Avatar مع زر التغيير
            ScaleTransition(
              scale: avatarScale,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    child: CircleAvatar(
                      radius: 44,
                      backgroundColor: colorScheme.surface,
                      backgroundImage: pickedImage != null
                          ? FileImage(pickedImage!) as ImageProvider
                          : (photoUrl != null ? NetworkImage(photoUrl!) : null),
                      child: (pickedImage == null && photoUrl == null)
                          ? Icon(
                              Icons.person_rounded,
                              size: 44,
                              color: colorScheme.primary,
                            )
                          : null,
                    ),
                  ),
                  GestureDetector(
                    onTap: onPickImage,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: colorScheme.secondary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              userName.isNotEmpty ? '@$userName' : '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: unused_element
class _ImageSourceSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Change Photo',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _SourceOption(
                icon: Icons.camera_alt_rounded,
                label: 'Camera',
                color: colorScheme.primary,
                // onTap: () {},
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              _SourceOption(
                icon: Icons.photo_library_rounded,
                label: 'Gallery',
                color: colorScheme.secondary,
                // onTap: () {},
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SourceOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final ColorScheme colorScheme;

  const _SectionLabel({required this.label, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
          color: colorScheme.primary,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final ColorScheme colorScheme;
  final bool isDark;
  final List<Widget> children;

  const _InfoCard({
    required this.colorScheme,
    required this.isDark,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surface.withValues(alpha: 0.8)
            : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : colorScheme.onSurface.withValues(alpha: 0.06),
        ),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isEditable;
  final VoidCallback onEdit;
  final ColorScheme colorScheme;
  final bool multiLine;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.isEditable = true,
    required this.onEdit,
    required this.colorScheme,
    this.multiLine = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: multiLine
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (isEditable)
            GestureDetector(
              onTap: onEdit,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.edit_rounded,
                  size: 16,
                  color: colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Separator extends StatelessWidget {
  final ColorScheme colorScheme;
  const _Separator({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 66,
      color: colorScheme.onSurface.withValues(alpha: 0.07),
    );
  }
}
