import 'package:arif_quiz/core/i18n/difficulty_l10n.dart';
import 'package:arif_quiz/features/admin/data/admin_repository.dart';
import 'package:arif_quiz/features/admin/presentation/widgets/admin_card.dart';
import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:flutter/material.dart';

/// Administration du défi du jour : un calendrier où chaque date porte au plus
/// un quiz, saisi à la main. Rien ne se programme tout seul — une date laissée
/// libre veut dire « aucun défi ce jour-là », et les joueurs tombent alors sur
/// un écran vide. C'est pourquoi les jours à venir non programmés sont
/// affichés en clair plutôt que laissés invisibles.
class AdminDailyChallengesScreen extends StatefulWidget {
  const AdminDailyChallengesScreen({super.key});

  @override
  State<AdminDailyChallengesScreen> createState() =>
      _AdminDailyChallengesScreenState();
}

class _AdminDailyChallengesScreenState
    extends State<AdminDailyChallengesScreen> {
  late final AdminRepository _repo;
  AdminDailyChallengeCalendar? _calendar;
  List<AdminSchedulableQuizModel> _quizzes = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repo = AdminRepository(apiService);
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _repo.getDailyChallenges(),
        _repo.getSchedulableQuizzes(),
      ]);
      _calendar = results[0] as AdminDailyChallengeCalendar;
      _quizzes = results[1] as List<AdminSchedulableQuizModel>;
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  void _snack(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: error ? AppColors.error : AppColors.success,
    ));
  }

  void _showScheduleForm({
    AdminDailyChallengeModel? challenge,
    DateTime? date,
  }) {
    if (_quizzes.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.appColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ScheduleForm(
        repo: _repo,
        quizzes: _quizzes,
        challenge: challenge,
        initialDate: date ?? challenge?.challengeDate ?? _firstFreeDate(),
        onSaved: () {
          Navigator.pop(context);
          _load();
        },
      ),
    );
  }

  void _showRotationForm() {
    if (_quizzes.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.appColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _RotationForm(
        repo: _repo,
        quizzes: _quizzes,
        initialDate: _firstFreeDate(),
        onSaved: (message) {
          Navigator.pop(context);
          _snack(message);
          _load();
        },
      ),
    );
  }

  /// Le premier trou du calendrier : c'est la date que l'admin vient boucher
  /// neuf fois sur dix, donc le défaut le plus utile des formulaires.
  DateTime _firstFreeDate() {
    final missing = _calendar?.missingDates ?? const [];
    if (missing.isEmpty) {
      final horizon = _calendar?.horizonDays ?? 30;
      return DateUtils.dateOnly(DateTime.now().add(Duration(days: horizon)));
    }
    return DateTime.parse(missing.first);
  }

  Future<void> _delete(AdminDailyChallengeModel challenge) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.appColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Text(l10n.unscheduleConfirmTitle,
            style: const TextStyle(fontWeight: FontWeight.w800)),
        content: Text(l10n.unscheduleConfirmBody(
          MaterialLocalizations.of(ctx).formatFullDate(challenge.challengeDate),
          challenge.attemptsCount,
        )),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.unscheduleBtn,
                style: const TextStyle(
                    color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await _repo.deleteDailyChallenge(challenge.id);
      _load();
    } catch (e) {
      _snack(e.toString(), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.appColors.bg,
      appBar: AppBar(
        backgroundColor: context.appColors.bg,
        title: Text(l10n.adminDailyChallenge,
            style: const TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.repeat_rounded),
            tooltip: l10n.fillRotation,
            color: context.appColors.textSecondary,
            onPressed: _quizzes.isEmpty ? null : _showRotationForm,
          ),
          IconButton(
            icon: const Icon(Icons.event_available_rounded),
            tooltip: l10n.scheduleDay,
            color: AppColors.primary,
            onPressed: _quizzes.isEmpty ? null : () => _showScheduleForm(),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final l10n = AppLocalizations.of(context);

    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_error != null) {
      return Center(
          child: Text(_error!,
              style: TextStyle(color: context.appColors.textSecondary)));
    }

    final calendar = _calendar!;

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(l10n.dailyChallengeCalendarHint,
              style: context.type.labelMedium.copyWith(color: context.appColors.textSecondary)),
          const SizedBox(height: AppSpacing.md),

          if (!calendar.todayScheduled) ...[
            _TodayWarning(
                onSchedule: () => _showScheduleForm(
                    date: DateUtils.dateOnly(DateTime.now()))),
            const SizedBox(height: AppSpacing.md),
          ],

          if (_quizzes.isEmpty) ...[
            _EmptyNotice(
                title: l10n.noSchedulableQuiz,
                body: l10n.noSchedulableQuizHint),
            const SizedBox(height: AppSpacing.md),
          ],

          _SectionTitle(label: l10n.upcomingSection),
          if (calendar.upcoming.isEmpty)
            _EmptyNotice(title: l10n.emptyCalendar)
          else
            for (final challenge in calendar.upcoming)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ChallengeTile(
                  challenge: challenge,
                  onEdit: () => _showScheduleForm(challenge: challenge),
                  onDelete: () => _delete(challenge),
                ),
              ),

          if (calendar.missingDates.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _FreeDaysCard(
              dates: calendar.missingDates,
              horizonDays: calendar.horizonDays,
              onPick: (date) => _showScheduleForm(date: date),
            ),
          ],

          if (calendar.past.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            _SectionTitle(label: l10n.historySection),
            for (final challenge in calendar.past)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ChallengeTile(
                  challenge: challenge,
                  onDelete: () => _delete(challenge),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

// ─── Briques d'affichage ─────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String label;
  const _SectionTitle({required this.label});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Text(label,
            style: context.type.titleMedium.copyWith(color: context.appColors.textPrimary, fontWeight: FontWeight.w800)),
      );
}

class _EmptyNotice extends StatelessWidget {
  final String title;
  final String? body;
  const _EmptyNotice({required this.title, this.body});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          borderRadius: AppRadius.rLg,
          border: Border.all(color: context.appColors.border),
        ),
        child: Column(
          children: [
            Text(title,
                textAlign: TextAlign.center,
                style: context.type.labelLarge.copyWith(color: context.appColors.textPrimary)),
            if (body != null) ...[
              const SizedBox(height: 6),
              Text(body!,
                  textAlign: TextAlign.center,
                  style: context.type.labelMedium.copyWith(color: context.appColors.textSecondary)),
            ],
          ],
        ),
      );
}

class _TodayWarning extends StatelessWidget {
  final VoidCallback onSchedule;
  const _TodayWarning({required this.onSchedule});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.10),
        borderRadius: AppRadius.rLg,
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: AppColors.warning, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(l10n.noChallengeTodayTitle,
                    style: context.type.labelLarge.copyWith(color: AppColors.warning, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(l10n.noChallengeTodayBody,
              style: context.type.labelMedium.copyWith(color: context.appColors.textSecondary)),
          const SizedBox(height: AppSpacing.md),
          AdminActionBar(actions: [
            AdminAction(
              icon: Icons.today_rounded,
              label: l10n.scheduleToday,
              color: AppColors.warning,
              onPressed: onSchedule,
            ),
          ]),
        ],
      ),
    );
  }
}

class _FreeDaysCard extends StatelessWidget {
  final List<String> dates;
  final int horizonDays;
  final ValueChanged<DateTime> onPick;

  const _FreeDaysCard({
    required this.dates,
    required this.horizonDays,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final material = MaterialLocalizations.of(context);
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.freeDaysLabel(dates.length, horizonDays),
              style: context.type.labelSmall.copyWith(color: context.appColors.textSecondary, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final date in dates)
                AdminTag(
                  label: material.formatMediumDate(DateTime.parse(date)),
                  color: context.appColors.textMuted,
                  onTap: () => onPick(DateTime.parse(date)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChallengeTile extends StatelessWidget {
  final AdminDailyChallengeModel challenge;
  final VoidCallback? onEdit;
  final VoidCallback onDelete;

  const _ChallengeTile({
    required this.challenge,
    this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final material = MaterialLocalizations.of(context);
    final accent = challenge.isToday ? AppColors.primary : AppColors.info;

    return AdminCard(
      opacity: challenge.isPast ? 0.72 : 1,
      onTap: onEdit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminCardHeader(
            leading: AdminLeadingBox(
              color: accent,
              filled: challenge.isToday,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${challenge.challengeDate.day}',
                      style: context.type.titleMedium.copyWith(color:
                              challenge.isToday ? Colors.white : accent, fontWeight: FontWeight.w900, height: 1.1)),
                  Text(
                    material
                        .formatMediumDate(challenge.challengeDate)
                        .split(' ')
                        .last,
                    style: context.type.labelSmall.copyWith(color: challenge.isToday
                            ? Colors.white.withValues(alpha: 0.9)
                            : accent, fontWeight: FontWeight.w700, height: 1.1),
                  ),
                ],
              ),
            ),
            title: challenge.quizTitle ?? '—',
            titleMaxLines: 2,
            subtitle: Text(
              '${material.formatMediumDate(challenge.challengeDate)} · '
              '${challenge.questionsCount} Q · '
              '${DifficultyL10n.label(context, challenge.difficulty)}',
            ),
            badges: [
              if (challenge.isToday)
                AdminTag(
                    label: l10n.dailyTag,
                    color: AppColors.primary,
                    strong: true),
              AdminTag(
                label: l10n.attemptsCount(challenge.attemptsCount),
                color: context.appColors.textMuted,
              ),
            ],
            menuActions: [
              if (onEdit != null)
                AdminAction(
                  icon: Icons.swap_horiz_rounded,
                  label: l10n.changeQuizBtn,
                  color: AppColors.info,
                  onPressed: onEdit,
                ),
              AdminAction(
                icon: Icons.event_busy_rounded,
                label: l10n.unscheduleBtn,
                destructive: true,
                onPressed: onDelete,
              ),
            ],
          ),
          if (!challenge.isPlayable && !challenge.isPast) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.10),
                borderRadius: AppRadius.rSm,
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppColors.warning, size: 15),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      challenge.quizIsPublished
                          ? l10n.challengeQuizEmpty
                          : l10n.challengeQuizUnpublished,
                      style: context.type.labelSmall.copyWith(color: AppColors.warning),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Formulaire : une date, un quiz ──────────────────────────────────────────

/// `Y-m-d` : le format attendu par l'API, indépendant du fuseau horaire.
String _dateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

InputDecoration _dec(BuildContext context, String label) => InputDecoration(
      labelText: label,
      filled: true,
      fillColor: context.appColors.bg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: context.appColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: context.appColors.border),
      ),
    );

class _ScheduleForm extends StatefulWidget {
  final AdminRepository repo;
  final List<AdminSchedulableQuizModel> quizzes;
  final AdminDailyChallengeModel? challenge;
  final DateTime initialDate;
  final VoidCallback onSaved;

  const _ScheduleForm({
    required this.repo,
    required this.quizzes,
    required this.challenge,
    required this.initialDate,
    required this.onSaved,
  });

  @override
  State<_ScheduleForm> createState() => _ScheduleFormState();
}

class _ScheduleFormState extends State<_ScheduleForm> {
  late DateTime _date;
  int? _quizId;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _date = DateUtils.dateOnly(widget.initialDate);
    final current = widget.challenge?.quizId;
    // Un quiz dépublié depuis la programmation ne figure plus dans la liste :
    // on ne le présélectionne pas, sinon le Dropdown planterait sur une valeur
    // absente de ses items.
    _quizId = widget.quizzes.any((q) => q.id == current) ? current : null;
  }

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isBefore(today) ? today : _date,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (_quizId == null) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      if (widget.challenge == null) {
        await widget.repo.scheduleDailyChallenge(
            quizId: _quizId!, date: _dateKey(_date));
      } else {
        await widget.repo.updateDailyChallenge(
            id: widget.challenge!.id, quizId: _quizId!, date: _dateKey(_date));
      }
      widget.onSaved();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.challenge == null ? l10n.scheduleDay : l10n.changeQuizBtn,
              style: context.type.headlineMedium.copyWith(color: context.appColors.textPrimary, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: InputDecorator(
                decoration: _dec(context, l10n.dateLabel),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        MaterialLocalizations.of(context).formatFullDate(_date),
                        style: context.type.bodyLarge.copyWith(color: context.appColors.textPrimary),
                      ),
                    ),
                    Icon(Icons.calendar_today_rounded,
                        size: 18, color: context.appColors.textSecondary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _quizId,
              isExpanded: true,
              decoration: _dec(context, l10n.chooseQuiz),
              dropdownColor: context.appColors.cardBg,
              items: [
                for (final quiz in widget.quizzes)
                  DropdownMenuItem(
                    value: quiz.id,
                    child: Text(
                      '${quiz.title} · ${quiz.questionsCount} Q',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (value) => setState(() => _quizId = value),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style:
                      context.type.labelMedium.copyWith(color: AppColors.error)),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving || _quizId == null ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(widget.challenge == null
                        ? l10n.scheduleBtn
                        : l10n.saveChanges),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Formulaire : remplissage en série ───────────────────────────────────────

class _RotationForm extends StatefulWidget {
  final AdminRepository repo;
  final List<AdminSchedulableQuizModel> quizzes;
  final DateTime initialDate;
  final ValueChanged<String> onSaved;

  const _RotationForm({
    required this.repo,
    required this.quizzes,
    required this.initialDate,
    required this.onSaved,
  });

  @override
  State<_RotationForm> createState() => _RotationFormState();
}

class _RotationFormState extends State<_RotationForm> {
  late DateTime _start;

  /// L'ordre de sélection est l'ordre de passage : cocher A puis B donne
  /// A, B, A, B… à partir du premier jour.
  final List<int> _selected = [];
  int _days = 14;
  bool _overwrite = false;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _start = DateUtils.dateOnly(widget.initialDate);
  }

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _start.isBefore(today) ? today : _start,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _start = picked);
  }

  Future<void> _save() async {
    if (_selected.isEmpty) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final result = await widget.repo.rotateDailyChallenges(
        quizIds: _selected,
        startDate: _dateKey(_start),
        days: _days,
        overwrite: _overwrite,
      );
      if (!mounted) return;
      widget.onSaved(AppLocalizations.of(context)
          .rotationDone(result.created, result.updated, result.skipped));
    } catch (e) {
      setState(() {
        _error = e.toString();
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.fillRotation,
                style: context.type.headlineMedium.copyWith(color: context.appColors.textPrimary, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(l10n.rotationHint,
                style: context.type.labelMedium.copyWith(color: context.appColors.textSecondary)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: InputDecorator(
                      decoration: _dec(context, l10n.firstDay),
                      child: Text(
                        MaterialLocalizations.of(context)
                            .formatMediumDate(_start),
                        style: context.type.bodyLarge.copyWith(color: context.appColors.textPrimary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 110,
                  child: TextFormField(
                    initialValue: '$_days',
                    keyboardType: TextInputType.number,
                    decoration: _dec(context, l10n.numberOfDays),
                    onChanged: (value) => setState(
                        () => _days = int.tryParse(value.trim()) ?? _days),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(l10n.rotationQuizzes,
                style: context.type.labelLarge.copyWith(color: context.appColors.textPrimary)),
            const SizedBox(height: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (final quiz in widget.quizzes)
                      _RotationQuizRow(
                        quiz: quiz,
                        rank: _selected.indexOf(quiz.id),
                        onToggle: () => setState(() {
                          if (!_selected.remove(quiz.id)) {
                            _selected.add(quiz.id);
                          }
                        }),
                      ),
                  ],
                ),
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _overwrite,
              onChanged: (value) => setState(() => _overwrite = value),
              title: Text(l10n.overwriteScheduled,
                  style: context.type.bodyMedium.copyWith(color: context.appColors.textPrimary)),
              activeThumbColor: AppColors.warning,
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style:
                      context.type.labelMedium.copyWith(color: AppColors.error)),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving || _selected.isEmpty ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(l10n.fillDays(_days)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RotationQuizRow extends StatelessWidget {
  final AdminSchedulableQuizModel quiz;
  final int rank;
  final VoidCallback onToggle;

  const _RotationQuizRow({
    required this.quiz,
    required this.rank,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final selected = rank != -1;
    return InkWell(
      onTap: onToggle,
      borderRadius: AppRadius.rMd,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Checkbox(
              value: selected,
              onChanged: (_) => onToggle(),
              activeColor: AppColors.primary,
            ),
            Expanded(
              child: Text(
                quiz.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.type.bodyMedium.copyWith(color: context.appColors.textPrimary),
              ),
            ),
            const SizedBox(width: 6),
            Text('${quiz.questionsCount} Q',
                style: context.type.labelSmall.copyWith(color: context.appColors.textMuted)),
            if (selected) ...[
              const SizedBox(width: 6),
              AdminTag(
                  label: '#${rank + 1}',
                  color: AppColors.primary,
                  strong: true),
            ],
          ],
        ),
      ),
    );
  }
}
