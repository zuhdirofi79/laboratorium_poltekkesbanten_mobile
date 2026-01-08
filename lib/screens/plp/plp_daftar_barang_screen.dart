import 'package:flutter/material.dart';
import '../../models/item_model.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/search_bar_widget.dart';

class PLPDaftarBarangScreen extends StatefulWidget {
  const PLPDaftarBarangScreen({super.key});

  @override
  State<PLPDaftarBarangScreen> createState() => _PLPDaftarBarangScreenState();
}

class _PLPDaftarBarangScreenState extends State<PLPDaftarBarangScreen> {
  final ApiService _apiService = ApiService();
  List<ItemModel> _items = [];
  List<ItemModel> _filteredItems = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final items = await _apiService.getDaftarBarang(search: _searchQuery.isNotEmpty ? _searchQuery : null);
      setState(() {
        _items = items;
        _filteredItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _filterItems(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredItems = _items;
      } else {
        _filteredItems = _items.where((item) {
          return item.namaBarang.toLowerCase().contains(query.toLowerCase()) ||
              item.kategori.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SearchBarWidget(
            onSearch: _filterItems,
            hintText: 'Cari barang...',
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredItems.isEmpty
                  ? const Center(child: Text('Tidak ada data'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: const Icon(Icons.inventory_2, color: AppTheme.primaryColor),
                            title: Text(item.namaBarang),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Kategori: ${item.kategori}'),
                                if (item.merk != null) Text('Merk: ${item.merk}'),
                                Text('Jumlah: ${item.jumlah}'),
                                Text('Kondisi: ${item.kondisi}'),
                              ],
                            ),
                            trailing: Icon(
                              item.kondisi.toLowerCase() == 'baik'
                                  ? Icons.check_circle
                                  : Icons.warning,
                              color: item.kondisi.toLowerCase() == 'baik'
                                  ? AppTheme.successColor
                                  : AppTheme.warningColor,
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}