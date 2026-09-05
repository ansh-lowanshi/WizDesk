import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glow_container.dart';
import '../bloc/focus_bloc.dart';
import '../bloc/focus_event.dart';
import '../bloc/focus_state.dart';

/// Fullscreen Immersive Zen Mode Focus Timer Screen
class FullscreenTimerScreen extends StatefulWidget {
  final bool enablePulseAnimation;

  const FullscreenTimerScreen({
    super.key,
    this.enablePulseAnimation = true,
  });

  @override
  State<FullscreenTimerScreen> createState() => _FullscreenTimerScreenState();
}

class _FullscreenTimerScreenState extends State<FullscreenTimerScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // Allow rotation (portrait & landscape) in Fullscreen Focus Timer
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Hide phone top status bar and bottom system navigation bar with edge-to-edge layout
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    if (widget.enablePulseAnimation) {
      _pulseController.repeat(reverse: true);
    }

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _restoreSystemOverlays() {
    // Re-lock orientation to portrait when exiting fullscreen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    _restoreSystemOverlays();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        _restoreSystemOverlays();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocBuilder<FocusBloc, FocusState>(
          builder: (context, state) {
            final modeColor = state.mode.color;
            final isRunning = state.isRunning;

            return Stack(
              children: [
                // Background Ambient Glow Orb
                Center(
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: isRunning ? _pulseAnimation.value : 1.0,
                        child: Container(
                          width: 300.r,
                          height: 300.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                modeColor.withAlpha(isRunning ? 45 : 20),
                                modeColor.withAlpha(isRunning ? 15 : 5),
                                modeColor.withAlpha(0),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Top Bar: Exit button & Phase mode (Safe padded)
                Positioned(
                  top: 0,
                  left: 20.w,
                  right: 20.w,
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: EdgeInsets.only(top: 16.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                        // Phase Badge
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 14.w, vertical: 6.h),
                          decoration: AppDecorations.badge(
                            color: modeColor,
                            borderRadius: 20.r,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8.r,
                                height: 8.r,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: modeColor,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                state.mode.label.toUpperCase(),
                                style: AppTypography.badge.copyWith(
                                  color: modeColor,
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Exit Fullscreen Button
                        IconButton(
                          icon: Icon(
                            Icons.fullscreen_exit_rounded,
                            size: 28.r,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () {
                            _restoreSystemOverlays();
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Center: Big Timer Display & Progress Ring
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Active Task Name (if present)
                      if (state.activeTask != null) ...[
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.task_alt_rounded,
                                    size: 16.r,
                                    color: AppColors.isDarkMode
                                        ? AppColors.accentCyan
                                        : AppColors.primary),
                                SizedBox(width: 8.w),
                                Text(
                                  state.activeTask!.title,
                                  style: AppTypography.titleMedium.copyWith(
                                    color: AppColors.textSecondary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 24.h),
                      ],

                      // Giant Circular Gauge
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glow backdrop
                          GlowContainer(
                            isCircle: true,
                            glowColor: isRunning ? modeColor : Colors.transparent,
                            blurRadius: isRunning ? 32 : 0,
                            spreadRadius: 2,
                            backgroundColor: Colors.transparent,
                            child: SizedBox(
                              width: 260.r,
                              height: 260.r,
                              child: CircularProgressIndicator(
                                value: state.progress,
                                strokeWidth: 8.r,
                                backgroundColor:
                                    AppColors.surfaceElevated,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(modeColor),
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                          ),

                          // Massive Digital Time Text
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                state.formattedTime,
                                style: AppTypography.timerDisplayFullscreen(
                                  fontSize: 62,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                state.isRunning
                                    ? 'FOCUS IN PROGRESS'
                                    : state.isPaused
                                        ? 'SESSION PAUSED'
                                        : 'READY TO FOCUS',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textMuted,
                                  letterSpacing: 1.5,
                                  fontSize: 11.sp,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 32.h),

                      // Cycle Indicator Dots (4-cycle sets)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (index) {
                          final currentCycleMod = state.completedCycles % 4;
                          final isFilled = index < currentCycleMod;
                          final isCurrent = index == currentCycleMod && isRunning;

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: EdgeInsets.symmetric(horizontal: 5.w),
                            width: isCurrent ? 24.w : 10.w,
                            height: 10.h,
                            decoration: BoxDecoration(
                              color: isFilled || isCurrent
                                  ? modeColor
                                  : AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(5.r),
                              boxShadow: isCurrent
                                  ? [
                                      BoxShadow(
                                        color: modeColor.withAlpha(150),
                                        blurRadius: 10,
                                      ),
                                    ]
                                  : null,
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),

                // Bottom Minimal Controls HUD
                Positioned(
                  bottom: 30.h,
                  left: 30.w,
                  right: 30.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Reset Button
                      IconButton(
                        icon: Icon(Icons.replay_rounded,
                            size: 26.r, color: AppColors.textSecondary),
                        onPressed: () {
                          context
                              .read<FocusBloc>()
                              .add(const ResetFocusSessionEvent());
                        },
                      ),

                      // Primary Play / Pause Button
                      GestureDetector(
                        onTap: () {
                          if (state.isRunning) {
                            context
                                .read<FocusBloc>()
                                .add(const PauseFocusSessionEvent());
                          } else if (state.isPaused) {
                            context
                                .read<FocusBloc>()
                                .add(const ResumeFocusSessionEvent());
                          } else {
                            context
                                .read<FocusBloc>()
                                .add(const StartFocusSessionEvent());
                          }
                        },
                        child: Container(
                          width: 68.r,
                          height: 68.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                modeColor,
                                modeColor.withAlpha(180),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: modeColor.withAlpha(140),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            state.isRunning
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            size: 36.r,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      // Skip Phase Button
                      IconButton(
                        icon: Icon(Icons.skip_next_rounded,
                            size: 28.r, color: AppColors.textSecondary),
                        onPressed: () {
                          context
                              .read<FocusBloc>()
                              .add(const SkipPhaseEvent());
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
