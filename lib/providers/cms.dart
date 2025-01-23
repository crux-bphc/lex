import 'package:get_it/get_it.dart';
import 'package:lex/modules/cms/services/client.dart';
import 'package:lex/providers/local_storage/local_storage.dart';
import 'package:lex/utils/logger.dart';
import 'package:signals/signals.dart';

final _prefs = GetIt.instance<LocalStorage>().preferences;

final cmsClient = computed(() => CMSClient(_prefs.cmsToken.value));

final cmsUser = computedAsync(() => cmsClient.value.fetchUserDetail());

final registeredCourses =
    computedAsync(() => cmsClient.value.fetchCourses(cmsUser().value!.userid));

final courseTitle = readonlySignalContainer<String, int>((id) {
  final courses = registeredCourses().value;
  if (courses == null) {
    logger.w("Registered courses were not loaded");
    return signal('');
  }

  final course = courses.firstWhere((course) => course.id == id);
  return signal(course.displayname);
});
