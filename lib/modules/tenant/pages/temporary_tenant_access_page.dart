import 'package:flutter/material.dart';

import '../../../core/services/http/api_client.dart';
import '../../auth/pages/auth_gate.dart';

class TemporaryTenantAccessPage extends StatelessWidget {
  const TemporaryTenantAccessPage({super.key, required this.apiClient});

  final ApiClient apiClient;

  @override
  Widget build(BuildContext context) => AuthGate(apiClient: apiClient);
}
