import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MilPayCalculatorApp());
}

// =============================================================
// АВТОНОМНОЕ СОХРАНЕНИЕ БЕЗ СТОРОННИХ ПЛАГИНОВ (JSON файл)
// =============================================================
class StorageService {
  static Map<String, dynamic> _data = {};
  static bool _initialized = false;

  static Future<File?> _getFile() async {
    try {
      final dir = Directory('/data/user/0/ru.milpay/app_flutter');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return File('${dir.path}/app_settings.json');
    } catch (_) {
      try {
        final fallbackDir = Directory('/data/data/ru.milpay/files');
        if (!await fallbackDir.exists()) {
          await fallbackDir.create(recursive: true);
        }
        return File('${fallbackDir.path}/app_settings.json');
      } catch (_) {
        return null;
      }
    }
  }

  static Future<void> init() async {
    if (_initialized) return;
    try {
      final file = await _getFile();
      if (file != null && await file.exists()) {
        final content = await file.readAsString();
        _data = jsonDecode(content) as Map<String, dynamic>;
      }
    } catch (_) {}
    _initialized = true;
  }

  static dynamic get(String key, [dynamic defaultValue]) {
    return _data.containsKey(key) ? _data[key] : defaultValue;
  }

  static Future<void> set(String key, dynamic value) async {
    _data[key] = value;
    try {
      final file = await _getFile();
      if (file != null) {
        await file.writeAsString(jsonEncode(_data));
      }
    } catch (_) {}
  }

  static Future<void> clearPrefix(String prefix) async {
    _data.removeWhere((key, _) => key.startsWith(prefix));
    try {
      final file = await _getFile();
      if (file != null) {
        await file.writeAsString(jsonEncode(_data));
      }
    } catch (_) {}
  }
}

// =============================================================
// ОБЩИЕ СПРАВОЧНИКИ (Все звания и 50 тарифных разрядов)
// =============================================================
final Map<String, double> militaryRanks = {
  'Не выбрано': 0.0,
  'Рядовой, матрос': 7166.0,
  'Ефрейтор, старший матрос': 7881.0,
  'Младший сержант, старшина 2 статьи': 8601.0,
  'Сержант, старшина 1 статьи': 9315.0,
  'Старший сержант, главный старшина': 10032.0,
  'Старшина, главный корабельный старшина': 10750.0,
  'Прапорщик, мичман': 11464.0,
  'Старший прапорщик, старший мичман': 12181.0,
  'Младший лейтенант': 13614.0,
  'Лейтенант': 14331.0,
  'Старший лейтенант': 15046.0,
  'Капитан, капитан-лейтенант': 15761.0,
  'Майор, капитан 3-го ранга': 16481.0,
  'Подполковник, капитан 2-го ранга': 17196.0,
  'Полковник, капитан 1-го ранга': 18629.0,
  'Генерал-майор, контр-адмирал': 28655.0,
  'Генерал-лейтенант, вице-адмирал': 32954.0,
  'Генерал-полковник, адмирал': 35819.0,
  'Генерал армии, адмирал флота': 38684.0,
  'Маршал Российской Федерации': 42983.0,
};

final Map<String, double> militaryTariffRanks = {
  'Не выбрано': 0.0,
  '1 т.р.': 14331.0,
  '2 т.р.': 15761.0,
  '3 т.р.': 17196.0,
  '4 т.р.': 18629.0,
  '5 т.р.': 21494.0,
  '6 т.р.': 22929.0,
  '7 т.р.': 24359.0,
  '8 т.р.': 25794.0,
  '9 т.р.': 27226.0,
  '10 т.р.': 28656.0,
  '11 т.р.': 29374.0,
  '12 т.р.': 30090.0,
  '13 т.р.': 30806.0,
  '14 т.р.': 31521.0,
  '15 т.р.': 32237.0,
  '16 т.р.': 32954.0,
  '17 т.р.': 33671.0,
  '18 т.р.': 34388.0,
  '19 т.р.': 35103.0,
  '20 т.р.': 35819.0,
  '21 т.р.': 36536.0,
  '22 т.р.': 37252.0,
  '23 т.р.': 37968.0,
  '24 т.р.': 38684.0,
  '25 т.р.': 39400.0,
  '26 т.р.': 40117.0,
  '27 т.р.': 41072.0,
  '28 т.р.': 42028.0,
  '29 т.р.': 42983.0,
  '30 т.р.': 44416.0,
  '31 т.р.': 45849.0,
  '32 т.р.': 47282.0,
  '33 т.р.': 48715.0,
  '34 т.р.': 50149.0,
  '35 т.р.': 51582.0,
  '36 т.р.': 52300.0,
  '37 т.р.': 53015.0,
  '38 т.р.': 53732.0,
  '39 т.р.': 54448.0,
  '40 т.р.': 55165.0,
  '41 т.р.': 55881.0,
  '42 т.р.': 56597.0,
  '43 т.р.': 57314.0,
  '44 т.р.': 58031.0,
  '45 т.р.': 58747.0,
  '46 т.р.': 59463.0,
  '47 т.р.': 60179.0,
  '48 т.р.': 60896.0,
  '49 т.р.': 63039.0,
  '50 т.р.': 64473.0,
};

class MilPayCalculatorApp extends StatefulWidget {
  const MilPayCalculatorApp({super.key});

  @override
  State<MilPayCalculatorApp> createState() => _MilPayCalculatorAppState();
}

class _MilPayCalculatorAppState extends State<MilPayCalculatorApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    await StorageService.init();
    final isDark = StorageService.get('app_is_dark');
    if (isDark != null) {
      setState(() {
        _themeMode = (isDark as bool) ? ThemeMode.dark : ThemeMode.light;
      });
    }
  }

  Future<void> _toggleTheme() async {
    final nextMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setState(() => _themeMode = nextMode);
    await StorageService.set('app_is_dark', nextMode == ThemeMode.dark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Калькулятор ДД',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF3F51B5),
        scaffoldBackgroundColor: const Color(0xFFF2F4F7),
        cardColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF3949AB),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Color(0xFF3949AB),
          unselectedItemColor: Colors.grey,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF5C6BC0),
        scaffoldBackgroundColor: const Color(0xFF121824),
        cardColor: const Color(0xFF1E2638),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A233A),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1A233A),
          selectedItemColor: Color(0xFF82B1FF),
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: MainNavigationHolder(
        onToggleTheme: _toggleTheme,
        isDarkMode: _themeMode == ThemeMode.dark,
      ),
    );
  }
}

class MainNavigationHolder extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const MainNavigationHolder({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<MainNavigationHolder> createState() => _MainNavigationHolderState();
}

class _MainNavigationHolderState extends State<MainNavigationHolder> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadTab();
  }

  Future<void> _loadTab() async {
    await StorageService.init();
    setState(() {
      _currentIndex = (StorageService.get('app_tab_index', 0) as num).toInt();
    });
  }

  Future<void> _setTab(int index) async {
    HapticFeedback.mediumImpact();
    setState(() => _currentIndex = index);
    await StorageService.set('app_tab_index', index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          SalaryCalculatorScreen(
            onToggleTheme: widget.onToggleTheme,
            isDarkMode: widget.isDarkMode,
          ),
          PensionCalculatorScreen(
            onToggleTheme: widget.onToggleTheme,
            isDarkMode: widget.isDarkMode,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _setTab,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Денежное довольствие',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance),
            label: 'Военная пенсия',
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// ЭКРАН 1: КАЛЬКУЛЯТОР ДЕНЕЖНОГО ДОВОЛЬСТВИЯ
// -------------------------------------------------------------
class SalaryCalculatorScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const SalaryCalculatorScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<SalaryCalculatorScreen> createState() => _SalaryCalculatorScreenState();
}

class _SalaryCalculatorScreenState extends State<SalaryCalculatorScreen> {
  void _playClickFeedback() {
    HapticFeedback.mediumImpact();
  }

  final Map<String, double> salaryPeriods = {
    'Оклады с 01.10.2025 г.': 1.0,
    'Оклады с 01.10.2026 г.': 1.0,
  };
  String selectedPeriod = 'Оклады с 01.10.2025 г.';

  String selectedRank = 'Не выбрано';
  String selectedTariff = 'Не выбрано';
  String selectedFlight = 'нет';
  String selectedNvl = 'до 2 лет – 0%';
  String selectedSecrecy = 'нет - 0%';
  String selectedOuvs = '0%';
  String selectedClass = 'без класса - 0%';

  double combatDutyPercent = 0.0;
  double selectedDistrictVal = 1.0;
  double selectedNorthernVal = 0.0;

  String selectedPremium = '0%';
  String selectedSpecialUnits = 'нет (0%)';
  String selectedOtherAchievements = '0%';

  bool hasContractBonus = false;
  bool isDriver = false;
  bool hasMatHelp = false;
  bool isVbd = false;

  String selectedMedals = 'нет надбавки - 0%';
  String selectedZgt = '0%';
  String selectedCipher = '0%';
  String selectedAlimony = '0%';
  String selectedChildDeduction = 'нет детей';

  final TextEditingController _days844Controller = TextEditingController();
  final TextEditingController _riskDaysController = TextEditingController();

  int days844 = 0;
  int riskDays = 0;

  final List<double> districtOptions = [
    1.0, 1.15, 1.2, 1.25, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 2.0
  ];

  final List<Map<String, dynamic>> northernOptions = [
    {'val': 0.0, 'label': '0 %'},
    {'val': 0.10, 'label': '10 %'},
    {'val': 0.20, 'label': '20 %'},
    {'val': 0.30, 'label': '30 % - IV группа территорий'},
    {'val': 0.40, 'label': '40 %'},
    {'val': 0.50, 'label': '50 % - III группа территорий'},
    {'val': 0.60, 'label': '60 %'},
    {'val': 0.70, 'label': '70 %'},
    {'val': 0.80, 'label': '80 % - II группа территорий'},
    {'val': 0.90, 'label': '90 %'},
    {'val': 1.00, 'label': '100 % - I группа территорий'},
  ];

  // Варианты ОУС кратно 5% до 100%
  final List<String> ouvsOptions = List.generate(21, (i) => '${i * 5}%');

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    await StorageService.init();
    setState(() {
      selectedPeriod = StorageService.get('dd_period', 'Оклады с 01.10.2025 г.');
      selectedRank = StorageService.get('dd_rank', 'Не выбрано');
      selectedTariff = StorageService.get('dd_tariff', 'Не выбрано');
      selectedFlight = StorageService.get('dd_flight', 'нет');
      selectedNvl = StorageService.get('dd_nvl', 'до 2 лет – 0%');
      selectedSecrecy = StorageService.get('dd_secrecy', 'нет - 0%');
      selectedOuvs = StorageService.get('dd_ouvs', '0%');
      selectedClass = StorageService.get('dd_class', 'без класса - 0%');
      combatDutyPercent = (StorageService.get('dd_combat_duty', 0.0) as num).toDouble();
      selectedDistrictVal = (StorageService.get('dd_district', 1.0) as num).toDouble();
      selectedNorthernVal = (StorageService.get('dd_northern', 0.0) as num).toDouble();
      selectedPremium = StorageService.get('dd_premium', '0%');
      selectedSpecialUnits = StorageService.get('dd_special_units', 'нет (0%)');
      selectedOtherAchievements = StorageService.get('dd_achievements', '0%');
      hasContractBonus = StorageService.get('dd_contract_bonus', false) as bool;
      isDriver = StorageService.get('dd_driver', false) as bool;
      hasMatHelp = StorageService.get('dd_mat_help', false) as bool;
      isVbd = StorageService.get('dd_vbd', false) as bool;
      selectedMedals = StorageService.get('dd_medals', 'нет надбавки - 0%');
      selectedZgt = StorageService.get('dd_zgt', '0%');
      selectedCipher = StorageService.get('dd_cipher', '0%');
      selectedAlimony = StorageService.get('dd_alimony', '0%');
      selectedChildDeduction = StorageService.get('dd_child', 'нет детей');
      days844 = (StorageService.get('dd_days844', 0) as num).toInt();
      riskDays = (StorageService.get('dd_risk_days', 0) as num).toInt();

      if (days844 > 0) _days844Controller.text = days844.toString();
      if (riskDays > 0) _riskDaysController.text = riskDays.toString();
    });
  }

  @override
  void dispose() {
    _days844Controller.dispose();
    _riskDaysController.dispose();
    super.dispose();
  }

  Future<void> _resetAllFields() async {
    _playClickFeedback();
    setState(() {
      selectedPeriod = 'Оклады с 01.10.2025 г.';
      selectedRank = 'Не выбрано';
      selectedTariff = 'Не выбрано';
      selectedFlight = 'нет';
      selectedNvl = 'до 2 лет – 0%';
      selectedSecrecy = 'нет - 0%';
      selectedOuvs = '0%';
      selectedClass = 'без класса - 0%';
      combatDutyPercent = 0.0;
      selectedDistrictVal = 1.0;
      selectedNorthernVal = 0.0;
      selectedPremium = '0%';
      selectedSpecialUnits = 'нет (0%)';
      selectedOtherAchievements = '0%';
      hasContractBonus = false;
      isDriver = false;
      hasMatHelp = false;
      isVbd = false;
      selectedMedals = 'нет надбавки - 0%';
      selectedZgt = '0%';
      selectedCipher = '0%';
      selectedAlimony = '0%';
      selectedChildDeduction = 'нет детей';
      days844 = 0;
      riskDays = 0;
      _days844Controller.clear();
      _riskDaysController.clear();
    });

    await StorageService.clearPrefix('dd_');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Все поля сброшены в исходное состояние'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  String _generateCalculationSummary({
    required double ovz,
    required double ovd,
    required double ods,
    required double nvlAmount,
    required double secrecyAmount,
    required double ouvsAmount,
    required double classAmount,
    required double flightAmount,
    required double combatDutyAmount,
    required double rkAmount,
    required double northernAmount,
    required double premiumAmount,
    required double specialUnitsAmount,
    required double otherAchievementsAmount,
    required double contractAmount,
    required double driverAmount,
    required double zgtAmount,
    required double cipherAmount,
    required double medalsAmount,
    required double matHelpAmount,
    required double comp844Amount,
    required double riskAmount,
    required double totalGross,
    required double ndfl,
    required double alimonyAmount,
    required double totalHold,
    required double netPay,
  }) {
    StringBuffer sb = StringBuffer();
    sb.writeln('📋 РАСЧЕТ ДЕНЕЖНОГО ДОВОЛЬСТВИЯ');
    sb.writeln('Период: $selectedPeriod');
    sb.writeln('--------------------------------');
    sb.writeln('• Воинское звание: $selectedRank (${ovz.toStringAsFixed(0)} руб.)');
    sb.writeln('• Тарифный разряд: $selectedTariff (${ovd.toStringAsFixed(0)} руб.)');
    sb.writeln('• Оклад денежного содержания (ОДС): ${ods.toStringAsFixed(0)} руб.');

    if (nvlAmount > 0) sb.writeln('• Выслуга лет ($selectedNvl): +${nvlAmount.toStringAsFixed(2)} руб.');
    if (secrecyAmount > 0) sb.writeln('• Гос. тайна ($selectedSecrecy): +${secrecyAmount.toStringAsFixed(2)} руб.');
    if (ouvsAmount > 0) sb.writeln('• НАДБАВКА ЗА ОУС + Командование подразделением ($selectedOuvs): +${ouvsAmount.toStringAsFixed(2)} руб.');
    if (classAmount > 0) sb.writeln('• Классная квалификация ($selectedClass): +${classAmount.toStringAsFixed(2)} руб.');
    if (flightAmount > 0) sb.writeln('• Летный состав ($selectedFlight): +${flightAmount.toStringAsFixed(2)} руб.');
    if (combatDutyAmount > 0) {
      String desc = combatDutyPercent == 0.30
          ? '5 и более суток в месяц (30%)'
          : combatDutyPercent == 0.15
              ? 'от 3 до 4 суток в месяц (15%)'
              : 'от 1 до 2 суток в месяц (5%)';
      sb.writeln('• Боевое дежурство ($desc): +${combatDutyAmount.toStringAsFixed(2)} руб.');
    }
    if (premiumAmount > 0) sb.writeln('• Премия ($selectedPremium): +${premiumAmount.toStringAsFixed(2)} руб.');
    if (rkAmount > 0) sb.writeln('• Районный коэф. (коэф. $selectedDistrictVal): +${rkAmount.toStringAsFixed(2)} руб.');
    if (northernAmount > 0) sb.writeln('• Северная надбавка (${(selectedNorthernVal * 100).toInt()}%): +${northernAmount.toStringAsFixed(2)} руб.');
    if (specialUnitsAmount > 0) sb.writeln('• Надбавка подразделениям ($selectedSpecialUnits): +${specialUnitsAmount.toStringAsFixed(2)} руб.');
    if (otherAchievementsAmount > 0) sb.writeln('• Особые достижения ($selectedOtherAchievements): +${otherAchievementsAmount.toStringAsFixed(2)} руб.');
    if (contractAmount > 0) sb.writeln('• Контракт 1-4 т.р. (50%): +${contractAmount.toStringAsFixed(2)} руб.');
    if (driverAmount > 0) sb.writeln('• Должность водителя (30%): +${driverAmount.toStringAsFixed(2)} руб.');
    if (medalsAmount > 0) sb.writeln('• Знаки отличия МО РФ ($selectedMedals): +${medalsAmount.toStringAsFixed(2)} руб.');
    if (zgtAmount > 0) sb.writeln('• Подразделения ЗГТ ($selectedZgt): +${zgtAmount.toStringAsFixed(2)} руб.');
    if (cipherAmount > 0) sb.writeln('• Работа с шифрами ($selectedCipher): +${cipherAmount.toStringAsFixed(2)} руб.');
    if (matHelpAmount > 0) sb.writeln('• Материальная помощь (1 ОДС): +${matHelpAmount.toStringAsFixed(2)} руб.');
    if (comp844Amount > 0) sb.writeln('• Компенсация по пр. № 844 ($days844 дн.): +${comp844Amount.toStringAsFixed(2)} руб.');
    if (riskAmount > 0) sb.writeln('• Риск для жизни ($riskDays дн.): +${riskAmount.toStringAsFixed(2)} руб.');

    sb.writeln('--------------------------------');
    sb.writeln('💵 ИТОГО НАЧИСЛЕНО: ${totalGross.toStringAsFixed(2)} руб.');
    sb.writeln('• НДФЛ (13%): -${ndfl.toStringAsFixed(2)} руб.');
    if (alimonyAmount > 0) sb.writeln('• Алименты ($selectedAlimony): -${alimonyAmount.toStringAsFixed(2)} руб.');
    sb.writeln('📉 ВСЕГО УДЕРЖАНО: ${totalHold.toStringAsFixed(2)} руб.');
    sb.writeln('--------------------------------');
    sb.writeln('💰 НА РУКИ: ${netPay.toStringAsFixed(2)} руб.');
    sb.writeln('\nРассчитано в приложении «Калькулятор ДД»');
    return sb.toString();
  }

  void _showShareDialog(String summary) {
    _playClickFeedback();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.description, color: Color(0xFF3949AB)),
            SizedBox(width: 8),
            Text('Итоговый расчет', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(
              summary,
              style: const TextStyle(fontSize: 13, height: 1.4, fontFamily: 'monospace'),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Закрыть'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3949AB),
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('Скопировать'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: summary));
              _playClickFeedback();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Расчет скопирован в буфер обмена!'),
                  duration: Duration(seconds: 3),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color highlightColor = isDark ? const Color(0xFFFFD54F) : const Color(0xFF1A237E);

    double indexCoeff = salaryPeriods[selectedPeriod] ?? 1.0;

    double baseRankVal = militaryRanks[selectedRank] ?? 0.0;
    double rawOvz = baseRankVal * indexCoeff;
    double ovz = (baseRankVal == 0.0 || indexCoeff == 1.0) ? rawOvz : rawOvz.ceilToDouble();

    double baseTariffVal = militaryTariffRanks[selectedTariff] ?? 0.0;
    double rawOvd = baseTariffVal * indexCoeff;
    double ovd = (baseTariffVal == 0.0 || indexCoeff == 1.0) ? rawOvd : rawOvd.ceilToDouble();

    double ods = ovz + ovd;

    double flightBonusPercent = 0.0;
    if (selectedFlight.startsWith('40%')) flightBonusPercent = 0.40;
    if (selectedFlight.startsWith('50%')) flightBonusPercent = 0.50;
    if (selectedFlight.startsWith('60%')) flightBonusPercent = 0.60;
    if (selectedFlight.startsWith('70%')) flightBonusPercent = 0.70;

    double nvlPercent = 0.0;
    if (selectedNvl.contains('10%')) nvlPercent = 0.10;
    if (selectedNvl.contains('15%')) nvlPercent = 0.15;
    if (selectedNvl.contains('20%')) nvlPercent = 0.20;
    if (selectedNvl.contains('25%')) nvlPercent = 0.25;
    if (selectedNvl.contains('30%')) nvlPercent = 0.30;
    if (selectedNvl.contains('40%')) nvlPercent = 0.40;

    double secrecyPercent = 0.0;
    if (selectedSecrecy.contains('10%')) secrecyPercent = 0.10;
    if (selectedSecrecy.contains('20%')) secrecyPercent = 0.20;
    if (selectedSecrecy.contains('25%')) secrecyPercent = 0.25;

    double ouvsPercent = double.parse(selectedOuvs.replaceAll('%', '')) / 100.0;

    double classPercent = 0.0;
    if (selectedClass.contains('5%')) classPercent = 0.05;
    if (selectedClass.contains('10%')) classPercent = 0.10;
    if (selectedClass.contains('20%')) classPercent = 0.20;
    if (selectedClass.contains('30%')) classPercent = 0.30;

    double combatDutyAmount = ovd * combatDutyPercent;
    double premiumPercent = double.parse(selectedPremium.replaceAll('%', '')) / 100.0;

    double specialUnitsPercent = 0.0;
    if (selectedSpecialUnits.contains('100%')) specialUnitsPercent = 1.0;
    if (selectedSpecialUnits.contains('110%')) specialUnitsPercent = 1.10;
    if (selectedSpecialUnits.contains('120%')) specialUnitsPercent = 1.20;
    double specialUnitsAmount = ovd * specialUnitsPercent;

    double otherAchievementsPercent = 0.0;
    if (selectedOtherAchievements.startsWith('15%')) otherAchievementsPercent = 0.15;
    if (selectedOtherAchievements.startsWith('20%')) otherAchievementsPercent = 0.20;
    if (selectedOtherAchievements.startsWith('30%')) otherAchievementsPercent = 0.30;
    if (selectedOtherAchievements.startsWith('40%')) otherAchievementsPercent = 0.40;
    if (selectedOtherAchievements.startsWith('60%')) otherAchievementsPercent = 0.60;
    if (selectedOtherAchievements.startsWith('70%')) otherAchievementsPercent = 0.70;
    if (selectedOtherAchievements.startsWith('80%')) otherAchievementsPercent = 0.80;
    if (selectedOtherAchievements.startsWith('90%')) otherAchievementsPercent = 0.90;
    if (selectedOtherAchievements.startsWith('100%')) otherAchievementsPercent = 1.0;
    double otherAchievementsAmount = ovd * otherAchievementsPercent;

    double contractAmount = hasContractBonus ? (ovd * 0.50) : 0.0;
    double driverAmount = isDriver ? (ovd * 0.30) : 0.0;

    double medalsPercent = 0.0;
    if (selectedMedals.contains('10%')) medalsPercent = 0.10;
    if (selectedMedals.contains('20%')) medalsPercent = 0.20;
    if (selectedMedals.contains('30%')) medalsPercent = 0.30;

    double zgtPercent = 0.0;
    if (selectedZgt.contains('10%')) zgtPercent = 0.10;
    if (selectedZgt.contains('15%')) zgtPercent = 0.15;
    if (selectedZgt.contains('20%')) zgtPercent = 0.20;

    double cipherPercent = 0.0;
    if (selectedCipher.contains('5%')) cipherPercent = 0.05;
    if (selectedCipher.contains('10%')) cipherPercent = 0.10;
    if (selectedCipher.contains('15%')) cipherPercent = 0.15;
    if (selectedCipher.contains('20%')) cipherPercent = 0.20;
    if (selectedCipher.contains('30%')) cipherPercent = 0.30;

    double alimonyPercent = 0.0;
    if (selectedAlimony.contains('25%')) alimonyPercent = 0.25;
    if (selectedAlimony.contains('33%')) alimonyPercent = 0.3333;
    if (selectedAlimony.contains('50%')) alimonyPercent = 0.50;

    double childDeduction = 0.0;
    if (selectedChildDeduction.contains('1400')) childDeduction = 1400.0;
    if (selectedChildDeduction.contains('2800')) childDeduction = 2800.0;
    if (selectedChildDeduction.contains('5800')) childDeduction = 5800.0;
    if (selectedChildDeduction.contains('8800')) childDeduction = 8800.0;

    double nvlAmount = ods * nvlPercent;
    double secrecyAmount = ovd * secrecyPercent;
    double ouvsAmount = ovd * ouvsPercent;
    double classAmount = ovd * classPercent;
    double flightAmount = ovd * flightBonusPercent;

    double baseRkSn = ods + nvlAmount + secrecyAmount + ouvsAmount + classAmount + flightAmount + combatDutyAmount;
    double rkAmount = baseRkSn * (selectedDistrictVal - 1.0);
    double northernAmount = baseRkSn * selectedNorthernVal;

    double premiumAmount = ods * premiumPercent;
    double zgtAmount = ovd * zgtPercent;
    double cipherAmount = ovd * cipherPercent;
    double medalsAmount = ovd * medalsPercent;
    double matHelpAmount = hasMatHelp ? ods : 0.0;

    int extraRestDays = (days844 ~/ 3) * 2;
    double comp844Amount = (ods / 30.0) * extraRestDays;

    double riskPercent = (riskDays * 0.02).clamp(0.0, 1.0);
    double riskAmount = ovd * riskPercent;

    double totalGross = baseRkSn +
        rkAmount +
        northernAmount +
        premiumAmount +
        specialUnitsAmount +
        otherAchievementsAmount +
        contractAmount +
        driverAmount +
        zgtAmount +
        cipherAmount +
        medalsAmount +
        matHelpAmount +
        comp844Amount +
        riskAmount;

    double totalDeductions = (isVbd ? 500.0 : 0.0) + childDeduction;
    double taxableBase = (totalGross - totalDeductions).clamp(0.0, double.infinity);
    double ndfl = (taxableBase * 0.13).roundToDouble();

    double afterTax = totalGross - ndfl;
    double alimonyAmount = afterTax * alimonyPercent;
    double totalHold = ndfl + alimonyAmount;
    double netPay = totalGross - totalHold;

    String calculationSummary = _generateCalculationSummary(
      ovz: ovz,
      ovd: ovd,
      ods: ods,
      nvlAmount: nvlAmount,
      secrecyAmount: secrecyAmount,
      ouvsAmount: ouvsAmount,
      classAmount: classAmount,
      flightAmount: flightAmount,
      combatDutyAmount: combatDutyAmount,
      rkAmount: rkAmount,
      northernAmount: northernAmount,
      premiumAmount: premiumAmount,
      specialUnitsAmount: specialUnitsAmount,
      otherAchievementsAmount: otherAchievementsAmount,
      contractAmount: contractAmount,
      driverAmount: driverAmount,
      zgtAmount: zgtAmount,
      cipherAmount: cipherAmount,
      medalsAmount: medalsAmount,
      matHelpAmount: matHelpAmount,
      comp844Amount: comp844Amount,
      riskAmount: riskAmount,
      totalGross: totalGross,
      ndfl: ndfl,
      alimonyAmount: alimonyAmount,
      totalHold: totalHold,
      netPay: netPay,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Калькулятор ДД', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Переключить тему',
            onPressed: () {
              _playClickFeedback();
              widget.onToggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.restart_alt),
            tooltip: 'Сбросить все поля',
            onPressed: _resetAllFields,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Поделиться расчетом',
            onPressed: () => _showShareDialog(calculationSummary),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            color: isDark ? const Color(0xFF1E2638) : Colors.white,
            child: Column(
              children: [
                Text('Начислено: ${totalGross.toStringAsFixed(2)} рублей',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Удержано: ${totalHold.toStringAsFixed(2)} рублей',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('На руки: ${netPay.toStringAsFixed(2)} рублей.',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: highlightColor)),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _buildPeriodSelector(isDark),

                _buildColoredLabelDropdown(
                  title: 'Воинское звание:',
                  highlightAmount: '${ovz.toStringAsFixed(0)} руб.',
                  value: selectedRank,
                  items: militaryRanks.keys.toList(),
                  onChanged: (val) {
                    _playClickFeedback();
                    setState(() => selectedRank = val!);
                    StorageService.set('dd_rank', val);
                  },
                  isDark: isDark,
                  highlightColor: highlightColor,
                ),

                _buildColoredLabelDropdown(
                  title: 'Тарифный разряд:',
                  highlightAmount: '${ovd.toStringAsFixed(0)} руб.',
                  value: selectedTariff,
                  items: militaryTariffRanks.keys.toList(),
                  onChanged: (val) {
                    _playClickFeedback();
                    setState(() => selectedTariff = val!);
                    StorageService.set('dd_tariff', val);
                  },
                  isDark: isDark,
                  highlightColor: highlightColor,
                ),

                _buildColoredLabelDropdown(
                  title: 'Надбавка за летный состав:',
                  highlightAmount: flightAmount > 0 ? '+${flightAmount.toStringAsFixed(1)} руб.' : '0.0 руб.',
                  value: selectedFlight,
                  items: ['нет', '40% - 3 класс', '50% - 2 класс', '60% - 1 класс', '70% - снайпер'],
                  onChanged: (val) {
                    _playClickFeedback();
                    setState(() => selectedFlight = val!);
                    StorageService.set('dd_flight', val);
                  },
                  isDark: isDark,
                  highlightColor: highlightColor,
                ),

                _buildColoredLabelDropdown(
                  title: 'Выслуга лет:',
                  highlightAmount: '+${nvlAmount.toStringAsFixed(1)} руб.',
                  value: selectedNvl,
                  items: [
                    'до 2 лет – 0%',
                    'от 2 до 5 лет – 10%',
                    'от 5 до 10 лет – 15%',
                    'от 10 до 15 лет – 20%',
                    'от 15 до 20 лет – 25%',
                    'от 20 до 25 лет – 30%',
                    '25 лет и более – 40%'
                  ],
                  onChanged: (val) {
                    _playClickFeedback();
                    setState(() => selectedNvl = val!);
                    StorageService.set('dd_nvl', val);
                  },
                  isDark: isDark,
                  highlightColor: highlightColor,
                ),

                _buildDropdownItem(
                  'Надбавка за допуск к сведениям, составляющим гос. тайну:',
                  selectedSecrecy,
                  ['нет - 0%', 'секретно - 10%', 'сов. секретно - 20%', 'особая важность - 25%'],
                  (val) {
                    _playClickFeedback();
                    setState(() => selectedSecrecy = val!);
                    StorageService.set('dd_secrecy', val);
                  },
                  isDark,
                ),

                // НАДБАВКА ЗА ОУС КРАТНО 5% ДО 100%
                _buildColoredLabelDropdown(
                  title: 'НАДБАВКА ЗА ОУС + Командование подразделением:',
                  highlightAmount: '+${ouvsAmount.toStringAsFixed(1)} руб.',
                  value: selectedOuvs,
                  items: ouvsOptions,
                  onChanged: (val) {
                    _playClickFeedback();
                    setState(() => selectedOuvs = val!);
                    StorageService.set('dd_ouvs', val);
                  },
                  isDark: isDark,
                  highlightColor: highlightColor,
                ),

                _buildColoredLabelDropdown(
                  title: 'Надбавка за классную квалификацию:',
                  highlightAmount: '+${classAmount.toStringAsFixed(1)} руб.',
                  value: selectedClass,
                  items: ['без класса - 0%', '3 класс - 5%', '2 класс - 10%', '1 класс - 20%', 'мастер - 30%'],
                  onChanged: (val) {
                    _playClickFeedback();
                    setState(() => selectedClass = val!);
                    StorageService.set('dd_class', val);
                  },
                  isDark: isDark,
                  highlightColor: highlightColor,
                ),

                // НАДБАВКА ЗА БОЕВОЕ ДЕЖУРСТВО
                Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: 'Надбавка за боевое дежурство (от ОВД): ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isDark ? const Color(0xFF82B1FF) : const Color(0xFF1A237E),
                            ),
                            children: [
                              TextSpan(
                                text: combatDutyAmount > 0 ? '+${combatDutyAmount.toStringAsFixed(1)} руб.' : '0.0 руб.',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: highlightColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildRadioOptionTile(
                          title: '5 и более суток в месяц — 30%',
                          amount: ovd * 0.30,
                          isSelected: combatDutyPercent == 0.30,
                          onTap: () {
                            _playClickFeedback();
                            final nextVal = combatDutyPercent == 0.30 ? 0.0 : 0.30;
                            setState(() => combatDutyPercent = nextVal);
                            StorageService.set('dd_combat_duty', nextVal);
                          },
                          isDark: isDark,
                          highlightColor: highlightColor,
                        ),
                        const SizedBox(height: 4),
                        _buildRadioOptionTile(
                          title: 'от 3 до 4 суток в месяц — 15%',
                          amount: ovd * 0.15,
                          isSelected: combatDutyPercent == 0.15,
                          onTap: () {
                            _playClickFeedback();
                            final nextVal = combatDutyPercent == 0.15 ? 0.0 : 0.15;
                            setState(() => combatDutyPercent = nextVal);
                            StorageService.set('dd_combat_duty', nextVal);
                          },
                          isDark: isDark,
                          highlightColor: highlightColor,
                        ),
                        const SizedBox(height: 4),
                        _buildRadioOptionTile(
                          title: 'от 1 до 2 суток в месяц — 5%',
                          amount: ovd * 0.05,
                          isSelected: combatDutyPercent == 0.05,
                          onTap: () {
                            _playClickFeedback();
                            final nextVal = combatDutyPercent == 0.05 ? 0.0 : 0.05;
                            setState(() => combatDutyPercent = nextVal);
                            StorageService.set('dd_combat_duty', nextVal);
                          },
                          isDark: isDark,
                          highlightColor: highlightColor,
                        ),
                      ],
                    ),
                  ),
                ),

                // РАЙОННЫЙ КОЭФФИЦИЕНТ
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: 'Районный коэффициент: ',
                          style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey.shade300 : Colors.black87),
                          children: [
                            TextSpan(
                              text: rkAmount > 0 ? '+${rkAmount.toStringAsFixed(2)} руб.' : '0.0 руб.',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: highlightColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E2638) : const Color(0xFFE4E7ED),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: isDark ? Colors.grey.shade700 : Colors.grey.shade400),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<double>(
                            value: districtOptions.contains(selectedDistrictVal) ? selectedDistrictVal : 1.0,
                            isExpanded: true,
                            itemHeight: 38.0,
                            dropdownColor: isDark ? const Color(0xFF1E2638) : Colors.white,
                            items: districtOptions.map((k) {
                              double sum = baseRkSn * (k - 1.0);
                              String labelText = k == 1.0 || k == 2.0 ? k.toStringAsFixed(0) : k.toString();
                              final bool isSelected = k == selectedDistrictVal;
                              return DropdownMenuItem<double>(
                                value: k,
                                child: Container(
                                  width: double.infinity,
                                  alignment: Alignment.centerLeft,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? (isDark ? const Color(0xFF2C3854) : const Color(0xFFD0D7DE))
                                        : Colors.transparent,
                                    border: Border(
                                      bottom: BorderSide(
                                        color: isDark ? Colors.white12 : Colors.black12,
                                        width: 0.5,
                                      ),
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                                  child: Text(
                                    '$labelText – ${sum.toStringAsFixed(2)} руб.',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? highlightColor : (isDark ? Colors.white : Colors.black87),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              _playClickFeedback();
                              final newVal = val ?? 1.0;
                              setState(() => selectedDistrictVal = newVal);
                              StorageService.set('dd_district', newVal);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // СЕВЕРНАЯ НАДБАВКА
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: 'Северная надбавка: ',
                          style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey.shade300 : Colors.black87),
                          children: [
                            TextSpan(
                              text: northernAmount > 0 ? '+${northernAmount.toStringAsFixed(2)} руб.' : '0.0 руб.',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: highlightColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E2638) : const Color(0xFFE4E7ED),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: isDark ? Colors.grey.shade700 : Colors.grey.shade400),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<double>(
                            value: northernOptions.any((opt) => (opt['val'] as double) == selectedNorthernVal)
                                ? selectedNorthernVal
                                : 0.0,
                            isExpanded: true,
                            itemHeight: 38.0,
                            dropdownColor: isDark ? const Color(0xFF1E2638) : Colors.white,
                            items: northernOptions.map((opt) {
                              double p = opt['val'] as double;
                              double sum = baseRkSn * p;
                              String label = opt['label'] as String;
                              final bool isSelected = p == selectedNorthernVal;
                              return DropdownMenuItem<double>(
                                value: p,
                                child: Container(
                                  width: double.infinity,
                                  alignment: Alignment.centerLeft,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? (isDark ? const Color(0xFF2C3854) : const Color(0xFFD0D7DE))
                                        : Colors.transparent,
                                    border: Border(
                                      bottom: BorderSide(
                                        color: isDark ? Colors.white12 : Colors.black12,
                                        width: 0.5,
                                      ),
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                                  child: Text(
                                    '$label – ${sum.toStringAsFixed(2)} руб.',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? highlightColor : (isDark ? Colors.white : Colors.black87),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              _playClickFeedback();
                              final newVal = val ?? 0.0;
                              setState(() => selectedNorthernVal = newVal);
                              StorageService.set('dd_northern', newVal);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                _buildColoredLabelDropdown(
                  title: 'Ежемесячная премия:',
                  highlightAmount: premiumAmount > 0 ? '+${premiumAmount.toStringAsFixed(1)} руб.' : '0.0 руб.',
                  value: selectedPremium,
                  items: List.generate(26, (i) => '$i%'),
                  onChanged: (val) {
                    _playClickFeedback();
                    setState(() => selectedPremium = val!);
                    StorageService.set('dd_premium', val);
                  },
                  isDark: isDark,
                  highlightColor: highlightColor,
                ),

                _buildColoredLabelDropdown(
                  title: 'Надбавка подразделениям (ВКС, ВМФ, РВСН, ГУ ГШ):',
                  highlightAmount: specialUnitsAmount > 0 ? '+${specialUnitsAmount.toStringAsFixed(1)} руб.' : '0.0 руб.',
                  value: selectedSpecialUnits,
                  items: [
                    'нет (0%)',
                    '100% от ОВД - офицерам',
                    '110% от ОВД - мичманы, прапорщики',
                    '120% от ОВД - матросы, старшины',
                  ],
                  onChanged: (val) {
                    _playClickFeedback();
                    setState(() => selectedSpecialUnits = val!);
                    StorageService.set('dd_special_units', val);
                  },
                  isDark: isDark,
                  highlightColor: highlightColor,
                ),

                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2638) : const Color(0xFFECEFF1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: isDark ? Colors.blueGrey.shade700 : Colors.blueGrey.shade200),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Надбавка положена контрактникам, проходящим службу в подразделениях: ВКС (летный состав), ВМФ (экипажи боевых кораблей/судов), РВСН и ГУ ГШ:',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text('• 100% от ОВД — офицерам', style: TextStyle(fontSize: 11)),
                      Text('• 110% от ОВД — мичманам и прапорщикам', style: TextStyle(fontSize: 11)),
                      Text('• 120% от ОВД — матросам, солдатам, сержантам и старшинам', style: TextStyle(fontSize: 11)),
                    ],
                  ),
                ),

                _buildColoredLabelDropdown(
                  title: 'Прочие достижения:',
                  highlightAmount: otherAchievementsAmount > 0 ? '+${otherAchievementsAmount.toStringAsFixed(1)} руб.' : '0.0 руб.',
                  value: selectedOtherAchievements,
                  items: [
                    '0%',
                    '15% - 2 уровень физо',
                    '20% - за разминирование',
                    '30% - 1 уровень физо',
                    '40% - доцент',
                    '60% - профессор',
                    '70% - высший уровень физо',
                    '80% - 1 разряд по ВПВС',
                    '90% - КМС по ВПВС',
                    '100% - МС по ВПВС',
                  ],
                  onChanged: (val) {
                    _playClickFeedback();
                    setState(() => selectedOtherAchievements = val!);
                    StorageService.set('dd_achievements', val);
                  },
                  isDark: isDark,
                  highlightColor: highlightColor,
                ),

                _buildColoredCheckboxTile(
                  title: 'Надбавка за особые достижения (- контракт 1-4 т.р.):',
                  highlightAmount: '${(ovd * 0.50).toStringAsFixed(1)} руб.',
                  value: hasContractBonus,
                  onChanged: (val) {
                    _playClickFeedback();
                    final newVal = val ?? false;
                    setState(() => hasContractBonus = newVal);
                    StorageService.set('dd_contract_bonus', newVal);
                  },
                  isDark: isDark,
                  highlightColor: highlightColor,
                ),

                _buildColoredCheckboxTile(
                  title: 'На должности водителя (30% от ОВД):',
                  highlightAmount: '${(ovd * 0.30).toStringAsFixed(1)} руб.',
                  value: isDriver,
                  onChanged: (val) {
                    _playClickFeedback();
                    final newVal = val ?? false;
                    setState(() => isDriver = newVal);
                    StorageService.set('dd_driver', newVal);
                  },
                  isDark: isDark,
                  highlightColor: highlightColor,
                ),

                _buildDropdownItem(
                  'Ежемесячная надбавка при награждении знаками отличия МО РФ:',
                  selectedMedals,
                  [
                    'нет надбавки - 0%',
                    '10% - "За воинскую доблесть" II степени',
                    '20% - "За разминирование", "За воинскую доблесть" I ст.',
                    '30% - "За боевые отличия"'
                  ],
                  (val) {
                    _playClickFeedback();
                    setState(() => selectedMedals = val!);
                    StorageService.set('dd_medals', val);
                  },
                  isDark,
                ),

                _buildDropdownItem(
                  'Надбавка за работу в структурных подразделениях по ЗГТ:',
                  selectedZgt,
                  ['0%', '10% - от 1 до 5 лет', '15% - от 5 до 10 лет', '20% - от 10 лет и выше'],
                  (val) {
                    _playClickFeedback();
                    setState(() => selectedZgt = val!);
                    StorageService.set('dd_zgt', val);
                  },
                  isDark,
                ),

                _buildDropdownItem(
                  'Надбавка за работу с шифрами:',
                  selectedCipher,
                  [
                    '0%',
                    '5% - до 3 лет (2 класс)',
                    '15% - до 3 лет (1 класс)',
                    '10% - от 3 до 6 лет (2 класс)',
                    '20% - от 3 до 6 лет (1 класс)',
                    '20% - от 6 и более (2 класс)',
                    '30% - от 6 и более (1 класс)'
                  ],
                  (val) {
                    _playClickFeedback();
                    setState(() => selectedCipher = val!);
                    StorageService.set('dd_cipher', val);
                  },
                  isDark,
                ),

                _buildDropdownItem(
                  'Алименты:',
                  selectedAlimony,
                  ['0%', '25% - на одного ребенка', '33% - на двух детей', '50% - на трех и более'],
                  (val) {
                    _playClickFeedback();
                    setState(() => selectedAlimony = val!);
                    StorageService.set('dd_alimony', val);
                  },
                  isDark,
                ),

                _buildColoredCheckboxTile(
                  title: 'Материальная помощь:',
                  highlightAmount: '${ods.toStringAsFixed(1)} руб.',
                  value: hasMatHelp,
                  onChanged: (val) {
                    _playClickFeedback();
                    final newVal = val ?? false;
                    setState(() => hasMatHelp = newVal);
                    StorageService.set('dd_mat_help', newVal);
                  },
                  isDark: isDark,
                  highlightColor: highlightColor,
                ),

                _buildCheckboxTile(
                  'Ветеран боевых действий (ст.218 п.1. пп.2 – 500 рублей)',
                  isVbd,
                  (val) {
                    _playClickFeedback();
                    final newVal = val ?? false;
                    setState(() => isVbd = newVal);
                    StorageService.set('dd_vbd', newVal);
                  },
                  isDark,
                ),

                _buildDropdownItem(
                  'Налоговый вычет на несовершеннолетних детей (ст. 218 п.1 пп. 4):',
                  selectedChildDeduction,
                  [
                    'нет детей',
                    '1 ребенок - 1400 руб.',
                    '2 ребенка - 2800 руб.',
                    '3 ребенка - 5800 руб.',
                    '4 ребенка - 8800 руб.'
                  ],
                  (val) {
                    _playClickFeedback();
                    setState(() => selectedChildDeduction = val!);
                    StorageService.set('dd_child', val);
                  },
                  isDark,
                ),

                const SizedBox(height: 10),

                _buildCardSection(
                  title: 'Приказ МО РФ № 844 (дополнительные сутки отдыха)',
                  isDark: isDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            flex: 3,
                            child: Text('Дней мероприятий (без ограничения времени):',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 1,
                            child: TextField(
                              controller: _days844Controller,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: const InputDecoration(
                                isDense: true,
                                border: OutlineInputBorder(),
                                hintText: '0',
                              ),
                              onChanged: (val) {
                                final newVal = int.tryParse(val) ?? 0;
                                setState(() => days844 = newVal);
                                StorageService.set('dd_days844', newVal);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      RichText(
                        text: TextSpan(
                          text: 'Положено суток отдыха: $extraRestDays дн. | Компенсация: ',
                          style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey.shade300 : Colors.blueGrey,
                              fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text: '${comp844Amount.toStringAsFixed(2)} руб.',
                              style: TextStyle(
                                color: highlightColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                _buildCardSection(
                  title: 'Риск для жизни (Приказ МО РФ № 727, 2% в день, макс 100%)',
                  isDark: isDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            flex: 3,
                            child: Text('Дней участия с риском для жизни:',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 1,
                            child: TextField(
                              controller: _riskDaysController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: const InputDecoration(
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (val) {
                                final newVal = int.tryParse(val) ?? 0;
                                setState(() => riskDays = newVal);
                                StorageService.set('dd_risk_days', newVal);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      RichText(
                        text: TextSpan(
                          text: 'Надбавка: ${(riskPercent * 100).toInt()}% от ОВД | Сумма: ',
                          style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey.shade300 : Colors.blueGrey,
                              fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text: '${riskAmount.toStringAsFixed(2)} руб.',
                              style: TextStyle(
                                color: highlightColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColoredLabelDropdown({
    required String title,
    required String highlightAmount,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required bool isDark,
    required Color highlightColor,
  }) {
    String effectiveValue = items.contains(value) ? value : items.first;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: '$title ',
              style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey.shade300 : Colors.black87),
              children: [
                TextSpan(
                  text: highlightAmount,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: highlightColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2638) : const Color(0xFFE4E7ED),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade400),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: effectiveValue,
                isExpanded: true,
                itemHeight: 38.0,
                dropdownColor: isDark ? const Color(0xFF1E2638) : Colors.white,
                items: items.map((item) {
                  final bool isSelected = item == effectiveValue;
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? const Color(0xFF2C3854) : const Color(0xFFD0D7DE))
                            : Colors.transparent,
                        border: Border(
                          bottom: BorderSide(
                            color: isDark ? Colors.white12 : Colors.black12,
                            width: 0.5,
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? highlightColor : (isDark ? Colors.white : Colors.black87),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColoredCheckboxTile({
    required String title,
    required String highlightAmount,
    required bool value,
    required ValueChanged<bool?> onChanged,
    required bool isDark,
    required Color highlightColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2638) : const Color(0xFFE4E7ED),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade400),
      ),
      child: CheckboxListTile(
        title: RichText(
          text: TextSpan(
            text: '$title ',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87),
            children: [
              TextSpan(
                text: highlightAmount,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: highlightColor,
                ),
              ),
            ],
          ),
        ),
        value: value,
        dense: true,
        controlAffinity: ListTileControlAffinity.leading,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildRadioOptionTile({
    required String title,
    required double amount,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    required Color highlightColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF2C3854) : const Color(0xFFD6DBE4))
              : (isDark ? const Color(0xFF1E2638) : const Color(0xFFE4E7ED)),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected
                ? (isDark ? const Color(0xFF82B1FF) : const Color(0xFF3949AB))
                : (isDark ? Colors.grey.shade700 : Colors.grey.shade400),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected
                  ? (isDark ? const Color(0xFF82B1FF) : const Color(0xFF3949AB))
                  : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            Text(
              '+${amount.toStringAsFixed(1)} руб.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: highlightColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(bool isDark) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF263248) : const Color(0xFFD6DBE4),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: isDark ? Colors.blueGrey.shade700 : Colors.grey.shade500),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedPeriod,
          isExpanded: true,
          itemHeight: 38.0,
          dropdownColor: isDark ? const Color(0xFF1E2638) : Colors.white,
          icon: const Icon(Icons.arrow_drop_down),
          style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 13),
          items: salaryPeriods.keys
              .map((p) => DropdownMenuItem(value: p, child: Text(p)))
              .toList(),
          onChanged: (val) {
            _playClickFeedback();
            setState(() => selectedPeriod = val!);
            StorageService.set('dd_period', val);
          },
        ),
      ),
    );
  }

  Widget _buildDropdownItem(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
    bool isDark,
  ) {
    String effectiveValue = items.contains(value) ? value : items.first;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey.shade300 : Colors.black87)),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2638) : const Color(0xFFE4E7ED),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade400),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: effectiveValue,
                isExpanded: true,
                itemHeight: 38.0,
                dropdownColor: isDark ? const Color(0xFF1E2638) : Colors.white,
                items: items.map((item) {
                  final bool isSelected = item == effectiveValue;
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? const Color(0xFF2C3854) : const Color(0xFFD0D7DE))
                            : Colors.transparent,
                        border: Border(
                          bottom: BorderSide(
                            color: isDark ? Colors.white12 : Colors.black12,
                            width: 0.5,
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? (isDark ? const Color(0xFFFFD54F) : const Color(0xFF1A237E))
                              : (isDark ? Colors.white : Colors.black87),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxTile(
      String label, bool value, ValueChanged<bool?> onChanged, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2638) : const Color(0xFFE4E7ED),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade400),
      ),
      child: CheckboxListTile(
        title: Text(label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        value: value,
        dense: true,
        controlAffinity: ListTileControlAffinity.leading,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildCardSection({
    required String title,
    required Widget child,
    required bool isDark,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDark ? const Color(0xFF82B1FF) : const Color(0xFF1A237E))),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// ЭКРАН 2: КАЛЬКУЛЯТОР ВОЕННОЙ ПЕНСИИ (Законы № 4468-1 и № 433-ФЗ)
// -------------------------------------------------------------
class PensionCalculatorScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const PensionCalculatorScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<PensionCalculatorScreen> createState() => _PensionCalculatorScreenState();
}

class _PensionCalculatorScreenState extends State<PensionCalculatorScreen> {
  void _playClickFeedback() {
    HapticFeedback.mediumImpact();
  }

  String selectedRank = 'Прапорщик, мичман';
  String selectedTariff = '4 т.р.';
  int serviceYears = 20;
  double selectedDistrictVal = 1.0;
  bool isVbd = false;

  double loweringCoeff = 0.9359;

  final List<double> pensionDistrictOptions = [
    1.0, 1.15, 1.2, 1.25, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 2.0
  ];

  @override
  void initState() {
    super.initState();
    _loadPensionPrefs();
  }

  Future<void> _loadPensionPrefs() async {
    await StorageService.init();
    setState(() {
      selectedRank = StorageService.get('pension_rank', 'Прапорщик, мичман');
      selectedTariff = StorageService.get('pension_tariff', '4 т.р.');
      serviceYears = (StorageService.get('pension_years', 20) as num).toInt();
      selectedDistrictVal = (StorageService.get('pension_district', 1.0) as num).toDouble();
      isVbd = StorageService.get('pension_vbd', false) as bool;
    });
  }

  void _sharePensionSummary(double totalPension, double baseOds, double nvlPercent, double pensionPercent) {
    _playClickFeedback();
    String text = '''
🎖 РАСЧЕТ ВОЕННОЙ ПЕНСИИ (Законы № 4468-1 и № 433-ФЗ)
--------------------------------
• Воинское звание: $selectedRank
• Тарифный разряд: $selectedTariff
• Базовый оклад для пенсии: ${baseOds.toStringAsFixed(2)} руб.
• Выслуга лет: $serviceYears лет
• Процент пенсии от ДД: ${(pensionPercent * 100).toInt()}%
• Понижающий коэффициент (№ 433-ФЗ): ${(loweringCoeff * 100).toStringAsFixed(2)}%
• Районный коэффициент: $selectedDistrictVal
• Ветеран боевых действий: ${isVbd ? "Да (+4184 руб.)" : "Нет"}
--------------------------------
💰 ИТОГОВАЯ ПЕНСИЯ: ${totalPension.toStringAsFixed(2)} руб./мес.
''';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Расчет пенсии'),
        content: SelectableText(text, style: const TextStyle(fontFamily: 'monospace', fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Закрыть')),
          ElevatedButton.icon(
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('Скопировать'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: text));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Расчет пенсии скопирован!')),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color highlightColor = isDark ? const Color(0xFFFFD54F) : const Color(0xFF1A237E);

    double ovz = militaryRanks[selectedRank] ?? 0.0;
    double ovd = militaryTariffRanks[selectedTariff] ?? 0.0;
    double ods = ovz + ovd;

    double nvlPercent = 0.0;
    if (serviceYears >= 2 && serviceYears < 5) nvlPercent = 0.10;
    if (serviceYears >= 5 && serviceYears < 10) nvlPercent = 0.15;
    if (serviceYears >= 10 && serviceYears < 15) nvlPercent = 0.20;
    if (serviceYears >= 15 && serviceYears < 20) nvlPercent = 0.25;
    if (serviceYears >= 20 && serviceYears < 25) nvlPercent = 0.30;
    if (serviceYears >= 25) nvlPercent = 0.40;

    double nvlAmount = ods * nvlPercent;
    double totalBaseDds = ods + nvlAmount;

    double pensionPercent = 0.50 + ((serviceYears - 20) * 0.03);
    if (pensionPercent > 0.85) pensionPercent = 0.85;
    if (pensionPercent < 0.50) pensionPercent = 0.50;

    double rawPension = totalBaseDds * pensionPercent * loweringCoeff * selectedDistrictVal;
    double vbdBonus = isVbd ? 4184.0 : 0.0;
    double totalPension = rawPension + vbdBonus;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Военная пенсия', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Переключить тему',
            onPressed: () {
              _playClickFeedback();
              widget.onToggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Поделиться',
            onPressed: () => _sharePensionSummary(totalPension, totalBaseDds, nvlPercent, pensionPercent),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            color: isDark ? const Color(0xFF1E2638) : Colors.white,
            child: Column(
              children: [
                const Text('РАЗМЕР ВОЕННОЙ ПЕНСИИ',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 4),
                Text('${totalPension.toStringAsFixed(2)} руб./мес.',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: highlightColor)),
                const SizedBox(height: 2),
                Text('База ДД: ${totalBaseDds.toStringAsFixed(0)} руб. | ${(pensionPercent * 100).toInt()}% от ДД',
                    style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              children: [
                _buildDropdown(
                  'Воинское звание:',
                  selectedRank,
                  militaryRanks.keys.toList(),
                  (val) {
                    _playClickFeedback();
                    setState(() => selectedRank = val!);
                    StorageService.set('pension_rank', val);
                  },
                  isDark,
                ),

                _buildDropdown(
                  'Тарифный разряд:',
                  selectedTariff,
                  militaryTariffRanks.keys.toList(),
                  (val) {
                    _playClickFeedback();
                    setState(() => selectedTariff = val!);
                    StorageService.set('pension_tariff', val);
                  },
                  isDark,
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Выслуга лет (в льготном исчислении):', style: TextStyle(fontSize: 12)),
                          Text('$serviceYears лет',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Slider(
                        value: serviceYears.toDouble(),
                        min: 20,
                        max: 35,
                        divisions: 15,
                        label: '$serviceYears лет',
                        onChanged: (val) {
                          _playClickFeedback();
                          final newVal = val.toInt();
                          setState(() => serviceYears = newVal);
                          StorageService.set('pension_years', newVal);
                        },
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Районный коэффициент:',
                          style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade300 : Colors.black87)),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E2638) : const Color(0xFFE4E7ED),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade400),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<double>(
                            value: pensionDistrictOptions.contains(selectedDistrictVal) ? selectedDistrictVal : 1.0,
                            isExpanded: true,
                            itemHeight: 38.0,
                            dropdownColor: isDark ? const Color(0xFF1E2638) : Colors.white,
                            items: pensionDistrictOptions.map((k) {
                              String labelText = k == 1.0 || k == 2.0 ? k.toStringAsFixed(0) : k.toString();
                              final bool isSelected = k == selectedDistrictVal;
                              return DropdownMenuItem<double>(
                                value: k,
                                child: Container(
                                  width: double.infinity,
                                  alignment: Alignment.centerLeft,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? (isDark ? const Color(0xFF2C3854) : const Color(0xFFD0D7DE))
                                        : Colors.transparent,
                                    border: Border(
                                      bottom: BorderSide(
                                        color: isDark ? Colors.white12 : Colors.black12,
                                        width: 0.5,
                                      ),
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                                  child: Text(
                                    labelText,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? highlightColor : (isDark ? Colors.white : Colors.black87),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              _playClickFeedback();
                              final newVal = val ?? 1.0;
                              setState(() => selectedDistrictVal = newVal);
                              StorageService.set('pension_district', newVal);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2638) : const Color(0xFFE4E7ED),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: CheckboxListTile(
                    title: const Text('Ветеран боевых действий (ЕДВ / надбавка)',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    value: isVbd,
                    dense: true,
                    onChanged: (val) {
                      _playClickFeedback();
                      final newVal = val ?? false;
                      setState(() => isVbd = newVal);
                      StorageService.set('pension_vbd', newVal);
                    },
                  ),
                ),

                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Нормативы расчета пенсии (Законы № 4468-1 и № 433-ФЗ):',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isDark ? const Color(0xFF82B1FF) : const Color(0xFF1A237E))),
                        const SizedBox(height: 6),
                        const Text('• 20 лет выслуги дают 50% от окладов денежного содержания.', style: TextStyle(fontSize: 12)),
                        const Text('• За каждый год свыше 20 лет начисляется +3% (но не более 85%).', style: TextStyle(fontSize: 12)),
                        Text('• Понижающий коэффициент (№ 433-ФЗ): 93,59% (0,9359).',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
    bool isDark,
  ) {
    String effectiveValue = items.contains(value) ? value : items.first;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade300 : Colors.black87)),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2638) : const Color(0xFFE4E7ED),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade400),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: effectiveValue,
                isExpanded: true,
                itemHeight: 38.0,
                dropdownColor: isDark ? const Color(0xFF1E2638) : Colors.white,
                items: items.map((item) {
                  final bool isSelected = item == effectiveValue;
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? const Color(0xFF2C3854) : const Color(0xFFD0D7DE))
                            : Colors.transparent,
                        border: Border(
                          bottom: BorderSide(
                            color: isDark ? Colors.white12 : Colors.black12,
                            width: 0.5,
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? (isDark ? const Color(0xFFFFD54F) : const Color(0xFF1A237E))
                              : (isDark ? Colors.white : Colors.black87),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
