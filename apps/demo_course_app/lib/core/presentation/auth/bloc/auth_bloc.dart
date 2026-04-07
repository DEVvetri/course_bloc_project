
import 'package:demo_course_app/core/presentation/auth/bloc/events/auth_events.dart';
import 'package:demo_course_app/core/presentation/auth/bloc/state/auth_state.dart';
import 'package:demo_course_app/core/domain/auth/service/auth_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent,AuthState> {
  final AuthService authService;

  AuthBloc(this.authService) : super(AuthInitial()) {
    on<AppStarted>((event, emit) {
      authService.authStateChanges.listen((user) {
        if (user != null) {
          add(_UserChanged(true));
        } else {
          add(_UserChanged(false));
        }
      });
    });

    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authService.login(event.email, event.password);
        if (user != null) {
          emit(AuthAuthenticated());
        } else {
          emit(AuthUnauthenticated());
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authService.signUp(event.email, event.password);
        if (user != null) {
          emit(AuthAuthenticated());
        } else {
          emit(AuthUnauthenticated());
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<LogoutRequested>((event, emit) async {
      await authService.logout();
      emit(AuthUnauthenticated());
    });

    on<_UserChanged>((event, emit) {
      emit(event.isLoggedIn ? AuthAuthenticated() : AuthUnauthenticated());
    });
  }
}

class _UserChanged extends AuthEvent {
  final bool isLoggedIn;
  _UserChanged(this.isLoggedIn);
}
