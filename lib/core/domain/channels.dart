class StoreChannel {
  const StoreChannel(
    this.id, {
    required this.online,
    this.androidPackage,
    this.website,
  });

  final String id;
  final bool online;
  final String? androidPackage;
  final String? website;
}

const storeChannels = <String, StoreChannel>{
  'zepto': StoreChannel(
    'zepto',
    online: true,
    androidPackage: 'com.zeptoconsumerapp',
    website: 'https://www.zeptonow.com',
  ),
  'blinkit': StoreChannel(
    'blinkit',
    online: true,
    androidPackage: 'com.grofers.customerapp',
    website: 'https://blinkit.com',
  ),
  'bigbasket': StoreChannel(
    'bigbasket',
    online: true,
    androidPackage: 'com.bigbasket.mobileapp',
    website: 'https://www.bigbasket.com',
  ),
  'amazon': StoreChannel(
    'amazon',
    online: true,
    androidPackage: 'in.amazon.mShop.android.shopping',
    website: 'https://www.amazon.in',
  ),
  'flipkart': StoreChannel(
    'flipkart',
    online: true,
    androidPackage: 'com.flipkart.android',
    website: 'https://www.flipkart.com',
  ),
  'meesho': StoreChannel(
    'meesho',
    online: true,
    androidPackage: 'com.meesho.supply',
    website: 'https://www.meesho.com',
  ),
  'offline': StoreChannel('offline', online: false),
};

const listChannels = <String, List<String>>{
  'grocery': ['zepto', 'blinkit', 'bigbasket', 'amazon', 'offline'],
  'shopping': ['amazon', 'flipkart', 'meesho', 'offline'],
};
