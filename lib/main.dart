import 'dart:math';
import 'package:flutter/material.dart';
import 'package:music_player/bottom_controls.dart';
import 'package:music_player/theme.dart';
import 'songs.dart';
import 'package:fluttery/gestures.dart';

void main() =>  runApp(new MyApp());

class MyApp extends StatelessWidget {
  final Widget child;

  MyApp({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Flutter Application",
      debugShowCheckedModeBanner: false,
      home: new MusicPlayerHome(),
    );
  }
}

class MusicPlayerHome extends StatefulWidget {
  final Widget child;

  MusicPlayerHome({Key key, this.child}) : super(key: key);

  _MusicPlayerHomeState createState() => _MusicPlayerHomeState();
}

class _MusicPlayerHomeState extends State<MusicPlayerHome> {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back_ios),
          color: new Color(0xFFDDDDDD),
          onPressed: (){},
        ),
        actions: <Widget>[
          new IconButton(
          icon: new Icon(Icons.menu),
          color: new Color(0xFFDDDDDD),
          onPressed: (){},
        ),
        ],
      ),
      body: new Column(
        children: <Widget>[
          //seek bar
            new Expanded(
              child: new RadialSeekBar(),
            ),

            //visualiser
            new Container(
              width: double.infinity,
              height: 125.0,
            ),

            //song title, artist name, and controls
            new BottomControls(),

        ],
      ),
    );
  }
}

class RadialSeekBar extends StatefulWidget {

  final double seekPercent;

  RadialSeekBar({this.seekPercent = 0.0});

  @override
  _RadialSeekBarState createState() => _RadialSeekBarState();
}

class _RadialSeekBarState extends State<RadialSeekBar> {

  double _seekPercent = 0.0;
  PolarCoord _startDragCoord;
  double _startDragPercent;
  double _currentDragPercent;

  void initState() { 
    super.initState();
    _seekPercent = widget.seekPercent;
  }

  @override
  void didUpdateWidget (RadialSeekBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _seekPercent = widget.seekPercent;
    
  }

  void _onDragStart(PolarCoord coords){
    _startDragCoord = coords;
    _startDragPercent = _seekPercent; 
  }
  
  void _onDragUpdate(PolarCoord coords){
    final dragAngle = coords.angle - _startDragCoord.angle;
    final dragPercent = dragAngle/(2 * pi);
    setState(() => _currentDragPercent = (_startDragPercent + dragPercent) % 1.0);
  }

  void _onDragEnd(){
    setState(() {
     _seekPercent = _currentDragPercent;
     _currentDragPercent = null;
     _startDragPercent = 0.0;
     _startDragCoord = null; 
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){},
      onDoubleTap: (){},
      child: new RadialDragGestureDetector(
        onRadialDragEnd: _onDragEnd,
        onRadialDragStart: _onDragStart,
        onRadialDragUpdate: _onDragUpdate,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.transparent,
          child: new Center(
            child: new Container(
              width: 160.0,
              height: 160.0,
              child: new RadialProgressBar(
                trackColor: new Color(0xFFDDDDDD),
                progressPercent: _currentDragPercent ?? _seekPercent,
                thumbPosition: _currentDragPercent ?? _seekPercent,
                progressColor: accentColor,
                thumbColor: lightAccentColor,
                innerPadding: const EdgeInsets.all(10.0),
                child: new ClipOval(
                  clipper: new CircleClipper(),
                  child: new Image.network(
                    demoPlaylist.songs[0].albumArtUrl,
                    fit: BoxFit.fill,
                  ),
                ),
              ), 
            ),
          ),
        ),
      ),
    );
  }
}

class RadialProgressBar extends StatefulWidget {

  final double trackWidth;
  final Color trackColor;
  final double progressWidth;
  final double progressPercent;
  final Color progressColor;
  final double thumbSize;
  final Color thumbColor;
  final thumbPosition;
  final innerPadding;

  final Widget child;

  RadialProgressBar({
    Key key, 
    this.child, 
    this.trackWidth = 3.0, 
    this.trackColor = Colors.grey, 
    this.progressWidth = 5.0, 
    this.progressColor = Colors.black, 
    this.thumbSize = 10.0, 
    this.thumbColor = Colors.black,
    this.thumbPosition = 0.0, 
    this.progressPercent = 0.0, 
    this.innerPadding = const EdgeInsets.all(0.0)
    
  }) : super(key: key);

  _RadialProgressBarState createState() => _RadialProgressBarState();
}

class _RadialProgressBarState extends State<RadialProgressBar> {

  EdgeInsets _insetsForPainter(){
    final outerThickness = max(
      widget.thumbSize, 
      max(widget.trackWidth, widget.progressWidth)
    )/2.0;
    return new EdgeInsets.all(outerThickness);
  }

  @override
  Widget build(BuildContext context) {
    return new CustomPaint(
      foregroundPainter: new RadialProgressBarPainter(
        trackWidth: widget.trackWidth, 
        trackColor: widget.trackColor,
        progressWidth: widget.progressWidth,
        progressPercent: widget.progressPercent,
        progressColor: widget.progressColor,
        thumbSize: widget.thumbSize,
        thumbColor: widget.thumbColor,
        thumbPosition: widget.thumbPosition, 
        innerPadding: widget.innerPadding,
      ),
      child: new Padding(
        padding: _insetsForPainter() + widget.innerPadding,
        child: widget.child,
      ),
    );
  }
}

class RadialProgressBarPainter extends CustomPainter{

  final double trackWidth;
  final Paint trackPaint;
  final double progressWidth;
  final double progressPercent;
  final Paint progressPaint;
  final double thumbSize;
  final thumbPosition;
  final Paint thumbPaint;

  RadialProgressBarPainter({
    
    @required this.trackWidth, 
    @required trackColor,
    @required this.progressWidth,
    @required this.progressPercent,
    @required progressColor,
    @required this.thumbSize, 
    @required thumbColor,
    @required this.thumbPosition, 
    @required innerPadding,  
    
  }) : trackPaint = new Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = trackWidth,
      progressPaint = new Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = progressWidth
        ..strokeCap = StrokeCap.round,
      thumbPaint = new Paint()
        ..color =thumbColor
        ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    final outerThickness = max(trackWidth, max(thumbSize, progressWidth));
    Size constrainedSize = new Size(
       size.width - outerThickness,
       size.height - outerThickness,
    );

    final Offset _center = new Offset(size.width/2, size.height/2);
    final double _radius = min(constrainedSize.width, constrainedSize.height)/2;

    //paint track
    canvas.drawCircle(
      _center, 
      _radius, 
      trackPaint
    );

    //paint progress
    final double progressAngle = 2 * pi * progressPercent;
    canvas.drawArc(
      new Rect.fromCircle(
        center: _center,
        radius: _radius,
      ), 
      - pi /2, 
      progressAngle, 
      false, 
      progressPaint
    );

    //paint thumb
    final thumbAngle = 2 * pi* thumbPosition - (pi/2);
    final thumbX = cos(thumbAngle) * _radius;
    final thumbY = sin(thumbAngle) * _radius;
    final thumbCenter = new Offset(thumbX, thumbY) + _center;
    final thumbRadius = thumbSize/2;
    canvas.drawCircle(thumbCenter, thumbRadius, thumbPaint);

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}