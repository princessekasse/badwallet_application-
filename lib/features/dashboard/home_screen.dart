import 'package:flutter/material';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/wallet_provider.dart';
import '../transfers/transfer_screen.dart';
import '../bills/bills_screen.dart';
import '../history/history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _obscureBalance = false;
  final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'F CFA', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WalletProvider>(context);

    if (provider.state == WalletState.error) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.red, size: 60),
                const SizedBox(height: 16),
                Text(provider.errorMessage, style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => provider.fetchAllData(provider.currentPhone),
                  child: const Text("Reessayer"),
                )
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Mon Portefeuille", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.grey),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthScreen())),
          )
        ],
      ),
      body: provider.state == WalletState.loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => provider.fetchAllData(provider.currentPhone),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF5B259F), Color(0xFF3F1970)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: const Color(0xFF5B259F).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Solde disponible", style: TextStyle(color: Colors.white70, fontSize: 14)),
                              const SizedBox(height: 8),
                              Text(
                                _obscureBalance ? "••••••••" : currencyFormat.format(double.parse(provider.balance)),
                                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(_obscureBalance ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.white),
                            onPressed: () => setState(() => _obscureBalance = !_obscureBalance),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildActionButton(context, "Transferer", Icons.send_rounded, const Color(0xFF5B259F), const TransferScreen()),
                        _buildActionButton(context, "Payer", Icons.receipt_long_rounded, const Color(0xFF00D2C4), const BillsScreen()),
                        _buildActionButton(context, "Historique", Icons.history_rounded, Colors.blueGrey, const HistoryScreen()),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Operations recentes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D144A))),
                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
                          child: const Text("Voir tout"),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    provider.transactions.isEmpty
                        ? const Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text("Aucune transaction recente")))
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: provider.transactions.take(5).length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final tx = provider.transactions[index];
                              final isNegative = tx['type'] == 'retrait' || tx['type'] == 'transfert_envoye';
                              return Container(
                                decoration: BorderRadius.circular(16),
                                color: Colors.white,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: isNegative ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                                    child: Icon(isNegative ? Icons.arrow_outward_rounded : Icons.call_received_rounded, color: isNegative ? Colors.red : Colors.green),
                                  ),
                                  title: Text(tx['title'] ?? 'Transaction', style: const TextStyle(fontWeight: FontWeight.w600)),
                                  subtitle: Text(tx['date'] ?? 'Aujourd\'hui', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  trailing: Text(
                                    "${isNegative ? '-' : '+'}${tx['amount']} F",
                                    style: TextStyle(color: isNegative ? Colors.red : Colors.green, fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                ),
                              );
                            },
                          )
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildActionButton(BuildContext context, String title, IconData icon, Color color, Widget screen) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.26,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Column(
          children: [
            CircleAvatar(radius: 24, backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2D144A)))
          ],
        ),
      ),
    );
  }
}