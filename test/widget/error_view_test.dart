import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:youtube_clone/presentation/widgets/error_view.dart';

Widget _testWidget(Widget child) => ScreenUtilInit(
  designSize: const Size(375, 812),
  builder: (_, __) => MaterialApp(home: Scaffold(body: child)),
);

void main() {
  group('ErrorView Widget', () {
    testWidgets('displays the provided error message', (tester) async {
      await tester.pumpWidget(
        _testWidget(const ErrorView(message: 'Failed to load videos')),
      );
      expect(find.text('Failed to load videos'), findsOneWidget);
    });

    testWidgets('displays "Something went wrong" header', (tester) async {
      await tester.pumpWidget(
        _testWidget(const ErrorView(message: 'Any error')),
      );
      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('shows retry button when onRetry is provided', (tester) async {
      await tester.pumpWidget(
        _testWidget(ErrorView(message: 'Error', onRetry: () {})),
      );
      expect(find.text('Try Again'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('does NOT show retry button when onRetry is null', (
      tester,
    ) async {
      await tester.pumpWidget(_testWidget(const ErrorView(message: 'Error')));
      expect(find.text('Try Again'), findsNothing);
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('retry button invokes the callback', (tester) async {
      var retryCount = 0;
      await tester.pumpWidget(
        _testWidget(ErrorView(message: 'Error', onRetry: () => retryCount++)),
      );

      await tester.tap(find.text('Try Again'));
      await tester.pump();

      expect(retryCount, 1);
    });

    testWidgets('tapping retry multiple times fires callback multiple times', (
      tester,
    ) async {
      var count = 0;
      await tester.pumpWidget(
        _testWidget(ErrorView(message: 'Error', onRetry: () => count++)),
      );

      await tester.tap(find.text('Try Again'));
      await tester.pump();
      await tester.tap(find.text('Try Again'));
      await tester.pump();

      expect(count, 2);
    });

    testWidgets('shows default error icon when icon not overridden', (
      tester,
    ) async {
      await tester.pumpWidget(_testWidget(const ErrorView(message: 'Error')));
      // Default icon uses FontAwesomeIcons.circleExclamation
      expect(find.byType(Icon), findsOneWidget);
    });
  });
}
