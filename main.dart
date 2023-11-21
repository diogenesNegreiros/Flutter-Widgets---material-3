import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';

final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const WidgetsListTileApp());
}

class WidgetsListTileApp extends StatelessWidget {
  const WidgetsListTileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Widgets - Material 3',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(color: Colors.black),
          color: Colors.blueGrey,
          foregroundColor: Colors.white,
          systemOverlayStyle: SystemUiOverlayStyle(
            //<-- SEE HERE
            // Status bar color
            statusBarColor: Colors.blueGrey,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.light,
          ),
        ),
      ),
      home: const WidgetsListTileExample(),
    );
  }
}

class WidgetsListTileExample extends StatefulWidget {
  const WidgetsListTileExample({super.key});

  @override
  State<WidgetsListTileExample> createState() => _WidgetsListTileExampleState();
}

class _WidgetsListTileExampleState extends State<WidgetsListTileExample> {
  @override
  void initState() {
    super.initState();
    MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: [testDevice]));
    _showBannerForId(bannerId, "top");
    _showBannerForId(bannerId, "bottom");
    _createInterstitialAd();
    _createRewardedAd();
  }

  static const AdRequest request = AdRequest(
    keywords: <String>['Developer', 'Flutter', 'android', 'technology'],
    contentUrl: 'https://diogenesdesouza.wixsite.com/aplicativos',
    nonPersonalizedAds: false,
  );

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;

  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;

  String testDevice = "B3EEABB8EE11C2BE770B684D95219ECB";
  int maxFailedLoadAttempts = 3;

  BannerAd? _bannerAd;
  BannerAd? _bannerAd2;

  bool checkboxValue1 = false;
  bool checkboxValue2 = false;
  bool checkboxValue3 = false;
  bool checkboxValue4 = false;
  String radioChoice = "";
  bool switchState = false;
  String textButtonResult = "";
  bool switchListTileState = false;
  double slideValue1 = 0;
  double slideValue2 = 2.5;
  double _currentCupertinoSliderValue = 0.0;
  String? _sliderCupertinoStatus;
  Icon floatIcon = const Icon(Icons.done);

  String bannerId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  void _showBannerForId(id, type) {
    BannerAd(
      adUnitId: id,
      request: request,
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            if (type == "top") {
              _bannerAd = ad as BannerAd;
            } else {
              _bannerAd2 = ad as BannerAd;
            }
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          ad.dispose();
        },
      ),
    ).load();
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: Platform.isAndroid //ca-app-pub-3940256099942544/1033173712
            ? 'ca-app-pub-3940256099942544/1033173712'
            : 'ca-app-pub-3940256099942544/4411468910',
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  void _createRewardedAd() {
    RewardedAd.load(
        adUnitId: Platform.isAndroid
            ? 'ca-app-pub-3940256099942544/5224354917'
            : 'ca-app-pub-3940256099942544/1712485313',
        request: request,
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            print('$ad loaded.');
            _rewardedAd = ad;
            _numRewardedLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedAd failed to load: $error');
            _rewardedAd = null;
            _numRewardedLoadAttempts += 1;
            if (_numRewardedLoadAttempts < maxFailedLoadAttempts) {
              _createRewardedAd();
            }
          },
        ));
  }

  void _showRewardedAd() {
    if (_rewardedAd == null) {
      print('Warning: attempt to show rewarded before loaded.');
      return;
    }
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createRewardedAd();
      },
    );

    _rewardedAd!.setImmersiveMode(true);
    _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      print('$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
    });
    _rewardedAd = null;
  }
  _launchURL(url) async {
    final Uri path = Uri.parse(url);
    if (!await launchUrl(path)) {
      throw Exception('Could not launch $path');
    }
  }
  void showSnack(String msg) {
    final SnackBar snackBar = SnackBar(
      content: Text(msg),
      action: SnackBarAction(
        textColor: Colors.lightBlue,
        label: 'Undo',
        onPressed: () {},
      ),
    );

    // Find the ScaffoldMessenger in the widget tree
    // and use it to show a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Flutter widgets - Material 3'),
          // systemOverlayStyle: SystemUiOverlayStyle.dark
        ),
        body: SingleChildScrollView(
            padding:
                const EdgeInsets.only(top: 20, bottom: 80, left: 20, right: 20),
            child: Column(children: <Widget>[
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text("Image",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.blue)),
              ),
              Image.asset(
                "images/widget.png",
                fit: BoxFit.contain,
              ),
              const Divider(height: 16),
              if (_bannerAd != null)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text("Admob banner",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Colors.blue)),
                ),
              if (_bannerAd != null)
                Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: _bannerAd!.size.width.toDouble(),
                      height: _bannerAd!.size.height.toDouble(),
                      child: AdWidget(ad: _bannerAd!),
                    )),
              const Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: Text("Form",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Colors.blue))),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      decoration: const InputDecoration(
                          hintText: 'Enter your email', labelText: 'email'),
                      keyboardType: TextInputType.emailAddress,
                      maxLength: 20,
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                          hintText: 'Enter your password',
                          labelText: 'password'),
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          // Validate will return true if the form is valid, or false if
                          // the form is invalid.
                          if (_formKey.currentState!.validate()) {
                            // Process data.
                          }
                        },
                        child: const Text('Submit'),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 16),
              const Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: Text("CheckboxListTile",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Colors.blue))),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text("checkbox result:  "),
                Text(checkboxValue1 ? "true  " : "false "),
                Text(checkboxValue2 ? "true " : "false "),
                Text(checkboxValue3 ? "true " : "false "),
                Text(checkboxValue4 ? "true " : "false ")
              ]),
              Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: CheckboxListTile(
                    title: const Text('Animate Slowly'),
                    value: checkboxValue1,
                    onChanged: (bool? value) {
                      setState(() {
                        checkboxValue1 = value!;
                        timeDilation = value! ? 6.0 : 1.0;
                      });
                    },
                    secondary: const Icon(Icons.hourglass_empty),
                  )),
              CheckboxListTile(
                value: checkboxValue2,
                onChanged: (bool? value) {
                  setState(() {
                    timeDilation = 1.0;
                    checkboxValue2 = value!;
                  });
                },
                title: const Text('Headline'),
                subtitle: const Text('Supporting text'),
              ),
              CheckboxListTile(
                value: checkboxValue3,
                onChanged: (bool? value) {
                  setState(() {
                    timeDilation = 1.0;
                    checkboxValue3 = value!;
                  });
                },
                title: const Text('Headline'),
                subtitle: const Text(
                    'Longer supporting text to demonstrate how the text wraps and the checkbox is centered vertically with the text.'),
              ),
              CheckboxListTile(
                value: checkboxValue4,
                onChanged: (bool? value) {
                  setState(() {
                    timeDilation = 1.0;
                    checkboxValue4 = value!;
                  });
                },
                title: const Text('Headline'),
                subtitle: const Text(
                    "Longer supporting text to demonstrate how the text wraps and how setting 'CheckboxListTile.isThreeLine = true' aligns the checkbox to the top vertically with the text."),
                isThreeLine: true,
              ),
              const Divider(height: 16),
              const Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: Text("Radio Button",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Colors.blue))),
              Text("Radio result: $radioChoice"),
              ListTile(
                title: const Text('First'),
                leading: Radio(
                  value: "First",
                  groupValue: radioChoice,
                  onChanged: (String? value) {
                    setState(() {
                      timeDilation = 1.0;
                      radioChoice = "First";
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Second'),
                leading: Radio(
                  value: "Second",
                  groupValue: radioChoice,
                  onChanged: (String? value) {
                    setState(() {
                      timeDilation = 1.0;
                      radioChoice = "Second";
                    });
                  },
                ),
              ),
              const Divider(height: 24),
              const Text("TextButton",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.blue)),
              Text(textButtonResult),
              TextButton(
                  child: const Text("Button",
                      style: TextStyle(fontSize: 20, color: Colors.green)),
                  onPressed: () {
                    setState(() {
                      textButtonResult = "Pressed";
                    });
                  }),
              const Divider(height: 24),
              const Text("Switch",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.blue)),
              Text("Switch result:  $switchState"),
              Switch(
                  value: switchState,
                  onChanged: (bool state) {
                    setState(() {
                      timeDilation = 1.0;
                      switchState = state;
                    });
                  }),
              const Divider(height: 24),
              const Text("SwitchListTile",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.blue)),
              SwitchListTile(
                  title: const Text("SwitchListTile Title"),
                  subtitle:
                      Text("subtitle example.. state: $switchListTileState"),
                  value: switchListTileState,
                  onChanged: (bool state) {
                    setState(() {
                      timeDilation = 1.0;
                      switchListTileState = state;
                    });
                  }),
              const Divider(height: 24),
              const Text("Slider",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.blue)),
              Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Slider(
                      value: slideValue2,
                      activeColor: Colors.blue,
                      inactiveColor: Colors.grey[400],
                      divisions: 5,
                      label: slideValue2.toString(),
                      min: 0,
                      max: 5,
                      onChanged: (double newValue) {
                        setState(() {
                          slideValue2 = newValue;
                        });
                      })),
              const Padding(
                  padding: EdgeInsets.only(top: 24, bottom: 10),
                  child: Text("CupertinoSlider",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Colors.blue))),
              Text('$_currentCupertinoSliderValue'),
              CupertinoSlider(
                key: const Key('slider'),
                value: _currentCupertinoSliderValue,
                // This allows the slider to jump between divisions.
                // If null, the slide movement is continuous.
                divisions: 5,
                // The maximum slider value
                max: 100,
                activeColor: CupertinoColors.systemPurple,
                thumbColor: CupertinoColors.systemPurple,
                // This is called when sliding is started.
                onChangeStart: (double value) {
                  setState(() {
                    _sliderCupertinoStatus = 'Sliding';
                  });
                },
                // This is called when sliding has ended.
                onChangeEnd: (double value) {
                  setState(() {
                    _sliderCupertinoStatus = 'Finished sliding';
                  });
                },
                // This is called when slider value is changed.
                onChanged: (double value) {
                  setState(() {
                    _currentCupertinoSliderValue = value;
                  });
                },
              ),
              Text(
                _sliderCupertinoStatus ?? '',
                style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                      fontSize: 12,
                    ),
              ),
              const Divider(height: 24),
              const Text("IconButton",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.blue)),
              Padding(padding: const EdgeInsets.all(16), child: floatIcon),
              Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(10),
                        child: IconButton(
                            color: Colors.blue,
                            onPressed: () {
                              setState(() {
                                floatIcon = const Icon(Icons.add);
                              });
                            },
                            icon: const Icon(Icons.add))),
                    Padding(
                        padding: const EdgeInsets.all(10),
                        child: IconButton(
                            color: Colors.green,
                            onPressed: () {
                              setState(() {
                                floatIcon = const Icon(Icons.alarm);
                              });
                            },
                            icon: const Icon(Icons.alarm))),
                    Padding(
                        padding: const EdgeInsets.all(10),
                        child: IconButton(
                            color: Colors.purple,
                            onPressed: () {
                              setState(() {
                                floatIcon = const Icon(Icons.share);
                              });
                            },
                            icon: const Icon(Icons.share))),
                    Padding(
                        padding: const EdgeInsets.all(10),
                        child: IconButton(
                            color: Colors.blueGrey,
                            onPressed: () {
                              setState(() {
                                floatIcon = const Icon(Icons.people);
                              });
                            },
                            icon: const Icon(Icons.people)))
                  ]),
              const Divider(height: 24),
              const Text("Buttons",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.blue)),
              const Padding(padding: EdgeInsets.only(top: 20)),
              OutlinedButton(
                // foreground
                onPressed: () {},
                child: const Text('OutlinedButton'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent, // background
                  foregroundColor: Colors.white, // foreground
                ),
                onPressed: () {},
                child: const Text('ElevatedButton'),
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text('ElevatedButton Default'),
              ),
              FilledButton(onPressed: () {}, child: const Text('Filled')),
              TextButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.blueAccent, // foreground
                ),
                onPressed: () {},
                child: const Text('TextButton'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // background
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(40), // foreground
                ),
                onPressed: () {},
                child: const Text('ElevatedButton full'),
              ),
              const Divider(height: 24),
              if (_bannerAd2 != null)
                Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: _bannerAd2!.size.width.toDouble(),
                      height: _bannerAd2!.size.height.toDouble(),
                      child: AdWidget(ad: _bannerAd2!),
                    )),
              const Divider(height: 50),
              Padding(
                  padding: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900], // background
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50), // foreground
                    ),
                    onPressed: () {
                      _launchURL("https://flutter.dev");
                    },
                    child: const Text('About Flutter'),
                  )),
              Padding(
                  padding: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[800], // background
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50), // foreground
                    ),
                    onPressed: () {},
                    child: const Text('App source code'),
                  ))
            ])),
        floatingActionButton: FloatingActionButton(
          tooltip: 'Add', // used by assistive technologies
          onPressed: () {
            showSnack('Show Snack - FloatingActionButton press');
          },
          child: const Icon(Icons.add),
        ),
        bottomNavigationBar: BottomAppBar(
            color: Colors.blueGrey,
            child: Row(children: [
              Expanded(
                child: TextButton(
                    onPressed: () {
                      _showInterstitialAd();
                    },
                    child: const Text("Interstitial",
                        style: TextStyle(fontSize: 16, color: Colors.white))),
              ),
              Expanded(
                  child: TextButton(
                      onPressed: () {
                        _showRewardedAd();
                      },
                      child: const Text("Reward",
                          style: TextStyle(fontSize: 16, color: Colors.white))))
            ])));
  }
}
