import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
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
  'limitDevice': {'fr': 'Limite de {n} photos par jour atteinte. Reviens demain ou choisis tes ingrédients à la main.', 'en': 'Daily limit of {n} photos reached. Come back tomorrow or pick your ingredients by hand.', 'ar': 'تم بلوغ الحد اليومي ({n} صور). عد غدًا أو اختر مكوّناتك يدويًا.', 'aeb': 'وصلت للحد اليومي ({n} تصاور). ارجع غدوة وإلا اختار المكوّنات بيدك.'},
  'limitGlobal': {'fr': 'Le scan est très sollicité aujourd\'hui. Réessaie plus tard ou choisis tes ingrédients à la main.', 'en': 'Scanning is very busy today. Try again later or pick your ingredients by hand.', 'ar': 'خدمة المسح عليها ضغط كبير اليوم. أعد المحاولة لاحقًا أو اختر مكوّناتك يدويًا.', 'aeb': 'السكان عليه برشا ضغط اليوم. عاود بعد شوية وإلا اختار المكوّنات بيدك.'},
  'noneFound': {'fr': 'Aucun ingrédient reconnu. Tu peux les cocher à la main.', 'en': 'No ingredient recognized. You can tick them manually.', 'ar': 'لم يتم التعرف على أي مكوّن. يمكنك اختيارها يدويا.', 'aeb': 'ما عرفنا حتى مكوّن. تنجم تختارهم بيدك.'},
  'detected': {'fr': '{n} ingrédient(s) détecté(s){x}.', 'en': '{n} ingredient(s) detected{x}.', 'ar': 'تم اكتشاف {n} مكوّن{x}.', 'aeb': 'لقينا {n} مكوّن{x}.'},
  'failedPhotos': {'fr': ' ({n} photo(s) en échec)', 'en': ' ({n} photo(s) failed)', 'ar': ' ({n} صور فشلت)', 'aeb': ' ({n} تصاور فشلو)'},
  'language': {'fr': 'Langue', 'en': 'Language', 'ar': 'اللغة', 'aeb': 'اللغة'},
  'chooseLanguage': {'fr': 'Choisis ta langue', 'en': 'Choose your language', 'ar': 'اختر لغتك', 'aeb': 'اختار لغتك'},
  'qtyTitle': {'fr': 'Quantité de {n} que tu as', 'en': 'How much {n} do you have?', 'ar': 'الكمية التي لديك من {n}', 'aeb': 'قدّاش عندك من {n}'},
  'qtyHint': {'fr': 'Quantité', 'en': 'Amount', 'ar': 'الكمية', 'aeb': 'الكمية'},
  'ok': {'fr': 'Valider', 'en': 'Confirm', 'ar': 'تأكيد', 'aeb': 'أكّد'},
  'cancel': {'fr': 'Annuler', 'en': 'Cancel', 'ar': 'إلغاء', 'aeb': 'إلغاء'},
  'remove': {'fr': 'Retirer', 'en': 'Remove', 'ar': 'إزالة', 'aeb': 'احذف'},
  'dontKnow': {'fr': 'Je ne sais pas', 'en': "I don't know", 'ar': 'لا أعرف', 'aeb': 'ما نعرفش'},
  'youHaveQty': {'fr': 'Tu as {q}', 'en': 'You have {q}', 'ar': 'لديك {q}', 'aeb': 'عندك {q}'},
  'missingQty': {'fr': 'Il manque {q}', 'en': 'Missing {q}', 'ar': 'ينقصك {q}', 'aeb': 'ينقصك {q}'},
  'qtyUnknown': {'fr': 'quantité non précisée (on suppose que tu en as assez)', 'en': 'amount not set (assuming you have enough)', 'ar': 'الكمية غير محددة (نفترض أنها كافية)', 'aeb': 'الكمية موش محدّدة (نفترضو كافية)'},
  'photoCredit': {'fr': 'Photos : Wikipédia / Wikimedia Commons', 'en': 'Photos: Wikipedia / Wikimedia Commons', 'ar': 'الصور: ويكيبيديا / ويكيميديا كومنز', 'aeb': 'الصور: ويكيبيديا / ويكيميديا كومنز'},
  'packHint': {'fr': 'ex. {n} × {p} · {c}', 'en': 'e.g. {n} × {p} · {c}', 'ar': 'مثال: {n} × {p} · {c}', 'aeb': 'مثلا: {n} × {p} · {c}'},
  'withProducts': {'fr': ', dont {p} produit(s) reconnu(s) à l\'emballage', 'en': ', including {p} packaged product(s) recognized', 'ar': '، منها {p} منتج معبّأ تم التعرف عليه', 'aeb': '، منهم {p} منتوج تعرفنا عليه من الغلاف'},
  'buyPacks': {'fr': 'À acheter (emballages entiers) : {c}', 'en': 'To buy (whole packs): {c}', 'ar': 'للشراء (عبوات كاملة): {c}', 'aeb': 'لازم تشري (عبوات كاملة): {c}'},
  'usedCost': {'fr': 'Coût des quantités utilisées : {c}', 'en': 'Cost of the amounts used: {c}', 'ar': 'تكلفة الكميات المستعملة: {c}', 'aeb': 'كلفة الكميات المستعملة: {c}'},
  'packBuy': {'fr': 'Acheter {n} × {p} · reste {r}', 'en': 'Buy {n} × {p} · {r} left over', 'ar': 'اشتر {n} × {p} · يبقى {r}', 'aeb': 'اشري {n} × {p} · يبقى {r}'},
  'usedPortion': {'fr': 'portion utilisée : {c}', 'en': 'portion used: {c}', 'ar': 'الجزء المستعمل: {c}', 'aeb': 'الجزء المستعمل: {c}'},
  'people': {'fr': 'Personnes', 'en': 'People', 'ar': 'عدد الأشخاص', 'aeb': 'عدد الناس'},
  'totalCost': {'fr': 'Coût total : {c}', 'en': 'Total cost: {c}', 'ar': 'التكلفة الإجمالية: {c}', 'aeb': 'الكلفة الجملية: {c}'},
  'toBuyCost': {'fr': 'À acheter : {c}', 'en': 'To buy: {c}', 'ar': 'للشراء: {c}', 'aeb': 'لازم تشري بـ: {c}'},
  'priceNote': {'fr': 'Prix indicatifs du marché tunisien, mis à jour le {d}', 'en': 'Indicative Tunisian market prices, updated {d}', 'ar': 'أسعار إرشادية للسوق التونسية، آخر تحديث {d}', 'aeb': 'أسعار تقريبية في السوق التونسية، تبدّلت في {d}'},
  'perPerson': {'fr': '{c} / pers.', 'en': '{c} / person', 'ar': '{c} / للفرد', 'aeb': '{c} / للواحد'},
  'u_g': {'fr': 'g', 'en': 'g', 'ar': 'غ', 'aeb': 'غ'},
  'u_kg': {'fr': 'kg', 'en': 'kg', 'ar': 'كغ', 'aeb': 'كيلو'},
  'u_ml': {'fr': 'ml', 'en': 'ml', 'ar': 'مل', 'aeb': 'مل'},
  'u_l': {'fr': 'L', 'en': 'L', 'ar': 'ل', 'aeb': 'لتر'},
  'u_piece': {'fr': 'pièce(s)', 'en': 'pc', 'ar': 'حبة', 'aeb': 'حبّة'},
  'u_box': {'fr': 'boîte', 'en': 'can', 'ar': 'علبة', 'aeb': 'علبة'},
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

// Une ligne d'ingrédient d'une recette : quantité par personne et prix
class IngLine {
  IngLine(this.name, this.qty, this.unit, this.price, this.date, this.loose);

  final String name; // nom français (clé)
  final double qty; // par personne : g, ml, pièces ou boîtes
  final String unit; // kg, l, piece, box (unité du prix)
  final double price; // DT par unité
  final String? date; // date de mise à jour du prix (AAAA-MM-JJ)
  final bool loose; // vendu à la portion (sinon : emballage entier obligatoire)

  double costFor(int people) => (unit == 'kg' || unit == 'l')
      ? qty / 1000 * price * people
      : qty * price * people;

  // Quantité manquante pour N personnes quand l'utilisateur en a `have`
  double missingFor(int people, double have) {
    final need = qty * people;
    final m = need - have;
    return m <= 0 ? 0 : (m > need ? need : m);
  }

  // Prix de ce qu'il reste à acheter
  double buyCost(int people, double have) {
    final need = qty * people;
    if (need <= 0) return 0;
    return costFor(people) * missingFor(people, have) / need;
  }
}

// Achat réel d'un ingrédient manquant : emballages entiers si le produit ne se vend pas à la portion
class Purchase {
  Purchase(this.cost, {this.pack, this.count = 0, this.leftover = 0});

  final double cost; // DT à payer
  final PackInfo? pack; // emballage choisi (si achat par emballage)
  final int count; // nombre d'emballages
  final double leftover; // quantité qui reste après la recette
}

Purchase purchaseFor(IngLine l, int people, double have, List<PackInfo>? packs) {
  final miss = l.missingFor(people, have);
  if (miss <= 0) return Purchase(0);
  if (l.loose || packs == null || packs.isEmpty) {
    return Purchase(l.buyCost(people, have));
  }
  PackInfo? best;
  var bestN = 0;
  var bestCost = double.infinity;
  var bestLeft = 0.0;
  for (final pk in packs) {
    if (pk.qty <= 0) continue;
    final n = (miss / pk.qty).ceil();
    final c = n * pk.price;
    final left = n * pk.qty - miss;
    if (c < bestCost - 1e-9 || ((c - bestCost).abs() < 1e-9 && left < bestLeft)) {
      best = pk;
      bestN = n;
      bestCost = c;
      bestLeft = left;
    }
  }
  if (best == null) return Purchase(l.buyCost(people, have));
  return Purchase(bestCost, pack: best, count: bestN, leftover: bestLeft);
}

// Un produit emballé d'une marque, avec sa taille et son prix
class PackInfo {
  PackInfo(this.label, this.qty, this.price, this.estimated);

  final String label; // marque + nom
  final double qty; // dans l'unité de base de l'ingrédient
  final double price; // DT
  final bool estimated; // prix estimé (non trouvé en ligne)
}

String _fmtNum(double v) {
  final r = (v * 10).round() / 10;
  return r == r.roundToDouble() ? r.toStringAsFixed(0) : r.toStringAsFixed(1);
}

String formatDt(double c) {
  if (c < 0.005) return t('free');
  return '${c.toStringAsFixed(2)}${t('dt')}';
}

String formatBase(double q, String unit) {
  switch (unit) {
    case 'kg':
      return q >= 1000
          ? '${_fmtNum(q / 1000)} ${t('u_kg')}'
          : '${q < 10 ? _fmtNum(q) : q.round()} ${t('u_g')}';
    case 'l':
      return q >= 1000
          ? '${_fmtNum(q / 1000)} ${t('u_l')}'
          : '${q < 10 ? _fmtNum(q) : q.round()} ${t('u_ml')}';
    case 'box':
      return '${_fmtNum(q)} ${t('u_box')}';
    default:
      return '${_fmtNum(q)} ${t('u_piece')}';
  }
}

String formatQty(IngLine l, int people) => formatBase(l.qty * people, l.unit);

String formatDate(String? iso) {
  if (iso == null || iso.length < 10) return '';
  return '${iso.substring(8, 10)}/${iso.substring(5, 7)}/${iso.substring(0, 4)}';
}

Future<void> setLanguage(String code) async {
  appLang.value = code;
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang', code);
  } catch (_) {}
}

const appVersion = '0.2.0';

// Identifiant anonyme de l'appareil (aucune donnée personnelle) : sert à compter
// les utilisateurs et à limiter le nombre de scans par jour.
String deviceId = '';

Future<String> _loadOrCreateDeviceId() async {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  try {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('device_id');
    if (saved != null && RegExp(r'^[A-Za-z0-9_-]{16,64}$').hasMatch(saved)) {
      return saved;
    }
    final rnd = Random.secure();
    final id = List.generate(32, (_) => chars[rnd.nextInt(chars.length)]).join();
    await prefs.setString('device_id', id);
    return id;
  } catch (_) {
    return '';
  }
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
  deviceId = await _loadOrCreateDeviceId();
  if (deviceId.isNotEmpty) {
    // Enregistrement anonyme de l'appareil, sans bloquer le démarrage
    Supabase.instance.client
        .rpc('register_device', params: {'p_device': deviceId, 'p_version': appVersion})
        .then((_) {}, onError: (_) {});
  }
  runApp(CuisinixApp(askLanguage: askLanguage));
}

// ---------------------------------------------------------------------------
// Style : couleurs, polices, thème
// ---------------------------------------------------------------------------
const Color kPrimary = Color(0xFFE8590C); // orange chaud
const Color kPrimaryDark = Color(0xFFC2410C);
const Color kGreen = Color(0xFF2F9E44); // vert frais
const Color kCream = Color(0xFFFFF7ED); // fond crème
const Color kInk = Color(0xFF2B2118); // texte
const Color kMuted = Color(0xFF8A7B6D); // texte secondaire
const Color kBorder = Color(0xFFEFE0CF);

String mealEmoji(String m) {
  switch (m) {
    case 'petit_dejeuner':
      return '🥐';
    case 'dejeuner':
      return '🍲';
    case 'diner':
      return '🍽️';
    default:
      return '🍴';
  }
}

Color mealTint(String m) {
  switch (m) {
    case 'petit_dejeuner':
      return const Color(0xFFFFE8B8);
    case 'dejeuner':
      return const Color(0xFFFFD9C7);
    case 'diner':
      return const Color(0xFFE3DBFF);
    default:
      return const Color(0xFFEFE0CF);
  }
}

ThemeData buildTheme(bool rtl) {
  final scheme = ColorScheme.fromSeed(seedColor: kPrimary).copyWith(
    primary: kPrimary,
    secondary: kGreen,
    surface: Colors.white,
  );
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: kCream,
  );
  final textTheme = (rtl
          ? GoogleFonts.cairoTextTheme(base.textTheme)
          : GoogleFonts.poppinsTextTheme(base.textTheme))
      .apply(bodyColor: kInk, displayColor: kInk);
  return base.copyWith(
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: kCream,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge
          ?.copyWith(fontWeight: FontWeight.w800, color: kInk),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFFFFE3D1),
      side: const BorderSide(color: kBorder),
      shape: const StadiumBorder(),
      checkmarkColor: kPrimary,
      labelStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: kPrimary,
      foregroundColor: Colors.white,
      extendedTextStyle:
          textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kPrimaryDark,
        side: const BorderSide(color: kPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: kPrimaryDark),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: kPrimary),
  );
}

const String _userAgent =
    'Cuisinix/1.0 (https://github.com/aminechiha1989-dot/mobile-app-CUISINIX)';

final Map<String, Future<String?>> _imageCache = {};

// Cherche sur Wikipédia la photo d'un plat à partir d'un mot-clé (gratuit)
Future<String?> _findImage(String query) async {
  try {
    final uri = Uri.https('en.wikipedia.org', '/w/api.php', {
      'action': 'query',
      'format': 'json',
      'generator': 'search',
      'gsrsearch': query,
      'gsrnamespace': '0',
      'gsrlimit': '5',
      'prop': 'pageimages',
      'piprop': 'thumbnail',
      'pithumbsize': '640',
    });
    final res = await http
        .get(uri, headers: {'User-Agent': _userAgent})
        .timeout(const Duration(seconds: 12));
    if (res.statusCode != 200) return null;
    final data = jsonDecode(res.body);
    final pages = data['query']?['pages'];
    if (pages is! Map) return null;
    final list = pages.values.whereType<Map>().toList()
      ..sort((a, b) =>
          ((a['index'] ?? 99) as num).compareTo((b['index'] ?? 99) as num));
    for (final pg in list) {
      final src = pg['thumbnail']?['source'];
      if (src is String && src.isNotEmpty) return src;
    }
  } catch (_) {}
  return null;
}

// Photo d'un plat (adresse enregistrée, sinon recherche Wikipédia, sinon emoji)
class DishImage extends StatelessWidget {
  const DishImage({
    super.key,
    required this.meal,
    this.url,
    this.query,
    this.size,
    this.radius = 18,
    this.emojiSize = 32,
    this.showFallback = true,
  });

  final String meal;
  final String? url;
  final String? query;
  final double? size;
  final double radius;
  final double emojiSize;
  final bool showFallback;

  Widget _fallback() => !showFallback
      ? const SizedBox.shrink()
      : Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: mealTint(meal),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Text(mealEmoji(meal), style: TextStyle(fontSize: emojiSize)),
      );

  Widget _photo(String src) => ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.network(
          src,
          width: size,
          height: size,
          fit: BoxFit.cover,
          headers: const {'User-Agent': _userAgent},
          errorBuilder: (_, __, ___) => _fallback(),
          loadingBuilder: (c, child, p) => p == null ? child : _fallback(),
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (url != null && url!.isNotEmpty) return _photo(url!);
    final q = query;
    if (q == null || q.isEmpty) return _fallback();
    return FutureBuilder<String?>(
      future: _imageCache.putIfAbsent(q, () => _findImage(q)),
      builder: (context, snap) {
        final src = snap.data;
        return src == null ? _fallback() : _photo(src);
      },
    );
  }
}

class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.text,
    this.icon,
    this.background = const Color(0xFFF6EBDD),
    this.foreground = kInk,
  });

  final String text;
  final IconData? icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
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
        theme: buildTheme(_isRtl),
        builder: (context, child) {
          final mq = MediaQuery.of(context);
          return MediaQuery(
            // Texte agrandi de 15 % par rapport au réglage du téléphone
            data: mq.copyWith(
              textScaler: TextScaler.linear(mq.textScaler.scale(1.0) * 1.15),
            ),
            child: Directionality(
              textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
              child: child ?? const SizedBox.shrink(),
            ),
          );
        },
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
  // nom français -> quantité possédée (g, ml, pièces ou boîtes) ; null = non précisée
  final Map<String, double?> _pantry = {};
  final Map<String, String> _ingUnit = {}; // nom français -> kg, l, piece, box
  List<String> _known = [];
  final Map<String, dynamic> _ingTr = {}; // nom français -> translations
  bool _scanning = false;
  int _people = 2; // nombre de personnes
  List<Map<String, dynamic>> _products = []; // produits emballés connus
  Map<String, List<PackInfo>> _packs = {};

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
          'id, name, cuisine, meal, prep_minutes, cost_dt, steps, translations, image_query, image_url, '
          'recipe_ingredients(qty_per_person, ingredients(name, translations, price_dt, price_unit, price_updated, sold_loose))',
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
            _ingUnit['${ing['name']}'] = '${ing['price_unit'] ?? 'kg'}';
          }
        }
      }
    }
    _known = names.toList()..sort();
    try {
      final pr = await Supabase.instance.client
          .from('products')
          .select('id, brand, name, pack_qty, price_dt, price_source, ingredients(name)')
          .order('brand');
      _products = List<Map<String, dynamic>>.from(pr);
    } catch (_) {
      _products = [];
    }
    _packs = _packsByIngredient();
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
      _ingredientsOf(r).where(_pantry.containsKey).length;

  List<IngLine> _linesOf(Map<String, dynamic> r) {
    final links = r['recipe_ingredients'];
    if (links is! List) return [];
    final out = <IngLine>[];
    for (final l in links) {
      if (l is Map && l['ingredients'] is Map) {
        final ing = l['ingredients'] as Map;
        out.add(IngLine(
          '${ing['name']}',
          double.tryParse('${l['qty_per_person']}') ?? 0,
          '${ing['price_unit'] ?? 'kg'}',
          double.tryParse('${ing['price_dt']}') ?? 0,
          ing['price_updated']?.toString(),
          ing['sold_loose'] != false,
        ));
      }
    }
    return out;
  }

  // Montant à dépenser : ingrédients que l'utilisateur n'a pas, pour N personnes
  double _haveOf(String n) =>
      _pantry.containsKey(n) ? (_pantry[n] ?? double.infinity) : 0;

  double _cost(Map<String, dynamic> r) => _linesOf(r).fold<double>(
      0,
      (a, l) =>
          a + purchaseFor(l, _people, _haveOf(l.name), _packs[l.name]).cost);

  String _formatCost(double c) => formatDt(c);

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
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                t('chooseLanguage'),
                style: Theme.of(ctx)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            for (final e in _langNames.entries)
              ListTile(
                leading: Icon(
                  Icons.translate,
                  color: appLang.value == e.key ? kPrimary : kMuted,
                ),
                title: Text(
                  e.value,
                  style: TextStyle(
                    fontWeight: appLang.value == e.key
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
                trailing: appLang.value == e.key
                    ? const Icon(Icons.check_circle, color: kPrimary)
                    : null,
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

  Widget _sourceTile(
    BuildContext ctx, {
    required IconData icon,
    required String title,
    String? subtitle,
    required String value,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: const Color(0xFFFFE3D1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: kPrimary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: subtitle == null ? null : Text(subtitle),
      onTap: () => Navigator.pop(ctx, value),
    );
  }

  Future<void> _chooseSource() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sourceTile(ctx,
                icon: Icons.photo_camera_rounded,
                title: t('takePhoto'),
                value: 'camera'),
            _sourceTile(ctx,
                icon: Icons.photo_library_rounded,
                title: t('gallery'),
                subtitle: t('gallerySub'),
                value: 'gallery'),
            const SizedBox(height: 8),
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
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          behavior: SnackBarBehavior.floating,
          backgroundColor: kInk,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
  }

  // Analyse une ou plusieurs photos, une par une, et cumule les ingrédients trouvés
  Future<void> _scanFiles(List<XFile> files) async {
    if (_known.isEmpty) {
      _snack(t('ingNotLoaded'));
      return;
    }
    setState(() => _scanning = true);
    final found = <String>{};
    final foundPacks = <int, int>{}; // id produit -> nombre d'exemplaires
    var failures = 0;
    String? lastError;
    String limitMsg = '';

    for (final x in files) {
      try {
        final bytes = await x.readAsBytes();
        final mime = (x.mimeType != null && x.mimeType!.startsWith('image/'))
            ? x.mimeType!
            : 'image/jpeg';
        final res = await Supabase.instance.client.functions.invoke(
          'quick-responder', // nom attribué par Supabase à la fonction de détection
          body: {
            'device_id': deviceId,
            'image_base64': base64Encode(bytes),
            'media_type': mime,
            'known': _known,
            'products': [
              for (final p in _products)
                {'id': p['id'], 'label': '${p['brand']} ${p['name']}'},
            ],
          },
        );
        final data = res.data;
        if (data is Map && data['ingredients'] is List) {
          found.addAll(List<String>.from(data['ingredients'] as List));
        }
        if (data is Map && data['products'] is List) {
          for (final item in data['products'] as List) {
            if (item is Map) {
              final id = (item['id'] as num).toInt();
              final c = ((item['count'] ?? 1) as num).toInt();
              foundPacks[id] = (foundPacks[id] ?? 0) + c;
            }
          }
        }
      } on FunctionException catch (e) {
        if (e.status == 429) {
          // Limite quotidienne (par appareil ou globale) atteinte : on arrête là
          final d = e.details;
          final code = d is Map ? '${d['code']}' : 'device_limit';
          final limit = d is Map && d['limit'] != null ? '${d['limit']}' : '10';
          limitMsg = code == 'global_limit'
              ? t('limitGlobal')
              : t('limitDevice', {'n': limit});
          break;
        }
        failures++;
        lastError = '$e';
      } catch (e) {
        failures++;
        lastError = '$e';
      }
    }

    if (!mounted) return;
    final detectedNames = <String>{...found};
    setState(() {
      _scanning = false;
      for (final n in found) {
        _pantry.putIfAbsent(n, () => null);
      }
      // Un produit reconnu apporte sa quantité d'emballage (ex. beurre 200 g)
      for (final e in foundPacks.entries) {
        for (final pr in _products) {
          if (pr['id'] == e.key && pr['ingredients'] is Map) {
            final ing = '${(pr['ingredients'] as Map)['name']}';
            detectedNames.add(ing);
            final qty = (double.tryParse('${pr['pack_qty']}') ?? 0) * e.value;
            _pantry[ing] = (_pantry[ing] ?? 0) + qty;
          }
        }
      }
    });

    if (limitMsg.isNotEmpty && found.isEmpty && foundPacks.isEmpty) {
      _snack(limitMsg);
      return;
    }
    if (failures == files.length) {
      _snack(t('analysisErr', {'e': '$lastError'}));
      return;
    }
    if (found.isEmpty && foundPacks.isEmpty) {
      _snack(t('noneFound'));
    } else {
      final packs = foundPacks.values.fold<int>(0, (a, b) => a + b);
      final extra = (packs > 0 ? t('withProducts', {'p': '$packs'}) : '') +
          (failures > 0 ? t('failedPhotos', {'n': '$failures'}) : '') +
          (limitMsg.isNotEmpty ? '\n$limitMsg' : '');
      _snack(t('detected', {'n': '${detectedNames.length}', 'x': extra}));
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
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.85,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t('myIngredients'),
                    style: Theme.of(ctx)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(t('fixList'), style: const TextStyle(color: kMuted)),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      for (final n in _known)
                        FilterChip(
                          label: Text(_chipLabel(n)),
                          selected: _pantry.containsKey(n),
                          onSelected: (_) async {
                            await _editQty(n);
                            setSheet(() {});
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    runSpacing: 4,
                    children: [
                      TextButton(
                        onPressed: () {
                          setSheet(() {});
                          setState(_pantry.clear);
                        },
                        child: Text(t('clearAll')),
                      ),
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
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(t('viewRecipes')),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (addMore) await _chooseSource();
  }

  String _chipLabel(String n) {
    final base = _ingLabel(n);
    if (!_pantry.containsKey(n)) return base;
    final q = _pantry[n];
    return q == null ? '$base · ?' : '$base · ${formatBase(q, _ingUnit[n] ?? 'kg')}';
  }

  // Demande la quantité possédée d'un ingrédient (ajout, modification ou retrait)
  Future<void> _editQty(String n) async {
    final unit = _ingUnit[n] ?? 'kg';
    final weighted = unit == 'kg' || unit == 'l';
    final cur = _pantry[n];
    var big = weighted && cur != null && cur >= 1000;
    final shownCur = cur == null ? null : (big ? cur / 1000 : cur);
    final controller = TextEditingController(
      text: shownCur == null ? '' : _fmtNum(shownCur),
    );
    final smallLabel = unit == 'l' ? t('u_ml') : t('u_g');
    final bigLabel = unit == 'l' ? t('u_l') : t('u_kg');
    final unitLabel = unit == 'box'
        ? t('u_box')
        : (unit == 'piece' ? t('u_piece') : '');
    final exists = _pantry.containsKey(n);

    final action = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(t('qtyTitle', {'n': _ingLabel(n)}),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: t('qtyHint'),
                  suffixText: unitLabel.isEmpty ? null : unitLabel,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
              if (weighted) ...[
                const SizedBox(height: 12),
                SegmentedButton<bool>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(value: false, label: Text(smallLabel)),
                    ButtonSegment(value: true, label: Text(bigLabel)),
                  ],
                  selected: {big},
                  onSelectionChanged: (v) => setD(() => big = v.first),
                ),
              ],
            ],
          ),
          actions: [
            if (exists)
              TextButton(
                onPressed: () => Navigator.pop(ctx, 'remove'),
                child: Text(t('remove')),
              ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'unknown'),
              child: Text(t('dontKnow')),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(t('cancel')),
            ),
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(80, 42)),
              onPressed: () => Navigator.pop(ctx, 'ok'),
              child: Text(t('ok')),
            ),
          ],
        ),
      ),
    );
    if (action == null) return;
    setState(() {
      if (action == 'remove') {
        _pantry.remove(n);
      } else if (action == 'unknown') {
        _pantry[n] = null;
      } else {
        final v = double.tryParse(controller.text.trim().replaceAll(',', '.'));
        if (v == null || v < 0) return;
        _pantry[n] = (weighted && big) ? v * 1000 : v;
      }
    });
  }

  Map<String, List<PackInfo>> _packsByIngredient() {
    final out = <String, List<PackInfo>>{};
    for (final p in _products) {
      if (p['ingredients'] is! Map) continue;
      final ing = '${(p['ingredients'] as Map)['name']}';
      out.putIfAbsent(ing, () => []).add(PackInfo(
        '${p['brand']} ${p['name']}',
        double.tryParse('${p['pack_qty']}') ?? 0,
        double.tryParse('${p['price_dt']}') ?? 0,
        '${p['price_source']}'.startsWith('estimation'),
      ));
    }
    return out;
  }

  void _openDetail(Map<String, dynamic> r) {
    final tr = r['translations'];
    final stepsText = trField(tr, 'steps', '${r['steps'] ?? ''}');
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RecipeDetailPage(
          name: trField(tr, 'name', '${r['name']}'),
          meal: '${r['meal']}',
          imageUrl: r['image_url'] as String?,
          imageQuery: r['image_query'] as String?,
          pills: [
            cuisineLabel('${r['cuisine']}'),
            mealLabel('${r['meal']}'),
            '${r['prep_minutes']} min',
          ],
          lines: _linesOf(r),
          packs: _packsByIngredient(),
          ingLabel: _ingLabel,
          pantry: Map<String, double?>.of(_pantry),
          people: _people,
          onPeople: (n) => setState(() => _people = n),
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
        const SizedBox(height: 4),
        _chipRow([
          for (final m in _meals)
            FilterChip(
              avatar: Text(mealEmoji(m)),
              label: Text(mealLabel(m)),
              selected: _meal == m,
              showCheckmark: false,
              onSelected: (s) => setState(() => _meal = s ? m : null),
            ),
        ]),
        const SizedBox(height: 2),
        _chipRow([
          for (final c in cuisines)
            FilterChip(
              label: Text(cuisineLabel(c)),
              selected: _cuisine == c,
              onSelected: (s) => setState(() => _cuisine = s ? c : null),
            ),
        ]),
        const SizedBox(height: 2),
        _chipRow([
          for (final v in _budgetValues)
            FilterChip(
              avatar: const Icon(Icons.payments_outlined, size: 18),
              label: Text(v == 0
                  ? '0${t('dt')}'
                  : '≤ ${v.toStringAsFixed(0)}${t('dt')}'),
              selected: _maxBudget == v,
              showCheckmark: false,
              onSelected: (s) => setState(() => _maxBudget = s ? v : null),
            ),
        ]),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _recipeCard(Map<String, dynamic> r) {
    final total = _ingredientsOf(r).length;
    final match = _matchOf(r);
    final cost = _cost(r);
    final free = cost == 0;
    final meal = '${r['meal']}';
    final name = trField(r['translations'], 'name', '${r['name']}');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => _openDetail(r),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: kBorder),
            ),
            child: Row(
              children: [
                DishImage(
                  meal: meal,
                  url: r['image_url'] as String?,
                  query: r['image_query'] as String?,
                  size: 82,
                  radius: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          Pill(
                            text: _formatCost(cost),
                            background: free
                                ? const Color(0xFFD8F3DC)
                                : const Color(0xFFFFE3D1),
                            foreground:
                                free ? const Color(0xFF1B7A32) : kPrimaryDark,
                          ),
                          Pill(
                            icon: Icons.schedule,
                            text: '${r['prep_minutes']} min',
                          ),
                          Pill(text: cuisineLabel('${r['cuisine']}')),
                        ],
                      ),
                      if (_pantry.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: total == 0 ? 0 : match / total,
                            minHeight: 6,
                            color: kGreen,
                            backgroundColor: const Color(0xFFE3F3E6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          t('youHave', {'a': '$match', 'b': '$total'}),
                          style: const TextStyle(
                              fontSize: 13,
                              color: kGreen,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🍳', style: TextStyle(fontSize: 26)),
            SizedBox(width: 8),
            Text('Cuisinix'),
          ],
        ),
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
              backgroundColor: kGreen,
              label: Text('${_pantry.length}'),
              child: const Icon(Icons.kitchen_outlined),
            ),
            onPressed: _known.isEmpty ? null : _editPantry,
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _scanning ? null : _chooseSource,
        icon: _scanning
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.photo_camera_rounded),
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
                    const Text('😕', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 8),
                    Text(t('loadError'),
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text('${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: kMuted)),
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
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: PeopleStepper(
                      value: _people,
                      onChanged: (n) => setState(() => _people = n),
                    ),
                  ),
                ),
              ),
              _buildFilters(all),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        t('recipesCount', {'n': '${recipes.length}'}),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: kMuted, fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (hasFilter)
                      Flexible(
                        child: TextButton(
                          onPressed: _resetFilters,
                          child: Text(t('clearFilters'),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: recipes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🥣', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 8),
                            Text(t('noRecipesFilter'),
                                style: const TextStyle(color: kMuted)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 96, top: 4),
                        itemCount: recipes.length,
                        itemBuilder: (context, index) =>
                            _recipeCard(recipes[index]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class PeopleStepper extends StatelessWidget {
  const PeopleStepper({super.key, required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget btn(IconData icon, bool enabled, VoidCallback f) => InkWell(
          customBorder: const CircleBorder(),
          onTap: enabled ? f : null,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(icon,
                size: 20, color: enabled ? kPrimaryDark : Colors.black26),
          ),
        );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 6),
          const Icon(Icons.group_outlined, size: 20, color: kMuted),
          const SizedBox(width: 6),
          Text(t('people'),
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(width: 4),
          btn(Icons.remove_circle_outline, value > 1,
              () => onChanged(value - 1)),
          SizedBox(
            width: 22,
            child: Text('$value',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w800)),
          ),
          btn(Icons.add_circle_outline, value < 20, () => onChanged(value + 1)),
        ],
      ),
    );
  }
}

class RecipeDetailPage extends StatefulWidget {
  const RecipeDetailPage({
    super.key,
    required this.name,
    required this.meal,
    this.imageUrl,
    this.imageQuery,
    required this.pills,
    required this.lines,
    required this.packs,
    required this.ingLabel,
    required this.pantry,
    required this.people,
    required this.onPeople,
    required this.steps,
  });

  final String name;
  final String meal;
  final String? imageUrl;
  final String? imageQuery;
  final List<String> pills;
  final List<IngLine> lines;
  final Map<String, List<PackInfo>> packs;
  final String Function(String) ingLabel;
  final Map<String, double?> pantry;
  final int people;
  final ValueChanged<int> onPeople;
  final List<String> steps;

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  late int _people = widget.people;

  Widget _section(BuildContext context, String title) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 10),
        child: Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final lines = widget.lines;
    final pantry = widget.pantry;
    final steps = widget.steps;
    double haveOf(IngLine l) =>
        pantry.containsKey(l.name) ? (pantry[l.name] ?? double.infinity) : 0;
    final have = lines
        .where((l) => pantry.containsKey(l.name) && l.missingFor(_people, haveOf(l)) <= 0)
        .toList();
    final missing = lines.where((l) => !have.contains(l)).toList();
    final total = lines.fold<double>(0, (a, l) => a + l.costFor(_people));
    final purchases = <IngLine, Purchase>{
      for (final l in lines)
        l: purchaseFor(l, _people, haveOf(l), widget.packs[l.name]),
    };
    final toBuy = purchases.values.fold<double>(0, (a, p) => a + p.cost);
    final isFree = toBuy < 0.005;
    final accent = isFree ? const Color(0xFF1B7A32) : kPrimaryDark;
    String? date;
    for (final l in lines) {
      if (l.date != null && (date == null || l.date!.compareTo(date) > 0)) {
        date = l.date;
      }
    }

    Widget row(IngLine l, bool owned) {
      final h = haveOf(l);
      final partial = !owned && pantry.containsKey(l.name);
      final pu = purchases[l]!;
      final price = owned ? l.costFor(_people) : pu.cost;
      var sub = formatQty(l, _people);
      if (owned && pantry[l.name] == null) {
        sub = '$sub · ${t('qtyUnknown')}';
      } else if (partial) {
        sub = '$sub · ${t('youHaveQty', {'q': formatBase(h, l.unit)})}'
            ' · ${t('missingQty', {'q': formatBase(l.missingFor(_people, h), l.unit)})}';
      } else if (!owned && pantry.isNotEmpty) {
        sub = '$sub · ${t('toBuy')}';
      }
      if (!owned && pu.pack != null) {
        // Produit vendu en emballage : on paie l'emballage entier, on n'en utilise qu'une portion
        sub = '$sub\n${t('packBuy', {
              'n': '${pu.count}',
              'p': pu.pack!.label,
              'r': formatBase(pu.leftover, l.unit),
            })}\n${t('usedPortion', {'c': formatDt(l.buyCost(_people, h))})}';
        if (pu.pack!.estimated) sub = '$sub (≈)';
      }
      return ListTile(
        dense: true,
        leading: owned
            ? const Icon(Icons.check_circle_rounded, color: kGreen)
            : Icon(
                pantry.isEmpty
                    ? Icons.circle_outlined
                    : Icons.shopping_basket_outlined,
                color: pantry.isEmpty ? kMuted : kPrimary,
              ),
        title: Text(widget.ingLabel(l.name),
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(sub),
        trailing: Text(
          formatDt(price),
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: owned ? kMuted : kInk,
            decoration: owned ? TextDecoration.lineThrough : null,
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 250,
            backgroundColor: kPrimary,
            foregroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            title: Text(
              widget.name,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFF8A3D), kPrimaryDark],
                      ),
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(top: 30),
                    child: Text(mealEmoji(widget.meal),
                        style: const TextStyle(fontSize: 76)),
                  ),
                  DishImage(
                    meal: widget.meal,
                    url: widget.imageUrl,
                    query: widget.imageQuery,
                    radius: 0,
                    showFallback: false,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x66000000), Color(0x00000000)],
                        stops: [0, 0.4],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final p in widget.pills) Pill(text: p),
                    ],
                  ),
                  const SizedBox(height: 16),
                  PeopleStepper(
                    value: _people,
                    onChanged: (n) {
                      setState(() => _people = n);
                      widget.onPeople(n);
                    },
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isFree
                          ? const Color(0xFFD8F3DC)
                          : const Color(0xFFFFE3D1),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.payments_rounded, color: accent),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                t('buyPacks', {'c': formatDt(toBuy)}),
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: accent),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsetsDirectional.only(start: 34),
                          child: Text(
                            '${t('usedCost', {'c': formatDt(total)})}'
                            ' (${t('perPerson', {'c': formatDt(total / _people)})})',
                            style: TextStyle(color: accent, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _section(context, t('ingredientsTitle')),
                  if (pantry.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        t('youHave', {
                          'a': '${have.length}',
                          'b': '${lines.length}',
                        }),
                        style: const TextStyle(
                            color: kGreen, fontWeight: FontWeight.w700),
                      ),
                    ),
                  if (lines.isEmpty) Text(t('noIngList')),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: kBorder),
                    ),
                    child: Column(
                      children: [
                        for (final l in have) row(l, true),
                        for (final l in missing) row(l, false),
                      ],
                    ),
                  ),
                  if (date != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        t('priceNote', {'d': formatDate(date)}),
                        style: const TextStyle(color: kMuted, fontSize: 13),
                      ),
                    ),
                  _section(context, t('prepTitle')),
                  if (steps.isEmpty) Text(t('noSteps')),
                  for (var n = 0; n < steps.length; n++)
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: kBorder),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: kPrimary,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${n + 1}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text(steps[n],
                                  style: const TextStyle(height: 1.45)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(t('photoCredit'),
                      style: const TextStyle(color: kMuted, fontSize: 13)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
