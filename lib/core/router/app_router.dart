import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_routes.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/create_pin_screen.dart';
import '../../features/auth/presentation/screens/confirm_pin_screen.dart';
import '../../features/auth/presentation/screens/invitation_code_screen.dart';
import '../../features/home/presentation/screens/main_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/explore/presentation/screens/explore_screen.dart';
import '../../features/portfolio/presentation/screens/portfolio_screen.dart';
import '../../features/transaction/presentation/screens/transaction_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/kyc/presentation/screens/risk_profile_screen.dart';
import '../../features/kyc/presentation/screens/risk_result_screen.dart';
import '../../features/kyc/presentation/screens/ktp_guide_screen.dart';
import '../../features/kyc/presentation/screens/personal_data_screen.dart';
import '../../features/kyc/presentation/screens/bank_data_screen.dart';
import '../../features/kyc/presentation/screens/signature_screen.dart';
import '../../features/kyc/presentation/screens/kyc_success_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isOnSplash = state.matchedLocation == AppRoutes.splash;
      final isOnAuth = state.matchedLocation.startsWith('/register') ||
          state.matchedLocation.startsWith('/otp') ||
          state.matchedLocation.startsWith('/create-pin') ||
          state.matchedLocation.startsWith('/confirm-pin') ||
          state.matchedLocation.startsWith('/invitation-code');

      if (authState.status == AuthStatus.unknown) return null;

      if (authState.status == AuthStatus.unauthenticated) {
        if (!isOnAuth && !isOnSplash) return AppRoutes.register;
        return null;
      }

      if (authState.status == AuthStatus.authenticated) {
        if (isOnAuth || isOnSplash) return AppRoutes.main;
        return null;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.otp,
        builder: (context, state) {
          final phone = state.extra as String? ?? '';
          return OtpScreen(phoneNumber: phone);
        },
      ),
      GoRoute(
        path: AppRoutes.createPin,
        builder: (context, state) => const CreatePinScreen(),
      ),
      GoRoute(
        path: AppRoutes.confirmPin,
        builder: (context, state) {
          final pin = state.extra as String? ?? '';
          return ConfirmPinScreen(originalPin: pin);
        },
      ),
      GoRoute(
        path: AppRoutes.invitationCode,
        builder: (context, state) => const InvitationCodeScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainScreen(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.main,
            redirect: (_, __) => AppRoutes.home,
          ),
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.portfolio,
            builder: (context, state) => const PortfolioScreen(),
          ),
          GoRoute(
            path: AppRoutes.explore,
            builder: (context, state) => const ExploreScreen(),
          ),
          GoRoute(
            path: AppRoutes.transaction,
            builder: (context, state) => const TransactionScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.riskProfile,
        builder: (context, state) => const RiskProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.riskResult,
        builder: (context, state) {
          final result = state.extra as String? ?? 'Moderat';
          return RiskResultScreen(riskType: result);
        },
      ),
      GoRoute(
        path: AppRoutes.ktpGuide,
        builder: (context, state) => const KtpGuideScreen(),
      ),
      GoRoute(
        path: AppRoutes.personalData,
        builder: (context, state) => const PersonalDataScreen(),
      ),
      GoRoute(
        path: AppRoutes.bankData,
        builder: (context, state) => const BankDataScreen(),
      ),
      GoRoute(
        path: AppRoutes.signature,
        builder: (context, state) => const SignatureScreen(),
      ),
      GoRoute(
        path: AppRoutes.kycSuccess,
        builder: (context, state) => const KycSuccessScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Halaman tidak ditemukan: ${state.error}'),
      ),
    ),
  );
});
