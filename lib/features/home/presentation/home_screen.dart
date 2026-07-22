import 'package:flutter/material.dart';

import '../../../core/design_system/ds_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedRankingTab = 0; // 0: Grupo, 1: Amigos
  String _selectedGroup = 'Grupo Alpha';

  final List<String> _groups = ['Grupo Alpha', 'Grupo Beta', 'CrossFit Squad'];

  @override
  Widget build(BuildContext context) {
    final dsColors = context.dsColors;
    final primaryColor = dsColors.primary;
    final backgroundColor = dsColors.background;
    final surfaceColor = dsColors.surface;
    final textPrimary = dsColors.onSurface;
    final textSecondary = dsColors.textMuted;
    final borderColor = dsColors.border;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Bar: App Title & Notifications
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'GymApp',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Stack(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.notifications_none_rounded,
                          size: 28,
                          color: textPrimary,
                        ),
                      ),
                      Positioned(
                        right: 12,
                        top: 12,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 2. Group Selector
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedGroup,
                    dropdownColor: surfaceColor,
                    icon: Icon(Icons.keyboard_arrow_down_rounded,
                        color: textPrimary),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedGroup = newValue;
                        });
                      }
                    },
                    items:
                        _groups.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child:
                            Text(value, style: TextStyle(color: textPrimary)),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 3. Ranking Section Card
              Container(
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    // Title & "Ver todos"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ranking',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Ver todos',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: primaryColor,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(Icons.chevron_right_rounded,
                                  size: 18, color: primaryColor),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Ranking Tab Selector (Grupo / Amigos)
                    Container(
                      height: 38,
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedRankingTab = 0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _selectedRankingTab == 0
                                      ? surfaceColor
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: _selectedRankingTab == 0
                                      ? [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.05),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : [],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Grupo',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _selectedRankingTab == 0
                                        ? primaryColor
                                        : textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedRankingTab = 1),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _selectedRankingTab == 1
                                      ? surfaceColor
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: _selectedRankingTab == 1
                                      ? [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.05),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : [],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Amigos',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _selectedRankingTab == 1
                                        ? primaryColor
                                        : textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Top 4 Ranking List
                    _buildRankingItem(
                      context: context,
                      pos: 1,
                      name: 'Rafael',
                      animal: '🦁 LEÃO',
                      pts: '12.540 pts',
                      isUser: false,
                      avatarUrl: 'https://i.pravatar.cc/150?img=11',
                    ),
                    _buildRankingItem(
                      context: context,
                      pos: 2,
                      name: 'Marina',
                      animal: '🐯 TIGRE',
                      pts: '9.450 pts',
                      isUser: false,
                      avatarUrl: 'https://i.pravatar.cc/150?img=5',
                    ),
                    _buildRankingItem(
                      context: context,
                      pos: 3,
                      name: 'Lucas',
                      animal: '🦅 ÁGUIA',
                      pts: '7.230 pts',
                      isUser: false,
                      avatarUrl: 'https://i.pravatar.cc/150?img=12',
                    ),
                    _buildRankingItem(
                      context: context,
                      pos: 4,
                      name: 'Você',
                      animal: '🦁 LEÃO',
                      pts: '6.830 pts',
                      isUser: true, // Highlighted user!
                      avatarUrl: 'https://i.pravatar.cc/150?img=33',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 4. Feed Section
              _buildFeedItem(
                context: context,
                userName: 'Bruna',
                userAvatar: 'https://i.pravatar.cc/150?img=20',
                timeAgo: '2h',
                caption: 'ode corrida ao amanhecer ☀️✨',
                imageUrl:
                    'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80',
                metrics: [
                  _MetricData(
                      icon: Icons.timer_outlined,
                      value: '46:30',
                      label: 'Duração'),
                  _MetricData(
                      icon: Icons.local_fire_department_outlined,
                      value: '432',
                      label: 'Calorias'),
                  _MetricData(
                      icon: Icons.favorite_outline,
                      value: '148',
                      label: 'FC média'),
                  _MetricData(
                      icon: Icons.location_on_outlined,
                      value: '8,2 km',
                      label: 'Distância'),
                ],
              ),
              const SizedBox(height: 20),

              _buildFeedItem(
                context: context,
                userName: 'Lucas',
                userAvatar: 'https://i.pravatar.cc/150?img=12',
                timeAgo: '5h',
                caption: 'Treino de força concluído! Foco e consistência 💪',
                imageUrl:
                    'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&w=800&q=80',
                metrics: [
                  _MetricData(
                      icon: Icons.timer_outlined,
                      value: '55:10',
                      label: 'Duração'),
                  _MetricData(
                      icon: Icons.local_fire_department_outlined,
                      value: '510',
                      label: 'Calorias'),
                  _MetricData(
                      icon: Icons.favorite_outline,
                      value: '135',
                      label: 'FC média'),
                  _MetricData(
                      icon: Icons.fitness_center_outlined,
                      value: 'Alta',
                      label: 'Carga'),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRankingItem({
    required BuildContext context,
    required int pos,
    required String name,
    required String animal,
    required String pts,
    required bool isUser,
    String? avatarUrl,
  }) {
    final dsColors = context.dsColors;
    final primaryColor = dsColors.primary;
    final textPrimary = dsColors.onSurface;
    final textSecondary = dsColors.textMuted;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color:
            isUser ? primaryColor.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isUser
            ? Border.all(color: primaryColor.withValues(alpha: 0.4))
            : null,
      ),
      child: Row(
        children: [
          // Position Number
          SizedBox(
            width: 22,
            child: Text(
              '$pos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isUser
                    ? primaryColor
                    : (pos == 1 ? const Color(0xFFD97706) : textPrimary),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Profile Picture
          CircleAvatar(
            radius: 18,
            backgroundColor:
                isUser ? primaryColor.withValues(alpha: 0.25) : dsColors.border,
            child: Text(
              name[0],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isUser ? primaryColor : textPrimary,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name & Animal Level
          Expanded(
            child: Row(
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isUser ? FontWeight.bold : FontWeight.w600,
                    color: isUser ? primaryColor : textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                // Small Animal Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    animal,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB45309),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Points
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                pts.split(' ').first,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isUser ? primaryColor : textPrimary,
                ),
              ),
              Text(
                'pts',
                style: TextStyle(
                  fontSize: 11,
                  color: isUser
                      ? primaryColor.withValues(alpha: 0.8)
                      : textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeedItem({
    required BuildContext context,
    required String userName,
    required String userAvatar,
    required String timeAgo,
    required String caption,
    required String imageUrl,
    required List<_MetricData> metrics,
  }) {
    final dsColors = context.dsColors;
    final surfaceColor = dsColors.surface;
    final textPrimary = dsColors.onSurface;
    final textSecondary = dsColors.textMuted;
    final borderColor = dsColors.border;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Header
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: borderColor,
                child: Text(
                  userName[0],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  userName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
              ),
              Text(
                timeAgo,
                style: TextStyle(fontSize: 13, color: textSecondary),
              ),
              const SizedBox(width: 4),
              Icon(Icons.more_horiz, color: textSecondary, size: 20),
            ],
          ),
          const SizedBox(height: 10),

          // Caption
          Text(
            caption,
            style: TextStyle(
              fontSize: 14,
              color: textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),

          // Workout Photo Container placeholder
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_run_rounded,
                      color: Colors.white, size: 48),
                  SizedBox(height: 8),
                  Text(
                    'Foto do Treino',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Single Line Metrics (Max 4 metrics)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: metrics.map((m) {
              return Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(m.icon, size: 16, color: dsColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        m.value,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    m.label,
                    style: TextStyle(
                      fontSize: 11,
                      color: textSecondary,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _MetricData {
  final IconData icon;
  final String value;
  final String label;

  _MetricData({
    required this.icon,
    required this.value,
    required this.label,
  });
}
