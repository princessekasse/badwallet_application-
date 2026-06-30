import 'package:flutter/material';
import 'package:provider/provider.dart';
import '../../core/wallet_provider.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});
  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(backgroundColor: Colors.white, title: const Text("Transferer de l'argent", style: TextStyle(fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Beneficiaire", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D144A))),
              const SizedBox(height: 12),
              TextFormField(
                controller: _recipientController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Numero de telephone du destinataire",
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) => value!.isEmpty ? "Champ obligatoire" : null,
              ),
              const SizedBox(height: 24),
              const Text("Montant de la transaction", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D144A))),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF5B259F)),
                decoration: InputDecoration(
                  suffixText: "XOF",
                  suffixStyle: const TextStyle(fontSize: 18, color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) => value!.isEmpty ? "Veuillez entrer un montant" : null,
              ),
              const SizedBox(height: 40),
              _isProcessing
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () => _showConfirmationDialog(context),
                      child: const Text("Suivant", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    )
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 50),
                const SizedBox(height: 16),
                const Text("Confirmer le transfert", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Destinataire :"), Text(_recipientController.text, style: const TextStyle(fontWeight: FontWeight.bold))]),
                const Divider(height: 24),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Montant :"), Text("${_amountController.text} XOF", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5B259F)))]),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5B259F), foregroundColor: Colors.white, minimumSize: const Size.fromHeight(50)),
                  onPressed: () async {
                    Navigator.pop(context);
                    setState(() => _isProcessing = true);
                    final success = await Provider.of<WalletProvider>(context, listen: false).makeTransfer(
                      _recipientController.text,
                      double.parse(_amountController.text),
                    );
                    setState(() => _isProcessing = false);
                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.green, content: Text("Transfert realise avec succes !")));
                      Navigator.pop(context);
                    } else if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.red, content: Text("Solde insuffisant ou erreur reseau.")));
                    }
                  },
                  child: const Text("Confirmer l'operation"),
                )
              ],
            ),
          );
        },
      );
    }
  }
}