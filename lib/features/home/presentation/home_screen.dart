import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/app_theme.dart';
import '../../auth/presentation/auth_controller.dart';

enum _AccountAction { signOut }

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.isGuest,
    required this.onSignOut,
    this.userEmail,
    super.key,
  });

  final bool isGuest;
  final String? userEmail;
  final Future<AuthActionResult> Function() onSignOut;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static final Uri _studioPhone = Uri.parse('tel:+919490359929');
  static const _streamUrl = 'https://stream.zeno.fm/tlbmhfile4yvv';

  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<PlaybackEvent>? _playbackEventSubscription;
  bool _audioSourceLoaded = false;
  bool _isPlaying = false;
  bool _isBuffering = false;
  String? _playerError;

  @override
  void initState() {
    super.initState();
    _playerStateSubscription = _player.playerStateStream.listen((state) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isPlaying = state.playing;
        _isBuffering = state.processingState == ProcessingState.loading ||
            state.processingState == ProcessingState.buffering;
      });
    });
    _playbackEventSubscription = _player.playbackEventStream.listen(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {
        if (!mounted) {
          return;
        }
        setState(() {
          _isBuffering = false;
          _isPlaying = false;
          _audioSourceLoaded = false;
          _playerError = 'The live stream could not be played. Please try again.';
        });
      },
    );
  }

  Future<void> _toggleAudio() async {
    try {
      setState(() => _playerError = null);
      if (_player.playing) {
        await _player.pause();
        return;
      }

      if (!_audioSourceLoaded) {
        setState(() => _isBuffering = true);
        await _player.setUrl(_streamUrl);
        _audioSourceLoaded = true;
      }

      unawaited(_player.play());
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isBuffering = false;
        _isPlaying = false;
        _audioSourceLoaded = false;
        _playerError = 'The live stream could not be played. Please try again.';
      });
    }
  }

  Future<void> _makeCall() async {
    final opened = await launchUrl(
      _studioPhone,
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No phone app is available on this device.')),
      );
    }
  }

  Future<void> _signOut() async {
    await _player.stop();
    final result = await widget.onSignOut();
    if (!result.succeeded && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );
    }
  }

  Future<void> _confirmExit() async {
    final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Close Hope For Life Radio?'),
            content: const Text('The live broadcast will stop.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Stay'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Close app'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldExit) {
      return;
    }

    await _player.stop();
    if (kIsWeb) {
      return;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      await SystemNavigator.pop();
    }
  }

  @override
  void dispose() {
    final playerStateSubscription = _playerStateSubscription;
    final playbackEventSubscription = _playbackEventSubscription;
    if (playerStateSubscription != null) {
      unawaited(playerStateSubscription.cancel());
    }
    if (playbackEventSubscription != null) {
      unawaited(playbackEventSubscription.cancel());
    }
    unawaited(_player.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final identity = widget.isGuest
        ? 'Guest listener'
        : (widget.userEmail ?? 'Signed-in listener');

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          unawaited(_confirmExit());
        }
      },
      child: Scaffold(
        key: const ValueKey('homeScreen'),
        appBar: AppBar(
          title: const Text(
            'Hope For Life Radio',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          actions: [
            PopupMenuButton<_AccountAction>(
              key: const ValueKey('accountMenu'),
              tooltip: 'Account',
              icon: const Icon(Icons.account_circle_outlined),
              onSelected: (action) {
                if (action == _AccountAction.signOut) {
                  unawaited(_signOut());
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<_AccountAction>(
                  enabled: false,
                  child: Text(
                    identity,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<_AccountAction>(
                  key: ValueKey('signOutMenuItem'),
                  value: _AccountAction.signOut,
                  child: Row(
                    children: [
                      Icon(Icons.logout_rounded),
                      SizedBox(width: 10),
                      Text('Sign out'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _WelcomeCard(identity: identity, isGuest: widget.isGuest),
              const SizedBox(height: 20),
              _RadioCard(
                isPlaying: _isPlaying,
                isBuffering: _isBuffering,
                error: _playerError,
                onToggle: _toggleAudio,
              ),
              const SizedBox(height: 20),
              _StudioCard(onCall: _makeCall),
              const SizedBox(height: 18),
              Text(
                'More features will be added after login and radio playback '
                'are fully verified.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blueGrey.shade700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({required this.identity, required this.isGuest});

  final String identity;
  final bool isGuest;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x12000000), blurRadius: 18, offset: Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.gold.withValues(alpha: 0.22),
            child: const Icon(Icons.favorite_rounded, color: AppColors.red),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                ),
                const SizedBox(height: 2),
                Text(
                  identity,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.blueGrey.shade700),
                ),
              ],
            ),
          ),
          if (isGuest)
            const Chip(
              label: Text('Guest'),
              avatar: Icon(Icons.person_outline_rounded, size: 18),
            ),
        ],
      ),
    );
  }
}

class _RadioCard extends StatelessWidget {
  const _RadioCard({
    required this.isPlaying,
    required this.isBuffering,
    required this.error,
    required this.onToggle,
  });

  final bool isPlaying;
  final bool isBuffering;
  final String? error;
  final Future<void> Function() onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navyLight, AppColors.navy],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Text(
            'LIVE BROADCAST',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.7,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bringing Hope Through Gospel',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 26),
          Semantics(
            button: true,
            label: isPlaying ? 'Pause live radio' : 'Play live radio',
            child: InkWell(
              key: const ValueKey('radioToggleButton'),
              onTap: isBuffering ? null : onToggle,
              customBorder: const CircleBorder(),
              child: CircleAvatar(
                radius: 43,
                backgroundColor: AppColors.gold,
                child: isBuffering
                    ? const SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: AppColors.navy,
                        ),
                      )
                    : Icon(
                        isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        size: 54,
                        color: AppColors.navy,
                      ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            error ?? (isPlaying ? 'Streaming live now' : 'Tap to listen'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: error == null ? Colors.white : Colors.red.shade200,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StudioCard extends StatelessWidget {
  const _StudioCard({required this.onCall});

  final Future<void> Function() onCall;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 25,
              backgroundColor: AppColors.navy,
              child: Icon(Icons.phone_in_talk_rounded, color: AppColors.gold),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Call the studio',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                  ),
                  SizedBox(height: 3),
                  Text('Prayer, testimony, and song requests'),
                ],
              ),
            ),
            IconButton.filled(
              key: const ValueKey('callStudioButton'),
              tooltip: 'Call studio',
              onPressed: onCall,
              icon: const Icon(Icons.call_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
