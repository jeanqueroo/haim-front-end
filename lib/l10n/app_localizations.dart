import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Haim App'**
  String get appTitle;

  /// No description provided for @registerUser.
  ///
  /// In en, this message translates to:
  /// **'Register User'**
  String get registerUser;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @roles.
  ///
  /// In en, this message translates to:
  /// **'Roles'**
  String get roles;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get admin;

  /// No description provided for @vendedor.
  ///
  /// In en, this message translates to:
  /// **'Salesperson'**
  String get vendedor;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @registering.
  ///
  /// In en, this message translates to:
  /// **'Registering...'**
  String get registering;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalidEmail;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Minimum 6 characters'**
  String get passwordMinLength;

  /// No description provided for @mustBeNumber.
  ///
  /// In en, this message translates to:
  /// **'Must be a number'**
  String get mustBeNumber;

  /// No description provided for @mustBeGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Must be greater than 0'**
  String get mustBeGreaterThanZero;

  /// No description provided for @selectGender.
  ///
  /// In en, this message translates to:
  /// **'Select gender'**
  String get selectGender;

  /// No description provided for @selectAtLeastOneRole.
  ///
  /// In en, this message translates to:
  /// **'Select at least one role'**
  String get selectAtLeastOneRole;

  /// No description provided for @checkEmailAvailability.
  ///
  /// In en, this message translates to:
  /// **'Check email availability'**
  String get checkEmailAvailability;

  /// No description provided for @emailAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered'**
  String get emailAlreadyRegistered;

  /// No description provided for @errorCheckingEmail.
  ///
  /// In en, this message translates to:
  /// **'Error checking email'**
  String get errorCheckingEmail;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error'**
  String get unexpectedError;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get selectLanguage;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get spanish;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get loginSuccess;

  /// No description provided for @loginError.
  ///
  /// In en, this message translates to:
  /// **'Login error'**
  String get loginError;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials'**
  String get invalidCredentials;

  /// No description provided for @userRegisteredSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'User registered successfully'**
  String get userRegisteredSuccessfully;

  /// No description provided for @registrationError.
  ///
  /// In en, this message translates to:
  /// **'Registration error'**
  String get registrationError;

  /// No description provided for @connectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection error. Check your internet connection'**
  String get connectionError;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error'**
  String get serverError;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @spain.
  ///
  /// In en, this message translates to:
  /// **'Spain'**
  String get spain;

  /// No description provided for @unitedStates.
  ///
  /// In en, this message translates to:
  /// **'United States'**
  String get unitedStates;

  /// No description provided for @countryRequired.
  ///
  /// In en, this message translates to:
  /// **'Country is required'**
  String get countryRequired;

  /// No description provided for @storeType.
  ///
  /// In en, this message translates to:
  /// **'Store Type'**
  String get storeType;

  /// No description provided for @selectStoreType.
  ///
  /// In en, this message translates to:
  /// **'Select a store type'**
  String get selectStoreType;

  /// No description provided for @truck.
  ///
  /// In en, this message translates to:
  /// **'Truck'**
  String get truck;

  /// No description provided for @store.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get store;

  /// No description provided for @supermarket.
  ///
  /// In en, this message translates to:
  /// **'Supermarket'**
  String get supermarket;

  /// No description provided for @restaurant.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get restaurant;

  /// No description provided for @storeTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Store type is required'**
  String get storeTypeRequired;

  /// No description provided for @storeAddress.
  ///
  /// In en, this message translates to:
  /// **'Store Address'**
  String get storeAddress;

  /// No description provided for @storeAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: Main Street 123'**
  String get storeAddressHint;

  /// No description provided for @storeCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get storeCountry;

  /// No description provided for @storeCountryHint.
  ///
  /// In en, this message translates to:
  /// **'Select country'**
  String get storeCountryHint;

  /// No description provided for @storePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get storePhone;

  /// No description provided for @storePhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: +1 234 567 8900'**
  String get storePhoneHint;

  /// No description provided for @addressRequired.
  ///
  /// In en, this message translates to:
  /// **'Address is required'**
  String get addressRequired;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneRequired;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone format'**
  String get invalidPhone;

  /// No description provided for @tables.
  ///
  /// In en, this message translates to:
  /// **'Tables'**
  String get tables;

  /// No description provided for @registerTable.
  ///
  /// In en, this message translates to:
  /// **'Register Table'**
  String get registerTable;

  /// No description provided for @tableNumber.
  ///
  /// In en, this message translates to:
  /// **'Table Number'**
  String get tableNumber;

  /// No description provided for @capacity.
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get capacity;

  /// No description provided for @tableStatus.
  ///
  /// In en, this message translates to:
  /// **'Table Status'**
  String get tableStatus;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @occupied.
  ///
  /// In en, this message translates to:
  /// **'Occupied'**
  String get occupied;

  /// No description provided for @reserved.
  ///
  /// In en, this message translates to:
  /// **'Reserved'**
  String get reserved;

  /// No description provided for @maintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get maintenance;

  /// No description provided for @tableNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Table number is required'**
  String get tableNumberRequired;

  /// No description provided for @capacityRequired.
  ///
  /// In en, this message translates to:
  /// **'Capacity is required'**
  String get capacityRequired;

  /// No description provided for @statusRequired.
  ///
  /// In en, this message translates to:
  /// **'Table status is required'**
  String get statusRequired;

  /// No description provided for @storeRequired.
  ///
  /// In en, this message translates to:
  /// **'Store is required'**
  String get storeRequired;

  /// No description provided for @tableRegisteredSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Table registered successfully'**
  String get tableRegisteredSuccessfully;

  /// No description provided for @tableUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Table updated successfully'**
  String get tableUpdatedSuccessfully;

  /// No description provided for @tableDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Table deleted successfully'**
  String get tableDeletedSuccessfully;

  /// No description provided for @registeringTable.
  ///
  /// In en, this message translates to:
  /// **'Registering table...'**
  String get registeringTable;

  /// No description provided for @updatingTable.
  ///
  /// In en, this message translates to:
  /// **'Updating table...'**
  String get updatingTable;

  /// No description provided for @tableList.
  ///
  /// In en, this message translates to:
  /// **'Tables List'**
  String get tableList;

  /// No description provided for @searchTables.
  ///
  /// In en, this message translates to:
  /// **'Search tables...'**
  String get searchTables;

  /// No description provided for @noTablesFound.
  ///
  /// In en, this message translates to:
  /// **'No tables found'**
  String get noTablesFound;

  /// No description provided for @addTable.
  ///
  /// In en, this message translates to:
  /// **'Add Table'**
  String get addTable;

  /// No description provided for @editTable.
  ///
  /// In en, this message translates to:
  /// **'Edit Table'**
  String get editTable;

  /// No description provided for @deleteTable.
  ///
  /// In en, this message translates to:
  /// **'Delete Table'**
  String get deleteTable;

  /// No description provided for @confirmDeleteTable.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this table?'**
  String get confirmDeleteTable;

  /// No description provided for @tableCapacity.
  ///
  /// In en, this message translates to:
  /// **'Table capacity'**
  String get tableCapacity;

  /// No description provided for @tableStatusAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get tableStatusAvailable;

  /// No description provided for @tableStatusOccupied.
  ///
  /// In en, this message translates to:
  /// **'Occupied'**
  String get tableStatusOccupied;

  /// No description provided for @tableStatusReserved.
  ///
  /// In en, this message translates to:
  /// **'Reserved'**
  String get tableStatusReserved;

  /// No description provided for @tableStatusMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get tableStatusMaintenance;

  /// No description provided for @tableNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: 1, 2, 3...'**
  String get tableNumberHint;

  /// No description provided for @capacityHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: 4, 6, 8...'**
  String get capacityHint;

  /// No description provided for @selectStatus.
  ///
  /// In en, this message translates to:
  /// **'Select a status'**
  String get selectStatus;

  /// No description provided for @searchStore.
  ///
  /// In en, this message translates to:
  /// **'Search and select store'**
  String get searchStore;

  /// No description provided for @clearForm.
  ///
  /// In en, this message translates to:
  /// **'Clear form'**
  String get clearForm;

  /// No description provided for @resetForm.
  ///
  /// In en, this message translates to:
  /// **'Reset to original values'**
  String get resetForm;

  /// No description provided for @updating.
  ///
  /// In en, this message translates to:
  /// **'Updating...'**
  String get updating;

  /// No description provided for @updateTable.
  ///
  /// In en, this message translates to:
  /// **'Update Table'**
  String get updateTable;

  /// No description provided for @tableNumberExample.
  ///
  /// In en, this message translates to:
  /// **'Ex: 1, 2, 3...'**
  String get tableNumberExample;

  /// No description provided for @capacityExample.
  ///
  /// In en, this message translates to:
  /// **'Ex: 4, 6, 8...'**
  String get capacityExample;

  /// No description provided for @tableNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Table Number'**
  String get tableNumberLabel;

  /// No description provided for @capacityLabel.
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get capacityLabel;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Table Status'**
  String get statusLabel;

  /// No description provided for @storeLabel.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get storeLabel;

  /// No description provided for @registerNewTable.
  ///
  /// In en, this message translates to:
  /// **'Register a new table'**
  String get registerNewTable;

  /// No description provided for @completeTableInfo.
  ///
  /// In en, this message translates to:
  /// **'Complete the table information'**
  String get completeTableInfo;

  /// No description provided for @editTableTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit table: #'**
  String get editTableTitle;

  /// No description provided for @modifyTableInfo.
  ///
  /// In en, this message translates to:
  /// **'Modify the table information'**
  String get modifyTableInfo;

  /// No description provided for @tableNumberValidation.
  ///
  /// In en, this message translates to:
  /// **'Table number must be a valid number'**
  String get tableNumberValidation;

  /// No description provided for @tableNumberPositive.
  ///
  /// In en, this message translates to:
  /// **'Table number must be greater than 0'**
  String get tableNumberPositive;

  /// No description provided for @capacityValidation.
  ///
  /// In en, this message translates to:
  /// **'Capacity must be a valid number'**
  String get capacityValidation;

  /// No description provided for @capacityPositive.
  ///
  /// In en, this message translates to:
  /// **'Capacity must be greater than 0'**
  String get capacityPositive;

  /// No description provided for @capacityMax.
  ///
  /// In en, this message translates to:
  /// **'Capacity cannot be greater than 20 people'**
  String get capacityMax;

  /// No description provided for @selectStore.
  ///
  /// In en, this message translates to:
  /// **'Select Store'**
  String get selectStore;

  /// No description provided for @tableCreated.
  ///
  /// In en, this message translates to:
  /// **'Table created successfully'**
  String get tableCreated;

  /// No description provided for @tableModified.
  ///
  /// In en, this message translates to:
  /// **'Table modified successfully'**
  String get tableModified;

  /// No description provided for @formCleared.
  ///
  /// In en, this message translates to:
  /// **'Form cleared correctly'**
  String get formCleared;

  /// No description provided for @formRestored.
  ///
  /// In en, this message translates to:
  /// **'Form restored to original values'**
  String get formRestored;

  /// No description provided for @loadingStores.
  ///
  /// In en, this message translates to:
  /// **'Loading stores...'**
  String get loadingStores;

  /// No description provided for @errorLoadingStores.
  ///
  /// In en, this message translates to:
  /// **'Error loading stores'**
  String get errorLoadingStores;

  /// No description provided for @errorLoadingUsers.
  ///
  /// In en, this message translates to:
  /// **'Error loading users'**
  String get errorLoadingUsers;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply filters'**
  String get applyFilters;

  /// No description provided for @allStatuses.
  ///
  /// In en, this message translates to:
  /// **'All statuses'**
  String get allStatuses;

  /// No description provided for @noTablesWithFilters.
  ///
  /// In en, this message translates to:
  /// **'No tables found with applied filters'**
  String get noTablesWithFilters;

  /// No description provided for @noTablesRegistered.
  ///
  /// In en, this message translates to:
  /// **'No tables registered'**
  String get noTablesRegistered;

  /// No description provided for @tryChangingFilters.
  ///
  /// In en, this message translates to:
  /// **'Try changing filters or clear the search'**
  String get tryChangingFilters;

  /// No description provided for @tapToAddTable.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add a table'**
  String get tapToAddTable;

  /// No description provided for @tableInfo.
  ///
  /// In en, this message translates to:
  /// **'Table information'**
  String get tableInfo;

  /// No description provided for @tableNumberInfo.
  ///
  /// In en, this message translates to:
  /// **'Table number'**
  String get tableNumberInfo;

  /// No description provided for @capacityInfo.
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get capacityInfo;

  /// No description provided for @statusInfo.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusInfo;

  /// No description provided for @storeInfo.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get storeInfo;

  /// No description provided for @createdAt.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get createdAt;

  /// No description provided for @updatedAt.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get updatedAt;

  /// No description provided for @people.
  ///
  /// In en, this message translates to:
  /// **'people'**
  String get people;

  /// No description provided for @table.
  ///
  /// In en, this message translates to:
  /// **'Table'**
  String get table;

  /// No description provided for @tablesCount.
  ///
  /// In en, this message translates to:
  /// **'tables'**
  String get tablesCount;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm deletion'**
  String get confirmDelete;

  /// No description provided for @deleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete table #'**
  String get deleteConfirmation;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @stores.
  ///
  /// In en, this message translates to:
  /// **'Stores'**
  String get stores;

  /// No description provided for @registerStore.
  ///
  /// In en, this message translates to:
  /// **'Register Store'**
  String get registerStore;

  /// No description provided for @selectStoreForUsers.
  ///
  /// In en, this message translates to:
  /// **'Select Store for Users'**
  String get selectStoreForUsers;

  /// No description provided for @registerProduct.
  ///
  /// In en, this message translates to:
  /// **'Register Product'**
  String get registerProduct;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmation;

  /// No description provided for @sessionClosed.
  ///
  /// In en, this message translates to:
  /// **'Session closed'**
  String get sessionClosed;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @information.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get information;

  /// No description provided for @selectLanguageDescription.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language'**
  String get selectLanguageDescription;

  /// No description provided for @currentLanguage.
  ///
  /// In en, this message translates to:
  /// **'Current Language'**
  String get currentLanguage;

  /// No description provided for @languageChangeNote.
  ///
  /// In en, this message translates to:
  /// **'Language changes will be applied after restarting the app'**
  String get languageChangeNote;

  /// No description provided for @registeredUsers.
  ///
  /// In en, this message translates to:
  /// **'Registered Users'**
  String get registeredUsers;

  /// No description provided for @searchUsers.
  ///
  /// In en, this message translates to:
  /// **'Search users...'**
  String get searchUsers;

  /// No description provided for @filterByRole.
  ///
  /// In en, this message translates to:
  /// **'Filter by role'**
  String get filterByRole;

  /// No description provided for @allRoles.
  ///
  /// In en, this message translates to:
  /// **'All roles'**
  String get allRoles;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @searchStores.
  ///
  /// In en, this message translates to:
  /// **'Search stores...'**
  String get searchStores;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @noStoresFound.
  ///
  /// In en, this message translates to:
  /// **'No stores found'**
  String get noStoresFound;

  /// No description provided for @noStoresRegistered.
  ///
  /// In en, this message translates to:
  /// **'No stores registered'**
  String get noStoresRegistered;

  /// No description provided for @noStoresWithFilters.
  ///
  /// In en, this message translates to:
  /// **'No stores found with applied filters'**
  String get noStoresWithFilters;

  /// No description provided for @allStoreTypes.
  ///
  /// In en, this message translates to:
  /// **'All store types'**
  String get allStoreTypes;

  /// No description provided for @allCountries.
  ///
  /// In en, this message translates to:
  /// **'All countries'**
  String get allCountries;

  /// No description provided for @editUser.
  ///
  /// In en, this message translates to:
  /// **'Edit User'**
  String get editUser;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @firstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'First name is required'**
  String get firstNameRequired;

  /// No description provided for @lastNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Last name is required'**
  String get lastNameRequired;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @ageRequired.
  ///
  /// In en, this message translates to:
  /// **'Age is required'**
  String get ageRequired;

  /// No description provided for @invalidAge.
  ///
  /// In en, this message translates to:
  /// **'Invalid age'**
  String get invalidAge;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @rolesRequired.
  ///
  /// In en, this message translates to:
  /// **'At least one role is required'**
  String get rolesRequired;

  /// No description provided for @errorUpdatingUser.
  ///
  /// In en, this message translates to:
  /// **'Error updating user'**
  String get errorUpdatingUser;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @registerProductDescription.
  ///
  /// In en, this message translates to:
  /// **'Product registration functionality will be available soon'**
  String get registerProductDescription;

  /// No description provided for @noWorkersFound.
  ///
  /// In en, this message translates to:
  /// **'No workers found'**
  String get noWorkersFound;

  /// No description provided for @noWorkersInStore.
  ///
  /// In en, this message translates to:
  /// **'No workers in this store'**
  String get noWorkersInStore;

  /// No description provided for @selectWorkersToSend.
  ///
  /// In en, this message translates to:
  /// **'Select workers to send'**
  String get selectWorkersToSend;

  /// No description provided for @noWorkersWithFilters.
  ///
  /// In en, this message translates to:
  /// **'No workers found with applied filters'**
  String get noWorkersWithFilters;

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get years;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to our application'**
  String get welcomeSubtitle;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @loginToAccess.
  ///
  /// In en, this message translates to:
  /// **'Login to access'**
  String get loginToAccess;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// No description provided for @welcomeToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Dashboard'**
  String get welcomeToDashboard;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @createNewUser.
  ///
  /// In en, this message translates to:
  /// **'Create new user'**
  String get createNewUser;

  /// No description provided for @viewUsers.
  ///
  /// In en, this message translates to:
  /// **'View Users'**
  String get viewUsers;

  /// No description provided for @manageUsers.
  ///
  /// In en, this message translates to:
  /// **'Manage users'**
  String get manageUsers;

  /// No description provided for @addNewStore.
  ///
  /// In en, this message translates to:
  /// **'Add new store'**
  String get addNewStore;

  /// No description provided for @addProducts.
  ///
  /// In en, this message translates to:
  /// **'Add products'**
  String get addProducts;

  /// No description provided for @viewStores.
  ///
  /// In en, this message translates to:
  /// **'View Stores'**
  String get viewStores;

  /// No description provided for @manageStores.
  ///
  /// In en, this message translates to:
  /// **'Manage stores'**
  String get manageStores;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @sales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get sales;

  /// No description provided for @accountInformation.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get accountInformation;

  /// No description provided for @userId.
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get userId;

  /// No description provided for @registeredDate.
  ///
  /// In en, this message translates to:
  /// **'Registered Date'**
  String get registeredDate;

  /// No description provided for @changeLanguageInSettings.
  ///
  /// In en, this message translates to:
  /// **'Change language in settings'**
  String get changeLanguageInSettings;

  /// No description provided for @accountActions.
  ///
  /// In en, this message translates to:
  /// **'Account Actions'**
  String get accountActions;

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get noUsersFound;

  /// No description provided for @noUsersWithFilters.
  ///
  /// In en, this message translates to:
  /// **'No users found with applied filters'**
  String get noUsersWithFilters;

  /// No description provided for @selectWorkersFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select workers first'**
  String get selectWorkersFirst;

  /// No description provided for @confirmSendWorkers.
  ///
  /// In en, this message translates to:
  /// **'Confirm Send Workers'**
  String get confirmSendWorkers;

  /// No description provided for @selectedWorkersCount.
  ///
  /// In en, this message translates to:
  /// **'Selected Workers'**
  String get selectedWorkersCount;

  /// No description provided for @workersToSend.
  ///
  /// In en, this message translates to:
  /// **'Workers to send'**
  String get workersToSend;

  /// No description provided for @andMore.
  ///
  /// In en, this message translates to:
  /// **'and {count} more'**
  String andMore(Object count);

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @errorsOccurred.
  ///
  /// In en, this message translates to:
  /// **'Errors Occurred'**
  String get errorsOccurred;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @workersForStore.
  ///
  /// In en, this message translates to:
  /// **'Workers for Store'**
  String get workersForStore;

  /// No description provided for @clearSelection.
  ///
  /// In en, this message translates to:
  /// **'Clear Selection'**
  String get clearSelection;

  /// No description provided for @searchWorkers.
  ///
  /// In en, this message translates to:
  /// **'Search workers'**
  String get searchWorkers;

  /// No description provided for @locale.
  ///
  /// In en, this message translates to:
  /// **'Locale'**
  String get locale;

  /// No description provided for @noUsersRegistered.
  ///
  /// In en, this message translates to:
  /// **'No users registered'**
  String get noUsersRegistered;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @userUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'User updated successfully'**
  String get userUpdatedSuccessfully;

  /// No description provided for @deleteUser.
  ///
  /// In en, this message translates to:
  /// **'Delete User'**
  String get deleteUser;

  /// No description provided for @confirmDeleteUser.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete'**
  String get confirmDeleteUser;

  /// No description provided for @userDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'User deleted successfully'**
  String get userDeletedSuccessfully;

  /// No description provided for @errorDeletingUser.
  ///
  /// In en, this message translates to:
  /// **'Error deleting user'**
  String get errorDeletingUser;

  /// No description provided for @addWorker.
  ///
  /// In en, this message translates to:
  /// **'Add Worker'**
  String get addWorker;

  /// No description provided for @addFirstWorker.
  ///
  /// In en, this message translates to:
  /// **'Add First Worker'**
  String get addFirstWorker;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
