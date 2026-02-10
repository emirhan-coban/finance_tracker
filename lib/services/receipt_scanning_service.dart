import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ReceiptScanningService {
  final _textRecognizer = TextRecognizer();
  final _picker = ImagePicker();

  Future<XFile?> pickImage(ImageSource source) async {
    return await _picker.pickImage(source: source);
  }

  Future<Map<String, dynamic>> scanReceipt(XFile imageFile) async {
    final inputImage = InputImage.fromFilePath(imageFile.path);
    final recognizedText = await _textRecognizer.processImage(inputImage);

    String text = recognizedText.text;

    // Parsing Logic
    double? amount = _extractAmount(text);
    DateTime? date = _extractDate(text);
    String? merchant = _extractMerchant(text);

    return {
      'amount': amount,
      'date': date,
      'merchant': merchant,
      'rawText': text,
    };
  }

  double? _extractAmount(String text) {
    // Look for lines containing "Total", "Tutar", "Toplam"
    // Regex to find decimal numbers
    final amountRegex = RegExp(r'(\d+[.,]\d{2})');
    final lines = text.split('\n');
    double? maxAmount;

    for (var line in lines) {
      // Simple heuristic: if line contains total keywords, prioritize meaningful numbers
      if (line.toLowerCase().contains('total') ||
          line.toLowerCase().contains('toplam') ||
          line.toLowerCase().contains('tutar')) {
        final match = amountRegex.firstMatch(line);
        if (match != null) {
          String amountStr = match.group(0)!.replaceAll(',', '.');
          // specific to locale where comma means decimal point, but let's standardise
          // If there are multiple dots, it's invalid. If comma is used as decimal separator.
          try {
            return double.parse(amountStr);
          } catch (e) {
            // continue
          }
        }
      }
    }

    // Fallback: Find the largest number in the text that looks like a price
    final allMatches = amountRegex.allMatches(text);
    for (var match in allMatches) {
      String amountStr = match.group(0)!.replaceAll(',', '.');
      try {
        double val = double.parse(amountStr);
        if (maxAmount == null || val > maxAmount) {
          maxAmount = val;
        }
      } catch (e) {
        // continue
      }
    }

    return maxAmount;
  }

  DateTime? _extractDate(String text) {
    // Regex for DD/MM/YYYY, YYYY-MM-DD, DD.MM.YYYY
    final dateRegex = RegExp(
      r'(\d{1,2}[./-]\d{1,2}[./-]\d{2,4})|(\d{4}[./-]\d{1,2}[./-]\d{1,2})',
    );

    final match = dateRegex.firstMatch(text);
    if (match != null) {
      String dateStr = match.group(0)!;
      // Try parsing with common formats
      List<String> formats = [
        'dd/MM/yyyy',
        'dd.MM.yyyy',
        'yyyy-MM-dd',
        'dd-MM-yyyy',
        'dd/MM/yy',
      ];

      for (var format in formats) {
        try {
          return DateFormat(format).parse(dateStr);
        } catch (e) {
          // continue
        }
      }
    }
    return null;
  }

  String? _extractMerchant(String text) {
    // Usually the first line of the receipt is the merchant name
    final lines = text.split('\n');
    if (lines.isNotEmpty) {
      return lines.first.trim();
    }
    return null;
  }

  void dispose() {
    _textRecognizer.close();
  }
}
