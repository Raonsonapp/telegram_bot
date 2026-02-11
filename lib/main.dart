void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Нест кардани TokenStorage.init() ва AppConfig.init(), чун онҳо статикӣ ҳастанд
  // Танҳо сервисҳоеро, ки воқеан ба Init ниёз доранд, нигоҳ дор
  
  runApp(const RaonsonAppRoot());
}
