import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'main.dart'; // for MainNavigationPage and deepLinkNotifier

// Global notifier for handling deep link job IDs
class DeepLinkNotifier extends ChangeNotifier {
  String? _pendingJobId;

  String? get pendingJobId => _pendingJobId;

  void setPendingJobId(String jobId) {
    _pendingJobId = jobId;
    notifyListeners();
  }

  void clearPendingJobId() {
    _pendingJobId = null;
  }
}

// Create a global instance
final deepLinkNotifier = DeepLinkNotifier();

// Create your appRouter
final appRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainNavigationPage(),
    ),
    GoRoute(
      path: '/job',
      redirect: (context, state) {
        final jobId = state.uri.queryParameters['id'];
        if (jobId != null && jobId.isNotEmpty) {
          deepLinkNotifier.setPendingJobId(jobId);
        }
        return '/';
      },
    ),
  ],
);