import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/change_writer.dart';
import 'package:nm_flat/core/data/ops/undo.dart';
import 'package:nm_flat/core/domain/ingredients.dart';
import 'package:nm_flat/core/domain/item_parse.dart';
import 'package:nm_flat/core/domain/recipe_validation.dart';

const recipePalette = <String>[
  '#5E8A2B',
  '#B9792A',
  '#C49A2C',
  '#B0412A',
  '#D3A21B',
  '#A8362A',
  '#C8642A',
  '#4F8A6B',
  '#C98A1F',
];

class RecipeView {
  const RecipeView({
    required this.id,
    required this.name,
    required this.glyph,
    required this.color,
    required this.timeMin,
    required this.serves,
    required this.mealTypes,
    required this.tags,
    required this.steps,
    required this.ingredients,
  });

  factory RecipeView.fromRow(Recipe r) => RecipeView(
    id: r.id,
    name: r.name,
    glyph: r.glyph,
    color: r.color,
    timeMin: r.timeMin,
    serves: r.serves,
    mealTypes: _decodeStrings(r.mealTypes),
    tags: _decodeStrings(r.tags),
    steps: _decodeStrings(r.stepsJson),
    ingredients: _decodeIngredients(r.ingredientsJson),
  );

  final String id;
  final String name;
  final String glyph;
  final String color;
  final int timeMin;
  final int serves;
  final List<String> mealTypes;
  final List<String> tags;
  final List<String> steps;
  final List<Ingredient> ingredients;

  List<String> get allTags => [...mealTypes, ...tags];

  PlannedRecipe toPlanned() => PlannedRecipe(name, serves, ingredients);

  static List<String> _decodeStrings(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return [
        for (final e in decoded)
          if (e is String) e,
      ];
    } catch (_) {
      return const [];
    }
  }

  static List<Ingredient> _decodeIngredients(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return [
        for (final e in decoded)
          if (e is Map) Ingredient.fromJson(Map<String, Object?>.from(e)),
      ];
    } catch (_) {
      return const [];
    }
  }
}

class RecipesRepo {
  RecipesRepo(this.db, this.changes, this.homeId);

  final NestDatabase db;
  final ChangeWriter changes;
  final String homeId;

  Stream<List<RecipeView>> watchAll() =>
      (db.select(db.recipes)
            ..where((r) => r.homeId.equals(homeId) & r.deleted.equals(false))
            ..orderBy([(r) => OrderingTerm.asc(r.name)]))
          .watch()
          .map((rows) => [for (final r in rows) RecipeView.fromRow(r)]);

  Stream<RecipeView?> watchOne(String id) =>
      (db.select(db.recipes)..where(
            (r) =>
                r.id.equals(id) &
                r.homeId.equals(homeId) &
                r.deleted.equals(false),
          ))
          .watchSingleOrNull()
          .map((r) => r == null ? null : RecipeView.fromRow(r));

  Future<String> save(RecipeDraft d, {String? id}) async {
    final trimmedName = d.name.trim();
    final glyph = trimmedName.isEmpty
        ? '?'
        : String.fromCharCode(trimmedName.runes.first).toUpperCase();
    final timeMin = d.timeMin ?? 1;
    final serves = d.serves ?? 4;
    final mealTypesJson = jsonEncode(d.mealTypes);
    final tagsJson = jsonEncode(d.tags);
    final ingredientsJson = jsonEncode([
      for (final row in d.ingredients)
        Ingredient(
          name: row.name.trim(),
          nameKey: itemNameKey(row.name),
          qty: parseQty(row.qtyText) ?? 1.0,
          unit: row.unit,
        ).toJson(),
    ]);
    final stepsJson = jsonEncode([
      for (final s in d.steps)
        if (s.trim().isNotEmpty) s.trim(),
    ]);

    late String outId;
    await changes.write('Saved recipe', (c) {
      final fields = <String, Object?>{
        'name': trimmedName,
        'glyph': glyph,
        'time_min': timeMin,
        'serves': serves,
        'meal_types': mealTypesJson,
        'tags': tagsJson,
        'ingredients_json': ingredientsJson,
        'steps_json': stepsJson,
      };
      if (id == null) {
        final codeSum = trimmedName.codeUnits.fold<int>(0, (a, b) => a + b);
        final color = recipePalette[codeSum % recipePalette.length];
        outId = c.create('recipes', {...fields, 'color': color});
      } else {
        outId = id;
        for (final entry in fields.entries) {
          c.set('recipes', id, entry.key, entry.value);
        }
      }
    }, homeId: homeId);
    return outId;
  }

  Future<ChangeResult> softDelete(
    String id, {
    required List<String> clearSlotIds,
  }) => changes.write('Deleted recipe', (c) {
    c.delete('recipes', id);
    for (final slotId in clearSlotIds) {
      c.set('meal_slots', slotId, 'kind', '');
    }
  }, homeId: homeId);

  Future<(int added, ChangeResult? result)> addStarterPack() async {
    final List<Object?> decoded;
    try {
      final raw = await rootBundle.loadString('assets/data/starter_recipes.json');
      final parsed = jsonDecode(raw);
      if (parsed is! List) return (0, null);
      decoded = parsed;
    } catch (_) {
      return (0, null);
    }

    final existingRows =
        await (db.select(db.recipes)..where(
              (r) => r.homeId.equals(homeId) & r.deleted.equals(false),
            ))
            .get();
    final existingNames = {
      for (final r in existingRows) r.name.trim().toLowerCase(),
    };

    final toAdd = <Map<String, Object?>>[];
    for (final item in decoded) {
      if (item is! Map) continue;
      final map = Map<String, Object?>.from(item);
      final name = map['name'];
      if (name is! String || name.trim().isEmpty) continue;
      if (existingNames.contains(name.trim().toLowerCase())) continue;
      toAdd.add(map);
    }

    if (toAdd.isEmpty) return (0, null);

    final res = await changes.write('Added starter recipes', (c) {
      for (final map in toAdd) {
        final name = (map['name'] as String).trim();
        final glyph = map['glyph'] is String
            ? map['glyph'] as String
            : String.fromCharCode(name.runes.first).toUpperCase();
        final color = map['color'] is String
            ? map['color'] as String
            : recipePalette[0];
        final timeMin = (map['time'] as num?)?.toInt() ?? 20;
        final serves = (map['serves'] as num?)?.toInt() ?? 4;

        final rawTags = [
          for (final t in (map['tags'] as List? ?? const []))
            if (t is String) t,
        ];
        final mealTypes = rawTags.isEmpty ? const <String>[] : [rawTags.first];
        final tags = rawTags.length > 1
            ? rawTags.sublist(1)
            : const <String>[];

        final rawIngs = map['ing'] as List? ?? const [];
        final ings = <Map<String, Object?>>[];
        for (final entry in rawIngs) {
          if (entry is List && entry.length >= 3) {
            final iName = '${entry[0]}';
            final iQty = entry[1] is num ? (entry[1] as num).toDouble() : 1.0;
            final iUnit = '${entry[2]}';
            ings.add(
              Ingredient(
                name: iName,
                nameKey: itemNameKey(iName),
                qty: iQty,
                unit: iUnit,
              ).toJson(),
            );
          }
        }

        final steps = [
          for (final s in (map['steps'] as List? ?? const []))
            if (s is String) s,
        ];

        c.create('recipes', {
          'name': name,
          'glyph': glyph,
          'color': color,
          'time_min': timeMin,
          'serves': serves,
          'meal_types': jsonEncode(mealTypes),
          'tags': jsonEncode(tags),
          'ingredients_json': jsonEncode(ings),
          'steps_json': jsonEncode(steps),
        });
      }
    }, homeId: homeId);

    return (toAdd.length, res);
  }
}
