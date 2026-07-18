import 'package:flutter/material.dart';

import '../../../../core/constants/catalog.dart';
import '../../../../core/constants/insets.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/utils/nickname_filter.dart';
import '../../../../core/widgets/avatar_circle.dart';

/// Child-safe profile creation: nickname (filtered), preset avatar, birth
/// year. Used by both guest and email-register flows. Reports isChild for
/// players under 13 so extra restrictions apply.
class ProfileSetupForm extends StatefulWidget {
  const ProfileSetupForm({
    super.key,
    required this.submitLabel,
    required this.onSubmit,
    this.busy = false,
    this.avatars = Avatars.free,
    this.initialNickname,
    this.initialAvatarId,
  });

  final String submitLabel;
  final bool busy;

  /// Avatars the player may pick (free set, or unlocked set when editing).
  final List<AvatarDef> avatars;
  final String? initialNickname;
  final String? initialAvatarId;
  final void Function(String nickname, String avatarId, bool isChild) onSubmit;

  @override
  State<ProfileSetupForm> createState() => _ProfileSetupFormState();
}

class _ProfileSetupFormState extends State<ProfileSetupForm> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late String _avatarId;
  late int _birthYear;

  static const int _childThreshold = 13;
  late final int _currentYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialNickname ?? '';
    _avatarId = widget.initialAvatarId ?? widget.avatars.first.id;
    _birthYear = _currentYear - 10;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isChild => (_currentYear - _birthYear) < _childThreshold;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSubmit(_controller.text.trim(), _avatarId, _isChild);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(S.createProfileTitle, style: theme.textTheme.titleLarge),
          const SizedBox(height: Insets.l),
          TextFormField(
            controller: _controller,
            textInputAction: TextInputAction.done,
            maxLength: NicknameFilter.maxLength,
            decoration: InputDecoration(
              labelText: S.nicknameLabel,
              helperText: S.nicknameHint,
              prefixIcon: const Icon(Icons.badge_outlined),
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) => NicknameFilter.validate(value ?? ''),
            onFieldSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: Insets.m),
          Text(S.chooseAvatar, style: theme.textTheme.labelLarge),
          const SizedBox(height: Insets.s),
          _AvatarPicker(
            avatars: widget.avatars,
            selected: _avatarId,
            onSelect: (id) => setState(() => _avatarId = id),
          ),
          const SizedBox(height: Insets.m),
          Row(
            children: [
              const Icon(Icons.cake_outlined),
              const SizedBox(width: Insets.s),
              Text(S.birthYearLabel, style: theme.textTheme.labelLarge),
              const Spacer(),
              DropdownButton<int>(
                value: _birthYear,
                onChanged: (year) => setState(() => _birthYear = year!),
                items: [
                  for (var y = _currentYear; y >= _currentYear - 80; y--)
                    DropdownMenuItem(value: y, child: Text('$y')),
                ],
              ),
            ],
          ),
          if (_isChild)
            Padding(
              padding: const EdgeInsets.only(top: Insets.s),
              child: _InfoBanner(text: S.childModeInfo),
            ),
          const SizedBox(height: Insets.l),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: widget.busy ? null : _submit,
              child: widget.busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.submitLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({
    required this.avatars,
    required this.selected,
    required this.onSelect,
  });
  final List<AvatarDef> avatars;
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Insets.s,
      runSpacing: Insets.s,
      children: [
        for (final avatar in avatars)
          InkResponse(
            radius: 32,
            onTap: () => onSelect(avatar.id),
            child: AvatarCircle(
              avatarId: avatar.id,
              size: 52,
              selected: avatar.id == selected,
            ),
          ),
      ],
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(Insets.m),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(Corners.m),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🛡️'),
          const SizedBox(width: Insets.s),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: scheme.onTertiaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}
