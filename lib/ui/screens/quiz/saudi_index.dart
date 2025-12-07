import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutterquiz/models/drug.dart';
import 'package:flutterquiz/services/drug_service.dart';
import 'package:flutterquiz/models/data_version.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart'; // Added import

class SaudiIndex extends StatefulWidget {
  const SaudiIndex({Key? key}) : super(key: key);

  static Route route(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => const SaudiIndex(),
      settings: settings,
    );
  }

  @override
  _SaudiIndexState createState() => _SaudiIndexState();
}

class _SaudiIndexState extends State<SaudiIndex> {
  final DrugService _drugService = DrugService();
  List<Drug> allDrugs = [];
  List<Drug> filteredDrugs = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  String errorMessage = '';
  String currentVersion = 'N/A';
  String searchCriteria = 'Trade Name';
  Drug? selectedDrug;
  String? selectedCountry;

  final String versionUrl = 'https://x-pharmacist.com/version.json';

  @override
  void initState() {
    super.initState();
    selectedCountry = 'Saudi'; // Set Egypt as default
    loadDrugs();
    searchController.addListener(_search);
  }

  @override
  void dispose() {
    searchController.removeListener(_search);
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadDrugs() async {
    try {
      bool hasLocalData = await _drugService.hasLocalData();

      if (!hasLocalData) {
        // Show initial data fetch progress
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 16),
                  Text('Fetching drug database for the first time...'),
                ],
              ),
              duration: Duration(seconds: 5),
            ),
          );
        }

        await _drugService.fetchAndStoreDrugs();

        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Drug database loaded successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }

      setState(() {
        allDrugs = _drugService.getAllDrugs();
        filteredDrugs = [];
        DataVersion? localVersion = _drugService.getLocalVersion();
        currentVersion = localVersion?.version ?? 'Unknown';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage =
            'Failed to load drugs. Please check your internet connection.';
        isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    // Show progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Checking for updates...'),
            ],
          ),
        );
      },
    );

    try {
      Map<String, dynamic> versionInfo = await fetchVersionInfo();
      String remoteVersion = versionInfo['version'] ?? 'Unknown';

      DataVersion? localVersion = _drugService.getLocalVersion();
      String localVersionStr = localVersion?.version ?? 'Unknown';

      // Close progress dialog
      Navigator.of(context).pop();

      if (_isVersionNewer(remoteVersion, localVersionStr)) {
        await _showUpdateDialog(remoteVersion);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data is already up to date.')),
        );
      }

      setState(() {
        allDrugs = _drugService.getAllDrugs();
        _search();
        DataVersion? localVersion = _drugService.getLocalVersion();
        currentVersion = localVersion?.version ?? 'Unknown';
        isLoading = false;
      });
    } catch (e) {
      // Close progress dialog if still open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      setState(() {
        errorMessage = 'No internet connection or there is a problem';
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  Future<Map<String, dynamic>> fetchVersionInfo() async {
    try {
      final response = await http.get(Uri.parse(versionUrl));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load version info');
      }
    } catch (e) {
      throw Exception('No internet connection or there is a problem');
    }
  }

  Future<void> _showUpdateDialog(String remoteVersion) async {
    DataVersion? localVersion = _drugService.getLocalVersion();
    String localVersionStr = localVersion?.version ?? 'Unknown';

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Version Available'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current Version: $localVersionStr'),
              Text('New Version: $remoteVersion'),
              const SizedBox(height: 10),
              const Text(
                'Updating will take a minute. Do you want to proceed?',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _performDataUpdate();
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performDataUpdate() async {
    // Show update progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Downloading updates...'),
              const SizedBox(height: 8),
              const Text(
                'Please wait, this may take a moment',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );

    try {
      await _drugService.fetchAndStoreDrugs();

      // Close progress dialog
      Navigator.of(context).pop();

      setState(() {
        allDrugs = _drugService.getAllDrugs();
        _search();
        DataVersion? localVersion = _drugService.getLocalVersion();
        currentVersion = localVersion?.version ?? 'Unknown';
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Close progress dialog if still open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      setState(() {
        errorMessage = 'Failed to update data. Please try again.';
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Update failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _isVersionNewer(String remote, String local) {
    List<int> remoteParts = remote.split('.').map(int.parse).toList();
    List<int> localParts = local.split('.').map(int.parse).toList();

    for (int i = 0; i < remoteParts.length; i++) {
      if (i >= localParts.length) return true;
      if (remoteParts[i] > localParts[i]) return true;
      if (remoteParts[i] < localParts[i]) return false;
    }
    return false;
  }

  void _onDrugTap(Drug drug) {
    setState(() {
      selectedDrug = drug;
    });
  }

  void _showSimilarDrugs() {
    if (selectedDrug == null) return;

    List<Drug> similarDrugs = allDrugs
        .where(
          (drug) =>
              drug.genericName.toLowerCase() ==
              selectedDrug!.genericName.toLowerCase(),
        )
        .toList();

    if (selectedCountry != null) {
      similarDrugs = similarDrugs.where((drug) {
        List<String> keValues = drug.ke.split(',');
        return selectedCountry == 'Egypt'
            ? (keValues.contains('1') || keValues.contains('2'))
            : (keValues.contains('1') || keValues.contains('3'));
      }).toList();
    }

    setState(() => filteredDrugs = similarDrugs);
  }

  void _showAlternativeDrugs() {
    if (selectedDrug == null) return;

    List<Drug> alternativeDrugs = allDrugs
        .where(
          (drug) =>
              drug.pharmacology.toLowerCase() ==
              selectedDrug!.pharmacology.toLowerCase(),
        )
        .toList();

    if (selectedCountry != null) {
      alternativeDrugs = alternativeDrugs.where((drug) {
        List<String> keValues = drug.ke.split(',');
        return selectedCountry == 'Egypt'
            ? (keValues.contains('1') || keValues.contains('2'))
            : (keValues.contains('1') || keValues.contains('3'));
      }).toList();
    }

    setState(() => filteredDrugs = alternativeDrugs);
  }

  Future<void> _showDrugImage() async {
    if (selectedDrug == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No drug selected')));
      return;
    }

    final tradeName = selectedDrug!.tradeName ?? 'N/A';
    final googleImagesUrl =
        'https://www.google.com/search?tbm=isch&q=$tradeName';

    if (await canLaunchUrl(Uri.parse(googleImagesUrl))) {
      await launchUrl(
        Uri.parse(googleImagesUrl),
        mode: LaunchMode.inAppWebView,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $googleImagesUrl')),
      );
    }
  }

  void _onDescriptionButtonClick() {
    if (selectedDrug == null) return;

    if (selectedDrug!.descriptionId.isNotEmpty) {
      Drug? descriptionDrug = allDrugs.firstWhere(
        (drug) => drug.id == selectedDrug!.descriptionId,
        orElse: () => selectedDrug!,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DrugDetailScreen(drug: descriptionDrug),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DrugDetailScreen(drug: selectedDrug!),
        ),
      );
    }
  }

  void _filterByCountry(String country) {
    searchController.clear();
    setState(() {
      selectedCountry = country;
      filteredDrugs = [];
    });
  }

  void _search() {
    final query = searchController.text.toLowerCase().trim();

    // Only show results when query has 2+ characters
    if (query.length < 2) {
      setState(() => filteredDrugs = []);
      return;
    }

    // Original search logic below (keep everything else the same)
    String pattern = '^' + query.replaceAll(' ', '.*');
    RegExp regex = RegExp(pattern, caseSensitive: false);
    // String pattern = query.replaceAll(' ', '.*').replaceAll('*', '.*');
    // RegExp regex = RegExp(pattern, caseSensitive: false);

    List<Drug> tempList = allDrugs.where((drug) {
      String fieldToSearch;
      switch (searchCriteria) {
        case 'Generic Name':
          fieldToSearch = drug.genericName.toLowerCase();
          break;
        case 'Pharmacology':
          fieldToSearch = drug.pharmacology.toLowerCase();
          break;
        default:
          fieldToSearch = drug.tradeName.toLowerCase();
      }
      return regex.hasMatch(fieldToSearch);
    }).toList();

    if (selectedCountry != null) {
      tempList = tempList.where((drug) {
        List<String> keValues = drug.ke.split(',');
        return selectedCountry == 'Egypt'
            ? (keValues.contains('1') || keValues.contains('2'))
            : (keValues.contains('1') || keValues.contains('3'));
      }).toList();
    }

    setState(() => filteredDrugs = tempList);
  }

  Widget _getOtcIndicator(String otc) {
    if (selectedCountry != 'Saudi') return const SizedBox.shrink();
    if (otc == 'o')
      return const Text(
        'OTC',
        style: TextStyle(fontSize: 12, color: Colors.green),
      );
    if (otc == 'p')
      return const Text(
        'Presc',
        style: TextStyle(fontSize: 12, color: Colors.red),
      );
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const SizedBox.shrink(),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh Data',
            color: Colors.white,
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () => _filterByCountry('Egypt'),
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedCountry == 'Egypt'
                  ? Colors.green
                  : Colors.grey[400],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            ),
            child: const Text('Egypt', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () => _filterByCountry('Saudi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedCountry == 'Saudi'
                  ? Colors.green
                  : Colors.grey[400],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            ),
            child: const Text('Saudi', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  const Text(
                    'Loading Drug Database...',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Version: $currentVersion',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            )
          : errorMessage.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isLoading = true;
                        errorMessage = '';
                      });
                      loadDrugs();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          onTap: () => searchController.clear(),
                          decoration: InputDecoration(
                            labelText: 'Search',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: const BorderSide(width: 0.5),
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      DropdownButton<String>(
                        value: searchCriteria,
                        dropdownColor: Colors.grey[100],
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        isExpanded: true,
                        hint: const Row(
                          children: [
                            Icon(Icons.filter_list, size: 20),
                            SizedBox(width: 8),
                            Text('Filter by'),
                          ],
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Trade Name',
                            child: Text('Trade Name'),
                          ),
                          DropdownMenuItem(
                            value: 'Generic Name',
                            child: Text('Generic Name'),
                          ),
                          DropdownMenuItem(
                            value: 'Pharmacology',
                            child: Text('Pharmacology'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              searchCriteria = value;
                              _search();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filteredDrugs.isNotEmpty
                      ? ListView.builder(
                          itemCount: filteredDrugs.length,
                          itemBuilder: (context, index) {
                            final drug = filteredDrugs[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: ListTile(
                                title: Text(
                                  drug.tradeName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Text(drug.genericName),
                                trailing: _getOtcIndicator(drug.otc),
                                onTap: () => _onDrugTap(drug),
                              ),
                            );
                          },
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/images/app_logo.svg', // Updated path
                              height: 109,
                              width: 240,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'For The Best Pharmacist s',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.blueGrey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 16.0),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: selectedDrug != null
                            ? _onDescriptionButtonClick
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedDrug != null
                              ? Colors.blue[800]
                              : Colors.grey,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (selectedDrug != null) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Text(
                                  selectedDrug!.tradeName,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                selectedDrug!.pharmacology,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ] else ...[
                              const Text(
                                'Description',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: selectedDrug != null
                                  ? _showSimilarDrugs
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[600],
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Similar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: selectedDrug != null
                                  ? _showAlternativeDrugs
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[600],
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Alternative',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: selectedDrug != null
                                  ? _showDrugImage
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange[600],
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Image',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class DrugDetailScreen extends StatelessWidget {
  final Drug drug;

  const DrugDetailScreen({Key? key, required this.drug}) : super(key: key);

  Widget _buildInfoRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildPriceRow() {
    if (drug.price <= 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Price:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${drug.price.toStringAsFixed(2)} EGP',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, String value, Color color) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(drug.tradeName),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main title
              Text(
                drug.tradeName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 16),

              // Status chips row
              if (drug.otc.isNotEmpty || drug.temperature.isNotEmpty)
                Wrap(
                  children: [
                    if (drug.otc == 'o')
                      _buildStatusChip('OTC', 'Over-the-counter', Colors.green),
                    if (drug.otc == 'p')
                      _buildStatusChip(
                        'Prescription',
                        'Required',
                        Colors.orange,
                      ),
                    if (drug.temperature.isNotEmpty)
                      _buildStatusChip(
                        'Storage',
                        drug.temperature,
                        Colors.blue,
                      ),
                  ],
                ),

              const SizedBox(height: 16),

              // Drug information
              _buildInfoRow('Generic Name', drug.genericName),
              _buildInfoRow('Arabic Name', drug.arabicName),
              _buildInfoRow('Pharmacology', drug.pharmacology),
              _buildInfoRow('Company', drug.company),
              _buildInfoRow('Route of Administration', drug.route),
              _buildInfoRow('Pharmacy', drug.pharmacy),
              _buildPriceRow(),

              const SizedBox(height: 8),

              // Description section
              if (drug.description.isNotEmpty) ...[
                const Text(
                  'Description:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    drug.description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
