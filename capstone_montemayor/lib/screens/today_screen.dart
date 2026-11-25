import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/dummy_data.dart';
import '../models/class_session.dart';
import '../theme/subject_colors.dart';
import '../widgets/class_card.dart';
import '../widgets/class_details_sheet.dart';

enum _TodayFilter { all, ongoing, upcoming, done }

class TodayScreen extends StatefulWidget {
  final List<ClassSession> allClasses;
  final DateTime Function()? nowProvider;

  const TodayScreen({
    super.key,
    required this.allClasses,
    this.nowProvider,
  });

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  _TodayFilter _filter = _TodayFilter.all;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = (widget.nowProvider ?? DateTime.now)();
    final todayName = DateFormat('EEEE').format(now);
    final dateSubtitle = DateFormat('MMM d, y').format(now);
    final currentMinutes = now.hour * 60 + now.minute;

    final todaysClasses = widget.allClasses
        .where((c) => c.dayOfWeek.trim().toLowerCase() == todayName.toLowerCase())
        .toList()
      ..sort((a, b) => a.startTotalMinutes.compareTo(b.startTotalMinutes));

    int doneCount = 0;
    int totalMins = 0;
    int doneMins = 0;
    ClassSession? focusSession;
    bool focusIsOngoing = false;

    for (final c in todaysClasses) {
      final dur = (c.endTotalMinutes - c.startTotalMinutes).clamp(0, 600);
      totalMins += dur;

      if (currentMinutes >= c.endTotalMinutes) {
        doneCount++;
        doneMins += dur;
      } else if (currentMinutes >= c.startTotalMinutes) {
        focusSession ??= c;
        focusIsOngoing = true;
        doneMins += (currentMinutes - c.startTotalMinutes).clamp(0, dur);
      } else {
        focusSession ??= c;
      }
    }

    final filteredClasses = todaysClasses.where((session) {
      final isOngoing = currentMinutes >= session.startTotalMinutes &&
          currentMinutes < session.endTotalMinutes;
      final isDone = currentMinutes >= session.endTotalMinutes;
      final isUpcoming = !isOngoing && !isDone;

      final matchesFilter = switch (_filter) {
        _TodayFilter.all => true,
        _TodayFilter.ongoing => isOngoing,
        _TodayFilter.upcoming => isUpcoming,
        _TodayFilter.done => isDone,
      };

      if (!matchesFilter) return false;
      if (_query.isEmpty) return true;

      final q = _query.toLowerCase();
      return session.courseCode.toLowerCase().contains(q) ||
          session.courseTitle.toLowerCase().contains(q) ||
          session.room.toLowerCase().contains(q);
    }).toList();

    return Container(
      color: AppPalette.bgDark,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 110),
          children: [
            // Header: Section badge + Today date + Reminder bell
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppPalette.cardDark,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppPalette.borderSubtle),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.school_rounded,
                        size: 16,
                        color: AppPalette.electricBlue,
                      ),
                      SizedBox(width: 6),
                      Text(
                        kSectionName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppPalette.inkWhite,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$todayName · $dateSubtitle',
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppPalette.inkMuted,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Automated reminders active 10 minutes before each class.',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppPalette.cardDark,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppPalette.borderSubtle),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.notifications_none_rounded,
                          size: 20,
                          color: AppPalette.inkWhite,
                        ),
                        Positioned(
                          top: 8,
                          right: 9,
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppPalette.flameOrange,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 2-Column Bento Widget Row (Yellow Focus Widget + Dark Concentric Goal Widget)
            Row(
              children: [
                Expanded(
                  child: _FocusBentoCard(
                    session: focusSession,
                    isOngoing: focusIsOngoing,
                    currentMinutes: currentMinutes,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DailyProgressBentoCard(
                    doneCount: doneCount,
                    totalCount: todaysClasses.length,
                    doneMinutes: doneMins,
                    totalMinutes: totalMins,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Dark Search Bar
            Container(
              decoration: BoxDecoration(
                color: AppPalette.cardDark,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppPalette.borderSubtle),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: AppPalette.inkWhite, fontSize: 14),
                onChanged: (value) => setState(() => _query = value.trim()),
                decoration: InputDecoration(
                  hintText: 'Search courses or rooms...',
                  hintStyle: const TextStyle(
                    fontSize: 13.5,
                    color: AppPalette.inkMuted,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppPalette.inkMuted,
                  ),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: AppPalette.inkMuted,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterPill(
                    label: 'All',
                    selected: _filter == _TodayFilter.all,
                    onTap: () => setState(() => _filter = _TodayFilter.all),
                  ),
                  const SizedBox(width: 8),
                  _FilterPill(
                    label: 'Ongoing',
                    selected: _filter == _TodayFilter.ongoing,
                    onTap: () => setState(() => _filter = _TodayFilter.ongoing),
                  ),
                  const SizedBox(width: 8),
                  _FilterPill(
                    label: 'Upcoming',
                    selected: _filter == _TodayFilter.upcoming,
                    onTap: () =>
                        setState(() => _filter = _TodayFilter.upcoming),
                  ),
                  const SizedBox(width: 8),
                  _FilterPill(
                    label: 'Done',
                    selected: _filter == _TodayFilter.done,
                    onTap: () => setState(() => _filter = _TodayFilter.done),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Class Cards
            if (todaysClasses.isEmpty)
              _EmptyBentoCard(
                icon: Icons.bedtime_rounded,
                title: 'No classes today',
                subtitle: 'Check the Schedule tab for the rest of the week.',
              )
            else if (filteredClasses.isEmpty)
              _EmptyBentoCard(
                icon: Icons.search_off_rounded,
                title: 'No matching classes',
                subtitle: 'Try clearing your search or switching filters.',
              )
            else
              ...filteredClasses.map((session) {
                final isOngoing = currentMinutes >= session.startTotalMinutes &&
                    currentMinutes < session.endTotalMinutes;
                final isDone = currentMinutes >= session.endTotalMinutes;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ClassCard(
                    session: session,
                    isOngoing: isOngoing,
                    isDone: isDone,
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _FocusBentoCard extends StatelessWidget {
  final ClassSession? session;
  final bool isOngoing;
  final int currentMinutes;

  const _FocusBentoCard({
    required this.session,
    required this.isOngoing,
    required this.currentMinutes,
  });

  @override
  Widget build(BuildContext context) {
    if (session == null) {
      return Container(
        height: 164,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppPalette.cardDark,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: AppPalette.borderSubtle),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Done',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: AppPalette.emeraldGreen,
                height: 1.0,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'All classes clear',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppPalette.inkMuted,
              ),
            ),
            Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Icon(
                Icons.check_circle_rounded,
                size: 40,
                color: AppPalette.emeraldGreen,
              ),
            ),
          ],
        ),
      );
    }

    final s = session!;
    final diffMinutes = (isOngoing
            ? s.endTotalMinutes - currentMinutes
            : s.startTotalMinutes - currentMinutes)
        .clamp(0, 1440);

    final String bigMetric;
    if (diffMinutes >= 60) {
      final h = diffMinutes ~/ 60;
      final m = diffMinutes % 60;
      bigMetric = m == 0 ? '${h}h' : '${h}h ${m}m';
    } else {
      bigMetric = '$diffMinutes min';
    }

    final statusLabel =
        isOngoing ? 'Remaining · ${s.courseCode}' : 'Starts in · ${s.courseCode}';
    final roomLabel = isOngoing ? 'Live now · ${s.room}' : 'Room ${s.room}';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: () => ClassDetailsSheet.show(context, s),
        child: Container(
          height: 164,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppPalette.vibrantYellow,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      bigMetric,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: AppPalette.inkDark,
                        height: 1.05,
                        letterSpacing: -0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    statusLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: AppPalette.inkDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    roomLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppPalette.inkDark.withValues(alpha: 0.78),
                    ),
                  ),
                ],
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Icon(
                  isOngoing
                      ? Icons.local_fire_department_rounded
                      : Icons.alarm_on_rounded,
                  size: 46,
                  color: AppPalette.flameOrange,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyProgressBentoCard extends StatelessWidget {
  final int doneCount;
  final int totalCount;
  final int doneMinutes;
  final int totalMinutes;

  const _DailyProgressBentoCard({
    required this.doneCount,
    required this.totalCount,
    required this.doneMinutes,
    required this.totalMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final classProgress =
        totalCount > 0 ? (doneCount / totalCount).clamp(0.0, 1.0) : 0.0;
    final timeProgress =
        totalMinutes > 0 ? (doneMinutes / totalMinutes).clamp(0.0, 1.0) : 0.0;

    return Container(
      height: 164,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.cardDark,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppPalette.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Daily Goal',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppPalette.inkWhite,
                  ),
                ),
              ),
              SizedBox(width: 6),
              Icon(
                Icons.bolt_rounded,
                size: 18,
                color: AppPalette.electricBlue,
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              SizedBox(
                width: 68,
                height: 68,
                child: CustomPaint(
                  painter: _ConcentricRingPainter(
                    outerProgress: classProgress,
                    innerProgress: timeProgress,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.menu_book_rounded,
                          size: 13,
                          color: AppPalette.electricBlue,
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            '$doneCount/$totalCount',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: AppPalette.inkWhite,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 13,
                          color: AppPalette.inkWhite,
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            '${(doneMinutes / 60).toStringAsFixed(1)}h',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppPalette.inkMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConcentricRingPainter extends CustomPainter {
  final double outerProgress;
  final double innerProgress;

  const _ConcentricRingPainter({
    required this.outerProgress,
    required this.innerProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = (size.width / 2) - 5;
    final innerRadius = outerRadius - 11;

    final trackPaint = Paint()
      ..color = AppPalette.cardElevated
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7;

    canvas.drawCircle(center, outerRadius, trackPaint);
    canvas.drawCircle(center, innerRadius, trackPaint);

    if (outerProgress > 0) {
      final outerPaint = Paint()
        ..color = AppPalette.electricBlue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: outerRadius),
        -math.pi / 2,
        2 * math.pi * outerProgress,
        false,
        outerPaint,
      );
    }

    if (innerProgress > 0) {
      final innerPaint = Paint()
        ..color = AppPalette.inkWhite
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: innerRadius),
        -math.pi / 2,
        2 * math.pi * innerProgress,
        false,
        innerPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ConcentricRingPainter oldDelegate) {
    return oldDelegate.outerProgress != outerProgress ||
        oldDelegate.innerProgress != innerProgress;
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppPalette.electricBlue : AppPalette.cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppPalette.electricBlue : AppPalette.borderSubtle,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppPalette.inkMuted,
          ),
        ),
      ),
    );
  }
}

class _EmptyBentoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyBentoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppPalette.cardDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppPalette.borderSubtle),
      ),
      child: Column(
        children: [
          Icon(icon, size: 42, color: AppPalette.electricBlue),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppPalette.inkWhite,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppPalette.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}
