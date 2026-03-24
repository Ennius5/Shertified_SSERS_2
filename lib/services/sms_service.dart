import 'package:another_telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class SmsService {
  final Telephony telephony = Telephony.instance;

  Future<void> sendSOS(
      List<String> numbers, String message) async {
    final permission = await Permission.sms.request();

    if (!permission.isGranted) {
      throw Exception("SMS permission denied");
    }

    for (String number in numbers) {
      await telephony.sendSms(
        to: number,
        message: message,
      );
    }
  }
}