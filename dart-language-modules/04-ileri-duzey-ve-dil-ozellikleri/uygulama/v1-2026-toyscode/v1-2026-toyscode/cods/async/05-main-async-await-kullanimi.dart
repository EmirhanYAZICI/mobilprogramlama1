void main() async {
  checkVersion();
  print('In main: version is ${await lookUpVersion()}');
}
