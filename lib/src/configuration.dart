import 'package:gherkin/src/io/indexer/feature_file_indexer.dart';
import 'package:gherkin/src/io/indexer/io_feature_file_indexer.dart';
import 'package:gherkin/src/io/reader/feature_file_reader.dart';

import '../gherkin.dart';
import './gherkin/parameters/custom_parameter.dart';
import './gherkin/steps/world.dart';
import './hooks/hook.dart';
import './reporters/reporter.dart';

import 'gherkin/attachments/attachment_manager.dart';
import 'io/reader/io_feature_file_reader.dart';

typedef CreateWorld = Future<World> Function(TestConfiguration config);
typedef CreateAttachmentManager = Future<AttachmentManager> Function(
  TestConfiguration config,
);

enum ExecutionOrder { sequential, random }

class TestConfiguration {
  /// The path(s) to all the features.
  /// All three [Pattern]s all supported: [RegExp], [String], [Glob].
  Iterable<Pattern> features;

  /// The default feature language
  String featureDefaultLanguage = 'en';

  /// a filter to limit the features that are run based on tags
  /// see https://docs.cucumber.io/cucumber/tag-expressions/ for expression syntax
  String tagExpression;

  /// The default step timeout - this can be override when definition a step definition
  Duration defaultTimeout = const Duration(seconds: 10);

  /// The execution order of features - this default to random to avoid any inter-test dependencies
  ExecutionOrder order = ExecutionOrder.random;

  /// The user defined step definitions that are matched with written steps in the features
  Iterable<StepDefinitionGeneric> stepDefinitions;

  /// Any user defined step parameters
  Iterable<CustomParameter<dynamic>> customStepParameterDefinitions;

  /// Hooks that are run at certain points in the execution cycle
  Iterable<Hook> hooks;

  /// a list of reporters to use.
  /// Built-in reporters:
  ///   - StdoutReporter
  ///   - ProgressReporter
  ///   - TestRunSummaryReporter
  ///   - JsonReporter
  /// Custom reporters can be created by extending (or implementing) Reporter.dart
  Iterable<Reporter> reporters;

  /// An optional function to create a world object for each scenario.
  CreateWorld createWorld;

  // Lists feature files paths, which match [features] patterns.
  FeatureFileIndexer featureFileIndexer = IoFeatureFileIndexer();

  // The feature file reader.
  // Takes files/resources paths from [featureFileIndexer] and returns their content as String.
  FeatureFileReader featureFileReader = IoFeatureFileReader();

  /// the program will exit after all the tests have run
  bool exitAfterTestRun = true;

  /// the program will exit after any test failed
  bool exitAfterTestFailed = false;

  /// used to allow for custom configuration to ensure framework specific configuration is in place
  void prepare() {}

  /// used to get a new instance of an attachment manager class that is passed to the World context
  CreateAttachmentManager getAttachmentManager =
      (_) => Future.value(AttachmentManager());

  /// Provide a configuration object with default settings such as the reports and feature file location
  /// Additional setting on the configuration object can be set on the returned instance.
  static TestConfiguration DEFAULT(
    Iterable<StepDefinitionGeneric<World>> steps, {
    String featurePath = 'features/.*\.feature',
  }) {
    return TestConfiguration()
      ..features = [RegExp(featurePath)]
      ..reporters = [
        StdoutReporter(MessageLevel.error),
        ProgressReporter(),
        TestRunSummaryReporter(),
        JsonReporter(path: './report.json')
      ]
      ..stepDefinitions = steps
      ..exitAfterTestRun = true
      ..exitAfterTestFailed = false;
  }
}
