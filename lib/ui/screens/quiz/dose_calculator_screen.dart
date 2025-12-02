import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterquiz/models/dose_data.dart';
import 'package:flutterquiz/models/trade_data.dart';
import 'package:flutterquiz/services/dose_calculator_service.dart';
import 'package:flutterquiz/ui/widgets/circular_progress_container.dart';
import 'package:flutterquiz/ui/widgets/custom_appbar.dart';
import 'package:flutterquiz/ui/widgets/error_container.dart';

class DoseCalculatorScreen extends StatefulWidget {
  static const String routeName = '/doseCalculator';

  const DoseCalculatorScreen({Key? key}) : super(key: key);

  @override
  State<DoseCalculatorScreen> createState() => _DoseCalculatorScreenState();
}

class _DoseCalculatorScreenState extends State<DoseCalculatorScreen> {
  final DoseCalculatorService _service = DoseCalculatorService();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _yearsController = TextEditingController();
  final TextEditingController _monthsController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  String _searchFilter = 'Trade Name';
  List<DoseData> _allDoseData = [];
  List<DoseData> _filteredDoseData = [];
  DoseData? _selectedDrug;
  List<Map<String, dynamic>> _calculationResults = [];
  bool _isCalculating = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      if (!_service.hasLocalData()) {
        await _service.fetchAndStoreAllData();
      }
      _allDoseData = _service.getAllDoseData();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Failed to load data: ${e.toString()}';
      });
    }
  }

  void _filterDrugs(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredDoseData = [];
      });
      return;
    }

    setState(() {
      _filteredDoseData = _allDoseData.where((drug) {
        if (_searchFilter == 'Trade Name') {
          return drug.tradeName.toLowerCase().contains(query.toLowerCase());
        } else {
          return drug.activeSubstanceWithConc.toLowerCase().contains(query.toLowerCase());
        }
      }).toList();
    });
  }

  void _selectDrug(DoseData drug) {
    setState(() {
      _selectedDrug = drug;
      _filteredDoseData = [];
      _searchController.clear();
      _calculationResults = [];
    });
  }

  void _onAgeChanged() {
    final years = int.tryParse(_yearsController.text) ?? 0;
    final months = int.tryParse(_monthsController.text) ?? 0;

    final weight = _service.getWeightByAge(years, months);
    if (weight != null) {
      _weightController.text = weight.toStringAsFixed(1);
    }
  }

  void _onWeightChanged() {
    if (_weightController.text.isNotEmpty) {
      _yearsController.clear();
      _monthsController.clear();
    }
  }

  Future<void> _calculateDose() async {
    if (_selectedDrug == null) return;

    final years = int.tryParse(_yearsController.text) ?? 0;
    final months = int.tryParse(_monthsController.text) ?? 0;
    final weight = double.tryParse(_weightController.text) ?? 0;

    if (weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid patient age or weight to calculate dosage'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _isCalculating = true;
      _calculationResults = [];
    });

    try {
      final tradeDataList = _service.getAllTradeData();
      final matchingTradeData = tradeDataList.where((trade) =>
          trade.activeSubstance.toLowerCase() == _selectedDrug!.activeSubstance.toLowerCase() &&
          trade.route.toLowerCase() == _selectedDrug!.route.toLowerCase() &&
          _service.patientFitsParam(trade.param, years, months, weight)
      ).toList();

      final results = <Map<String, dynamic>>[];
      for (final tradeData in matchingTradeData) {
        final result = _service.calculateDose(
          tradeData: tradeData,
          doseData: _selectedDrug!,
          weight: weight,
        );
        results.add(result);
      }

      // Debug: Log total available vs matching criteria for troubleshooting
      print('Debug: Found ${tradeDataList.length} total trade entries, ${matchingTradeData.length} matching patient criteria');

      setState(() {
        _calculationResults = results;
        _isCalculating = false;
      });

      if (results.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No suitable dosage found for this age/weight combination. Please verify patient criteria.'),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isCalculating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error calculating dose: ${e.toString()}')),
      );
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  void _copyAllDoses() {
    if (_calculationResults.isEmpty) return;
    
    final allDoses = _calculationResults.map((result) => result['result']).join('\n\n');
    _copyToClipboard(allDoses);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: QAppBar(title: const Text('Dose Calculator')),
        body: const CircularProgressContainer(),
      );
    }

    if (_hasError) {
      return Scaffold(
        appBar: QAppBar(title: const Text('Dose Calculator')),
        body: ErrorContainer(
          errorMessage: _errorMessage,
          onTapRetry: _initializeData,
          showErrorImage: true,
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: QAppBar(title: const Text('Dose Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Search section
            _buildSearchSection(),
            const SizedBox(height: 12),

            // Selected drug display
            if (_selectedDrug != null) ...[
              _buildSelectedDrugCard(),
              const SizedBox(height: 12),
              _buildPatientInputs(),
              const SizedBox(height: 12),
              _buildActionButtons(),
              const SizedBox(height: 12),
            ],

            // Results section
            if (_selectedDrug == null)
              _buildSearchResults()
            else
              _buildCalculationResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1565C0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF0D47A1), width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _filterDrugs,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Search for drug',
                hintStyle: TextStyle(color: Colors.white70),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                prefixIcon: Icon(Icons.search, color: Colors.white70),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0D47A1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: DropdownButton<String>(
              value: _searchFilter,
              underline: const SizedBox(),
              dropdownColor: const Color(0xFF0D47A1),
              style: const TextStyle(color: Colors.white, fontSize: 12),
              items: ['Trade Name', 'Generic name'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _searchFilter = newValue!;
                  _filteredDoseData = [];
                  _searchController.clear();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_filteredDoseData.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: const Text(
          'Start typing to search for medications',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _filteredDoseData.length,
        itemBuilder: (context, index) {
          final drug = _filteredDoseData[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF0D47A1), width: 1),
            ),
            child: ListTile(
              dense: true,
              title: Text(
                drug.tradeName,
                style: const TextStyle(color: Colors.yellow, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                drug.activeSubstanceWithConc,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              onTap: () => _selectDrug(drug),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedDrugCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1565C0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF0D47A1), width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedDrug!.tradeName,
                  style: const TextStyle(color: Colors.yellow, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedDrug!.activeSubstanceWithConc,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              setState(() {
                _selectedDrug = null;
                _calculationResults = [];
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPatientInputs() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1565C0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF0D47A1), width: 2),
      ),
      child: Row(
        children: [
          // Years
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Years :', style: TextStyle(color: Colors.white, fontSize: 12)),
                const SizedBox(height: 4),
                Container(
                  height: 35,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D47A1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: TextField(
                    controller: _yearsController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _onAgeChanged(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Months
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Months :', style: TextStyle(color: Colors.white, fontSize: 12)),
                const SizedBox(height: 4),
                Container(
                  height: 35,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D47A1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: TextField(
                    controller: _monthsController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _onAgeChanged(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Weight
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Weight :', style: TextStyle(color: Colors.white, fontSize: 12)),
                const SizedBox(height: 4),
                Container(
                  height: 35,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D47A1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _onWeightChanged(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Text('Kg', style: TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF0D47A1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: ElevatedButton(
              onPressed: _isCalculating ? null : _calculateDose,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: _isCalculating
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'Calculate dose',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF0D47A1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: ElevatedButton(
              onPressed: _calculationResults.isNotEmpty ? () {} : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text(
                'More info.',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalculationResults() {
    if (_calculationResults.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: const Text(
          'Enter patient information and tap "Calculate dose"',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D47A1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1565C0), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Dose',
                  style: TextStyle(color: Colors.yellow, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: InkWell(
                  onTap: _copyAllDoses,
                  child: const Text(
                    'Copy dose',
                    style: TextStyle(color: Color(0xFF0D47A1), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...(_calculationResults.map((result) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result['result'].toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
                if (result['note'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Note: ${result['note']}',
                    style: const TextStyle(color: Colors.orange, fontSize: 11),
                  ),
                ],
                if (result['ref'] != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Ref: ${result['ref']}',
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ],
            ),
          )).toList()),
        ],
      ),
    );
  }
}
