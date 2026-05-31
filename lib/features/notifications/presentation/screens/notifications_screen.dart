import 'package:arif_quiz/features/notifications/data/notifications_repository.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _repo = NotificationsRepository(apiService);
  List<AppNotification> _items = [];
  int _unreadCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await _repo.getNotifications();
      setState(() {
        _items = res.items;
        _unreadCount = res.unreadCount;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bg,
      appBar: AppBar(
        backgroundColor: context.appColors.bg,
        title: Row(
          children: [
            const Text('Notifications'),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(12)),
                child: Text('$_unreadCount', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ],
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: () async {
                await _repo.markAllAsRead();
                setState(() {
                  _items = _items.map((n) => AppNotification(id: n.id, type: n.type, data: n.data, readAt: DateTime.now(), createdAt: n.createdAt)).toList();
                  _unreadCount = 0;
                });
              },
              child: const Text('Tout lire', style: TextStyle(color: AppColors.secondary, fontSize: 12)),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🔔', style: TextStyle(fontSize: 48)),
                      SizedBox(height: 12),
                      Text('Aucune notification', style: TextStyle(color: context.appColors.textSecondary)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.primary,
                  child: ListView.separated(
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const Divider(color: Color(0xFF2A2A4A), height: 1),
                    itemBuilder: (_, i) => _NotifTile(
                      notif: _items[i],
                      onTap: () async {
                        if (!_items[i].isRead) {
                          await _repo.markAsRead(_items[i].id);
                          setState(() {
                            _items[i] = AppNotification(
                              id: _items[i].id, type: _items[i].type, data: _items[i].data,
                              readAt: DateTime.now(), createdAt: _items[i].createdAt,
                            );
                            _unreadCount = (_unreadCount - 1).clamp(0, 999);
                          });
                        }
                      },
                    ),
                  ),
                ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final AppNotification notif;
  final VoidCallback onTap;

  const _NotifTile({required this.notif, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _iconForType(notif.notifType);
    return InkWell(
      onTap: onTap,
      child: Container(
        color: notif.isRead ? Colors.transparent : AppColors.primary.withValues(alpha: 0.05),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(icon, style: const TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notif.message, style: TextStyle(color: notif.isRead ? context.appColors.textSecondary : context.appColors.textPrimary, fontSize: 13, fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(timeago.format(notif.createdAt, locale: 'fr'), style: TextStyle(color: context.appColors.textMuted, fontSize: 11)),
                ],
              ),
            ),
            if (!notif.isRead)
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
          ],
        ),
      ),
    );
  }

  (String, Color) _iconForType(String type) => switch (type) {
        'friend_request' => ('👋', AppColors.secondary),
        'friend_accepted' => ('🤝', AppColors.success),
        'challenge_invitation' => ('⚔️', AppColors.primary),
        'challenge_completed' => ('🏆', AppColors.accent),
        _ => ('🔔', AppColors.textMuted),
      };
}
