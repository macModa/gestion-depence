import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_list.dart';
import 'add_transaction_screen.dart';
import 'profile_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    TransactionList(), // Accueil : liste transactions
    StatsScreen(),     // Stats
    const AddTransactionScreen(), // Ajouter
    ProfileScreen(),   // Profil
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion de Dépenses'),
        actions: [
          Consumer<TransactionProvider>(
            builder: (context, provider, _) {
              return PopupMenuButton<DateFilter>(
                onSelected: provider.setFilter,
                initialValue: provider.activeFilter,
                icon: const Icon(Icons.filter_list),
                tooltip: 'Filtrer les transactions',
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<DateFilter>>[
                  const PopupMenuItem<DateFilter>(
                    value: DateFilter.thisMonth,
                    child: Text('Ce mois-ci'),
                  ),
                  const PopupMenuItem<DateFilter>(
                    value: DateFilter.last30Days,
                    child: Text('30 derniers jours'),
                  ),
                  const PopupMenuItem<DateFilter>(
                    value: DateFilter.all,
                    child: Text('Toutes'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        // Using `fixed` type ensures all labels are visible, which is good practice
        // for navigation bars with four or more items.
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Ajouter'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}