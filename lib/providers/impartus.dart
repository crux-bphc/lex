import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghotpromax/logger.dart';
import 'package:ghotpromax/modules/impartus/services/client.dart';
import 'package:ghotpromax/providers/preferences.dart';

@immutable
class _ImpartusSettings {
  const _ImpartusSettings(this.email, this.password);
  final String email;
  final String password;
}

class _ImpartusSettingsNotifier extends Notifier<_ImpartusSettings> {
  @override
  _ImpartusSettings build() {
    final prefs = ref.watch(preferencesProvider);

    ref.listenSelf((previous, next) {
      prefs.setString("impartus_email", next.email);
      prefs.setString("impartus_password", next.password);
      prefs.remove("impartus_token");
      logger.i("remove cached impartus token");
    });

    return _ImpartusSettings(
      prefs.getString("impartus_email") ?? "",
      prefs.getString("impartus_password") ?? "",
    );
  }

  void setEmail(String email) {
    state = _ImpartusSettings(email, state.password);
  }

  void setPassword(String password) {
    state = _ImpartusSettings(state.email, password);
  }
}

final impartusSettingsProvider =
    NotifierProvider<_ImpartusSettingsNotifier, _ImpartusSettings>(
  _ImpartusSettingsNotifier.new,
);

final impartusClientProvider = Provider<ImpartusClient>(
  (ref) => throw UnimplementedError(),
);
