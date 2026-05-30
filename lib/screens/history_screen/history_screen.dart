import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../utils/calculation_history.dart';
import '../../utils/utils.dart';

class CalculationHistory extends StatefulWidget {
  const CalculationHistory({super.key});

  @override
  State<CalculationHistory> createState() => _CalculationHistoryState();
}

class _CalculationHistoryState extends State<CalculationHistory> {
  late Future<List<CalculationHistoryEntry>> _entriesFuture;

  // Human-readable labels for the stable calculator-type identifiers.
  static const Map<String, String> _typeLabels = {
    'monthlySIP': 'Monthly SIP',
    'lumpsumSIP': 'Lumpsum SIP',
    'targetSIP': 'Target SIP',
    'emi': 'EMI',
    'stepUpSIP': 'Step-Up SIP',
    'swp': 'SWP',
  };

  // The headline output key per calculator type.
  static const Map<String, String> _headlineKey = {
    'monthlySIP': 'maturity',
    'lumpsumSIP': 'maturity',
    'targetSIP': 'requiredMonthly',
    'emi': 'emi',
    'stepUpSIP': 'maturity',
    'swp': 'remainingCorpus',
  };

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _entriesFuture = CalculationHistoryStore.instance.load();
  }

  Future<void> _delete(CalculationHistoryEntry entry) async {
    await CalculationHistoryStore.instance.delete(entry.id);
    setState(_reload);
  }

  Future<void> _clearAll() async {
    await CalculationHistoryStore.instance.clear();
    setState(_reload);
  }

  String _formatHeadline(CalculationHistoryEntry entry) {
    final key = _headlineKey[entry.calculatorType];
    final value = key != null ? entry.result[key] : null;
    if (value == null) return '—';
    return Utils().formatNumbersInt(number: value);
  }

  String _formatInputs(CalculationHistoryEntry entry) {
    final parts = <String>[];
    entry.inputs.forEach((key, value) {
      final display =
          value == value.roundToDouble() ? value.toInt().toString() : '$value';
      parts.add('$key: $display');
    });
    return parts.join('  •  ');
  }

  String _formatTimestamp(DateTime timestamp) {
    return DateFormat.yMMMd().add_jm().format(timestamp.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            tooltip: 'Clear all',
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () => _confirmClearAll(context),
          ),
        ],
      ),
      body: FutureBuilder<List<CalculationHistoryEntry>>(
        future: _entriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final entries = snapshot.data ?? const [];
          if (entries.isEmpty) {
            return _buildEmptyState();
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final entry = entries[index];
              return Dismissible(
                key: ValueKey(entry.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  color: Colors.red.shade400,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => _delete(entry),
                child: ListTile(
                  title: Text(
                    _typeLabels[entry.calculatorType] ?? entry.calculatorType,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(_formatInputs(entry)),
                      const SizedBox(height: 2),
                      Text(
                        _formatTimestamp(entry.timestamp),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  trailing: Text(
                    _formatHeadline(entry),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No calculations yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Calculations you run will appear here so you can revisit them.',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClearAll(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all history?'),
        content: const Text('This removes every saved calculation.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear all'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _clearAll();
    }
  }
}
