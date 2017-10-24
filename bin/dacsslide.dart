import 'dart:io';
import 'package:resource/resource.dart' show Resource;
import 'dart:convert' show UTF8;
import 'dart:async';


abstract class Command {
  String get name;
  String get help;
  Future<int> execute(List<String> arguments);
  const Command();
}

class CreationParameter {
  final String name;
  final String defaultValue;
  final String description;
  const CreationParameter(this.name, this.defaultValue, this.description);
}
class CreateCommand extends Command {
  CreateCommand();

  static const List<String> templatableExtensions =  const ['.yaml','.html'];
  static const List<String> parameters = const [
    const CreationParameter("name",  "new_presentation", "Presentation name"),
    const CreationParameter("title", "Great New Presentation","Presentation title"),
    const CreationParameter("ghaccount", "mygithubaccount","GitHub account"),
    const CreationParameter("author", "Anonymous","Authour's name"),
    const CreationParameter("email", "example@example.com","Author's email"),
  ];

  final Map<String,String> parametersValues = {};
  RegExp parameterRegExp;

  Future<bool> createFile(String fileName) async {

    print("Processing ${fileName}");
    var file = await (new File(fileName).create(recursive: true));
    if (fileName.endsWith(".template")) fileName = fileName.substring(fileName.length-".templat".length);
    var fileResource = new Resource("package:dacsslide/template/${fileName}");
    if (templatableExtensions.any( (ext) => fileName.endsWith(ext))) {
       print("Processing template ${fileName}");
       var content = await fileResource.readAsString(encoding: UTF8);
       var _content = content.replaceAllMapped(parameterRegExp, (m) => parametersValues[m.group(0).substring(1)]);
       if (content != _content) {
         //print("Changed:\n ${_content}");
         await file.writeAsString(_content);
         return true;
       }
    } 
    await file.writeAsBytes(await fileResource.readAsBytes());
    return true;
  }

  @override
  int execute(List<String> arguments) async {
    print("Generating project ${arguments.join('-')}");
    for (CreationParameter parameter in parameters) {
      parametersValues[parameter.name] = parameter.defaultValue;
    }
    parameterRegExp = new RegExp("\\\$(${parameters.map( (p) => p.name).join('|')})");

    var resource = new Resource("package:dacsslide/template/.files.txt");
    var fileNames = (await resource.readAsString(encoding: UTF8)).split("\n")
      .where( (f) => f.length>0).map( (f) => f.substring(2));
    await Future.wait(fileNames.map(createFile));
    print("Project generated");
    return 0;
  }

  @override
  String get help => "Use 'create' command to initialize new presentation project.";

  @override
  String get name => "create";
}

//T commandCreator<T>() => new T();

List<Command> commands =  [new CreateCommand()];

void main(List<String> arguments) async {
  if (arguments.length<1) {
    var commandList = commands.map((Command c) => c.name).join(",");
    stderr.write("Usage: dacsslide [command]\nWhere [command] is one of: ${commandList}");
    exitCode = 2;
    return;
  }
  
  var command = commands.firstWhere((Command c) => c.name==arguments.first, orElse: () => null);
  if (command == null) {
    var commandList = commands.map((Command c) => c.name).join(",");
    stderr.write("Invalid command '${arguments.first}'\nAwailable commands are: ${commandList}");
    exitCode = 2;
    return;
  }
  exitCode = await command.execute(arguments.sublist(1));
}
