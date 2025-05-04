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
  late TabController _tabController;
  
  // Режим выбора диапазона дат
  bool _isRangeDateMode = false;
  
  // Даты начала и конца диапазона
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));

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

  // Выбор начальной даты диапазона
  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    
    if (picked != null) {
      setState(() {
        _startDate = picked;
        
        // Если конечная дата раньше начальной, корректируем конечную дату
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate;
        }
      });
    }
  }
  
  // Выбор конечной даты диапазона
  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate.isAfter(_startDate) ? _endDate : _startDate,
      firstDate: _startDate, // Конечная дата не может быть раньше начальной
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }
  
  // Получение списка дат в диапазоне
  List<DateTime> _getDatesInRange() {
    List<DateTime> dates = [];
    
    // Если не режим диапазона, возвращаем только начальную дату
    if (!_isRangeDateMode) {
      // Создаем копию даты с только необходимыми полями (без времени)
      return [DateTime(_startDate.year, _startDate.month, _startDate.day)];
    }
    
    // Генерируем все даты в диапазоне
    DateTime current = DateTime(_startDate.year, _startDate.month, _startDate.day);
    final end = DateTime(_endDate.year, _endDate.month, _endDate.day);
    
    // Убедимся, что даты идут в правильном порядке
    if (current.isAfter(end)) {
      return [current]; // Если что-то не так, возвращаем только начальную дату
    }
    
    // Добавляем все даты в диапазоне
    while (!current.isAfter(end)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }
    
    return dates;
  }

  // Добавление плана путешествия для диапазона дат
  void _addTravelPlan() async {
    if (_cityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите название города')),
      );
      return;
    }

    final wardrobeProvider = Provider.of<WardrobeProvider>(context, listen: false);
    
    // Получаем все даты в выбранном диапазоне
    final datesInRange = _getDatesInRange();
    
    // Проверяем, что у нас есть хотя бы одна дата
    if (datesInRange.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите хотя бы одну дату')),
      );
      return;
    }
    
    // Показываем индикатор загрузки и сохраняем текущий режим для сброса после завершения
    bool wasRangeMode = _isRangeDateMode;
    setState(() => _isRangeDateMode = false);
    
    if (datesInRange.length == 1) {
      // Если это одиночная дата, используем простой метод
      await wardrobeProvider.addCityToTravelPlan(_cityController.text, datesInRange[0]);
    } else {
      // Иначе используем оптимизированный метод для диапазона
      await wardrobeProvider.addCityToTravelPlanForDateRange(_cityController.text, datesInRange);
    }
    
    if (wardrobeProvider.error == null) {
      _cityController.clear();
      // Сбрасываем к начальному состоянию
      setState(() {
        _startDate = DateTime.now().add(const Duration(days: 1));
        _endDate = DateTime.now().add(const Duration(days: 1));
        _isRangeDateMode = false; // Всегда сбрасываем режим диапазона после успешного добавления
      });
      
      // Переключаемся на список городов после добавления
      _tabController.animateTo(1);
    } else {
      // В случае ошибки восстанавливаем предыдущий режим
      setState(() {
        _isRangeDateMode = wasRangeMode;
      });
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
    
    // Вычисляем количество дней в диапазоне
    final datesInRange = _getDatesInRange();
    final int daysCount = datesInRange.length;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Планирование путешествия',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
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
          
          // Переключатель режима выбора дат
          Row(
            children: [
              Checkbox(
                value: _isRangeDateMode,
                onChanged: (value) {
                  setState(() {
                    _isRangeDateMode = value ?? false;
                  });
                },
              ),
              const Text('Выбрать диапазон дат'),
            ],
          ),
          
          // Показываем либо одну дату, либо диапазон дат
          if (!_isRangeDateMode) ...[
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectStartDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Дата посещения',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('dd.MM.yyyy').format(_startDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Добавление города на один день',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectStartDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'С даты',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        DateFormat('dd.MM.yyyy').format(_startDate),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectEndDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'По дату',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        DateFormat('dd.MM.yyyy').format(_endDate),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Показываем количество дней и список дат
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Выбрано дней: $daysCount',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (daysCount > 3) 
                    Text(
                      'Даты: ${DateFormat('dd.MM').format(_startDate)} - ${DateFormat('dd.MM').format(_endDate)}',
                    )
                  else
                    Text(
                      'Даты: ${datesInRange.map((d) => DateFormat('dd.MM').format(d)).join(', ')}',
                    ),
                ],
              ),
            ),
          ],
          
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
          const SizedBox(height: 16),
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
    
    // Группируем планы по городам
    final Map<String, List<TravelPlan>> groupedPlans = {};
    for (var plan in travelPlans) {
      if (!groupedPlans.containsKey(plan.cityName)) {
        groupedPlans[plan.cityName] = [];
      }
      groupedPlans[plan.cityName]!.add(plan);
    }
    
    return Expanded(
      child: ListView.builder(
        itemCount: groupedPlans.length,
        itemBuilder: (ctx, i) {
          final cityName = groupedPlans.keys.elementAt(i);
          final cityPlans = groupedPlans[cityName]!;
          
          // Сортируем планы по дате
          cityPlans.sort((a, b) => a.date.compareTo(b.date));
          
          // Проверяем, являются ли даты последовательными (непрерывный диапазон)
          bool isConsecutive = true;
          for (int j = 0; j < cityPlans.length - 1; j++) {
            final difference = cityPlans[j + 1].date.difference(cityPlans[j].date).inDays;
            if (difference != 1) {
              isConsecutive = false;
              break;
            }
          }
          
          // Формируем подзаголовок в зависимости от непрерывности диапазона
          String subtitleText;
          if (isConsecutive && cityPlans.length > 1) {
            subtitleText = '${cityPlans.length} дней: ${DateFormat('dd.MM').format(cityPlans.first.date)} - ${DateFormat('dd.MM').format(cityPlans.last.date)}';
          } else {
            subtitleText = '${cityPlans.length} дней: ${cityPlans.map((p) => DateFormat('dd.MM').format(p.date)).join(', ')}';
          }
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              title: Text(cityName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(subtitleText),
              children: cityPlans.map((plan) => 
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  title: Text(DateFormat('dd.MM.yyyy').format(plan.date)),
                  subtitle: Text('${plan.recommendation.clothingType.toUpperCase()}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (plan.recommendation.needUmbrella)
                        const Icon(Icons.umbrella, color: Colors.blue),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => wardrobeProvider.removeCityFromTravelPlan(
                          travelPlans.indexOf(plan)
                        ),
                      ),
                    ],
                  ),
                )
              ).toList(),
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