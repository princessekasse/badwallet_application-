import 'package:flutter/material';
import 'package:provider/provider.dart';
import '../../core/wallet_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WalletProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(backgroundColor: Colors.white, title: const Text("Historique des Operations", style: TextStyle(fontWeight: FontWeight.bold))),
      body: provider.transactions.isEmpty
          ? const Center(child: Text("Aucune transaction enregistree."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.transactions.length,
              itemBuilder: (context, index) {
                final tx = provider.transactions[index];
                final isNegative = tx['type'] == 'retrait' || tx['type'] == 'transfert_envoye';
                
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isNegative ? Colors.red.withOpacity(0.08) : Colors.green.withOpacity(0.08),
                      child: Icon(
                        isNegative ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                        color: isNegative ? Colors.red.shade700 : Colors.green.shade700,
                      ),
                    ),
                    title: Text(tx['title'] ?? 'Transaction', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(tx['date'] ?? 'Date inconnue', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    trailing: Text(
                      "${isNegative ? '-' : '+'}${tx['amount']} XOF",
                      style: TextStyle(
                        color: isNegative ? Colors.red.shade700 : Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}