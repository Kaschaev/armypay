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
                        color: isDark ? Colors.amberAccent : Colors.black)),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _buildPeriodSelector(isDark),

                _buildDropdownItem(
                  'Воинское звание: ${ovz.toStringAsFixed(0)} руб.',
                  selectedRank,
                  militaryRanks.keys.toList(),
                  (val) {
                    _playClickFeedback();
                    setState(() => selectedRank = val!);
                  },
                  isDark,
                ),

                _buildDropdownItem(
                  'Тарифный разряд: ${ovd.toStringAsFixed(0)} руб.',
                  selectedTariff,
                  militaryTariffRanks.keys.toList(),
                  (val) {
                    _playClickFeedback();
                    setState(() => selectedTariff = val!);
                  },
                  isDark,
                ),

                _buildDropdownItem(
                  'Надбавка за летный состав: ${flightAmount > 0 ? "+${flightAmount.toStringAsFixed(1)} руб." : "0.0 руб."}',
                  selectedFlight,
                  ['нет', '40% - 3 класс', '50% - 2 класс', '60% - 1 класс', '70% - снайпер'],
                  (val) {
                    _playClickFeedback();
                    setState(() => selectedFlight = val!);
                  },
                  isDark,
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
                  isDark,
                ),

                _buildDropdownItem(
                  'Надбавка за допуск к сведениям, составляющим гос. тайну:',
                  selectedSecrecy,
                  ['нет - 0%', 'секретно - 10%', 'сов. секретно - 20%', 'особая важность - 25%'],
                  (val) {
                    _playClickFeedback();
                    setState(() => selectedSecrecy = val!);
                  },
                  isDark,
                ),

                _buildDropdownItem(
                  'Надбавка за особые условия службы: +${ouvsAmount.toStringAsFixed(1)} руб.',
                  selectedOuvs,
                  ['0%', '10%', '20%', '30%', '50%', '70%', '100%'],
                  (val) {
                    _playClickFeedback();
                    setState(() => selectedOuvs = val!);
                  },
                  isDark,
                ),

                _buildDropdownItem(
                  'Надбавка за классную квалификацию: +${classAmount.toStringAsFixed(1)} руб.',
                  selectedClass,
                  ['без класса - 0%', '3 класс - 5%', '2 класс - 10%', '1 класс - 20%', 'мастер - 30%'],
                  (val) {
                    _playClickFeedback();
                    setState(() => selectedClass = val!);
                  },
                  isDark,
                ),

                // ---------------- НАДБАВКА ЗА БОЕВОЕ ДЕЖУРСТВО С ОБНОВЛЕННЫМИ СТРОКАМИ ----------------
                _buildCardSection(
                  title: 'Надбавка за боевое дежурство (от ОВД): ${combatDutyAmount > 0 ? "+${combatDutyAmount.toStringAsFixed(1)} руб." : "0.0 руб."}',
                  isDark: isDark,
                  child: Column(
                    children: [
                      _buildRadioOptionTile(
                        title: '5 и более суток в месяц — 30%',
                        amount: ovd * 0.30,
                        isSelected: combatDutyPercent == 0.30,
                        onTap: () {
                          _playClickFeedback();
                          setState(() {
                            combatDutyPercent = combatDutyPercent == 0.30 ? 0.0 : 0.30;
                          });
                        },
                        isDark: isDark,
                      ),
                      const SizedBox(height: 4),
                      _buildRadioOptionTile(
                        title: 'от 3 до 4 суток в месяц — 15%',
                        amount: ovd * 0.15,
                        isSelected: combatDutyPercent == 0.15,
                        onTap: () {
                          _playClickFeedback();
                          setState(() {
                            combatDutyPercent = combatDutyPercent == 0.15 ? 0.0 : 0.15;
                          });
                        },
                        isDark: isDark,
                      ),
                      const SizedBox(height: 4),
                      _buildRadioOptionTile(
                        title: 'от 1 до 2 суток в месяц — 5%',
                        amount: ovd * 0.05,
                        isSelected: combatDutyPercent == 0.05,
                        onTap: () {
                          _playClickFeedback();
                          setState(() {
                            combatDutyPercent = combatDutyPercent == 0.05 ? 0.0 : 0.05;
                          });
                        },
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                // ---------------- РАЙОННЫЙ КОЭФФИЦИЕНТ ----------------
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Районный коэффициент: ${rkAmount > 0 ? "+${rkAmount.toStringAsFixed(2)} руб." : "0.0 руб."}',
                        style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey.shade300 : Colors.black87),
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
                            dropdownColor: isDark ? const Color(0xFF1E2638) : Colors.white,
                            items: districtOptions.map((k) {
                              double sum = baseRkSn * (k - 1.0);
                              String labelText = k == 1.0 || k == 2.0 ? k.toStringAsFixed(0) : k.toString();
                              return DropdownMenuItem<double>(
                                value: k,
                                child: Text(
                                  '$labelText – ${sum.toStringAsFixed(2)} руб.',
                                  style: const TextStyle(fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              _playClickFeedback();
                              setState(() => selectedDistrictVal = val ?? 1.0);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ---------------- СЕВЕРНАЯ НАДБАВКА ----------------
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Северная надбавка: ${northernAmount > 0 ? "+${northernAmount.toStringAsFixed(2)} руб." : "0.0 руб."}',
                        style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey.shade300 : Colors.black87),
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
                            dropdownColor: isDark ? const Color(0xFF1E2638) : Colors.white,
                            items: northernOptions.map((opt) {
                              double p = opt['val'] as double;
                              double sum = baseRkSn * p;
                              String label = opt['label'] as String;
                              return DropdownMenuItem<double>(
                                value: p,
                                child: Text(
                                  '$label – ${sum.toStringAsFixed(2)} руб.',
                                  style: const TextStyle(fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              _playClickFeedback();
                              setState(() => selectedNorthernVal = val ?? 0.0);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                _buildDropdownItem(
                  'Ежемесячная премия: ${premiumAmount > 0 ? "+${premiumAmount.toStringAsFixed(1)} руб." : "0.0 руб."}',
                  selectedPremium,
                  List.generate(26, (i) => '$i%'),
                  (val) {
                    _playClickFeedback();
                    setState(() => selectedPremium = val!);
                  },
                  isDark,
                ),

                _buildDropdownItem(
                  'Надбавка подразделениям (ВКС, ВМФ, РВСН, ГУ ГШ): ${specialUnitsAmount > 0 ? "+${specialUnitsAmount.toStringAsFixed(1)} руб." : "0.0 руб."}',
                  selectedSpecialUnits,
                  [
                    'нет (0%)',
                    '100% от ОВД - офицерам',
                    '110% от ОВД - мичманы, прапорщики',
                    '120% от ОВД - матросы, старшины',
                  ],
                  (val) {
                    _playClickFeedback();
                    setState(() => selectedSpecialUnits = val!);
                  },
                  isDark,
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
                  isDark,
                ),

                _buildCheckboxTile(
                  'Надбавка за особые достижения (- контракт 1-4 т.р.): ${(ovd * 0.50).toStringAsFixed(1)} рублей',
                  hasContractBonus,
                  (val) {
                    _playClickFeedback();
                    setState(() => hasContractBonus = val ?? false);
                  },
                  isDark,
                ),

                _buildCheckboxTile(
                  'На должности водителя (30% от ОВД): ${(ovd * 0.30).toStringAsFixed(1)} рублей',
                  isDriver,
                  (val) {
                    _playClickFeedback();
                    setState(() => isDriver = val ?? false);
                  },
                  isDark,
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
                  isDark,
                ),

                _buildDropdownItem(
                  'Надбавка за работу в структурных подразделениях по ЗГТ:',
                  selectedZgt,
                  ['0%', '10% - от 1 до 5 лет', '15% - от 5 до 10 лет', '20% - от 10 лет и выше'],
                  (val) {
                    _playClickFeedback();
                    setState(() => selectedZgt = val!);
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
                  },
                  isDark,
                ),

                _buildCheckboxTile(
                  'Материальная помощь: ${ods.toStringAsFixed(1)} рублей',
                  hasMatHelp,
                  (val) {
                    _playClickFeedback();
                    setState(() => hasMatHelp = val ?? false);
                  },
                  isDark,
                ),

                _buildCheckboxTile(
                  'Ветеран боевых действий (ст.218 п.1. пп.2 – 500 рублей)',
                  isVbd,
                  (val) {
                    _playClickFeedback();
                    setState(() => isVbd = val ?? false);
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
                        style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.lightBlueAccent : Colors.blueGrey,
                            fontWeight: FontWeight.bold),
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
                        style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.lightBlueAccent : Colors.blueGrey,
                            fontWeight: FontWeight.bold),
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

  Widget _buildRadioOptionTile({
    required String title,
    required double amount,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
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
                color: isSelected
                    ? (isDark ? Colors.amberAccent : const Color(0xFF1A237E))
                    : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
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
                dropdownColor: isDark ? const Color(0xFF1E2638) : Colors.white,
                items: items
                    .map((item) => DropdownMenuItem(
                        value: item,
                        child: Text(item, overflow: TextOverflow.ellipsis)))
                    .toList(),
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
                        color: isDark ? Colors.amberAccent : const Color(0xFF1A237E))),
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
                          setState(() => serviceYears = val.toInt());
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
                            dropdownColor: isDark ? const Color(0xFF1E2638) : Colors.white,
                            items: pensionDistrictOptions.map((k) {
                              String labelText = k == 1.0 || k == 2.0 ? k.toStringAsFixed(0) : k.toString();
                              return DropdownMenuItem<double>(
                                value: k,
                                child: Text(labelText),
                              );
                            }).toList(),
                            onChanged: (val) {
                              _playClickFeedback();
                              setState(() => selectedDistrictVal = val ?? 1.0);
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
                      setState(() => isVbd = val ?? false);
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
                value: value,
                isExpanded: true,
                dropdownColor: isDark ? const Color(0xFF1E2638) : Colors.white,
                items: items
                    .map((item) => DropdownMenuItem(value: item, child: Text(item, overflow: TextOverflow.ellipsis)))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
