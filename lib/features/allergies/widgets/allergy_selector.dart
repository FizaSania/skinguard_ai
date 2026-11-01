import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/form_fields.dart';
import '../../../core/widgets/layout.dart';
import '../../../core/widgets/selection.dart';
import '../../../models/user_profile.dart';
import '../../../providers/user_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_theme.dart';

/// Allergy picker used in onboarding and on "My Allergies".
///
/// Predefined allergies are toggled with switches. Custom allergies are
/// added verbatim from the text field – they are never classified or
/// expanded into other allergies.
class AllergySelector extends StatefulWidget {
  const AllergySelector({super.key});

  @override
  State<AllergySelector> createState() => _AllergySelectorState();
}

class _AllergySelectorState extends State<AllergySelector> {
  final _controller = TextEditingController();
  String? _message;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addCustom() {
    final text = _controller.text;
    final users = context.read<UserProvider>();
    if (text.trim().isEmpty) {
      setState(() => _message = 'Type an allergy name first.');
      return;
    }
    final added = users.addCustomAllergy(text);
    setState(() {
      _message = added ? null : '"${text.trim()}" is already selected.';
      if (added) _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final users = context.watch<UserProvider>();
    final allergies = users.profile.allergies;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          label: 'Other allergy',
          hint: "Can't find your allergy? Type its name.",
          controller: _controller,
          fieldKey: const Key('custom_allergy_field'),
          textInputAction: TextInputAction.done,
          maxLength: 40,
          onSubmitted: (_) => _addCustom(),
          suffix: IconButton(
            key: const Key('add_custom_allergy'),
            tooltip: 'Add allergy',
            icon: const Icon(Icons.add_circle, color: AppColors.primary),
            onPressed: _addCustom,
          ),
        ),
        if (_message != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(_message!,
                style: AppTextStyles.small.copyWith(color: AppColors.danger)),
          ),
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < kPredefinedAllergies.length; i++) ...[
                if (i > 0) const Divider(height: 1),
                SwitchListTile(
                  title: Text(kPredefinedAllergies[i],
                      style: AppTextStyles.body.copyWith(fontSize: 16)),
                  value: users.hasAllergy(kPredefinedAllergies[i]),
                  onChanged: (_) =>
                      users.toggleAllergy(kPredefinedAllergies[i]),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        SectionTitle(
          'Selected',
          trailing: allergies.isEmpty
              ? null
              : TextButton(
                  onPressed: users.clearAllergies,
                  child: const Text('Clear all'),
                ),
        ),
        if (allergies.isEmpty)
          const InfoNote(
            icon: Icons.check_circle_outline,
            text:
                'No allergies selected. That is fine – leave this empty if you do not have any known allergies.',
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final a in allergies)
                TagChip(
                  label: users.profile.isCustomAllergy(a) ? '$a (custom)' : a,
                  onDeleted: () => users.removeAllergy(a),
                ),
            ],
          ),
      ],
    );
  }
}
