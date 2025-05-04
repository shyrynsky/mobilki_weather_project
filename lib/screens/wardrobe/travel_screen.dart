import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/wardrobe_provider.dart';
import '../../providers/weather_provider.dart';
import '../../models/wardrobe_model.dart';
import '../../widgets/error_handler.dart';

class TravelWardrobeScreen extends StatefulWidget {
  const TravelWardrobeScreen({super.key});

  @override
  State<TravelWardrobeScreen> createState() => _TravelWardrobeScreenState();
}

class _TravelWardrobeScreenState extends State<TravelWardrobeScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _cityController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _cityController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 14)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _addTravelPlan() async {
    if (_cityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите название города')),
      );
      return;
    }

    final wardrobeProvider = Provider.of<WardrobeProvider>(context, listen: false);
    await wardrobeProvider.addCityToTravelPlan(_cityController.text, _selectedDate);
    
    if (wardrobeProvider.error == null) {
      _cityController.clear();
      // Переключаемся на список городов после добавления
      _tabController.animateTo(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Добавить город"),
            Tab(text: "Список для поездки"),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildAddCityTab(),
              _buildPackingListTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddCityTab() {
    final wardrobeProvider = Provider.of<WardrobeProvider>(context);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Планирование путешествия',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          Text(
            'Добавьте города, которые вы планируете посетить:',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _cityController,
            decoration: const InputDecoration(
              labelText: 'Название города',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_city),
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => _selectDate(context),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Дата посещения',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
              child: Text(
                DateFormat('dd.MM.yyyy').format(_selectedDate),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: wardrobeProvider.isLoading ? null : _addTravelPlan,
                child: const Text('Добавить'),
              ),
              OutlinedButton(
                onPressed: wardrobeProvider.isLoading || wardrobeProvider.travelPlans.isEmpty 
                    ? null 
                    : () {
                        wardrobeProvider.clearTravelPlan();
                      },
                child: const Text('Очистить план'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (wardrobeProvider.isLoading)
            const Center(child: CircularProgressIndicator()),
          if (wardrobeProvider.error != null)
            ErrorHandler.buildFullScreenError(
              wardrobeProvider.error!,
              onRetry: () {
                wardrobeProvider.clearError();
              },
            ),
          const SizedBox(height: 24),
          _buildTravelPlanList(),
        ],
      ),
    );
  }

  Widget _buildTravelPlanList() {
    final wardrobeProvider = Provider.of<WardrobeProvider>(context);
    final travelPlans = wardrobeProvider.travelPlans;
    
    if (travelPlans.isEmpty) {
      return const Center(
        child: Text('Добавьте города в план путешествия'),
      );
    }
    
    return Expanded(
      child: ListView.builder(
        itemCount: travelPlans.length,
        itemBuilder: (ctx, i) {
          final plan = travelPlans[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(plan.cityName),
              subtitle: Text(DateFormat('dd.MM.yyyy').format(plan.date)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (plan.recommendation.needUmbrella)
                    const Icon(Icons.umbrella, color: Colors.blue),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => wardrobeProvider.removeCityFromTravelPlan(i),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPackingListTab() {
    final wardrobeProvider = Provider.of<WardrobeProvider>(context);
    final packingList = wardrobeProvider.packingList;
    
    if (wardrobeProvider.travelPlans.isEmpty) {
      return const Center(
        child: Text('Добавьте города в план путешествия'),
      );
    }
    
    if (packingList == null) {
      return const Center(
        child: Text('Не удалось создать список вещей'),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Что взять в путешествие',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Text(
            packingList.recommendation,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Text(
            'Необходимые вещи:',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildItemsList(packingList.essentialItems),
          
          const SizedBox(height: 24),
          Text(
            'Одежда:',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildClothingCountsList(packingList.clothingCounts),
        ],
      ),
    );
  }
  
  Widget _buildItemsList(List<String> items) {
    return Column(
      children: items.map((item) => 
        ListTile(
          leading: const Icon(Icons.check_circle, color: Colors.green),
          title: Text(item),
          dense: true,
          contentPadding: EdgeInsets.zero,
        )
      ).toList(),
    );
  }
  
  Widget _buildClothingCountsList(Map<String, int> clothingCounts) {
    return Column(
      children: clothingCounts.entries.map((entry) => 
        ListTile(
          leading: const Icon(Icons.checkroom, color: Colors.blue),
          title: Text(entry.key),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${entry.value} шт',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          dense: true,
          contentPadding: EdgeInsets.zero,
        )
      ).toList(),
    );
  }
} 