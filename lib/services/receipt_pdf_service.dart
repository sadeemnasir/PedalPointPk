import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/booking.dart';

class ReceiptPdfService {
  static Future<Uint8List> generate(Booking booking, PdfPageFormat format) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(22),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#059669'),
              borderRadius: pw.BorderRadius.circular(16),
            ),
            child: pw.Column(
              children: [
                pw.Container(
                  width: 52,
                  height: 52,
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#33FFFFFF'),
                    shape: pw.BoxShape.circle,
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      '✓',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Booking Confirmed!',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'PedalPoint Cycle Rental Pakistan',
                  style: pw.TextStyle(
                    color: PdfColor.fromHex('#D1FAE5'),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 22),
          pw.Text(
            'RENTAL RECEIPT',
            style: pw.TextStyle(
              color: PdfColor.fromHex('#0175C2'),
              fontSize: 15,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 14),
          _row('Receipt Ref', booking.refCode),
          _row('Rider Name', booking.customerName),
          _row('CNIC / Passport', booking.cnic),
          _row('WhatsApp', booking.phone),
          _row('Reserved Cycle', booking.bikeTitle),
          _row('Pick-Up Hub', booking.city),
          _row('Delivery', booking.delivery),
          _row('Rental Dates', '${booking.startDate} to ${booking.endDate}'),
          _row('Duration', '${booking.days} ${booking.days == 1 ? 'Day' : 'Days'}'),
          pw.SizedBox(height: 10),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#ECFDF5'),
              border: pw.Border.all(
                color: PdfColor.fromHex('#A7F3D0'),
              ),
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Total Fees Paid',
                  style: pw.TextStyle(
                    color: PdfColor.fromHex('#047857'),
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'PKR ${_money(booking.totalAmount)}',
                  style: pw.TextStyle(
                    color: PdfColor.fromHex('#047857'),
                    fontSize: 17,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 28),
          pw.Divider(color: PdfColor.fromHex('#E2E8F0')),
          pw.SizedBox(height: 10),
          pw.Text(
            'Thank you for choosing PedalPoint.',
            style: pw.TextStyle(
              color: PdfColor.fromHex('#334155'),
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Please keep this receipt for your rental records.',
            style: pw.TextStyle(
              color: PdfColor.fromHex('#64748B'),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static Future<void> printReceipt(Booking booking) async {
    await Printing.layoutPdf(
      name: 'PedalPoint-${booking.refCode.replaceAll('#', '')}',
      onLayout: (format) => generate(booking, format),
    );
  }

  static Future<void> downloadReceipt(Booking booking) async {
    final bytes = await generate(booking, PdfPageFormat.a4);
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'PedalPoint-${booking.refCode.replaceAll('#', '')}.pdf',
    );
  }

  static pw.Widget _row(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 9),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 125,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                color: PdfColor.fromHex('#94A3B8'),
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                color: PdfColor.fromHex('#334155'),
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _money(int n) {
    return n.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}
