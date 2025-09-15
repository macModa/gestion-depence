import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class PdfExportService {
  static Future<void> exportTransactionsPdf(
      String title, List<Transaction> transactions) async {
    final pdf = pw.Document();

    // Calculate totals for the summary section
    double totalIncome = 0;
    double totalExpenses = 0;
    for (var tx in transactions) {
      if (tx.type == 'income') {
        totalIncome += tx.amount;
      } else {
        totalExpenses += tx.amount;
      }
    }
    final double netBalance = totalIncome - totalExpenses;
    final currencyFormatter =
        NumberFormat.currency(locale: 'fr_FR', symbol: '€');

    // Load fonts that support Unicode characters like '€'
    final fontData = await rootBundle.load("assets/fonts/NotoSans-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);
    final boldFontData = await rootBundle.load("assets/fonts/NotoSans-Bold.ttf");
    final ttfBold = pw.Font.ttf(boldFontData);

    final theme = pw.ThemeData.withFont(
      base: ttf,
      bold: ttfBold,
    );

    final tableHeaders = ['Date', 'Catégorie', 'Type', 'Montant'];

    final tableData = transactions.map((tx) {
      return [
        DateFormat('dd/MM/yyyy').format(tx.date),
        tx.category,
        tx.type == 'income' ? 'Revenu' : 'Dépense',
        currencyFormatter.format(tx.amount),
      ];
    }).toList();

    pdf.addPage(
      pw.MultiPage(
        theme: theme,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(title, textScaleFactor: 1.5),
                  pw.Text(DateFormat('dd/MM/yyyy').format(DateTime.now())),
                ],
              ),
            ),
            pw.Table.fromTextArray(
              headers: tableHeaders,
              data: tableData,
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              cellHeight: 30,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.center,
                3: pw.Alignment.centerRight,
              },
            ),
            pw.Divider(height: 20),
            pw.SizedBox(height: 20),
            pw.Header(level: 1, text: 'Résumé'),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
              pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    _buildSummaryRow('Revenus totaux:',
                        currencyFormatter.format(totalIncome), PdfColors.green),
                    _buildSummaryRow('Dépenses totales:',
                        currencyFormatter.format(totalExpenses), PdfColors.red),
                    pw.Divider(height: 10, thickness: 1),
                    _buildSummaryRow('Solde net:',
                        currencyFormatter.format(netBalance),
                        netBalance >= 0 ? PdfColors.black : PdfColors.red,
                        isBold: true),
                  ])
            ]),
          ];
        },
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
            child: pw.Text(
              'Page ${context.pageNumber} sur ${context.pagesCount}',
              style: pw.Theme.of(context)
                  .defaultTextStyle
                  .copyWith(color: PdfColors.grey),
            ),
          );
        },
      ),
    );

    // Show print/save dialog
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static pw.Widget _buildSummaryRow(String label, String amount, PdfColor color,
      {bool isBold = false}) {
    return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Row(children: [
          pw.Text(label,
              style: pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.SizedBox(width: 20),
          pw.Text(amount,
              style: pw.TextStyle(color: color, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        ]));
  }
}