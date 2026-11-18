import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../models/app_role.dart';
import '../services/http/api_client.dart';
import '../services/routes/app_routes.dart';
import '../theme/app_theme.dart';

class AppNavigationShell extends StatefulWidget {
  const AppNavigationShell({
    super.key,
    required this.apiClient,
    required this.requiredRole,
    required this.currentRoute,
    required this.child,
  });

  final ApiClient apiClient;
  final AppRole requiredRole;
  final String currentRoute;
  final Widget child;

  static void logout(BuildContext context, ApiClient apiClient) {
    apiClient.clearSession();
    Navigator.of(context)
        .pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
  }

  static bool isMenuOpen(BuildContext context) =>
      _AppNavigationScope.maybeOf(context)?.isOpen ?? false;

  @override
  State<AppNavigationShell> createState() => _AppNavigationShellState();
}

class _AppNavigationShellState extends State<AppNavigationShell> {
  bool _isOpen = false;

  void _toggleMenu() {
    setState(() => _isOpen = !_isOpen);
  }

  void _navigate(String route) {
    if (route == widget.currentRoute) {
      if (_isOpen) setState(() => _isOpen = false);
      return;
    }

    Navigator.of(context)
        .pushNamedAndRemoveUntil(route, ModalRoute.withName(AppRoutes.home));
  }

  void _logout() {
    AppNavigationShell.logout(context, widget.apiClient);
  }

  List<_NavigationItem> _items(AppLocalizations l10n) {
    if (widget.requiredRole == AppRole.admin) {
      return [
        _NavigationItem(
          AppRoutes.dashboard,
          l10n.navDashboard,
          Icons.dashboard_outlined,
        ),
        _NavigationItem(
          AppRoutes.loans,
          l10n.navLoans,
          Icons.receipt_long_outlined,
        ),
        _NavigationItem(
          AppRoutes.books,
          l10n.navBooks,
          Icons.menu_book_outlined,
        ),
        _NavigationItem(
          AppRoutes.publishers,
          l10n.navPublishers,
          Icons.business_outlined,
        ),
        _NavigationItem(AppRoutes.users, l10n.navUsers, Icons.people_outline),
      ];
    }

    return [
      _NavigationItem(
        AppRoutes.tenant,
        l10n.navDashboard,
        Icons.dashboard_outlined,
      ),
    ];
  }

  Widget _buildMenu(
    double width,
    List<_NavigationItem> items,
    AppLocalizations l10n,
  ) {
    return SizedBox(
      width: width,
      child: ColoredBox(
        color: AppTheme.primaryColor,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(
                height: 76,
                child: Center(
                  child: Icon(
                    Icons.menu_book_outlined,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
              ),
              const Divider(height: 1, color: Color(0x667F94A8)),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  children: [
                    for (final item in items)
                      _NavigationMenuItem(
                        item: item,
                        selected: item.route == widget.currentRoute,
                        onTap: () => _navigate(item.route),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0x667F94A8)),
              _NavigationMenuItem(
                item: _NavigationItem(
                  '',
                  l10n.navLogout,
                  Icons.logout_outlined,
                ),
                onTap: _logout,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mediaQuery = MediaQuery.of(context);
    final isAvailable = widget.apiClient.role == widget.requiredRole;
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final menuWidth = availableWidth < 600
            ? math.min(220.0, availableWidth * 0.58)
            : 248.0;
        final showMenu = isAvailable && _isOpen;
        final contentWidth = math.max(
          0.0,
          availableWidth - (showMenu ? menuWidth : 0),
        );
        return _AppNavigationScope(
          isOpen: showMenu,
          isAvailable: isAvailable,
          onToggle: _toggleMenu,
          child: Row(
            children: [
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                alignment: Alignment.centerLeft,
                child: showMenu
                    ? _buildMenu(menuWidth, _items(l10n), l10n)
                    : const SizedBox.shrink(),
              ),
              Expanded(
                child: MediaQuery(
                  data: mediaQuery.copyWith(
                    size: Size(contentWidth, mediaQuery.size.height),
                  ),
                  child: widget.child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AppNavigationButton extends StatelessWidget {
  const AppNavigationButton({super.key});

  @override
  Widget build(BuildContext context) {
    final navigation = _AppNavigationScope.maybeOf(context);
    if (navigation == null || !navigation.isAvailable) {
      return Navigator.of(context).canPop()
          ? const BackButton()
          : const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    return IconButton(
      tooltip: navigation.isOpen ? l10n.navClose : l10n.navOpen,
      onPressed: navigation.onToggle,
      icon: Icon(navigation.isOpen ? Icons.close : Icons.menu),
    );
  }
}

class _NavigationItem {
  const _NavigationItem(this.route, this.label, this.icon);

  final String route;
  final String label;
  final IconData icon;
}

class _NavigationMenuItem extends StatelessWidget {
  const _NavigationMenuItem({
    required this.item,
    required this.onTap,
    this.selected = false,
  });

  final _NavigationItem item;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Material(
          color: selected ? const Color(0xFF31577E) : Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              height: 48,
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Icon(item.icon, color: Colors.white, size: 22),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppNavigationScope extends InheritedWidget {
  const _AppNavigationScope({
    required this.isOpen,
    required this.isAvailable,
    required this.onToggle,
    required super.child,
  });

  final bool isOpen;
  final bool isAvailable;
  final VoidCallback onToggle;

  static _AppNavigationScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_AppNavigationScope>();

  @override
  bool updateShouldNotify(_AppNavigationScope oldWidget) =>
      isOpen != oldWidget.isOpen || isAvailable != oldWidget.isAvailable;
}
