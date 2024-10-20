import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:signature/signature.dart';
import 'pdf_view.dart'; // Import your PDF preview screen

class CreateInvoiceScreen extends StatefulWidget {
  @override
  _CreateInvoiceScreenState createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _invoiceNumberController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _customerAddressController = TextEditingController();
  final _invoiceDateController = TextEditingController();
  final _invoiceDueDateController = TextEditingController(); // Due date controller
  List<Map<String, dynamic>> _invoiceItems = [];

  // Signature controller
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  // Default company details
  final String companyName = "ABC Corporation";
  final String companyAddress = "123 Business St, Suite 400";
  final String companyPhone = "(123) 456-7890";
  final String companyEmail = "info@abccorp.com";

  // Template Selection
  String _selectedTemplate = 'Template 1'; // Default to Template 1

  @override
  void dispose() {
    _invoiceNumberController.dispose();
    _customerNameController.dispose();
    _customerAddressController.dispose();
    _invoiceDateController.dispose();
    _invoiceDueDateController.dispose(); // Dispose due date controller
    _signatureController.dispose(); // Dispose the signature controller
    super.dispose();
  }

  void _addItem() {
    _invoiceItems.add({
      'itemCode': '',
      'itemName': '',
      'itemDescription': '',
      'quantity': 1,
      'price': 0.0,
    });
    setState(() {});
  }

  void _removeItem(int index) {
    _invoiceItems.removeAt(index);
    setState(() {});
  }

  Future<Uint8List> _downloadLogo() async {
    final response = await http.get(Uri.parse('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRRX5PzoDfuuZX0uQiNZ4dfCCozeV8K4F_fGw&s'));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load logo');
    }
  }

  Future<void> _generatePDFAndPreview() async {
    final pdf = pw.Document();
    final signatureImage = await _signatureController.toPngBytes();
    final logoImage = await _downloadLogo(); // Download logo from internet

    // Based on the selected template, call the respective PDF generation function
    if (_selectedTemplate == 'Template 1') {
      await _generateTemplate1(pdf, signatureImage, logoImage);
    } else {
      await _generateTemplate2(pdf, signatureImage, logoImage);
    }

    // Save the PDF file to the device
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/invoice_${_invoiceNumberController.text}.pdf');
    await file.writeAsBytes(await pdf.save());

    // Navigate to the PDF preview screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PDFViewerScreen3(filePath: file.path)),
    );
  }

  Future<void> _generateTemplate1(pw.Document pdf, Uint8List? signatureImage, Uint8List logoImage) async {
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Container(
          child: pw.Padding(
            padding: pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Template 1 Design
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Image(pw.MemoryImage(logoImage), width: 120, height: 60),
                    pw.Text("Invoice", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Text(companyName, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.Text(companyAddress, style: pw.TextStyle(fontSize: 12)),
                pw.Text('Phone: $companyPhone', style: pw.TextStyle(fontSize: 12)),
                pw.Text('Email: $companyEmail', style: pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 20),
                pw.Text('To:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.Text(_customerNameController.text, style: pw.TextStyle(fontSize: 12)),
                pw.Text(_customerAddressController.text, style: pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 20),
                pw.Table.fromTextArray(
                  headers: ['Hrs/Qty', 'Service', 'Rate/Price', 'Sub Total'],
                  data: _invoiceItems.map((item) => [
                    item['quantity'].toString(),
                    item['itemName'],
                    '\$${item['price'].toString()}',
                    '\$${(item['quantity'] * item['price']).toStringAsFixed(2)}',
                  ]).toList(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  cellStyle: pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 20),
                pw.Text('Signature:', style: pw.TextStyle(fontSize: 12)),
                if (signatureImage != null) pw.Image(pw.MemoryImage(signatureImage), height: 100, width: 200),
              ],
            ),
          ),
        ),
      ),
    );
  }


// Template 2 Design based on the new provided image
Future<void> _generateTemplate2(pw.Document pdf, Uint8List? signatureImage, Uint8List logoImage) async {
  pdf.addPage(
    pw.Page(
      build: (pw.Context context) => pw.Container(
        child: pw.Padding(
          padding: pw.EdgeInsets.all(20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Section: Logo, Business Info, Invoice Number and Date
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  // Left side: Business Name and Logo
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Image(pw.MemoryImage(logoImage), width: 60, height: 60),
                      pw.SizedBox(height: 10),
                      pw.Text(companyName, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                      pw.Text(companyAddress, style: pw.TextStyle(fontSize: 12)),
                      pw.Text('Phone: $companyPhone', style: pw.TextStyle(fontSize: 12)),
                      pw.Text('Email: $companyEmail', style: pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                  
                  // Right side: Invoice Number and Date
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text("Invoice #${_invoiceNumberController.text}", style: pw.TextStyle(fontSize: 18)),
                      pw.Text("Issue Date: ${_invoiceDateController.text}", style: pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // Main Section: Billing Info, Details, Payment
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  // Billing Information
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('BILL TO', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      pw.Text(_customerNameController.text, style: pw.TextStyle(fontSize: 12)),
                      pw.Text(_customerAddressController.text, style: pw.TextStyle(fontSize: 12)),
                    ],
                  ),

                  // Details Section
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('DETAILS', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      pw.Text("Enter a brief description", style: pw.TextStyle(fontSize: 12)),
                      pw.Text("About your job or project", style: pw.TextStyle(fontSize: 12)),
                    ],
                  ),

                  // Payment Section
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('PAYMENT', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Due Date: ${_invoiceDueDateController.text}', style: pw.TextStyle(fontSize: 12)),
                      pw.Text('\$${_calculateTotal().toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // Itemized Table for Services/Products
              pw.Table.fromTextArray(
                headers: ['ITEM', 'QTY', 'PRICE', 'AMOUNT'],
                data: _invoiceItems.map((item) => [
                  item['itemDescription'],
                  item['quantity'].toString(),
                  '\$${item['price'].toString()}',
                  '\$${(item['quantity'] * item['price']).toStringAsFixed(2)}',
                ]).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellStyle: pw.TextStyle(fontSize: 12),
              ),

              pw.SizedBox(height: 20),

              // Subtotal, Tax, and Total Due
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Subtotal: \$${_calculateSubTotal().toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 12)),
                      pw.Text('Tax: \$${_calculateTax().toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 12)),
                      pw.Text('Total Due: \$${_calculateTotal().toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 30),

              // Footer Section
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text('Want to customize your invoice even more?'),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text('Add taxes, discounts, and service charges', style: pw.TextStyle(fontSize: 10)),
                  pw.Text(' with Square Invoices.', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

double _calculateSubTotal() {
  return _invoiceItems.fold(0.0, (sum, item) {
    return sum + (item['quantity'] * item['price']);
  });
}

double _calculateTax() {
  return _calculateSubTotal() * 0.1; // Example tax calculation
}

double _calculateTotal() {
  return _calculateSubTotal() + _calculateTax();
}






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Invoice'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Dropdown to select the invoice template
              DropdownButtonFormField<String>(
                value: _selectedTemplate,
                decoration: InputDecoration(labelText: 'Select Template'),
                items: [
                  DropdownMenuItem(value: 'Template 1', child: Text('Template 1')),
                  DropdownMenuItem(value: 'Template 2', child: Text('Template 2')),
                ],
                onChanged: (String? value) {
                  setState(() {
                    _selectedTemplate = value!;
                  });
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _invoiceNumberController,
                decoration: InputDecoration(labelText: 'Invoice Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter invoice number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _customerNameController,
                decoration: InputDecoration(labelText: 'Customer Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter customer name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _customerAddressController,
                decoration: InputDecoration(labelText: 'Customer Address'),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _invoiceDateController,
                decoration: InputDecoration(
                  labelText: 'Invoice Date',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        _invoiceDateController.text =
                            pickedDate.toLocal().toString().split(' ')[0];
                      }
                    },
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _invoiceDueDateController, // Due date field
                decoration: InputDecoration(
                  labelText: 'Invoice Due Date',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        _invoiceDueDateController.text =
                            pickedDate.toLocal().toString().split(' ')[0];
                      }
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text('Invoice Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _invoiceItems.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4.0,
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          TextFormField(
                            initialValue: _invoiceItems[index]['itemCode'],
                            decoration: InputDecoration(labelText: 'Item Code'),
                            onChanged: (value) {
                              _invoiceItems[index]['itemCode'] = value;
                            },
                          ),
                          SizedBox(height: 5),
                          TextFormField(
                            initialValue: _invoiceItems[index]['itemName'],
                            decoration: InputDecoration(labelText: 'Item Name'),
                            onChanged: (value) {
                              _invoiceItems[index]['itemName'] = value;
                            },
                          ),
                          SizedBox(height: 5),
                          TextFormField(
                            initialValue: _invoiceItems[index]['itemDescription'],
                            decoration: InputDecoration(labelText: 'Item Description'),
                            onChanged: (value) {
                              _invoiceItems[index]['itemDescription'] = value;
                            },
                          ),
                          SizedBox(height: 5),
                          TextFormField(
                            initialValue: _invoiceItems[index]['quantity'].toString(),
                            decoration: InputDecoration(labelText: 'Quantity'),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              _invoiceItems[index]['quantity'] = int.tryParse(value) ?? 1;
                            },
                          ),
                          SizedBox(height: 5),
                          TextFormField(
                            initialValue: _invoiceItems[index]['price'].toString(),
                            decoration: InputDecoration(labelText: 'Price per Unit'),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              _invoiceItems[index]['price'] = double.tryParse(value) ?? 0.0;
                            },
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _removeItem(index);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                icon: Icon(Icons.add),
                label: Text('Add Item'),
                onPressed: _addItem,
              ),
              SizedBox(height: 20),
              Text('Signature', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Signature(
                controller: _signatureController,
                height: 150,
                backgroundColor: Colors.grey[200]!,
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () => _signatureController.clear(),
                    child: Text('Clear Signature'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        _generatePDFAndPreview();
                      }
                    },
                    child: Text('Save Invoice'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PDFViewerScreen3 extends StatelessWidget {
  final String filePath;

  PDFViewerScreen3({required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice PDF Preview'),
      ),
      body: PDFView(
        filePath: filePath,
      ),
    );
  }
}
