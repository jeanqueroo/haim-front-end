import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  // Textos en español
  static const Map<String, String> _es = {
    'appTitle': 'Haim App',
    'registerUser': 'Registrar Usuario',
    'email': 'Email',
    'password': 'Contraseña',
    'firstName': 'Nombre',
    'lastName': 'Apellidos',
    'address': 'Dirección',
    'country': 'País',
    'age': 'Edad',
    'gender': 'Sexo',
    'roles': 'Roles',
    'male': 'Masculino',
    'female': 'Femenino',
    'other': 'Otro',
    'admin': 'Administrador',
    'vendedor': 'Vendedor',
    'user': 'Usuario',
    'register': 'Registrar',
    'registering': 'Registrando...',
    'required': 'Obligatorio',
    'invalidEmail': 'Email no válido',
    'passwordMinLength': 'Mínimo 6 caracteres',
    'mustBeNumber': 'Debe ser número',
    'mustBeGreaterThanZero': 'Debe ser mayor a 0',
    'selectGender': 'Selecciona el sexo',
    'selectAtLeastOneRole': 'Selecciona al menos un rol',
    'checkEmailAvailability': 'Verificar disponibilidad del email',
    'emailAlreadyRegistered': 'Este email ya está registrado',
    'errorCheckingEmail': 'Error al verificar email',
    'unexpectedError': 'Error inesperado',
    'selectLanguage': 'Seleccionar idioma',
    'language': 'Idioma',
    'spanish': 'Español',
    'english': 'English',
    'login': 'Iniciar Sesión',
  'welcome': '¡Bienvenido!',
  'welcomeSubtitle': 'Tu aplicación de gestión de tiendas',
  'getStarted': 'Comenzar',
  'loginToAccess': 'Inicia sesión para acceder a todas las funciones',
  'dashboard': 'Panel de Control',
    'loginSuccess': 'Inicio de sesión exitoso',
    'loginError': 'Error al iniciar sesión',
    'invalidCredentials': 'Credenciales inválidas',
    'userRegisteredSuccessfully': 'Usuario registrado exitosamente',
    'registrationError': 'Error al registrar usuario',
    'connectionError': 'Error de conexión',
    'serverError': 'Error del servidor',
    'tryAgain': 'Intentar de nuevo',
    'save': 'Guardar',
    'edit': 'Editar',
    'delete': 'Eliminar',
  'confirm': 'Confirmar',
  'yes': 'Sí',
  'no': 'No',
  'selectLanguageDescription': 'Selecciona el idioma que prefieras para la aplicación',
  'information': 'Información',
  'currentLanguage': 'Idioma actual:',
  'languageChangeNote': 'Los cambios de idioma se aplicarán inmediatamente en toda la aplicación',
  'hello': '¡Hola',
  'welcomeToDashboard': 'Bienvenido a tu panel de gestión',
  'quickActions': 'Acciones Rápidas',
  'createNewUser': 'Crear nuevo usuario',
  'viewUsers': 'Ver Usuarios',
  'manageUsers': 'Gestionar usuarios',
  'addNewStore': 'Añadir nueva tienda',
  'addProducts': 'Añadir productos',
  'viewStores': 'Ver Tiendas',
  'manageStores': 'Gestionar tiendas',
  'statistics': 'Estadísticas',
  'users': 'Usuarios',
  'stores': 'Tiendas',
  'products': 'Productos',
  'sales': 'Ventas',
  'registeredUsers': 'Usuarios Registrados',
  'searchUsers': 'Buscar usuarios...',
  'filterByRole': 'Filtrar por rol:',
  'allRoles': 'Todos los roles',
  'noUsersFound': 'No se encontraron usuarios',
  'noUsersRegistered': 'No hay usuarios registrados',
  'clearFilters': 'Limpiar filtros',
  'refresh': 'Actualizar',
  'viewDetails': 'Ver detalles',
  'years': 'años',
  'registeredDate': 'Fecha de registro',
  'close': 'Cerrar',
  'errorLoadingUsers': 'Error al cargar usuarios',
  'comingSoon': 'Próximamente',
  'storesFeatureDescription': 'La gestión de tiendas estará disponible pronto',
  'registerStoreDescription': 'El registro de tiendas estará disponible pronto',
  'productsFeatureDescription': 'La gestión de productos estará disponible pronto',
  'registerProductDescription': 'El registro de productos estará disponible pronto',
  'profile': 'Perfil',
  'personalInformation': 'Información Personal',
  'accountInformation': 'Información de Cuenta',
  'userId': 'ID de Usuario',
  'accountActions': 'Acciones de Cuenta',
  'logoutConfirmation': '¿Estás seguro de que quieres cerrar sesión?',
  'changeLanguageInSettings': 'Cambia el idioma en Configuración',
  'home': 'Inicio',
  'settings': 'Ajustes',
  'selectStore': 'Seleccionar Tienda',
  'sessionClosed': 'Sesión cerrada correctamente',
  'darkMode': 'Modo oscuro (demo)',
  'version': 'Versión',
  'store': 'Tienda',
  'product': 'Producto',
  };

  // Textos en inglés
  static const Map<String, String> _en = {
    'appTitle': 'Haim App',
    'registerUser': 'Register User',
    'email': 'Email',
    'password': 'Password',
    'firstName': 'First Name',
    'lastName': 'Last Name',
    'address': 'Address',
    'country': 'Country',
    'age': 'Age',
    'gender': 'Gender',
    'roles': 'Roles',
    'male': 'Male',
    'female': 'Female',
    'other': 'Other',
    'admin': 'Administrator',
    'vendedor': 'Salesperson',
    'user': 'User',
    'register': 'Register',
    'registering': 'Registering...',
    'required': 'Required',
    'invalidEmail': 'Invalid email',
    'passwordMinLength': 'Minimum 6 characters',
    'mustBeNumber': 'Must be a number',
    'mustBeGreaterThanZero': 'Must be greater than 0',
    'selectGender': 'Select gender',
    'selectAtLeastOneRole': 'Select at least one role',
    'checkEmailAvailability': 'Check email availability',
    'emailAlreadyRegistered': 'This email is already registered',
    'errorCheckingEmail': 'Error checking email',
    'unexpectedError': 'Unexpected error',
    'selectLanguage': 'Select language',
    'language': 'Language',
    'spanish': 'Español',
    'english': 'English',
    'login': 'Login',
  'welcome': 'Welcome!',
  'welcomeSubtitle': 'Your store management application',
  'getStarted': 'Get Started',
  'loginToAccess': 'Login to access all features',
  'dashboard': 'Dashboard',
    'loginSuccess': 'Login successful',
    'loginError': 'Login error',
    'invalidCredentials': 'Invalid credentials',
    'userRegisteredSuccessfully': 'User registered successfully',
    'registrationError': 'Registration error',
    'connectionError': 'Connection error',
    'serverError': 'Server error',
    'tryAgain': 'Try again',
    'save': 'Save',
    'edit': 'Edit',
    'delete': 'Delete',
  'confirm': 'Confirm',
  'yes': 'Yes',
  'no': 'No',
  'selectLanguageDescription': 'Select your preferred language for the application',
  'information': 'Information',
  'currentLanguage': 'Current language:',
  'languageChangeNote': 'Language changes will be applied immediately throughout the application',
  'hello': 'Hello',
  'welcomeToDashboard': 'Welcome to your management panel',
  'quickActions': 'Quick Actions',
  'createNewUser': 'Create new user',
  'viewUsers': 'View Users',
  'manageUsers': 'Manage users',
  'addNewStore': 'Add new store',
  'addProducts': 'Add products',
  'viewStores': 'View Stores',
  'manageStores': 'Manage stores',
  'statistics': 'Statistics',
  'users': 'Users',
  'stores': 'Stores',
  'products': 'Products',
  'sales': 'Sales',
  'registeredUsers': 'Registered Users',
  'searchUsers': 'Search users...',
  'filterByRole': 'Filter by role:',
  'allRoles': 'All roles',
  'noUsersFound': 'No users found',
  'noUsersRegistered': 'No users registered',
  'clearFilters': 'Clear filters',
  'refresh': 'Refresh',
  'viewDetails': 'View details',
  'years': 'years',
  'registeredDate': 'Registration date',
  'close': 'Close',
  'errorLoadingUsers': 'Error loading users',
  'comingSoon': 'Coming Soon',
  'storesFeatureDescription': 'Store management will be available soon',
  'registerStoreDescription': 'Store registration will be available soon',
  'productsFeatureDescription': 'Product management will be available soon',
  'registerProductDescription': 'Product registration will be available soon',
  'profile': 'Profile',
  'personalInformation': 'Personal Information',
  'accountInformation': 'Account Information',
  'userId': 'User ID',
  'accountActions': 'Account Actions',
  'logoutConfirmation': 'Are you sure you want to logout?',
  'changeLanguageInSettings': 'Change language in Settings',
  'home': 'Home',
  'settings': 'Settings',
  'selectStore': 'Select Store',
  'sessionClosed': 'Session closed successfully',
  'darkMode': 'Dark mode (demo)',
  'version': 'Version',
  'store': 'Store',
  'product': 'Product',
  };

  String _getText(String key) {
    final texts = locale.languageCode == 'en' ? _en : _es;
    return texts[key] ?? key;
  }

  // Getters para todos los textos
  String get appTitle => _getText('appTitle');
  String get registerUser => _getText('registerUser');
  String get email => _getText('email');
  String get password => _getText('password');
  String get firstName => _getText('firstName');
  String get lastName => _getText('lastName');
  String get address => _getText('address');
  String get country => _getText('country');
  String get age => _getText('age');
  String get gender => _getText('gender');
  String get roles => _getText('roles');
  String get male => _getText('male');
  String get female => _getText('female');
  String get other => _getText('other');
  String get admin => _getText('admin');
  String get vendedor => _getText('vendedor');
  String get user => _getText('user');
  String get register => _getText('register');
  String get registering => _getText('registering');
  String get required => _getText('required');
  String get invalidEmail => _getText('invalidEmail');
  String get passwordMinLength => _getText('passwordMinLength');
  String get mustBeNumber => _getText('mustBeNumber');
  String get mustBeGreaterThanZero => _getText('mustBeGreaterThanZero');
  String get selectGender => _getText('selectGender');
  String get selectAtLeastOneRole => _getText('selectAtLeastOneRole');
  String get checkEmailAvailability => _getText('checkEmailAvailability');
  String get emailAlreadyRegistered => _getText('emailAlreadyRegistered');
  String get errorCheckingEmail => _getText('errorCheckingEmail');
  String get unexpectedError => _getText('unexpectedError');
  String get selectLanguage => _getText('selectLanguage');
  String get language => _getText('language');
  String get spanish => _getText('spanish');
  String get english => _getText('english');
  String get login => _getText('login');
  String get welcome => _getText('welcome');
  String get welcomeSubtitle => _getText('welcomeSubtitle');
  String get getStarted => _getText('getStarted');
  String get loginToAccess => _getText('loginToAccess');
  String get dashboard => _getText('dashboard');
  String get logout => _getText('logout');
  String get loginSuccess => _getText('loginSuccess');
  String get loginError => _getText('loginError');
  String get invalidCredentials => _getText('invalidCredentials');
  String get userRegisteredSuccessfully => _getText('userRegisteredSuccessfully');
  String get registrationError => _getText('registrationError');
  String get connectionError => _getText('connectionError');
  String get serverError => _getText('serverError');
  String get tryAgain => _getText('tryAgain');
  String get cancel => _getText('cancel');
  String get save => _getText('save');
  String get edit => _getText('edit');
  String get delete => _getText('delete');
  String get confirm => _getText('confirm');
  String get yes => _getText('yes');
  String get no => _getText('no');
  String get settings => _getText('settings');
  String get selectLanguageDescription => _getText('selectLanguageDescription');
  String get information => _getText('information');
  String get currentLanguage => _getText('currentLanguage');
  String get languageChangeNote => _getText('languageChangeNote');
  String get hello => _getText('hello');
  String get welcomeToDashboard => _getText('welcomeToDashboard');
  String get quickActions => _getText('quickActions');
  String get createNewUser => _getText('createNewUser');
  String get viewUsers => _getText('viewUsers');
  String get manageUsers => _getText('manageUsers');
  String get registerStore => _getText('registerStore');
  String get addNewStore => _getText('addNewStore');
  String get registerProduct => _getText('registerProduct');
  String get addProducts => _getText('addProducts');
  String get viewStores => _getText('viewStores');
  String get manageStores => _getText('manageStores');
  String get statistics => _getText('statistics');
  String get users => _getText('users');
  String get stores => _getText('stores');
  String get products => _getText('products');
  String get sales => _getText('sales');
  String get registeredUsers => _getText('registeredUsers');
  String get searchUsers => _getText('searchUsers');
  String get filterByRole => _getText('filterByRole');
  String get allRoles => _getText('allRoles');
  String get noUsersFound => _getText('noUsersFound');
  String get noUsersRegistered => _getText('noUsersRegistered');
  String get clearFilters => _getText('clearFilters');
  String get refresh => _getText('refresh');
  String get viewDetails => _getText('viewDetails');
  String get years => _getText('years');
  String get registeredDate => _getText('registeredDate');
  String get close => _getText('close');
  String get errorLoadingUsers => _getText('errorLoadingUsers');
  String get comingSoon => _getText('comingSoon');
  String get storesFeatureDescription => _getText('storesFeatureDescription');
  String get registerStoreDescription => _getText('registerStoreDescription');
  String get productsFeatureDescription => _getText('productsFeatureDescription');
  String get registerProductDescription => _getText('registerProductDescription');
  String get profile => _getText('profile');
  String get personalInformation => _getText('personalInformation');
  String get accountInformation => _getText('accountInformation');
  String get userId => _getText('userId');
  String get accountActions => _getText('accountActions');
  String get logoutConfirmation => _getText('logoutConfirmation');
  String get changeLanguageInSettings => _getText('changeLanguageInSettings');
  String get home => _getText('home');
  String get selectStore => _getText('selectStore');
  String get sessionClosed => _getText('sessionClosed');
  String get darkMode => _getText('darkMode');
  String get version => _getText('version');
  String get store => _getText('store');
  String get product => _getText('product');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
