import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:zorvyn/config/theme.dart';
import 'package:zorvyn/models/transaction_model.dart';
import 'package:zorvyn/providers/transaction_provider.dart';
import 'package:zorvyn/widgets/common_widgets.dart';

class TransactionCalendarScreen extends ConsumerStatefulWidget {
  const TransactionCalendarScreen({super.key});

  @override
  ConsumerState<TransactionCalendarScreen> createState() =>
      _TransactionCalendarScreenState();
}

class _TransactionCalendarScreenState
    extends ConsumerState<TransactionCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(transactionNotifierProvider.notifier).loadTransactions(limit: 200);
    });
  }

  Map<DateTime, List<Transaction>> _groupByDate(List<Transaction> txns) {
    final map = <DateTime, List<Transaction>>{};
    for (final tx in txns) {
      if (tx.date == null) continue;
      final d = DateTime.tryParse(tx.date!);
      if (d == null) continue;
      final key = DateTime(d.year, d.month, d.day);
      map.putIfAbsent(key, () => []).add(tx);
    }
    return map;
  }

  List<Transaction> _getEventsForDay(
      DateTime day, Map<DateTime, List<Transaction>> grouped) {
    return grouped[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionNotifierProvider);
    final grouped = _groupByDate(state.transactions);
    final selectedTxns = _getEventsForDay(_selectedDay, grouped);

    // Totals for selected day
    double dayIncome = 0, dayExpense = 0;
    for (final tx in selectedTxns) {
      if (tx.isIncome) {
        dayIncome += tx.amount;
      } else {
        dayExpense += tx.amount;
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.bgC(context),
      appBar: AppBar(title: const Text('Transaction Calendar')),
      body: state.isLoading
          ? Center(child: SkeletonCard(height: 300))
          : Column(
              children: [
                // Calendar widget
                ClayCard(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: TableCalendar<Transaction>(
                    firstDay: DateTime.now().subtract(const Duration(days: 365)),
                    lastDay: DateTime.now().add(const Duration(days: 30)),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selected, focused) {
                      setState(() {
                        _selectedDay = selected;
                        _focusedDay = focused;
                      });
                    },
                    onFormatChanged: (format) {
                      setState(() => _calendarFormat = format);
                    },
                    onPageChanged: (focused) => _focusedDay = focused,
                    eventLoader: (day) => _getEventsForDay(day, grouped),
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      todayDecoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: const BoxDecoration(
                        color: AppTheme.accent,
                        shape: BoxShape.circle,
                      ),
                      markerSize: 6,
                      markersMaxCount: 3,
                      defaultTextStyle:
                          TextStyle(color: AppTheme.textPrimaryC(context)),
                      weekendTextStyle:
                          TextStyle(color: AppTheme.textSecondaryC(context)),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: true,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimaryC(context)),
                      leftChevronIcon: Icon(CupertinoIcons.chevron_left,
                          size: 18, color: AppTheme.textSecondaryC(context)),
                      rightChevronIcon: Icon(CupertinoIcons.chevron_right,
                          size: 18, color: AppTheme.textSecondaryC(context)),
                      formatButtonTextStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary),
                      formatButtonDecoration: BoxDecoration(
                        border: Border.fromBorderSide(
                            BorderSide(color: AppTheme.primary)),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle:
                          TextStyle(fontSize: 12, color: AppTheme.textHintC(context)),
                      weekendStyle:
                          TextStyle(fontSize: 12, color: AppTheme.textHintC(context)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Day summary
                if (selectedTxns.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: ClayCard(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                Text(DateFormat('MMM dd').format(_selectedDay),
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textHintC(context))),
                                const SizedBox(height: 4),
                                Text('+${formatAmount(dayIncome)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.success)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClayCard(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                Text('Spent',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textHintC(context))),
                                const SizedBox(height: 4),
                                Text('-${formatAmount(dayExpense)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.accent)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClayCard(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                Text('Net',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textHintC(context))),
                                const SizedBox(height: 4),
                                Text(
                                    formatAmount(dayIncome - dayExpense),
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: (dayIncome - dayExpense) >= 0
                                            ? AppTheme.success
                                            : AppTheme.accent)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),

                // Transactions for selected day
                Expanded(
                  child: selectedTxns.isEmpty
                      ? Center(
                          child: Text(
                            'No transactions on ${DateFormat('MMM dd, yyyy').format(_selectedDay)}',
                            style: TextStyle(
                                color: AppTheme.textHintC(context), fontSize: 14),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: selectedTxns.length,
                          itemBuilder: (context, index) {
                            final tx = selectedTxns[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: ClayCard(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                onTap: () =>
                                    context.push('/transactions/${tx.id}'),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: getCategoryColor(tx.category)
                                            .withValues(alpha: 0.12),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                          getCategoryIcon(tx.category),
                                          size: 18,
                                          color:
                                              getCategoryColor(tx.category)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tx.category.isEmpty
                                                ? 'Uncategorized'
                                                : tx.category[0].toUpperCase() +
                                                    tx.category
                                                        .substring(1)
                                                        .replaceAll('_', ' '),
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color:
                                                    AppTheme.textPrimaryC(context)),
                                          ),
                                          if (tx.description != null &&
                                              tx.description!.isNotEmpty)
                                            Text(tx.description!,
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        AppTheme.textHintC(context))),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${tx.isIncome ? '+' : '-'}${formatAmount(tx.amount)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: tx.isIncome
                                            ? AppTheme.success
                                            : AppTheme.accent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
