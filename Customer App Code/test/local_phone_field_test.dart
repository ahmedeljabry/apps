import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_text_field_widget.dart';

void main() {
  testWidgets('phone field accepts a 10-digit local number in LTR', (
    tester,
  ) async {
    final TextEditingController controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: CustomTextFieldWidget(
            controller: controller,
            inputType: TextInputType.phone,
            isPhone: true,
            showLabelText: false,
          ),
        ),
      ),
    );

    expect(find.text('06xxxxxxxx'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), '061234567890');
    expect(controller.text, '0612345678');
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).textDirection,
      TextDirection.ltr,
    );
  });
}
