import 'package:flutter/material.dart';

/// Simple dialog for entering a shopping list name.
/// Returns the entered name via [Navigator.pop], or null if cancelled.
class CreateListDialog extends StatefulWidget {
  const CreateListDialog({super.key, this.initialName});

  /// When provided, the dialog acts as a rename dialog.
  final String? initialName;

  @override
  State<CreateListDialog> createState() => _CreateListDialogState();
}

class _CreateListDialogState extends State<CreateListDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isRename = widget.initialName != null;
    return AlertDialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        isRename ? 'Rename list' : 'New list',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          color: colors.onSurface,
        ),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        onSubmitted: (_) => _submit(),
        style: TextStyle(color: colors.onSurface, fontFamily: 'Poppins'),
        decoration: InputDecoration(
          hintText: 'List name',
          hintStyle: TextStyle(
            color: colors.onSurface.withValues(alpha: 0.38),
            fontFamily: 'Poppins',
          ),
          filled: true,
          fillColor: colors.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: colors.onSurface.withValues(alpha: 0.54),
              fontFamily: 'Poppins',
            ),
          ),
        ),
        TextButton(
          onPressed: _submit,
          child: const Text(
            'Save',
            style: TextStyle(
              color: Color(0xFFFF6B35),
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
