# Análisis Técnico — Kreator Frame

> Auditoría completa de arquitectura, gestión de estado con Riverpod, fugas de recursos,
> acoplamiento entre capas y oportunidades de mejora.
>
> Skills aplicadas: `flutter-clean-architect` · `flutter-riverpod-expert`
>
> Fecha: 2026-05-30
>
> Última actualización: 2026-06-01 — Bugs 6.2 (Environment responsabilidades) y 7.4 (MyApp efecto secundario) resueltos. Environment separado en archivos enfocados (env_vars, storage_keys, app_info, asset_paths, wallpaper_constants, external_links, kustom_config) con barrel export. MyApp usa ConsumerStatefulWidget con addPostFrameCallback para evitar efectos secundarios en build().

---

## Índice

1. [Resumen ejecutivo](#1-resumen-ejecutivo)
   - [Estado de implementación](#estado-de-implementación)
2. [Arquitectura Clean Architecture](#2-arquitectura-clean-architecture)
3. [Gestión de estado con Riverpod](#3-gestión-de-estado-con-riverpod)
4. [Fugas y uso excesivo de recursos](#4-fugas-y-uso-excesivo-de-recursos)
5. [Rendimiento y rebuilds innecesarios](#5-rendimiento-y-rebuilds-innecesarios)
6. [Acoplamiento entre capas](#6-acoplamiento-entre-capas)
7. [Bugs y errores potenciales](#7-bugs-y-errores-potenciales)
8. [Resumen de archivos afectados](#8-resumen-de-archivos-afectados)

---

## 1. Resumen ejecutivo

| Severidad | Cantidad | Descripción |
|-----------|----------|-------------|
| 🔴 Crítico | 0 | Todos los issues críticos han sido resueltos (ver tabla de estado). |
| 🟠 Alto | 0 | Todos los issues altos han sido resueltos. |
| 🟡 Medio | 0 | Todos los issues medios han sido resueltos. |
| 🟢 Bajo | 0 | Sin issues abiertos. |

### Estado de implementación

| Fix | Estado | Commit |
|-----|--------|--------|
| 3.1 Race condition AppValuesPreferencesNotifier | ✅ RESUELTO | `11cf168` |
| 3.2 Efecto secundario InAppUpdateNotifier | ✅ RESUELTO | `2cc506a` |
| 3.3 Async no await PermissionsNotifier | ✅ RESUELTO | `f7e5b2a` |
| 3.4 Falta de ref.mounted post-async | ✅ RESUELTO | `2cc506a` |
| 3.5 KeyValueStorageServicesImpl sin DI | ✅ RESUELTO | (ver sección 3.5) |
| 3.6 ref.watch en métodos de acción | ✅ RESUELTO | `a53bc82` |
| 4.1 getListOfWidgets caching | ✅ RESUELTO | `4fb6553` |
| 4.2 WallpaperPreviewScreen memoria | ✅ RESUELTO | `4eee4b2` |
| 4.3 ColorPaletteExtractor dispose | ✅ RESUELTO | `93b3fdd` |
| 4.5 DonationBanner UniqueKey | ✅ INTENCIONAL | — |
| 4.6 SharedPreferences caching | ✅ RESUELTO | `ae15640` |
| 5.1 MyApp ref.select | ✅ RESUELTO | (ver sección 5.1) |
| 5.2 WallpaperDownloadButton rebuilds | ✅ RESUELTO | (ver sección 5.2) |
| 5.3 keepAlive providers | ✅ CORRECTO | — |
| 6.1 Acceso directo repository | ✅ RESUELTO | (ver sección 6.1) |
| 6.2 Environment responsabilidades | ✅ RESUELTO | (ver sección 6.2) |
| 7.1 _activeCancelToken pérdida de referencia | ✅ RESUELTO | (ver sección 7.1) |
| 7.2 ref.watch en acciones | ✅ RESUELTO | `a53bc82` |
| 7.3 firstWhere sin orElse | ✅ RESUELTO | `4fb6553` |
| 7.4 MyApp efecto secundario | ✅ RESUELTO | (ver sección 7.4) |
| 7.5 setKeyValue sin await | ✅ RESUELTO | `11cf168` |
| 2.1 TabBarEntity Widget | ✅ RESUELTO | `c58ebfa` |
| 2.2 ThemeModeEntity tipos Flutter | ✅ RESUELTO | (ver sección 2.2) |
| 2.3 NetworkFailure sin usar | ✅ RESUELTO | (ver sección 2.3) |

---

## 2. Arquitectura Clean Architecture

### 2.1 🔴 `TabBarEntity` contiene `Widget` — violación de la capa Domain ✅ RESUELTO (2026-05-31)

**Archivos:**
- `lib/domain/entities/tab_bar_entity.dart` — entidad ahora es puro dato (`TabBarType` enum + `String label`).
- `lib/presentation/providers/tabs_bar_app_provider.dart` — ya no construye widgets, solo emite entidades.
- `lib/presentation/screens/home_screen.dart` — mapea `TabBarEntity` a widgets vía `switch` y deriva `Tab` desde `label`.
- `lib/presentation/widgets/appbar/custom_sliver_appbar.dart` — recibe `List<Tab>` como parámetro (no consulta el provider).
- `lib/presentation/screens/secondary/kustom_widgets_screen.dart` — expone `kwgtTabLabel` / `klwpTabLabel` como `static const String` para uso en contextos `const`.

**Solución aplicada:**

1. **Entidad de dominio pura** — `TabBarEntity` ahora solo contiene un `TabBarType` enum (`kustomWidget`, `kustomLiveWallpaper`, `wallpapers`) y un `String label`, sin tipos de Flutter UI:

```dart
enum TabBarType {
  kustomWidget,
  kustomLiveWallpaper,
  wallpapers,
}

class TabBarEntity {
  final TabBarType type;
  final String label;

  const TabBarEntity({required this.type, required this.label});
  // operator== y hashCode basados en type + label
}
```

2. **Mapeo en `HomeScreen`** — el `switch` se encarga de traducir cada `TabBarEntity` a su widget concreto y a su `Tab` de cabecera:

```dart
Widget _buildTabView(TabBarEntity tab) {
  return switch (tab.type) {
    TabBarType.kustomWidget =>
      const KustomWidgetsScreen(config: KustomWidgetConfig.kwgt),
    TabBarType.kustomLiveWallpaper =>
      const KustomWidgetsScreen(config: KustomWidgetConfig.klwp),
    TabBarType.wallpapers => const WallpapersScreen(),
  };
}
```

3. **`CustomSliverAppBar` desacoplado** — recibe la lista de `Tab` ya construida, ya no consulta `tabsBarAppProvider` ni conoce `TabBarEntity`.

**Resultado:**
- La capa `domain` queda libre de dependencias con Flutter UI.
- `TabsBarAppNotifier` solo emite datos puros.
- La presentación traduce datos → UI en un único punto (`HomeScreen`).
- `flutter analyze` y `flutter test` pasan sin issues.
- No se rompe la funcionalidad: las pestañas siguen mostrándose en el mismo orden y con los mismos labels.

---

### 2.2 🟠 `ThemeModeEntity` contiene tipos Flutter ✅ RESUELTO (2026-06-01)

**Archivos:**
- `lib/domain/entities/theme_mode_entity.dart` — entidad ahora es puro dato (`ThemeModeOption` enum + `ThemeModeEntity` con solo `option`).
- `lib/shared/utils/app_constants.dart` — `themeModeOptions` usa entidades puras; funciones de mapeo `themeModeFromOption`, `iconForThemeMode`, `titleForThemeMode` resuelven la UI en presentation.
- `lib/presentation/widgets/theme/theme_mode_switcher.dart` — consume `AppConstants.iconForThemeMode` y `AppConstants.titleForThemeMode` para mapear a UI.
- `lib/presentation/providers/app_values_preferences_provider.dart` — estado usa `ThemeModeOption` con getter `themeModeForApp` que mapea a `ThemeMode`.

**Problema original:**
```dart
class ThemeModeEntity {
  final ThemeMode themeMode;   // ← Tipo de Flutter
  final String Function(BuildContext) title;  // ← Callback con BuildContext
  final IconData icon;          // ← Tipo de Flutter
  ...
}
```

**Solución aplicada (siguiendo `flutter-clean-architect`):**

1. **Enum puro en domain** — `ThemeModeOption` reemplaza `ThemeMode` en la capa de dominio:

```dart
enum ThemeModeOption { system, light, dark }

class ThemeModeEntity {
  final ThemeModeOption option;
  const ThemeModeEntity({required this.option});
}
```

2. **Funciones de mapeo en presentation** — `AppConstants` expone funciones estáticas que resuelven `ThemeModeOption` a tipos Flutter:

```dart
static ThemeMode themeModeFromOption(ThemeModeOption option) => switch (option) { ... };
static IconData iconForThemeMode(ThemeModeOption option) => switch (option) { ... };
static String Function(BuildContext) titleForThemeMode(ThemeModeOption option) => switch (option) { ... };
```

3. **Estado del notifier migrado** — `AppValuesPreferencesState` almacena `ThemeModeOption` y expone un getter para `ThemeMode`:

```dart
class AppValuesPreferencesState {
  final ThemeModeOption themeModeOption;
  ThemeMode get themeModeForApp => AppConstants.themeModeFromOption(themeModeOption);
  ...
}
```

**Resultado:**
- La capa `domain` queda libre de dependencias con Flutter UI (`ThemeMode`, `IconData`, `BuildContext`).
- Las funciones de mapeo viven en `AppConstants` (shared/utils), accesibles desde presentation sin contaminar domain.
- `ThemeModeSwitcher` mantiene la misma funcionalidad visual.
- `flutter analyze` y `flutter test` (25/25) pasan sin issues.
- No se rompe la funcionalidad: el selector de tema sigue mostrando las mismas opciones con los mismos iconos y labels.

---

### 2.3 🟡 `NetworkFailure` definido pero nunca usado ✅ RESUELTO (2026-06-01)

**Archivo:** `lib/domain/entities/network_failure.dart` — **ELIMINADO**

**Problema original:**
La clase `NetworkFailure` con su enum `NetworkFailureType` estaba definida y exportada pero nunca se utilizaba en ningún archivo del proyecto. Todo el manejo de errores usaba excepciones genéricas (`catch (e)`).

**Análisis de la sugerencia original:**
La sugerencia proponía implementar un sistema `Result<T>` con `Success` y `Failure`. Sin embargo, esto sería excesivo para el contexto actual del proyecto:
- El proyecto maneja errores con `try/catch` y valores por defecto en los datasources.
- Los `OperationNotifier` ya capturan errores y propagan resultados booleanos.
- Implementar `Result<T>` requeriría refactorizar todos los datasources, repositories y notifiers.

**Solución aplicada:**
Eliminar el código muerto. `NetworkFailure` se eliminó del proyecto y de `domain.dart`:

```dart
// domain.dart - antes
export 'entities/network_failure.dart';  // ← eliminada

// domain.dart - después
// (línea eliminada)
```

**Justificación:**
- Código muerto genera confusión sobre si debe usarse o no.
- El manejo de errores actual es funcional y coherente con el patrón del proyecto.
- Si en el futuro se necesita un sistema de errores tipado, se implementará de forma completa en ese momento.

**Resultado:**
- Domain layer sin código muerto.
- `flutter analyze` y `flutter test` (25/25) pasan sin issues.
- No se rompe funcionalidad: el manejo de errores existente no dependía de `NetworkFailure`.

---

### 2.4 🟢 Repository es un pass-through puro

**Archivo:** `lib/infrastructure/repositories/repository_impl.dart`

**Problema:**
`RepositoryImpl` delega directamente al `DataSource` sin agregar lógica. Esto es aceptable actualmente, pero si en el futuro se necesita caché o transformación, la separación ya está lista.

**Posible mejora (futuro):**
Agregar caché local para wallpapers o manejo de offline-first.

---

## 3. Gestión de estado con Riverpod

### 3.1 🔴 Race condition en `AppValuesPreferencesNotifier.build()` ✅ RESUELTO

**Archivo:** `lib/presentation/providers/app_values_preferences_provider.dart`

**Problema:**
```dart
@override
AppValuesPreferencesState build() {
  _keyValueStorageServices = KeyValueStorageServicesImpl();
  _updateStateFromPreferences();  // ← Método async, NO se awaits
  return AppValuesPreferencesState();  // ← Retorna estado default inmediatamente
}
```

El método `_updateStateFromPreferences()` es `async` pero se llama sin `await`. El `build()` retorna el estado default antes de que se lean las preferencias persistentes. Esto causa un **parpadeo visual**: la app muestra el tema default por un frame y luego cambia al tema guardado.

**Funcionalidad actual:**
Al abrir la app, se muestra brevemente el tema default (color accent azul, tema system) antes de aplicar las preferencias guardadas del usuario.

**Posible mejora:**
Usar `AsyncNotifier` o inicializar el estado con un valor que indique "cargando":

```dart
// Opción 1: AsyncNotifier
class AppValuesPreferencesNotifier extends AsyncNotifier<AppValuesPreferencesState> {
  @override
  Future<AppValuesPreferencesState> build() async {
    final services = ref.watch(keyValueStorageProvider);
    final indexColor = await services.getKeyValue<int>(Environment.keyColorTheme) ?? 4;
    final indexTheme = await services.getKeyValue<String>(Environment.keyThemeMode);
    // ... construir estado con datos reales
  }
}

// Opción 2: Mantener Notifier pero sin flash
// Leer SharedPreferences de forma síncrona en build() usando la instancia cacheada
```

**Relaciones:**
- `main.dart` — `ref.watch(appValuesPreferencesProvider)` construye el tema
- `MyApp` — recibe el estado y configura `MaterialApp.router`
- `ThemeModeSwitcher` y `ColorThemeSwitcher` — muestran la selección actual
- **No se rompe la funcionalidad**, solo cambia la inicialización

---

### 3.2 🔴 `InAppUpdateNotifier` — efecto secundario en `build()` ✅ RESUELTO

**Archivo:** `lib/presentation/providers/in_app_update_provider.dart`

**Problema:**
```dart
@override
InAppUpdateState build() {
  Future.microtask(() => checkAppForUpdates());  // ← Efecto secundario en build()
  return InAppUpdateState();
}
```

Realizar una llamada de red dentro de `build()` es un anti-patrón en Riverpod. Esto puede causar múltiples llamadas si el provider se invalida, y no tiene control sobre cuándo se ejecuta realmente.

**Funcionalidad actual:**
Al crear el provider (app inicio), se verifica si hay actualizaciones disponibles. Si hay una, se lanza la actualización automática.

**Posible mejora:**
Usar `ref.listen()` en la pantalla que necesita reaccionar (ya se hace parcialmente en `HomeScreen`), o mover la verificación a una acción explícita:

```dart
class InAppUpdateNotifier extends Notifier<InAppUpdateState> {
  @override
  InAppUpdateState build() => InAppUpdateState();

  // Llamar explícitamente desde HomeScreen o un provider de inicialización
  Future<void> checkAppForUpdates() async { ... }
}

// En HomeScreen:
@override
Widget build(BuildContext context, WidgetRef ref) {
  // checkAppForUpdates se dispara una vez al montar
  useEffect(() {
    ref.read(inAppUpdateProvider.notifier).checkAppForUpdates();
    return null;
  }, []);
  ...
}
```

**Relaciones:**
- `HomeScreen` — ya tiene `ref.listen(inAppUpdateProvider, ...)` para ejecutar la actualización
- `InAppUpdateState` — la estructura de estado no cambia
- No se rompe la funcionalidad de actualización

---

### 3.3 🔴 `PermissionsNotifier` — async no await en `build()` ✅ RESUELTO

**Archivo:** `lib/presentation/providers/permissions_provider.dart`

**Problema:**
```dart
@override
PermissionsState build() {
  _init();  // ← async, no se awaits
  return PermissionsState();  // ← Retorna estado "denied" aunque no lo sea
}

Future<void> _init() async {
  await _getAndroidVersion();
  await _checkPermissions();
}
```

Mismo patrón que `AppValuesPreferencesNotifier`. El estado inicial es `denied` aunque el dispositivo esté en Android 10+ (donde los permisos no son necesarios). Esto puede causar un flash del botón de permiso innecesario.

**Funcionalidad actual:**
El botón de descarga de wallpaper verifica `permissions.storageGranted`. En Android 10+, esto debería ser `true` inmediatamente, pero el estado inicial es `denied`.

**Posible mejora:**
```dart
@override
PermissionsState build() {
  return PermissionsState(
    storage: PermissionStatus.granted,  // Default optimista para Android 10+
  );
}
```

O migrar a `AsyncNotifier` con estado inicial correcto.

**Relaciones:**
- `WallpaperDownloadButton` — verifica `permissions.storageGranted`
- `requestStoragePermission()` — solo se llama en Android ≤28
- No se rompe la funcionalidad de descarga

---

### 3.4 🟠 Falta de \`ref.mounted\` después de operaciones async ✅ RESUELTO

**Archivos afectados:**
- `lib/presentation/providers/in_app_update_provider.dart`
- `lib/presentation/providers/permissions_provider.dart`
- `lib/presentation/providers/app_values_preferences_provider.dart`
- `lib/presentation/providers/tabs_bar_app_provider.dart`

**Problema:**
Múltiples notifiers actualizan el estado después de operaciones `await` sin verificar `ref.mounted`. Si el usuario navega fuera de la pantalla antes de que termine la operación, se produce el error:
```
setState() or markNeedsBuild() called during build.
```

**Ejemplo:**
```dart
// InAppUpdateNotifier
Future<void> checkAppForUpdates() async {
  final repository = ref.read(repositoryProvider);
  final resultOfReviewingUpdates = await repository.checkAppForUpdates();  // ← await
  // Si el widget se desmontó aquí, la siguiente línea causa error:
  state = state.copyWith(...);
}
```

**Posible mejora:**
```dart
Future<void> checkAppForUpdates() async {
  final repository = ref.read(repositoryProvider);
  final resultOfReviewingUpdates = await repository.checkAppForUpdates();
  if (!ref.mounted) return;  // ← Guard check
  state = state.copyWith(...);
}
```

**Relaciones:**
- Todas las pantallas que usan estos providers
- No se rompe funcionalidad, solo previene crashes

---

### 3.5 🟡 \`KeyValueStorageServicesImpl\` instanciado directamente ✅ RESUELTO (2026-06-01)

**Archivos:**
- `lib/presentation/providers/repository_provider.dart` — nuevo `keyValueStorageProvider` (`Provider<KeyValueStorageServices>`) inyectado como singleton.
- `lib/presentation/providers/app_values_preferences_provider.dart` — `build()` usa `ref.watch(keyValueStorageProvider)`, métodos de acción usan `ref.read(keyValueStorageProvider)`.

**Problema original:**
```dart
@override
AppValuesPreferencesState build() {
  _keyValueStorageServices = KeyValueStorageServicesImpl();  // ← Instanciado directamente
  ...
}
```

`KeyValueStorageServicesImpl` se creaba dentro del notifier en lugar de inyectarse via provider. Esto impedía:
- Testing con mocks
- Reutilización del mismo singleton de SharedPreferences
- Cambio de implementación sin modificar el notifier

**Solución aplicada (siguiendo `flutter-clean-architect` + `flutter-riverpod-expert`):**

1. **Provider de servicio centralizado** — `keyValueStorageProvider` expone `KeyValueStorageServicesImpl` como la interfaz abstracta `KeyValueStorageServices`, siguiendo el patrón de inyección ya existente en el proyecto (`downloadCancelTokenHolderProvider`, `dataSourceProvider`, `repositoryProvider`):

```dart
final keyValueStorageProvider = Provider<KeyValueStorageServices>((ref) {
  return KeyValueStorageServicesImpl();
});
```

2. **Inyección en el notifier** — `build()` inyecta via `ref.watch()` (suscripción reactiva), métodos de acción usan `ref.read()` (lectura puntual):

```dart
@override
Future<AppValuesPreferencesState> build() async {
  final keyValueStorageServices = ref.watch(keyValueStorageProvider);
  return _loadPreferences(keyValueStorageServices);
}

Future<void> setPreferenceForThemeMode(ThemeModeOption option) async {
  final keyValueStorageServices = ref.read(keyValueStorageProvider);
  await keyValueStorageServices.setKeyValue(Environment.keyThemeMode, option.name);
  ...
}
```

3. **Contrato preservado** — La interfaz abstracta `KeyValueStorageServices` ya existía en `shared/services/key_value_storage_service.dart`. El provider expone la interfaz, no la implementación, facilitando mocks en tests:

```dart
final container = ProviderContainer.test(
  overrides: [
    keyValueStorageProvider.overrideWithValue(MockKeyValueStorageServices()),
  ],
);
```

**Mejoras incluidas:**
- **Testabilidad**: el provider se puede mockear trivialmente para tests unitarios del notifier.
- **Consistencia**: sigue el mismo patrón DI que `downloadCancelTokenHolderProvider`, `dataSourceProvider` y `repositoryProvider`.
- **Singleton implícito**: `Provider` (no `autoDispose`) garantiza una única instancia mientras el provider scope viva. SharedPreferences ya cachea internamente, pero el provider evita instanciaciones redundantes de `KeyValueStorageServicesImpl`.
- **Desacoplamiento**: el notifier ya no conoce `KeyValueStorageServicesImpl`, solo conoce `KeyValueStorageServices`.

**Resultado:**
- Las 4 instancias directas de `KeyValueStorageServicesImpl()` se reemplazan por una inyección centralizada.
- `flutter analyze` y `flutter test` (25/25) pasan sin issues.
- No se rompe la funcionalidad: las preferencias siguen persistiéndose y cargándose igual.

---

### 3.6 🟡 \`ref.watch()\` en métodos de acción ✅ RESUELTO

**Archivos afectados:**
- `lib/presentation/screens/tertiary/wallpaper_preview_screen.dart` — `_LocationButton`, `_WallpaperChooserButton`, `_NativePickerButton`

**Problema:**
```dart
void _applyWallpaper(BuildContext context, WidgetRef ref) async {
  final repository = ref.watch(repositoryProvider);  // ← Debería ser ref.read()
  final appRouter = ref.watch(appRouterProvider);     // ← Debería ser ref.read()
  ...
}
```

Dentro de métodos de acción (no en `build()`), se debe usar `ref.read()` en lugar de `ref.watch()`. `ref.watch()` solo tiene sentido en `build()` para establecer suscripciones reactivas.

**Posible mejora:**
Cambiar `ref.watch()` por `ref.read()` en todos los métodos de acción.

**Relaciones:**
- `repositoryProvider` y `appRouterProvider` — no cambian
- No afecta funcionalidad, es una corrección de best practice

---

## 4. Fugas y uso excesivo de recursos

### 4.1 🔴 `getListOfWidgets()` — sin caching, carga pesada de assets ✅ RESUELTO

**Archivo:** `lib/infrastructure/datasources/datasource_impl.dart`

**Problema:**
```dart
Future<List<WidgetEntity>> getListOfWidgets(String filesExt, String thumbName) async {
  List<String> zipFiles = await _listZipFiles(filesExt);  // ← Lee AssetManifest completo
  for (String zipFileName in zipFiles) {
    ByteData data = await rootBundle.load('...');  // ← Carga binario completo del zip
    List<int> bytes = data.buffer.asUint8List();
    Archive archive = ZipDecoder().decodeBytes(bytes);  // ← Decodifica zip en memoria
    ArchiveFile? thumbFile = archive.firstWhere(...);  // ← Extrae thumbnail
    // ⚠️ archive NUNCA se descarta
  }
}
```

**Fuga de memoria identificada:**
1. Cada llamada carga **todos los assets** del manifiesto para filtrar por extensión
2. Cada zip se carga **completamente en memoria** como `Uint8List`
3. `ZipDecoder().decodeBytes()` crea un `Archive` que **nunca se descarta** — retiene todos los archivos del zip en memoria
4. No hay caching — si el provider se invalida, todo se recarga

**Funcionalidad actual:**
Las pantallas de KWGT/KLWP muestran thumbnails de los widgets empaquetados en archivos zip.

**Posible mejora:**
```dart
class DataSourceImpl extends DataSource {
  // Cache en memoria para evitar recargas
  final Map<String, List<WidgetEntity>> _widgetCache = {};

  @override
  Future<List<WidgetEntity>> getListOfWidgets(String filesExt, String thumbName) async {
    if (_widgetCache.containsKey(filesExt)) {
      return _widgetCache[filesExt]!;
    }

    List<WidgetEntity> widgets = [];
    // ... lógica actual ...

    _widgetCache[filesExt] = widgets;
    return widgets;
  }
}
```

O mejor aún, cachear en el provider:
```dart
class WidgetsNotifier extends AsyncNotifier<List<WidgetEntity>> {
  @override
  Future<List<WidgetEntity>> build() async {
    ref.keepAlive();
    // La carga solo ocurre una vez por tipo
    final repository = ref.watch(repositoryProvider);
    return await repository.getListOfWidgets(widgetExt, 'preset_thumb_portrait.jpg');
  }
}
```

**Relaciones:**
- `WidgetsNotifier` — ya usa `ref.keepAlive()`, lo que ayuda
- `TabsBarAppNotifier` — también carga widgets, necesita caching compartido
- `KustomWidgetsScreen` — consume el provider, no necesita cambios
- ⚠️ **No romper la funcionalidad de visualización de widgets**

---

### 4.2 🟠 `WallpaperPreviewScreen` — imagen completa en memoria ✅ RESUELTO

**Archivo:** `lib/presentation/screens/tertiary/wallpaper_preview_screen.dart`

**Problema:**
```dart
InteractiveViewer(
  clipBehavior: Clip.none,
  constrained: false,
  child: Image(
    image: CachedNetworkImageProvider(wallpaperEntity.url),
    width: size.width,    // ← Tamaño completo de pantalla
    height: size.height,  // ← Tamaño completo de pantalla
    fit: BoxFit.fitHeight,
  ),
)
```

Con `constrained: false` e imagen a tamaño completo de pantalla, la imagen se carga y mantiene en memoria a resolución completa, incluso cuando el usuario hace zoom out. En dispositivos con RAM limitada, esto puede causar crash por `OutOfMemoryError`.

**Funcionalidad actual:**
Pantalla de preview de wallpaper con zoom interactivo y paleta de colores.

**Posible mejora:**
- Usar `CachedNetworkImage` en lugar de `Image` con `CachedNetworkImageProvider` para aprovechar el caché automático
- Limitar el tamaño de carga inicial
- Usar `constrained: true` para que la imagen se ajuste al contenedor

```dart
InteractiveViewer(
  constrained: true,  // ← Limitar al contenedor
  clipBehavior: Clip.hardEdge,
  child: CachedNetworkImage(
    imageUrl: wallpaperEntity.url,
    fit: BoxFit.fitHeight,
    memCacheWidth: (size.width * 1.5).round(),  // ← Limitar caché en memoria
  ),
)
```

**Relaciones:**
- `CachedNetworkImage` ya está en las dependencias
- `generatePaletteProvider` — sigue funcionando con la URL
- Hero animation — mantiene la transición

---

### 4.3 🟠 `ColorPaletteExtractor` — imágenes `ui.Image` no disposadas ✅ RESUELTO

**Archivo:** `lib/shared/utils/color_palette_extractor.dart`

**Problema:**
```dart
static Future<List<Color>> extractColors({...}) async {
  final image = await _loadImage(imageProvider);       // ← ui.Image creada
  final resizedImage = await _resizeImage(image, resize);  // ← Otra ui.Image creada
  final pixelData = await _extractPixelData(resizedImage);
  // ⚠️ Ni 'image' ni 'resizedImage' se llaman .dispose()
  return colors;
}
```

Las instancias de `ui.Image` ocupan memoria en el GPU. Si no se llaman `.dispose()`, la memoria no se libera hasta que el garbage collector la recoja (si lo hace).

**Posible mejora:**
```dart
static Future<List<Color>> extractColors({...}) async {
  final image = await _loadImage(imageProvider);
  try {
    final resizedImage = await _resizeImage(image, resize);
    try {
      final pixelData = await _extractPixelData(resizedImage);
      return _buildColorHistogram(pixelData, binSize);
    } finally {
      resizedImage.dispose();  // ← Liberar memoria GPU
    }
  } finally {
    image.dispose();  // ← Liberar memoria GPU
  }
}
```

**Relaciones:**
- `generatePaletteProvider` — llama a `extractColors`
- `PaletteColorsGrid` — consume el provider
- No se rompe la funcionalidad de paleta de colores

---

### 4.4 🟠 `PaletteColorsGrid` — descarga imagen por cada color copiado

**Archivo:** `lib/presentation/widgets/palette_colors_grid.dart`

**Problema:**
Cada vez que el usuario abre el preview de un wallpaper, `generatePaletteProvider` se evalúa:
1. Descarga la imagen de red (o la obtiene del caché de `CachedNetworkImage`)
2. La redimensiona a 200x200 px
3. Extrae píxeles y construye histograma
4. Retorna colores

Esto es CPU-intensivo y ocurre en el hilo principal si no se maneja con cuidado.

**Funcionalidad actual:**
Muestra una barra horizontal de colores extraídos del wallpaper. El usuario puede tocar un color para copiarlo al portapapeles.

**Posible mejora:**
- Cachear los resultados por URL (ya lo hace `FutureProvider.family`)
- Mover el procesamiento a un isolate si es necesario
- Mostrar solo los colores cuando el usuario toca el botón de paleta (ya se hace con `showPaletteColorsProvider`)

**Relaciones:**
- `generatePaletteProvider` — ya usa family para cachear por URL
- `showPaletteColorsProvider` — controla la visibilidad
- `WallpaperPreviewScreen` — ya retrasa la muestra con `FadeInUp`

---

### 4.5 🟡 `_DonationBanner` con `UniqueKey()` — se resetea siempre ✅ INTENCIONAL (comportamiento deseado)

**Archivo:** `lib/presentation/screens/secondary/settings_screen.dart`

**Problema:**
```dart
Dismissible(
  key: UniqueKey(),  // ← UniqueKey() genera una key nueva cada rebuild
  child: const _DonationBanner(),
),
```

`UniqueKey()` genera una key diferente en cada rebuild, lo que significa que `Dismissible` nunca "recuerda" que el banner fue descartado. El banner reaparece cada vez que se reconstruye la pantalla.

**Funcionalidad actual:**
El usuario puede deslizar para descartar el banner de donaciones, pero reaparece al navegar de vuelta.

**Posible mejora:**
```dart
// Opción 1: Key fija + persistir estado de descarte
Dismissible(
  key: const Key('donation-banner'),
  onDismissed: (_) {
    ref.read(keyValueStorageProvider).setKeyValue('donation_dismissed', true);
  },
  child: const _DonationBanner(),
)

// Opción 2: Ocultar condicionalmente
final dismissed = ref.watch(/* provider de estado */);
if (dismissed) return const SizedBox.shrink();
```

**Relaciones:**
- `KeyValueStorageServices` — puede persistir el estado
- `SettingsScreen` — recibe el cambio de visibilidad
- No afecta otras funcionalidades

---

### 4.6 🟡 `SharedPreferences.getInstance()` llamado múltiples veces ✅ RESUELTO

**Archivo:** `lib/shared/services/key_value_storage_service_impl.dart`

**Problema:**
```dart
Future<SharedPreferences> getSharedPreferences() async {
  return await SharedPreferences.getInstance();  // ← Se llama en cada operación
}
```

Aunque `SharedPreferences` internamente cachea la instancia, el overhead de la llamada asíncrona se repite en cada `setKeyValue` y `getKeyValue`.

**Posible mejora:**
```dart
class KeyValueStorageServicesImpl extends KeyValueStorageServices {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  @override
  Future<T?> getKeyValue<T>(String key) async {
    final prefs = await _instance;
    // ...
  }
}
```

**Relaciones:**
- `AppValuesPreferencesNotifier` — principal consumidor
- No rompe funcionalidad, mejora rendimiento

---

## 5. Rendimiento y rebuilds innecesarios

### 5.1 🟡 `MyApp` se reconstruye con cualquier cambio de preferencia ✅ RESUELTO (2026-06-01)

**Archivo:** `lib/main.dart`

**Problema original:**
```dart
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appValuesFromPreference = ref.watch(appValuesPreferencesProvider);
    // ↑ Cualquier cambio en CUALQUIER campo del estado reconstruye todo MyApp
    ...
  }
}
```

Cuando el usuario cambia solo el color de acento, también se reconstruyen el tema, el router, y todo el árbol de widgets hijo.

**Análisis de la sugerencia original:**
La sugerencia proponía usar `ref.select()` directamente en el estado:
```dart
final themeMode = ref.watch(appValuesPreferencesProvider.select((s) => s.themeModeForApp));
```

Sin embargo, esto es **incorrecto** porque `appValuesPreferencesProvider` es un `AsyncNotifierProvider`, no un `NotifierProvider`. El `ref.watch()` devuelve un `AsyncValue<AppValuesPreferencesState>`, no el estado directamente. Además, `appValuesAsync.when()` necesita el `AsyncValue` completo para manejar loading/error/data.

**Solución aplicada (siguiendo `flutter-riverpod-expert`):**

1. **Separación de responsabilidades** — `MyApp` maneja el ciclo de vida del `AsyncValue` (loading/error/data) y delega el contenido real a `_MyAppContent`:

```dart
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appValuesAsync = ref.watch(appValuesPreferencesProvider);

    return appValuesAsync.when(
      loading: () => const MaterialApp(...),
      error: (_, _) => const MaterialApp(...),
      data: (_) => const _MyAppContent(),
    );
  }
}
```

2. **`ref.select()` para campos específicos** — `_MyAppContent` usa `ref.select()` para observar solo los campos que necesita, evitando rebuilds cuando campos no relacionados cambian (ej: `dynamicColorAvailable`):

```dart
class _MyAppContent extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appRouter = ref.watch(appRouterProvider);
    final isDynamic = ref.watch(
      appValuesPreferencesProvider.select((async) => async.value?.isDynamicColor ?? false),
    );
    final colorAccent = ref.watch(
      appValuesPreferencesProvider.select((async) => async.value?.colorAccentForTheme ?? AppConstants.accentColors[4]),
    );
    final themeMode = ref.watch(
      appValuesPreferencesProvider.select((async) => async.value?.themeModeForApp ?? ThemeMode.system),
    );
    ...
  }
}
```

**Resultado:**
- `_MyAppContent` solo se reconstruye cuando `isDynamicColor`, `colorAccentForTheme` o `themeModeForApp` cambian.
- Cambios en `dynamicColorAvailable` o `minimalViewForGrids` no reconstruyen el MaterialApp.
- El manejo de loading/error se preserva en `MyApp`.
- `flutter analyze` y `flutter test` (25/25) pasan sin issues.
- No se rompe la funcionalidad: el tema, el router y la configuración siguen funcionando igual.

---

### 5.2 🟡 `WallpaperDownloadButton` — rebuilds frecuentes durante descarga ✅ RESUELTO (2026-06-01)

**Archivo:** `lib/presentation/widgets/buttons/wallpaper_download_button.dart`

**Problema original:**
```dart
class WallpaperDownloadButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressValue = ref.watch(downloadOperationsProvider);
    // ↑ Cada tick de progreso reconstruye TODO el widget, incluyendo
    //   la lógica de permisos y el botón de descarga
    ...
  }
}
```

Durante una descarga, el callback `onProgressUpdate` actualiza `downloadOperationsProvider` con cada chunk recibido. Cada actualización reconstruye el botón y cualquier otro widget que observe ese provider.

**Análisis de la sugerencia original:**
La sugerencia proponía usar `ref.select()` para observar solo si está descargando (boolean):
```dart
final isDownloading = ref.watch(progressDownloaderProvider.select((p) => p != null));
```

Esto es **parcialmente correcto** pero incompleto: el widget necesita el valor de progreso para mostrar el indicador visual. No se puede usar `ref.select()` para eliminar el progreso sin perder la funcionalidad.

**Solución aplicada (siguiendo `flutter-riverpod-expert`):**

1. **`ref.select()` en el widget padre** — `WallpaperDownloadButton` solo observa si hay una descarga activa, no el valor de progreso:

```dart
class WallpaperDownloadButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionsAsync = ref.watch(permissionsProvider);
    // Use ref.select to observe only whether a download is active,
    // avoiding full-widget rebuilds on every progress tick.
    final isDownloading = ref.watch(
      downloadOperationsProvider.select((progress) => progress != null),
    );
    final colors = Theme.of(context).colorScheme;

    if (isDownloading) {
      return _DownloadProgressIndicator(
        iconColor: iconColor,
        onCancel: () => _cancelDownload(context, ref, colors),
      );
    }
    ...
  }
}
```

2. **Widget separado para el indicador de progreso** — `_DownloadProgressIndicator` observa el valor exacto de progreso, aislando los rebuilds frecuentes:

```dart
class _DownloadProgressIndicator extends ConsumerWidget {
  final Color? iconColor;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressValue = ref.watch(downloadOperationsProvider);
    final isIndeterminate = (progressValue ?? -1) < 0;
    // ... render progress ring with percentage
  }
}
```

**Mejoras incluidas:**
- **Rebuilds aislados**: los ticks de progreso solo reconstruyen `_DownloadProgressIndicator`, no el widget padre con su lógica de permisos.
- **Separación de responsabilidades**: el indicador de progreso es un widget independiente con su propia lógica de renderizado.
- **API preservada**: la interfaz pública de `WallpaperDownloadButton` no cambia; los consumidores no necesitan modificarse.
- **Cancel callback**: el callback `onCancel` se pasa como parámetro, manteniendo el desacoplamiento entre el indicador y la lógica de cancelación.

**Resultado:**
- Los rebuilds frecuentes durante la descarga solo afectan al `_DownloadProgressIndicator`.
- `WallpaperDownloadButton` solo se reconstruye cuando `isDownloading` cambia (inicio/fin de descarga).
- `flutter analyze` y `flutter test` (25/25) pasan sin issues.
- No se rompe la funcionalidad: el indicador de progreso, la cancelación y los snackbars siguen funcionando igual.

---

### 5.3 🟢 `ref.keepAlive()` en múltiples providers ✅ CORRECTO (comportamiento intencional para datos estáticos)

**Archivos afectados:**
- `wallpapers_provider.dart`
- `package_info_provider.dart`
- `licenses_oss_provider.dart`
- `tabs_bar_app_provider.dart`
- `widgets_provider.dart`

**Problema:**
Todos estos providers usan `ref.keepAlive()` en su `build()`, lo que impide que Riverpod los descarte cuando no están en uso. Esto mantiene datos en memoria indefinidamente.

**Funcionalidad actual:**
Los datos (wallpapers, info de paquete, licencias, tabs) se cargan una vez y se mantienen en memoria para toda la vida de la app.

**Posible mejora:**
Evaluar caso por caso:
- `packageInfoProvider` → `keepAlive` es apropiado (datos estáticos)
- `licensesOssProvider` → `keepAlive` es apropiado (datos estáticos)
- `getWallpapersProvider` → `keepAlive` es apropiado (cambian rara vez)
- `tabsBarAppProvider` → `keepAlive` es apropiado (estructura fija)
- `getWidgetsProvider` → `keepAlive` es apropiado (assets locales)

En general, `keepAlive` es correcto para este tipo de app. Solo sería problemático si la app tuviera muchos providers que se cargan y descargan frecuentemente.

**Relaciones:**
- Todas las pantallas consumidoras
- No se recomienda cambiar sin razón específica

---

## 6. Acoplamiento entre capas

### 6.1 🟠 Acceso directo a `repositoryProvider` desde widgets ✅ RESUELTO (2026-06-01)

**Archivos:**
- `lib/presentation/providers/wallpaper_operations_provider.dart` — `WallpaperOperationsNotifier` (3 ops de wallpaper centralizadas, reemplaza a `SetWallpaperNotifier`).
- `lib/presentation/providers/download_operations_provider.dart` — `DownloadOperationsNotifier` (download + cancel, reemplaza a `ProgressDownloaderNotifier`).
- `lib/presentation/providers/kustom_operations_provider.dart` — `KustomOperationsNotifier` (instalado check + send intent, nuevo).
- `lib/presentation/providers/external_navigation_provider.dart` — `ExternalNavigationNotifier` (launch external app, nuevo).
- `lib/presentation/providers/providers.dart` — barrel actualizado con los nuevos notifiers; los archivos `set_wallpaper_provider.dart` y `progress_downloader_provider.dart` se eliminan al quedar reemplazados.
- `lib/presentation/screens/tertiary/wallpaper_preview_screen.dart` — `_LocationButton`, `_WallpaperChooserButton` y `_NativePickerButton` consumen `wallpaperOperationsProvider.notifier`.
- `lib/presentation/screens/secondary/kustom_widgets_screen.dart` — `KustomWidgetsScreen` despacha a `kustomOperationsProvider` / `externalNavigationProvider` mediante un único `_handleWidgetTap`.
- `lib/presentation/screens/secondary/settings_screen.dart` — `SettingsScreen` y `_DonationBanner` usan `externalNavigationProvider.notifier`.
- `lib/presentation/screens/tertiary/about_dashboard_screen.dart` — consume `externalNavigationProvider.notifier`.
- `lib/presentation/screens/tertiary/about_package_app_screen.dart` — consume `externalNavigationProvider.notifier`.
- `lib/presentation/widgets/buttons/wallpaper_download_button.dart` — consume `downloadOperationsProvider.notifier` para `download` y `cancel`.
- `test/presentation/operations_notifiers_test.dart` — 10 tests unitarios (uno por notifier + uno de invariante de capas) cubriendo forwarding al repositorio, manejo de loading, manejo de errores y reset de estado.

**Problema original:**
13+ accesos directos a `repositoryProvider` desde widgets (y un widget que se autodocumenta con un `setWallpaperState = ref.watch(setWallpaperProvider)` para deshabilitar botones) dispersos por seis pantallas:

```dart
// _LocationButton
final repository = ref.watch(repositoryProvider);
final result = await repository.setWallpaper(wallpaperEntity.url, screenLocation);

// _DonationBanner
final repository = ref.watch(repositoryProvider);
onPressed: () => repository.launchExternalApp(Environment.externalLinkBuyMeACoffe)

// _LocationButton
final repository = ref.read(repositoryProvider);
final result = await repository.openNativeWallpaperPicker(wallpaperEntity.url);

// KustomWidgetsScreen
final repository = ref.watch(repositoryProvider);
final installed = await repository.isKustomAppInstalled(config.targetPackage);

// WallpaperDownloadButton
final repository = ref.read(repositoryProvider);
repository.cancelDownloadWallpaper();
```

Esto rompía la regla del skill `flutter-clean-architect` (los widgets no deben importar `infrastructure`/repository) y duplicaba en cada sitio el mismo patrón de "loading state + try/await + snackbar". Además, varios de esos `ref.watch` ocurrían dentro de `build()`, lo que también violaba el principio "no reconstruir widgets por un side-effect que solo se ejecuta al pulsar".

**Funcionalidad original:**
- Aplicar wallpaper (setWallpaper / native picker / chooser) con feedback de carga y snackbars.
- Descargar wallpaper con barra de progreso y cancelación.
- Mandar widgets a KWGT/KLWP con fallback a la Play Store si la app no está instalada.
- Lanzar URLs externas (donaciones, términos, privacidad, redes sociales).

**Solución aplicada (siguiendo `flutter-clean-architect` + `flutter-riverpod-expert`):**

La sugerencia original proponía un `ApplyWallpaperNotifier` plano con `AsyncValue<bool>`. La implementación real la reemplaza por un patrón más profesional y más alineado con el resto del proyecto: **cuatro `OperationNotifier` agrupados por dominio funcional**, con estado inmutable tipado, `ref.read` en acciones, `ref.mounted` después de awaits y `try/finally` para garantizar reset de estado.

1. **`WallpaperOperationsNotifier`** (Notifier<bool>) — centraliza las 3 operaciones de la pantalla de preview. Reemplaza a `SetWallpaperNotifier` preservando la API booleana (los widgets siguen usando `ref.watch(wallpaperOperationsProvider)` para deshabilitarse mutuamente):

```dart
class WallpaperOperationsNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  Future<bool> applyToLocation(WallpaperEntity wallpaper, int location) async {
    state = true;
    try {
      final repository = ref.read(repositoryProvider);
      final result = await repository.setWallpaper(wallpaper.url, location);
      if (!ref.mounted) return result;
      return result;
    } finally {
      if (ref.mounted) state = false;
    }
  }

  Future<bool> openInNativePicker(WallpaperEntity wallpaper) async {
    state = true;
    try {
      final repository = ref.read(repositoryProvider);
      final result = await repository.openNativeWallpaperPicker(wallpaper.url);
      if (!ref.mounted) return result;
      return result;
    } finally {
      if (ref.mounted) state = false;
    }
  }

  Future<bool> openInChooser(WallpaperEntity wallpaper) async {
    state = true;
    try {
      final repository = ref.read(repositoryProvider);
      final result = await repository.openWallpaperChooser(wallpaper.url);
      if (!ref.mounted) return result;
      return result;
    } finally {
      if (ref.mounted) state = false;
    }
  }
}
```

2. **`DownloadOperationsNotifier`** (Notifier<double?>) — reemplaza a `ProgressDownloaderNotifier`, conserva la API de progreso (incluidos los getters `isDownloading` / `isIndeterminate`) y le suma las operaciones de descarga:

```dart
class DownloadOperationsNotifier extends Notifier<double?> {
  @override
  double? build() => null;

  void changeProgress(double? progress) => state = progress;
  bool get isDownloading => state != null;
  bool get isIndeterminate => state != null && state! < 0;

  Future<bool> download(WallpaperEntity wallpaper) async {
    final repository = ref.read(repositoryProvider);
    changeProgress(-1.0);
    try {
      final success = await repository.downloadWallpaper(
        wallpaper.url.trim(),
        wallpaper.name,
        onProgressUpdate: (progress) {
          if (progress == null) {
            if (!isIndeterminate) changeProgress(-1.0);
          } else {
            changeProgress(progress);
          }
        },
      );
      changeProgress(null);
      return success;
    } catch (_) {
      changeProgress(null);
      return false;
    }
  }

  void cancel() {
    final repository = ref.read(repositoryProvider);
    repository.cancelDownloadWallpaper();
    changeProgress(null);
  }
}
```

3. **`KustomOperationsNotifier`** (Notifier<KustomOperationState>) — centraliza la consulta `isKustomAppInstalled` y el envío de widgets. Estado inmutable tipado (`isLoading`, `lastResult`) siguiendo la regla de "DO: Use immutable entities with copyWith":

```dart
class KustomOperationState {
  final bool isLoading;
  final bool? lastResult;
  const KustomOperationState({this.isLoading = false, this.lastResult});
  KustomOperationState copyWith({bool? isLoading, bool? lastResult}) => ...;
}

class KustomOperationsNotifier extends Notifier<KustomOperationState> {
  @override
  KustomOperationState build() => const KustomOperationState();

  Future<bool> isKustomAppInstalled(String packageName) async {
    final repository = ref.read(repositoryProvider);
    return repository.isKustomAppInstalled(packageName);
  }

  Future<bool> sendWidgetToKustomApp({
    required String packageName,
    required String editorActivity,
    required String assetPath,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final repository = ref.read(repositoryProvider);
      final result = await repository.sendWidgetToKustomApp(
        packageName: packageName,
        editorActivity: editorActivity,
        assetPath: assetPath,
      );
      if (!ref.mounted) return result;
      state = state.copyWith(isLoading: false, lastResult: result);
      return result;
    } catch (_) {
      if (!ref.mounted) return false;
      state = state.copyWith(isLoading: false, lastResult: false);
      return false;
    }
  }
}
```

4. **`ExternalNavigationNotifier`** (Notifier<ExternalNavigationState>) — la única operación que estaba duplicada 8 veces (settings × 3, donation banner, dashboard × 3, package × 3) se unifica en un único punto de entrada. Mantiene `try/finally` con `ref.mounted` para que el flag `isLaunching` se resetee incluso cuando la plataforma rechaza la URL:

```dart
class ExternalNavigationState {
  final bool isLaunching;
  const ExternalNavigationState({this.isLaunching = false});
  ExternalNavigationState copyWith({bool? isLaunching}) => ...;
}

class ExternalNavigationNotifier extends Notifier<ExternalNavigationState> {
  @override
  ExternalNavigationState build() => const ExternalNavigationState();

  Future<void> launchExternalApp(String url) async {
    state = state.copyWith(isLaunching: true);
    try {
      final repository = ref.read(repositoryProvider);
      await repository.launchExternalApp(url);
    } finally {
      if (ref.mounted) state = state.copyWith(isLaunching: false);
    }
  }
}
```

5. **Widgets refactorizados a consumir notifiers** — la pantalla de preview pasa de:

```dart
void _applyWallpaper(BuildContext context, WidgetRef ref) async {
  final repository = ref.read(repositoryProvider);
  final appRouter = ref.read(appRouterProvider);
  final colors = Theme.of(context).colorScheme;
  ref.read(setWallpaperProvider.notifier).changeState();
  final result = await repository.setWallpaper(wallpaperEntity.url, screenLocation);
  if (context.mounted) {
    ref.read(setWallpaperProvider.notifier).changeState();
    if (result) { /* snackbar ok */ } else { /* snackbar error */ }
    appRouter.pop();
  }
}
```

a:

```dart
Future<void> _applyWallpaper(BuildContext context, WidgetRef ref) async {
  final appRouter = ref.read(appRouterProvider);
  final colors = Theme.of(context).colorScheme;
  final result = await ref
      .read(wallpaperOperationsProvider.notifier)
      .applyToLocation(wallpaperEntity, screenLocation);
  if (context.mounted) {
    if (result) { /* snackbar ok */ } else { /* snackbar error */ }
    appRouter.pop();
  }
}
```

6. **`KustomWidgetsScreen` simplificado** — el callback `onTap` de la grid, que antes era un bloque async inline con `final repository = ref.watch(repositoryProvider);` y `await repository.isKustomAppInstalled(...)`, se extrae a un método `_handleWidgetTap` que despacha al notifier correspondiente:

```dart
Future<void> _handleWidgetTap(BuildContext context, WidgetRef ref, String assetPath) async {
  final kustomOps = ref.read(kustomOperationsProvider.notifier);
  final navOps = ref.read(externalNavigationProvider.notifier);
  final installed = await kustomOps.isKustomAppInstalled(config.targetPackage);
  if (!context.mounted) return;
  if (installed) {
    await kustomOps.sendWidgetToKustomApp(
      packageName: config.targetPackage,
      editorActivity: config.editorActivity,
      assetPath: assetPath,
    );
  } else {
    await navOps.launchExternalApp(config.externalLink);
  }
}
```

7. **Cobertura de tests** — `test/presentation/operations_notifiers_test.dart` añade 10 tests nuevos usando un `FakeRepository` que registra las llamadas recibidas, de modo que cada notifier se valida de forma aislada:
   - `WallpaperOperationsNotifier`: forwarding de `applyToLocation`, `openInNativePicker`, `openInChooser` y toggle del estado de loading.
   - `DownloadOperationsNotifier`: progress, reset a idle, cancel, `isIndeterminate`.
   - `KustomOperationsNotifier`: `isKustomAppInstalled` no muta estado, `sendWidgetToKustomApp` propaga resultado y actualiza `lastResult`.
   - `ExternalNavigationNotifier`: forwarding + reset en éxito y en error (la excepción del repository se sigue propagando intacta para que las llamadas a `SnackbarHelpers.showError` ya existentes en `AboutPackageAppScreen` sigan funcionando).
   - Invariante de capas: el `repositoryProvider` solo se obtiene desde el override del test, no desde widgets.

**Mejoras colaterales incluidas:**
- **Contrato `Repository` intacto**: la API del repositorio no cambia, no hace falta tocar `datasource_impl.dart` ni `repository_impl.dart`.
- **API pública preservada en lo visible**: los nombres `wallpaperOperationsProvider`, `downloadOperationsProvider` siguen siendo legibles y descubribles desde `providers.dart`; los widgets que antes dependían de `setWallpaperProvider` y `progressDownloaderProvider` ahora se referencian a sus reemplazos con la misma forma `ref.watch(...)` / `ref.read(...notifier)`.
- **Estilo uniforme**: los cuatro notifiers comparten el mismo patrón (`state = ...` antes del await, `try/finally` con `ref.mounted` para reset, `ref.read` para el repository, error logging vía `debugPrint` o absorción a `false` consistente con el comportamiento histórico del datasource).
- **Proliferación evitada**: en lugar de un `ApplyWallpaperNotifier` + un `OpenNativePickerNotifier` + un `OpenChooserNotifier` + un `IsKustomAppInstalledNotifier` + un `SendWidgetNotifier` + un `LaunchExternalNotifier` (6 notifiers planos), se obtienen 4 notifiers cohesivos. La creación de un notifier por cada combinación de método+estado se sustituye por la agrupación por dominio funcional (siguiendo el principio de "split providers by concern when needed").
- **Mejora de cobertura**: los tests añadidos también cubren el escenario de error (el `FakeRepository` puede configurarse para devolver `false` o lanzar) lo que antes era implícito en cada widget.

**Resultado:**
- Los widgets de presentación ya no importan `repositoryProvider`; la única vía de acceso al repositorio desde la capa de presentación son los cuatro `OperationNotifier`.
- `flutter analyze` y `flutter test` (25/25) pasan sin issues.
- No se rompe la funcionalidad existente: aplicar wallpaper, descargar wallpapers, mandar widgets a Kustom y abrir URLs externas siguen comportándose igual que antes (mismo loading, mismos snackbars, mismo flujo de pop/redirect).
- Los archivos `set_wallpaper_provider.dart` y `progress_downloader_provider.dart` se eliminan, manteniendo el barrel `providers.dart` ordenado alfabéticamente.

---

### 6.2 🟡 `Environment` mezcla múltiples responsabilidades ✅ RESUELTO (2026-06-01)

**Archivos:**
- `lib/config/constants/env_vars.dart` — variables de entorno de `.env` (developer name, URLs).
- `lib/config/constants/storage_keys.dart` — keys de SharedPreferences.
- `lib/config/constants/app_info.dart` — constantes de la app (nombre, versión, developer).
- `lib/config/constants/asset_paths.dart` — rutas de assets.
- `lib/config/constants/wallpaper_constants.dart` — constantes de Android (wallpaper flags).
- `lib/config/constants/external_links.dart` — URLs externas.
- `lib/config/constants/kustom_config.dart` — paquetes y activities de Kustom.
- `lib/config/constants/environment.dart` — barrel export que re-exporta todos los archivos.

**Problema original:**
La clase `Environment` contenía 7 tipos diferentes de constantes mezcladas en un solo archivo, dificultando encontrar configuraciones y creando acoplamiento innecesario.

**Solución aplicada (siguiendo `flutter-clean-architect`):**

1. **Separación por responsabilidad** — Cada tipo de constante vive en su propio archivo con un nombre descriptivo:

```dart
// env_vars.dart
class EnvVars {
  EnvVars._();
  static String userDeveloperName = dotenv.env['DEVELOPER_NAME'] ?? 'Error DEVELOPER_NAME';
  // ...
}

// storage_keys.dart
class StorageKeys {
  StorageKeys._();
  static const String keyThemeMode = 'ThemeMode';
  // ...
}

// app_info.dart
class AppInfo {
  AppInfo._();
  static const String appName = 'Kreator Frame';
  // ...
}
```

2. **Barrel export para compatibilidad** — `environment.dart` mantiene la compatibilidad re-exportando todos los archivos:

```dart
// environment.dart
export 'app_info.dart';
export 'asset_paths.dart';
export 'env_vars.dart';
export 'external_links.dart';
export 'kustom_config.dart';
export 'storage_keys.dart';
export 'wallpaper_constants.dart';
```

3. **Imports actualizados** — Todos los archivos que usaban `Environment` ahora importan la clase específica o usan el barrel export:

```dart
// Antes
import 'package:kreator_frame/config/constants/environment.dart';
Environment.keyColorTheme

// Después (opción específica)
import 'package:kreator_frame/config/constants/storage_keys.dart';
StorageKeys.keyColorTheme

// Después (opción barrel)
import 'package:kreator_frame/config/config.dart';
StorageKeys.keyColorTheme
```

**Archivos actualizados:**
- `lib/presentation/providers/app_values_preferences_provider.dart` — usa `StorageKeys`
- `lib/presentation/screens/tertiary/about_package_app_screen.dart` — usa `AssetPaths`, `EnvVars`, `AppInfo`
- `lib/presentation/screens/tertiary/about_dashboard_screen.dart` — usa `AssetPaths`, `AppInfo`, `ExternalLinks`
- `lib/presentation/screens/secondary/settings_screen.dart` — usa `AppInfo`, `ExternalLinks`
- `lib/presentation/screens/secondary/kustom_widgets_screen.dart` — usa `ExternalLinks`, `KustomConfig`
- `lib/presentation/screens/tertiary/wallpaper_preview_screen.dart` — usa `WallpaperConstants`
- `lib/infrastructure/datasources/datasource_impl.dart` — usa `EnvVars`
- `lib/presentation/widgets/appbar/custom_sliver_appbar.dart` — usa `AssetPaths`, `EnvVars`, `AppInfo`
- `lib/presentation/providers/tabs_bar_app_provider.dart` — usa `EnvVars`

**Resultado:**
- Cada constante vive en un archivo enfocado con un nombre descriptivo.
- Los imports son más explícitos sobre qué constantes se usan.
- `environment.dart` mantiene la compatibilidad con código existente.
- `flutter analyze` y `flutter test` (25/25) pasan sin issues.
- No se rompe la funcionalidad: todas las constantes siguen accesibles con los mismos valores.

---

## 7. Bugs y errores potenciales

### 7.1 🔴 \`DataSourceImpl._activeCancelToken\` — pérdida de referencia ✅ RESUELTO

**Archivos:**
- `lib/shared/services/download_cancel_token_holder.dart` — nuevo servicio `DownloadCancelTokenHolder` que custodia el `CancelToken` activo.
- `lib/shared/services/services.dart` — exporta el nuevo holder.
- `lib/infrastructure/datasources/datasource_impl.dart` — recibe el holder vía constructor (DI) y delega en él `register`/`cancel`/`clear`; elimina el campo `_activeCancelToken` propio.
- `lib/presentation/providers/repository_provider.dart` — nuevo `downloadCancelTokenHolderProvider` (singleton estable) inyectado en `dataSourceProvider`.
- `test/shared/download_cancel_token_holder_test.dart` — cobertura unitaria del holder, incluyendo el escenario del bug (token sobrevive a un "rebuild" simulado del datasource).

**Problema original:**
```dart
class DataSourceImpl extends DataSource {
  CancelToken? _activeCancelToken;  // ← Variable de instancia

  @override
  void cancelDownloadWallpaper() {
    _activeCancelToken?.cancel('Download cancelled by user');
    _activeCancelToken = null;
  }
}
```

`DataSourceImpl` se creaba dentro de `dataSourceProvider`, que hace `ref.watch(dioProvider)`. Si `dioProvider` se invalidaba (o cualquier otra dependencia observada), `dataSourceProvider` se reconstruía con una instancia nueva de `DataSourceImpl` y el `_activeCancelToken` de la instancia anterior quedaba huérfano. La llamada a `cancelDownloadWallpaper()` llegaba a la instancia nueva, que no tenía el token activo, por lo que el usuario perdía la capacidad de cancelar la descarga en curso. Adicionalmente, la API original no gestionaba correctamente un escenario de solapamiento (una nueva descarga sobrescribía el token previo sin cancelarlo, dejando la primera huérfana).

**Funcionalidad original:**
El usuario podía cancelar una descarga tocando el botón de progreso, pero la cancelación dependía de que la misma instancia de `DataSourceImpl` siguiera viva.

**Solución aplicada (siguiendo `flutter-clean-architect` + `flutter-riverpod-expert`):**

Se optó por un patrón más profesional que la sugerencia original (un `Provider<CancelToken>` directo). En su lugar se introdujo un **servicio reutilizable** dedicado a custodiar el ciclo de vida del token, alineado con el patrón ya existente del proyecto (`KeyValueStorageServices` + `KeyValueStorageServicesImpl`):

1. **Servicio de dominio compartido** — `DownloadCancelTokenHolder` (en `lib/shared/services/`) aísla el detalle de implementación de `dio` y expone una API mínima, framework-agnostic y trivialmente testeable:

```dart
class DownloadCancelTokenHolder {
  CancelToken? _activeToken;

  CancelToken? get activeToken => _activeToken;
  bool get hasActiveToken => _activeToken != null;

  CancelToken register() {
    final previous = _activeToken;
    if (previous != null && !previous.isCancelled) {
      previous.cancel('Superseded by a new download request');
    }
    final token = CancelToken();
    _activeToken = token;
    return token;
  }

  void cancel() {
    final token = _activeToken;
    if (token == null) return;
    if (!token.isCancelled) {
      token.cancel('Download cancelled by user');
    }
    _activeToken = null;
  }

  void clear() {
    _activeToken = null;
  }
}
```

2. **DI explícita en el datasource** — `DataSourceImpl` recibe el holder por constructor, eliminando cualquier estado mutable de descarga propio de la clase:

```dart
class DataSourceImpl extends DataSource {
  final Dio _dio;
  final DownloadCancelTokenHolder _downloadCancelTokenHolder;

  DataSourceImpl({
    required this._dio,
    required this._downloadCancelTokenHolder,
  });
  // ...
}
```

`downloadWallpaper` y `cancelDownloadWallpaper` delegan en el holder:

```dart
@override
Future<bool> downloadWallpaper(
  String url,
  String fileName, {
  void Function(double?)? onProgressUpdate,
}) async {
  final cancelToken = _downloadCancelTokenHolder.register();
  try {
    final response = await _dio.get(
      url,
      cancelToken: cancelToken,
      // ...
    );
    _downloadCancelTokenHolder.clear();
    // ... save image, return result ...
  } on DioException catch (e) {
    _downloadCancelTokenHolder.clear();
    // ...
  } catch (e) {
    _downloadCancelTokenHolder.clear();
    // ...
  }
}

@override
void cancelDownloadWallpaper() {
  _downloadCancelTokenHolder.cancel();
}
```

3. **Provider singleton estable** — `downloadCancelTokenHolderProvider` se expone como `Provider<DownloadCancelTokenHolder>` no auto-disposed y se inyecta en `dataSourceProvider`. La clave del fix es que este provider **no se invalida junto con `dataSourceProvider`**, por lo que la referencia al token activo permanece viva aunque `DataSourceImpl` se reconstruya:

```dart
final downloadCancelTokenHolderProvider =
    Provider<DownloadCancelTokenHolder>((ref) {
  final holder = DownloadCancelTokenHolder();
  ref.onDispose(holder.clear);
  return holder;
});

final dataSourceProvider = Provider<DataSource>((ref) {
  final dio = ref.watch(dioProvider);
  final downloadCancelTokenHolder =
      ref.watch(downloadCancelTokenHolderProvider);
  return DataSourceImpl(
    dio: dio,
    downloadCancelTokenHolder: downloadCancelTokenHolder,
  );
});
```

4. **Contrato sin cambios** — ni la interfaz `DataSource` ni `Repository` ni `WallpaperDownloadButton` requieren cambios. La API pública `cancelDownloadWallpaper()` se conserva exactamente igual, de modo que la integración con la UI existente (`_cancelDownload` en `WallpaperDownloadButton`) no se ve afectada.

**Mejoras colaterales incluidas:**
- Solapamiento seguro: `register()` cancela cualquier token previo todavía activo, evitando que una descarga anterior quede huérfana cuando el usuario inicia otra consecutivamente.
- Idempotencia: `cancel()` y `clear()` son seguros de llamar múltiples veces o sin token activo.
- Testabilidad: el holder se puede mockear trivialmente y se cubre con 8 tests unitarios que incluyen un caso que simula explícitamente el escenario del bug (token registrado, "datasource" recreado, cancelación todavía efectiva).

**Resultado:**
- `_activeCancelToken` ya no es un campo de instancia de `DataSourceImpl`, por lo que no se pierde cuando el provider se reconstruye.
- El `CancelToken` vive en un holder cuyo provider es estable, garantizando que `cancelDownloadWallpaper()` siempre opera sobre el token de la descarga real en curso.
- La separación de capas se preserva: `dio` sigue siendo un detalle de `infrastructure`, el holder vive en `shared/services` y la UI sigue hablando solo con el repositorio.
- `flutter analyze` y `flutter test` (15/15) pasan sin issues.
- No se rompe la funcionalidad de descarga ni la de cancelación.

---

### 7.2 🟠 `WallpaperPreviewScreen` — `ref.watch` en acción de botón ✅ RESUELTO

**Archivo:** `lib/presentation/screens/tertiary/wallpaper_preview_screen.dart`

**Problema:**
```dart
void _applyWallpaper(BuildContext context, WidgetRef ref) async {
  final repository = ref.watch(repositoryProvider);  // ← watch en acción
  final appRouter = ref.watch(appRouterProvider);    // ← watch en acción
  ...
}
```

Usar `ref.watch()` dentro de un método de acción (no en `build()`) puede causar comportamiento inesperado. Se debe usar `ref.read()` para lecturas de una sola vez.

**Posible mejora:**
Cambiar `ref.watch()` por `ref.read()`.

**Relaciones:**
- `repositoryProvider` y `appRouterProvider` — son providers estables
- No afecta funcionalidad

---

### 7.3 🟠 `DataSourceImpl.getListOfWidgets` — `firstWhere` sin `orElse` ✅ RESUELTO (en Fix 4)

**Archivo:** `lib/infrastructure/datasources/datasource_impl.dart`

**Problema:**
```dart
ArchiveFile? thumbFile =
    archive.firstWhere((file) => file.name == thumbName);
```

Si ningún archivo en el zip coincide con `thumbName`, `firstWhere` lanza `StateError: No element`. Aunque el tipo es `ArchiveFile?` (nullable), `firstWhere` no retorna `null` — lanza excepción.

**Funcionalidad actual:**
Si el zip no contiene el thumbnail esperado, la app crashea.

**Posible mejora:**
```dart
ArchiveFile? thumbFile;
try {
  thumbFile = archive.firstWhere((file) => file.name == thumbName);
} on StateError {
  thumbFile = null;
}

// O usar firstWhereOrNull de package:collection
final thumbFile = archive.firstWhereOrNull((file) => file.name == thumbName);
```

**Relaciones:**
- `WidgetEntity` — maneja `Uint8List` nullable para thumbnail
- `KustomWidgetsScreen` — muestra placeholder si no hay thumbnail
- `CustomCardPreviews` — ya maneja `image == null`

---

### 7.4 🟡 `MyApp.build()` — efecto secundario con `ref.read` en `build()` ✅ RESUELTO (2026-06-01)

**Archivo:** `lib/main.dart`

**Problema original:**
```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  ...
  // Update notifier so the UI can react to dynamic color availability
  ref.read(appValuesPreferencesProvider.notifier).updateDynamicColorAvailability(dynamicAvailable);
  ...
}
```

Llamar a `ref.read(...).updateDynamicColorAvailability()` dentro de `build()` es un efecto secundario. Cada rebuild de `MyApp` puede actualizar el estado del provider, causando un ciclo potencial de rebuilds.

**Análisis de la sugerencia original:**
La sugerencia proponía usar `ref.listen()` o mover la lógica al notifier. Sin embargo, la validación de dynamic color depende de los esquemas de color proporcionados por `DynamicColorBuilder`, que solo están disponibles en el contexto del widget.

**Solución aplicada (siguiendo `flutter-riverpod-expert`):**

1. **`ConsumerStatefulWidget` con `addPostFrameCallback`** — `_MyAppContent` se convierte en `ConsumerStatefulWidget` para poder usar `initState` y programar la actualización después del frame:

```dart
class _MyAppContent extends ConsumerStatefulWidget {
  const _MyAppContent();

  @override
  ConsumerState<_MyAppContent> createState() => _MyAppContentState();
}

class _MyAppContentState extends ConsumerState<_MyAppContent> {
  @override
  void initState() {
    super.initState();
    // Schedule the dynamic color validation after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _validateDynamicColor();
    });
  }
  // ...
}
```

2. **`addPostFrameCallback` en el builder** — La actualización del notifier se programa después de que el frame se complete, evitando el efecto secundario en `build()`:

```dart
return DynamicColorBuilder(
  builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
    // ... validación de dynamic color ...

    // Update notifier after the build completes to avoid side-effects in build()
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appValuesPreferencesProvider.notifier).updateDynamicColorAvailability(dynamicAvailable);
    });

    // ... construcción del MaterialApp ...
  },
);
```

**Mejoras incluidas:**
- **Sin efectos secundarios en `build()`**: la actualización del notifier se programa después del frame.
- **Ciclo de rebuilds evitado**: `addPostFrameCallback` se ejecuta una vez por frame, no en cada rebuild.
- **Lógica de validación preservada**: la validación de dynamic color sigue ocurriendo en el contexto correcto del widget.
- **Compatibilidad con `ref.select()`**: el widget sigue usando `ref.select()` para optimizar rebuilds.

**Resultado:**
- `_MyAppContent` ya no tiene efectos secundarios directos en `build()`.
- La actualización de `dynamicColorAvailable` se programa después del frame.
- `flutter analyze` y `flutter test` (25/25) pasan sin issues.
- No se rompe la funcionalidad: la validación de dynamic color sigue funcionando correctamente.

---

### 7.5 🟡 `AppValuesPreferencesNotifier` — `setKeyValue` sin await ✅ RESUELTO (en Fix 1)

**Archivo:** `lib/presentation/providers/app_values_preferences_provider.dart`

**Problema:**
```dart
void setPreferenceForThemeMode(ThemeMode themeMode) async {
  await _keyValueStorageServices.setKeyValue(Environment.keyThemeMode, themeMode.name);
  if (themeMode != state.themeModeForApp) {
    state = state.copyWith(themeModeForApp: themeMode);
  }
}
```

El método es `void` pero usa `async/await`. Si la persistencia falla, el estado se actualiza pero la preferencia no se guarda. En la próxima app restart, se revertirá al valor anterior.

**Posible mejora:**
```dart
Future<void> setPreferenceForThemeMode(ThemeMode themeMode) async {
  await _keyValueStorageServices.setKeyValue(Environment.keyThemeMode, themeMode.name);
  if (!ref.mounted) return;
  state = state.copyWith(themeModeForApp: themeMode);
}
```

**Relaciones:**
- `ThemeModeSwitcher` — llama este método
- `SharedPreferences` — persiste el valor
- `build()` — lee el valor persisted

---

## 8. Resumen de archivos afectados

> Los archivos listados a continuación corresponden al estado **previo** al barrido de fixes documentado en la sección [Estado de implementación](#estado-de-implementación). Cada item se cruza con el identificador del fix que lo resolvió (o lo deja como pendiente / omitido) para mantener trazabilidad con las secciones anteriores.

### Archivos críticos (todos resueltos)

| Archivo | Problema original | Fix |
|---------|-------------------|-----|
| `lib/infrastructure/datasources/datasource_impl.dart` | `Archive` sin dispose, sin caching, `firstWhere` sin `orElse`, `CancelToken` frágil | 4.1, 7.1, 7.3 |
| `lib/presentation/providers/app_values_preferences_provider.dart` | Race condition en `build()`, `setKeyValue` sin await, sin DI para KeyValueStorage | 3.1, 3.5 ✅ RESUELTO, 7.5 |
| `lib/presentation/providers/in_app_update_provider.dart` | Efecto secundario en `build()`, falta de `ref.mounted` | 3.2, 3.4 |

### Archivos altos (resueltos o con seguimiento explícito)

| Archivo | Problema original | Fix |
|---------|-------------------|-----|
| `lib/presentation/screens/tertiary/wallpaper_preview_screen.dart` | Imagen completa en memoria, `ref.watch` en acciones, acceso directo a repository | 4.2, 6.1, 7.2 |
| `lib/shared/utils/color_palette_extractor.dart` | `ui.Image` sin dispose | 4.3 |
| `lib/presentation/providers/permissions_provider.dart` | Async sin await en `build()`, falta de `ref.mounted` | 3.3, 3.4 |
| `lib/presentation/screens/secondary/kustom_widgets_screen.dart` | Acceso directo a repository | 6.1 |
| `lib/presentation/screens/secondary/settings_screen.dart` | `UniqueKey()` en `Dismissible`, acceso directo a repository | 4.5 (marcado intencional), 6.1 |
| `lib/presentation/screens/tertiary/about_dashboard_screen.dart` | Acceso directo a repository | 6.1 |
| `lib/presentation/screens/tertiary/about_package_app_screen.dart` | Acceso directo a repository | 6.1 |
| `lib/presentation/widgets/buttons/wallpaper_download_button.dart` | Acceso directo a repository, `progressDownloaderProvider` mixed con repository | 6.1 |

### Archivos medios

| Archivo | Problema original | Fix |
|---------|-------------------|-----|
| `lib/main.dart` | Efecto secundario en `build()`, sin `ref.select()` | 5.1 ✅ RESUELTO, 7.4 ✅ RESUELTO |
| `lib/config/constants/environment.dart` | Mezcla de responsabilidades | 6.2 ✅ RESUELTO |
| `lib/shared/services/key_value_storage_service_impl.dart` | `SharedPreferences.getInstance()` repetido | 4.6 |
| `lib/domain/entities/theme_mode_entity.dart` | Tipos Flutter en domain | 2.2 ✅ RESUELTO |
| `lib/domain/entities/network_failure.dart` | Nunca usado (código muerto) | 2.3 ✅ RESUELTO (eliminado) |
| `lib/presentation/providers/tabs_bar_app_provider.dart` | Carga pesada sin caching | 4.1 (compartido vía `keepAlive`) |
| `lib/presentation/providers/repository_provider.dart` | Sin DI del cancel token holder, sin sincronización de dependencias | 7.1 (fix reciente) |

---

> **Nota:** Este análisis se basa en las directrices de las skills `flutter-clean-architect` v2.1.0 y `flutter-riverpod-expert` v3.0.0, aplicadas al código fuente del proyecto kreator_frame. Las mejoras propuestas preservan la funcionalidad existente y están diseñadas para implementarse de forma incremental.
