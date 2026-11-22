import 'dart:io';

/// Returns the first non-loopback IPv4 address on a `wlan*` interface, else any non-loopback IPv4.
Future<String?> localWifiIp() async {
  try {
    final ifaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
    for (final iface in ifaces) {
      if (!iface.name.startsWith('wlan')) continue;
      for (final addr in iface.addresses) {
        if (!addr.isLoopback) return addr.address;
      }
    }
    for (final iface in ifaces) {
      for (final addr in iface.addresses) {
        if (!addr.isLoopback) return addr.address;
      }
    }
  } on Object {
    // Ignore platform interface enumeration errors.
  }
  return null;
}

/// True when a `wlan*` interface holds at least one non-loopback IPv4 address.
Future<bool> onWifi() async {
  try {
    final ifaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
    for (final iface in ifaces) {
      if (!iface.name.startsWith('wlan')) continue;
      if (iface.addresses.any((a) => !a.isLoopback)) return true;
    }
  } on Object {
    // Ignore platform interface enumeration errors.
  }
  return false;
}
