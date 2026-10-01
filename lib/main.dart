import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MilPayCalculatorApp());
}

class MilPayCalculatorApp extends StatelessWidget {
  const MilPayCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Денежное довольствие',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF3F51B5),
        scaffoldBackgroundColor: const Color(0xFFF2F4F7),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF3949AB),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  bool isProUser = true;

  // Четкий тактильный микро-щелчок (виброотклик тумблера)
  void _playClickFeedback() {
    HapticFeedback.mediumImpact();
  }

  // 1. Периоды окладов и коэффициенты индексации
  final Map<String, double> salaryPeriods = {
    'Оклады с 01.10.2025 г.': 1.0,
    'Оклады с 01.10.2026 г. (+4.0%)': 1.04,
  };
  String selectedPeriod = 'Оклады с 01.10.2025 г.';

  // 2. Базовая сетка окладов по воинским званиям (ОВЗ) на 01.10.2025 г.
  final Map<String, double> baseRanks = {
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

  // 3. Базовая сетка окладов по 50 тарифным разрядам на 01.10.2025 г.
  final Map<String, double> baseTariffRanks = {
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

  // Переменные состояния
  String selectedRank = 'Ефрейтор, старший матрос';
  String selectedTariff = '4 т.р.';
  String selectedFlight = 'нет';
  String selectedNvl = '25 лет и более – 40%';
  String selectedSecrecy = 'секретно - 10%';
  String selectedOuvs = '50%';
  String selectedClass = '1 класс - 20%';
  String selectedDistrict = '1.6';
  String selectedNorthern = '80% - II группа территорий';
  String selectedPremium = '25%';

  String selectedSpecialUnits = 'нет (0%)';
  String selectedOtherAchievements = '0%';

  // Чекбоксы
  bool hasContractBonus = true;
  bool isDriver = false;
  bool hasMatHelp = false;
  bool isVbd = false;

  String selectedMedals = '20% - "За разминирование", "За воинскую доблесть" I ст.';
  String selectedZgt = '0%';
  String selectedCipher = '0%';
  String selectedAlimony = '0%';
  String selectedChildDeduction = 'нет детей';

  // PRO: Контроллеры ввода
  final TextEditingController _days844Controller = TextEditingController();
  final TextEditingController _riskDaysController = TextEditingController();

  int days844 = 0;
  int riskDays = 0;

  @override
  void dispose() {
    _days844Controller.dispose();
    _riskDaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double indexCoeff = salaryPeriods[selectedPeriod] ?? 1.0;

    // Оклады с округлением в большую сторону до целого рубля
    double rawOvz = (baseRanks[selectedRank] ?? 7881.0) * indexCoeff;
    double ovz = indexCoeff == 1.0 ? rawOvz : rawOvz.ceilToDouble();

    double rawOvd = (baseTariffRanks[selectedTariff] ?? 18629.0) * indexCoeff;
    double ovd = indexCoeff == 1.0 ? rawOvd : rawOvd.ceilToDouble();

    double ods = ovz + ovd;

    // Парсинг процентов
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

    double districtCoeff = double.parse(selectedDistrict);

    double northernPercent = 0.0;
    if (selectedNorthern.contains('30%')) northernPercent = 0.30;
    if (selectedNorthern.contains('50%')) northernPercent = 0.50;
    if (selectedNorthern.contains('80%')) northernPercent = 0.80;
    if (selectedNorthern.contains('100%')) northernPercent = 1.0;

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

    double baseRkSn = ods + nvlAmount + secrecyAmount + ouvsAmount + classAmount + flightAmount;
    double rkAmount = baseRkSn * (districtCoeff - 1.0);
    double northernAmount = baseRkSn * northernPercent;

    double premiumAmount = ods * premiumPercent;
    double zgtAmount = ovd * zgtPercent;
    double cipherAmount = ovd * cipherPercent;
    double medalsAmount = ovd * medalsPercent;
    double matHelpAmount = hasMatHelp ? ods : 0.0;

    int extraRestDays = (days844 ~/ 3) * 2;
    double comp844Amount = (ods / 30.0) * extraRestDays;

    double riskPercent = (riskDays * 0.02).clamp(0.0, 0.60);
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Денежное довольствие...'),
        actions: [
          IconButton(
            icon: Icon(isProUser ? Icons.star : Icons.star_border, color: Colors.amber),
            onPressed: () {
              _playClickFeedback();
              setState(() => isProUser = !isProUser);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(isProUser ? 'PRO-режим включен' : 'PRO-режим отключен')),
              );
            },
          ),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            color: Colors.white,
            child: Column(
              children: [
                Text('Начислено: ${totalGross.toStringAsFixed(2)} рублей',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Удержано: ${totalHold.toStringAsFixed(2)} рублей',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('На руки: ${netPay.toStringAsFixed(2)} рублей.',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _buildPeriodSelector(),

                _buildDropdownItem(
                  'Воинское звание: ${ovz.toStringAsFixed(0)} руб.',
                  selectedRank,
                  baseRanks.keys.toList(),
                  (val) {
                    _playClickFeedback();
                    setState(() => selectedRank = val!);
                  },
                ),

                _buildDropdownItem(
                  'Тарифный разряд: ${ovd.toStringAsFixed(0)} руб.',
                  selectedTariff,
                  baseTariffRanks.keys.toList(),
                  (val) {
                    _playClickFeedback();
                    setState(() => selectedTariff = val!);
                  },
                ),

                _buildDropdownItem(
                  'Надбавка за летный состав: ${flightAmount > 0 ? "+${flightAmount.toStringAsFixed(1)} руб." : "0.0 руб."}',
                  selectedFlight,
                  ['нет', '40% - 3 класс', '50% - 2 класс', '60% - 1 класс', '70% - снайпер'],
                  (val) {
                    _playClickFeedback();
                    setState(() => selectedFlight = val!);
                  },
                ),

                _buildDropdownItem(
                  'Выслуга лет: +${nvlAmount.toStringAsFixed(1)} руб.',
                  selectedNvl,
                  [
                    'до 2 лет – 0%',
                    'от 2 до 5 лет – 10%',
                    'от 5 до 10 лет – 15%',
                    'от 10 до 15 лет – 20%',
                    'от 15 до 20 лет – 25%',
                    'от 20 до 25 лет – 30%',
                    '25 лет и более – 40%'
                  ],
                  (val) {
                    _playClickFeedback();
                    setState(() => selectedNvl = val!);
                  },
                ),

                _buildDropdownItem(
                  'Надбавка за допуск к сведениям, составляющим гос. тайну:',
                  selectedSecrecy,
                  ['нет - 0%', 'секретно - 10%', 'сов. секретно - 20%', 'особая важность - 25%'],
                  (val) {
                    _playClickFeedback();
                    setState(() => selectedSecrecy = val!);
                  },
                ),

                _buildDropdownItem(
                  'Надбавка за особые условия службы: +${ouvsAmount.toStringAsFixed(1)} руб.',
                  selectedOuvs,
                  ['0%', '10%', '20%', '30%', '50%', '70%', '100%'],
                  (val) {
                    _playClickFeedback();
                    setState(() => selectedOuvs = val!);
                  },
                ),

                _buildDropdownItem(
                  'Надбавка за классную квалификацию: +${classAmount.toStringAsFixed(1)} руб.',
                  selectedClass,
                  ['без класса - 0%', '3 класс - 5%', '2 класс - 10%', '1 класс - 20%', 'мастер - 30%'],
                  (val) {
                    _playClickFeedback();
                    setState(() => selectedClass = val!);
                  },
                ),

                _buildDropdownItem(
                  'Районный коэффициент: ${rkAmount > 0 ? "+${rkAmount.toStringAsFixed(1)} руб." : "0.0 руб."}',
                  selectedDistrict,
                  ['1.0', '1.15', '1.2', '1.25', '1.3', '1.4', '1.5', '1.6', '2.0'],
                  (val) {
                    _playClickFeedback();
                    setState(() => districtCoeff = double.parse(val!));
                  },
                ),

                _buildDropdownItem(
                  'Северная надбавка: ${northernAmount > 0 ? "+${northernAmount.toStringAsFixed(1)} руб." : "0.0 руб."}',
                  selectedNorthern,
                  [
                    '0% - нет надбавки',
                    '30% - IV группа',
                    '50% - III группа',
                    '80% - II группа территорий',
                    '100% - I группа территорий'
                  ],
                  (val) {
                    _playClickFeedback();
                    setState(() => selectedNorthern = val!);
                  },
                ),

                _buildDropdownItem(
                  'Ежемесячная премия: ${premiumAmount > 0 ? "+${premiumAmount.toStringAsFixed(1)} руб." : "0.0 руб."}',
                  selectedPremium,
                  List.generate(26, (i) => '$i%'),
                  (val) {
                    _playClickFeedback();
                    setState(() => selectedPremium = val!);
                  },
                ),

                _buildDropdownItem(
                  'Надбавка подразделениям (ВКС, ВМФ, РВСН, ГУ ГШ): ${specialUnitsAmount > 0 ? "+${specialUnitsAmount.toStringAsFixed(1)} руб." : "0.0 руб."}',
                  selectedSpecialUnits,
                  ['нет (0%)', '100% от ОВД', '110% от ОВД', '120% от ОВД'],
                  (val) {
                    _playClickFeedback();
                    setState(() => selectedSpecialUnits = val!);
                  },
                ),

                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECEFF1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.blueGrey.shade200),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Надбавка в размерах 100% / 110% / 120% от ОВД положена только контрактникам, проходящим службу в следующих подразделениях и составах:',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      SizedBox(height: 4),
                      Text('1. Летный состав Воздушно-космических сил (ВКС)', style: TextStyle(fontSize: 11)),
                      Text('2. Плавсостав Военно-морского флота (ВМФ) — экипажи боевых кораблей, судов и катеров.', style: TextStyle(fontSize: 11)),
                      Text('3. Ракетные войска стратегического назначения (РВСН).', style: TextStyle(fontSize: 11)),
                      Text('4. Главное управление Генерального штаба (ГУ ГШ).', style: TextStyle(fontSize: 11)),
                    ],
                  ),
                ),

                _buildDropdownItem(
                  'Прочие достижения: ${otherAchievementsAmount > 0 ? "+${otherAchievementsAmount.toStringAsFixed(1)} руб." : "0.0 руб."}',
                  selectedOtherAchievements,
                  [
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
                  (val) {
                    _playClickFeedback();
                    setState(() => selectedOtherAchievements = val!);
                  },
                ),

                _buildCheckboxTile(
                  'Надбавка за особые достижения (- контракт 1-4 т.р.): ${(ovd * 0.50).toStringAsFixed(1)} рублей',
                  hasContractBonus,
                  (val) {
                    _playClickFeedback();
                    setState(() => hasContractBonus = val ?? false);
                  },
                ),

                _buildCheckboxTile(
                  'На должности водителя (30% от ОВД): ${(ovd * 0.30).toStringAsFixed(1)} рублей',
                  isDriver,
                  (val) {
                    _playClickFeedback();
                    setState(() => isDriver = val ?? false);
                  },
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
                  },
                ),

                _buildDropdownItem(
                  'Надбавка за работу в структурных подразделениях по ЗГТ:',
                  selectedZgt,
                  ['0%', '10% - от 1 до 5 лет', '15% - от 5 до 10 лет', '20% - от 10 лет и выше'],
                  (val) {
                    _playClickFeedback();
                    setState(() => selectedZgt = val!);
                  },
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
                  },
                ),

                _buildDropdownItem(
                  'Алименты:',
                  selectedAlimony,
                  ['0%', '25% - на одного ребенка', '33% - на двух детей', '50% - на трех и более'],
                  (val) {
                    _playClickFeedback();
                    setState(() => selectedAlimony = val!);
                  },
                ),

                _buildCheckboxTile(
                  'Материальная помощь: ${ods.toStringAsFixed(1)} рублей',
                  hasMatHelp,
                  (val) {
                    _playClickFeedback();
                    setState(() => hasMatHelp = val ?? false);
                  },
                ),

                _buildCheckboxTile(
                  'Ветеран боевых действий (ст.218 п.1. пп.2 – 500 рублей)',
                  isVbd,
                  (val) {
                    _playClickFeedback();
                    setState(() => isVbd = val ?? false);
                  },
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
                  },
                ),

                const SizedBox(height: 14),
                const Center(
                  child: Text('PRO ФУНКЦИОНАЛ (ПОДПИСКА)',
                      style: TextStyle(color: Color(0xFF3949AB), fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                ),
                const SizedBox(height: 8),

                _buildProCard(
                  title: 'Приказ МО РФ № 844 (дополнительные сутки отдыха)',
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
                                setState(() {
                                  days844 = int.tryParse(val) ?? 0;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Положено суток отдыха: $extraRestDays дн. | Компенсация: ${comp844Amount.toStringAsFixed(2)} руб.',
                        style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                _buildProCard(
                  title: 'Риск для жизни (Приказ МО РФ № 727, 2% в день, макс 60%)',
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
                                setState(() {
                                  riskDays = int.tryParse(val) ?? 0;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Надбавка: ${(riskPercent * 100).toInt()}% от ОВД | Сумма: ${riskAmount.toStringAsFixed(2)} руб.',
                        style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.bold),
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

  Widget _buildPeriodSelector() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFD6DBE4),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade500),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedPeriod,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black87),
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13),
          items: salaryPeriods.keys.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
          onChanged: (val) {
            _playClickFeedback();
            setState(() {
              selectedPeriod = val!;
            });
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
  ) {
    String effectiveValue = items.contains(value) ? value : items.first;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black87)),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE4E7ED),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: effectiveValue,
                isExpanded: true,
                items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, overflow: TextOverflow.ellipsis))).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxTile(String label, bool value, ValueChanged<bool?> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE4E7ED),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: CheckboxListTile(
        title: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        value: value,
        dense: true,
        controlAffinity: ListTileControlAffinity.leading,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildProCard({required String title, required Widget child}) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.amber.shade700, borderRadius: BorderRadius.circular(4)),
                  child: const Text('PRO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}
