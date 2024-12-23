import 'package:eventy/features/user_services/widgets/delete_alert.dart';
import 'package:flutter/material.dart';

void showDeleteDialog({required BuildContext context, required String id}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: DeleteAlert(id),
        ),
      );
    },
  );
}