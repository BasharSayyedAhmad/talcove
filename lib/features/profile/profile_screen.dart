// lib/features/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talcove/core/constants/auth_method.dart';
import 'package:talcove/core/utils/validators.dart';
import 'package:talcove/features/profile/privacy_settings_screen.dart';
import 'package:talcove/features/providers/auth_provider.dart';
import 'package:talcove/generated/l10n.dart';
import 'package:talcove/shared/widgets/app_snackbar.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).profile),
        backgroundColor: colorScheme.primary,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: user?.photoUrl != null
                        ? NetworkImage(user!.photoUrl!)
                        : null,
                    child: user?.photoUrl == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                ),
                const SizedBox(height: 24),

                //  اسم المستخدم
                _buildInfoRow(
                  context,
                  icon: Icons.person,
                  label: S.of(context).UserName,
                  value: user?.userName ?? "",
                  isEditable: false,
                  onEdit: () {},
                ),

                const Divider(),

                //  الإيميل
                _buildInfoRow(
                  context,
                  icon: Icons.email,
                  label: S.of(context).email,
                  value: user?.email?.isNotEmpty == true
                      ? user!.email!
                      : S.of(context).notProvided,
                  isEditable:
                      authState.authMethod ==
                      AuthMethod
                          .userNameAndPassword, //ما بصير يعدل ايميلو الا اذا كان مسجل ب يوزر نيم وباسوورد
                  onEdit: () => _showEditDialog(
                    title: S.of(context).editEmail,
                    initialValue: user?.email ?? "",
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) => Validators.email(context, val),
                    onSave: (newValue) => ref
                        .read(authNotifierProvider.notifier)
                        .updateEmail(newValue),
                  ),
                ),

                const Divider(),

                //  رقم الهاتف
                _buildInfoRow(
                  context,
                  icon: Icons.phone,
                  label: S.of(context).phoneNumber,
                  value: user?.phoneNumber?.isNotEmpty == true
                      ? user!.phoneNumber!
                      : S.of(context).notProvided,

                  onEdit: () => _showEditDialog(
                    title: S.of(context).editPhone,
                    initialValue: user?.phoneNumber ?? "",
                    keyboardType: TextInputType.phone,
                    onSave: (newValue) => ref
                        .read(authNotifierProvider.notifier)
                        .updatePhoneNumber(newValue),
                  ),
                ),

                const Divider(),

                //  Bio
                _buildInfoRow(
                  context,
                  icon: Icons.description,
                  label: S.of(context).bio,
                  value: user?.bio?.isNotEmpty == true
                      ? user!.bio!
                      : S.of(context).noBio,
                  onEdit: () => _showEditDialog(
                    title: S.of(context).editBio,
                    initialValue: user?.bio ?? "",
                    maxLines: 3,
                    onSave: (newValue) => _updateField('bio', newValue),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PrivacySettingsScreen(),
                      ),
                    );
                  },
                  child: Text("Privacy"),
                ),
              ],
            ),
          ),

          if (authState.isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool isEditable = true, //  افتراضي قابل للتعديل
    required VoidCallback onEdit,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
              ],
            ),
          ),

          if (isEditable)
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: onEdit,
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: validator,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
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
    print("Updating $field to: $value");
    AppSnackBar.show(context, message: "$field updated successfully");
  }
}
