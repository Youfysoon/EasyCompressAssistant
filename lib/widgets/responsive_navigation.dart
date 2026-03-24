import 'package:fluent_ui/fluent_ui.dart';

// The purpose of this file is to provide a responsive navigation widget for different screen sizes.

/// NavItem Data Class
class NavItem {
  final IconData icon;
  final String label;
  final Widget body;

  const NavItem({
    required this.icon,
    required this.label,
    required this.body,
  });
}

/// Responsive Navigation Component
/// Wide Screen: Fluent UI NavigationView (Compact)
/// Narrow Screen: Bottom Navigation Bar (With Blue Bar + Animation)
class ResponsiveNavigation extends StatefulWidget {
  final String title;
  final List<NavItem> items;

  const ResponsiveNavigation({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  State<ResponsiveNavigation> createState() => _ResponsiveNavigationState();
}

class _ResponsiveNavigationState extends State<ResponsiveNavigation>
    with TickerProviderStateMixin {
  int _currentIndex = 0;

  // used for bottom navigation bar
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  // Initialize Animation Controllers
  void _initAnimations() {
    _animationControllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );

    _animations = _animationControllers.map((controller) {
      return CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      );
    }).toList();

    // Initialize the value of animation to 1.0 for the current selected item
    _animationControllers[_currentIndex].value = 1.0;
  }

  @override
  void dispose() {
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onIndexChanged(int index) {
    if (index == _currentIndex) return;

    setState(() {
      // Play the animation inversely for the previously selected item
      _animationControllers[_currentIndex].reverse();

      // Play the animation for the newly selected item
      _currentIndex = index;
      _animationControllers[_currentIndex].forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 600;

    if (isNarrow) {
      return _buildNarrowLayout();
    } else {
      return _buildWideLayout();
    }
  }

  /// Wide Screen Layout - Fluent UI NavigationView (Compact)
  Widget _buildWideLayout() {
    return NavigationView(
      appBar: NavigationAppBar(
        title: Text(widget.title),
      ),
      pane: NavigationPane(
        selected: _currentIndex,
        onChanged: _onIndexChanged,
        displayMode: PaneDisplayMode.compact,
        size: const NavigationPaneSize(
          openMinWidth: 150,
          openMaxWidth: 200,
          compactWidth: 50,
        ),
        items: <NavigationPaneItem>[
          ...widget.items.map((item) => PaneItem(
            icon: Icon(item.icon, size: 20),
            title: Text(item.label),
            body: item.body,
          )),
        ],
      ),
    );
  }

  /// Narrow Screen Layout - Bottom Navigation Bar (With Blue Bar + Animation)
  Widget _buildNarrowLayout() {
    final theme = FluentTheme.of(context);
    final accentColor = theme.accentColor;

    return ScaffoldPage(
      padding: EdgeInsets.zero,
      content: AnimatedPageSwitcher(
        currentIndex: _currentIndex,
        children: widget.items.map((item) => item.body).toList(),
      ),
      bottomBar: Container(
        decoration: BoxDecoration(
          color: theme.menuColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: widget.items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;

                return Expanded(
                  child: _BottomNavItem(
                    icon: item.icon,
                    label: item.label,
                    isSelected: index == _currentIndex,
                    accentColor: accentColor,
                    animation: _animations[index],
                    onTap: () => _onIndexChanged(index),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom Navigation Item Component (With Animation and Blue Bar)
class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color accentColor;
  final Animation<double> animation;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.accentColor,
    required this.animation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final color = Color.lerp(
            theme.inactiveColor,
            accentColor,
            animation.value,
          )!;

          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 24,
                color: color,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: isSelected
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 20 + (animation.value * 8),
                height: 3,
                decoration: BoxDecoration(
                  color: accentColor.withAlpha((animation.value * 255).round()),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Page Switch Animation Wrapper
class AnimatedPageSwitcher extends StatelessWidget {
  final int currentIndex;
  final List<Widget> children;

  const AnimatedPageSwitcher({
    super.key,
    required this.currentIndex,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.02, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey<int>(currentIndex),
        child: children[currentIndex],
      ),
    );
  }
}
