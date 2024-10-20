import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart'; // Import the share_plus package
import 'package:flutter_application_1/screens/create_invoice.dart';
import 'package:flutter_application_1/screens/pdf_view.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // To keep track of BottomAppBar navigation

  final List<Map<String, dynamic>> invoices = [
    {
      'invoiceNumber': 'INV-001',
      'customerName': 'John Doe',
      'date': '2024-10-19',
      'totalAmount': 250.0,
      'pdfUrl': 'https://slicedinvoices.com/pdf/wordpress-pdf-invoice-plugin-sample.pdf',
    },
    {
      'invoiceNumber': 'INV-002',
      'customerName': 'Jane Smith',
      'date': '2024-10-18',
      'totalAmount': 300.5,
      'pdfUrl': 'https://slicedinvoices.com/pdf/wordpress-pdf-invoice-plugin-sample.pdf',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoices'),
        backgroundColor: Colors.purple, // Purple theme for the AppBar
      ),
      body: _selectedIndex == 0 ? _buildInvoiceList() : CompanyDetailsScreen(), // Switch between Invoice list and Company Details
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to Create Invoice Screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateInvoiceScreen()),
          );
        },
        backgroundColor: Colors.purple,
        child: Icon(Icons.add),
        tooltip: 'Create Invoice',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.purple,
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          backgroundColor: Colors.transparent,
          elevation: 0, // Remove bottom bar elevation to blend with the BottomAppBar
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white60,
          showSelectedLabels: true,
          showUnselectedLabels: false,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Invoices',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.business),
              label: 'Company',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceList() {
    return invoices.isEmpty
        ? Center(
            child: Text('No Invoices Found'),
          )
        : ListView.builder(
            itemCount: invoices.length,
            itemBuilder: (context, index) {
              final invoice = invoices[index];
              return Card(
                elevation: 4.0,
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  title: Text(invoice['invoiceNumber']),
                  subtitle: Text('${invoice['customerName']} - ${invoice['date']}'),
                  trailing: Text('\$${invoice['totalAmount'].toString()}'),
                  onTap: () {
                    print('View/Download Invoice PDF: ${invoice['invoiceNumber']}');
                  },
                  leading: PopupMenuButton<String>(
                    onSelected: (String value) {
                      if (value == 'view') {
                        // Navigate to PDF Viewer when 'View' is selected
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PDFViewerScreen(
                              pdfUrl: invoice['pdfUrl'],
                            ),
                          ),
                        );
                      } else if (value == 'share') {
                        // Implement the share function using Share Plus
                        Share.share(
                          'Here is the invoice for ${invoice['customerName']}:\n${invoice['pdfUrl']}',
                          subject: 'Invoice ${invoice['invoiceNumber']}',
                        );
                      } else if (value == 'delete') {
                        // Logic to delete the invoice
                        print('Deleting ${invoice['invoiceNumber']}');
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Delete Invoice'),
                              content: Text('Are you sure you want to delete this invoice?'),
                              actions: [
                                TextButton(
                                  child: Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text('Delete'),
                                  onPressed: () {
                                    print('Invoice deleted');
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'view',
                        child: Text('View PDF'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'share',
                        child: Text('Share Invoice'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Delete Invoice'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }
}

// Company Details Screen Placeholder (Add your company details content here)
class CompanyDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Company Details',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
