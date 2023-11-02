import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:running_mate/models/user.dart';

class UserNotifier extends StateNotifier<UserModel?> {
  UserNotifier() : super(null);

  void setUserInfo(UserModel user) {
    state = user;
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserModel?>((ref) {
  return UserNotifier();
});
