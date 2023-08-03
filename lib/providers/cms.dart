import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghotpromax/modules/cms/services/client.dart';
import 'package:ghotpromax/providers/preferences.dart';
import 'package:ghotpromax/utils/logger.dart';

final cmsTokenProvider = StateProvider<String>((ref) {
  final prefs = ref.watch(preferencesProvider);

  ref.listenSelf((previous, next) {
    prefs.setString("cms_token", next);
  });

  return prefs.getString("cms_token") ?? "";
});

final cmsClientProvider = Provider((ref) {
  final token = ref.watch(cmsTokenProvider);
  return CMSClient(token);
});

final cmsUser = FutureProvider((ref) async {
  final client = ref.watch(cmsClientProvider);
  return client.fetchUserDetail();
});

final registeredCoursesProvider = FutureProvider((ref) {
  final client = ref.watch(cmsClientProvider);
  final user = ref.watch(cmsUser);
  return client.fetchCourses(user.asData!.value.userid);
});

final courseTitleProvider = Provider.autoDispose.family<String, int>((ref, id) {
  final courses = ref.watch(registeredCoursesProvider).valueOrNull;
  if (courses == null) {
    logger.w("Registered courses were not loaded");
    return "";
  }

  final course = courses.firstWhere((course) => course.id == id);
  return course.displayname;
});
