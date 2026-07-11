import 'package:arif_quiz/features/admin/data/admin_repository.dart';
import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class AdminImportScreen extends StatefulWidget {
  const AdminImportScreen({super.key});

  @override
  State<AdminImportScreen> createState() => _AdminImportScreenState();
}

class _AdminImportScreenState extends State<AdminImportScreen> {
  late final AdminRepository _repo;
  List<AdminCategoryModel> _categories = [];

  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _timeLimitCtrl = TextEditingController(text: '30');
  final _pointsCtrl = TextEditingController(text: '10');

  int? _categoryId;
  String _difficulty = 'medium';
  bool _isPublished = false;
  PlatformFile? _pickedFile;

  bool _loading = true;
  bool _importing = false;
  String? _error;
  Map<String, dynamic>? _result;

  @override
  void initState() {
    super.initState();
    _repo = AdminRepository(apiService);
    _loadCategories();
  }

  @override
  void dispose() {
    _titleCtrl.dispose(); _descCtrl.dispose();
    _timeLimitCtrl.dispose(); _pointsCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      _categories = await _repo.getCategories();
      if (_categories.isNotEmpty) _categoryId = _categories.first.id;
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls', 'csv'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() { _pickedFile = result.files.first; _result = null; _error = null; });
    }
  }

  Future<void> _import() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pickedFile == null) {
      setState(() => _error = AppLocalizations.of(context).selectExcelFile);
      return;
    }
    if (_pickedFile!.path == null) {
      setState(() => _error = AppLocalizations.of(context).cantAccessFile);
      return;
    }

    setState(() { _importing = true; _error = null; _result = null; });

    try {
      final res = await _repo.importExcel(
        categoryId: _categoryId!,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        difficulty: _difficulty,
        timeLimit: int.parse(_timeLimitCtrl.text.trim()),
        pointsPerQuestion: int.parse(_pointsCtrl.text.trim()),
        isPublished: _isPublished,
        filePath: _pickedFile!.path!,
        fileName: _pickedFile!.name,
      );
      if (mounted) {
        setState(() {
          _result = res;
          _importing = false;
          _pickedFile = null;
          _titleCtrl.clear();
          _descCtrl.clear();
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _importing = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bg,
      appBar: AppBar(
        backgroundColor: context.appColors.bg,
        title: Text(AppLocalizations.of(context).importExcel, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 16),
                  if (_result != null) ...[
                    _buildSuccessCard(_result!),
                    const SizedBox(height: 16),
                  ],
                  if (_error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                      child: Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
                    ),
                    const SizedBox(height: 12),
                  ],
                  _sectionTitle(AppLocalizations.of(context).quizMetadata),
                  const SizedBox(height: 10),
                  _field(AppLocalizations.of(context).titleRequired, _titleCtrl, validator: (v) => v!.trim().isEmpty ? AppLocalizations.of(context).requiredField : null),
                  const SizedBox(height: 10),
                  _field(AppLocalizations.of(context).descriptionLabel, _descCtrl, maxLines: 2),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    initialValue: _categoryId,
                    decoration: _dec(AppLocalizations.of(context).categoryRequired),
                    items: _categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                    onChanged: (v) => setState(() => _categoryId = v),
                    validator: (v) => v == null ? AppLocalizations.of(context).requiredField : null,
                    dropdownColor: context.appColors.cardBg,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: _difficulty,
                    decoration: _dec(AppLocalizations.of(context).difficultyRequired),
                    items: [
                      DropdownMenuItem(value: 'easy', child: Text(AppLocalizations.of(context).diffEasy)),
                      DropdownMenuItem(value: 'medium', child: Text(AppLocalizations.of(context).diffMedium)),
                      DropdownMenuItem(value: 'hard', child: Text(AppLocalizations.of(context).diffHard)),
                    ],
                    onChanged: (v) => setState(() => _difficulty = v!),
                    dropdownColor: context.appColors.cardBg,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _field(AppLocalizations.of(context).timeSeconds, _timeLimitCtrl, keyboardType: TextInputType.number, validator: (v) {
                        final n = int.tryParse(v ?? '');
                        return (n == null || n < 5 || n > 600) ? '5–600' : null;
                      })),
                      const SizedBox(width: 12),
                      Expanded(child: _field(AppLocalizations.of(context).pointsPerQuestionReq, _pointsCtrl, keyboardType: TextInputType.number, validator: (v) {
                        final n = int.tryParse(v ?? '');
                        return (n == null || n < 1 || n > 1000) ? '1–1000' : null;
                      })),
                    ],
                  ),
                  SwitchListTile(
                    value: _isPublished,
                    onChanged: (v) => setState(() => _isPublished = v),
                    title: Text(AppLocalizations.of(context).publishNow, style: TextStyle(color: context.appColors.textPrimary, fontWeight: FontWeight.w600)),
                    activeThumbColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),
                  _sectionTitle(AppLocalizations.of(context).excelFile),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _pickFile,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: context.appColors.cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _pickedFile != null ? AppColors.primary : context.appColors.border,
                          width: _pickedFile != null ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _pickedFile != null ? Icons.check_circle_rounded : Icons.upload_file_rounded,
                            color: _pickedFile != null ? AppColors.primary : context.appColors.textMuted,
                            size: 40,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _pickedFile != null ? _pickedFile!.name : AppLocalizations.of(context).tapToSelectFile,
                            style: TextStyle(
                              color: _pickedFile != null ? AppColors.primary : context.appColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (_pickedFile != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              '${(_pickedFile!.size / 1024).toStringAsFixed(1)} KB',
                              style: TextStyle(color: context.appColors.textMuted, fontSize: 12),
                            ),
                          ],
                          const SizedBox(height: 4),
                          Text(
                            AppLocalizations.of(context).acceptedFormats,
                            style: TextStyle(color: context.appColors.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _importing ? null : _import,
                      icon: _importing
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.upload_rounded, color: Colors.white),
                      label: Text(
                        _importing ? AppLocalizations.of(context).importing : AppLocalizations.of(context).importBtn,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.info_outline_rounded, color: AppColors.info, size: 18),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context).excelFormatTitle, style: const TextStyle(color: AppColors.info, fontWeight: FontWeight.w700, fontSize: 13)),
          ]),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).excelFormatColumns,
            style: TextStyle(color: context.appColors.textSecondary, fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessCard(Map<String, dynamic> res) {
    final data = res['data'] as Map<String, dynamic>? ?? {};
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context).importSuccess, style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w800, fontSize: 15)),
          ]),
          const SizedBox(height: 8),
          Text(res['message'] as String? ?? '', style: TextStyle(color: context.appColors.textPrimary, fontSize: 13)),
          const SizedBox(height: 6),
          Text(AppLocalizations.of(context).questionsImported((data['questions_count'] as int?) ?? 0), style: TextStyle(color: context.appColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
        text,
        style: TextStyle(color: context.appColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800),
      );

  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: context.appColors.cardBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.appColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.appColors.border)),
      );

  Widget _field(String label, TextEditingController ctrl, {String? Function(String?)? validator, int maxLines = 1, TextInputType? keyboardType}) {
    return TextFormField(
      controller: ctrl,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: _dec(label),
    );
  }
}
