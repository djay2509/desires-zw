import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DESIRES',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  final String myNumber = "263785438913";
  List<Map<String, dynamic>> list = [];
  List<String> favs = [];
  List<String> usedCodes = [];
  String searchWhat = "";
  String searchCity = "";
  String filter = "All";
  String countryFilter = "All Countries";
  String typeFilter = "All Types";
  bool lowData = false;
  bool isShona = false;
  bool isPremium = false;
  bool nearMeOnly = false;
  double? myLat;
  double? myLon;
  int chatCount = 0;
  String subUntil = "";

  final List<String> cats = [
    "All",
    "Electrician",
    "Tiler",
    "Plumber",
    "Builder",
    "Painter",
    "Carpenter",
    "Hair & Beauty",
    "Food",
    "Phones & Repair",
    "Clothes",
    "Cleaning",
    "Mechanic",
    "Photography",
    "Other",
  ];

  final List<String> countries = [
    "Zimbabwe",
    "South Africa",
    "Botswana",
    "Namibia",
    "Zambia",
    "Malawi",
    "Mozambique",
    "Angola",
    "Kenya",
    "Tanzania",
    "Uganda",
    "Nigeria",
    "Ghana",
    "Egypt",
    "United Kingdom",
    "United States",
    "Canada",
    "Australia",
    "Germany",
    "France",
    "Italy",
    "Spain",
    "Portugal",
    "India",
    "Pakistan",
    "China",
    "Japan",
    "Brazil",
    "Mexico",
  ];

  bool get isSubscribed {
    if (subUntil.isEmpty) {
      return false;
    }
    try {
      return DateTime.parse(subUntil).isAfter(
        DateTime.now(),
      );
    } catch (e) {
      return false;
    }
  }

  int get freeLeft {
    if (isSubscribed) {
      return 999;
    }
    int left = 2 - chatCount;
    if (left < 0) {
      return 0;
    }
    return left;
  }

  @override
  void initState() {
    super.initState();
    load();
    getLocation();
  }

  Future<void> getLocation() async {
    try {
      bool on = await Geolocator.isLocationServiceEnabled();
      if (!on) {
        return;
      }
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied) {
        return;
      }
      if (perm == LocationPermission.deniedForever) {
        return;
      }
      Position p = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        myLat = p.latitude;
        myLon = p.longitude;
      });
    } catch (e) {}
  }

  double getKm(Map b) {
    double lat = -17.8252;
    double lon = 31.0335;
    if (b["lat"] != null) {
      lat = (b["lat"] as num).toDouble();
    }
    if (b["lon"] != null) {
      lon = (b["lon"] as num).toDouble();
    }
    if (myLat == null || myLon == null) {
      String city = (b["city"] ?? "").toString();
      city = city.toLowerCase();
      if (city == "harare") {
        return 1.2;
      }
      if (city == "mutare") {
        return 256.0;
      }
      if (city == "gweru") {
        return 164.0;
      }
      return 8.0;
    }
    double d = Geolocator.distanceBetween(
      myLat!,
      myLon!,
      lat,
      lon,
    );
    d = d / 1000;
    return double.parse(d.toStringAsFixed(1));
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    isPremium = prefs.getBool("desires_premium") ?? false;
    usedCodes = prefs.getStringList("desires_used") ?? [];
    favs = prefs.getStringList("desires_favs") ?? [];
    chatCount = prefs.getInt("desires_chat") ?? 0;
    subUntil = prefs.getString("desires_sub") ?? "";
    final s = prefs.getString("desires_v3");
    if (s != null) {
      List decoded = jsonDecode(s);
      setState(() {
        list = List<Map<String, dynamic>>.from(decoded);
      });
    } else {
      setState(() {
        list = [
          {
            "name": "Denny",
            "city": "Harare",
            "country": "Zimbabwe",
            "phone": "263785438913",
            "desc": "Electrician - wiring, lights, sockets.",
            "cat": "Electrician",
            "type": "worker",
            "ratings": [5, 5, 4],
            "image": "",
            "price": "\$20 per job",
            "verified": true,
            "reported": false,
            "boosted": true,
            "urgent": false,
            "lat": -17.8252,
            "lon": 31.0335,
          },
          {
            "name": "Mai Chipo",
            "city": "Mutare",
            "country": "Zimbabwe",
            "phone": "263772345678",
            "desc": "Fresh sadza, chicken, vegetables.",
            "cat": "Food",
            "type": "seller",
            "ratings": [5, 5, 5],
            "image": "",
            "price": "\$5 per plate",
            "verified": false,
            "reported": false,
            "boosted": false,
            "urgent": false,
            "lat": -18.9707,
            "lon": 32.65,
          },
          {
            "name": "Tawanda",
            "city": "Gweru",
            "country": "Zimbabwe",
            "phone": "263773456789",
            "desc": "Tiler - bathrooms, kitchens, floors.",
            "cat": "Tiler",
            "type": "worker",
            "ratings": [5, 4],
            "image": "",
            "price": "\$15 per sqm",
            "verified": false,
            "reported": false,
            "boosted": false,
            "urgent": false,
            "lat": -19.45,
            "lon": 29.82,
          },
          {
            "name": "Baba Tech",
            "city": "Kwekwe",
            "country": "Zimbabwe",
            "phone": "263774567890",
            "desc": "Phone flashing, screens, batteries.",
            "cat": "Phones & Repair",
            "type": "seller",
            "ratings": [5, 5],
            "image": "",
            "price": "Flashing from \$5",
            "verified": true,
            "reported": false,
            "boosted": false,
            "urgent": false,
            "lat": -18.92,
            "lon": 29.81,
          },
        ];
      });
      save();
    }
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("desires_v3", jsonEncode(list));
    await prefs.setBool("desires_premium", isPremium);
    await prefs.setStringList("desires_used", usedCodes);
    await prefs.setStringList("desires_favs", favs);
    await prefs.setInt("desires_chat", chatCount);
    await prefs.setString("desires_sub", subUntil);
  }

  double avgRating(Map b) {
    var r = b["ratings"] as List?;
    if (r == null || r.isEmpty) {
      return 5.0;
    }
    double sum = 0;
    for (var v in r) {
      sum += (v as num).toDouble();
    }
    return sum / r.length;
  }

  Widget buildImage(String s, double h) {
    if (s.isEmpty) {
      return const SizedBox();
    }
    try {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          base64Decode(s),
          height: h,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    } catch (e) {
      return const SizedBox();
    }
  }

  void showPay(
    String item,
    String price,
    VoidCallback onPaid,
  ) {
    showDialog(
      context: context,
      builder: (d) {
        return AlertDialog(
          title: Text("Pay for $item - $price"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Where are you? Choose how to pay:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(d);
                    showPayDetails(
                      item,
                      price,
                      "EcoCash",
                      onPaid,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    "I AM IN ZIMBABWE - EcoCash",
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(d);
                    showPayDetails(
                      item,
                      price,
                      "Mukuru",
                      onPaid,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    "I AM IN SA / BOTSWANA - Mukuru",
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(d);
                    showPayDetails(
                      item,
                      price,
                      " 【entity-PayPal¦canonical_name=PayPal】",
                      onPaid,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    "I AM IN UK / USA - 【entity-PayPal¦canonical_name=PayPal】",
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(d);
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void showPayDetails(
    String item,
    String price,
    String method,
    VoidCallback onPaid,
  ) {
    String txCode = "";
    String title = "";
    String step1 = "";
    String hint = "";
    if (method == "EcoCash") {
      title = "Pay with EcoCash - $price";
      step1 = "Send $price via EcoCash to:\n"
          "Number: +263785438913\n"
          "Name: DESIRES";
      hint = "EcoCash Code e.g. MP240123.4567";
    } else if (method == "Mukuru") {
      title = "Pay with Mukuru - $price";
      step1 = "1. Open Mukuru App\n"
          "2. Send $price to Zimbabwe\n"
          "3. Phone: +263785438913\n"
          "4. Name: DESIRES\n"
          "For SA: R20 = \$1, R40 = \$2";
      hint = "Mukuru Code e.g. MUKU123456";
    } else {
      title = "Pay with 【entity-PayPal¦canonical_name=PayPal】 - $price";
      step1 = "1. WhatsApp DESIRES: +263785438913\n"
          "2. We send you 【entity-PayPal¦canonical_name=PayPal】 link\n"
          "3. Pay $price via 【entity-PayPal¦canonical_name=PayPal】\n"
          "4. Enter 【entity-PayPal¦canonical_name=PayPal】 Code below";
      hint = " 【entity-PayPal¦canonical_name=PayPal】 Transaction ID";
    }

    showDialog(
      context: context,
      builder: (d) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "STEP 1: Pay",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(step1),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    Clipboard.setData(
                      const ClipboardData(
                        text: "263785438913",
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Number copied: +263785438913",
                        ),
                      ),
                    );
                  },
                  child: const Text("Copy Number"),
                ),
                const SizedBox(height: 12),
                const Text(
                  "STEP 2: Enter Code",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  hint,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                TextField(
                  decoration: InputDecoration(
                    labelText: "$method Code",
                  ),
                  onChanged: (v) {
                    txCode = v.trim();
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(d);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                String code = txCode.trim().toUpperCase();
                if (code.length < 5) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Enter your REAL $method Code",
                      ),
                    ),
                  );
                  return;
                }
                if (usedCodes.contains(code)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "This code was already used!",
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                usedCodes.add(code);
                Navigator.pop(d);
                onPaid();
                save();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "$item ACTIVATED via $method!",
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text("VERIFY & UNLOCK"),
            ),
          ],
        );
      },
    );
  }

  void showSubscribe() {
    showDialog(
      context: context,
      builder: (d) {
        return AlertDialog(
          title: const Text(
            "You used your 2 FREE chats!",
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "To keep chatting, subscribe:",
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(d);
                    showPay(
                      "SUBSCRIBE Weekly",
                      "\$1",
                      () {
                        setState(() {
                          subUntil = DateTime.now()
                              .add(
                                const Duration(days: 7),
                              )
                              .toIso8601String();
                        });
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text(
                    "WEEKLY - \$1 (7 Days)",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(d);
                    showPay(
                      "SUBSCRIBE Monthly",
                      "\$2",
                      () {
                        setState(() {
                          subUntil = DateTime.now()
                              .add(
                                const Duration(days: 30),
                              )
                              .toIso8601String();
                        });
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                  ),
                  child: const Text(
                    "MONTHLY - \$2 (30 Days)",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Pay: EcoCash / Mukuru / PayPal\n"
                "Number: +263785438913\n"
                "Name: DESIRES",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(d);
              },
              child: const Text("Later"),
            ),
          ],
        );
      },
    );
  }

  void doShare(Map b) {
    String msg = "DESIRES - ${b['name']} | "
        "${b['cat']} in ${b['city']}, ${b['country']} | "
        "Price: ${b['price']} | "
        "WhatsApp: +${b['phone']}";
    Share.share(msg);
  }

  void doInvite() {
    Share.share(
      "Download DESIRES - Find Electricians, "
      "Plumbers, Tilers, Food & More Near You!",
    );
  }

  Future<void> doRealChat(Map b) async {
    if (!isSubscribed && chatCount >= 2) {
      showSubscribe();
      return;
    }
    if (!isSubscribed) {
      setState(() {
        chatCount++;
      });
      save();
      String leftMsg = "FREE chat used. "
          "You have $freeLeft FREE left.";
      if (freeLeft == 0) {
        leftMsg = "That was your last FREE chat!";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(leftMsg)),
      );
    }
    String phone = b['phone'].toString();
    String name = b['name'].toString();
    String cat = b['cat'].toString();
    String city = b['city'].toString();
    String price = b['price'].toString();
    String msg = "Hi $name, I saw your $cat post "
        "in $city on DESIRES. Are you available? "
        "Price: $price";
    String encoded = Uri.encodeComponent(msg);
    final uri = Uri.parse(
      'https://wa.me/$phone?text=$encoded',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  void showAdd() {
    String name = "";
    String city = "";
    String phone = "";
    String desc = "";
    String price = "";
    String cat = cats[1];
    String type = "worker";
    String selectedCountry = "Zimbabwe";
    String? imageBase64;
    Uint8List? imageBytes;

    int myCount = list.where((b) {
      return b["isMine"] == true;
    }).length;

    if (!isPremium && myCount >= 1) {
      showPay(
        "PREMIUM Monthly",
        "\$2",
        () {
          setState(() {
            isPremium = true;
          });
        },
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx2, setS) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx2).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Post Your Work",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      children: [
                        ChoiceChip(
                          label: const Text("Worker"),
                          selected: type == "worker",
                          onSelected: (v) {
                            setS(() {
                              type = "worker";
                            });
                          },
                        ),
                        ChoiceChip(
                          label: const Text("Seller"),
                          selected: type == "seller",
                          onSelected: (v) {
                            setS(() {
                              type = "seller";
                            });
                          },
                        ),
                        ChoiceChip(
                          label: const Text("I NEED WORK DONE"),
                          selected: type == "request",
                          onSelected: (v) {
                            setS(() {
                              type = "request";
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: "Your Name",
                      ),
                      onChanged: (v) {
                        name = v;
                      },
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: "Phone e.g. 26377...",
                      ),
                      keyboardType: TextInputType.phone,
                      onChanged: (v) {
                        phone = v;
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButton<String>(
                      value: cat,
                      isExpanded: true,
                      items: cats.where((e) {
                        return e != "All";
                      }).map((c) {
                        return DropdownMenuItem(
                          value: c,
                          child: Text(c),
                        );
                      }).toList(),
                      onChanged: (v) {
                        setS(() {
                          cat = v!;
                        });
                      },
                    ),
                    DropdownButton<String>(
                      value: selectedCountry,
                      isExpanded: true,
                      items: countries.map((c) {
                        return DropdownMenuItem(
                          value: c,
                          child: Text(c),
                        );
                      }).toList(),
                      onChanged: (v) {
                        setS(() {
                          selectedCountry = v!;
                        });
                      },
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: "City e.g. Harare",
                      ),
                      onChanged: (v) {
                        city = v;
                      },
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: "What do you do / sell?",
                      ),
                      maxLines: 2,
                      onChanged: (v) {
                        desc = v;
                      },
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: "Price e.g. \$20 per job",
                      ),
                      onChanged: (v) {
                        price = v;
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Add Picture:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    imageBytes != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              imageBytes!,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const SizedBox(),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final p = await ImagePicker().pickImage(
                                source: ImageSource.camera,
                                imageQuality: 60,
                              );
                              if (p != null) {
                                final bytes = await p.readAsBytes();
                                setS(() {
                                  imageBytes = bytes;
                                  imageBase64 = base64Encode(bytes);
                                });
                              }
                            },
                            icon: const Icon(Icons.camera_alt),
                            label: const Text("Camera"),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final p = await ImagePicker().pickImage(
                                source: ImageSource.gallery,
                                imageQuality: 60,
                              );
                              if (p != null) {
                                final bytes = await p.readAsBytes();
                                setS(() {
                                  imageBytes = bytes;
                                  imageBase64 = base64Encode(bytes);
                                });
                              }
                            },
                            icon: const Icon(Icons.photo_library),
                            label: const Text("Gallery"),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Fill Name, City and Description",
                                ),
                              ),
                            );
                            return;
                          }
                          if (city.isEmpty || desc.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Fill Name, City and Description",
                                ),
                              ),
                            );
                            return;
                          }
                          setState(() {
                            list.insert(0, {
                              "name": name,
                              "city": city,
                              "country": selectedCountry,
                              "phone": phone,
                              "desc": desc,
                              "cat": cat,
                              "type": type,
                              "ratings": [],
                              "image": imageBase64 ?? "",
                              "price": price,
                              "verified": false,
                              "reported": false,
                              "boosted": false,
                              "urgent": false,
                              "isMine": true,
                              "lat": myLat ?? -17.8252,
                              "lon": myLon ?? 31.0335,
                            });
                          });
                          save();
                          Navigator.pop(ctx2);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Posted! You are LIVE on Desires",
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(16),
                        ),
                        child: const Text("POST NOW"),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void showTop() {
    var sorted = List<Map<String, dynamic>>.from(
      list.where((b) {
        return b["reported"] != true;
      }),
    );
    sorted.sort((a, b) {
      return avgRating(b).compareTo(avgRating(a));
    });
    showModalBottomSheet(
      context: context,
      builder: (c) {
        return ListView(
          children: [
            const ListTile(
              title: Text(
                "Top Workers",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            ...sorted.take(5).map((b) {
              return ListTile(
                leading: CircleAvatar(
                  child: Text(b["name"].toString()[0]),
                ),
                title: Text(
                  "${b['name']} - ${b['cat']}",
                ),
                subtitle: Text(
                  "${b['city']}, ${b['country']} - "
                  "${avgRating(b).toStringAsFixed(1)} - "
                  "${getKm(b)}km away",
                ),
              );
            }),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> show = [];
    for (var b in list) {
      if (b["reported"] == true) {
        continue;
      }
      String what = searchWhat.toLowerCase().trim();
      String where = searchCity.toLowerCase().trim();
      String catLow = b["cat"].toString().toLowerCase();
      String nameLow = b["name"].toString().toLowerCase();
      String descLow = b["desc"].toString().toLowerCase();
      bool m1 = what.isEmpty ||
          catLow.contains(what) ||
          nameLow.contains(what) ||
          descLow.contains(what);
      bool m2 = filter == "All" || b["cat"] == filter;
      bool m3 = true;
      if (countryFilter != "All Countries") {
        String bc = (b["country"] ?? "").toString();
        if (bc.toLowerCase() != countryFilter.toLowerCase()) {
          m3 = false;
        }
      }
      if (where.isNotEmpty) {
        String cityLow = b["city"].toString().toLowerCase();
        String countryLow = (b["country"] ?? "").toString();
        countryLow = countryLow.toLowerCase();
        if (!cityLow.contains(where)) {
          if (!countryLow.contains(where)) {
            m3 = false;
          }
        }
      }
      bool m4 = typeFilter == "All Types" || b["type"] == typeFilter;
      bool m5 = true;
      if (nearMeOnly) {
        if (getKm(b) >= 15) {
          m5 = false;
        }
      }
      if (m1 && m2 && m3 && m4 && m5) {
        show.add(b);
      }
    }

    show.sort((a, b) {
      if (nearMeOnly) {
        return getKm(a).compareTo(getKm(b));
      }
      bool aU = a["urgent"] == true;
      bool bU = b["urgent"] == true;
      if (aU != bU) {
        return bU ? 1 : -1;
      }
      bool ab = a["boosted"] == true;
      bool bb = b["boosted"] == true;
      if (ab != bb) {
        return bb ? 1 : -1;
      }
      return 0;
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "DESIRES",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              Icons.star,
              color: isPremium ? Colors.amber : Colors.white,
            ),
            onPressed: () {
              if (isPremium) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("You are PREMIUM"),
                  ),
                );
              } else {
                showPay(
                  "PREMIUM Monthly",
                  "\$2",
                  () {
                    setState(() {
                      isPremium = true;
                    });
                  },
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              showDialog(
                context: context,
                builder: (d) {
                  return AlertDialog(
                    title: const Text("New in your area"),
                    content: SizedBox(
                      height: 300,
                      width: 300,
                      child: ListView(
                        children: list.take(5).map((b) {
                          return ListTile(
                            title: Text(
                              "${b['name']} - ${b['cat']}",
                            ),
                            subtitle: Text(
                              "${b['city']} - ${b['price'] ?? ''} - "
                              "${getKm(b)}km",
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(d);
                        },
                        child: const Text("OK"),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FloatingActionButton.extended(
          onPressed: showAdd,
          backgroundColor: Colors.blue,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            "POST",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Column(
        children: [
          isSubscribed
              ? Container(
                  width: double.infinity,
                  color: Colors.green[100],
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    "SUBSCRIBED - Unlimited Chats Until "
                    "${subUntil.isNotEmpty ? subUntil.substring(0, 10) : ''}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                )
              : Container(
                  width: double.infinity,
                  color: freeLeft > 0 ? Colors.orange[100] : Colors.red[100],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          freeLeft > 0
                              ? "You have $freeLeft FREE chats left"
                              : "You used your 2 FREE chats - Subscribe!",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: showSubscribe,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("SUBSCRIBE \$1"),
                      ),
                    ],
                  ),
                ),
          Container(
            color: Colors.black,
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                TextField(
                  onChanged: (v) {
                    setState(() {
                      searchWhat = v;
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "WHAT? e.g. Electrician",
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.blue,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  onChanged: (v) {
                    setState(() {
                      searchCity = v;
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "WHERE? e.g. Harare",
                    prefixIcon: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: showTop,
                        icon: const Icon(Icons.emoji_events),
                        label: const Text(
                          "Top Workers",
                          style: TextStyle(fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: doInvite,
                        icon: const Icon(Icons.card_giftcard),
                        label: const Text(
                          "Invite",
                          style: TextStyle(fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (myLat == null) {
                        await getLocation();
                      }
                      setState(() {
                        nearMeOnly = !nearMeOnly;
                      });
                    },
                    icon: const Icon(
                      Icons.location_on,
                      size: 16,
                    ),
                    label: Text(
                      nearMeOnly
                          ? "NEAR ME: ON - Tap to Show All"
                          : "PEOPLE NEAR ME - Tap to Activate GPS",
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: nearMeOnly ? Colors.red : Colors.white,
                      foregroundColor: nearMeOnly ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Switch(
                      value: lowData,
                      onChanged: (v) {
                        setState(() {
                          lowData = v;
                        });
                      },
                    ),
                    const Text(
                      "Low Data",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    Switch(
                      value: isShona,
                      onChanged: (v) {
                        setState(() {
                          isShona = v;
                        });
                      },
                    ),
                    const Text(
                      "Shona",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      isPremium ? "PREMIUM" : "FREE",
                      style: TextStyle(
                        color: isPremium ? Colors.amber : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 45,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              children: cats.map((c) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(c),
                    selected: filter == c,
                    onSelected: (v) {
                      setState(() {
                        filter = c;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Container(
            height: 45,
            color: Colors.white,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              children: ["All Countries", ...countries].map((c) {
                final sel = countryFilter == c;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(c),
                    selected: sel,
                    selectedColor: Colors.blue,
                    labelStyle: TextStyle(
                      color: sel ? Colors.white : Colors.black,
                    ),
                    onSelected: (v) {
                      setState(() {
                        countryFilter = c;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              children: ["All Types", "worker", "seller", "request"].map((t) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(
                      t == "request" ? "I NEED WORK" : t,
                    ),
                    selected: typeFilter == t,
                    onSelected: (v) {
                      setState(() {
                        typeFilter = t;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: show.isEmpty
                ? const Center(
                    child: Text(
                      "No results yet.\nBe first to post!",
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    itemCount: show.length,
                    padding: const EdgeInsets.only(
                      left: 10,
                      right: 10,
                      top: 10,
                      bottom: 80,
                    ),
                    itemBuilder: (c, i) {
                      var b = show[i];
                      String key = b["name"].toString() + b["phone"].toString();
                      bool isFav = favs.contains(key);
                      double km = getKm(b);
                      bool isUrgent = b["urgent"] == true;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        elevation: 3,
                        color: isUrgent ? Colors.red[50] : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: isUrgent
                              ? const BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                )
                              : BorderSide.none,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              isUrgent
                                  ? Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        "URGENT - NEEDS WORKER TODAY!",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    )
                                  : const SizedBox(),
                              SizedBox(
                                height: isUrgent ? 8 : 0,
                              ),
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    child: Text(
                                      b["name"].toString()[0],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                b["name"],
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            b["verified"] == true
                                                ? const Icon(
                                                    Icons.verified,
                                                    color: Colors.blue,
                                                    size: 18,
                                                  )
                                                : const SizedBox(),
                                          ],
                                        ),
                                        Text(
                                          "${b['cat']} - ${b['city']}, "
                                          "${b['country'] ?? ''}",
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          "${km}km away",
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  b["boosted"] == true
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.purple,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: const Text(
                                            "BOOSTED",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )
                                      : const SizedBox(),
                                  IconButton(
                                    icon: Icon(
                                      isFav
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        if (isFav) {
                                          favs.remove(key);
                                        } else {
                                          favs.add(key);
                                        }
                                      });
                                      save();
                                    },
                                  ),
                                ],
                              ),
                              (!lowData && (b["image"] ?? "") != "")
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: buildImage(
                                        b["image"],
                                        180,
                                      ),
                                    )
                                  : const SizedBox(),
                              const SizedBox(height: 8),
                              Text(b["desc"] ?? ""),
                              const SizedBox(height: 6),
                              (b["price"] ?? "") != ""
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.amber[100],
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        "Price: ${b['price']}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : const SizedBox(),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 18,
                                  ),
                                  Flexible(
                                    child: Text(
                                      " ${avgRating(b).toStringAsFixed(1)} "
                                      "(${(b['ratings'] as List?)?.length ?? 0})",
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      int myRate = 5;
                                      showDialog(
                                        context: context,
                                        builder: (d) {
                                          return AlertDialog(
                                            title: const Text(
                                              "Rate this person",
                                            ),
                                            content: StatefulBuilder(
                                              builder: (cc, setD) {
                                                return Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children:
                                                      List.generate(5, (idx) {
                                                    return IconButton(
                                                      icon: Icon(
                                                        Icons.star,
                                                        color: idx < myRate
                                                            ? Colors.amber
                                                            : Colors.grey,
                                                        size: 32,
                                                      ),
                                                      onPressed: () {
                                                        setD(() {
                                                          myRate = idx + 1;
                                                        });
                                                      },
                                                    );
                                                  }),
                                                );
                                              },
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(d);
                                                },
                                                child: const Text("Cancel"),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  setState(() {
                                                    if (b["ratings"] == null) {
                                                      b["ratings"] = [];
                                                    }
                                                    (b["ratings"] as List)
                                                        .add(myRate);
                                                  });
                                                  save();
                                                  Navigator.pop(d);
                                                },
                                                child: const Text("RATE"),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: const Text(
                                      "Rate",
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        b["reported"] = true;
                                      });
                                      save();
                                    },
                                    child: const Text(
                                      "Report",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        String ph = b['phone'].toString();
                                        final uri = Uri.parse(
                                          'tel:$ph',
                                        );
                                        if (await canLaunchUrl(uri)) {
                                          launchUrl(uri);
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text(
                                        "Call",
                                        style: TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        doRealChat(b);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text(
                                        "WhatsApp",
                                        style: TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        doRealChat(b);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.purple,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text(
                                        "Chat",
                                        style: TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        doShare(b);
                                      },
                                      icon: const Icon(
                                        Icons.share,
                                        size: 16,
                                      ),
                                      label: const Text("Share"),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              (b["verified"] != true && b["isMine"] == true)
                                  ? SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          showPay(
                                            "VERIFIED BADGE",
                                            "\$1",
                                            () {
                                              setState(() {
                                                b["verified"] = true;
                                              });
                                            },
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.verified,
                                          size: 18,
                                        ),
                                        label: const Text(
                                          "GET VERIFIED BADGE - \$1",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    )
                                  : const SizedBox(),
                              (b["type"] == "request" && !isUrgent)
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            showPay(
                                              "URGENT JOB",
                                              "\$2",
                                              () {
                                                setState(() {
                                                  b["urgent"] = true;
                                                });
                                              },
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.warning,
                                            size: 18,
                                          ),
                                          label: const Text(
                                            "MAKE URGENT - \$2 Go To Top!",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox(),
                              const SizedBox(height: 8),
                              b["boosted"] != true
                                  ? SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          showPay(
                                            "BOOST",
                                            "\$1",
                                            () {
                                              setState(() {
                                                b["boosted"] = true;
                                              });
                                            },
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.rocket_launch,
                                          size: 18,
                                        ),
                                        label: const Text(
                                          "BOOST THIS PERSON - \$1",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.purple,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.purple[50],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Text(
                                        "This person is BOOSTED - At the top!",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.purple,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
