import 'dart:io';

void main() async {
  final file = File('assets/service_account.json');
  final contents = await file.readAsString();

  final envFile = File('.env.secrets');
  await envFile.writeAsString(
      'FCM_SERVICE_ACCOUNT=\'${contents.replaceAll('\n', '')}\'\n');

  print('Setting secret...');
  final result = await Process.run(
    'npx.cmd',
    [
      'supabase',
      'secrets',
      'set',
      '--env-file',
      '.env.secrets',
      '--project-ref',
      'bgryhkvorqgjlvmtbcht'
    ],
  );

  print('Exit code: ${result.exitCode}');
  print('Stdout: ${result.stdout}');
  print('Stderr: ${result.stderr}');

  await envFile.delete();
}
