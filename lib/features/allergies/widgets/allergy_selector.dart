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

  String _chipLabel(UserProfile profile, String allergy) {
    if (profile.isCustomAllergy(allergy)) return '$allergy (custom)';
    final product = profile.reactionProduct.trim();
    return allergy == kProductReactionAllergy && product.isNotEmpty
        ? '$allergy: $product'
        : allergy;
  }

  @override
  Widget build(BuildContext context) {
    final users = context.watch<UserProvider>();
    final allergies = users.profile.allergies;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (users.profile.hasProductReaction) ...[
          const _ReactionProductField(),
          const SizedBox(height: AppSpacing.lg),
        ],
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
            icon: Icon(Icons.add_circle, color: AppColors.primary),
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
                  label: _chipLabel(users.profile, a),
                  onDeleted: () => users.removeAllergy(a),
                ),
            ],
          ),
      ],
    );
  }
}

/// Required field shown only while "Skincare product reaction" is selected.
class _ReactionProductField extends StatefulWidget {
  const _ReactionProductField();

  @override
  State<_ReactionProductField> createState() => _ReactionProductFieldState();
}

class _ReactionProductFieldState extends State<_ReactionProductField> {
  late final TextEditingController _controller = TextEditingController(
      text: context.read<UserProvider>().profile.reactionProduct);
  bool _wasShowingError = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final users = context.watch<UserProvider>();
    final showError = users.showReactionProductError;
    if (showError && !_wasShowingError) {
      // The field is at the top of a long page; bring the error into view.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Scrollable.ensureVisible(context,
              duration: const Duration(milliseconds: 250));
        }
      });
    }
    _wasShowingError = showError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          label: 'Which product caused the reaction?',
          hint: 'Enter the product name or ingredient',
          controller: _controller,
          fieldKey: const Key('reaction_product_field'),
          textInputAction: TextInputAction.done,
          maxLength: 80,
          onChanged: users.setReactionProduct,
        ),
        if (showError)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text('Please enter the product that caused the reaction',
                style: AppTextStyles.small.copyWith(color: AppColors.danger)),
          ),
      ],
    );
  }
}

/// Keeps the user on the allergy step while the required product is missing.
class AllergyStepGuard extends StatelessWidget {
  const AllergyStepGuard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final users = context.watch<UserProvider>();
    return PopScope(
      canPop: !(users.user?.isReactionProductMissing ?? false),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) users.validateAllergies();
      },
      child: child,
    );
  }
}
