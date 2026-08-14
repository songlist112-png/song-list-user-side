import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_app/features/auth/presentation/controllers/auth_controller.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockAuthResponse extends Mock implements AuthResponse {}

class MockGoogleAuthClient extends Mock implements GoogleAuthClient {}

void main() {
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;
  late MockGoogleAuthClient mockGoogleAuthClient;
  late AuthController authController;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();
    mockGoogleAuthClient = MockGoogleAuthClient();

    when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
    when(() => mockGoogleAuthClient.signOut()).thenAnswer((_) async {});

    authController = AuthController(
      supabase: mockSupabaseClient,
      googleAuthClient: mockGoogleAuthClient,
    );
  });

  group('AuthController - signInWithEmail', () {
    test('successfully signs in with email and password', () async {
      // Arrange
      final mockResponse = MockAuthResponse();
      when(
        () => mockGoTrueClient.signInWithPassword(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).thenAnswer((_) async => mockResponse);

      // Act
      final result = await authController.signInWithEmail(
        'test@example.com',
        'password123',
      );

      // Assert
      expect(result, equals(mockResponse));
      verify(
        () => mockGoTrueClient.signInWithPassword(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).called(1);
    });

    test('rethrows exception on sign in failure', () async {
      // Arrange
      when(
        () => mockGoTrueClient.signInWithPassword(
          email: 'test@example.com',
          password: 'wrong',
        ),
      ).thenThrow(AuthException('Invalid login credentials'));

      // Act & Assert
      expect(
        () => authController.signInWithEmail('test@example.com', 'wrong'),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('AuthController - signUpWithEmail', () {
    test('successfully signs up with email and password', () async {
      // Arrange
      final mockResponse = MockAuthResponse();
      when(
        () => mockGoTrueClient.signUp(
          email: 'new@example.com',
          password: 'password123',
        ),
      ).thenAnswer((_) async => mockResponse);

      // Act
      final result = await authController.signUpWithEmail(
        'new@example.com',
        'password123',
      );

      // Assert
      expect(result, equals(mockResponse));
      verify(
        () => mockGoTrueClient.signUp(
          email: 'new@example.com',
          password: 'password123',
        ),
      ).called(1);
    });
  });

  group('AuthController - signOut', () {
    test('signs out successfully', () async {
      // Arrange
      when(() => mockGoTrueClient.signOut()).thenAnswer((_) async {});

      // Act
      await authController.signOut();

      // Assert
      verify(() => mockGoTrueClient.signOut()).called(1);
      verify(() => mockGoogleAuthClient.signOut()).called(1);
    });

    test('still signs out from Supabase when Google sign-out fails', () async {
      when(
        () => mockGoogleAuthClient.signOut(),
      ).thenThrow(Exception('No Google session'));
      when(() => mockGoTrueClient.signOut()).thenAnswer((_) async {});

      await authController.signOut();

      verify(() => mockGoTrueClient.signOut()).called(1);
    });
  });
}
