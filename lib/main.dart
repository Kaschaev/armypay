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
  // Флаг PRO подписки
  bool isProUser = true;

  // 1. Полная актуальная сетка окладов по воинским званиям (ОВЗ)
  final Map<String, double> ranks = {
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

  // 2. Полная сетка окладов по 50 тарифным разрядам (ОВД)
  final Map<String, double> tariffRanks = {
    '1 т.р. - Стрелок, водитель, курсант': 14331.0,
    '2 т.р. - Пулемётчик, снайпер, сапёр': 15761.0,
    '3 т.р. - Старший сапёр, командир расчёта': 17196.0,
    '4 т.р. - Командир танка, техник': 18629.0,
    '5 т.р. - Командир отделения': 21494.0,
    '6 т.р. - Фельдшер, старший техник роты': 22929.0,
    '7 т.р. - Заместитель командира взвода': 24359.0,
    '8 т.р. - Старшина роты, батареи': 25794.0,
    '9 т.р. - Начальник инспекции': 27226.0,
    '10 т.р. - Командир взвода': 28656.0,
    '11 т.р. - Заместитель командира роты': 29374.0,
    '12 т.р. - Старший инженер полка': 30090.0,
    '13 т.р. - Помощник начальника службы полка': 30806.0,
    '14 т.р. - Командир роты, командир батареи': 31521.0,
    '15 т.р. - Помощник командира полка': 32237.0,
    '16 т.р. - Заместитель командира батальона': 32954.0,
    '17 т.р. - Начальник штаба батальона': 33671.0,
    '18 т.р. - Командир батальона, дивизиона': 34388.0,
    '19 т.р. - Начальник штаба полка': 35103.0,
    '20 т.р. - Заместитель командира полка': 35819.0,
    '21 т.р. - Начальник службы бригады': 36536.0,
    '22 т.р. - Заместитель командира бригады': 37252.0,
    '23 т.р. - Командир полка': 37968.0,
    '24 т.р. - Начальник отдела армии': 38684.0,
    '25 т.р. - Начальник службы управления округа': 39400.0,
    '26 т.р. - Заместитель командира дивизии': 40117.0,
    '27 т.р. - Начальник штаба дивизии': 41072.0,
    '28 т.р. - Заместитель командира корпуса': 42028.0,
    '29 т.р. - Командир дивизии': 42983.0,
    '30 т.р. - Зам. начальника управления округа': 44416.0,
    '31 т.р. - Начальник управления армии': 45849.0,
    '32 т.р. - Зам. командира армейского корпуса': 47282.0,
    '33 т.р. - Начальник штаба армейского корпуса': 48715.0,
    '34 т.р. - Начальник управления военного округа': 50149.0,
    '35 т.р. - Командир армейского корпуса': 51582.0,
    '36 т.р. - Зам. командующего армией': 52300.0,
    '37 т.р. - Начальник штаба армии': 53015.0,
    '38 т.р. - Командующий общевойсковой армией': 53732.0,
    '39 т.р. - Зам. командующего войсками округа': 54448.0,
    '40 т.р. - Начальник штаба округа': 55165.0,
    '41 т.р. - Командующий войсками округа, главк МО': 55881.0,
    '42 т.р. - Начальник Главного управления МО РФ': 56597.0,
    '43 т.р. - Зам. главнокомандующего видом ВС': 57314.0,
    '44 т.р. - Командующий родом войск (ВДВ, РВСН)': 58031.0,
    '45 т.р. - Заместитель начальника ГШ ВС РФ': 58747.0,
    '46 т.р. - Заместитель Министра обороны РФ': 59463.0,
    '47 т.р. - Начальник НЦУО РФ': 60179.0,
    '48 т.р. - Первый зам. начальника ГШ ВС РФ': 60896.0,
    '49 т.р. - Первый заместитель Министра обороны': 63039.0,
    '50 т.р. - Первый зам. Министра обороны (высшая)': 64473.0,
  };

  // Выбранные параметры по умолчанию
  String selectedRank = 'Ефрейтор, старший матрос';
  String selectedTariff = '4 т.р. - Командир танка, техник';

  // Надбавки
  double flightBonusPercent = 0.0;
  double nvlPercent = 0.40; // 25 лет и более – 40%
  double secrecyPercent = 0.10; // 3 форма – 10%
  double ouvsPercent = 0.50; // ОУВС 50%
  double classPercent = 0.20; // 1 класс – 20%
  double districtCoeff = 1.6; // Районный коэффициент 1.6
  double northernPercent = 0.80; // Северная надбавка 80%
  double premiumPercent = 0.25; // Премия 25%

  // Специфические надбавки
  double contractBonusPercent = 0.50; // Контракт 1-4 т.р.
  double zgtPercent = 0.0; // ПЗГТ
  double cipherPercent = 0.0; // Шифры
  double medalsPercent = 0.20; // Медали МО РФ
  bool hasMatHelp = false;

  // Налоги и вычеты
  bool isVbd = false;
  double childDeduction = 0.0;
  double alimonyPercent = 0.0;

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
    // 1. Базовые оклады
    double ovz = ranks[selectedRank] ?? 7881.0;
    double ovd = tariffRanks[selectedTariff] ?? 18629.0;
    double ods = ovz + ovd;

    // 2. Расчет базовых надбавок
    double nvlAmount = ods * nvlPercent;
    double secrecyAmount = ovd * secrecyPercent;
    double ouvsAmount = ovd * ouvsPercent;
    double classAmount = ovd * classPercent;
    double flightAmount = ovd * flightBonusPercent;

    // 3. База для РК и СН (ОВД + ОВЗ + Выслуга + Класс + Гостайна + ОУВС)
    double baseRkSn = ods + nvlAmount + secrecyAmount + ouvsAmount + classAmount + flightAmount;
    double rkAmount = baseRkSn * (districtCoeff - 1.0);
    double northernAmount = baseRkSn * northernPercent;

    // 4. Прочие надбавки
    double premiumAmount = ods * premiumPercent;
    double contractAmount = ovd * contractBonusPercent;
    double zgtAmount = ovd * zgtPercent;
    double cipherAmount = ovd * cipherPercent;
    double medalsAmount = ovd * medalsPercent;
    double matHelpAmount = hasMatHelp ? ods : 0.0;

    // 5. PRO-расчеты
    int extraRestDays = (days844 ~/ 3) * 2;
    double comp844Amount = (ods / 30.0) * extraRestDays;

    double riskPercent = (riskDays * 0.02).clamp(0.0, 0.60);
    double riskAmount = ovd * riskPercent;

    // 6. Итого начислено
    double totalGross = baseRkSn +
        rkAmount +
        northernAmount +
        premiumAmount +
        contractAmount +
        zgtAmount +
        cipherAmount +
        medalsAmount +
        matHelpAmount +
        comp844Amount +
        riskAmount;

    // 7. Налоговые вычеты и НДФЛ 13%
    double totalDeductions = (isVbd ? 500.0 : 0.0) + childDeduction;
    double taxableBase = (totalGross - totalDeductions).clamp(0.0, double.infinity);
    double ndfl = (taxableBase * 0.13).roundToDouble();

    // 8. Алименты и расчет на руки
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
          // Фиксированная шапка результатов
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

          // Поля калькулятора
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _buildInfoBadge('оклады на 2026 г.'),

                // Воинское звание
                _buildDropdownItem('Воинское звание:', selectedRank, ranks.keys.toList(), (val) {
                  setState(() => selectedRank = val!);
                }),

                // Тарифный разряд
                _buildDropdownItem('Тарифный разряд:', selectedTariff, tariffRanks.keys.toList(), (val) {
                  setState(() => selectedTariff = val!);
                }),

                // Летный состав
                _buildDropdownItem(
                  'Надбавка за квалификационную категорию летного состава:',
                  flightBonusPercent == 0.0 ? 'нет' : '${(flightBonusPercent * 100).toInt()}%',
                  ['нет', '40% - 3 класс', '50% - 2 класс', '60% - 1 класс', '70% - снайпер'],
                  (val) {
                    setState(() {
                      if (val == 'нет') flightBonusPercent = 0.0;
                      if (val!.startsWith('40%')) flightBonusPercent = 0.40;
                      if (val.startsWith('50%')) flightBonusPercent = 0.50;
                      if (val.startsWith('60%')) flightBonusPercent = 0.60;
                      if (val.startsWith('70%')) flightBonusPercent = 0.70;
                    });
                  },
                ),

                // Выслуга лет
                _buildDropdownItem(
                  'Выслуга лет:',
                  nvlPercent == 0.40 ? '25 лет и более – 40%' : '${(nvlPercent * 100).toInt()}%',
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
                    setState(() {
                      if (val!.contains('0%')) nvlPercent = 0.0;
                      if (val.contains('10%')) nvlPercent = 0.10;
                      if (val.contains('15%')) nvlPercent = 0.15;
                      if (val.contains('20%')) nvlPercent = 0.20;
                      if (val.contains('25%')) nvlPercent = 0.25;
                      if (val.contains('30%')) nvlPercent = 0.30;
                      if (val.contains('40%')) nvlPercent = 0.40;
                    });
                  },
                ),

                // Допуск к гостайне
                _buildDropdownItem(
                  'Надбавка за допуск к сведениям, составляющим гос. тайну:',
                  secrecyPercent == 0.10 ? 'секретно - 10%' : '${(secrecyPercent * 100).toInt()}%',
                  ['нет - 0%', 'секретно - 10%', 'сов. секретно - 20%', 'особая важность - 25%'],
                  (val) {
                    setState(() {
                      if (val!.contains('0%')) secrecyPercent = 0.0;
                      if (val.contains('10%')) secrecyPercent = 0.10;
                      if (val.contains('20%')) secrecyPercent = 0.20;
                      if (val.contains('25%')) secrecyPercent = 0.25;
                    });
                  },
                ),

                // ОУВС
                _buildDropdownItem(
                  'Надбавка за особые условия службы:',
                  '${(ouvsPercent * 100).toInt()}%',
                  ['0%', '10%', '20%', '30%', '50%', '70%', '100%'],
                  (val) => setState(() => ouvsPercent = double.parse(val!.replaceAll('%', '')) / 100),
                ),

                // Классная квалификация
                _buildDropdownItem(
                  'Надбавка за классную квалификацию:',
                  classPercent == 0.20 ? '1 класс - 20%' : '${(classPercent * 100).toInt()}%',
                  ['без класса - 0%', '3 класс - 5%', '2 класс - 10%', '1 класс - 20%', 'мастер - 30%'],
                  (val) {
                    setState(() {
                      if (val!.contains('0%')) classPercent = 0.0;
                      if (val.contains('5%')) classPercent = 0.05;
                      if (val.contains('10%')) classPercent = 0.10;
                      if (val.contains('20%')) classPercent = 0.20;
                      if (val.contains('30%')) classPercent = 0.30;
                    });
                  },
                ),

                // Районный коэффициент
                _buildDropdownItem(
                  'Районный коэффициент:',
                  districtCoeff.toString(),
                  ['1.0', '1.15', '1.2', '1.25', '1.3', '1.4', '1.5', '1.6', '2.0'],
                  (val) => setState(() => districtCoeff = double.parse(val!)),
                ),

                // Северная надбавка
                _buildDropdownItem(
                  'Северная надбавка:',
                  northernPercent == 0.80 ? '80% - II группа территорий' : '${(northernPercent * 100).toInt()}%',
                  [
                    '0% - нет надбавки',
                    '30% - IV группа',
                    '50% - III группа',
                    '80% - II группа территорий',
                    '100% - I группа территорий'
                  ],
                  (val) {
                    setState(() {
                      if (val!.contains('0%')) northernPercent = 0.0;
                      if (val.contains('30%')) northernPercent = 0.30;
                      if (val.contains('50%')) northernPercent = 0.50;
                      if (val.contains('80%')) northernPercent = 0.80;
                      if (val.contains('100%')) northernPercent = 1.0;
                    });
                  },
                ),

                // Премия
                _buildDropdownItem(
                  'Ежемесячная премия:',
                  '${(premiumPercent * 100).toInt()}%',
                  ['0%', '10%', '15%', '20%', '25%'],
                  (val) => setState(() => premiumPercent = double.parse(val!.replaceAll('%', '')) / 100),
                ),

                // Особые достижения (1-4 т.р.)
                _buildDropdownItem(
                  'Надбавка за особые достижения (- контракт 1-4 т.р.):',
                  '${(contractBonusPercent * 100).toInt()}%',
                  ['0%', '50%'],
                  (val) => setState(() => contractBonusPercent = double.parse(val!.replaceAll('%', '')) / 100),
                ),

                // Знаки отличия МО РФ
                _buildDropdownItem(
                  'Ежемесячная надбавка при награждении знаками отличия МО РФ:',
                  medalsPercent == 0.20
                      ? '20% - "За разминирование", "За воинскую доблесть" I ст.'
                      : '${(medalsPercent * 100).toInt()}%',
                  [
                    'нет надбавки - 0%',
                    '10% - "За воинскую доблесть" II степени',
                    '20% - "За разминирование", "За воинскую доблесть" I ст.',
                    '30% - "За боевые отличия"'
                  ],
                  (val) {
                    setState(() {
                      if (val!.contains('0%')) medalsPercent = 0.0;
                      if (val.contains('10%')) medalsPercent = 0.10;
                      if (val.contains('20%')) medalsPercent = 0.20;
                      if (val.contains('30%')) medalsPercent = 0.30;
                    });
                  },
                ),

                // Подразделения по ЗГТ
                _buildDropdownItem(
                  'Надбавка за работу в структурных подразделениях по ЗГТ:',
                  zgtPercent == 0.0 ? '0%' : '${(zgtPercent * 100).toInt()}%',
                  ['0%', '10% - от 1 до 5 лет', '15% - от 5 до 10 лет', '20% - от 10 лет и выше'],
                  (val) {
                    setState(() {
                      if (val!.contains('0%')) zgtPercent = 0.0;
                      if (val.contains('10%')) zgtPercent = 0.10;
                      if (val.contains('15%')) zgtPercent = 0.15;
                      if (val.contains('20%')) zgtPercent = 0.20;
                    });
                  },
                ),

                // Работа с шифрами
                _buildDropdownItem(
                  'Надбавка за работу с шифрами:',
                  cipherPercent == 0.0 ? '0%' : '${(cipherPercent * 100).toInt()}%',
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
                    setState(() {
                      if (val!.contains('0%')) cipherPercent = 0.0;
                      if (val.contains('5%')) cipherPercent = 0.05;
                      if (val.contains('10%')) cipherPercent = 0.10;
                      if (val.contains('15%')) cipherPercent = 0.15;
                      if (val.contains('20%')) cipherPercent = 0.20;
                      if (val.contains('30%')) cipherPercent = 0.30;
                    });
                  },
                ),

                // Алименты
                _buildDropdownItem(
                  'Алименты:',
                  alimonyPercent == 0.0 ? '0%' : '${(alimonyPercent * 100).toInt()}%',
                  ['0%', '25% - на одного ребенка', '33% - на двух детей', '50% - на трех и более'],
                  (val) {
                    setState(() {
                      if (val!.contains('0%')) alimonyPercent = 0.0;
                      if (val.contains('25%')) alimonyPercent = 0.25;
                      if (val.contains('33%')) alimonyPercent = 0.3333;
                      if (val.contains('50%')) alimonyPercent = 0.50;
                    });
                  },
                ),

                // Материальная помощь
                _buildCheckboxTile(
                  'Материальная помощь: ${ods.toStringAsFixed(1)} рублей',
                  hasMatHelp,
                  (val) => setState(() => hasMatHelp = val ?? false),
                ),

                // Ветеран боевых действий
                _buildCheckboxTile(
                  'Ветеран боевых действий (ст.218 п.1. пп.2 – 500 рублей)',
                  isVbd,
                  (val) => setState(() => isVbd = val ?? false),
                ),

                // Налоговый вычет на детей
                _buildDropdownItem(
                  'Налоговый вычет на несовершеннолетних детей (ст. 218 п.1 пп. 4):',
                  childDeduction == 0.0 ? 'нет детей' : '${childDeduction.toInt()} руб.',
                  [
                    'нет детей',
                    '1 ребенок - 1400 руб.',
                    '2 ребенка - 2800 руб.',
                    '3 ребенка - 5800 руб.',
                    '4 ребенка - 8800 руб.'
                  ],
                  (val) {
                    setState(() {
                      if (val!.contains('нет')) childDeduction = 0.0;
                      if (val.contains('1400')) childDeduction = 1400.0;
                      if (val.contains('2800')) childDeduction = 2800.0;
                      if (val.contains('5800')) childDeduction = 5800.0;
                      if (val.contains('8800')) childDeduction = 8800.0;
                    });
                  },
                ),

                const SizedBox(height: 14),
                const Center(
                  child: Text('PRO ФУНКЦИОНАЛ (ПОДПИСКА)',
                      style: TextStyle(color: Color(0xFF3949AB), fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                ),
                const SizedBox(height: 8),

                // PRO Блок 1: Приказ 844
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

                // PRO Блок 2: Приказ 727 (Риск для жизни)
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
                                hintText: '0',
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

  Widget _buildInfoBadge(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFD6DBE4),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Center(
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildDropdownItem(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
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
                value: items.contains(value) ? value : items.first,
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
