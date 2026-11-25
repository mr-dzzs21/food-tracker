// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $FoodsTable extends Foods with TableInfo<$FoodsTable, Food> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<FoodSource, int> source =
      GeneratedColumn<int>(
        'source',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<FoodSource>($FoodsTable.$convertersource);
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _externalIdMeta = const VerificationMeta(
    'externalId',
  );
  @override
  late final GeneratedColumn<String> externalId = GeneratedColumn<String>(
    'external_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quantityLabelMeta = const VerificationMeta(
    'quantityLabel',
  );
  @override
  late final GeneratedColumn<String> quantityLabel = GeneratedColumn<String>(
    'quantity_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isLiquidMeta = const VerificationMeta(
    'isLiquid',
  );
  @override
  late final GeneratedColumn<bool> isLiquid = GeneratedColumn<bool>(
    'is_liquid',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_liquid" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _servingSizeMeta = const VerificationMeta(
    'servingSize',
  );
  @override
  late final GeneratedColumn<double> servingSize = GeneratedColumn<double>(
    'serving_size',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _servingLabelMeta = const VerificationMeta(
    'servingLabel',
  );
  @override
  late final GeneratedColumn<String> servingLabel = GeneratedColumn<String>(
    'serving_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kcalMeta = const VerificationMeta('kcal');
  @override
  late final GeneratedColumn<double> kcal = GeneratedColumn<double>(
    'kcal',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fatMeta = const VerificationMeta('fat');
  @override
  late final GeneratedColumn<double> fat = GeneratedColumn<double>(
    'fat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _saturatedFatMeta = const VerificationMeta(
    'saturatedFat',
  );
  @override
  late final GeneratedColumn<double> saturatedFat = GeneratedColumn<double>(
    'saturated_fat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _carbsMeta = const VerificationMeta('carbs');
  @override
  late final GeneratedColumn<double> carbs = GeneratedColumn<double>(
    'carbs',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sugarsMeta = const VerificationMeta('sugars');
  @override
  late final GeneratedColumn<double> sugars = GeneratedColumn<double>(
    'sugars',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fibreMeta = const VerificationMeta('fibre');
  @override
  late final GeneratedColumn<double> fibre = GeneratedColumn<double>(
    'fibre',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _proteinMeta = const VerificationMeta(
    'protein',
  );
  @override
  late final GeneratedColumn<double> protein = GeneratedColumn<double>(
    'protein',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _saltMeta = const VerificationMeta('salt');
  @override
  late final GeneratedColumn<double> salt = GeneratedColumn<double>(
    'salt',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nutriScoreMeta = const VerificationMeta(
    'nutriScore',
  );
  @override
  late final GeneratedColumn<String> nutriScore = GeneratedColumn<String>(
    'nutri_score',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _novaGroupMeta = const VerificationMeta(
    'novaGroup',
  );
  @override
  late final GeneratedColumn<int> novaGroup = GeneratedColumn<int>(
    'nova_group',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoriesMeta = const VerificationMeta(
    'categories',
  );
  @override
  late final GeneratedColumn<String> categories = GeneratedColumn<String>(
    'categories',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completenessMeta = const VerificationMeta(
    'completeness',
  );
  @override
  late final GeneratedColumn<double> completeness = GeneratedColumn<double>(
    'completeness',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFavouriteMeta = const VerificationMeta(
    'isFavourite',
  );
  @override
  late final GeneratedColumn<bool> isFavourite = GeneratedColumn<bool>(
    'is_favourite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favourite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastUsedAtMeta = const VerificationMeta(
    'lastUsedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastUsedAt = GeneratedColumn<DateTime>(
    'last_used_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastViewedAtMeta = const VerificationMeta(
    'lastViewedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastViewedAt = GeneratedColumn<DateTime>(
    'last_viewed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    source,
    barcode,
    externalId,
    name,
    brand,
    quantityLabel,
    isLiquid,
    servingSize,
    servingLabel,
    kcal,
    fat,
    saturatedFat,
    carbs,
    sugars,
    fibre,
    protein,
    salt,
    nutriScore,
    novaGroup,
    categories,
    imageUrl,
    completeness,
    isFavourite,
    lastUsedAt,
    lastViewedAt,
    fetchedAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'foods';
  @override
  VerificationContext validateIntegrity(
    Insertable<Food> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('external_id')) {
      context.handle(
        _externalIdMeta,
        externalId.isAcceptableOrUnknown(data['external_id']!, _externalIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('quantity_label')) {
      context.handle(
        _quantityLabelMeta,
        quantityLabel.isAcceptableOrUnknown(
          data['quantity_label']!,
          _quantityLabelMeta,
        ),
      );
    }
    if (data.containsKey('is_liquid')) {
      context.handle(
        _isLiquidMeta,
        isLiquid.isAcceptableOrUnknown(data['is_liquid']!, _isLiquidMeta),
      );
    }
    if (data.containsKey('serving_size')) {
      context.handle(
        _servingSizeMeta,
        servingSize.isAcceptableOrUnknown(
          data['serving_size']!,
          _servingSizeMeta,
        ),
      );
    }
    if (data.containsKey('serving_label')) {
      context.handle(
        _servingLabelMeta,
        servingLabel.isAcceptableOrUnknown(
          data['serving_label']!,
          _servingLabelMeta,
        ),
      );
    }
    if (data.containsKey('kcal')) {
      context.handle(
        _kcalMeta,
        kcal.isAcceptableOrUnknown(data['kcal']!, _kcalMeta),
      );
    }
    if (data.containsKey('fat')) {
      context.handle(
        _fatMeta,
        fat.isAcceptableOrUnknown(data['fat']!, _fatMeta),
      );
    }
    if (data.containsKey('saturated_fat')) {
      context.handle(
        _saturatedFatMeta,
        saturatedFat.isAcceptableOrUnknown(
          data['saturated_fat']!,
          _saturatedFatMeta,
        ),
      );
    }
    if (data.containsKey('carbs')) {
      context.handle(
        _carbsMeta,
        carbs.isAcceptableOrUnknown(data['carbs']!, _carbsMeta),
      );
    }
    if (data.containsKey('sugars')) {
      context.handle(
        _sugarsMeta,
        sugars.isAcceptableOrUnknown(data['sugars']!, _sugarsMeta),
      );
    }
    if (data.containsKey('fibre')) {
      context.handle(
        _fibreMeta,
        fibre.isAcceptableOrUnknown(data['fibre']!, _fibreMeta),
      );
    }
    if (data.containsKey('protein')) {
      context.handle(
        _proteinMeta,
        protein.isAcceptableOrUnknown(data['protein']!, _proteinMeta),
      );
    }
    if (data.containsKey('salt')) {
      context.handle(
        _saltMeta,
        salt.isAcceptableOrUnknown(data['salt']!, _saltMeta),
      );
    }
    if (data.containsKey('nutri_score')) {
      context.handle(
        _nutriScoreMeta,
        nutriScore.isAcceptableOrUnknown(data['nutri_score']!, _nutriScoreMeta),
      );
    }
    if (data.containsKey('nova_group')) {
      context.handle(
        _novaGroupMeta,
        novaGroup.isAcceptableOrUnknown(data['nova_group']!, _novaGroupMeta),
      );
    }
    if (data.containsKey('categories')) {
      context.handle(
        _categoriesMeta,
        categories.isAcceptableOrUnknown(data['categories']!, _categoriesMeta),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('completeness')) {
      context.handle(
        _completenessMeta,
        completeness.isAcceptableOrUnknown(
          data['completeness']!,
          _completenessMeta,
        ),
      );
    }
    if (data.containsKey('is_favourite')) {
      context.handle(
        _isFavouriteMeta,
        isFavourite.isAcceptableOrUnknown(
          data['is_favourite']!,
          _isFavouriteMeta,
        ),
      );
    }
    if (data.containsKey('last_used_at')) {
      context.handle(
        _lastUsedAtMeta,
        lastUsedAt.isAcceptableOrUnknown(
          data['last_used_at']!,
          _lastUsedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_viewed_at')) {
      context.handle(
        _lastViewedAtMeta,
        lastViewedAt.isAcceptableOrUnknown(
          data['last_viewed_at']!,
          _lastViewedAtMeta,
        ),
      );
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Food map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Food(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      source: $FoodsTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}source'],
        )!,
      ),
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      externalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      ),
      quantityLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quantity_label'],
      ),
      isLiquid: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_liquid'],
      )!,
      servingSize: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}serving_size'],
      ),
      servingLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}serving_label'],
      ),
      kcal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kcal'],
      ),
      fat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat'],
      ),
      saturatedFat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}saturated_fat'],
      ),
      carbs: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs'],
      ),
      sugars: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sugars'],
      ),
      fibre: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fibre'],
      ),
      protein: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein'],
      ),
      salt: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}salt'],
      ),
      nutriScore: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nutri_score'],
      ),
      novaGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}nova_group'],
      ),
      categories: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}categories'],
      ),
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      completeness: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}completeness'],
      ),
      isFavourite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favourite'],
      )!,
      lastUsedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_used_at'],
      ),
      lastViewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_viewed_at'],
      ),
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FoodsTable createAlias(String alias) {
    return $FoodsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<FoodSource, int, int> $convertersource =
      const EnumIndexConverter<FoodSource>(FoodSource.values);
}

class Food extends DataClass implements Insertable<Food> {
  final int id;
  final FoodSource source;

  /// Normalised barcode (GTIN). NULL for own foods without a barcode.
  final String? barcode;

  /// The food's key in its source, for example the BLS code "B782100".
  /// NULL for Open Food Facts products (their key is [barcode]) and own
  /// foods. Added in schema version 2.
  final String? externalId;
  final String name;
  final String? brand;

  /// Package size for display, for example "175 g".
  final String? quantityLabel;

  /// True for drinks: values are per 100 ml and amounts are in ml.
  final bool isLiquid;

  /// Size of one portion in g (or ml), for example 30.
  final double? servingSize;

  /// Text for one portion, for example "1 Riegel (30 g)".
  final String? servingLabel;
  final double? kcal;
  final double? fat;
  final double? saturatedFat;
  final double? carbs;
  final double? sugars;
  final double? fibre;
  final double? protein;
  final double? salt;

  /// Nutri-Score grade "A" … "E" as reported by Open Food Facts.
  final String? nutriScore;
  final int? novaGroup;

  /// Open Food Facts category tags, joined with commas
  /// (for example "en:snacks,en:chips"). Used by the health rating.
  final String? categories;
  final String? imageUrl;

  /// How complete the Open Food Facts entry is (0.0 – 1.0).
  final double? completeness;
  final bool isFavourite;

  /// Last time this food was added to the diary ("Zuletzt gegessen").
  final DateTime? lastUsedAt;

  /// Last time the product page was opened ("Zuletzt angesehen").
  final DateTime? lastViewedAt;

  /// When the data was downloaded from Open Food Facts (cache age).
  final DateTime? fetchedAt;
  final DateTime createdAt;
  const Food({
    required this.id,
    required this.source,
    this.barcode,
    this.externalId,
    required this.name,
    this.brand,
    this.quantityLabel,
    required this.isLiquid,
    this.servingSize,
    this.servingLabel,
    this.kcal,
    this.fat,
    this.saturatedFat,
    this.carbs,
    this.sugars,
    this.fibre,
    this.protein,
    this.salt,
    this.nutriScore,
    this.novaGroup,
    this.categories,
    this.imageUrl,
    this.completeness,
    required this.isFavourite,
    this.lastUsedAt,
    this.lastViewedAt,
    this.fetchedAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['source'] = Variable<int>($FoodsTable.$convertersource.toSql(source));
    }
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    if (!nullToAbsent || externalId != null) {
      map['external_id'] = Variable<String>(externalId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || brand != null) {
      map['brand'] = Variable<String>(brand);
    }
    if (!nullToAbsent || quantityLabel != null) {
      map['quantity_label'] = Variable<String>(quantityLabel);
    }
    map['is_liquid'] = Variable<bool>(isLiquid);
    if (!nullToAbsent || servingSize != null) {
      map['serving_size'] = Variable<double>(servingSize);
    }
    if (!nullToAbsent || servingLabel != null) {
      map['serving_label'] = Variable<String>(servingLabel);
    }
    if (!nullToAbsent || kcal != null) {
      map['kcal'] = Variable<double>(kcal);
    }
    if (!nullToAbsent || fat != null) {
      map['fat'] = Variable<double>(fat);
    }
    if (!nullToAbsent || saturatedFat != null) {
      map['saturated_fat'] = Variable<double>(saturatedFat);
    }
    if (!nullToAbsent || carbs != null) {
      map['carbs'] = Variable<double>(carbs);
    }
    if (!nullToAbsent || sugars != null) {
      map['sugars'] = Variable<double>(sugars);
    }
    if (!nullToAbsent || fibre != null) {
      map['fibre'] = Variable<double>(fibre);
    }
    if (!nullToAbsent || protein != null) {
      map['protein'] = Variable<double>(protein);
    }
    if (!nullToAbsent || salt != null) {
      map['salt'] = Variable<double>(salt);
    }
    if (!nullToAbsent || nutriScore != null) {
      map['nutri_score'] = Variable<String>(nutriScore);
    }
    if (!nullToAbsent || novaGroup != null) {
      map['nova_group'] = Variable<int>(novaGroup);
    }
    if (!nullToAbsent || categories != null) {
      map['categories'] = Variable<String>(categories);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || completeness != null) {
      map['completeness'] = Variable<double>(completeness);
    }
    map['is_favourite'] = Variable<bool>(isFavourite);
    if (!nullToAbsent || lastUsedAt != null) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt);
    }
    if (!nullToAbsent || lastViewedAt != null) {
      map['last_viewed_at'] = Variable<DateTime>(lastViewedAt);
    }
    if (!nullToAbsent || fetchedAt != null) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FoodsCompanion toCompanion(bool nullToAbsent) {
    return FoodsCompanion(
      id: Value(id),
      source: Value(source),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      externalId: externalId == null && nullToAbsent
          ? const Value.absent()
          : Value(externalId),
      name: Value(name),
      brand: brand == null && nullToAbsent
          ? const Value.absent()
          : Value(brand),
      quantityLabel: quantityLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(quantityLabel),
      isLiquid: Value(isLiquid),
      servingSize: servingSize == null && nullToAbsent
          ? const Value.absent()
          : Value(servingSize),
      servingLabel: servingLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(servingLabel),
      kcal: kcal == null && nullToAbsent ? const Value.absent() : Value(kcal),
      fat: fat == null && nullToAbsent ? const Value.absent() : Value(fat),
      saturatedFat: saturatedFat == null && nullToAbsent
          ? const Value.absent()
          : Value(saturatedFat),
      carbs: carbs == null && nullToAbsent
          ? const Value.absent()
          : Value(carbs),
      sugars: sugars == null && nullToAbsent
          ? const Value.absent()
          : Value(sugars),
      fibre: fibre == null && nullToAbsent
          ? const Value.absent()
          : Value(fibre),
      protein: protein == null && nullToAbsent
          ? const Value.absent()
          : Value(protein),
      salt: salt == null && nullToAbsent ? const Value.absent() : Value(salt),
      nutriScore: nutriScore == null && nullToAbsent
          ? const Value.absent()
          : Value(nutriScore),
      novaGroup: novaGroup == null && nullToAbsent
          ? const Value.absent()
          : Value(novaGroup),
      categories: categories == null && nullToAbsent
          ? const Value.absent()
          : Value(categories),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      completeness: completeness == null && nullToAbsent
          ? const Value.absent()
          : Value(completeness),
      isFavourite: Value(isFavourite),
      lastUsedAt: lastUsedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUsedAt),
      lastViewedAt: lastViewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastViewedAt),
      fetchedAt: fetchedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(fetchedAt),
      createdAt: Value(createdAt),
    );
  }

  factory Food.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Food(
      id: serializer.fromJson<int>(json['id']),
      source: $FoodsTable.$convertersource.fromJson(
        serializer.fromJson<int>(json['source']),
      ),
      barcode: serializer.fromJson<String?>(json['barcode']),
      externalId: serializer.fromJson<String?>(json['externalId']),
      name: serializer.fromJson<String>(json['name']),
      brand: serializer.fromJson<String?>(json['brand']),
      quantityLabel: serializer.fromJson<String?>(json['quantityLabel']),
      isLiquid: serializer.fromJson<bool>(json['isLiquid']),
      servingSize: serializer.fromJson<double?>(json['servingSize']),
      servingLabel: serializer.fromJson<String?>(json['servingLabel']),
      kcal: serializer.fromJson<double?>(json['kcal']),
      fat: serializer.fromJson<double?>(json['fat']),
      saturatedFat: serializer.fromJson<double?>(json['saturatedFat']),
      carbs: serializer.fromJson<double?>(json['carbs']),
      sugars: serializer.fromJson<double?>(json['sugars']),
      fibre: serializer.fromJson<double?>(json['fibre']),
      protein: serializer.fromJson<double?>(json['protein']),
      salt: serializer.fromJson<double?>(json['salt']),
      nutriScore: serializer.fromJson<String?>(json['nutriScore']),
      novaGroup: serializer.fromJson<int?>(json['novaGroup']),
      categories: serializer.fromJson<String?>(json['categories']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      completeness: serializer.fromJson<double?>(json['completeness']),
      isFavourite: serializer.fromJson<bool>(json['isFavourite']),
      lastUsedAt: serializer.fromJson<DateTime?>(json['lastUsedAt']),
      lastViewedAt: serializer.fromJson<DateTime?>(json['lastViewedAt']),
      fetchedAt: serializer.fromJson<DateTime?>(json['fetchedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'source': serializer.toJson<int>(
        $FoodsTable.$convertersource.toJson(source),
      ),
      'barcode': serializer.toJson<String?>(barcode),
      'externalId': serializer.toJson<String?>(externalId),
      'name': serializer.toJson<String>(name),
      'brand': serializer.toJson<String?>(brand),
      'quantityLabel': serializer.toJson<String?>(quantityLabel),
      'isLiquid': serializer.toJson<bool>(isLiquid),
      'servingSize': serializer.toJson<double?>(servingSize),
      'servingLabel': serializer.toJson<String?>(servingLabel),
      'kcal': serializer.toJson<double?>(kcal),
      'fat': serializer.toJson<double?>(fat),
      'saturatedFat': serializer.toJson<double?>(saturatedFat),
      'carbs': serializer.toJson<double?>(carbs),
      'sugars': serializer.toJson<double?>(sugars),
      'fibre': serializer.toJson<double?>(fibre),
      'protein': serializer.toJson<double?>(protein),
      'salt': serializer.toJson<double?>(salt),
      'nutriScore': serializer.toJson<String?>(nutriScore),
      'novaGroup': serializer.toJson<int?>(novaGroup),
      'categories': serializer.toJson<String?>(categories),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'completeness': serializer.toJson<double?>(completeness),
      'isFavourite': serializer.toJson<bool>(isFavourite),
      'lastUsedAt': serializer.toJson<DateTime?>(lastUsedAt),
      'lastViewedAt': serializer.toJson<DateTime?>(lastViewedAt),
      'fetchedAt': serializer.toJson<DateTime?>(fetchedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Food copyWith({
    int? id,
    FoodSource? source,
    Value<String?> barcode = const Value.absent(),
    Value<String?> externalId = const Value.absent(),
    String? name,
    Value<String?> brand = const Value.absent(),
    Value<String?> quantityLabel = const Value.absent(),
    bool? isLiquid,
    Value<double?> servingSize = const Value.absent(),
    Value<String?> servingLabel = const Value.absent(),
    Value<double?> kcal = const Value.absent(),
    Value<double?> fat = const Value.absent(),
    Value<double?> saturatedFat = const Value.absent(),
    Value<double?> carbs = const Value.absent(),
    Value<double?> sugars = const Value.absent(),
    Value<double?> fibre = const Value.absent(),
    Value<double?> protein = const Value.absent(),
    Value<double?> salt = const Value.absent(),
    Value<String?> nutriScore = const Value.absent(),
    Value<int?> novaGroup = const Value.absent(),
    Value<String?> categories = const Value.absent(),
    Value<String?> imageUrl = const Value.absent(),
    Value<double?> completeness = const Value.absent(),
    bool? isFavourite,
    Value<DateTime?> lastUsedAt = const Value.absent(),
    Value<DateTime?> lastViewedAt = const Value.absent(),
    Value<DateTime?> fetchedAt = const Value.absent(),
    DateTime? createdAt,
  }) => Food(
    id: id ?? this.id,
    source: source ?? this.source,
    barcode: barcode.present ? barcode.value : this.barcode,
    externalId: externalId.present ? externalId.value : this.externalId,
    name: name ?? this.name,
    brand: brand.present ? brand.value : this.brand,
    quantityLabel: quantityLabel.present
        ? quantityLabel.value
        : this.quantityLabel,
    isLiquid: isLiquid ?? this.isLiquid,
    servingSize: servingSize.present ? servingSize.value : this.servingSize,
    servingLabel: servingLabel.present ? servingLabel.value : this.servingLabel,
    kcal: kcal.present ? kcal.value : this.kcal,
    fat: fat.present ? fat.value : this.fat,
    saturatedFat: saturatedFat.present ? saturatedFat.value : this.saturatedFat,
    carbs: carbs.present ? carbs.value : this.carbs,
    sugars: sugars.present ? sugars.value : this.sugars,
    fibre: fibre.present ? fibre.value : this.fibre,
    protein: protein.present ? protein.value : this.protein,
    salt: salt.present ? salt.value : this.salt,
    nutriScore: nutriScore.present ? nutriScore.value : this.nutriScore,
    novaGroup: novaGroup.present ? novaGroup.value : this.novaGroup,
    categories: categories.present ? categories.value : this.categories,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    completeness: completeness.present ? completeness.value : this.completeness,
    isFavourite: isFavourite ?? this.isFavourite,
    lastUsedAt: lastUsedAt.present ? lastUsedAt.value : this.lastUsedAt,
    lastViewedAt: lastViewedAt.present ? lastViewedAt.value : this.lastViewedAt,
    fetchedAt: fetchedAt.present ? fetchedAt.value : this.fetchedAt,
    createdAt: createdAt ?? this.createdAt,
  );
  Food copyWithCompanion(FoodsCompanion data) {
    return Food(
      id: data.id.present ? data.id.value : this.id,
      source: data.source.present ? data.source.value : this.source,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      externalId: data.externalId.present
          ? data.externalId.value
          : this.externalId,
      name: data.name.present ? data.name.value : this.name,
      brand: data.brand.present ? data.brand.value : this.brand,
      quantityLabel: data.quantityLabel.present
          ? data.quantityLabel.value
          : this.quantityLabel,
      isLiquid: data.isLiquid.present ? data.isLiquid.value : this.isLiquid,
      servingSize: data.servingSize.present
          ? data.servingSize.value
          : this.servingSize,
      servingLabel: data.servingLabel.present
          ? data.servingLabel.value
          : this.servingLabel,
      kcal: data.kcal.present ? data.kcal.value : this.kcal,
      fat: data.fat.present ? data.fat.value : this.fat,
      saturatedFat: data.saturatedFat.present
          ? data.saturatedFat.value
          : this.saturatedFat,
      carbs: data.carbs.present ? data.carbs.value : this.carbs,
      sugars: data.sugars.present ? data.sugars.value : this.sugars,
      fibre: data.fibre.present ? data.fibre.value : this.fibre,
      protein: data.protein.present ? data.protein.value : this.protein,
      salt: data.salt.present ? data.salt.value : this.salt,
      nutriScore: data.nutriScore.present
          ? data.nutriScore.value
          : this.nutriScore,
      novaGroup: data.novaGroup.present ? data.novaGroup.value : this.novaGroup,
      categories: data.categories.present
          ? data.categories.value
          : this.categories,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      completeness: data.completeness.present
          ? data.completeness.value
          : this.completeness,
      isFavourite: data.isFavourite.present
          ? data.isFavourite.value
          : this.isFavourite,
      lastUsedAt: data.lastUsedAt.present
          ? data.lastUsedAt.value
          : this.lastUsedAt,
      lastViewedAt: data.lastViewedAt.present
          ? data.lastViewedAt.value
          : this.lastViewedAt,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Food(')
          ..write('id: $id, ')
          ..write('source: $source, ')
          ..write('barcode: $barcode, ')
          ..write('externalId: $externalId, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('quantityLabel: $quantityLabel, ')
          ..write('isLiquid: $isLiquid, ')
          ..write('servingSize: $servingSize, ')
          ..write('servingLabel: $servingLabel, ')
          ..write('kcal: $kcal, ')
          ..write('fat: $fat, ')
          ..write('saturatedFat: $saturatedFat, ')
          ..write('carbs: $carbs, ')
          ..write('sugars: $sugars, ')
          ..write('fibre: $fibre, ')
          ..write('protein: $protein, ')
          ..write('salt: $salt, ')
          ..write('nutriScore: $nutriScore, ')
          ..write('novaGroup: $novaGroup, ')
          ..write('categories: $categories, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('completeness: $completeness, ')
          ..write('isFavourite: $isFavourite, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('lastViewedAt: $lastViewedAt, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    source,
    barcode,
    externalId,
    name,
    brand,
    quantityLabel,
    isLiquid,
    servingSize,
    servingLabel,
    kcal,
    fat,
    saturatedFat,
    carbs,
    sugars,
    fibre,
    protein,
    salt,
    nutriScore,
    novaGroup,
    categories,
    imageUrl,
    completeness,
    isFavourite,
    lastUsedAt,
    lastViewedAt,
    fetchedAt,
    createdAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Food &&
          other.id == this.id &&
          other.source == this.source &&
          other.barcode == this.barcode &&
          other.externalId == this.externalId &&
          other.name == this.name &&
          other.brand == this.brand &&
          other.quantityLabel == this.quantityLabel &&
          other.isLiquid == this.isLiquid &&
          other.servingSize == this.servingSize &&
          other.servingLabel == this.servingLabel &&
          other.kcal == this.kcal &&
          other.fat == this.fat &&
          other.saturatedFat == this.saturatedFat &&
          other.carbs == this.carbs &&
          other.sugars == this.sugars &&
          other.fibre == this.fibre &&
          other.protein == this.protein &&
          other.salt == this.salt &&
          other.nutriScore == this.nutriScore &&
          other.novaGroup == this.novaGroup &&
          other.categories == this.categories &&
          other.imageUrl == this.imageUrl &&
          other.completeness == this.completeness &&
          other.isFavourite == this.isFavourite &&
          other.lastUsedAt == this.lastUsedAt &&
          other.lastViewedAt == this.lastViewedAt &&
          other.fetchedAt == this.fetchedAt &&
          other.createdAt == this.createdAt);
}

class FoodsCompanion extends UpdateCompanion<Food> {
  final Value<int> id;
  final Value<FoodSource> source;
  final Value<String?> barcode;
  final Value<String?> externalId;
  final Value<String> name;
  final Value<String?> brand;
  final Value<String?> quantityLabel;
  final Value<bool> isLiquid;
  final Value<double?> servingSize;
  final Value<String?> servingLabel;
  final Value<double?> kcal;
  final Value<double?> fat;
  final Value<double?> saturatedFat;
  final Value<double?> carbs;
  final Value<double?> sugars;
  final Value<double?> fibre;
  final Value<double?> protein;
  final Value<double?> salt;
  final Value<String?> nutriScore;
  final Value<int?> novaGroup;
  final Value<String?> categories;
  final Value<String?> imageUrl;
  final Value<double?> completeness;
  final Value<bool> isFavourite;
  final Value<DateTime?> lastUsedAt;
  final Value<DateTime?> lastViewedAt;
  final Value<DateTime?> fetchedAt;
  final Value<DateTime> createdAt;
  const FoodsCompanion({
    this.id = const Value.absent(),
    this.source = const Value.absent(),
    this.barcode = const Value.absent(),
    this.externalId = const Value.absent(),
    this.name = const Value.absent(),
    this.brand = const Value.absent(),
    this.quantityLabel = const Value.absent(),
    this.isLiquid = const Value.absent(),
    this.servingSize = const Value.absent(),
    this.servingLabel = const Value.absent(),
    this.kcal = const Value.absent(),
    this.fat = const Value.absent(),
    this.saturatedFat = const Value.absent(),
    this.carbs = const Value.absent(),
    this.sugars = const Value.absent(),
    this.fibre = const Value.absent(),
    this.protein = const Value.absent(),
    this.salt = const Value.absent(),
    this.nutriScore = const Value.absent(),
    this.novaGroup = const Value.absent(),
    this.categories = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.completeness = const Value.absent(),
    this.isFavourite = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    this.lastViewedAt = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  FoodsCompanion.insert({
    this.id = const Value.absent(),
    required FoodSource source,
    this.barcode = const Value.absent(),
    this.externalId = const Value.absent(),
    required String name,
    this.brand = const Value.absent(),
    this.quantityLabel = const Value.absent(),
    this.isLiquid = const Value.absent(),
    this.servingSize = const Value.absent(),
    this.servingLabel = const Value.absent(),
    this.kcal = const Value.absent(),
    this.fat = const Value.absent(),
    this.saturatedFat = const Value.absent(),
    this.carbs = const Value.absent(),
    this.sugars = const Value.absent(),
    this.fibre = const Value.absent(),
    this.protein = const Value.absent(),
    this.salt = const Value.absent(),
    this.nutriScore = const Value.absent(),
    this.novaGroup = const Value.absent(),
    this.categories = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.completeness = const Value.absent(),
    this.isFavourite = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    this.lastViewedAt = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    required DateTime createdAt,
  }) : source = Value(source),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<Food> custom({
    Expression<int>? id,
    Expression<int>? source,
    Expression<String>? barcode,
    Expression<String>? externalId,
    Expression<String>? name,
    Expression<String>? brand,
    Expression<String>? quantityLabel,
    Expression<bool>? isLiquid,
    Expression<double>? servingSize,
    Expression<String>? servingLabel,
    Expression<double>? kcal,
    Expression<double>? fat,
    Expression<double>? saturatedFat,
    Expression<double>? carbs,
    Expression<double>? sugars,
    Expression<double>? fibre,
    Expression<double>? protein,
    Expression<double>? salt,
    Expression<String>? nutriScore,
    Expression<int>? novaGroup,
    Expression<String>? categories,
    Expression<String>? imageUrl,
    Expression<double>? completeness,
    Expression<bool>? isFavourite,
    Expression<DateTime>? lastUsedAt,
    Expression<DateTime>? lastViewedAt,
    Expression<DateTime>? fetchedAt,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (source != null) 'source': source,
      if (barcode != null) 'barcode': barcode,
      if (externalId != null) 'external_id': externalId,
      if (name != null) 'name': name,
      if (brand != null) 'brand': brand,
      if (quantityLabel != null) 'quantity_label': quantityLabel,
      if (isLiquid != null) 'is_liquid': isLiquid,
      if (servingSize != null) 'serving_size': servingSize,
      if (servingLabel != null) 'serving_label': servingLabel,
      if (kcal != null) 'kcal': kcal,
      if (fat != null) 'fat': fat,
      if (saturatedFat != null) 'saturated_fat': saturatedFat,
      if (carbs != null) 'carbs': carbs,
      if (sugars != null) 'sugars': sugars,
      if (fibre != null) 'fibre': fibre,
      if (protein != null) 'protein': protein,
      if (salt != null) 'salt': salt,
      if (nutriScore != null) 'nutri_score': nutriScore,
      if (novaGroup != null) 'nova_group': novaGroup,
      if (categories != null) 'categories': categories,
      if (imageUrl != null) 'image_url': imageUrl,
      if (completeness != null) 'completeness': completeness,
      if (isFavourite != null) 'is_favourite': isFavourite,
      if (lastUsedAt != null) 'last_used_at': lastUsedAt,
      if (lastViewedAt != null) 'last_viewed_at': lastViewedAt,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  FoodsCompanion copyWith({
    Value<int>? id,
    Value<FoodSource>? source,
    Value<String?>? barcode,
    Value<String?>? externalId,
    Value<String>? name,
    Value<String?>? brand,
    Value<String?>? quantityLabel,
    Value<bool>? isLiquid,
    Value<double?>? servingSize,
    Value<String?>? servingLabel,
    Value<double?>? kcal,
    Value<double?>? fat,
    Value<double?>? saturatedFat,
    Value<double?>? carbs,
    Value<double?>? sugars,
    Value<double?>? fibre,
    Value<double?>? protein,
    Value<double?>? salt,
    Value<String?>? nutriScore,
    Value<int?>? novaGroup,
    Value<String?>? categories,
    Value<String?>? imageUrl,
    Value<double?>? completeness,
    Value<bool>? isFavourite,
    Value<DateTime?>? lastUsedAt,
    Value<DateTime?>? lastViewedAt,
    Value<DateTime?>? fetchedAt,
    Value<DateTime>? createdAt,
  }) {
    return FoodsCompanion(
      id: id ?? this.id,
      source: source ?? this.source,
      barcode: barcode ?? this.barcode,
      externalId: externalId ?? this.externalId,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      quantityLabel: quantityLabel ?? this.quantityLabel,
      isLiquid: isLiquid ?? this.isLiquid,
      servingSize: servingSize ?? this.servingSize,
      servingLabel: servingLabel ?? this.servingLabel,
      kcal: kcal ?? this.kcal,
      fat: fat ?? this.fat,
      saturatedFat: saturatedFat ?? this.saturatedFat,
      carbs: carbs ?? this.carbs,
      sugars: sugars ?? this.sugars,
      fibre: fibre ?? this.fibre,
      protein: protein ?? this.protein,
      salt: salt ?? this.salt,
      nutriScore: nutriScore ?? this.nutriScore,
      novaGroup: novaGroup ?? this.novaGroup,
      categories: categories ?? this.categories,
      imageUrl: imageUrl ?? this.imageUrl,
      completeness: completeness ?? this.completeness,
      isFavourite: isFavourite ?? this.isFavourite,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      lastViewedAt: lastViewedAt ?? this.lastViewedAt,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (source.present) {
      map['source'] = Variable<int>(
        $FoodsTable.$convertersource.toSql(source.value),
      );
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (externalId.present) {
      map['external_id'] = Variable<String>(externalId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (quantityLabel.present) {
      map['quantity_label'] = Variable<String>(quantityLabel.value);
    }
    if (isLiquid.present) {
      map['is_liquid'] = Variable<bool>(isLiquid.value);
    }
    if (servingSize.present) {
      map['serving_size'] = Variable<double>(servingSize.value);
    }
    if (servingLabel.present) {
      map['serving_label'] = Variable<String>(servingLabel.value);
    }
    if (kcal.present) {
      map['kcal'] = Variable<double>(kcal.value);
    }
    if (fat.present) {
      map['fat'] = Variable<double>(fat.value);
    }
    if (saturatedFat.present) {
      map['saturated_fat'] = Variable<double>(saturatedFat.value);
    }
    if (carbs.present) {
      map['carbs'] = Variable<double>(carbs.value);
    }
    if (sugars.present) {
      map['sugars'] = Variable<double>(sugars.value);
    }
    if (fibre.present) {
      map['fibre'] = Variable<double>(fibre.value);
    }
    if (protein.present) {
      map['protein'] = Variable<double>(protein.value);
    }
    if (salt.present) {
      map['salt'] = Variable<double>(salt.value);
    }
    if (nutriScore.present) {
      map['nutri_score'] = Variable<String>(nutriScore.value);
    }
    if (novaGroup.present) {
      map['nova_group'] = Variable<int>(novaGroup.value);
    }
    if (categories.present) {
      map['categories'] = Variable<String>(categories.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (completeness.present) {
      map['completeness'] = Variable<double>(completeness.value);
    }
    if (isFavourite.present) {
      map['is_favourite'] = Variable<bool>(isFavourite.value);
    }
    if (lastUsedAt.present) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt.value);
    }
    if (lastViewedAt.present) {
      map['last_viewed_at'] = Variable<DateTime>(lastViewedAt.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoodsCompanion(')
          ..write('id: $id, ')
          ..write('source: $source, ')
          ..write('barcode: $barcode, ')
          ..write('externalId: $externalId, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('quantityLabel: $quantityLabel, ')
          ..write('isLiquid: $isLiquid, ')
          ..write('servingSize: $servingSize, ')
          ..write('servingLabel: $servingLabel, ')
          ..write('kcal: $kcal, ')
          ..write('fat: $fat, ')
          ..write('saturatedFat: $saturatedFat, ')
          ..write('carbs: $carbs, ')
          ..write('sugars: $sugars, ')
          ..write('fibre: $fibre, ')
          ..write('protein: $protein, ')
          ..write('salt: $salt, ')
          ..write('nutriScore: $nutriScore, ')
          ..write('novaGroup: $novaGroup, ')
          ..write('categories: $categories, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('completeness: $completeness, ')
          ..write('isFavourite: $isFavourite, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('lastViewedAt: $lastViewedAt, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MealSlotsTable extends MealSlots
    with TableInfo<$MealSlotsTable, MealSlot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MealSlotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _builtInMeta = const VerificationMeta(
    'builtIn',
  );
  @override
  late final GeneratedColumn<String> builtIn = GeneratedColumn<String>(
    'built_in',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customNameMeta = const VerificationMeta(
    'customName',
  );
  @override
  late final GeneratedColumn<String> customName = GeneratedColumn<String>(
    'custom_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isHiddenMeta = const VerificationMeta(
    'isHidden',
  );
  @override
  late final GeneratedColumn<bool> isHidden = GeneratedColumn<bool>(
    'is_hidden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_hidden" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _startMinuteMeta = const VerificationMeta(
    'startMinute',
  );
  @override
  late final GeneratedColumn<int> startMinute = GeneratedColumn<int>(
    'start_minute',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    builtIn,
    customName,
    position,
    isHidden,
    startMinute,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meal_slots';
  @override
  VerificationContext validateIntegrity(
    Insertable<MealSlot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('built_in')) {
      context.handle(
        _builtInMeta,
        builtIn.isAcceptableOrUnknown(data['built_in']!, _builtInMeta),
      );
    }
    if (data.containsKey('custom_name')) {
      context.handle(
        _customNameMeta,
        customName.isAcceptableOrUnknown(data['custom_name']!, _customNameMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('is_hidden')) {
      context.handle(
        _isHiddenMeta,
        isHidden.isAcceptableOrUnknown(data['is_hidden']!, _isHiddenMeta),
      );
    }
    if (data.containsKey('start_minute')) {
      context.handle(
        _startMinuteMeta,
        startMinute.isAcceptableOrUnknown(
          data['start_minute']!,
          _startMinuteMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MealSlot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MealSlot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      builtIn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}built_in'],
      ),
      customName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_name'],
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      isHidden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_hidden'],
      )!,
      startMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_minute'],
      ),
    );
  }

  @override
  $MealSlotsTable createAlias(String alias) {
    return $MealSlotsTable(attachedDatabase, alias);
  }
}

class MealSlot extends DataClass implements Insertable<MealSlot> {
  final int id;

  /// `breakfast`, `lunch`, `dinner` or `snacks` for the four meals the app
  /// starts with (their names are translated). NULL for meals the user added.
  final String? builtIn;

  /// Name chosen by the user. If set, it is shown instead of the default name.
  final String? customName;

  /// Display order, 0 first.
  final int position;
  final bool isHidden;

  /// Time of day in minutes after midnight from which this meal is suggested
  /// (for example 660 = 11:00). NULL = never suggested automatically.
  final int? startMinute;
  const MealSlot({
    required this.id,
    this.builtIn,
    this.customName,
    required this.position,
    required this.isHidden,
    this.startMinute,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || builtIn != null) {
      map['built_in'] = Variable<String>(builtIn);
    }
    if (!nullToAbsent || customName != null) {
      map['custom_name'] = Variable<String>(customName);
    }
    map['position'] = Variable<int>(position);
    map['is_hidden'] = Variable<bool>(isHidden);
    if (!nullToAbsent || startMinute != null) {
      map['start_minute'] = Variable<int>(startMinute);
    }
    return map;
  }

  MealSlotsCompanion toCompanion(bool nullToAbsent) {
    return MealSlotsCompanion(
      id: Value(id),
      builtIn: builtIn == null && nullToAbsent
          ? const Value.absent()
          : Value(builtIn),
      customName: customName == null && nullToAbsent
          ? const Value.absent()
          : Value(customName),
      position: Value(position),
      isHidden: Value(isHidden),
      startMinute: startMinute == null && nullToAbsent
          ? const Value.absent()
          : Value(startMinute),
    );
  }

  factory MealSlot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MealSlot(
      id: serializer.fromJson<int>(json['id']),
      builtIn: serializer.fromJson<String?>(json['builtIn']),
      customName: serializer.fromJson<String?>(json['customName']),
      position: serializer.fromJson<int>(json['position']),
      isHidden: serializer.fromJson<bool>(json['isHidden']),
      startMinute: serializer.fromJson<int?>(json['startMinute']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'builtIn': serializer.toJson<String?>(builtIn),
      'customName': serializer.toJson<String?>(customName),
      'position': serializer.toJson<int>(position),
      'isHidden': serializer.toJson<bool>(isHidden),
      'startMinute': serializer.toJson<int?>(startMinute),
    };
  }

  MealSlot copyWith({
    int? id,
    Value<String?> builtIn = const Value.absent(),
    Value<String?> customName = const Value.absent(),
    int? position,
    bool? isHidden,
    Value<int?> startMinute = const Value.absent(),
  }) => MealSlot(
    id: id ?? this.id,
    builtIn: builtIn.present ? builtIn.value : this.builtIn,
    customName: customName.present ? customName.value : this.customName,
    position: position ?? this.position,
    isHidden: isHidden ?? this.isHidden,
    startMinute: startMinute.present ? startMinute.value : this.startMinute,
  );
  MealSlot copyWithCompanion(MealSlotsCompanion data) {
    return MealSlot(
      id: data.id.present ? data.id.value : this.id,
      builtIn: data.builtIn.present ? data.builtIn.value : this.builtIn,
      customName: data.customName.present
          ? data.customName.value
          : this.customName,
      position: data.position.present ? data.position.value : this.position,
      isHidden: data.isHidden.present ? data.isHidden.value : this.isHidden,
      startMinute: data.startMinute.present
          ? data.startMinute.value
          : this.startMinute,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MealSlot(')
          ..write('id: $id, ')
          ..write('builtIn: $builtIn, ')
          ..write('customName: $customName, ')
          ..write('position: $position, ')
          ..write('isHidden: $isHidden, ')
          ..write('startMinute: $startMinute')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, builtIn, customName, position, isHidden, startMinute);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MealSlot &&
          other.id == this.id &&
          other.builtIn == this.builtIn &&
          other.customName == this.customName &&
          other.position == this.position &&
          other.isHidden == this.isHidden &&
          other.startMinute == this.startMinute);
}

class MealSlotsCompanion extends UpdateCompanion<MealSlot> {
  final Value<int> id;
  final Value<String?> builtIn;
  final Value<String?> customName;
  final Value<int> position;
  final Value<bool> isHidden;
  final Value<int?> startMinute;
  const MealSlotsCompanion({
    this.id = const Value.absent(),
    this.builtIn = const Value.absent(),
    this.customName = const Value.absent(),
    this.position = const Value.absent(),
    this.isHidden = const Value.absent(),
    this.startMinute = const Value.absent(),
  });
  MealSlotsCompanion.insert({
    this.id = const Value.absent(),
    this.builtIn = const Value.absent(),
    this.customName = const Value.absent(),
    required int position,
    this.isHidden = const Value.absent(),
    this.startMinute = const Value.absent(),
  }) : position = Value(position);
  static Insertable<MealSlot> custom({
    Expression<int>? id,
    Expression<String>? builtIn,
    Expression<String>? customName,
    Expression<int>? position,
    Expression<bool>? isHidden,
    Expression<int>? startMinute,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (builtIn != null) 'built_in': builtIn,
      if (customName != null) 'custom_name': customName,
      if (position != null) 'position': position,
      if (isHidden != null) 'is_hidden': isHidden,
      if (startMinute != null) 'start_minute': startMinute,
    });
  }

  MealSlotsCompanion copyWith({
    Value<int>? id,
    Value<String?>? builtIn,
    Value<String?>? customName,
    Value<int>? position,
    Value<bool>? isHidden,
    Value<int?>? startMinute,
  }) {
    return MealSlotsCompanion(
      id: id ?? this.id,
      builtIn: builtIn ?? this.builtIn,
      customName: customName ?? this.customName,
      position: position ?? this.position,
      isHidden: isHidden ?? this.isHidden,
      startMinute: startMinute ?? this.startMinute,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (builtIn.present) {
      map['built_in'] = Variable<String>(builtIn.value);
    }
    if (customName.present) {
      map['custom_name'] = Variable<String>(customName.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (isHidden.present) {
      map['is_hidden'] = Variable<bool>(isHidden.value);
    }
    if (startMinute.present) {
      map['start_minute'] = Variable<int>(startMinute.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MealSlotsCompanion(')
          ..write('id: $id, ')
          ..write('builtIn: $builtIn, ')
          ..write('customName: $customName, ')
          ..write('position: $position, ')
          ..write('isHidden: $isHidden, ')
          ..write('startMinute: $startMinute')
          ..write(')'))
        .toString();
  }
}

class $DiaryEntriesTable extends DiaryEntries
    with TableInfo<$DiaryEntriesTable, DiaryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DiaryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 10,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mealSlotIdMeta = const VerificationMeta(
    'mealSlotId',
  );
  @override
  late final GeneratedColumn<int> mealSlotId = GeneratedColumn<int>(
    'meal_slot_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES meal_slots (id)',
    ),
  );
  static const VerificationMeta _foodIdMeta = const VerificationMeta('foodId');
  @override
  late final GeneratedColumn<int> foodId = GeneratedColumn<int>(
    'food_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES foods (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isLiquidMeta = const VerificationMeta(
    'isLiquid',
  );
  @override
  late final GeneratedColumn<bool> isLiquid = GeneratedColumn<bool>(
    'is_liquid',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_liquid" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _servingLabelMeta = const VerificationMeta(
    'servingLabel',
  );
  @override
  late final GeneratedColumn<String> servingLabel = GeneratedColumn<String>(
    'serving_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kcalMeta = const VerificationMeta('kcal');
  @override
  late final GeneratedColumn<double> kcal = GeneratedColumn<double>(
    'kcal',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fatMeta = const VerificationMeta('fat');
  @override
  late final GeneratedColumn<double> fat = GeneratedColumn<double>(
    'fat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _saturatedFatMeta = const VerificationMeta(
    'saturatedFat',
  );
  @override
  late final GeneratedColumn<double> saturatedFat = GeneratedColumn<double>(
    'saturated_fat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _carbsMeta = const VerificationMeta('carbs');
  @override
  late final GeneratedColumn<double> carbs = GeneratedColumn<double>(
    'carbs',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sugarsMeta = const VerificationMeta('sugars');
  @override
  late final GeneratedColumn<double> sugars = GeneratedColumn<double>(
    'sugars',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fibreMeta = const VerificationMeta('fibre');
  @override
  late final GeneratedColumn<double> fibre = GeneratedColumn<double>(
    'fibre',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _proteinMeta = const VerificationMeta(
    'protein',
  );
  @override
  late final GeneratedColumn<double> protein = GeneratedColumn<double>(
    'protein',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _saltMeta = const VerificationMeta('salt');
  @override
  late final GeneratedColumn<double> salt = GeneratedColumn<double>(
    'salt',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    day,
    mealSlotId,
    foodId,
    name,
    brand,
    amount,
    isLiquid,
    servingLabel,
    kcal,
    fat,
    saturatedFat,
    carbs,
    sugars,
    fibre,
    protein,
    salt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'diary_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<DiaryEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('meal_slot_id')) {
      context.handle(
        _mealSlotIdMeta,
        mealSlotId.isAcceptableOrUnknown(
          data['meal_slot_id']!,
          _mealSlotIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mealSlotIdMeta);
    }
    if (data.containsKey('food_id')) {
      context.handle(
        _foodIdMeta,
        foodId.isAcceptableOrUnknown(data['food_id']!, _foodIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('is_liquid')) {
      context.handle(
        _isLiquidMeta,
        isLiquid.isAcceptableOrUnknown(data['is_liquid']!, _isLiquidMeta),
      );
    }
    if (data.containsKey('serving_label')) {
      context.handle(
        _servingLabelMeta,
        servingLabel.isAcceptableOrUnknown(
          data['serving_label']!,
          _servingLabelMeta,
        ),
      );
    }
    if (data.containsKey('kcal')) {
      context.handle(
        _kcalMeta,
        kcal.isAcceptableOrUnknown(data['kcal']!, _kcalMeta),
      );
    }
    if (data.containsKey('fat')) {
      context.handle(
        _fatMeta,
        fat.isAcceptableOrUnknown(data['fat']!, _fatMeta),
      );
    }
    if (data.containsKey('saturated_fat')) {
      context.handle(
        _saturatedFatMeta,
        saturatedFat.isAcceptableOrUnknown(
          data['saturated_fat']!,
          _saturatedFatMeta,
        ),
      );
    }
    if (data.containsKey('carbs')) {
      context.handle(
        _carbsMeta,
        carbs.isAcceptableOrUnknown(data['carbs']!, _carbsMeta),
      );
    }
    if (data.containsKey('sugars')) {
      context.handle(
        _sugarsMeta,
        sugars.isAcceptableOrUnknown(data['sugars']!, _sugarsMeta),
      );
    }
    if (data.containsKey('fibre')) {
      context.handle(
        _fibreMeta,
        fibre.isAcceptableOrUnknown(data['fibre']!, _fibreMeta),
      );
    }
    if (data.containsKey('protein')) {
      context.handle(
        _proteinMeta,
        protein.isAcceptableOrUnknown(data['protein']!, _proteinMeta),
      );
    }
    if (data.containsKey('salt')) {
      context.handle(
        _saltMeta,
        salt.isAcceptableOrUnknown(data['salt']!, _saltMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DiaryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DiaryEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      mealSlotId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}meal_slot_id'],
      )!,
      foodId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}food_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      isLiquid: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_liquid'],
      )!,
      servingLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}serving_label'],
      ),
      kcal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kcal'],
      ),
      fat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat'],
      ),
      saturatedFat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}saturated_fat'],
      ),
      carbs: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs'],
      ),
      sugars: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sugars'],
      ),
      fibre: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fibre'],
      ),
      protein: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein'],
      ),
      salt: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}salt'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DiaryEntriesTable createAlias(String alias) {
    return $DiaryEntriesTable(attachedDatabase, alias);
  }
}

class DiaryEntry extends DataClass implements Insertable<DiaryEntry> {
  final int id;

  /// Local calendar day, for example "2026-11-14" (see core/clock.dart).
  final String day;
  final int mealSlotId;

  /// The food this entry came from (NULL if that food was deleted).
  final int? foodId;
  final String name;
  final String? brand;

  /// How much was eaten, in g (or ml when [isLiquid]).
  final double amount;
  final bool isLiquid;
  final String? servingLabel;
  final double? kcal;
  final double? fat;
  final double? saturatedFat;
  final double? carbs;
  final double? sugars;
  final double? fibre;
  final double? protein;
  final double? salt;
  final DateTime createdAt;
  const DiaryEntry({
    required this.id,
    required this.day,
    required this.mealSlotId,
    this.foodId,
    required this.name,
    this.brand,
    required this.amount,
    required this.isLiquid,
    this.servingLabel,
    this.kcal,
    this.fat,
    this.saturatedFat,
    this.carbs,
    this.sugars,
    this.fibre,
    this.protein,
    this.salt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['day'] = Variable<String>(day);
    map['meal_slot_id'] = Variable<int>(mealSlotId);
    if (!nullToAbsent || foodId != null) {
      map['food_id'] = Variable<int>(foodId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || brand != null) {
      map['brand'] = Variable<String>(brand);
    }
    map['amount'] = Variable<double>(amount);
    map['is_liquid'] = Variable<bool>(isLiquid);
    if (!nullToAbsent || servingLabel != null) {
      map['serving_label'] = Variable<String>(servingLabel);
    }
    if (!nullToAbsent || kcal != null) {
      map['kcal'] = Variable<double>(kcal);
    }
    if (!nullToAbsent || fat != null) {
      map['fat'] = Variable<double>(fat);
    }
    if (!nullToAbsent || saturatedFat != null) {
      map['saturated_fat'] = Variable<double>(saturatedFat);
    }
    if (!nullToAbsent || carbs != null) {
      map['carbs'] = Variable<double>(carbs);
    }
    if (!nullToAbsent || sugars != null) {
      map['sugars'] = Variable<double>(sugars);
    }
    if (!nullToAbsent || fibre != null) {
      map['fibre'] = Variable<double>(fibre);
    }
    if (!nullToAbsent || protein != null) {
      map['protein'] = Variable<double>(protein);
    }
    if (!nullToAbsent || salt != null) {
      map['salt'] = Variable<double>(salt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DiaryEntriesCompanion toCompanion(bool nullToAbsent) {
    return DiaryEntriesCompanion(
      id: Value(id),
      day: Value(day),
      mealSlotId: Value(mealSlotId),
      foodId: foodId == null && nullToAbsent
          ? const Value.absent()
          : Value(foodId),
      name: Value(name),
      brand: brand == null && nullToAbsent
          ? const Value.absent()
          : Value(brand),
      amount: Value(amount),
      isLiquid: Value(isLiquid),
      servingLabel: servingLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(servingLabel),
      kcal: kcal == null && nullToAbsent ? const Value.absent() : Value(kcal),
      fat: fat == null && nullToAbsent ? const Value.absent() : Value(fat),
      saturatedFat: saturatedFat == null && nullToAbsent
          ? const Value.absent()
          : Value(saturatedFat),
      carbs: carbs == null && nullToAbsent
          ? const Value.absent()
          : Value(carbs),
      sugars: sugars == null && nullToAbsent
          ? const Value.absent()
          : Value(sugars),
      fibre: fibre == null && nullToAbsent
          ? const Value.absent()
          : Value(fibre),
      protein: protein == null && nullToAbsent
          ? const Value.absent()
          : Value(protein),
      salt: salt == null && nullToAbsent ? const Value.absent() : Value(salt),
      createdAt: Value(createdAt),
    );
  }

  factory DiaryEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DiaryEntry(
      id: serializer.fromJson<int>(json['id']),
      day: serializer.fromJson<String>(json['day']),
      mealSlotId: serializer.fromJson<int>(json['mealSlotId']),
      foodId: serializer.fromJson<int?>(json['foodId']),
      name: serializer.fromJson<String>(json['name']),
      brand: serializer.fromJson<String?>(json['brand']),
      amount: serializer.fromJson<double>(json['amount']),
      isLiquid: serializer.fromJson<bool>(json['isLiquid']),
      servingLabel: serializer.fromJson<String?>(json['servingLabel']),
      kcal: serializer.fromJson<double?>(json['kcal']),
      fat: serializer.fromJson<double?>(json['fat']),
      saturatedFat: serializer.fromJson<double?>(json['saturatedFat']),
      carbs: serializer.fromJson<double?>(json['carbs']),
      sugars: serializer.fromJson<double?>(json['sugars']),
      fibre: serializer.fromJson<double?>(json['fibre']),
      protein: serializer.fromJson<double?>(json['protein']),
      salt: serializer.fromJson<double?>(json['salt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'day': serializer.toJson<String>(day),
      'mealSlotId': serializer.toJson<int>(mealSlotId),
      'foodId': serializer.toJson<int?>(foodId),
      'name': serializer.toJson<String>(name),
      'brand': serializer.toJson<String?>(brand),
      'amount': serializer.toJson<double>(amount),
      'isLiquid': serializer.toJson<bool>(isLiquid),
      'servingLabel': serializer.toJson<String?>(servingLabel),
      'kcal': serializer.toJson<double?>(kcal),
      'fat': serializer.toJson<double?>(fat),
      'saturatedFat': serializer.toJson<double?>(saturatedFat),
      'carbs': serializer.toJson<double?>(carbs),
      'sugars': serializer.toJson<double?>(sugars),
      'fibre': serializer.toJson<double?>(fibre),
      'protein': serializer.toJson<double?>(protein),
      'salt': serializer.toJson<double?>(salt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DiaryEntry copyWith({
    int? id,
    String? day,
    int? mealSlotId,
    Value<int?> foodId = const Value.absent(),
    String? name,
    Value<String?> brand = const Value.absent(),
    double? amount,
    bool? isLiquid,
    Value<String?> servingLabel = const Value.absent(),
    Value<double?> kcal = const Value.absent(),
    Value<double?> fat = const Value.absent(),
    Value<double?> saturatedFat = const Value.absent(),
    Value<double?> carbs = const Value.absent(),
    Value<double?> sugars = const Value.absent(),
    Value<double?> fibre = const Value.absent(),
    Value<double?> protein = const Value.absent(),
    Value<double?> salt = const Value.absent(),
    DateTime? createdAt,
  }) => DiaryEntry(
    id: id ?? this.id,
    day: day ?? this.day,
    mealSlotId: mealSlotId ?? this.mealSlotId,
    foodId: foodId.present ? foodId.value : this.foodId,
    name: name ?? this.name,
    brand: brand.present ? brand.value : this.brand,
    amount: amount ?? this.amount,
    isLiquid: isLiquid ?? this.isLiquid,
    servingLabel: servingLabel.present ? servingLabel.value : this.servingLabel,
    kcal: kcal.present ? kcal.value : this.kcal,
    fat: fat.present ? fat.value : this.fat,
    saturatedFat: saturatedFat.present ? saturatedFat.value : this.saturatedFat,
    carbs: carbs.present ? carbs.value : this.carbs,
    sugars: sugars.present ? sugars.value : this.sugars,
    fibre: fibre.present ? fibre.value : this.fibre,
    protein: protein.present ? protein.value : this.protein,
    salt: salt.present ? salt.value : this.salt,
    createdAt: createdAt ?? this.createdAt,
  );
  DiaryEntry copyWithCompanion(DiaryEntriesCompanion data) {
    return DiaryEntry(
      id: data.id.present ? data.id.value : this.id,
      day: data.day.present ? data.day.value : this.day,
      mealSlotId: data.mealSlotId.present
          ? data.mealSlotId.value
          : this.mealSlotId,
      foodId: data.foodId.present ? data.foodId.value : this.foodId,
      name: data.name.present ? data.name.value : this.name,
      brand: data.brand.present ? data.brand.value : this.brand,
      amount: data.amount.present ? data.amount.value : this.amount,
      isLiquid: data.isLiquid.present ? data.isLiquid.value : this.isLiquid,
      servingLabel: data.servingLabel.present
          ? data.servingLabel.value
          : this.servingLabel,
      kcal: data.kcal.present ? data.kcal.value : this.kcal,
      fat: data.fat.present ? data.fat.value : this.fat,
      saturatedFat: data.saturatedFat.present
          ? data.saturatedFat.value
          : this.saturatedFat,
      carbs: data.carbs.present ? data.carbs.value : this.carbs,
      sugars: data.sugars.present ? data.sugars.value : this.sugars,
      fibre: data.fibre.present ? data.fibre.value : this.fibre,
      protein: data.protein.present ? data.protein.value : this.protein,
      salt: data.salt.present ? data.salt.value : this.salt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DiaryEntry(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('mealSlotId: $mealSlotId, ')
          ..write('foodId: $foodId, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('amount: $amount, ')
          ..write('isLiquid: $isLiquid, ')
          ..write('servingLabel: $servingLabel, ')
          ..write('kcal: $kcal, ')
          ..write('fat: $fat, ')
          ..write('saturatedFat: $saturatedFat, ')
          ..write('carbs: $carbs, ')
          ..write('sugars: $sugars, ')
          ..write('fibre: $fibre, ')
          ..write('protein: $protein, ')
          ..write('salt: $salt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    day,
    mealSlotId,
    foodId,
    name,
    brand,
    amount,
    isLiquid,
    servingLabel,
    kcal,
    fat,
    saturatedFat,
    carbs,
    sugars,
    fibre,
    protein,
    salt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DiaryEntry &&
          other.id == this.id &&
          other.day == this.day &&
          other.mealSlotId == this.mealSlotId &&
          other.foodId == this.foodId &&
          other.name == this.name &&
          other.brand == this.brand &&
          other.amount == this.amount &&
          other.isLiquid == this.isLiquid &&
          other.servingLabel == this.servingLabel &&
          other.kcal == this.kcal &&
          other.fat == this.fat &&
          other.saturatedFat == this.saturatedFat &&
          other.carbs == this.carbs &&
          other.sugars == this.sugars &&
          other.fibre == this.fibre &&
          other.protein == this.protein &&
          other.salt == this.salt &&
          other.createdAt == this.createdAt);
}

class DiaryEntriesCompanion extends UpdateCompanion<DiaryEntry> {
  final Value<int> id;
  final Value<String> day;
  final Value<int> mealSlotId;
  final Value<int?> foodId;
  final Value<String> name;
  final Value<String?> brand;
  final Value<double> amount;
  final Value<bool> isLiquid;
  final Value<String?> servingLabel;
  final Value<double?> kcal;
  final Value<double?> fat;
  final Value<double?> saturatedFat;
  final Value<double?> carbs;
  final Value<double?> sugars;
  final Value<double?> fibre;
  final Value<double?> protein;
  final Value<double?> salt;
  final Value<DateTime> createdAt;
  const DiaryEntriesCompanion({
    this.id = const Value.absent(),
    this.day = const Value.absent(),
    this.mealSlotId = const Value.absent(),
    this.foodId = const Value.absent(),
    this.name = const Value.absent(),
    this.brand = const Value.absent(),
    this.amount = const Value.absent(),
    this.isLiquid = const Value.absent(),
    this.servingLabel = const Value.absent(),
    this.kcal = const Value.absent(),
    this.fat = const Value.absent(),
    this.saturatedFat = const Value.absent(),
    this.carbs = const Value.absent(),
    this.sugars = const Value.absent(),
    this.fibre = const Value.absent(),
    this.protein = const Value.absent(),
    this.salt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  DiaryEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String day,
    required int mealSlotId,
    this.foodId = const Value.absent(),
    required String name,
    this.brand = const Value.absent(),
    required double amount,
    this.isLiquid = const Value.absent(),
    this.servingLabel = const Value.absent(),
    this.kcal = const Value.absent(),
    this.fat = const Value.absent(),
    this.saturatedFat = const Value.absent(),
    this.carbs = const Value.absent(),
    this.sugars = const Value.absent(),
    this.fibre = const Value.absent(),
    this.protein = const Value.absent(),
    this.salt = const Value.absent(),
    required DateTime createdAt,
  }) : day = Value(day),
       mealSlotId = Value(mealSlotId),
       name = Value(name),
       amount = Value(amount),
       createdAt = Value(createdAt);
  static Insertable<DiaryEntry> custom({
    Expression<int>? id,
    Expression<String>? day,
    Expression<int>? mealSlotId,
    Expression<int>? foodId,
    Expression<String>? name,
    Expression<String>? brand,
    Expression<double>? amount,
    Expression<bool>? isLiquid,
    Expression<String>? servingLabel,
    Expression<double>? kcal,
    Expression<double>? fat,
    Expression<double>? saturatedFat,
    Expression<double>? carbs,
    Expression<double>? sugars,
    Expression<double>? fibre,
    Expression<double>? protein,
    Expression<double>? salt,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (day != null) 'day': day,
      if (mealSlotId != null) 'meal_slot_id': mealSlotId,
      if (foodId != null) 'food_id': foodId,
      if (name != null) 'name': name,
      if (brand != null) 'brand': brand,
      if (amount != null) 'amount': amount,
      if (isLiquid != null) 'is_liquid': isLiquid,
      if (servingLabel != null) 'serving_label': servingLabel,
      if (kcal != null) 'kcal': kcal,
      if (fat != null) 'fat': fat,
      if (saturatedFat != null) 'saturated_fat': saturatedFat,
      if (carbs != null) 'carbs': carbs,
      if (sugars != null) 'sugars': sugars,
      if (fibre != null) 'fibre': fibre,
      if (protein != null) 'protein': protein,
      if (salt != null) 'salt': salt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  DiaryEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? day,
    Value<int>? mealSlotId,
    Value<int?>? foodId,
    Value<String>? name,
    Value<String?>? brand,
    Value<double>? amount,
    Value<bool>? isLiquid,
    Value<String?>? servingLabel,
    Value<double?>? kcal,
    Value<double?>? fat,
    Value<double?>? saturatedFat,
    Value<double?>? carbs,
    Value<double?>? sugars,
    Value<double?>? fibre,
    Value<double?>? protein,
    Value<double?>? salt,
    Value<DateTime>? createdAt,
  }) {
    return DiaryEntriesCompanion(
      id: id ?? this.id,
      day: day ?? this.day,
      mealSlotId: mealSlotId ?? this.mealSlotId,
      foodId: foodId ?? this.foodId,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      amount: amount ?? this.amount,
      isLiquid: isLiquid ?? this.isLiquid,
      servingLabel: servingLabel ?? this.servingLabel,
      kcal: kcal ?? this.kcal,
      fat: fat ?? this.fat,
      saturatedFat: saturatedFat ?? this.saturatedFat,
      carbs: carbs ?? this.carbs,
      sugars: sugars ?? this.sugars,
      fibre: fibre ?? this.fibre,
      protein: protein ?? this.protein,
      salt: salt ?? this.salt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (mealSlotId.present) {
      map['meal_slot_id'] = Variable<int>(mealSlotId.value);
    }
    if (foodId.present) {
      map['food_id'] = Variable<int>(foodId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (isLiquid.present) {
      map['is_liquid'] = Variable<bool>(isLiquid.value);
    }
    if (servingLabel.present) {
      map['serving_label'] = Variable<String>(servingLabel.value);
    }
    if (kcal.present) {
      map['kcal'] = Variable<double>(kcal.value);
    }
    if (fat.present) {
      map['fat'] = Variable<double>(fat.value);
    }
    if (saturatedFat.present) {
      map['saturated_fat'] = Variable<double>(saturatedFat.value);
    }
    if (carbs.present) {
      map['carbs'] = Variable<double>(carbs.value);
    }
    if (sugars.present) {
      map['sugars'] = Variable<double>(sugars.value);
    }
    if (fibre.present) {
      map['fibre'] = Variable<double>(fibre.value);
    }
    if (protein.present) {
      map['protein'] = Variable<double>(protein.value);
    }
    if (salt.present) {
      map['salt'] = Variable<double>(salt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DiaryEntriesCompanion(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('mealSlotId: $mealSlotId, ')
          ..write('foodId: $foodId, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('amount: $amount, ')
          ..write('isLiquid: $isLiquid, ')
          ..write('servingLabel: $servingLabel, ')
          ..write('kcal: $kcal, ')
          ..write('fat: $fat, ')
          ..write('saturatedFat: $saturatedFat, ')
          ..write('carbs: $carbs, ')
          ..write('sugars: $sugars, ')
          ..write('fibre: $fibre, ')
          ..write('protein: $protein, ')
          ..write('salt: $salt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $UserGoalTable extends UserGoal
    with TableInfo<$UserGoalTable, UserGoalRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserGoalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kcalMeta = const VerificationMeta('kcal');
  @override
  late final GeneratedColumn<int> kcal = GeneratedColumn<int>(
    'kcal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinMeta = const VerificationMeta(
    'protein',
  );
  @override
  late final GeneratedColumn<double> protein = GeneratedColumn<double>(
    'protein',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _carbsMeta = const VerificationMeta('carbs');
  @override
  late final GeneratedColumn<double> carbs = GeneratedColumn<double>(
    'carbs',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fatMeta = const VerificationMeta('fat');
  @override
  late final GeneratedColumn<double> fat = GeneratedColumn<double>(
    'fat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Sex?, int> sex =
      GeneratedColumn<int>(
        'sex',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<Sex?>($UserGoalTable.$convertersexn);
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
    'age',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightCmMeta = const VerificationMeta(
    'heightCm',
  );
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
    'height_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ActivityLevel?, int> activity =
      GeneratedColumn<int>(
        'activity',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<ActivityLevel?>($UserGoalTable.$converteractivityn);
  @override
  late final GeneratedColumnWithTypeConverter<GoalType?, int> goalType =
      GeneratedColumn<int>(
        'goal_type',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<GoalType?>($UserGoalTable.$convertergoalTypen);
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kcal,
    protein,
    carbs,
    fat,
    sex,
    age,
    heightCm,
    weightKg,
    activity,
    goalType,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_goal';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserGoalRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('kcal')) {
      context.handle(
        _kcalMeta,
        kcal.isAcceptableOrUnknown(data['kcal']!, _kcalMeta),
      );
    } else if (isInserting) {
      context.missing(_kcalMeta);
    }
    if (data.containsKey('protein')) {
      context.handle(
        _proteinMeta,
        protein.isAcceptableOrUnknown(data['protein']!, _proteinMeta),
      );
    }
    if (data.containsKey('carbs')) {
      context.handle(
        _carbsMeta,
        carbs.isAcceptableOrUnknown(data['carbs']!, _carbsMeta),
      );
    }
    if (data.containsKey('fat')) {
      context.handle(
        _fatMeta,
        fat.isAcceptableOrUnknown(data['fat']!, _fatMeta),
      );
    }
    if (data.containsKey('age')) {
      context.handle(
        _ageMeta,
        age.isAcceptableOrUnknown(data['age']!, _ageMeta),
      );
    }
    if (data.containsKey('height_cm')) {
      context.handle(
        _heightCmMeta,
        heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta),
      );
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserGoalRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserGoalRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      kcal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}kcal'],
      )!,
      protein: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein'],
      ),
      carbs: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs'],
      ),
      fat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat'],
      ),
      sex: $UserGoalTable.$convertersexn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}sex'],
        ),
      ),
      age: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}age'],
      ),
      heightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height_cm'],
      ),
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      ),
      activity: $UserGoalTable.$converteractivityn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}activity'],
        ),
      ),
      goalType: $UserGoalTable.$convertergoalTypen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}goal_type'],
        ),
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UserGoalTable createAlias(String alias) {
    return $UserGoalTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Sex, int, int> $convertersex =
      const EnumIndexConverter<Sex>(Sex.values);
  static JsonTypeConverter2<Sex?, int?, int?> $convertersexn =
      JsonTypeConverter2.asNullable($convertersex);
  static JsonTypeConverter2<ActivityLevel, int, int> $converteractivity =
      const EnumIndexConverter<ActivityLevel>(ActivityLevel.values);
  static JsonTypeConverter2<ActivityLevel?, int?, int?> $converteractivityn =
      JsonTypeConverter2.asNullable($converteractivity);
  static JsonTypeConverter2<GoalType, int, int> $convertergoalType =
      const EnumIndexConverter<GoalType>(GoalType.values);
  static JsonTypeConverter2<GoalType?, int?, int?> $convertergoalTypen =
      JsonTypeConverter2.asNullable($convertergoalType);
}

class UserGoalRow extends DataClass implements Insertable<UserGoalRow> {
  final int id;
  final int kcal;

  /// Daily macro goals in grams (NULL = not set).
  final double? protein;
  final double? carbs;
  final double? fat;
  final Sex? sex;
  final int? age;
  final double? heightCm;
  final double? weightKg;
  final ActivityLevel? activity;
  final GoalType? goalType;
  final DateTime updatedAt;
  const UserGoalRow({
    required this.id,
    required this.kcal,
    this.protein,
    this.carbs,
    this.fat,
    this.sex,
    this.age,
    this.heightCm,
    this.weightKg,
    this.activity,
    this.goalType,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['kcal'] = Variable<int>(kcal);
    if (!nullToAbsent || protein != null) {
      map['protein'] = Variable<double>(protein);
    }
    if (!nullToAbsent || carbs != null) {
      map['carbs'] = Variable<double>(carbs);
    }
    if (!nullToAbsent || fat != null) {
      map['fat'] = Variable<double>(fat);
    }
    if (!nullToAbsent || sex != null) {
      map['sex'] = Variable<int>($UserGoalTable.$convertersexn.toSql(sex));
    }
    if (!nullToAbsent || age != null) {
      map['age'] = Variable<int>(age);
    }
    if (!nullToAbsent || heightCm != null) {
      map['height_cm'] = Variable<double>(heightCm);
    }
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    if (!nullToAbsent || activity != null) {
      map['activity'] = Variable<int>(
        $UserGoalTable.$converteractivityn.toSql(activity),
      );
    }
    if (!nullToAbsent || goalType != null) {
      map['goal_type'] = Variable<int>(
        $UserGoalTable.$convertergoalTypen.toSql(goalType),
      );
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserGoalCompanion toCompanion(bool nullToAbsent) {
    return UserGoalCompanion(
      id: Value(id),
      kcal: Value(kcal),
      protein: protein == null && nullToAbsent
          ? const Value.absent()
          : Value(protein),
      carbs: carbs == null && nullToAbsent
          ? const Value.absent()
          : Value(carbs),
      fat: fat == null && nullToAbsent ? const Value.absent() : Value(fat),
      sex: sex == null && nullToAbsent ? const Value.absent() : Value(sex),
      age: age == null && nullToAbsent ? const Value.absent() : Value(age),
      heightCm: heightCm == null && nullToAbsent
          ? const Value.absent()
          : Value(heightCm),
      weightKg: weightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightKg),
      activity: activity == null && nullToAbsent
          ? const Value.absent()
          : Value(activity),
      goalType: goalType == null && nullToAbsent
          ? const Value.absent()
          : Value(goalType),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserGoalRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserGoalRow(
      id: serializer.fromJson<int>(json['id']),
      kcal: serializer.fromJson<int>(json['kcal']),
      protein: serializer.fromJson<double?>(json['protein']),
      carbs: serializer.fromJson<double?>(json['carbs']),
      fat: serializer.fromJson<double?>(json['fat']),
      sex: $UserGoalTable.$convertersexn.fromJson(
        serializer.fromJson<int?>(json['sex']),
      ),
      age: serializer.fromJson<int?>(json['age']),
      heightCm: serializer.fromJson<double?>(json['heightCm']),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      activity: $UserGoalTable.$converteractivityn.fromJson(
        serializer.fromJson<int?>(json['activity']),
      ),
      goalType: $UserGoalTable.$convertergoalTypen.fromJson(
        serializer.fromJson<int?>(json['goalType']),
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kcal': serializer.toJson<int>(kcal),
      'protein': serializer.toJson<double?>(protein),
      'carbs': serializer.toJson<double?>(carbs),
      'fat': serializer.toJson<double?>(fat),
      'sex': serializer.toJson<int?>($UserGoalTable.$convertersexn.toJson(sex)),
      'age': serializer.toJson<int?>(age),
      'heightCm': serializer.toJson<double?>(heightCm),
      'weightKg': serializer.toJson<double?>(weightKg),
      'activity': serializer.toJson<int?>(
        $UserGoalTable.$converteractivityn.toJson(activity),
      ),
      'goalType': serializer.toJson<int?>(
        $UserGoalTable.$convertergoalTypen.toJson(goalType),
      ),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserGoalRow copyWith({
    int? id,
    int? kcal,
    Value<double?> protein = const Value.absent(),
    Value<double?> carbs = const Value.absent(),
    Value<double?> fat = const Value.absent(),
    Value<Sex?> sex = const Value.absent(),
    Value<int?> age = const Value.absent(),
    Value<double?> heightCm = const Value.absent(),
    Value<double?> weightKg = const Value.absent(),
    Value<ActivityLevel?> activity = const Value.absent(),
    Value<GoalType?> goalType = const Value.absent(),
    DateTime? updatedAt,
  }) => UserGoalRow(
    id: id ?? this.id,
    kcal: kcal ?? this.kcal,
    protein: protein.present ? protein.value : this.protein,
    carbs: carbs.present ? carbs.value : this.carbs,
    fat: fat.present ? fat.value : this.fat,
    sex: sex.present ? sex.value : this.sex,
    age: age.present ? age.value : this.age,
    heightCm: heightCm.present ? heightCm.value : this.heightCm,
    weightKg: weightKg.present ? weightKg.value : this.weightKg,
    activity: activity.present ? activity.value : this.activity,
    goalType: goalType.present ? goalType.value : this.goalType,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserGoalRow copyWithCompanion(UserGoalCompanion data) {
    return UserGoalRow(
      id: data.id.present ? data.id.value : this.id,
      kcal: data.kcal.present ? data.kcal.value : this.kcal,
      protein: data.protein.present ? data.protein.value : this.protein,
      carbs: data.carbs.present ? data.carbs.value : this.carbs,
      fat: data.fat.present ? data.fat.value : this.fat,
      sex: data.sex.present ? data.sex.value : this.sex,
      age: data.age.present ? data.age.value : this.age,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      activity: data.activity.present ? data.activity.value : this.activity,
      goalType: data.goalType.present ? data.goalType.value : this.goalType,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserGoalRow(')
          ..write('id: $id, ')
          ..write('kcal: $kcal, ')
          ..write('protein: $protein, ')
          ..write('carbs: $carbs, ')
          ..write('fat: $fat, ')
          ..write('sex: $sex, ')
          ..write('age: $age, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg, ')
          ..write('activity: $activity, ')
          ..write('goalType: $goalType, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kcal,
    protein,
    carbs,
    fat,
    sex,
    age,
    heightCm,
    weightKg,
    activity,
    goalType,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserGoalRow &&
          other.id == this.id &&
          other.kcal == this.kcal &&
          other.protein == this.protein &&
          other.carbs == this.carbs &&
          other.fat == this.fat &&
          other.sex == this.sex &&
          other.age == this.age &&
          other.heightCm == this.heightCm &&
          other.weightKg == this.weightKg &&
          other.activity == this.activity &&
          other.goalType == this.goalType &&
          other.updatedAt == this.updatedAt);
}

class UserGoalCompanion extends UpdateCompanion<UserGoalRow> {
  final Value<int> id;
  final Value<int> kcal;
  final Value<double?> protein;
  final Value<double?> carbs;
  final Value<double?> fat;
  final Value<Sex?> sex;
  final Value<int?> age;
  final Value<double?> heightCm;
  final Value<double?> weightKg;
  final Value<ActivityLevel?> activity;
  final Value<GoalType?> goalType;
  final Value<DateTime> updatedAt;
  const UserGoalCompanion({
    this.id = const Value.absent(),
    this.kcal = const Value.absent(),
    this.protein = const Value.absent(),
    this.carbs = const Value.absent(),
    this.fat = const Value.absent(),
    this.sex = const Value.absent(),
    this.age = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.activity = const Value.absent(),
    this.goalType = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UserGoalCompanion.insert({
    this.id = const Value.absent(),
    required int kcal,
    this.protein = const Value.absent(),
    this.carbs = const Value.absent(),
    this.fat = const Value.absent(),
    this.sex = const Value.absent(),
    this.age = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.activity = const Value.absent(),
    this.goalType = const Value.absent(),
    required DateTime updatedAt,
  }) : kcal = Value(kcal),
       updatedAt = Value(updatedAt);
  static Insertable<UserGoalRow> custom({
    Expression<int>? id,
    Expression<int>? kcal,
    Expression<double>? protein,
    Expression<double>? carbs,
    Expression<double>? fat,
    Expression<int>? sex,
    Expression<int>? age,
    Expression<double>? heightCm,
    Expression<double>? weightKg,
    Expression<int>? activity,
    Expression<int>? goalType,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kcal != null) 'kcal': kcal,
      if (protein != null) 'protein': protein,
      if (carbs != null) 'carbs': carbs,
      if (fat != null) 'fat': fat,
      if (sex != null) 'sex': sex,
      if (age != null) 'age': age,
      if (heightCm != null) 'height_cm': heightCm,
      if (weightKg != null) 'weight_kg': weightKg,
      if (activity != null) 'activity': activity,
      if (goalType != null) 'goal_type': goalType,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UserGoalCompanion copyWith({
    Value<int>? id,
    Value<int>? kcal,
    Value<double?>? protein,
    Value<double?>? carbs,
    Value<double?>? fat,
    Value<Sex?>? sex,
    Value<int?>? age,
    Value<double?>? heightCm,
    Value<double?>? weightKg,
    Value<ActivityLevel?>? activity,
    Value<GoalType?>? goalType,
    Value<DateTime>? updatedAt,
  }) {
    return UserGoalCompanion(
      id: id ?? this.id,
      kcal: kcal ?? this.kcal,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      sex: sex ?? this.sex,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      activity: activity ?? this.activity,
      goalType: goalType ?? this.goalType,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kcal.present) {
      map['kcal'] = Variable<int>(kcal.value);
    }
    if (protein.present) {
      map['protein'] = Variable<double>(protein.value);
    }
    if (carbs.present) {
      map['carbs'] = Variable<double>(carbs.value);
    }
    if (fat.present) {
      map['fat'] = Variable<double>(fat.value);
    }
    if (sex.present) {
      map['sex'] = Variable<int>(
        $UserGoalTable.$convertersexn.toSql(sex.value),
      );
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (activity.present) {
      map['activity'] = Variable<int>(
        $UserGoalTable.$converteractivityn.toSql(activity.value),
      );
    }
    if (goalType.present) {
      map['goal_type'] = Variable<int>(
        $UserGoalTable.$convertergoalTypen.toSql(goalType.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserGoalCompanion(')
          ..write('id: $id, ')
          ..write('kcal: $kcal, ')
          ..write('protein: $protein, ')
          ..write('carbs: $carbs, ')
          ..write('fat: $fat, ')
          ..write('sex: $sex, ')
          ..write('age: $age, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg, ')
          ..write('activity: $activity, ')
          ..write('goalType: $goalType, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FoodsTable foods = $FoodsTable(this);
  late final $MealSlotsTable mealSlots = $MealSlotsTable(this);
  late final $DiaryEntriesTable diaryEntries = $DiaryEntriesTable(this);
  late final $UserGoalTable userGoal = $UserGoalTable(this);
  late final Index foodsSourceExternalId = Index(
    'foods_source_external_id',
    'CREATE UNIQUE INDEX foods_source_external_id ON foods (source, external_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    foods,
    mealSlots,
    diaryEntries,
    userGoal,
    foodsSourceExternalId,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'foods',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('diary_entries', kind: UpdateKind.update)],
    ),
  ]);
}

typedef $$FoodsTableCreateCompanionBuilder = FoodsCompanion Function({
  Value<int> id,
  required FoodSource source,
  Value<String?> barcode,
  Value<String?> externalId,
  required String name,
  Value<String?> brand,
  Value<String?> quantityLabel,
  Value<bool> isLiquid,
  Value<double?> servingSize,
  Value<String?> servingLabel,
  Value<double?> kcal,
  Value<double?> fat,
  Value<double?> saturatedFat,
  Value<double?> carbs,
  Value<double?> sugars,
  Value<double?> fibre,
  Value<double?> protein,
  Value<double?> salt,
  Value<String?> nutriScore,
  Value<int?> novaGroup,
  Value<String?> categories,
  Value<String?> imageUrl,
  Value<double?> completeness,
  Value<bool> isFavourite,
  Value<DateTime?> lastUsedAt,
  Value<DateTime?> lastViewedAt,
  Value<DateTime?> fetchedAt,
  required DateTime createdAt,
});
typedef $$FoodsTableUpdateCompanionBuilder = FoodsCompanion Function({
  Value<int> id,
  Value<FoodSource> source,
  Value<String?> barcode,
  Value<String?> externalId,
  Value<String> name,
  Value<String?> brand,
  Value<String?> quantityLabel,
  Value<bool> isLiquid,
  Value<double?> servingSize,
  Value<String?> servingLabel,
  Value<double?> kcal,
  Value<double?> fat,
  Value<double?> saturatedFat,
  Value<double?> carbs,
  Value<double?> sugars,
  Value<double?> fibre,
  Value<double?> protein,
  Value<double?> salt,
  Value<String?> nutriScore,
  Value<int?> novaGroup,
  Value<String?> categories,
  Value<String?> imageUrl,
  Value<double?> completeness,
  Value<bool> isFavourite,
  Value<DateTime?> lastUsedAt,
  Value<DateTime?> lastViewedAt,
  Value<DateTime?> fetchedAt,
  Value<DateTime> createdAt,
});

final class $$FoodsTableReferences
    extends BaseReferences<_$AppDatabase, $FoodsTable, Food> {
  $$FoodsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DiaryEntriesTable, List<DiaryEntry>>
  _diaryEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.diaryEntries,
    aliasName: 'foods__id__diary_entries__food_id',
  );

  $$DiaryEntriesTableProcessedTableManager get diaryEntriesRefs {
    final manager = $$DiaryEntriesTableTableManager(
      $_db,
      $_db.diaryEntries,
    ).filter((f) => f.foodId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_diaryEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FoodsTableFilterComposer extends Composer<_$AppDatabase, $FoodsTable> {
  $$FoodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<FoodSource, FoodSource, int> get source =>
      $composableBuilder(
        column: $table.source,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quantityLabel => $composableBuilder(
    column: $table.quantityLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLiquid => $composableBuilder(
    column: $table.isLiquid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get servingSize => $composableBuilder(
    column: $table.servingSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get servingLabel => $composableBuilder(
    column: $table.servingLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get saturatedFat => $composableBuilder(
    column: $table.saturatedFat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbs => $composableBuilder(
    column: $table.carbs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sugars => $composableBuilder(
    column: $table.sugars,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fibre => $composableBuilder(
    column: $table.fibre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get salt => $composableBuilder(
    column: $table.salt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nutriScore => $composableBuilder(
    column: $table.nutriScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get novaGroup => $composableBuilder(
    column: $table.novaGroup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categories => $composableBuilder(
    column: $table.categories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get completeness => $composableBuilder(
    column: $table.completeness,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavourite => $composableBuilder(
    column: $table.isFavourite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastViewedAt => $composableBuilder(
    column: $table.lastViewedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> diaryEntriesRefs(
    Expression<bool> Function($$DiaryEntriesTableFilterComposer f) f,
  ) {
    final $$DiaryEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.diaryEntries,
      getReferencedColumn: (t) => t.foodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DiaryEntriesTableFilterComposer(
            $db: $db,
            $table: $db.diaryEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FoodsTableOrderingComposer
    extends Composer<_$AppDatabase, $FoodsTable> {
  $$FoodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quantityLabel => $composableBuilder(
    column: $table.quantityLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLiquid => $composableBuilder(
    column: $table.isLiquid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get servingSize => $composableBuilder(
    column: $table.servingSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get servingLabel => $composableBuilder(
    column: $table.servingLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get saturatedFat => $composableBuilder(
    column: $table.saturatedFat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbs => $composableBuilder(
    column: $table.carbs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sugars => $composableBuilder(
    column: $table.sugars,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fibre => $composableBuilder(
    column: $table.fibre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get salt => $composableBuilder(
    column: $table.salt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nutriScore => $composableBuilder(
    column: $table.nutriScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get novaGroup => $composableBuilder(
    column: $table.novaGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categories => $composableBuilder(
    column: $table.categories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get completeness => $composableBuilder(
    column: $table.completeness,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavourite => $composableBuilder(
    column: $table.isFavourite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastViewedAt => $composableBuilder(
    column: $table.lastViewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FoodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoodsTable> {
  $$FoodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<FoodSource, int> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get quantityLabel => $composableBuilder(
    column: $table.quantityLabel,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isLiquid =>
      $composableBuilder(column: $table.isLiquid, builder: (column) => column);

  GeneratedColumn<double> get servingSize => $composableBuilder(
    column: $table.servingSize,
    builder: (column) => column,
  );

  GeneratedColumn<String> get servingLabel => $composableBuilder(
    column: $table.servingLabel,
    builder: (column) => column,
  );

  GeneratedColumn<double> get kcal =>
      $composableBuilder(column: $table.kcal, builder: (column) => column);

  GeneratedColumn<double> get fat =>
      $composableBuilder(column: $table.fat, builder: (column) => column);

  GeneratedColumn<double> get saturatedFat => $composableBuilder(
    column: $table.saturatedFat,
    builder: (column) => column,
  );

  GeneratedColumn<double> get carbs =>
      $composableBuilder(column: $table.carbs, builder: (column) => column);

  GeneratedColumn<double> get sugars =>
      $composableBuilder(column: $table.sugars, builder: (column) => column);

  GeneratedColumn<double> get fibre =>
      $composableBuilder(column: $table.fibre, builder: (column) => column);

  GeneratedColumn<double> get protein =>
      $composableBuilder(column: $table.protein, builder: (column) => column);

  GeneratedColumn<double> get salt =>
      $composableBuilder(column: $table.salt, builder: (column) => column);

  GeneratedColumn<String> get nutriScore => $composableBuilder(
    column: $table.nutriScore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get novaGroup =>
      $composableBuilder(column: $table.novaGroup, builder: (column) => column);

  GeneratedColumn<String> get categories => $composableBuilder(
    column: $table.categories,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<double> get completeness => $composableBuilder(
    column: $table.completeness,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFavourite => $composableBuilder(
    column: $table.isFavourite,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastViewedAt => $composableBuilder(
    column: $table.lastViewedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> diaryEntriesRefs<T extends Object>(
    Expression<T> Function($$DiaryEntriesTableAnnotationComposer a) f,
  ) {
    final $$DiaryEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.diaryEntries,
      getReferencedColumn: (t) => t.foodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DiaryEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.diaryEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FoodsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FoodsTable,
          Food,
          $$FoodsTableFilterComposer,
          $$FoodsTableOrderingComposer,
          $$FoodsTableAnnotationComposer,
          $$FoodsTableCreateCompanionBuilder,
          $$FoodsTableUpdateCompanionBuilder,
          (Food, $$FoodsTableReferences),
          Food,
          PrefetchHooks Function({bool diaryEntriesRefs})
        > {
  $$FoodsTableTableManager(_$AppDatabase db, $FoodsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<FoodSource> source = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<String?> externalId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<String?> quantityLabel = const Value.absent(),
                Value<bool> isLiquid = const Value.absent(),
                Value<double?> servingSize = const Value.absent(),
                Value<String?> servingLabel = const Value.absent(),
                Value<double?> kcal = const Value.absent(),
                Value<double?> fat = const Value.absent(),
                Value<double?> saturatedFat = const Value.absent(),
                Value<double?> carbs = const Value.absent(),
                Value<double?> sugars = const Value.absent(),
                Value<double?> fibre = const Value.absent(),
                Value<double?> protein = const Value.absent(),
                Value<double?> salt = const Value.absent(),
                Value<String?> nutriScore = const Value.absent(),
                Value<int?> novaGroup = const Value.absent(),
                Value<String?> categories = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<double?> completeness = const Value.absent(),
                Value<bool> isFavourite = const Value.absent(),
                Value<DateTime?> lastUsedAt = const Value.absent(),
                Value<DateTime?> lastViewedAt = const Value.absent(),
                Value<DateTime?> fetchedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => FoodsCompanion(
                id: id,
                source: source,
                barcode: barcode,
                externalId: externalId,
                name: name,
                brand: brand,
                quantityLabel: quantityLabel,
                isLiquid: isLiquid,
                servingSize: servingSize,
                servingLabel: servingLabel,
                kcal: kcal,
                fat: fat,
                saturatedFat: saturatedFat,
                carbs: carbs,
                sugars: sugars,
                fibre: fibre,
                protein: protein,
                salt: salt,
                nutriScore: nutriScore,
                novaGroup: novaGroup,
                categories: categories,
                imageUrl: imageUrl,
                completeness: completeness,
                isFavourite: isFavourite,
                lastUsedAt: lastUsedAt,
                lastViewedAt: lastViewedAt,
                fetchedAt: fetchedAt,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required FoodSource source,
                Value<String?> barcode = const Value.absent(),
                Value<String?> externalId = const Value.absent(),
                required String name,
                Value<String?> brand = const Value.absent(),
                Value<String?> quantityLabel = const Value.absent(),
                Value<bool> isLiquid = const Value.absent(),
                Value<double?> servingSize = const Value.absent(),
                Value<String?> servingLabel = const Value.absent(),
                Value<double?> kcal = const Value.absent(),
                Value<double?> fat = const Value.absent(),
                Value<double?> saturatedFat = const Value.absent(),
                Value<double?> carbs = const Value.absent(),
                Value<double?> sugars = const Value.absent(),
                Value<double?> fibre = const Value.absent(),
                Value<double?> protein = const Value.absent(),
                Value<double?> salt = const Value.absent(),
                Value<String?> nutriScore = const Value.absent(),
                Value<int?> novaGroup = const Value.absent(),
                Value<String?> categories = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<double?> completeness = const Value.absent(),
                Value<bool> isFavourite = const Value.absent(),
                Value<DateTime?> lastUsedAt = const Value.absent(),
                Value<DateTime?> lastViewedAt = const Value.absent(),
                Value<DateTime?> fetchedAt = const Value.absent(),
                required DateTime createdAt,
              }) => FoodsCompanion.insert(
                id: id,
                source: source,
                barcode: barcode,
                externalId: externalId,
                name: name,
                brand: brand,
                quantityLabel: quantityLabel,
                isLiquid: isLiquid,
                servingSize: servingSize,
                servingLabel: servingLabel,
                kcal: kcal,
                fat: fat,
                saturatedFat: saturatedFat,
                carbs: carbs,
                sugars: sugars,
                fibre: fibre,
                protein: protein,
                salt: salt,
                nutriScore: nutriScore,
                novaGroup: novaGroup,
                categories: categories,
                imageUrl: imageUrl,
                completeness: completeness,
                isFavourite: isFavourite,
                lastUsedAt: lastUsedAt,
                lastViewedAt: lastViewedAt,
                fetchedAt: fetchedAt,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FoodsTable, Food>(table),
                  $$FoodsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({diaryEntriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (diaryEntriesRefs) db.diaryEntries],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (diaryEntriesRefs)
                    await $_getPrefetchedDataByColumns<
                      Food,
                      $FoodsTable,
                      DiaryEntry,
                      $DiaryEntriesTable
                    >(
                      currentTable: table,
                      referencedTable: $$FoodsTableReferences
                          ._diaryEntriesRefsTable(db),
                      managerFromTypedResult: (p0) => $$FoodsTableReferences(
                        db,
                        table,
                        p0,
                      ).diaryEntriesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'food_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$FoodsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FoodsTable,
      Food,
      $$FoodsTableFilterComposer,
      $$FoodsTableOrderingComposer,
      $$FoodsTableAnnotationComposer,
      $$FoodsTableCreateCompanionBuilder,
      $$FoodsTableUpdateCompanionBuilder,
      (Food, $$FoodsTableReferences),
      Food,
      PrefetchHooks Function({bool diaryEntriesRefs})
    >;
typedef $$MealSlotsTableCreateCompanionBuilder = MealSlotsCompanion Function({
  Value<int> id,
  Value<String?> builtIn,
  Value<String?> customName,
  required int position,
  Value<bool> isHidden,
  Value<int?> startMinute,
});
typedef $$MealSlotsTableUpdateCompanionBuilder = MealSlotsCompanion Function({
  Value<int> id,
  Value<String?> builtIn,
  Value<String?> customName,
  Value<int> position,
  Value<bool> isHidden,
  Value<int?> startMinute,
});

final class $$MealSlotsTableReferences
    extends BaseReferences<_$AppDatabase, $MealSlotsTable, MealSlot> {
  $$MealSlotsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DiaryEntriesTable, List<DiaryEntry>>
  _diaryEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.diaryEntries,
    aliasName: 'meal_slots__id__diary_entries__meal_slot_id',
  );

  $$DiaryEntriesTableProcessedTableManager get diaryEntriesRefs {
    final manager = $$DiaryEntriesTableTableManager(
      $_db,
      $_db.diaryEntries,
    ).filter((f) => f.mealSlotId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_diaryEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MealSlotsTableFilterComposer
    extends Composer<_$AppDatabase, $MealSlotsTable> {
  $$MealSlotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get builtIn => $composableBuilder(
    column: $table.builtIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isHidden => $composableBuilder(
    column: $table.isHidden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> diaryEntriesRefs(
    Expression<bool> Function($$DiaryEntriesTableFilterComposer f) f,
  ) {
    final $$DiaryEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.diaryEntries,
      getReferencedColumn: (t) => t.mealSlotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DiaryEntriesTableFilterComposer(
            $db: $db,
            $table: $db.diaryEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MealSlotsTableOrderingComposer
    extends Composer<_$AppDatabase, $MealSlotsTable> {
  $$MealSlotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get builtIn => $composableBuilder(
    column: $table.builtIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isHidden => $composableBuilder(
    column: $table.isHidden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MealSlotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MealSlotsTable> {
  $$MealSlotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get builtIn =>
      $composableBuilder(column: $table.builtIn, builder: (column) => column);

  GeneratedColumn<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<bool> get isHidden =>
      $composableBuilder(column: $table.isHidden, builder: (column) => column);

  GeneratedColumn<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => column,
  );

  Expression<T> diaryEntriesRefs<T extends Object>(
    Expression<T> Function($$DiaryEntriesTableAnnotationComposer a) f,
  ) {
    final $$DiaryEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.diaryEntries,
      getReferencedColumn: (t) => t.mealSlotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DiaryEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.diaryEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MealSlotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MealSlotsTable,
          MealSlot,
          $$MealSlotsTableFilterComposer,
          $$MealSlotsTableOrderingComposer,
          $$MealSlotsTableAnnotationComposer,
          $$MealSlotsTableCreateCompanionBuilder,
          $$MealSlotsTableUpdateCompanionBuilder,
          (MealSlot, $$MealSlotsTableReferences),
          MealSlot,
          PrefetchHooks Function({bool diaryEntriesRefs})
        > {
  $$MealSlotsTableTableManager(_$AppDatabase db, $MealSlotsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MealSlotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MealSlotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MealSlotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> builtIn = const Value.absent(),
                Value<String?> customName = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<bool> isHidden = const Value.absent(),
                Value<int?> startMinute = const Value.absent(),
              }) => MealSlotsCompanion(
                id: id,
                builtIn: builtIn,
                customName: customName,
                position: position,
                isHidden: isHidden,
                startMinute: startMinute,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> builtIn = const Value.absent(),
                Value<String?> customName = const Value.absent(),
                required int position,
                Value<bool> isHidden = const Value.absent(),
                Value<int?> startMinute = const Value.absent(),
              }) => MealSlotsCompanion.insert(
                id: id,
                builtIn: builtIn,
                customName: customName,
                position: position,
                isHidden: isHidden,
                startMinute: startMinute,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MealSlotsTable, MealSlot>(table),
                  $$MealSlotsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({diaryEntriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (diaryEntriesRefs) db.diaryEntries],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (diaryEntriesRefs)
                    await $_getPrefetchedDataByColumns<
                      MealSlot,
                      $MealSlotsTable,
                      DiaryEntry,
                      $DiaryEntriesTable
                    >(
                      currentTable: table,
                      referencedTable: $$MealSlotsTableReferences
                          ._diaryEntriesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$MealSlotsTableReferences(
                            db,
                            table,
                            p0,
                          ).diaryEntriesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'meal_slot_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MealSlotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MealSlotsTable,
      MealSlot,
      $$MealSlotsTableFilterComposer,
      $$MealSlotsTableOrderingComposer,
      $$MealSlotsTableAnnotationComposer,
      $$MealSlotsTableCreateCompanionBuilder,
      $$MealSlotsTableUpdateCompanionBuilder,
      (MealSlot, $$MealSlotsTableReferences),
      MealSlot,
      PrefetchHooks Function({bool diaryEntriesRefs})
    >;
typedef $$DiaryEntriesTableCreateCompanionBuilder =
    DiaryEntriesCompanion Function({
      Value<int> id,
      required String day,
      required int mealSlotId,
      Value<int?> foodId,
      required String name,
      Value<String?> brand,
      required double amount,
      Value<bool> isLiquid,
      Value<String?> servingLabel,
      Value<double?> kcal,
      Value<double?> fat,
      Value<double?> saturatedFat,
      Value<double?> carbs,
      Value<double?> sugars,
      Value<double?> fibre,
      Value<double?> protein,
      Value<double?> salt,
      required DateTime createdAt,
    });
typedef $$DiaryEntriesTableUpdateCompanionBuilder =
    DiaryEntriesCompanion Function({
      Value<int> id,
      Value<String> day,
      Value<int> mealSlotId,
      Value<int?> foodId,
      Value<String> name,
      Value<String?> brand,
      Value<double> amount,
      Value<bool> isLiquid,
      Value<String?> servingLabel,
      Value<double?> kcal,
      Value<double?> fat,
      Value<double?> saturatedFat,
      Value<double?> carbs,
      Value<double?> sugars,
      Value<double?> fibre,
      Value<double?> protein,
      Value<double?> salt,
      Value<DateTime> createdAt,
    });

final class $$DiaryEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $DiaryEntriesTable, DiaryEntry> {
  $$DiaryEntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MealSlotsTable _mealSlotIdTable(_$AppDatabase db) =>
      db.mealSlots.createAlias('diary_entries__meal_slot_id__meal_slots__id');

  $$MealSlotsTableProcessedTableManager get mealSlotId {
    final $_column = $_itemColumn<int>('meal_slot_id')!;

    final manager = $$MealSlotsTableTableManager(
      $_db,
      $_db.mealSlots,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mealSlotIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $FoodsTable _foodIdTable(_$AppDatabase db) =>
      db.foods.createAlias('diary_entries__food_id__foods__id');

  $$FoodsTableProcessedTableManager? get foodId {
    final $_column = $_itemColumn<int>('food_id');
    if ($_column == null) return null;
    final manager = $$FoodsTableTableManager(
      $_db,
      $_db.foods,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_foodIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DiaryEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $DiaryEntriesTable> {
  $$DiaryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLiquid => $composableBuilder(
    column: $table.isLiquid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get servingLabel => $composableBuilder(
    column: $table.servingLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get saturatedFat => $composableBuilder(
    column: $table.saturatedFat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbs => $composableBuilder(
    column: $table.carbs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sugars => $composableBuilder(
    column: $table.sugars,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fibre => $composableBuilder(
    column: $table.fibre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get salt => $composableBuilder(
    column: $table.salt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MealSlotsTableFilterComposer get mealSlotId {
    final $$MealSlotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mealSlotId,
      referencedTable: $db.mealSlots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MealSlotsTableFilterComposer(
            $db: $db,
            $table: $db.mealSlots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FoodsTableFilterComposer get foodId {
    final $$FoodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.foodId,
      referencedTable: $db.foods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodsTableFilterComposer(
            $db: $db,
            $table: $db.foods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DiaryEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $DiaryEntriesTable> {
  $$DiaryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLiquid => $composableBuilder(
    column: $table.isLiquid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get servingLabel => $composableBuilder(
    column: $table.servingLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get saturatedFat => $composableBuilder(
    column: $table.saturatedFat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbs => $composableBuilder(
    column: $table.carbs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sugars => $composableBuilder(
    column: $table.sugars,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fibre => $composableBuilder(
    column: $table.fibre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get salt => $composableBuilder(
    column: $table.salt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MealSlotsTableOrderingComposer get mealSlotId {
    final $$MealSlotsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mealSlotId,
      referencedTable: $db.mealSlots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MealSlotsTableOrderingComposer(
            $db: $db,
            $table: $db.mealSlots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FoodsTableOrderingComposer get foodId {
    final $$FoodsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.foodId,
      referencedTable: $db.foods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodsTableOrderingComposer(
            $db: $db,
            $table: $db.foods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DiaryEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DiaryEntriesTable> {
  $$DiaryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<bool> get isLiquid =>
      $composableBuilder(column: $table.isLiquid, builder: (column) => column);

  GeneratedColumn<String> get servingLabel => $composableBuilder(
    column: $table.servingLabel,
    builder: (column) => column,
  );

  GeneratedColumn<double> get kcal =>
      $composableBuilder(column: $table.kcal, builder: (column) => column);

  GeneratedColumn<double> get fat =>
      $composableBuilder(column: $table.fat, builder: (column) => column);

  GeneratedColumn<double> get saturatedFat => $composableBuilder(
    column: $table.saturatedFat,
    builder: (column) => column,
  );

  GeneratedColumn<double> get carbs =>
      $composableBuilder(column: $table.carbs, builder: (column) => column);

  GeneratedColumn<double> get sugars =>
      $composableBuilder(column: $table.sugars, builder: (column) => column);

  GeneratedColumn<double> get fibre =>
      $composableBuilder(column: $table.fibre, builder: (column) => column);

  GeneratedColumn<double> get protein =>
      $composableBuilder(column: $table.protein, builder: (column) => column);

  GeneratedColumn<double> get salt =>
      $composableBuilder(column: $table.salt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$MealSlotsTableAnnotationComposer get mealSlotId {
    final $$MealSlotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mealSlotId,
      referencedTable: $db.mealSlots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MealSlotsTableAnnotationComposer(
            $db: $db,
            $table: $db.mealSlots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FoodsTableAnnotationComposer get foodId {
    final $$FoodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.foodId,
      referencedTable: $db.foods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodsTableAnnotationComposer(
            $db: $db,
            $table: $db.foods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DiaryEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DiaryEntriesTable,
          DiaryEntry,
          $$DiaryEntriesTableFilterComposer,
          $$DiaryEntriesTableOrderingComposer,
          $$DiaryEntriesTableAnnotationComposer,
          $$DiaryEntriesTableCreateCompanionBuilder,
          $$DiaryEntriesTableUpdateCompanionBuilder,
          (DiaryEntry, $$DiaryEntriesTableReferences),
          DiaryEntry,
          PrefetchHooks Function({bool mealSlotId, bool foodId})
        > {
  $$DiaryEntriesTableTableManager(_$AppDatabase db, $DiaryEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DiaryEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DiaryEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DiaryEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<int> mealSlotId = const Value.absent(),
                Value<int?> foodId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<bool> isLiquid = const Value.absent(),
                Value<String?> servingLabel = const Value.absent(),
                Value<double?> kcal = const Value.absent(),
                Value<double?> fat = const Value.absent(),
                Value<double?> saturatedFat = const Value.absent(),
                Value<double?> carbs = const Value.absent(),
                Value<double?> sugars = const Value.absent(),
                Value<double?> fibre = const Value.absent(),
                Value<double?> protein = const Value.absent(),
                Value<double?> salt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => DiaryEntriesCompanion(
                id: id,
                day: day,
                mealSlotId: mealSlotId,
                foodId: foodId,
                name: name,
                brand: brand,
                amount: amount,
                isLiquid: isLiquid,
                servingLabel: servingLabel,
                kcal: kcal,
                fat: fat,
                saturatedFat: saturatedFat,
                carbs: carbs,
                sugars: sugars,
                fibre: fibre,
                protein: protein,
                salt: salt,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String day,
                required int mealSlotId,
                Value<int?> foodId = const Value.absent(),
                required String name,
                Value<String?> brand = const Value.absent(),
                required double amount,
                Value<bool> isLiquid = const Value.absent(),
                Value<String?> servingLabel = const Value.absent(),
                Value<double?> kcal = const Value.absent(),
                Value<double?> fat = const Value.absent(),
                Value<double?> saturatedFat = const Value.absent(),
                Value<double?> carbs = const Value.absent(),
                Value<double?> sugars = const Value.absent(),
                Value<double?> fibre = const Value.absent(),
                Value<double?> protein = const Value.absent(),
                Value<double?> salt = const Value.absent(),
                required DateTime createdAt,
              }) => DiaryEntriesCompanion.insert(
                id: id,
                day: day,
                mealSlotId: mealSlotId,
                foodId: foodId,
                name: name,
                brand: brand,
                amount: amount,
                isLiquid: isLiquid,
                servingLabel: servingLabel,
                kcal: kcal,
                fat: fat,
                saturatedFat: saturatedFat,
                carbs: carbs,
                sugars: sugars,
                fibre: fibre,
                protein: protein,
                salt: salt,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DiaryEntriesTable, DiaryEntry>(table),
                  $$DiaryEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({mealSlotId = false, foodId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (mealSlotId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.mealSlotId,
                        referencedTable: $$DiaryEntriesTableReferences
                            ._mealSlotIdTable(db),
                        referencedColumn: $$DiaryEntriesTableReferences
                            ._mealSlotIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (foodId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.foodId,
                        referencedTable: $$DiaryEntriesTableReferences
                            ._foodIdTable(db),
                        referencedColumn: $$DiaryEntriesTableReferences
                            ._foodIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DiaryEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DiaryEntriesTable,
      DiaryEntry,
      $$DiaryEntriesTableFilterComposer,
      $$DiaryEntriesTableOrderingComposer,
      $$DiaryEntriesTableAnnotationComposer,
      $$DiaryEntriesTableCreateCompanionBuilder,
      $$DiaryEntriesTableUpdateCompanionBuilder,
      (DiaryEntry, $$DiaryEntriesTableReferences),
      DiaryEntry,
      PrefetchHooks Function({bool mealSlotId, bool foodId})
    >;
typedef $$UserGoalTableCreateCompanionBuilder = UserGoalCompanion Function({
  Value<int> id,
  required int kcal,
  Value<double?> protein,
  Value<double?> carbs,
  Value<double?> fat,
  Value<Sex?> sex,
  Value<int?> age,
  Value<double?> heightCm,
  Value<double?> weightKg,
  Value<ActivityLevel?> activity,
  Value<GoalType?> goalType,
  required DateTime updatedAt,
});
typedef $$UserGoalTableUpdateCompanionBuilder = UserGoalCompanion Function({
  Value<int> id,
  Value<int> kcal,
  Value<double?> protein,
  Value<double?> carbs,
  Value<double?> fat,
  Value<Sex?> sex,
  Value<int?> age,
  Value<double?> heightCm,
  Value<double?> weightKg,
  Value<ActivityLevel?> activity,
  Value<GoalType?> goalType,
  Value<DateTime> updatedAt,
});

class $$UserGoalTableFilterComposer
    extends Composer<_$AppDatabase, $UserGoalTable> {
  $$UserGoalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbs => $composableBuilder(
    column: $table.carbs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Sex?, Sex, int> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ActivityLevel?, ActivityLevel, int>
  get activity => $composableBuilder(
    column: $table.activity,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<GoalType?, GoalType, int> get goalType =>
      $composableBuilder(
        column: $table.goalType,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserGoalTableOrderingComposer
    extends Composer<_$AppDatabase, $UserGoalTable> {
  $$UserGoalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbs => $composableBuilder(
    column: $table.carbs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get activity => $composableBuilder(
    column: $table.activity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get goalType => $composableBuilder(
    column: $table.goalType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserGoalTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserGoalTable> {
  $$UserGoalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get kcal =>
      $composableBuilder(column: $table.kcal, builder: (column) => column);

  GeneratedColumn<double> get protein =>
      $composableBuilder(column: $table.protein, builder: (column) => column);

  GeneratedColumn<double> get carbs =>
      $composableBuilder(column: $table.carbs, builder: (column) => column);

  GeneratedColumn<double> get fat =>
      $composableBuilder(column: $table.fat, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Sex?, int> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ActivityLevel?, int> get activity =>
      $composableBuilder(column: $table.activity, builder: (column) => column);

  GeneratedColumnWithTypeConverter<GoalType?, int> get goalType =>
      $composableBuilder(column: $table.goalType, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserGoalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserGoalTable,
          UserGoalRow,
          $$UserGoalTableFilterComposer,
          $$UserGoalTableOrderingComposer,
          $$UserGoalTableAnnotationComposer,
          $$UserGoalTableCreateCompanionBuilder,
          $$UserGoalTableUpdateCompanionBuilder,
          (
            UserGoalRow,
            BaseReferences<_$AppDatabase, $UserGoalTable, UserGoalRow>,
          ),
          UserGoalRow,
          PrefetchHooks Function()
        > {
  $$UserGoalTableTableManager(_$AppDatabase db, $UserGoalTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserGoalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserGoalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserGoalTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> kcal = const Value.absent(),
                Value<double?> protein = const Value.absent(),
                Value<double?> carbs = const Value.absent(),
                Value<double?> fat = const Value.absent(),
                Value<Sex?> sex = const Value.absent(),
                Value<int?> age = const Value.absent(),
                Value<double?> heightCm = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<ActivityLevel?> activity = const Value.absent(),
                Value<GoalType?> goalType = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UserGoalCompanion(
                id: id,
                kcal: kcal,
                protein: protein,
                carbs: carbs,
                fat: fat,
                sex: sex,
                age: age,
                heightCm: heightCm,
                weightKg: weightKg,
                activity: activity,
                goalType: goalType,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int kcal,
                Value<double?> protein = const Value.absent(),
                Value<double?> carbs = const Value.absent(),
                Value<double?> fat = const Value.absent(),
                Value<Sex?> sex = const Value.absent(),
                Value<int?> age = const Value.absent(),
                Value<double?> heightCm = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<ActivityLevel?> activity = const Value.absent(),
                Value<GoalType?> goalType = const Value.absent(),
                required DateTime updatedAt,
              }) => UserGoalCompanion.insert(
                id: id,
                kcal: kcal,
                protein: protein,
                carbs: carbs,
                fat: fat,
                sex: sex,
                age: age,
                heightCm: heightCm,
                weightKg: weightKg,
                activity: activity,
                goalType: goalType,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UserGoalTable, UserGoalRow>(table),
                  BaseReferences<_$AppDatabase, $UserGoalTable, UserGoalRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserGoalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserGoalTable,
      UserGoalRow,
      $$UserGoalTableFilterComposer,
      $$UserGoalTableOrderingComposer,
      $$UserGoalTableAnnotationComposer,
      $$UserGoalTableCreateCompanionBuilder,
      $$UserGoalTableUpdateCompanionBuilder,
      (UserGoalRow, BaseReferences<_$AppDatabase, $UserGoalTable, UserGoalRow>),
      UserGoalRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FoodsTableTableManager get foods =>
      $$FoodsTableTableManager(_db, _db.foods);
  $$MealSlotsTableTableManager get mealSlots =>
      $$MealSlotsTableTableManager(_db, _db.mealSlots);
  $$DiaryEntriesTableTableManager get diaryEntries =>
      $$DiaryEntriesTableTableManager(_db, _db.diaryEntries);
  $$UserGoalTableTableManager get userGoal =>
      $$UserGoalTableTableManager(_db, _db.userGoal);
}
