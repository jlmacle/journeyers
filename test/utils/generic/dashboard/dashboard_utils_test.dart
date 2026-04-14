import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'package:journeyers/utils/generic/dashboard/dashboard_testing_data.dart';
import 'package:journeyers/utils/generic/dashboard/dashboard_utils.dart';

class PathProviderPlatformRedirectForTesting extends  PathProviderPlatform {
  PathProviderPlatformRedirectForTesting(this._path);

  final String _path;

  @override
  Future<String?> getApplicationSupportPath() async => _path;
}

// ---------------------------------------------------------------------------
// Helper funtion
// ---------------------------------------------------------------------------

/// Reads and JSON-decodes the content of the file.
List<dynamic> _readRecords(File file) =>
    jsonDecode(file.readAsStringSync()) as List<dynamic>;

// ---------------------------------------------------------------------------
// Test suite
// ---------------------------------------------------------------------------
void main() {
  Directory? tempDir;
  DashboardUtils? sut; // system under test

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('dashboard_utils_test_');
    PathProviderPlatform.instance = PathProviderPlatformRedirectForTesting(tempDir!.path);
    sut = DashboardUtils();
  });

  tearDown(() async {
    if (tempDir!.existsSync()) {
      await tempDir!.delete(recursive: true);
    }
  });


  // getSessionMetadataFile
  group('getSessionMetadataFile', () {

    test('creates the file when it does not yet exist', () async {
      final file = await sut!.getSessionMetadataFile(
        typeOfContextData: DashboardUtils.contextAnalysesContext,
      );
      expect(file.existsSync(), isTrue);
    });

    test('initialises a newly created file with an empty JSON array',
      () async {
        final file = await sut!.getSessionMetadataFile(
          typeOfContextData: DashboardUtils.contextAnalysesContext,
        );

        final records = _readRecords(file);
        expect(records, isEmpty);
      },
    );   
  });


  // saveDashboardMetadata  (exercises _saveSessionMetadataHelper indirectly)
  group('saveDashboardMetadata', () {
    test('persists the title correctly', () async {
      await sut!.saveDashboardMetadata(
        typeOfContextData: DashboardUtils.contextAnalysesContext,
        title: testFile1Title,
        keywords: testFile1Keywords,
        formattedDate: aDate,
        pathToFile: testFile1Path,
      );

      final file = await sut!.getSessionMetadataFile(
        typeOfContextData: DashboardUtils.contextAnalysesContext,
      );
      final records = _readRecords(file);

      expect(records.first[DashboardUtils.keyTitle], testFile1Title);
    });

    test('uses "Untitled" when title is null', () async {
      await sut!.saveDashboardMetadata(
        typeOfContextData: DashboardUtils.contextAnalysesContext,
        title: null,
        keywords: [],
        formattedDate: aDate,
        pathToFile: aPath,
      );

      final file = await sut!.getSessionMetadataFile(
        typeOfContextData: DashboardUtils.contextAnalysesContext,
      );
      final records = _readRecords(file);

      expect(records.first[DashboardUtils.keyTitle], 'Untitled');
    });

    test('persists the keywords list correctly', () async {
      await sut!.saveDashboardMetadata(
        typeOfContextData: DashboardUtils.contextAnalysesContext,
        title: aTitle,
        keywords: keywords,
        formattedDate: aDate,
        pathToFile: aPath,
      );

      final file = await sut!.getSessionMetadataFile(
        typeOfContextData: DashboardUtils.contextAnalysesContext,
      );
      final records = _readRecords(file);

      expect(
        List<String>.from(records.first[DashboardUtils.keyKeywords] as List),
        equals(keywords),
      );
    });

    test('persists the date correctly', () async {
      await sut!.saveDashboardMetadata(
        typeOfContextData: DashboardUtils.contextAnalysesContext,
        title: aTitle,
        keywords: keywords,
        formattedDate: aDate,
        pathToFile: aPath,
      );

      final file = await sut!.getSessionMetadataFile(
        typeOfContextData: DashboardUtils.contextAnalysesContext,
      );
      final records = _readRecords(file);

      expect(records.first[DashboardUtils.keyDate], aDate);
    });

    test('persists the file path correctly', () async {
      await sut!.saveDashboardMetadata(
        typeOfContextData: DashboardUtils.contextAnalysesContext,
        title: aTitle,
        keywords: [],
        formattedDate: aDate,
        pathToFile: aPath,
      );

      final file = await sut!.getSessionMetadataFile(
        typeOfContextData: DashboardUtils.contextAnalysesContext,
      );
      final records = _readRecords(file);

      expect(records.first[DashboardUtils.keyFilePath], aPath);
    });

    test('stores records for the two contexts in separate files',
      () async {
        await sut!.saveDashboardMetadata(
          typeOfContextData: DashboardUtils.contextAnalysesContext,
          title: 'CA Session',
          keywords: [],
          formattedDate: aDate,
          pathToFile: testFile1Path,
        );
        await sut!.saveDashboardMetadata(
          typeOfContextData: DashboardUtils.groupProblemSolvingsContext,
          title: 'GPS Session',
          keywords: [],
          formattedDate: aDate,
          pathToFile: testFile2Path,
        );

        final caFile = await sut!.getSessionMetadataFile(
          typeOfContextData: DashboardUtils.contextAnalysesContext,
        );
        final gpsFile = await sut!.getSessionMetadataFile(
          typeOfContextData: DashboardUtils.groupProblemSolvingsContext,
        );

        expect(_readRecords(caFile), hasLength(1));
        expect(_readRecords(gpsFile), hasLength(1));

        expect(
          _readRecords(caFile).first[DashboardUtils.keyTitle],
          'CA Session',
        );
        expect(
          _readRecords(gpsFile).first[DashboardUtils.keyTitle],
          'GPS Session',
        );
      },
    );
  });


  // retrieveAllDashboardMetadata
  group('retrieveAllDashboardMetadata –', () {  
    test('returns records in reverse insertion order (most recent first)',
        () async {
      final titles = ['Oldest', 'Middle', 'Newest'];
      for (final t in titles) {
        await sut!.saveDashboardMetadata(
          typeOfContextData: DashboardUtils.contextAnalysesContext,
          title: t,
          keywords: [],
          formattedDate: aDate,
          pathToFile: '/files/${t.toLowerCase()}.json',
        );
      }

      final result = await sut!.retrieveAllDashboardMetadata(
        typeOfContextData: DashboardUtils.contextAnalysesContext,
      );

      expect(result.first[DashboardUtils.keyTitle], 'Newest');
      expect(result.last[DashboardUtils.keyTitle], 'Oldest');
    });

    test('returned records contain all expected keys', () async {
      await sut!.saveDashboardMetadata(
        typeOfContextData: DashboardUtils.contextAnalysesContext,
        title: aTitle,
        keywords: [],
        formattedDate: aDate,
        pathToFile: aPath,
      );

      final result = await sut!.retrieveAllDashboardMetadata(
        typeOfContextData: DashboardUtils.contextAnalysesContext,
      );
      final record = result.first as Map<String, dynamic>;

      expect(record.containsKey(DashboardUtils.keyTitle), isTrue);
      expect(record.containsKey(DashboardUtils.keyKeywords), isTrue);
      expect(record.containsKey(DashboardUtils.keyDate), isTrue);
      expect(record.containsKey(DashboardUtils.keyFilePath), isTrue);
    });
  });


  // deleteSpecificSessionMetadata
  group('deleteSpecificSessionMetadata', () {
    test('removes the record whose file path matches the target', () async {
      const fileToDelete = '/file/to/delete';

      await sut!.saveDashboardMetadata(
        typeOfContextData: DashboardUtils.contextAnalysesContext,
        title: 'Title: File to keep',
        keywords: [],
        formattedDate: aDate,
        pathToFile: '/file/to/keep',
      );
      await sut!.saveDashboardMetadata(
        typeOfContextData: DashboardUtils.contextAnalysesContext,
        title: testFile2Title,
        keywords: [],
        formattedDate: aDate,
        pathToFile: fileToDelete,
      );

      await sut!.deleteSpecificSessionMetadata(
        typeOfContextData: DashboardUtils.contextAnalysesContext,
        filePathRelatedToDataToDelete: fileToDelete,
      );

      final result = await sut!.retrieveAllDashboardMetadata(
        typeOfContextData: DashboardUtils.contextAnalysesContext,
      );

      expect(result, hasLength(1));
      expect(result.first[DashboardUtils.keyTitle], 'Title: File to keep');
    });

    test('does not alter other records when one is deleted', () async {
      for (var i = 1; i <= 4; i++) {
        await sut!.saveDashboardMetadata(
          typeOfContextData: DashboardUtils.contextAnalysesContext,
          title: 'Session $i',
          keywords: [],
          formattedDate: aDate,
          pathToFile: '/files/session_$i.json',
        );
      }

      await sut!.deleteSpecificSessionMetadata(
        typeOfContextData: DashboardUtils.contextAnalysesContext,
        filePathRelatedToDataToDelete: '/files/session_2.json',
      );

      final result = await sut!.retrieveAllDashboardMetadata(
        typeOfContextData: DashboardUtils.contextAnalysesContext,
      );

      expect(result, hasLength(3));
      
      final remaining = result
          .map((r) => r[DashboardUtils.keyFilePath] as String)
          .toList();
      expect(remaining, isNot(contains('/files/session_2.json')));
    });

    test('results in an empty file after its only record is deleted',
        () async {
      const onlyPath = 'only/file';
      await sut!.saveDashboardMetadata(
        typeOfContextData: DashboardUtils.contextAnalysesContext,
        title: 'Only one file',
        keywords: [],
        formattedDate: aDate,
        pathToFile: onlyPath,
      );

      await sut!.deleteSpecificSessionMetadata(
        typeOfContextData: DashboardUtils.contextAnalysesContext,
        filePathRelatedToDataToDelete: onlyPath,
      );

      final result = await sut!.retrieveAllDashboardMetadata(
        typeOfContextData: DashboardUtils.contextAnalysesContext,
      );

      expect(result, isEmpty);
    });

    
  });

  // saveAllSessionsMetadata
  group('saveAllSessionsMetadata –', () {

    test('can save an empty list',
        () async {

      await sut!.saveAllSessionsMetadata(
        typeOfContextData: DashboardUtils.contextAnalysesContext,
        allSessionsMetadata: [],
      );

      final result = await sut!.retrieveAllDashboardMetadata(
        typeOfContextData: DashboardUtils.contextAnalysesContext,
      );

      expect(result, isEmpty);
    });

  });


  // Round-trip integration
  group('Round-trip', () {
    test('data saved via saveDashboardMetadata is faithfully recovered '
        'via retrieveAllDashboardMetadata',
      () async {
        const expectedTitle = 'Round-trip Title';
        const expectedKeywords = ['alpha', 'beta', 'gamma'];
        const expectedDate = aDate;
        const expectedPath = '/round/trip';

        await sut!.saveDashboardMetadata(
          typeOfContextData: DashboardUtils.contextAnalysesContext,
          title: expectedTitle,
          keywords: expectedKeywords,
          formattedDate: expectedDate,
          pathToFile: expectedPath,
        );

        final result = await sut!.retrieveAllDashboardMetadata(
          typeOfContextData: DashboardUtils.contextAnalysesContext,
        );
        final record = result.first as Map<String, dynamic>;

        expect(record[DashboardUtils.keyTitle], expectedTitle);
        expect(
          List<String>.from(record[DashboardUtils.keyKeywords] as List),
          expectedKeywords,
        );
        expect(record[DashboardUtils.keyDate], expectedDate);
        expect(record[DashboardUtils.keyFilePath], expectedPath);
      },
    );

    test('save → delete → retrieve leaves no trace of the deleted session',
      () async {
        const fileToDelete = '/path/to/file/to/delete';

        // 2 files added
        await sut!.saveDashboardMetadata(
          typeOfContextData: DashboardUtils.contextAnalysesContext,
          title: testFile1Title,
          keywords: [],
          formattedDate: aDate,
          pathToFile: testFile1Path,
        );
        await sut!.saveDashboardMetadata(
          typeOfContextData: DashboardUtils.contextAnalysesContext,
          title: testFile2Title,
          keywords: [],
          formattedDate: aDate,
          pathToFile: fileToDelete,
        );

        // 1 file deleted
        await sut!.deleteSpecificSessionMetadata(
          typeOfContextData: DashboardUtils.contextAnalysesContext,
          filePathRelatedToDataToDelete: fileToDelete,
        );

        // Metadata retrieval
        final result = await sut!.retrieveAllDashboardMetadata(
          typeOfContextData: DashboardUtils.contextAnalysesContext,
        );

        expect(result, hasLength(1));
        expect(result.first[DashboardUtils.keyTitle], testFile1Title);
      },
    );    
  });
}