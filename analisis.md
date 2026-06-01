# Análisis Técnico — Kreator Frame

> Auditoría completa de arquitectura, gestión de estado con Riverpod, fugas de recursos,
> acoplamiento entre capas y oportunidades de mejora.
>
> Skills aplicadas: `flutter-clean-architect` · `flutter-riverpod-expert`
>
> Fecha: 2026-05-30
>
> Última actualización: 2026-06-01 — Estado de implementación actualizado con todos los fixes commiteados.

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
| 🔴 Crítico | 3 | Race conditions, fuga de memoria en assets, efectos secundarios en `build()` |
| 🟠 Alto | 5 | Fugas de memoria en imágenes/UI, falta de `ref.mounted`, acoplamiento domain↔presentation |
| 🟡 Medio | 6 | Rebuilds innecesarios, falta de caching, dependencias sin DI |
| 🟢 Bajo | 3 | Código sin usar, constantes mezcladas, mejoras de UX |

### Estado de implementación

| Fix | Estado | Commit |
|-----|--------|--------|
| 3.1 Race condition AppValuesPreferencesNotifier | ✅ RESUELTO | `11cf168` |
| 3.2 Efecto secundario InAppUpdateNotifier | ✅ RESUELTO | `2cc506a` |
| 3.3 Async no await PermissionsNotifier | ✅ RESUELTO | `f7e5b2a` |
| 3.4 Falta de ref.mounted post-async | ✅ RESUELTO | `2cc506a` |
| 3.5 KeyValueStorageServicesImpl sin DI | ❌ PENDIENTE | — |
| 3.6 ref.watch en métodos de acción | ✅ RESUELTO | `a53bc82` |
| 4.1 getListOfWidgets caching | ✅ RESUELTO | `4fb6553` |
| 4.2 WallpaperPreviewScreen memoria | ✅ RESUELTO | `4eee4b2` |
| 4.3 ColorPaletteExtractor dispose | ✅ RESUELTO | `93b3fdd` |
| 4.5 DonationBanner UniqueKey | ✅ INTENCIONAL | — |
| 4.6 SharedPreferences caching | ✅ RESUELTO | `ae15640` |
| 5.1 MyApp ref.select | ⏭️ OMITIDO | impacto bajo |
| 5.2 WallpaperDownloadButton rebuilds | ⏭️ OMITIDO | impacto menor |
| 5.3 keepAlive providers | ✅ CORRECTO | — |
| 6.1 Acceso directo repository | ⏭️ PENDIENTE | refactor grande |
| 6.2 Environment responsabilidades | ⏭️ OMITIDO | mantenibilidad |
| 7.1 _activeCancelToken pérdida de referencia | ❌ PENDIENTE | — |
| 7.2 ref.watch en acciones | ✅ RESUELTO | `a53bc82` |
| 7.3 firstWhere sin orElse | ✅ RESUELTO | `4fb6553` |
| 7.4 MyApp efecto secundario | ⏭️ OMITIDO | bajo impacto |
| 7.5 setKeyValue sin await | ✅ RESUELTO | `11cf168` |
| 2.1 TabBarEntity Widget | ✅ RESUELTO | `c58ebfa` |
| 2.3 NetworkFailure sin usar | ⏭️ OMITIDO | UX |

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

### 2.2 🟠 `ThemeModeEntity` contiene tipos Flutter

**Archivo:** `lib/domain/entities/theme_mode_entity.dart`

**Problema:**
```dart
class ThemeModeEntity {
  final ThemeMode themeMode;   // ← Tipo de Flutter
  final String Function(BuildContext) title;  // ← Callback con BuildContext
  final IconData icon;          // ← Tipo de Flutter
  ...
}
```

**Funcionalidad actual:**
Se usa en `AppConstants.themeModeOptions` para definir las opciones del selector de tema.

**Posible mejora:**
Separar la entidad de datos del widget de presentación:

```dart
// Domain
enum ThemeModeOption { system, light, dark }

// Presentation - mapear a UI
IconData iconFor(ThemeModeOption option) => switch (option) { ... };
String labelFor(ThemeModeOption option, BuildContext ctx) => switch (option) { ... };
```

**Relaciones:**
- `AppConstants.themeModeOptions` (`lib/shared/utils/app_constants.dart`)
- `ThemeModeSwitcher` (`lib/presentation/widgets/theme/theme_mode_switcher.dart`)
- `AppValuesPreferencesNotifier` (`lib/presentation/providers/app_values_preferences_provider.dart`)

---

### 2.3 🟡 `NetworkFailure` definido pero nunca usado ⏭️ OMITIDO (mejora de UX, bajo impacto)

**Archivo:** `lib/domain/entities/network_failure.dart`

**Problema:**
La clase `NetworkFailure` con su enum `NetworkFailureType` está definida y exportada pero nunca se utiliza en ningún archivo del proyecto. Todo el manejo de errores usa excepciones genéricas (`catch (e)`).

**Funcionalidad actual:**
Los datasources capturan errores y retornan valores por defecto (listas vacías, `false`, strings de error).

**Posible mejora:**
Implementar un sistema de errores tipado en la capa de dominio y usarlo en los notifiers:

```dart
// Domain - resultado tipado
sealed class Result<T> {
  const Result();
}
class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}
class Failure<T> extends Result<T> {
  final NetworkFailure failure;
  const Failure(this.failure);
}
```

**Relaciones:**
- `DataSourceImpl` — todos los métodos `catch` retornarían `Failure`
- Todos los `AsyncNotifier` — usarían `AsyncValue.guard()` con el tipo de error
- `ErrorView` — podría mostrar mensajes más específicos según el tipo de fallo

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

### 3.5 🟡 \`KeyValueStorageServicesImpl\` instanciado directamente ❌ PENDIENTE

**Archivo:** `lib/presentation/providers/app_values_preferences_provider.dart`

**Problema:**
```dart
@override
AppValuesPreferencesState build() {
  _keyValueStorageServices = KeyValueStorageServicesImpl();  // ← Instanciado directamente
  ...
}
```

`KeyValueStorageServicesImpl` se crea dentro del notifier en lugar de inyectarse via provider. Esto impide:
- Testing con mocks
- Reutilización del mismo singleton de SharedPreferences
- Cambio de implementación sin modificar el notifier

**Posible mejora:**
```dart
// Provider
final keyValueStorageProvider = Provider<KeyValueStorageServices>((ref) {
  return KeyValueStorageServicesImpl();
});

// En el notifier
class AppValuesPreferencesNotifier extends Notifier<AppValuesPreferencesState> {
  @override
  AppValuesPreferencesState build() {
    _keyValueStorageServices = ref.watch(keyValueStorageProvider);
    ...
  }
}
```

**Relaciones:**
- `KeyValueStorageServicesImpl` — no cambia
- `AppValuesPreferencesNotifier` — recibe la dependencia via DI
- Test mocking — se facilita significativamente

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

### 5.1 🟡 `MyApp` se reconstruye con cualquier cambio de preferencia ⏭️ OMITIDO (impacto bajo, cambios de tema son infrecuentes)

**Archivo:** `lib/main.dart`

**Problema:**
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

**Posible mejora:**
Usar `ref.select()` para observar solo los campos necesarios:

```dart
final themeMode = ref.watch(appValuesPreferencesProvider.select((s) => s.themeModeForApp));
final colorAccent = ref.watch(appValuesPreferencesProvider.select((s) => s.colorAccentForTheme));
final isDynamic = ref.watch(appValuesPreferencesProvider.select((s) => s.isDynamicColor));
```

**Relaciones:**
- `AppValuesPreferencesState` — no cambia
- `AppTheme` — recibe los valores individuales
- No rompe funcionalidad, mejora rendimiento

---

### 5.2 🟡 `WallpaperDownloadButton` — rebuilds frecuentes durante descarga ⏭️ OMITIDO (progreso visible es intencional, impacto menor)

**Archivo:** `lib/presentation/widgets/buttons/wallpaper_download_button.dart`

**Problema:**
Durante una descarga, el callback `onProgressUpdate` actualiza `progressDownloaderProvider` con cada chunk recibido. Cada actualización reconstruye el botón y cualquier otro widget que observe ese provider.

**Posible mejora:**
- Usar `ref.select()` en los widgets que solo necesitan saber si está descargando (boolean)
- Separar el progreso detallado del estado de "descargando/no descargando"

```dart
// En el widget:
final isDownloading = ref.watch(progressDownloaderProvider.select((p) => p != null));
final progressValue = ref.watch(progressDownloaderProvider); // Solo si se necesita el valor
```

**Relaciones:**
- `progressDownloaderProvider` — no cambia su API
- `WallpaperDownloadButton` — solo cambia la suscripción
- Otros widgets que observen el provider — pueden usar select también

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

### 6.1 🟠 Acceso directo a `repositoryProvider` desde widgets ⏭️ PENDIENTE (refactor grande, requiere crear notifiers dedicados)

**Archivos afectados:**
- `lib/presentation/screens/tertiary/wallpaper_preview_screen.dart` — `_LocationButton`, `_WallpaperChooserButton`, `_NativePickerButton`
- `lib/presentation/screens/secondary/kustom_widgets_screen.dart` — `KustomWidgetsScreen`
- `lib/presentation/screens/secondary/settings_screen.dart` — `_DonationBanner`
- `lib/presentation/screens/tertiary/about_dashboard_screen.dart`
- `lib/presentation/screens/tertiary/about_package_app_screen.dart`

**Problema:**
Los widgets acceden directamente a `repositoryProvider` para llamar métodos como `setWallpaper`, `openNativeWallpaperPicker`, `isKustomAppInstalled`, `launchExternalApp`, etc.

Esto viola el patrón de capas: los widgets de presentación no deberían interactuar directamente con el repositorio. Debería haber un notifier intermedio que maneje la lógica de negocio.

**Funcionalidad actual:**
Al tocar el botón de "aplicar wallpaper", el widget llama directamente al repositorio:
```dart
void _applyWallpaper(BuildContext context, WidgetRef ref) async {
  final repository = ref.watch(repositoryProvider);  // ← Acceso directo
  final result = await repository.setWallpaper(wallpaperEntity.url, screenLocation);
  // ...
}
```

**Posible mejora:**
Crear notifiers dedicados para las operaciones:

```dart
// Provider de operación
class ApplyWallpaperNotifier extends Notifier<AsyncValue<bool>> {
  @override
  AsyncValue<bool> build() => const AsyncData(false);

  Future<void> apply(String url, int location) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(repositoryProvider);
      return await repo.setWallpaper(url, location);
    });
  }
}

// En el widget:
onPressed: () => ref.read(applyWallpaperProvider.notifier).apply(url, location);
```

**Relaciones:**
- `setWallpaperProvider` — ya existe como boolean simple, podría reutilizarse o extenderse
- `RepositoryImpl` — no cambia
- Las pantallas consumidoras — usan el notifier en lugar del repositorio directo

---

### 6.2 🟡 `Environment` mezcla múltiples responsabilidades ⏭️ OMITIDO (mejora de mantenibilidad, bajo impacto funcional)

**Archivo:** `lib/config/constants/environment.dart`

**Problema:**
La clase `Environment` contiene:
1. Variables de entorno de `.env` (developer name, URLs)
2. Keys de SharedPreferences
3. Constantes de la app (nombre, versión)
4. Paths de assets
5. Constantes de Android (wallpaper flags)
6. URLs externas
7. Paquetes de Kustom

Esto dificulta encontrar configuraciones y crea acoplamiento innecesario.

**Posible mejora:**
Separar en archivos enfocados:
```
lib/config/constants/
├── environment.dart        ← Solo .env vars
├── app_constants.dart      ← Nombre, versión, developer
├── storage_keys.dart       ← SharedPreferences keys
├── asset_paths.dart        ← Rutas de assets
├── android_constants.dart  ← Wallpaper flags, etc.
├── external_links.dart     ← URLs externas
└── kustom_config.dart      ← Paquetes y activities de Kustom
```

**Relaciones:**
- Todos los archivos que importan `Environment` — necesitan actualizar imports
- No rompe funcionalidad, mejora mantenibilidad

---

## 7. Bugs y errores potenciales

### 7.1 🔴 \`DataSourceImpl._activeCancelToken\` — pérdida de referencia ❌ PENDIENTE

**Archivo:** `lib/infrastructure/datasources/datasource_impl.dart`

**Problema:**
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

`DataSourceImpl` se crea como provider. Si `dioProvider` cambia (por cualquier razón), `dataSourceProvider` se recrea, y `_activeCancelToken` se pierde. El usuario no podría cancelar la descarga en curso.

**Funcionalidad actual:**
El usuario puede cancelar una descarga de wallpaper tocando el botón de progreso.

**Posible mejora:**
Mover el `CancelToken` a un provider dedicado:
```dart
final downloadCancelTokenProvider = Provider<CancelToken>((ref) {
  final token = CancelToken();
  ref.onDispose(() => token.cancel());
  return token;
});
```

O mejor, usar un notifier de operación de descarga que gestione el ciclo de vida.

**Relaciones:**
- `WallpaperDownloadButton` — llama `cancelDownloadWallpaper()`
- `downloadWallpaper` en `DataSourceImpl` — necesita el token
- `dioProvider` — si cambia, el token sobrevive

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

### 7.4 🟡 `MyApp.build()` — efecto secundario con `ref.read` en `build()` ⏭️ OMITIDO (necesario para validación de dynamic color, bajo impacto)

**Archivo:** `lib/main.dart`

**Problema:**
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

**Posible mejora:**
Usar `ref.listen()` en un widget raíz o mover la lógica a un `Hook` o `useEffect`:

```dart
// En MyApp o en un widget wrapper
ref.listen(appValuesPreferencesProvider, (prev, next) {
  // La lógica de validación de dynamic color ya debería estar en el notifier
});
```

O mejor, mover toda la lógica de validación de dynamic color al `AppValuesPreferencesNotifier`:

```dart
// En el notifier, después de cargar preferencias:
void validateDynamicColor(bool isAvailable) {
  if (state.isDynamicColor && state.dynamicColorAvailable != isAvailable) {
    state = state.copyWith(dynamicColorAvailable: isAvailable);
  }
}
```

**Relaciones:**
- `appValuesPreferencesProvider` — recibe la actualización
- `DynamicColorValidator` — se puede integrar en el notifier
- `ThemeSelectorScreen` — muestra el warning de dynamic color

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

### Archivos con problemas críticos (requieren corrección urgente)

| Archivo | Problema |
|---------|----------|
| `lib/infrastructure/datasources/datasource_impl.dart` | `Archive` sin dispose, sin caching, `firstWhere` sin orElse, `CancelToken` frágil |
| `lib/presentation/providers/app_values_preferences_provider.dart` | Race condition en `build()`, sin DI, sin `ref.mounted` |
| `lib/presentation/providers/in_app_update_provider.dart` | Efecto secundario en `build()`, sin `ref.mounted` |

### Archivos con problemas altos

| Archivo | Problema |
|---------|----------|
| `lib/presentation/screens/tertiary/wallpaper_preview_screen.dart` | Imagen completa en memoria, `ref.watch` en acciones |
| `lib/shared/utils/color_palette_extractor.dart` | `ui.Image` sin dispose |
| `lib/presentation/providers/permissions_provider.dart` | Async sin await en `build()`, sin `ref.mounted` |
| `lib/presentation/screens/secondary/kustom_widgets_screen.dart` | Acceso directo a repository |
| `lib/presentation/screens/secondary/settings_screen.dart` | `UniqueKey()` en Dismissible |

### Archivos con problemas medios

| Archivo | Problema |
|---------|----------|
| `lib/main.dart` | Efecto secundario en `build()`, sin `ref.select()` |
| `lib/config/constants/environment.dart` | Mezcla de responsabilidades |
| `lib/shared/services/key_value_storage_service_impl.dart` | `SharedPreferences.getInstance()` repetido |
| `lib/domain/entities/theme_mode_entity.dart` | Tipos Flutter en domain |
| `lib/domain/entities/network_failure.dart` | Nunca usado |
| `lib/presentation/providers/tabs_bar_app_provider.dart` | Carga pesada sin caching |

---

> **Nota:** Este análisis se basa en las directrices de las skills `flutter-clean-architect` v2.1.0 y `flutter-riverpod-expert` v3.0.0, aplicadas al código fuente del proyecto kreator_frame. Las mejoras propuestas preservan la funcionalidad existente y están diseñadas para implementarse de forma incremental.
