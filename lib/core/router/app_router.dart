import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:globaledu_ai/core/router/route_names.dart';
import 'package:globaledu_ai/core/router/route_transitions.dart';
import 'package:globaledu_ai/features/auth/presentation/providers/auth_provider.dart';
import 'package:globaledu_ai/features/auth/presentation/screens/login_screen.dart';
import 'package:globaledu_ai/features/auth/presentation/screens/register_screen.dart';
import 'package:globaledu_ai/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:globaledu_ai/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:globaledu_ai/features/onboarding/presentation/screens/profile_setup_screen.dart';
import 'package:globaledu_ai/features/home/presentation/screens/home_screen.dart';
import 'package:globaledu_ai/features/universities/presentation/screens/university_search_screen.dart';
import 'package:globaledu_ai/features/universities/presentation/screens/university_detail_screen.dart';
import 'package:globaledu_ai/features/ai_assistant/presentation/screens/ai_chat_screen.dart';
import 'package:globaledu_ai/features/ai_assistant/presentation/screens/conversation_list_screen.dart';
import 'package:globaledu_ai/features/applications/presentation/screens/applications_screen.dart';
import 'package:globaledu_ai/features/applications/presentation/screens/application_detail_screen.dart';
import 'package:globaledu_ai/features/applications/presentation/screens/create_application_screen.dart';
import 'package:globaledu_ai/features/documents/presentation/screens/documents_screen.dart';
import 'package:globaledu_ai/features/documents/presentation/screens/ai_review_screen.dart';
import 'package:globaledu_ai/features/visa/presentation/screens/visa_guide_screen.dart';
import 'package:globaledu_ai/features/visa/presentation/screens/visa_checklist_screen.dart';
import 'package:globaledu_ai/features/visa/presentation/screens/interview_prep_screen.dart';
import 'package:globaledu_ai/features/scholarships/presentation/screens/scholarships_screen.dart';
import 'package:globaledu_ai/features/scholarships/presentation/screens/scholarship_detail_screen.dart';
import 'package:globaledu_ai/features/profile/presentation/screens/profile_screen.dart';
import 'package:globaledu_ai/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:globaledu_ai/features/profile/presentation/screens/settings_screen.dart';
import 'package:globaledu_ai/features/subscription/presentation/screens/subscription_screen.dart';
import 'package:globaledu_ai/features/splash/presentation/screens/splash_screen.dart';
import 'package:globaledu_ai/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:globaledu_ai/core/widgets/layouts/scaffold_with_nav.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteNames.splashPath,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final currentPath = state.matchedLocation;

      final authPaths = [
        RouteNames.loginPath,
        RouteNames.registerPath,
        RouteNames.forgotPasswordPath,
      ];
      final publicPaths = [
        RouteNames.splashPath,
        RouteNames.welcomePath,
        ...authPaths,
      ];

      // Splash → redirect based on auth
      if (currentPath == RouteNames.splashPath) {
        return isLoggedIn ? RouteNames.shellPath : RouteNames.welcomePath;
      }

      // Not logged in & not on a public path → welcome
      if (!isLoggedIn && !publicPaths.contains(currentPath)) {
        return RouteNames.welcomePath;
      }

      // Logged in & on auth path → home
      if (isLoggedIn && authPaths.contains(currentPath)) {
        return RouteNames.shellPath;
      }

      return null;
    },
    routes: [
      // ─── Splash ───
      GoRoute(
        path: RouteNames.splashPath,
        pageBuilder: (context, state) => RouteTransitions.fade(
          state: state,
          child: const SplashScreen(),
        ),
      ),

      // ─── Auth Routes ───
      GoRoute(
        name: RouteNames.welcome,
        path: RouteNames.welcomePath,
        pageBuilder: (context, state) => RouteTransitions.fade(
          state: state,
          child: const WelcomeScreen(),
        ),
      ),
      GoRoute(
        name: RouteNames.login,
        path: RouteNames.loginPath,
        pageBuilder: (context, state) => RouteTransitions.slideRight(
          state: state,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        name: RouteNames.register,
        path: RouteNames.registerPath,
        pageBuilder: (context, state) => RouteTransitions.slideRight(
          state: state,
          child: const RegisterScreen(),
        ),
      ),
      GoRoute(
        name: RouteNames.forgotPassword,
        path: RouteNames.forgotPasswordPath,
        pageBuilder: (context, state) => RouteTransitions.slideRight(
          state: state,
          child: const ForgotPasswordScreen(),
        ),
      ),

      // ─── Onboarding ───
      GoRoute(
        name: RouteNames.profileSetup,
        path: RouteNames.profileSetupPath,
        pageBuilder: (context, state) => RouteTransitions.slideUp(
          state: state,
          child: const ProfileSetupScreen(),
        ),
      ),

      // ─── Subscription / Paywall (modal) ───
      GoRoute(
        name: RouteNames.subscription,
        path: RouteNames.subscriptionPath,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => RouteTransitions.slideUp(
          state: state,
          child: const SubscriptionScreen(),
        ),
      ),
      GoRoute(
        name: RouteNames.paywall,
        path: RouteNames.paywallPath,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => RouteTransitions.slideUp(
          state: state,
          child: const SubscriptionScreen(),
        ),
      ),

      // ─── Main Shell ───
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => ScaffoldWithNav(child: child),
        routes: [
          // Home
          GoRoute(
            name: RouteNames.home,
            path: '${RouteNames.shellPath}/${RouteNames.homePath}',
            pageBuilder: (context, state) => RouteTransitions.fade(
              state: state,
              child: const HomeScreen(),
            ),
            routes: [
              GoRoute(
                name: RouteNames.notifications,
                path: 'notifications',
                parentNavigatorKey: _rootNavigatorKey,
                pageBuilder: (context, state) => RouteTransitions.slideRight(
                  state: state,
                  child: const NotificationsScreen(),
                ),
              ),
            ],
          ),

          // Universities
          GoRoute(
            name: RouteNames.universities,
            path: '${RouteNames.shellPath}/${RouteNames.universitiesPath}',
            pageBuilder: (context, state) => RouteTransitions.fade(
              state: state,
              child: const UniversitySearchScreen(),
            ),
            routes: [
              GoRoute(
                name: RouteNames.universityDetail,
                path: ':id',
                parentNavigatorKey: _rootNavigatorKey,
                pageBuilder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return RouteTransitions.slideRight(
                    state: state,
                    child: UniversityDetailScreen(universityId: id),
                  );
                },
              ),
            ],
          ),

          // AI Chat
          GoRoute(
            name: RouteNames.aiChat,
            path: '${RouteNames.shellPath}/${RouteNames.aiChatPath}',
            pageBuilder: (context, state) => RouteTransitions.fade(
              state: state,
              child: const AiChatScreen(),
            ),
            routes: [
              GoRoute(
                name: RouteNames.conversationList,
                path: 'conversations',
                parentNavigatorKey: _rootNavigatorKey,
                pageBuilder: (context, state) =>
                    RouteTransitions.slideRight(
                  state: state,
                  child: const ConversationListScreen(),
                ),
              ),
            ],
          ),

          // Applications
          GoRoute(
            name: RouteNames.applications,
            path: '${RouteNames.shellPath}/${RouteNames.applicationsPath}',
            pageBuilder: (context, state) => RouteTransitions.fade(
              state: state,
              child: const ApplicationsScreen(),
            ),
            routes: [
              GoRoute(
                name: RouteNames.createApplication,
                path: 'create',
                parentNavigatorKey: _rootNavigatorKey,
                pageBuilder: (context, state) =>
                    RouteTransitions.slideUp(
                  state: state,
                  child: const CreateApplicationScreen(),
                ),
              ),
              GoRoute(
                name: RouteNames.applicationDetail,
                path: ':id',
                parentNavigatorKey: _rootNavigatorKey,
                pageBuilder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return RouteTransitions.slideRight(
                    state: state,
                    child: ApplicationDetailScreen(applicationId: id),
                  );
                },
                routes: [
                  GoRoute(
                    name: RouteNames.documents,
                    path: 'documents',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) {
                      final appId = state.pathParameters['id']!;
                      return RouteTransitions.slideRight(
                        state: state,
                        child: DocumentsScreen(applicationId: appId),
                      );
                    },
                  ),
                  GoRoute(
                    name: RouteNames.visaGuide,
                    path: 'visa',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) =>
                        RouteTransitions.slideRight(
                      state: state,
                      child: const VisaGuideScreen(),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Profile
          GoRoute(
            name: RouteNames.profile,
            path: '${RouteNames.shellPath}/${RouteNames.profilePath}',
            pageBuilder: (context, state) => RouteTransitions.fade(
              state: state,
              child: const ProfileScreen(),
            ),
            routes: [
              GoRoute(
                name: RouteNames.editProfile,
                path: 'edit',
                parentNavigatorKey: _rootNavigatorKey,
                pageBuilder: (context, state) =>
                    RouteTransitions.slideRight(
                  state: state,
                  child: const EditProfileScreen(),
                ),
              ),
              GoRoute(
                name: RouteNames.settings,
                path: 'settings',
                parentNavigatorKey: _rootNavigatorKey,
                pageBuilder: (context, state) =>
                    RouteTransitions.slideRight(
                  state: state,
                  child: const SettingsScreen(),
                ),
              ),
            ],
          ),
        ],
      ),

      // ─── Standalone Routes (outside shell) ───
      GoRoute(
        name: RouteNames.scholarships,
        path: '/scholarships',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => RouteTransitions.slideRight(
          state: state,
          child: const ScholarshipsScreen(),
        ),
        routes: [
          GoRoute(
            name: RouteNames.scholarshipDetail,
            path: ':id',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return RouteTransitions.slideRight(
                state: state,
                child: ScholarshipDetailScreen(scholarshipId: id),
              );
            },
          ),
        ],
      ),
      GoRoute(
        name: RouteNames.visaChecklist,
        path: '/visa/:country',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final country = state.pathParameters['country']!;
          return RouteTransitions.slideRight(
            state: state,
            child: VisaChecklistScreen(country: country),
          );
        },
        routes: [
          GoRoute(
            name: RouteNames.interviewPrep,
            path: 'interview',
            pageBuilder: (context, state) {
              final country = state.pathParameters['country']!;
              return RouteTransitions.slideRight(
                state: state,
                child: InterviewPrepScreen(country: country),
              );
            },
          ),
        ],
      ),
      GoRoute(
        name: RouteNames.aiReview,
        path: '/ai-review/:id',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return RouteTransitions.slideUp(
            state: state,
            child: AiReviewScreen(documentId: id),
          );
        },
      ),
    ],
  );
});
