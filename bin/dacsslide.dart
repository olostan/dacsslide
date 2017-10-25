import 'dart:io';
import 'package:resource/resource.dart' show Resource;
import 'dart:convert' show UTF8, JsonEncoder, JsonDecoder;
import 'dart:async';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;

String ask(String prompt,String defaultsTo) {
  stdout.write("${prompt} [${defaultsTo}]:");
  var result  = stdin.readLineSync();
  if (result == "") return defaultsTo;
  return result;
}
class Config {
  String _homePath() {
    String os = Platform.operatingSystem;
    String home = "";
    Map<String, String> envVars = Platform.environment;
    if (Platform.isMacOS) {
      home = envVars['HOME'];
    } else if (Platform.isLinux) {
      home = envVars['HOME'];
    } else if (Platform.isWindows) {
      home = envVars['UserProfile'];
    }
    return home;
  }
  Map<String, String> _data={"ghaccount":"github-name","author":"Anonymous","email":"example@example.com"};
  bool _modified = false;

  String get configFileName => path.join(_homePath(),".dacsslide.json");

  Config._() {
    
    var file = new File(configFileName);
    if (file.existsSync()) {
      _data = new JsonDecoder().convert(file.readAsStringSync());
    }
  }
  static Config _instance;
  operator[](String key) => _data[key];
  operator[]=(String key, String value) {
    if (_data[key]!=value) {
      _modified = true;
      _data[key] = value;
    }
  }
  void save() {
    if (_modified) {
      new File(configFileName).writeAsStringSync(new JsonEncoder().convert(_data));
      _modified = false;
    }
  }

  factory Config() {
    if (_instance==null) _instance = new Config._();
    return _instance;
  }

}


class CreateCommand extends Command {
  final name = "create";
  final description = "Creates new project";
  final config = new Config();

  CreateCommand() {
     argParser
      ..addOption('title',defaultsTo: "Great New Presentation",help:"Presentation title")
      ..addOption('ghaccount',help:'GitHub account', defaultsTo: config["ghaccount"] )
      ..addOption('author',help:"Author's name", defaultsTo: config["author"])
      ..addOption('email',help:"Author's email", defaultsTo: config["email"]);
  }

  static const List<String> templatableExtensions =  const ['.yaml','.html','.dart'];

  RegExp parameterRegExp;
  String projectName;

  Future<bool> createFile(String fileName) async {

    var fileResource = new Resource("package:dacsslide/template/${fileName}");
    if (fileName.endsWith(".template")) fileName = fileName.substring(0,fileName.length-".template".length);
    var file = await (new File(path.join(projectName,fileName)).create(recursive: true));
    if (templatableExtensions.any( (ext) => fileName.endsWith(ext))) {
       var content = await fileResource.readAsString(encoding: UTF8);
       var _content = content.replaceAllMapped(parameterRegExp, (m) => m.group(0)=="\$name"?projectName:argResults[m.group(0).substring(1)]);
       if (content != _content) {
         await file.writeAsString(_content);
         return true;
       }
    } 
    await file.writeAsBytes(await fileResource.readAsBytes());
    return true;
  }

  void _askArgument(String name, String prompt) {
    if (!argResults.wasParsed(name)) {
      config[name]  = ask("Enter ${prompt}",config[name]);
    } else {
      config[name] = argResults[name];
    }
  }

  Future<int> run() async {
    projectName = argResults.rest.length>0?argResults.rest.first:ask('Enter project name','some-name');
    _askArgument('ghaccount','GitHub account');
    _askArgument('author',"author's full name");
    _askArgument('email',"author's email");


    print("Generating project '${projectName}'");
    await new Directory(projectName).create();

    parameterRegExp = new RegExp("\\\$(${argResults.options.join('|')}|name)");

    var resource = new Resource("package:dacsslide/template/.files.txt");
    var fileNames = (await resource.readAsString(encoding: UTF8)).split("\n")
      .where( (f) => f.length>0).map( (f) => f.substring(2));
    await Future.wait(fileNames.map(createFile));
    print("Project ${projectName} generated.");

    config.save();
    
    return 0;
  }

}

void main(List<String> arguments)  {
  var runner = new CommandRunner("dacsslide","CLI for DaCSSlide presentation library")
    ..addCommand(new CreateCommand());
  runner.run(arguments).catchError((error) {
    if (error is! UsageException) throw error;
    print(error);
    exit(64); // Exit code 64 indicates a usage error.
  });
}
