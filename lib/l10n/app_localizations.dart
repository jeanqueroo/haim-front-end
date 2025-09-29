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
    'welcome': 'Bienvenido',
    'dashboard': 'Panel de Control',
    'settings': 'Configuración',
    'home': 'Inicio',
    'profile': 'Perfil',
    'stores': 'Tiendas',
    'registerStore': 'Registrar Tienda',
    'selectStore': 'Seleccionar Tienda',
    'users': 'Usuarios',
    'registerProduct': 'Registrar Producto',
    'logout': 'Cerrar Sesión',
    'logoutConfirmation': '¿Estás seguro de que quieres cerrar sesión?',
    'sessionClosed': 'Sesión cerrada',
    'darkMode': 'Modo Oscuro',
    'version': 'Versión',
    'hello': 'Hola',
    'welcomeToDashboard': 'Bienvenido al Panel de Control',
    'quickActions': 'Acciones Rápidas',
    'createNewUser': 'Crear Nuevo Usuario',
    'viewUsers': 'Ver Usuarios',
    'manageUsers': 'Gestionar Usuarios',
    'addNewStore': 'Agregar Nueva Tienda',
    'addProducts': 'Agregar Productos',
    'viewStores': 'Ver Tiendas',
    'manageStores': 'Gestionar Tiendas',
    'statistics': 'Estadísticas',
    'products': 'Productos',
    'sales': 'Ventas',
    'personalInformation': 'Información Personal',
    'accountInformation': 'Información de la Cuenta',
    'userId': 'ID de Usuario',
    'registeredDate': 'Fecha de Registro',
    'currentLanguage': 'Idioma Actual',
    'changeLanguageInSettings': 'Cambiar idioma en Configuración',
    'accountActions': 'Acciones de la Cuenta',
    'comingSoon': 'Próximamente',
    'registerProductDescription': 'Registra nuevos productos en el sistema',
    'selectLanguageDescription': 'Selecciona tu idioma preferido',
    'information': 'Información',
    'languageChangeNote': 'El cambio de idioma se aplicará al reiniciar la aplicación',
    'editUser': 'Editar Usuario',
    'firstNameRequired': 'El nombre es obligatorio',
    'lastNameRequired': 'Los apellidos son obligatorios',
    'emailRequired': 'El email es obligatorio',
    'ageRequired': 'La edad es obligatoria',
    'invalidAge': 'Edad inválida',
    'saving': 'Guardando...',
    'rolesRequired': 'Los roles son obligatorios',
    'errorUpdatingUser': 'Error al actualizar usuario',
    'registeredUsers': 'Usuarios Registrados',
    'searchUsers': 'Buscar usuarios...',
    'filterByRole': 'Filtrar por rol',
    'allRoles': 'Todos los roles',
    'noUsersFound': 'No se encontraron usuarios',
    'noUsersRegistered': 'No hay usuarios registrados',
    'viewDetails': 'Ver Detalles',
    'years': 'años',
    'close': 'Cerrar',
    'userUpdatedSuccessfully': 'Usuario actualizado exitosamente',
    'welcomeSubtitle': 'Gestiona tu negocio de manera eficiente',
    'getStarted': 'Comenzar',
    'loginToAccess': 'Inicia sesión para acceder',
    'selectStoreForUsers': 'Seleccionar Tienda para Usuarios',
    'searchStores': 'Buscar tiendas...',
    'noStoresFound': 'No se encontraron tiendas',
    'noStoresRegistered': 'No hay tiendas registradas',
    'noStoresWithFilters': 'No se encontraron tiendas con los filtros aplicados',
    'workersForStore': 'Trabajadores de la Tienda',
    'searchWorkers': 'Buscar trabajadores...',
    'noWorkersFound': 'No se encontraron trabajadores',
    'noWorkersInStore': 'No hay trabajadores en esta tienda',
    'noWorkersWithFilters': 'No se encontraron trabajadores con los filtros aplicados',
    'addWorker': 'Agregar Trabajador',
    'addFirstWorker': 'Agregar Primer Trabajador',
    'deleteUser': 'Eliminar Usuario',
    'confirmDeleteUser': '¿Estás seguro de que quieres eliminar al usuario',
    'userDeletedSuccessfully': 'Usuario eliminado exitosamente',
    'errorDeletingUser': 'Error al eliminar usuario',
    'phone': 'Teléfono',
    'allStoreTypes': 'Todos los tipos de tienda',
    'allCountries': 'Todos los países',
    'search': 'Búsqueda',
    'selectedWorker': 'Trabajador Seleccionado',
    'selectWorkerToViewDetails': 'Selecciona un trabajador para ver sus detalles',
    'selectedWorkersCount': 'Trabajadores Seleccionados',
    'selectWorkersToSend': 'Selecciona trabajadores para enviar',
    'selectWorkersFirst': 'Primero selecciona trabajadores',
    'confirmSendWorkers': 'Confirmar Envío de Trabajadores',
    'workersToSend': 'Trabajadores a enviar:',
    'andMore': 'y {count} más',
    'send': 'Enviar',
    'sendSelected': 'Enviar Seleccionados',
    'workersSentSuccessfully': 'Trabajadores enviados exitosamente',
    'errorSendingWorkers': 'Error al enviar trabajadores',
    'clearSelection': 'Limpiar Selección',
    'selectAll': 'Seleccionar Todos',
    'someErrorsOccurred': 'Algunos errores ocurrieron',
    'errorsOccurred': 'Errores Ocurridos',
    'loginSuccess': 'Inicio de sesión exitoso',
    'loginError': 'Error al iniciar sesión',
    'invalidCredentials': 'Credenciales inválidas',
    'userRegisteredSuccessfully': 'Usuario registrado exitosamente',
    'registrationError': 'Error al registrar usuario',
    'connectionError': 'Error de conexión. Verifica tu conexión a internet',
    'serverError': 'Error del servidor',
    'tryAgain': 'Intentar de nuevo',
    'cancel': 'Cancelar',
    'save': 'Guardar',
    'edit': 'Editar',
    'delete': 'Eliminar',
    'confirm': 'Confirmar',
    'yes': 'Sí',
    'no': 'No',
    'spain': 'España',
    'unitedStates': 'Estados Unidos',
    'countryRequired': 'El país es obligatorio',
    'storeType': 'Tipo de tienda',
    'selectStoreType': 'Selecciona un tipo de tienda',
    'truck': 'Camión',
    'store': 'Tienda',
    'supermarket': 'Supermercado',
    'restaurant': 'Restaurante',
    'storeTypeRequired': 'El tipo de tienda es obligatorio',
    'storeAddress': 'Dirección de la tienda',
    'storeAddressHint': 'Ej: Calle Principal 123',
    'storeCountry': 'País',
    'storeCountryHint': 'Selecciona el país',
    'storePhone': 'Número de teléfono',
    'storePhoneHint': 'Ej: +1 234 567 8900',
    'addressRequired': 'La dirección es obligatoria',
    'phoneRequired': 'El número de teléfono es obligatorio',
    'invalidPhone': 'Formato de teléfono inválido',
    'tables': 'Mesas',
    'registerTable': 'Registrar Mesa',
    'tableNumber': 'Número de mesa',
    'capacity': 'Capacidad',
    'tableStatus': 'Estado de la mesa',
    'available': 'Disponible',
    'occupied': 'Ocupada',
    'reserved': 'Reservada',
    'maintenance': 'Mantenimiento',
    'tableNumberRequired': 'El número de mesa es obligatorio',
    'capacityRequired': 'La capacidad es obligatoria',
    'statusRequired': 'El estado de la mesa es obligatorio',
    'storeRequired': 'La tienda es obligatoria',
    'tableRegisteredSuccessfully': 'Mesa registrada exitosamente',
    'tableUpdatedSuccessfully': 'Mesa actualizada exitosamente',
    'tableDeletedSuccessfully': 'Mesa eliminada exitosamente',
    'registeringTable': 'Registrando mesa...',
    'updatingTable': 'Actualizando mesa...',
    'tableList': 'Lista de Mesas',
    'searchTables': 'Buscar mesas...',
    'noTablesFound': 'No se encontraron mesas',
    'addTable': 'Agregar Mesa',
    'editTable': 'Editar Mesa',
    'deleteTable': 'Eliminar Mesa',
    'confirmDeleteTable': '¿Estás seguro de que quieres eliminar esta mesa?',
    'tableCapacity': 'Capacidad de la mesa',
    'tableStatusAvailable': 'Disponible',
    'tableStatusOccupied': 'Ocupada',
    'tableStatusReserved': 'Reservada',
    'tableStatusMaintenance': 'Mantenimiento',
    'tableNumberHint': 'Ej: 1, 2, 3...',
    'capacityHint': 'Ej: 4, 6, 8...',
    'selectStatus': 'Selecciona un estado',
    'searchStore': 'Buscar y seleccionar tienda',
    'clearForm': 'Limpiar formulario',
    'resetForm': 'Restaurar valores originales',
    'updating': 'Actualizando...',
    'updateTable': 'Actualizar Mesa',
    'tableNumberExample': 'Ej: 1, 2, 3...',
    'capacityExample': 'Ej: 4, 6, 8...',
    'tableNumberLabel': 'Número de mesa',
    'capacityLabel': 'Capacidad',
    'statusLabel': 'Estado de la mesa',
    'storeLabel': 'Tienda',
    'registerNewTable': 'Registra una nueva mesa',
    'completeTableInfo': 'Completa la información de la mesa',
    'editTableTitle': 'Editar mesa: #',
    'modifyTableInfo': 'Modifica la información de la mesa',
    'tableNumberValidation': 'El número de mesa debe ser un número válido',
    'tableNumberPositive': 'El número de mesa debe ser mayor a 0',
    'capacityValidation': 'La capacidad debe ser un número válido',
    'capacityPositive': 'La capacidad debe ser mayor a 0',
    'capacityMax': 'La capacidad no puede ser mayor a 20 personas',
    'tableCreated': 'Mesa creada exitosamente',
    'tableModified': 'Mesa modificada exitosamente',
    'formCleared': 'Formulario limpiado correctamente',
    'formRestored': 'Formulario restaurado a los valores originales',
    'loadingStores': 'Cargando tiendas...',
    'errorLoadingStores': 'Error al cargar tiendas',
    'errorLoadingUsers': 'Error al cargar usuarios',
    'retry': 'Reintentar',
    'refresh': 'Actualizar',
    'filters': 'Filtros',
    'clearFilters': 'Limpiar filtros',
    'applyFilters': 'Aplicar filtros',
    'allStatuses': 'Todos los estados',
    'noTablesWithFilters': 'No se encontraron mesas con los filtros aplicados',
    'noTablesRegistered': 'No hay mesas registradas',
    'tryChangingFilters': 'Intenta cambiar los filtros o limpiar la búsqueda',
    'tapToAddTable': 'Toca el botón + para agregar una mesa',
    'tableInfo': 'Información de la mesa',
    'tableNumberInfo': 'Número de mesa',
    'capacityInfo': 'Capacidad',
    'statusInfo': 'Estado',
    'storeInfo': 'Tienda',
    'createdAt': 'Creado',
    'updatedAt': 'Actualizado',
    'people': 'personas',
    'table': 'Mesa',
    'tablesCount': 'mesas',
    'confirmDelete': 'Confirmar eliminación',
    'deleteConfirmation': '¿Estás seguro de que quieres eliminar la mesa #',
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
    'welcome': 'Welcome',
    'dashboard': 'Dashboard',
    'settings': 'Settings',
    'home': 'Home',
    'profile': 'Profile',
    'stores': 'Stores',
    'registerStore': 'Register Store',
    'selectStore': 'Select Store',
    'users': 'Users',
    'registerProduct': 'Register Product',
    'logout': 'Logout',
    'logoutConfirmation': 'Are you sure you want to logout?',
    'sessionClosed': 'Session closed',
    'darkMode': 'Dark Mode',
    'version': 'Version',
    'hello': 'Hello',
    'welcomeToDashboard': 'Welcome to Dashboard',
    'quickActions': 'Quick Actions',
    'createNewUser': 'Create New User',
    'viewUsers': 'View Users',
    'manageUsers': 'Manage Users',
    'addNewStore': 'Add New Store',
    'addProducts': 'Add Products',
    'viewStores': 'View Stores',
    'manageStores': 'Manage Stores',
    'statistics': 'Statistics',
    'products': 'Products',
    'sales': 'Sales',
    'personalInformation': 'Personal Information',
    'accountInformation': 'Account Information',
    'userId': 'User ID',
    'registeredDate': 'Registered Date',
    'currentLanguage': 'Current Language',
    'changeLanguageInSettings': 'Change language in Settings',
    'accountActions': 'Account Actions',
    'comingSoon': 'Coming Soon',
    'registerProductDescription': 'Register new products in the system',
    'selectLanguageDescription': 'Select your preferred language',
    'information': 'Information',
    'languageChangeNote': 'Language change will apply when restarting the app',
    'editUser': 'Edit User',
    'firstNameRequired': 'First name is required',
    'lastNameRequired': 'Last name is required',
    'emailRequired': 'Email is required',
    'ageRequired': 'Age is required',
    'invalidAge': 'Invalid age',
    'saving': 'Saving...',
    'rolesRequired': 'Roles are required',
    'errorUpdatingUser': 'Error updating user',
    'registeredUsers': 'Registered Users',
    'searchUsers': 'Search users...',
    'filterByRole': 'Filter by role',
    'allRoles': 'All roles',
    'noUsersFound': 'No users found',
    'noUsersRegistered': 'No users registered',
    'viewDetails': 'View Details',
    'years': 'years',
    'close': 'Close',
    'userUpdatedSuccessfully': 'User updated successfully',
    'welcomeSubtitle': 'Manage your business efficiently',
    'getStarted': 'Get Started',
    'loginToAccess': 'Login to access',
    'selectStoreForUsers': 'Select Store for Users',
    'searchStores': 'Search stores...',
    'noStoresFound': 'No stores found',
    'noStoresRegistered': 'No stores registered',
    'noStoresWithFilters': 'No stores found with applied filters',
    'workersForStore': 'Store Workers',
    'searchWorkers': 'Search workers...',
    'noWorkersFound': 'No workers found',
    'noWorkersInStore': 'No workers in this store',
    'noWorkersWithFilters': 'No workers found with applied filters',
    'addWorker': 'Add Worker',
    'addFirstWorker': 'Add First Worker',
    'deleteUser': 'Delete User',
    'confirmDeleteUser': 'Are you sure you want to delete user',
    'userDeletedSuccessfully': 'User deleted successfully',
    'errorDeletingUser': 'Error deleting user',
    'phone': 'Phone',
    'allStoreTypes': 'All store types',
    'allCountries': 'All countries',
    'search': 'Search',
    'selectedWorker': 'Selected Worker',
    'selectWorkerToViewDetails': 'Select a worker to view their details',
    'selectedWorkersCount': 'Selected Workers',
    'selectWorkersToSend': 'Select workers to send',
    'selectWorkersFirst': 'First select workers',
    'confirmSendWorkers': 'Confirm Send Workers',
    'workersToSend': 'Workers to send:',
    'andMore': 'and {count} more',
    'send': 'Send',
    'sendSelected': 'Send Selected',
    'workersSentSuccessfully': 'Workers sent successfully',
    'errorSendingWorkers': 'Error sending workers',
    'clearSelection': 'Clear Selection',
    'selectAll': 'Select All',
    'someErrorsOccurred': 'Some errors occurred',
    'errorsOccurred': 'Errors Occurred',
    'loginSuccess': 'Login successful',
    'loginError': 'Login error',
    'invalidCredentials': 'Invalid credentials',
    'userRegisteredSuccessfully': 'User registered successfully',
    'registrationError': 'Registration error',
    'connectionError': 'Connection error. Check your internet connection',
    'serverError': 'Server error',
    'tryAgain': 'Try again',
    'cancel': 'Cancel',
    'save': 'Save',
    'edit': 'Edit',
    'delete': 'Delete',
    'confirm': 'Confirm',
    'yes': 'Yes',
    'no': 'No',
    'spain': 'Spain',
    'unitedStates': 'United States',
    'countryRequired': 'Country is required',
    'storeType': 'Store Type',
    'selectStoreType': 'Select a store type',
    'truck': 'Truck',
    'store': 'Store',
    'supermarket': 'Supermarket',
    'restaurant': 'Restaurant',
    'storeTypeRequired': 'Store type is required',
    'storeAddress': 'Store Address',
    'storeAddressHint': 'Ex: Main Street 123',
    'storeCountry': 'Country',
    'storeCountryHint': 'Select country',
    'storePhone': 'Phone Number',
    'storePhoneHint': 'Ex: +1 234 567 8900',
    'addressRequired': 'Address is required',
    'phoneRequired': 'Phone number is required',
    'invalidPhone': 'Invalid phone format',
    'tables': 'Tables',
    'registerTable': 'Register Table',
    'tableNumber': 'Table Number',
    'capacity': 'Capacity',
    'tableStatus': 'Table Status',
    'available': 'Available',
    'occupied': 'Occupied',
    'reserved': 'Reserved',
    'maintenance': 'Maintenance',
    'tableNumberRequired': 'Table number is required',
    'capacityRequired': 'Capacity is required',
    'statusRequired': 'Table status is required',
    'storeRequired': 'Store is required',
    'tableRegisteredSuccessfully': 'Table registered successfully',
    'tableUpdatedSuccessfully': 'Table updated successfully',
    'tableDeletedSuccessfully': 'Table deleted successfully',
    'registeringTable': 'Registering table...',
    'updatingTable': 'Updating table...',
    'tableList': 'Tables List',
    'searchTables': 'Search tables...',
    'noTablesFound': 'No tables found',
    'addTable': 'Add Table',
    'editTable': 'Edit Table',
    'deleteTable': 'Delete Table',
    'confirmDeleteTable': 'Are you sure you want to delete this table?',
    'tableCapacity': 'Table capacity',
    'tableStatusAvailable': 'Available',
    'tableStatusOccupied': 'Occupied',
    'tableStatusReserved': 'Reserved',
    'tableStatusMaintenance': 'Maintenance',
    'tableNumberHint': 'Ex: 1, 2, 3...',
    'capacityHint': 'Ex: 4, 6, 8...',
    'selectStatus': 'Select a status',
    'searchStore': 'Search and select store',
    'clearForm': 'Clear form',
    'resetForm': 'Reset to original values',
    'updating': 'Updating...',
    'updateTable': 'Update Table',
    'tableNumberExample': 'Ex: 1, 2, 3...',
    'capacityExample': 'Ex: 4, 6, 8...',
    'tableNumberLabel': 'Table Number',
    'capacityLabel': 'Capacity',
    'statusLabel': 'Table Status',
    'storeLabel': 'Store',
    'registerNewTable': 'Register a new table',
    'completeTableInfo': 'Complete the table information',
    'editTableTitle': 'Edit table: #',
    'modifyTableInfo': 'Modify the table information',
    'tableNumberValidation': 'Table number must be a valid number',
    'tableNumberPositive': 'Table number must be greater than 0',
    'capacityValidation': 'Capacity must be a valid number',
    'capacityPositive': 'Capacity must be greater than 0',
    'capacityMax': 'Capacity cannot be greater than 20 people',
    'tableCreated': 'Table created successfully',
    'tableModified': 'Table modified successfully',
    'formCleared': 'Form cleared correctly',
    'formRestored': 'Form restored to original values',
    'loadingStores': 'Loading stores...',
    'errorLoadingStores': 'Error loading stores',
    'errorLoadingUsers': 'Error loading users',
    'retry': 'Retry',
    'refresh': 'Refresh',
    'filters': 'Filters',
    'clearFilters': 'Clear filters',
    'applyFilters': 'Apply filters',
    'allStatuses': 'All statuses',
    'noTablesWithFilters': 'No tables found with applied filters',
    'noTablesRegistered': 'No tables registered',
    'tryChangingFilters': 'Try changing filters or clear the search',
    'tapToAddTable': 'Tap the + button to add a table',
    'tableInfo': 'Table information',
    'tableNumberInfo': 'Table number',
    'capacityInfo': 'Capacity',
    'statusInfo': 'Status',
    'storeInfo': 'Store',
    'createdAt': 'Created',
    'updatedAt': 'Updated',
    'people': 'people',
    'table': 'Table',
    'tablesCount': 'tables',
    'confirmDelete': 'Confirm deletion',
    'deleteConfirmation': 'Are you sure you want to delete table #',
  };

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
  String get dashboard => _getText('dashboard');
  String get settings => _getText('settings');
  String get home => _getText('home');
  String get profile => _getText('profile');
  String get stores => _getText('stores');
  String get registerStore => _getText('registerStore');
  String get selectStore => _getText('selectStore');
  String get users => _getText('users');
  String get registerProduct => _getText('registerProduct');
  String get logout => _getText('logout');
  String get logoutConfirmation => _getText('logoutConfirmation');
  String get sessionClosed => _getText('sessionClosed');
  String get darkMode => _getText('darkMode');
  String get version => _getText('version');
  String get hello => _getText('hello');
  String get welcomeToDashboard => _getText('welcomeToDashboard');
  String get quickActions => _getText('quickActions');
  String get createNewUser => _getText('createNewUser');
  String get viewUsers => _getText('viewUsers');
  String get manageUsers => _getText('manageUsers');
  String get addNewStore => _getText('addNewStore');
  String get addProducts => _getText('addProducts');
  String get viewStores => _getText('viewStores');
  String get manageStores => _getText('manageStores');
  String get statistics => _getText('statistics');
  String get products => _getText('products');
  String get sales => _getText('sales');
  String get personalInformation => _getText('personalInformation');
  String get accountInformation => _getText('accountInformation');
  String get userId => _getText('userId');
  String get registeredDate => _getText('registeredDate');
  String get currentLanguage => _getText('currentLanguage');
  String get changeLanguageInSettings => _getText('changeLanguageInSettings');
  String get accountActions => _getText('accountActions');
  String get comingSoon => _getText('comingSoon');
  String get registerProductDescription => _getText('registerProductDescription');
  String get selectLanguageDescription => _getText('selectLanguageDescription');
  String get information => _getText('information');
  String get languageChangeNote => _getText('languageChangeNote');
  String get editUser => _getText('editUser');
  String get firstNameRequired => _getText('firstNameRequired');
  String get lastNameRequired => _getText('lastNameRequired');
  String get emailRequired => _getText('emailRequired');
  String get ageRequired => _getText('ageRequired');
  String get invalidAge => _getText('invalidAge');
  String get saving => _getText('saving');
  String get rolesRequired => _getText('rolesRequired');
  String get errorUpdatingUser => _getText('errorUpdatingUser');
  String get registeredUsers => _getText('registeredUsers');
  String get searchUsers => _getText('searchUsers');
  String get filterByRole => _getText('filterByRole');
  String get allRoles => _getText('allRoles');
  String get noUsersFound => _getText('noUsersFound');
  String get noUsersRegistered => _getText('noUsersRegistered');
  String get viewDetails => _getText('viewDetails');
  String get years => _getText('years');
  String get close => _getText('close');
  String get userUpdatedSuccessfully => _getText('userUpdatedSuccessfully');
  String get welcomeSubtitle => _getText('welcomeSubtitle');
  String get getStarted => _getText('getStarted');
  String get loginToAccess => _getText('loginToAccess');
  String get selectStoreForUsers => _getText('selectStoreForUsers');
  String get searchStores => _getText('searchStores');
  String get noStoresFound => _getText('noStoresFound');
  String get noStoresRegistered => _getText('noStoresRegistered');
  String get noStoresWithFilters => _getText('noStoresWithFilters');
  String get workersForStore => _getText('workersForStore');
  String get searchWorkers => _getText('searchWorkers');
  String get noWorkersFound => _getText('noWorkersFound');
  String get noWorkersInStore => _getText('noWorkersInStore');
  String get noWorkersWithFilters => _getText('noWorkersWithFilters');
  String get addWorker => _getText('addWorker');
  String get addFirstWorker => _getText('addFirstWorker');
  String get deleteUser => _getText('deleteUser');
  String get confirmDeleteUser => _getText('confirmDeleteUser');
  String get userDeletedSuccessfully => _getText('userDeletedSuccessfully');
  String get errorDeletingUser => _getText('errorDeletingUser');
  String get phone => _getText('phone');
  String get allStoreTypes => _getText('allStoreTypes');
  String get allCountries => _getText('allCountries');
  String get search => _getText('search');
  String get selectedWorker => _getText('selectedWorker');
  String get selectWorkerToViewDetails => _getText('selectWorkerToViewDetails');
  String get selectedWorkersCount => _getText('selectedWorkersCount');
  String get selectWorkersToSend => _getText('selectWorkersToSend');
  String get selectWorkersFirst => _getText('selectWorkersFirst');
  String get confirmSendWorkers => _getText('confirmSendWorkers');
  String get workersToSend => _getText('workersToSend');
  String get andMore => _getText('andMore');
  String get send => _getText('send');
  String get sendSelected => _getText('sendSelected');
  String get workersSentSuccessfully => _getText('workersSentSuccessfully');
  String get errorSendingWorkers => _getText('errorSendingWorkers');
  String get clearSelection => _getText('clearSelection');
  String get selectAll => _getText('selectAll');
  String get someErrorsOccurred => _getText('someErrorsOccurred');
  String get errorsOccurred => _getText('errorsOccurred');
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
  String get spain => _getText('spain');
  String get unitedStates => _getText('unitedStates');
  String get countryRequired => _getText('countryRequired');
  String get storeType => _getText('storeType');
  String get selectStoreType => _getText('selectStoreType');
  String get truck => _getText('truck');
  String get store => _getText('store');
  String get supermarket => _getText('supermarket');
  String get restaurant => _getText('restaurant');
  String get storeTypeRequired => _getText('storeTypeRequired');
  String get storeAddress => _getText('storeAddress');
  String get storeAddressHint => _getText('storeAddressHint');
  String get storeCountry => _getText('storeCountry');
  String get storeCountryHint => _getText('storeCountryHint');
  String get storePhone => _getText('storePhone');
  String get storePhoneHint => _getText('storePhoneHint');
  String get addressRequired => _getText('addressRequired');
  String get phoneRequired => _getText('phoneRequired');
  String get invalidPhone => _getText('invalidPhone');
  String get tables => _getText('tables');
  String get registerTable => _getText('registerTable');
  String get tableNumber => _getText('tableNumber');
  String get capacity => _getText('capacity');
  String get tableStatus => _getText('tableStatus');
  String get available => _getText('available');
  String get occupied => _getText('occupied');
  String get reserved => _getText('reserved');
  String get maintenance => _getText('maintenance');
  String get tableNumberRequired => _getText('tableNumberRequired');
  String get capacityRequired => _getText('capacityRequired');
  String get statusRequired => _getText('statusRequired');
  String get storeRequired => _getText('storeRequired');
  String get tableRegisteredSuccessfully => _getText('tableRegisteredSuccessfully');
  String get tableUpdatedSuccessfully => _getText('tableUpdatedSuccessfully');
  String get tableDeletedSuccessfully => _getText('tableDeletedSuccessfully');
  String get registeringTable => _getText('registeringTable');
  String get updatingTable => _getText('updatingTable');
  String get tableList => _getText('tableList');
  String get searchTables => _getText('searchTables');
  String get noTablesFound => _getText('noTablesFound');
  String get addTable => _getText('addTable');
  String get editTable => _getText('editTable');
  String get deleteTable => _getText('deleteTable');
  String get confirmDeleteTable => _getText('confirmDeleteTable');
  String get tableCapacity => _getText('tableCapacity');
  String get tableStatusAvailable => _getText('tableStatusAvailable');
  String get tableStatusOccupied => _getText('tableStatusOccupied');
  String get tableStatusReserved => _getText('tableStatusReserved');
  String get tableStatusMaintenance => _getText('tableStatusMaintenance');
  String get tableNumberHint => _getText('tableNumberHint');
  String get capacityHint => _getText('capacityHint');
  String get selectStatus => _getText('selectStatus');
  String get searchStore => _getText('searchStore');
  String get clearForm => _getText('clearForm');
  String get resetForm => _getText('resetForm');
  String get updating => _getText('updating');
  String get updateTable => _getText('updateTable');
  String get tableNumberExample => _getText('tableNumberExample');
  String get capacityExample => _getText('capacityExample');
  String get tableNumberLabel => _getText('tableNumberLabel');
  String get capacityLabel => _getText('capacityLabel');
  String get statusLabel => _getText('statusLabel');
  String get storeLabel => _getText('storeLabel');
  String get registerNewTable => _getText('registerNewTable');
  String get completeTableInfo => _getText('completeTableInfo');
  String get editTableTitle => _getText('editTableTitle');
  String get modifyTableInfo => _getText('modifyTableInfo');
  String get tableNumberValidation => _getText('tableNumberValidation');
  String get tableNumberPositive => _getText('tableNumberPositive');
  String get capacityValidation => _getText('capacityValidation');
  String get capacityPositive => _getText('capacityPositive');
  String get capacityMax => _getText('capacityMax');
  String get tableCreated => _getText('tableCreated');
  String get tableModified => _getText('tableModified');
  String get formCleared => _getText('formCleared');
  String get formRestored => _getText('formRestored');
  String get loadingStores => _getText('loadingStores');
  String get errorLoadingStores => _getText('errorLoadingStores');
  String get errorLoadingUsers => _getText('errorLoadingUsers');
  String get retry => _getText('retry');
  String get refresh => _getText('refresh');
  String get filters => _getText('filters');
  String get clearFilters => _getText('clearFilters');
  String get applyFilters => _getText('applyFilters');
  String get allStatuses => _getText('allStatuses');
  String get noTablesWithFilters => _getText('noTablesWithFilters');
  String get noTablesRegistered => _getText('noTablesRegistered');
  String get tryChangingFilters => _getText('tryChangingFilters');
  String get tapToAddTable => _getText('tapToAddTable');
  String get tableInfo => _getText('tableInfo');
  String get tableNumberInfo => _getText('tableNumberInfo');
  String get capacityInfo => _getText('capacityInfo');
  String get statusInfo => _getText('statusInfo');
  String get storeInfo => _getText('storeInfo');
  String get createdAt => _getText('createdAt');
  String get updatedAt => _getText('updatedAt');
  String get people => _getText('people');
  String get table => _getText('table');
  String get tablesCount => _getText('tablesCount');
  String get confirmDelete => _getText('confirmDelete');
  String get deleteConfirmation => _getText('deleteConfirmation');

  String _getText(String key) {
    if (locale.languageCode == 'es') {
      return _es[key] ?? key;
    } else {
      return _en[key] ?? key;
    }
  }
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
