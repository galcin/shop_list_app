import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_list_app/core/constants/units.dart';
import 'package:shop_list_app/core/theme/colors.dart';
import 'package:shop_list_app/core/utils/number_utils.dart';
import 'package:shop_list_app/features/products/domain/entities/product.dart';
import 'package:shop_list_app/features/recipes/domain/entities/recipe.dart';
import 'package:shop_list_app/features/recipes/presentation/providers/recipe_providers.dart';
import 'package:shop_list_app/shared/widgets/product_picker_sheet.dart';

const String _kOtherCategory = '__other__';

/// 3-step form for creating or editing a recipe.
class RecipeFormPage extends ConsumerStatefulWidget {
  /// When non-null, the form is pre-filled for editing.
  final Recipe? initialRecipe;

  const RecipeFormPage({super.key, this.initialRecipe});

  @override
  ConsumerState<RecipeFormPage> createState() => _RecipeFormPageState();
}

class _RecipeFormPageState extends ConsumerState<RecipeFormPage> {
  final _pageController = PageController();
  int _currentStep = 0;
  bool _saving = false;
  String? _titleError;

  // Step 1 – Basics
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _prepCtrl;
  late final TextEditingController _cookCtrl;
  late final TextEditingController _categoryCtrl;
  String? _selectedCategory;
  late int _servings;

  // Step 2 – Ingredients
  late List<_IngredientDraft> _ingredients;

  // Step 3 – Instructions
  late List<_StepDraft> _steps;

  @override
  void initState() {
    super.initState();
    final r = widget.initialRecipe;
    _nameCtrl = TextEditingController(text: r?.name ?? '');
    _descCtrl = TextEditingController(text: r?.description ?? '');
    _prepCtrl = TextEditingController(text: r?.prepTime?.toString() ?? '');
    _cookCtrl = TextEditingController(text: r?.cookTime?.toString() ?? '');
    _categoryCtrl = TextEditingController(text: r?.category ?? '');
    _selectedCategory = r?.category;
    _servings = r?.servings ?? 2;
    _ingredients =
        r?.ingredients.map(_IngredientDraft.fromIngredient).toList() ?? [];
    _steps = (r?.instructionSteps ?? [])
        .map((s) => _StepDraft(ctrl: TextEditingController(text: s)))
        .toList();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _prepCtrl.dispose();
    _cookCtrl.dispose();
    _categoryCtrl.dispose();
    for (final i in _ingredients) {
      i.dispose();
    }
    for (final s in _steps) {
      s.dispose();
    }
    super.dispose();
  }

  void _goNext() {
    if (_currentStep == 0) {
      if (_nameCtrl.text.trim().isEmpty) {
        setState(() => _titleError = 'Recipe name is required');
        return;
      }
      setState(() => _titleError = null);
    }
    if (_currentStep < 2) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _goBack() {
    if (_currentStep > 0) {
      _pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      context.pop();
    }
  }

  String? get _categoryValue {
    final typed = _categoryCtrl.text.trim();
    if (_selectedCategory == _kOtherCategory) {
      return typed.isEmpty ? null : typed;
    }
    return _selectedCategory;
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _titleError = 'Recipe name is required');
      _pageController.animateToPage(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      return;
    }

    final ingredients = _ingredients
        .where((d) => d.nameCtrl.text.trim().isNotEmpty)
        .map((d) => d.toIngredient())
        .toList();

    if (ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one ingredient.')),
      );
      _pageController.animateToPage(1,
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      return;
    }

    final initial = widget.initialRecipe;
    final recipe = Recipe(
      id: initial?.id,
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      category: _categoryValue,
      prepTime: int.tryParse(_prepCtrl.text.trim()),
      cookTime: int.tryParse(_cookCtrl.text.trim()),
      servings: _servings,
      instructions: _steps
          .map((s) => s.ctrl.text.trim())
          .where((s) => s.isNotEmpty)
          .join('\n'),
      ingredients: ingredients,
      favorite: initial?.favorite ?? false,
      rating: initial?.rating,
      imageUrl: initial?.imageUrl,
      tags: initial?.tags ?? const [],
      seedKey: initial?.seedKey,
      createdAt: initial?.createdAt,
    );

    setState(() => _saving = true);
    final result =
        await ref.read(recipeListProvider.notifier).saveRecipe(recipe);
    if (!mounted) return;
    setState(() => _saving = false);

    result.fold(
      (f) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(f.message))),
      (_) => context.pop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialRecipe != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: AppColors.textPrimary, size: 20),
          onPressed: _goBack,
        ),
        title: Text(
          isEditing ? 'Edit Recipe' : 'New Recipe',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          _saving
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : TextButton(
                  onPressed: _currentStep == 2 ? _save : _goNext,
                  child: Text(
                    _currentStep == 2 ? 'Save' : 'Next',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
        ],
      ),
      body: Column(
        children: [
          _buildProgressBar(),
          if (isEditing && widget.initialRecipe!.isBuiltIn)
            _buildBuiltInNotice(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _currentStep = i),
              children: [
                _buildBasicsStep(),
                _buildIngredientsStep(),
                _buildInstructionsStep(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuiltInNotice() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: AppColors.primary),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'This is a built-in recipe. Saving makes it your own copy; '
                'future app updates will not change it.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: AppColors.textBody,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    const labels = ['Basics', 'Ingredients', 'Instructions'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: List.generate(3, (i) {
          final active = i <= _currentStep;
          return Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 4,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Step ${i + 1}: ${labels[i]}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: i == _currentStep
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontWeight:
                        i == _currentStep ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ── Step 1: Basics ──────────────────────────────────────────────────────────

  Widget _buildBasicsStep() {
    final categories = ref.watch(recipeCategoriesProvider).asData?.value ?? [];
    final options = <String>{
      ...categories,
      if (_selectedCategory != null && _selectedCategory != _kOtherCategory)
        _selectedCategory!,
    }.toList()
      ..sort();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Recipe name *'),
          _input(
            controller: _nameCtrl,
            hint: 'e.g. Chicken Tacos',
            errorText: _titleError,
            onChanged: (_) {
              if (_titleError != null) setState(() => _titleError = null);
            },
          ),
          const SizedBox(height: 16),
          _label('Category'),
          DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            decoration: _decoration('Choose a category'),
            dropdownColor: AppColors.surfaceVariant,
            style: const TextStyle(
                fontFamily: 'Poppins',
                color: AppColors.textPrimary,
                fontSize: 14),
            items: [
              ...options.map((c) => DropdownMenuItem(value: c, child: Text(c))),
              const DropdownMenuItem(
                  value: _kOtherCategory, child: Text('Other…')),
            ],
            onChanged: (v) => setState(() => _selectedCategory = v),
          ),
          if (_selectedCategory == _kOtherCategory) ...[
            const SizedBox(height: 8),
            _input(controller: _categoryCtrl, hint: 'New category name'),
          ],
          const SizedBox(height: 16),
          _label('Description / Notes'),
          _input(
            controller: _descCtrl,
            hint: 'Short description…',
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Prep time (min)'),
                    _input(
                        controller: _prepCtrl,
                        hint: '15',
                        inputType: TextInputType.number),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Cook time (min)'),
                    _input(
                        controller: _cookCtrl,
                        hint: '30',
                        inputType: TextInputType.number),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _label('Servings'),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (_servings > 1) setState(() => _servings--);
                },
                icon: const Icon(Icons.remove_circle_outline,
                    color: AppColors.primary),
              ),
              Text(
                '$_servings',
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary),
              ),
              IconButton(
                onPressed: () => setState(() => _servings++),
                icon: const Icon(Icons.add_circle_outline,
                    color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Step 2: Ingredients ─────────────────────────────────────────────────────

  Widget _buildIngredientsStep() {
    return Column(
      children: [
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            itemCount: _ingredients.length,
            onReorder: (old, newIdx) {
              setState(() {
                if (newIdx > old) newIdx--;
                final item = _ingredients.removeAt(old);
                _ingredients.insert(newIdx, item);
              });
            },
            itemBuilder: (_, i) => _IngredientRow(
              key: ValueKey(_ingredients[i]),
              draft: _ingredients[i],
              onRemove: () => setState(() => _ingredients.removeAt(i)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextButton.icon(
            onPressed: () =>
                setState(() => _ingredients.add(_IngredientDraft.empty())),
            icon: const Icon(Icons.add, color: AppColors.primary),
            label: const Text(
              'Add ingredient',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  // ── Step 3: Instructions ────────────────────────────────────────────────────

  Widget _buildInstructionsStep() {
    return Column(
      children: [
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            itemCount: _steps.length,
            onReorder: (old, newIdx) {
              setState(() {
                if (newIdx > old) newIdx--;
                final item = _steps.removeAt(old);
                _steps.insert(newIdx, item);
              });
            },
            itemBuilder: (_, i) => _StepRow(
              key: ValueKey(_steps[i]),
              stepNumber: i + 1,
              controller: _steps[i].ctrl,
              onRemove: () => setState(() => _steps.removeAt(i)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextButton.icon(
            onPressed: () => setState(
                () => _steps.add(_StepDraft(ctrl: TextEditingController()))),
            icon: const Icon(Icons.add, color: AppColors.primary),
            label: const Text(
              'Add step',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  // ── Shared helpers ──────────────────────────────────────────────────────────

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: AppColors.textPrimary,
          ),
        ),
      );

  InputDecoration _decoration(String hint, {String? errorText}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
            fontFamily: 'Poppins', color: AppColors.textSecondary),
        errorText: errorText,
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      );

  Widget _input({
    required TextEditingController controller,
    required String hint,
    String? errorText,
    int maxLines = 1,
    TextInputType inputType = TextInputType.text,
    ValueChanged<String>? onChanged,
  }) =>
      TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: inputType,
        onChanged: onChanged,
        style: const TextStyle(
            fontFamily: 'Poppins', color: AppColors.textPrimary),
        decoration: _decoration(hint, errorText: errorText),
      );
}

// ── Ingredient draft state ────────────────────────────────────────────────────

class _IngredientDraft {
  /// Catalogue product linked to this line. `null` means free-text entry.
  int? productId;

  final TextEditingController nameCtrl;

  /// Holds a number ("250", "1.5") or a note ("to taste") when no amount.
  final TextEditingController qtyCtrl;
  String unit;

  _IngredientDraft({
    this.productId,
    required this.nameCtrl,
    required this.qtyCtrl,
    this.unit = Units.pcs,
  });

  factory _IngredientDraft.empty() => _IngredientDraft(
        nameCtrl: TextEditingController(),
        qtyCtrl: TextEditingController(),
      );

  factory _IngredientDraft.fromIngredient(Ingredient i) => _IngredientDraft(
        productId: i.productId,
        nameCtrl: TextEditingController(text: i.name),
        qtyCtrl: TextEditingController(
          text: i.quantity != null
              ? NumberUtils.formatDecimal(i.quantity!)
              : (i.note ?? ''),
        ),
        unit: i.unit,
      );

  Ingredient toIngredient() {
    final raw = qtyCtrl.text.trim().replaceAll(',', '.');
    final qty = double.tryParse(raw);
    return Ingredient(
      productId: productId,
      name: nameCtrl.text.trim(),
      quantity: qty,
      unit: qty == null ? Units.none : unit,
      note: qty == null && raw.isNotEmpty ? raw : null,
    );
  }

  void dispose() {
    nameCtrl.dispose();
    qtyCtrl.dispose();
  }
}

// ── Ingredient row widget ─────────────────────────────────────────────────────

class _IngredientRow extends StatefulWidget {
  const _IngredientRow({
    super.key,
    required this.draft,
    required this.onRemove,
  });

  final _IngredientDraft draft;
  final VoidCallback onRemove;

  @override
  State<_IngredientRow> createState() => _IngredientRowState();
}

class _IngredientRowState extends State<_IngredientRow> {
  _IngredientDraft get draft => widget.draft;

  Future<void> _pickProduct() async {
    final Product? product = await showProductPickerSheet(context);
    if (!mounted || product == null) return;
    setState(() {
      draft.productId = product.id;
      draft.nameCtrl.text = product.name ?? '';
      draft.unit = product.defaultUnit;
    });
  }

  void _clearProduct() {
    setState(() {
      draft.productId = null;
      draft.nameCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final linked = draft.productId != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: AppColors.surfaceVariant,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Product picker row ──────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: linked
                      ? _ProductChip(
                          name: draft.nameCtrl.text,
                          onClear: _clearProduct,
                        )
                      : _FreeTextField(
                          controller: draft.nameCtrl,
                          onPick: _pickProduct,
                        ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: AppColors.error, size: 20),
                  onPressed: widget.onRemove,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // ── Qty + Unit row ───────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _inputField(draft.qtyCtrl, 'Qty or "to taste"',
                      inputType: const TextInputType.numberWithOptions(
                          decimal: true)),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 104,
                  child: DropdownButtonFormField<String>(
                    initialValue: Units.common.contains(draft.unit)
                        ? draft.unit
                        : Units.pcs,
                    isDense: true,
                    dropdownColor: AppColors.surfaceVariant,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: AppColors.textPrimary),
                    decoration: _fieldDecoration('Unit'),
                    items: Units.common
                        .map((u) => DropdownMenuItem(
                            value: u, child: Text(Units.pickerLabel(u))))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => draft.unit = v);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: AppColors.textSecondary),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 1),
        ),
      );

  Widget _inputField(TextEditingController ctrl, String hint,
          {TextInputType inputType = TextInputType.text}) =>
      TextField(
        controller: ctrl,
        keyboardType: inputType,
        style: const TextStyle(
            fontFamily: 'Poppins', fontSize: 13, color: AppColors.textPrimary),
        decoration: _fieldDecoration(hint),
      );
}

/// Green chip shown when a product is linked.
class _ProductChip extends StatelessWidget {
  const _ProductChip({required this.name, required this.onClear});
  final String name;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline,
              color: AppColors.primary, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: onClear,
            child: const Icon(Icons.close,
                color: AppColors.textSecondary, size: 16),
          ),
        ],
      ),
    );
  }
}

/// Free-text ingredient name with a search button that opens the catalogue.
class _FreeTextField extends StatelessWidget {
  const _FreeTextField({required this.controller, required this.onPick});
  final TextEditingController controller;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textCapitalization: TextCapitalization.sentences,
      style: const TextStyle(
          fontFamily: 'Poppins', fontSize: 13, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: 'Ingredient name…',
        hintStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: AppColors.textSecondary),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        filled: true,
        fillColor: AppColors.surface,
        suffixIcon: IconButton(
          tooltip: 'Choose from catalogue',
          icon: const Icon(Icons.search, color: AppColors.primary, size: 18),
          onPressed: onPick,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 1),
        ),
      ),
    );
  }
}

// ── Instruction step draft state ──────────────────────────────────────────────

class _StepDraft {
  final TextEditingController ctrl;
  _StepDraft({required this.ctrl});
  void dispose() => ctrl.dispose();
}

// ── Instruction step row ──────────────────────────────────────────────────────

class _StepRow extends StatelessWidget {
  const _StepRow({
    super.key,
    required this.stepNumber,
    required this.controller,
    required this.onRemove,
  });

  final int stepNumber;
  final TextEditingController controller;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: AppColors.surfaceVariant,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(
                '$stepNumber',
                style: const TextStyle(
                    color: AppColors.onPrimary,
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                maxLines: null,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Describe step $stepNumber…',
                  hintStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppColors.textSecondary),
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 1),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: AppColors.error, size: 20),
              onPressed: onRemove,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}
