import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/features/category/domain/models/category_model.dart';

class AiChatMessageModel {
  int? totalSize;
  int? limit;
  int? offset;
  int? conversationId;
  List<AiChatMessage>? messages;

  AiChatMessageModel({this.totalSize, this.limit, this.offset, this.conversationId, this.messages});

  AiChatMessageModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'] is String ? int.tryParse(json['limit']) : json['limit'];
    offset = json['offset'] is String ? int.tryParse(json['offset']) : json['offset'];
    conversationId = json['conversation_id'];

    final dynamic rawMessages = json['data'] ?? json['messages'];
    if (rawMessages != null) {
      messages = <AiChatMessage>[];
      rawMessages.forEach((v) {
        messages!.add(AiChatMessage.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    data['conversation_id'] = conversationId;
    if (messages != null) {
      data['data'] = messages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AiChatMessage {
  int? id;
  int? conversationId;
  String? role;
  String? content;
  String? toolName;
  AiChatMetadata? metadata;
  String? createdAt;
  String? updatedAt;
  bool sending;

  AiChatMessage({
    this.id,
    this.conversationId,
    this.role,
    this.content,
    this.toolName,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.sending = false,
  });

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';

  AiChatMessage.fromJson(Map<String, dynamic> json)
      : sending = false {
    id = json['id'];
    conversationId = json['conversation_id'];
    role = json['role'];
    content = json['content'] ?? json['message'];
    toolName = json['tool_name'];
    metadata = json['metadata'] != null && json['metadata'] is Map<String, dynamic>
        ? AiChatMetadata.fromJson(json['metadata'])
        : null;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['conversation_id'] = conversationId;
    data['role'] = role;
    data['content'] = content;
    data['tool_name'] = toolName;
    if (metadata != null) {
      data['metadata'] = metadata!.toJson();
    }
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class AiChatMetadata {
  List<Product>? products;
  List<Restaurant>? restaurants;
  List<CategoryModel>? categories;
  AiChatCart? cart;
  bool? cartUpdated;

  AiChatMetadata({this.products, this.restaurants, this.categories, this.cart, this.cartUpdated});

  AiChatMetadata.fromJson(Map<String, dynamic> json) {
    cartUpdated = json['cart_updated'] is bool ? json['cart_updated'] as bool : null;

    if (json['products'] is List) {
      products = <Product>[];
      for (var v in (json['products'] as List)) {
        if (v is Map<String, dynamic>) {
          try {
            products!.add(Product.fromJson(_normalizeProductJson(v)));
          } catch (_) {}
        }
      }
    }

    // StackFood is food-only: the backend returns "restaurants", but we also
    // accept "stores" so the same 6amMart-style payload keeps working.
    final dynamic rawRestaurants = json['restaurants'] ?? json['stores'];
    if (rawRestaurants is List) {
      restaurants = <Restaurant>[];
      for (var v in rawRestaurants) {
        if (v is Map<String, dynamic>) {
          try {
            restaurants!.add(Restaurant.fromJson(_normalizeRestaurantJson(v)));
          } catch (_) {}
        }
      }
    }

    if (json['categories'] is List) {
      categories = <CategoryModel>[];
      for (var v in (json['categories'] as List)) {
        if (v is Map<String, dynamic>) {
          try {
            categories!.add(CategoryModel.fromJson(_normalizeCategoryJson(v)));
          } catch (_) {}
        }
      }
    }

    if (json['cart'] is Map<String, dynamic>) {
      try {
        cart = AiChatCart.fromJson(json['cart']);
      } catch (_) {}
    }
  }

  bool get hasProducts => products != null && products!.isNotEmpty;
  bool get hasRestaurants => restaurants != null && restaurants!.isNotEmpty;
  bool get hasCategories => categories != null && categories!.isNotEmpty;
  bool get hasCart => cart != null && cart!.stores.isNotEmpty;
  bool get isEmpty => !hasProducts && !hasRestaurants && !hasCategories && !hasCart;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    if (restaurants != null) {
      data['restaurants'] = restaurants!.map((v) => v.toJson()).toList();
    }
    if (categories != null) {
      data['categories'] = categories!.map((v) => v.toJson()).toList();
    }
    if (cart != null) {
      data['cart'] = cart!.toJson();
    }
    if (cartUpdated != null) {
      data['cart_updated'] = cartUpdated;
    }
    return data;
  }
}

class AiChatCart {
  List<AiChatCartStoreGroup> stores;
  double? grandTotal;
  int? totalItems;

  AiChatCart({required this.stores, this.grandTotal, this.totalItems});

  AiChatCart.fromJson(Map<String, dynamic> json) : stores = <AiChatCartStoreGroup>[] {
    grandTotal = (json['grand_total'] as num?)?.toDouble();
    totalItems = json['total_items'] is String ? int.tryParse(json['total_items']) : json['total_items'];

    if (json['stores'] is List) {
      for (var v in (json['stores'] as List)) {
        if (v is Map<String, dynamic>) {
          try {
            stores.add(AiChatCartStoreGroup.fromJson(v));
          } catch (_) {}
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stores'] = stores.map((v) => v.toJson()).toList();
    data['grand_total'] = grandTotal;
    data['total_items'] = totalItems;
    return data;
  }
}

class AiChatCartStoreGroup {
  int? storeId;
  String? storeName;
  List<AiChatCartItem> items;
  double? storeSubtotal;

  AiChatCartStoreGroup({this.storeId, this.storeName, required this.items, this.storeSubtotal});

  AiChatCartStoreGroup.fromJson(Map<String, dynamic> json) : items = <AiChatCartItem>[] {
    storeId = json['store_id'];
    storeName = json['store_name'];
    storeSubtotal = (json['store_subtotal'] as num?)?.toDouble();

    if (json['items'] is List) {
      for (var v in (json['items'] as List)) {
        if (v is Map<String, dynamic>) {
          try {
            items.add(AiChatCartItem.fromJson(_normalizeCartItemJson(v)));
          } catch (_) {}
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['store_id'] = storeId;
    data['store_name'] = storeName;
    data['items'] = items.map((v) => v.toJson()).toList();
    data['store_subtotal'] = storeSubtotal;
    return data;
  }
}

class AiChatCartItem {
  int? cartId;
  int? itemId;
  String? name;
  String? variation;
  String? image;
  String? imageFullUrl;
  int? quantity;
  double? unitPrice;
  double? lineTotal;

  AiChatCartItem({
    this.cartId, this.itemId, this.name, this.variation, this.image,
    this.imageFullUrl, this.quantity, this.unitPrice, this.lineTotal,
  });

  AiChatCartItem.fromJson(Map<String, dynamic> json) {
    cartId = json['cart_id'];
    itemId = json['item_id'];
    name = json['name'];
    variation = json['variation'];
    image = json['image'];
    imageFullUrl = json['image_full_url'];
    quantity = json['quantity'] is String ? int.tryParse(json['quantity']) : json['quantity'];
    unitPrice = (json['unit_price'] as num?)?.toDouble();
    lineTotal = (json['line_total'] as num?)?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cart_id'] = cartId;
    data['item_id'] = itemId;
    data['name'] = name;
    data['variation'] = variation;
    data['image'] = image;
    data['image_full_url'] = imageFullUrl;
    data['quantity'] = quantity;
    data['unit_price'] = unitPrice;
    data['line_total'] = lineTotal;
    return data;
  }
}


Map<String, dynamic> _normalizeProductJson(Map<String, dynamic> raw) {
  final Map<String, dynamic> json = Map<String, dynamic>.from(raw);

  if (json['veg'] is bool) {
    json['veg'] = (json['veg'] as bool) ? 1 : 0;
  }

  if ((json['image_full_url'] == null || json['image_full_url'].toString().isEmpty)
      && json['image'] != null && json['image'].toString().isNotEmpty) {
    json['image_full_url'] = json['image'];
  }

  // [Product.fromJson] calls `.toDouble()` on these keys WITHOUT a null guard,
  // so any missing numeric would throw and silently drop the card. Default them.
  json['price'] ??= 0;
  json['discount'] ??= 0;
  json['restaurant_discount'] ??= 0;
  json['avg_rating'] ??= 0;

  return json;
}

Map<String, dynamic> _normalizeRestaurantJson(Map<String, dynamic> raw) {
  final Map<String, dynamic> json = Map<String, dynamic>.from(raw);

  if (json['veg'] is bool) {
    json['veg'] = (json['veg'] as bool) ? 1 : 0;
  }
  if (json['non_veg'] is bool) {
    json['non_veg'] = (json['non_veg'] as bool) ? 1 : 0;
  }

  if (json['open'] == null && json['is_open'] != null) {
    json['open'] = (json['is_open'] is bool)
        ? ((json['is_open'] as bool) ? 1 : 0)
        : json['is_open'];
  }

  if (json['distance'] == null && json['distance_km'] != null) {
    json['distance'] = (json['distance_km'] as num).toDouble();
  }

  if ((json['logo_full_url'] == null || json['logo_full_url'].toString().isEmpty)
      && json['logo'] != null && json['logo'].toString().isNotEmpty) {
    json['logo_full_url'] = json['logo'];
  } else if ((json['logo_full_url'] == null || json['logo_full_url'].toString().isEmpty)
      && json['restaurant_logo'] != null && json['restaurant_logo'].toString().isNotEmpty) {
    json['logo_full_url'] = json['restaurant_logo'];
  }

  if ((json['cover_photo_full_url'] == null || json['cover_photo_full_url'].toString().isEmpty)
      && json['cover_photo'] != null && json['cover_photo'].toString().isNotEmpty) {
    json['cover_photo_full_url'] = json['cover_photo'];
  }

  // A `discount` object is parsed by the nested Discount.fromJson, which calls
  // `.toDouble()` on discount/min_purchase/max_discount WITHOUT a null guard.
  // Backfill them so a partial discount payload can't drop the whole restaurant.
  if (json['discount'] is Map) {
    final Map<String, dynamic> discount = Map<String, dynamic>.from(json['discount'] as Map);
    discount['discount'] ??= 0;
    discount['min_purchase'] ??= 0;
    discount['max_discount'] ??= 0;
    json['discount'] = discount;
  }

  return json;
}

Map<String, dynamic> _normalizeCartItemJson(Map<String, dynamic> raw) {
  final Map<String, dynamic> json = Map<String, dynamic>.from(raw);

  if ((json['image_full_url'] == null || json['image_full_url'].toString().isEmpty)
      && json['image'] != null && json['image'].toString().isNotEmpty) {
    json['image_full_url'] = json['image'];
  }

  return json;
}

Map<String, dynamic> _normalizeCategoryJson(Map<String, dynamic> raw) {
  final Map<String, dynamic> json = Map<String, dynamic>.from(raw);

  if ((json['image_full_url'] == null || json['image_full_url'].toString().isEmpty)
      && json['image'] != null && json['image'].toString().isNotEmpty) {
    json['image_full_url'] = json['image'];
  }

  return json;
}
