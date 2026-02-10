import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/core/utils/dashboard/dashboard_utils.dart';
import 'package:journeyers/core/utils/printing_and_logging/print_utils.dart';
import 'package:journeyers/widgets/custom/text/custom_heading.dart';

class ContextAnalysesDashboardPage extends StatefulWidget {
  const ContextAnalysesDashboardPage({super.key});

  @override
  State<ContextAnalysesDashboardPage> createState() => _ContextAnalysesDashboardPageState();
}

class _ContextAnalysesDashboardPageState extends State<ContextAnalysesDashboardPage> {
  FocusNode contextAnalysisDashboardFocusNode = FocusNode();

  bool _isDataLoading = true;
  bool _isAscending = false; 
  List<dynamic>? _allSessions;
  List<dynamic>? _filteredSessions;
  List<String>? _usedKeywords;
  final List<String> _selectedKeywords = [];
  final List<String> _selectedSessionsForDeletion = [];

  DashboardUtils du = DashboardUtils();
  PrintUtils pu = PrintUtils();

  @override
  void initState() {
    super.initState();
    _sessionDataRetrieval();
  }

  void _sessionDataRetrieval() async {
    final data = await du.retrieveAllDashboardSessionData(
      typeOfContextData: DashboardUtils.contextAnalysesContext,
    );
    _usedKeywords = await usedKeywords(data);
    _allSessions = data;
    _sortSessionsByDate();
    setState(() {
      _isDataLoading = false;
    });
  }

  Future<List<String>> usedKeywords(List<dynamic> listOfSessionData) async {
    Set<String> kwSet = {};
    for (var sessionData in listOfSessionData) {
      List<dynamic> kws = sessionData[DashboardUtils.keyKeywords];
      kwSet.addAll(kws.cast<String>());
    }
    return kwSet.toList();
  }

  void _sortSessionsByDate() {
    _allSessions?.sort((a, b) {
      DateTime dateA = DateFormat("MM/dd/yy").parse(a[DashboardUtils.keyDate]);
      DateTime dateB = DateFormat("MM/dd/yy").parse(b[DashboardUtils.keyDate]);
      return _isAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
    });
    _applyFilters();
  }

  void _toggleFilter(String keyword) {
    setState(() {
      if (_selectedKeywords.contains(keyword)) {
        _selectedKeywords.remove(keyword);
      } else {
        _selectedKeywords.add(keyword);
      }
      _applyFilters();
    });
  }

  void _applyFilters() {
    if (_selectedKeywords.isEmpty) {
      _filteredSessions = List.from(_allSessions!);
    } else {
      _filteredSessions = _allSessions!.where((session) {
        final sessionKeywords = session[DashboardUtils.keyKeywords].cast<String>();
        return _selectedKeywords.every((k) => sessionKeywords.contains(k));
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isDataLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 10),
                  child: CustomHeading(headingText: "Previous session data", headingLevel: 2),
                ),
                _buildFilterAndSortBar(),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredSessions?.length ?? 0,
                    itemBuilder: (context, index) {
                      final session = _filteredSessions![index];
                      final String filePath = session[DashboardUtils.keyFilePath];
                      final bool isChecked = _selectedSessionsForDeletion.contains(filePath);

                      return ListTile(
                        leading: Checkbox(
                          value: isChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedSessionsForDeletion.add(filePath);
                              } else {
                                _selectedSessionsForDeletion.remove(filePath);
                              }
                            });
                          },
                        ),
                       title: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "${session[DashboardUtils.keyTitle]}",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.edit, size: 18),
                              onPressed: () {}, // TODO
                            ),
                            Text(
                              "(${session[DashboardUtils.keyDate]})",
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                        subtitle: Text("Keywords: ${session[DashboardUtils.keyKeywords].join(', ')}"),
                        trailing: Wrap(
                          spacing: -8, // Tighter grouping for icons
                          children: [
                            IconButton(icon: const Icon(Icons.find_in_page_rounded), onPressed: () {}),
                            IconButton(icon: const Icon(Icons.edit_document), onPressed: () {}),
                            IconButton(icon: const Icon(Icons.style_rounded), onPressed: () {}),
                            IconButton(icon: const Icon(Icons.share), onPressed: () {}),
                            IconButton(
                              icon: const Icon(Icons.delete_rounded),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterAndSortBar() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _isAscending = !_isAscending;
                    _sortSessionsByDate();
                  });
                },
                icon: Icon(_isAscending ? Icons.arrow_upward : Icons.arrow_downward, color: Colors.black),
                label: const Text("Sort by Date", style: TextStyle(color: Colors.black),),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: const Text("Filter by Keywords:", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Wrap(
            spacing: 8.0,
            children: _usedKeywords!.map((kw) {
              return FilterChip(
                label: Text(kw),
                onSelected: (_) => _toggleFilter(kw),
                selected: _selectedKeywords.contains(kw),
              );
            }).toList(),
          ),
        ),
        const Divider(),
      ],
    );
  }

  @override
  void dispose() {
    contextAnalysisDashboardFocusNode.dispose();
    super.dispose();
  }
}