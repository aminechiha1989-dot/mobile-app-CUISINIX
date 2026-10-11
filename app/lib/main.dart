import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'https://nwvvixepyeoouraeraeu.supabase.co';
const supabaseAnonKey = 'sb_publishable_ids5xXyb8vt2VGIsYBksDA_NDhO4QNH';

// ---------------------------------------------------------------------------
// Langues : fr, en, ar (arabe standard), aeb (derja tunisienne)
// ---------------------------------------------------------------------------
final ValueNotifier<String> appLang = ValueNotifier<String>('fr');

const Map<String, String> _langNames = {
  'fr': 'Français',
  'en': 'English',
  'ar': 'العربية',
  'aeb': 'الدارجة التونسية',
};

bool get _isRtl => appLang.value == 'ar' || appLang.value == 'aeb';

const Map<String, Map<String, String>> _ui = {
  'appTitle': {'fr': 'Cuisinix – Recettes', 'en': 'Cuisinix – Recipes', 'ar': 'Cuisinix – وصفات', 'aeb': 'Cuisinix – وصفات'},
  'myIngredients': {'fr': 'Mes ingrédients', 'en': 'My ingredients', 'ar': 'مكوّناتي', 'aeb': 'المكوّنات متاعي'},
  'fixList': {'fr': 'Corrige la liste si besoin.', 'en': 'Edit the list if needed.', 'ar': 'عدّل القائمة عند الحاجة.', 'aeb': 'صحّح القائمة كان لزم.'},
  'clearAll': {'fr': 'Tout effacer', 'en': 'Clear all', 'ar': 'مسح الكل', 'aeb': 'امسح الكل'},
  'addPhoto': {'fr': 'Ajouter une photo', 'en': 'Add a photo', 'ar': 'أضف صورة', 'aeb': 'زيد تصويرة'},
  'viewRecipes': {'fr': 'Voir les recettes', 'en': 'View recipes', 'ar': 'عرض الوصفات', 'aeb': 'شوف الوصفات'},
  'scanBtn': {'fr': 'Scanner mes ingrédients', 'en': 'Scan my ingredients', 'ar': 'صوّر مكوّناتك', 'aeb': 'صوّر المكوّنات متاعك'},
  'analyzing': {'fr': 'Analyse…', 'en': 'Analyzing…', 'ar': 'جارٍ التحليل…', 'aeb': 'نحلّل…'},
  'takePhoto': {'fr': 'Prendre une photo', 'en': 'Take a photo', 'ar': 'التقاط صورة', 'aeb': 'خذ تصويرة'},
  'gallery': {'fr': 'Choisir dans la galerie', 'en': 'Choose from gallery', 'ar': 'اختيار من المعرض', 'aeb': 'اختار من الصور'},
  'gallerySub': {'fr': 'Une ou plusieurs photos (5 maximum)', 'en': 'One or more photos (5 max)', 'ar': 'صورة أو عدة صور (5 كحد أقصى)', 'aeb': 'تصويرة ولا برشا تصاور (5 على الأكثر)'},
  'recipesCount': {'fr': '{n} recette(s)', 'en': '{n} recipe(s)', 'ar': '{n} وصفة', 'aeb': '{n} وصفة'},
  'clearFilters': {'fr': 'Effacer les filtres', 'en': 'Clear filters', 'ar': 'مسح التصفية', 'aeb': 'امسح الفلاتر'},
  'noRecipesFilter': {'fr': 'Aucune recette pour ces filtres.', 'en': 'No recipes match these filters.', 'ar': 'لا توجد وصفات لهذه التصفية.', 'aeb': 'ما فما حتى وصفة بالفلاتر هاذم.'},
  'noRecipes': {'fr': 'Aucune recette trouvée.', 'en': 'No recipes found.', 'ar': 'لم يتم العثور على وصفات.', 'aeb': 'ما لقينا حتى وصفة.'},
  'loadError': {'fr': 'Impossible de charger les recettes.', 'en': 'Could not load recipes.', 'ar': 'تعذّر تحميل الوصفات.', 'aeb': 'ما نجمناش نحمّلو الوصفات.'},
  'retry': {'fr': 'Réessayer', 'en': 'Retry', 'ar': 'إعادة المحاولة', 'aeb': 'عاود جرّب'},
  'youHave': {'fr': 'Tu as {a}/{b} ingrédients', 'en': 'You have {a}/{b} ingredients', 'ar': 'لديك {a}/{b} من المكوّنات', 'aeb': 'عندك {a}/{b} من المكوّنات'},
  'free': {'fr': 'Gratuit (0 DT)', 'en': 'Free (0 DT)', 'ar': 'مجاني (0 د.ت)', 'aeb': 'بلاش (0 د.ت)'},
  'dt': {'fr': ' DT', 'en': ' DT', 'ar': ' د.ت', 'aeb': ' د.ت'},
  'estCost': {'fr': 'Coût estimé : {c}', 'en': 'Estimated cost: {c}', 'ar': 'التكلفة التقديرية: {c}', 'aeb': 'التكلفة التقريبية: {c}'},
  'ingredientsTitle': {'fr': 'Ingrédients', 'en': 'Ingredients', 'ar': 'المكوّنات', 'aeb': 'المكوّنات'},
  'prepTitle': {'fr': 'Préparation', 'en': 'Preparation', 'ar': 'طريقة التحضير', 'aeb': 'كيفاش تعملها'},
  'toBuy': {'fr': 'À acheter', 'en': 'To buy', 'ar': 'للشراء', 'aeb': 'لازم تشريه'},
  'noSteps': {'fr': 'Étapes non disponibles pour le moment.', 'en': 'Steps not available yet.', 'ar': 'الخطوات غير متوفرة حاليا.', 'aeb': 'الخطوات مازالت موش موجودة.'},
  'noIngList': {'fr': 'Liste non disponible.', 'en': 'List not available.', 'ar': 'القائمة غير متوفرة.', 'aeb': 'القائمة موش موجودة.'},
  'ingNotLoaded': {'fr': 'Les ingrédients ne sont pas encore chargés.', 'en': 'Ingredients are not loaded yet.', 'ar': 'لم يتم تحميل المكوّنات بعد.', 'aeb': 'المكوّنات مازالت ما تحمّلتش.'},
  'fewPhotos': {'fr': 'Seules les 5 premières photos sont analysées.', 'en': 'Only the first 5 photos are analyzed.', 'ar': 'يتم تحليل أول 5 صور فقط.', 'aeb': 'نحلّلو غير أول 5 تصاور.'},
  'openPhotoErr': {'fr': 'Impossible d\'ouvrir la photo : {e}', 'en': 'Could not open the photo: {e}', 'ar': 'تعذّر فتح الصورة: {e}', 'aeb': 'ما نجمناش نحلّو التصويرة: {e}'},
  'analysisErr': {'fr': 'Analyse impossible : {e}', 'en': 'Analysis failed: {e}', 'ar': 'تعذّر التحليل: {e}', 'aeb': 'ما نجمناش نحلّلو: {e}'},
  'noneFound': {'fr': 'Aucun ingrédient reconnu. Tu peux les cocher à la main.', 'en': 'No ingredient recognized. You can tick them manually.', 'ar': 'لم يتم التعرف على أي مكوّن. يمكنك اختيارها يدويا.', 'aeb': 'ما عرفنا حتى مكوّن. تنجم تختارهم بيدك.'},
  'detected': {'fr': '{n} ingrédient(s) détecté(s){x}.', 'en': '{n} ingredient(s) detected{x}.', 'ar': 'تم اكتشاف {n} مكوّن{x}.', 'aeb': 'لقينا {n} مكوّن{x}.'},
  'failedPhotos': {'fr': ' ({n} photo(s) en échec)', 'en': ' ({n} photo(s) failed)', 'ar': ' ({n} صور فشلت)', 'aeb': ' ({n} تصاور فشلو)'},
  'language': {'fr': 'Langue', 'en': 'Language', 'ar': 'اللغة', 'aeb': 'اللغة'},
  'chooseLanguage': {'fr': 'Choisis ta langue', 'en': 'Choose your language', 'ar': 'اختر لغتك', 'aeb': 'اختار لغتك'},
  'meal_petit_dejeuner': {'fr': 'Petit-déjeuner', 'en': 'Breakfast', 'ar': 'الفطور', 'aeb': 'الفطور'},
  'meal_dejeuner': {'fr': 'Déjeuner', 'en': 'Lunch', 'ar': 'الغداء', 'aeb': 'الغدا'},
  'meal_diner': {'fr': 'Dîner', 'en': 'Dinner', 'ar': 'العشاء', 'aeb': 'العشا'},
  'cuisine_Tunisienne': {'fr': 'Tunisienne', 'en': 'Tunisian', 'ar': 'تونسية', 'aeb': 'تونسية'},
  'cuisine_Française': {'fr': 'Française', 'en': 'French', 'ar': 'فرنسية', 'aeb': 'فرنسية'},
  'cuisine_Italienne': {'fr': 'Italienne', 'en': 'Italian', 'ar': 'إيطالية', 'aeb': 'طلياني'},
  'cuisine_Orientale': {'fr': 'Orientale', 'en': 'Oriental', 'ar': 'شرقية', 'aeb': 'شرقية'},
  'cuisine_Méditerranéenne': {'fr': 'Méditerranéenne', 'en': 'Mediterranean', 'ar': 'متوسطية', 'aeb': 'متوسطية'},
};

String t(String key, [Map<String, String> args = const {}]) {
  var s = _ui[key]?[appLang.value] ?? _ui[key]?['fr'] ?? key;
  args.forEach((k, v) {
    s = s.replaceAll('{$k}', v);
  });
  return s;
}

// Lit un champ traduit dans une colonne jsonb "translations" (sinon valeur par défaut)
String trField(dynamic translations, String field, String fallback) {
  if (translations is Map) {
    final byLang = translations[appLang.value];
    if (byLang is Map) {
      final v = byLang[field];
      if (v is String && v.isNotEmpty) return v;
    }
  }
  return fallback;
}

String cuisineLabel(String c) => _ui.containsKey('cuisine_$c') ? t('cuisine_$c') : c;
String mealLabel(String m) => _ui.containsKey('meal_$m') ? t('meal_$m') : m;

Future<void> setLanguage(String code) async {
  appLang.value = code;
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang', code);
  } catch (_) {}
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var askLanguage = true;
  try {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('lang');
    if (saved != null && _langNames.containsKey(saved)) {
      appLang.value = saved;
      askLanguage = false;
    }
  } catch (_) {}
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(CuisinixApp(askLanguage: askLanguage));
}

class CuisinixApp extends StatelessWidget {
  const CuisinixApp({super.key, required this.askLanguage});

  final bool askLanguage;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appLang,
      builder: (context, lang, _) => MaterialApp(
        title: 'Cuisinix',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.deepOrange, useMaterial3: true),
        builder: (context, child) => Directionality(
          textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: child ?? const SizedBox.shrink(),
        ),
        home: RecipesPage(askLanguage: askLanguage),
      ),
    );
  }
}

class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key, this.askLanguage = false});

  final bool askLanguage;

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  late Future<List<Map<String, dynamic>>> _recipes;

  // Filtres (null = tous). On garde les valeurs françaises comme clés.
  String? _meal;
  String? _cuisine;
  double? _maxBudget;

  // Ingrédients que l'utilisateur possède (clés françaises)
  final Set<String> _pantry = {};
  List<String> _known = [];
  final Map<String, dynamic> _ingTr = {}; // nom français -> translations
  bool _scanning = false;

  static const _meals = ['petit_dejeuner', 'dejeuner', 'diner'];
  static const _budgetValues = <double>[0, 5, 10, 20];

  @override
  void initState() {
    super.initState();
    _recipes = _loadRecipes();
    if (widget.askLanguage) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await _chooseLanguage();
        await setLanguage(appLang.value); // mémorise le choix (même si fermé)
      });
    }
  }

  Future<List<Map<String, dynamic>>> _loadRecipes() async {
    final data = await Supabase.instance.client
        .from('recipes')
        .select(
          'id, name, cuisine, meal, prep_minutes, cost_dt, steps, translations, '
          'recipe_ingredients(ingredients(name, translations))',
        )
        .order('name');
    final list = List<Map<String, dynamic>>.from(data);
    final names = <String>{};
    for (final r in list) {
      names.addAll(_ingredientsOf(r));
      final links = r['recipe_ingredients'];
      if (links is List) {
        for (final l in links) {
          if (l is Map && l['ingredients'] is Map) {
            final ing = l['ingredients'] as Map;
            _ingTr['${ing['name']}'] = ing['translations'];
          }
        }
      }
    }
    _known = names.toList()..sort();
    return list;
  }

  void _reload() {
    setState(() {
      _recipes = _loadRecipes();
    });
  }

  void _resetFilters() {
    setState(() {
      _meal = null;
      _cuisine = null;
      _maxBudget = null;
      _pantry.clear();
    });
  }

  List<String> _ingredientsOf(Map<String, dynamic> r) {
    final links = r['recipe_ingredients'];
    if (links is! List) return [];
    return [
      for (final l in links)
        if (l is Map && l['ingredients'] is Map) '${l['ingredients']['name']}',
    ];
  }

  String _ingLabel(String frName) => trField(_ingTr[frName], 'name', frName);

  int _matchOf(Map<String, dynamic> r) =>
      _ingredientsOf(r).where(_pantry.contains).length;

  double _cost(Map<String, dynamic> r) =>
      double.tryParse('${r['cost_dt']}') ?? 0;

  String _formatCost(double c) {
    if (c == 0) return t('free');
    final s = c == c.roundToDouble() ? c.toStringAsFixed(0) : c.toStringAsFixed(2);
    return '$s${t('dt')}';
  }

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> all) {
    final list = all.where((r) {
      if (_meal != null && r['meal'] != _meal) return false;
      if (_cuisine != null && r['cuisine'] != _cuisine) return false;
      if (_maxBudget != null && _cost(r) > _maxBudget!) return false;
      if (_pantry.isNotEmpty && _matchOf(r) == 0) return false;
      return true;
    }).toList();
    if (_pantry.isNotEmpty) {
      list.sort((a, b) {
        final ra = _matchOf(a) / (_ingredientsOf(a).length.clamp(1, 999));
        final rb = _matchOf(b) / (_ingredientsOf(b).length.clamp(1, 999));
        return rb.compareTo(ra);
      });
    }
    return list;
  }

  // ---------- Langue ----------

  Future<void> _chooseLanguage() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                t('chooseLanguage'),
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
            ),
            for (final e in _langNames.entries)
              ListTile(
                title: Text(e.value),
                trailing: appLang.value == e.key ? const Icon(Icons.check) : null,
                onTap: () {
                  setLanguage(e.key);
                  Navigator.pop(ctx);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ---------- Scan par photo ----------

  Future<void> _chooseSource() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: Text(t('takePhoto')),
              onTap: () => Navigator.pop(ctx, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(t('gallery')),
              subtitle: Text(t('gallerySub')),
              onTap: () => Navigator.pop(ctx, 'gallery'),
            ),
          ],
        ),
      ),
    );
    if (choice == null) return;
    try {
      final picker = ImagePicker();
      if (choice == 'camera') {
        final x = await picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1024,
          imageQuality: 70,
        );
        if (x != null) await _scanFiles([x]);
      } else {
        final xs = await picker.pickMultiImage(
          maxWidth: 1024,
          imageQuality: 70,
        );
        if (xs.isEmpty) return;
        if (xs.length > 5) {
          _snack(t('fewPhotos'));
        }
        await _scanFiles(xs.take(5).toList());
      }
    } catch (e) {
      _snack(t('openPhotoErr', {'e': '$e'}));
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  // Analyse une ou plusieurs photos, une par une, et cumule les ingrédients trouvés
  Future<void> _scanFiles(List<XFile> files) async {
    if (_known.isEmpty) {
      _snack(t('ingNotLoaded'));
      return;
    }
    setState(() => _scanning = true);
    final found = <String>{};
    var failures = 0;
    String? lastError;

    for (final x in files) {
      try {
        final bytes = await x.readAsBytes();
        final mime = (x.mimeType != null && x.mimeType!.startsWith('image/'))
            ? x.mimeType!
            : 'image/jpeg';
        final res = await Supabase.instance.client.functions.invoke(
          'quick-responder', // nom attribué par Supabase à la fonction de détection
          body: {
            'image_base64': base64Encode(bytes),
            'media_type': mime,
            'known': _known,
          },
        );
        final data = res.data;
        if (data is Map && data['ingredients'] is List) {
          found.addAll(List<String>.from(data['ingredients'] as List));
        }
      } catch (e) {
        failures++;
        lastError = '$e';
      }
    }

    if (!mounted) return;
    setState(() {
      _scanning = false;
      _pantry.addAll(found);
    });

    if (failures == files.length) {
      _snack(t('analysisErr', {'e': '$lastError'}));
      return;
    }
    if (found.isEmpty) {
      _snack(t('noneFound'));
    } else {
      final extra = failures > 0 ? t('failedPhotos', {'n': '$failures'}) : '';
      _snack(t('detected', {'n': '${found.length}', 'x': extra}));
    }
    await _editPantry();
  }

  Future<void> _editPantry() async {
    var addMore = false;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t('myIngredients'),
                    style: Theme.of(ctx).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(t('fixList')),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final n in _known)
                      FilterChip(
                        label: Text(_ingLabel(n)),
                        selected: _pantry.contains(n),
                        onSelected: (s) {
                          setSheet(() {});
                          setState(() {
                            if (s) {
                              _pantry.add(n);
                            } else {
                              _pantry.remove(n);
                            }
                          });
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        setSheet(() {});
                        setState(_pantry.clear);
                      },
                      child: Text(t('clearAll')),
                    ),
                    const Spacer(),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.add_a_photo_outlined),
                      onPressed: () {
                        addMore = true;
                        Navigator.pop(ctx);
                      },
                      label: Text(t('addPhoto')),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(t('viewRecipes')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (addMore) await _chooseSource();
  }

  void _openDetail(Map<String, dynamic> r) {
    final tr = r['translations'];
    final stepsText = trField(tr, 'steps', '${r['steps'] ?? ''}');
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RecipeDetailPage(
          name: trField(tr, 'name', '${r['name']}'),
          subtitle:
              '${cuisineLabel('${r['cuisine']}')} · ${mealLabel('${r['meal']}')} · ${r['prep_minutes']} min',
          cost: _formatCost(_cost(r)),
          ingredients: _ingredientsOf(r),
          ingLabel: _ingLabel,
          pantry: Set<String>.of(_pantry),
          steps: stepsText
              .split('\n')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
        ),
      ),
    );
  }

  // ---------- Interface ----------

  Widget _chipRow(List<Widget> chips) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          for (final c in chips)
            Padding(padding: const EdgeInsetsDirectional.only(end: 8), child: c),
        ],
      ),
    );
  }

  Widget _buildFilters(List<Map<String, dynamic>> all) {
    final cuisines = all.map((r) => '${r['cuisine']}').toSet().toList()..sort();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _chipRow([
          for (final m in _meals)
            FilterChip(
              label: Text(mealLabel(m)),
              selected: _meal == m,
              onSelected: (s) => setState(() => _meal = s ? m : null),
            ),
        ]),
        const SizedBox(height: 4),
        _chipRow([
          for (final c in cuisines)
            FilterChip(
              label: Text(cuisineLabel(c)),
              selected: _cuisine == c,
              onSelected: (s) => setState(() => _cuisine = s ? c : null),
            ),
        ]),
        const SizedBox(height: 4),
        _chipRow([
          for (final v in _budgetValues)
            FilterChip(
              avatar: const Icon(Icons.payments_outlined, size: 18),
              label: Text(v == 0
                  ? '0${t('dt')}'
                  : '≤ ${v.toStringAsFixed(0)}${t('dt')}'),
              selected: _maxBudget == v,
              onSelected: (s) => setState(() => _maxBudget = s ? v : null),
            ),
        ]),
        const SizedBox(height: 4),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t('appTitle')),
        actions: [
          IconButton(
            tooltip: t('language'),
            icon: const Icon(Icons.translate),
            onPressed: _chooseLanguage,
          ),
          IconButton(
            tooltip: t('myIngredients'),
            icon: Badge(
              isLabelVisible: _pantry.isNotEmpty,
              label: Text('${_pantry.length}'),
              child: const Icon(Icons.kitchen_outlined),
            ),
            onPressed: _known.isEmpty ? null : _editPantry,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _scanning ? null : _chooseSource,
        icon: _scanning
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.photo_camera),
        label: Text(_scanning ? t('analyzing') : t('scanBtn')),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _recipes,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(t('loadError')),
                    const SizedBox(height: 8),
                    Text('${snapshot.error}', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(onPressed: _reload, child: Text(t('retry'))),
                  ],
                ),
              ),
            );
          }
          final all = snapshot.data ?? [];
          if (all.isEmpty) {
            return Center(child: Text(t('noRecipes')));
          }
          final recipes = _applyFilters(all);
          final hasFilter = _meal != null ||
              _cuisine != null ||
              _maxBudget != null ||
              _pantry.isNotEmpty;

          return Column(
            children: [
              _buildFilters(all),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Text(t('recipesCount', {'n': '${recipes.length}'})),
                    const Spacer(),
                    if (hasFilter)
                      TextButton(
                        onPressed: _resetFilters,
                        child: Text(t('clearFilters')),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: recipes.isEmpty
                    ? Center(child: Text(t('noRecipesFilter')))
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 88),
                        itemCount: recipes.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final r = recipes[index];
                          final total = _ingredientsOf(r).length;
                          final lines = [
                            '${cuisineLabel('${r['cuisine']}')} · ${mealLabel('${r['meal']}')} · ${r['prep_minutes']} min',
                            if (_pantry.isNotEmpty)
                              t('youHave', {'a': '${_matchOf(r)}', 'b': '$total'}),
                          ];
                          return ListTile(
                            onTap: () => _openDetail(r),
                            isThreeLine: _pantry.isNotEmpty,
                            title: Text(trField(r['translations'], 'name', '${r['name']}')),
                            subtitle: Text(lines.join('\n')),
                            trailing: Text(
                              _formatCost(_cost(r)),
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class RecipeDetailPage extends StatelessWidget {
  const RecipeDetailPage({
    super.key,
    required this.name,
    required this.subtitle,
    required this.cost,
    required this.ingredients,
    required this.ingLabel,
    required this.pantry,
    required this.steps,
  });

  final String name;
  final String subtitle;
  final String cost;
  final List<String> ingredients;
  final String Function(String) ingLabel;
  final Set<String> pantry;
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final have = ingredients.where(pantry.contains).toList();
    final missing = ingredients.where((i) => !pantry.contains(i)).toList();

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(subtitle, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 4),
          Text(t('estCost', {'c': cost}),
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          Text(t('ingredientsTitle'), style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          if (pantry.isNotEmpty)
            Text(t('youHave', {'a': '${have.length}', 'b': '${ingredients.length}'})),
          const SizedBox(height: 8),
          if (ingredients.isEmpty) Text(t('noIngList')),
          for (final i in have)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: Text(ingLabel(i)),
            ),
          for (final i in missing)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                pantry.isEmpty ? Icons.circle_outlined : Icons.shopping_basket_outlined,
                color: pantry.isEmpty ? null : Colors.deepOrange,
              ),
              title: Text(ingLabel(i)),
              subtitle: pantry.isEmpty ? null : Text(t('toBuy')),
            ),
          const SizedBox(height: 20),
          Text(t('prepTitle'), style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (steps.isEmpty) Text(t('noSteps')),
          for (var n = 0; n < steps.length; n++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(radius: 14, child: Text('${n + 1}')),
                  const SizedBox(width: 12),
                  Expanded(child: Text(steps[n])),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
