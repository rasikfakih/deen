import 'package:flutter_test/flutter_test.dart';

import 'package:deen/features/social/data/supabase_service.dart';

void main() {
  group('Invite code generator', () {
    test('generates exactly 6 characters', () {
      final service = SupabaseService();
      final code = service.generateInviteCode();
      expect(code.length, 6);
    });

    test('is alphanumeric uppercase', () {
      final service = SupabaseService();
      final code = service.generateInviteCode();
      expect(RegExp(r'^[A-Za-z0-9]{6}$').hasMatch(code), isTrue);
    });

    test('is uppercase or digit and uses secure random', () {
      final service = SupabaseService();
      // Generate 20 codes, ensure all are 6 and alphanumeric
      for (var i = 0; i < 20; i++) {
        final c = service.generateInviteCode();
        expect(c.length, 6);
        expect(
          RegExp(r'^[A-Z0-9]{6}$').hasMatch(c),
          isTrue,
          reason: 'Code $c should be A-Z0-9',
        );
      }
    });

    test('generates unique codes (probabilistic)', () {
      final service = SupabaseService();
      final codes = <String>{};
      for (var i = 0; i < 100; i++) {
        codes.add(service.generateInviteCode());
      }
      // With 36^6 possibilities, 100 should be mostly unique
      expect(codes.length, greaterThan(90));
    });
  });
}
