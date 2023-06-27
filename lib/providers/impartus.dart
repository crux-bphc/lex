import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghotpromax/providers/preferences.dart';

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
