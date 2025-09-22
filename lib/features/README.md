# Estructura de Carpetas por Funcionalidad

Este directorio contiene todas las funcionalidades de la aplicación organizadas por módulos independientes.

## 📁 Estructura de Carpetas

```
lib/features/
├── auth/                    # Autenticación y login
│   ├── pages/              # Páginas de autenticación
│   │   └── login_page.dart
│   ├── services/           # Servicios de autenticación
│   │   └── auth_service.dart
│   └── providers/          # Providers de estado
│       └── auth_provider.dart
│
├── users/                  # Gestión de usuarios
│   ├── pages/              # Páginas de usuarios
│   │   ├── register_user_page.dart
│   │   └── users_list_page.dart
│   ├── services/           # Servicios de usuarios
│   │   └── user_service.dart
│   └── widgets/            # Widgets específicos de usuarios
│
├── settings/               # Configuración de la aplicación
│   ├── pages/              # Páginas de configuración
│   │   └── settings_page.dart
│   └── services/           # Servicios de configuración
│       └── language_service.dart
│
├── stores/                 # Gestión de tiendas
│   ├── pages/              # Páginas de tiendas
│   │   ├── stores_list_page.dart
│   │   └── register_store_page.dart
│   ├── services/           # Servicios de tiendas
│   └── widgets/            # Widgets específicos de tiendas
│
└── products/               # Gestión de productos
    ├── pages/              # Páginas de productos
    │   ├── products_list_page.dart
    │   └── register_product_page.dart
    ├── services/           # Servicios de productos
    └── widgets/            # Widgets específicos de productos
```

## 🎯 Beneficios de esta Estructura

### **1. Separación de Responsabilidades**
- Cada funcionalidad está en su propia carpeta
- Fácil localización de archivos relacionados
- Mejor organización del código

### **2. Escalabilidad**
- Fácil agregar nuevas funcionalidades
- Estructura consistente para todos los módulos
- Desarrollo en equipo más eficiente

### **3. Mantenibilidad**
- Código más fácil de mantener
- Cambios aislados por funcionalidad
- Menor acoplamiento entre módulos

### **4. Reutilización**
- Servicios y widgets reutilizables
- Lógica de negocio centralizada
- Componentes modulares

## 📋 Convenciones de Nomenclatura

### **Páginas (`pages/`)**
- `[feature]_page.dart` - Páginas principales
- `[action]_[feature]_page.dart` - Páginas de acciones específicas

### **Servicios (`services/`)**
- `[feature]_service.dart` - Servicios principales
- `[specific]_service.dart` - Servicios específicos

### **Widgets (`widgets/`)**
- `[feature]_[widget_name].dart` - Widgets específicos
- `[action]_[feature]_widget.dart` - Widgets de acciones

### **Providers (`providers/`)**
- `[feature]_provider.dart` - Providers de estado

## 🔄 Flujo de Desarrollo

1. **Crear nueva funcionalidad:**
   - Crear carpeta en `features/[feature_name]/`
   - Crear subcarpetas `pages/`, `services/`, `widgets/`
   - Implementar archivos necesarios

2. **Agregar páginas:**
   - Crear en `features/[feature]/pages/`
   - Actualizar navegación en `dashboard_page.dart`

3. **Agregar servicios:**
   - Crear en `features/[feature]/services/`
   - Implementar lógica de negocio

4. **Agregar widgets:**
   - Crear en `features/[feature]/widgets/`
   - Reutilizar en páginas del módulo

## 🌍 Internacionalización

Todas las funcionalidades usan el sistema de traducciones centralizado:
- Importar: `import '../../../l10n/app_localizations.dart';`
- Usar: `final l10n = AppLocalizations.of(context);`

## 📱 Navegación

La navegación entre funcionalidades se maneja desde:
- `dashboard_page.dart` - Página principal con acceso a todas las funcionalidades
- Cada módulo puede tener su propia navegación interna

## 🚀 Próximos Pasos

1. **Implementar funcionalidades de tiendas:**
   - Servicios de API
   - Formularios de registro
   - Lista y gestión de tiendas

2. **Implementar funcionalidades de productos:**
   - Servicios de API
   - Formularios de registro
   - Lista y gestión de productos

3. **Agregar más widgets reutilizables:**
   - Componentes comunes
   - Formularios estándar
   - Listas y cards
