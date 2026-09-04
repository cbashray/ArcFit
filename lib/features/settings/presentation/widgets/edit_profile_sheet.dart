import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class EditProfileSheet extends ConsumerStatefulWidget {
  final UserEntity user;

  const EditProfileSheet({
    super.key,
    required this.user,
  });

  static Future<void> show(BuildContext context, UserEntity user) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditProfileSheet(user: user),
    );
  }

  @override
  ConsumerState<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;

  late String _selectedEmoji;
  String? _selectedGender;
  bool _isLoading = false;

  static const List<String> _avatarEmojis = [
    '⚡',
    '🦁',
    '🏋️',
    '🔥',
    '🦾',
    '🥇',
    '🥊',
    '🚴',
    '🏃',
    '🥋',
    '🥑',
    '🎯',
    '🚀',
    '🐺',
    '🦍',
    '🧘',
    '🏆',
    '👑',
    '🧗',
    '💥',
    '🦈',
    '🛡️',
    '⚔️',
    '🐅',
  ];

  static const List<String> _genderOptions = [
    'Male',
    'Female',
    'Non-binary',
    'Prefer not to say',
  ];

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _nameController = TextEditingController(text: u.name);
    _ageController =
        TextEditingController(text: u.age != null ? u.age.toString() : '');
    _heightController = TextEditingController(
        text: u.height != null ? u.height!.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '') : '');
    _weightController = TextEditingController(
        text: u.weight != null ? u.weight!.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '') : '');

    _selectedEmoji = u.avatarEmoji ?? '⚡';
    _selectedGender = u.gender;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final name = _nameController.text.trim();
    final age = int.tryParse(_ageController.text.trim());
    final height = double.tryParse(_heightController.text.trim());
    final weight = double.tryParse(_weightController.text.trim());

    final error = await ref.read(authNotifierProvider.notifier).updateProfile(
          name: name,
          age: age,
          gender: _selectedGender,
          height: height,
          weight: weight,
          avatarEmoji: _selectedEmoji,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    } else {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully! 🎉'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: bottomInset + 24,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Profile',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Emoji Avatar Selector
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryGreen.withValues(alpha: 0.15),
                          border: Border.all(
                            color: AppTheme.primaryGreen,
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryGreen.withValues(alpha: 0.25),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _selectedEmoji,
                          style: const TextStyle(fontSize: 42),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose Avatar Icon',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 48,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _avatarEmojis.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final emoji = _avatarEmojis[index];
                            final isSelected = emoji == _selectedEmoji;
                            return InkWell(
                              onTap: () => setState(() => _selectedEmoji = emoji),
                              borderRadius: BorderRadius.circular(12),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.primaryGreen.withValues(alpha: 0.2)
                                      : (isDark
                                          ? const Color(0xFF2C2C2C)
                                          : Colors.grey.shade100),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppTheme.primaryGreen
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 22),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Name field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                    hintText: 'e.g. Alex Rivera',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name cannot be empty';
                    }
                    if (value.trim().length < 2) {
                      return 'Name is too short';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Age & Gender Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Age
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Age',
                          prefixIcon: Icon(Icons.cake_outlined),
                          hintText: '25',
                          suffixText: 'yrs',
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final val = int.tryParse(value.trim());
                            if (val == null || val <= 0 || val > 120) {
                              return 'Invalid age';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Gender Dropdown / selection
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        initialValue: _genderOptions.contains(_selectedGender)
                            ? _selectedGender
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'Gender',
                          prefixIcon: Icon(Icons.wc_rounded),
                        ),
                        items: _genderOptions.map((g) {
                          return DropdownMenuItem(
                            value: g,
                            child: Text(g, style: const TextStyle(fontSize: 14)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() => _selectedGender = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Height & Weight Row
                Row(
                  children: [
                    // Height
                    Expanded(
                      child: TextFormField(
                        controller: _heightController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Height',
                          prefixIcon: Icon(Icons.height_rounded),
                          hintText: '175',
                          suffixText: 'cm',
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final val = double.tryParse(value.trim());
                            if (val == null || val <= 30 || val > 300) {
                              return 'Invalid height';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Weight
                    Expanded(
                      child: TextFormField(
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Weight',
                          prefixIcon: Icon(Icons.fitness_center_rounded),
                          hintText: '70',
                          suffixText: 'kg',
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final val = double.tryParse(value.trim());
                            if (val == null || val <= 20 || val > 500) {
                              return 'Invalid weight';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Save button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
