import 'package:flutter/material';
import 'package:provider/provider.dart';
import '../../core/wallet_provider.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});
  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  List<dynamic> _facturesLocal = [];
  bool _isPaying = false;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<WalletProvider>(context, listen: false);
    _facturesLocal = provider.unpaidBills.map((f) => Map<String, dynamic>.from(f)).toList();
  }

  @override
  Widget build(BuildContext context) {
    int totalSelected = _facturesLocal.where((f) => f['checked'] == true).fold(0, (sum, item) => sum + (item['amount'] as int));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(backgroundColor: Colors.white, title: const Text("Paiement de Factures", style: TextStyle(fontWeight: FontWeight.bold))),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _facturesLocal.length,
              itemBuilder: (context, index) {
                final facture = _facturesLocal[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: facture['checked'] ? const Color(0xFF5B259F) : Colors.transparent, width: 1.5)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: CheckboxListTile(
                      activeColor: const Color(0xFF5B259F),
                      title: Text(facture['provider'], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D144A))),
                      subtitle: Text("Facture impayee : ${facture['amount']} F CFA", style: const TextStyle(color: Colors.grey)),
                      value: facture['checked'],
                      onChanged: (bool? value) {
                        setState(() {
                          _facturesLocal[index]['checked'] = value!;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total a regler", style: TextStyle(fontSize: 16, color: Colors.grey)),
                    Text("$totalSelected F CFA", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF5B259F))),
                  ],
                ),
                const SizedBox(height: 20),
                _isPaying
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00D2C4),
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: totalSelected == 0
                            ? null
                            : () async {
                                final selectedIds = _facturesLocal
                                    .where((f) => f['checked'] == true)
                                    .map((f) => f['id'].toString())
                                    .toList();
                                
                                setState(() => _isPaying = true);
                                final success = await Provider.of<WalletProvider>(context, listen: false).payBills(selectedIds);
                                setState(() => _isPaying = false);
                                
                                if (success && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.green, content: Text("Reglement groupe valide !")));
                                  Navigator.pop(context);
                                } else if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.red, content: Text("Erreur lors de la validation du paiement.")));
                                }
                              },
                        child: const Text("Valider le paiement groupe", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
              ],
            ),
          )
        ],
      ),
    );
  }
}