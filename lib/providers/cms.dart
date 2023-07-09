import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghotpromax/modules/cms/services/client.dart';
import 'package:ghotpromax/providers/preferences.dart';

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

final cmsUser = FutureProvider((ref) {
  final client = ref.watch(cmsClientProvider);
  return client.fetchUserDetail();
});
