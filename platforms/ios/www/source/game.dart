part of TOTC;

class Game extends Sprite implements Animatable{
  
  static const TITLE_PHASE = 5;
  static const INSTRUCTION_PHASE = 6;
  static const FISHING_PHASE = 1;
  static const BUY_PHASE = 2;
  static const REGROWTH_PHASE = 3;
  static const ENDGAME_PHASE = 4;
  static const FINALSUMMARY_PHASE = 7;
  
  
  static const MAX_ROUNDS = 4;
//  static const MAX_ROUNDS = 0;
  
  static const FISHING_TIMER_WIDTH = 125;
  static const REGROWTH_TIMER_WIDTH = 125;
  static const BUY_TIMER_WIDTH = 125;
  
  static const FISHING_TIME = 25;
  static const REGROWTH_TIME = 10;
  static const BUYING_TIME = 15;
//  static const FISHING_TIME = 10;
//  static const REGROWTH_TIME = 10;
//  static const BUYING_TIME = 10;
  
  static const timerPieRadius = 92;
  static const TUNA = 0;
  static const SARDINE = 1;
  static const SHARK = 2;
  
  //Timer Type
  static const BAR_TIMER = 0;
  static const PIE_TIMER = 1;
  
  static const sardineBarMult = 1.5;
  static const tunaBarMult = 3;
  static const sharkBarMult = 6;
  
  num timerType = PIE_TIMER; // TOGGLE VARIABLE
  Bitmap pieTimerBitmap, pieTimerBitmapButton;
  
  ResourceManager _resourceManager;
  Juggler _juggler;
  
  Fleet _fleet;
  Ecosystem _ecosystem;
  Offseason _offseason;
  Bitmap _background;
  Endgame _endgame;
  
  Title _title;
  FinalSummary _finalSummary;
  
  TouchManager tmanager = new TouchManager();
  TouchLayer tlayer = new TouchLayer();
  
  bool gameStarted = false;
  bool newGame = true;
  
  int width =2048;
  int height=1536;
  int totalTimeCounter = 0;
  Bitmap _mask;
  Tween _maskTween;
  
  TextField teamAMoneyText, teamBMoneyText;
  TextField teamAScoreText, teamBScoreText;
  TextField roundTitle, roundNumber, seasonTitle, roundNumberDiv;
  
  int starCount = 0;
  int teamAMoney = 0;
  int teamBMoney = 0;
  int teamAScore = 0;
  int teamBScore = 0;
  int teamARoundProfit = 0;
  int teamBRoundProfit = 0;
  int teamATotalProfit = 0;
  int teamBTotalProfit = 0;
  bool moneyChanged = false;
  int moneyTimer = 0;
  int moneyTimerMax = 2;
  int round = 0;
  int gameID = -1;

  //REGROWTH INFO
  static const LINE_GRAPH_INFO = 0;
  static const BADGE_STAR_INFO = 1;
  num regrowthInfoType = BADGE_STAR_INFO; // TOGGLE VARIABLE
  
  Graph _teamAGraph, _teamBGraph;
  int _graphTimerMax = 25;
  int _graphTimer=0;
  
  EcosystemBadge badge;
  
  Shape timerGraphicA,timerGraphicB, timerPie;
  Shape sardineBar, tunaBar, sharkBar, sardineOutline, tunaOutline, sharkOutline;
  TextField timerTextA, timerTextB, gameIDText;
  Bitmap sardineIcon, tunaIcon, sharkIcon;
  
  int phase = TITLE_PHASE;
  int timer = 0;
  int fishingTimerTick = 25;
  int buyTimerTick = 20;
  int regrowthTimerTick = 15;
  
  bool transition, timerButtonBool, timerButtonReady;
  bool timerActive;
  Sound timerSound;
  SoundChannel timerSoundChannel;
  Timer timerSoundTimer;
  SimpleButton timerButton;
  
  Timer clockUpdateTimer;
  Timer curTimer;
  num clockCounter;
  // Slider _teamASlider, _teamBSlider;
  // int sliderPrompt = 6;
  
  
  Sound transition_titleToFishingSound;
  Sound transition_fishingToRegrowthSound;
  Sound transition_regrowthToBuySound;
  Sound transition_buyToFishingSound;
  Sound transition_regrowthToEndSound;
  Sound transition_endToSummarySound;
  
  Sound ui_tapTimerSound;
  
  Sound background_music;
  Sound background_music_short;
  
  List<DisplayObject> uiObjects = new List<DisplayObject>();
  
//  DataLogger datalogger;
  
  Game(ResourceManager resourceManager, Juggler juggler, int w, int h) {
    _resourceManager = resourceManager;
    _juggler = juggler;
    width = w;
    height = h;//+16;
    print("Game Width:" + width.toString());
    print("Game Height:" + height.toString());
     
      
    transition = false;
    timerActive = true;
//    datalogger = new DataLogger();
    
    tmanager.registerEvents(this);
    tmanager.addTouchLayer(tlayer);
    
    _background = new Bitmap(_resourceManager.getBitmapData("Background"));
    _mask = new Bitmap(_resourceManager.getBitmapData("Mask"));
    _fleet = new Fleet(_resourceManager, _juggler, this);
    _ecosystem = new Ecosystem(_resourceManager, _juggler, this, _fleet);
    _endgame = new Endgame(_resourceManager, _juggler, this, _ecosystem);
    
    _title = new Title(_resourceManager, _juggler, this, _ecosystem);
    _finalSummary = new FinalSummary(_resourceManager, _juggler, this, _ecosystem);
    
    _background.width = width;
    _background.height = height;
    _mask.alpha = 0;
    _mask.width = width;
    _mask.height = height;

    badge = new EcosystemBadge(_resourceManager, _juggler, this, _ecosystem);
    timerButtonBool = false;
    
    transition_titleToFishingSound = _resourceManager.getSound("transition_titleToFishing");
    transition_fishingToRegrowthSound = _resourceManager.getSound("transition_fishingToRegrowth");
    transition_regrowthToBuySound =_resourceManager.getSound("transition_regrowthToBuy");
    transition_buyToFishingSound = _resourceManager.getSound("transition_buyToFishing");
    transition_regrowthToEndSound = _resourceManager.getSound("transition_regrowthToEnd");
    transition_endToSummarySound = _resourceManager.getSound("transition_endToSummary");
    ui_tapTimerSound = _resourceManager.getSound("ui_tapTimer");
    
    addChild(_background);
    addChild(_ecosystem);
    addChild(_mask);
    addChild(_fleet);
    addChild(_endgame);
    addChild(_finalSummary);
    
    timerSound = _resourceManager.getSound("timerSound");
    timerSoundChannel = timerSound.play();
    timerSoundChannel.stop();
    
    _loadTextAndShapes();
    timerActive = false;
    addChild(_title);
    
    background_music = _resourceManager.getSound("background_music");
    background_music_short = _resourceManager.getSound("background_music_short");
    _playBgMusic();

  }
  
  void _playBgMusic(){
    SoundTransform soundTransform = new SoundTransform();
    SoundChannel music = background_music.play(true, soundTransform);
    new Timer(new Duration(milliseconds:482429),_playBgMusic);
  }

  bool advanceTime(num time) {

    if(gameStarted && newGame){
      newGame = false;
      new Timer.periodic(new Duration(seconds:1), (var e) => totalTimeCounter++);
//      ws.send('newgame');
//      ws.onMessage.listen((html.MessageEvent e) {
//        handleMsg(e.data);
//      });
    }
    
    if (gameStarted == false){
      sardineBar.height = _ecosystem._fishCount[SARDINE] * sardineBarMult;
      sardineIcon.y = sardineBar.y - sardineBar.height - sardineIcon.height;
 
      tunaBar.height = _ecosystem._fishCount[TUNA] * tunaBarMult;
      tunaIcon.y = tunaBar.y - tunaBar.height - tunaIcon.height;
      
      sharkBar.height = _ecosystem._fishCount[SHARK]* sharkBarMult;
      sharkIcon.y = sharkBar.y - sharkBar.height - sharkIcon.height;
      return true;
    }
    if(!timerActive && gameStarted){
      phase = FISHING_PHASE;
      startTimer();
      timerActive = true;
    }

    //Update Team Money
    if (moneyTimer>moneyTimerMax && moneyChanged==true) _updateMoney();
    else moneyTimer++;
    
    //Update Team Score
    teamAScoreText.text = "Score: ${teamAScore}";
    teamBScoreText.text = "Score: ${teamBScore}";
    
    
    //Update Timer and initiate phase change
//    if (timerGraphicA.width<=2 && !transition) _nextSeason();
//    else {
//      if (!transition)_decreaseTimer();
//    }
    
    
    //Display growth information
    if (phase==REGROWTH_PHASE){
      
      if(regrowthInfoType == LINE_GRAPH_INFO){
        if (_graphTimer>_graphTimerMax) _redrawGraph();
        else _graphTimer++;
      }
      else if (regrowthInfoType == BADGE_STAR_INFO){

      }
    }
    
    //Update the population bar graph size
    
    if(_ecosystem._fishCount[SARDINE] > Ecosystem.MAX_SARDINE){
      sardineBar.height =  Ecosystem.MAX_SARDINE* sardineBarMult;
    }
    else{
      sardineBar.height = _ecosystem._fishCount[SARDINE] * sardineBarMult;
    }
    sardineIcon.y = sardineBar.y - sardineBar.height - sardineIcon.height;
    
    
    if(_ecosystem._fishCount[TUNA] > Ecosystem.MAX_TUNA){
      tunaBar.height = Ecosystem.MAX_TUNA* tunaBarMult;
    }
    else{
      tunaBar.height = _ecosystem._fishCount[TUNA] * tunaBarMult;
    }
    tunaIcon.y = tunaBar.y - tunaBar.height - tunaIcon.height;
    
    if(_ecosystem._fishCount[SHARK] > Ecosystem.MAX_SHARK){
      sharkBar.height = Ecosystem.MAX_SHARK* sharkBarMult;
    }
    else{
      sharkBar.height = _ecosystem._fishCount[SHARK]* sharkBarMult;
    }
    sharkIcon.y = sharkBar.y - sharkBar.height - sharkIcon.height;
    
    gameIDText.text = "Game ID: $gameID";
    return true;
  }
  
  void _setMask() {
    num a = _ecosystem.ecosystemGrade()[0];
    a = 1-a;
    
    _maskTween = new Tween(_mask, 2);
    _maskTween.animate.alpha.to(a);
    _juggler.add(_maskTween);
  }
  
  void _updateMoney() {
    moneyTimer = 0;
    int a = int.parse(teamAMoneyText.text.substring(1));
    int b = int.parse(teamBMoneyText.text.substring(1));

    if (a==teamAMoney) teamAMoneyText.textColor = Color.LightYellow;
    if (b==teamBMoney) teamBMoneyText.textColor = Color.LightYellow;
    
    if (a==teamAMoney && b==teamBMoney) moneyChanged = false;
    else {
      if (a<teamAMoney) {
        teamAMoneyText.textColor = Color.LightGreen;
        if (a<teamAMoney-5) a=a+5;
        else a=a+1;
      } else if (a>teamAMoney){
        teamAMoneyText.textColor = Color.Salmon;
        if (a>teamAMoney+5) a=a-5;
        else a=a-1;
      }
      teamAMoneyText.text = "\$$a";
      
      if (b<teamBMoney) {
        teamBMoneyText.textColor = Color.LightGreen;
        if (b<teamBMoney-5)b=b+5;
        else b=b+1;
      } else if (b>teamBMoney){
        teamBMoneyText.textColor = Color.Salmon;
        if (b>teamBMoney+5) b=b-5;
        else b=b-1;
      }
      teamBMoneyText.text = "\$$b";
    }
  }
  
  void timerSoundFunction(){
    timerSoundChannel = timerSound.play();
  }
  
  void startTimer(){
    timerButtonReady = false;
    clockUpdateTimer = new Timer.periodic(new Duration(milliseconds:250), updateClock);
    
    
    if(phase == FISHING_PHASE){
      curTimer = new Timer(new Duration(milliseconds:FISHING_TIME*1000+250), _nextSeason );
      timerSoundTimer = new Timer(new Duration(milliseconds:FISHING_TIME*1000 -5000), timerSoundFunction);
      clockCounter = FISHING_TIME*1000;
      new Timer(new Duration(milliseconds:FISHING_TIME*1000+250), clockUpdateTimer.cancel);
      new Timer(new Duration(milliseconds:2000),() => timerButtonReady = true);
    }
    else if(phase == REGROWTH_PHASE){
      curTimer = new Timer(new Duration(milliseconds:REGROWTH_TIME*1000 +250), _nextSeason );
      timerSoundTimer = new Timer(new Duration(milliseconds:REGROWTH_TIME*1000 -5000), timerSoundFunction);
      clockCounter = REGROWTH_TIME*1000;
      new Timer(new Duration(milliseconds:REGROWTH_TIME*1000+250), clockUpdateTimer.cancel);
      new Timer(new Duration(milliseconds:5500),() => timerButtonReady = true);
    }
    else if(phase == BUY_PHASE){
      curTimer = new Timer(new Duration(milliseconds:BUYING_TIME*1000+250), _nextSeason );
      timerSoundTimer = new Timer(new Duration(milliseconds:BUYING_TIME*1000 -5000), timerSoundFunction);
      clockCounter = BUYING_TIME*1000;
      new Timer(new Duration(milliseconds:BUYING_TIME*1000+250), clockUpdateTimer.cancel);
      new Timer(new Duration(milliseconds:2000),() => timerButtonReady = true);
    }
    
//    clockUpdateTimer = new Timer.periodic(new Duration(milliseconds:250), updateClock);
    
  }
  
  void updateClock(Timer updater){
    clockCounter -= 250;
//    if(clockCounter <= 0){
//      updater.cancel();
//      return;
//    }
    timerPie.graphics.clear();
    if (phase==FISHING_PHASE) {

      timerPie..graphics.beginPath()
          ..graphics.lineTo(0, timerPieRadius)
          ..graphics.lineTo(timerPieRadius, timerPieRadius)
          ..graphics.arc(0, timerPieRadius, timerPieRadius, 0, 2*math.PI * (clockCounter+0.0)/(FISHING_TIME*1000), false)
          ..graphics.closePath();
    }
    else if(phase==BUY_PHASE){

      timerPie..graphics.beginPath()
          ..graphics.lineTo(0, timerPieRadius)
          ..graphics.lineTo(timerPieRadius, timerPieRadius)
          ..graphics.arc(0, timerPieRadius, timerPieRadius, 0, 2*math.PI * (clockCounter+0.0)/(BUYING_TIME*1000), false)
          ..graphics.closePath();
    }
    else if(phase==REGROWTH_PHASE){
      timerPie..graphics.beginPath()
          ..graphics.lineTo(0, timerPieRadius)
          ..graphics.lineTo(timerPieRadius, timerPieRadius)
          ..graphics.arc(0, timerPieRadius, timerPieRadius, 0, 2*math.PI * (clockCounter+0.0)/(REGROWTH_TIME*1000), false)
          ..graphics.closePath();
    }
    timerPie.graphics.fillColor(Color.Black);
    arrangeTimerUI();
  }

  
  bool endgame(){
    if(round >=MAX_ROUNDS || _ecosystem._fishCount[SARDINE] <=0 || _ecosystem._fishCount[TUNA] <=0 || _ecosystem._fishCount[SHARK] <=0){
      return true;
    }
    else{
      return false;
    }
  }
  
  void _nextSeason() {
    if (phase==FISHING_PHASE) {
      transition = true;
      phase = REGROWTH_PHASE;
      _fleet.returnBoats();
      transition_fishingToRegrowthSound.play();

      _fleet.alpha = 0;
      _fleet.removeBoatsFromTouchables();
      _graphTimer = 0;

      timerGraphicA.graphics.fillColor(Color.DarkRed);
      timerGraphicA.width = REGROWTH_TIMER_WIDTH;
      timerGraphicA.x = width-REGROWTH_TIMER_WIDTH-50;
      timerTextA.text = "Regrowth season";
      
      timerGraphicB.graphics.fillColor(Color.DarkRed);
      timerGraphicB.width = REGROWTH_TIMER_WIDTH;
      timerTextB.text = "Regrowth season";
      
      badge.alpha = 1;
      addChild(badge);
      badge.showBadge();
      transition = false;
//      timerActive = false;
      startTimer();
      
      for(int i = 0; i < _fleet.boats.length; i++){
        _fleet.boats[i]._unloadNet();
      }
      
      if(round == 0){
        for(int i = 0; i < _fleet.boats.length; i++){
          _fleet.boats[i]._promptUserFinished();
        }
      }
    }
    else if (phase==REGROWTH_PHASE) {
      
      logRound();
      
      if(endgame()){
        transition = true;
        logEndGame();
        phase = ENDGAME_PHASE;
        transition_regrowthToEndSound.play();
        
        
        Tween t1 = new Tween (badge, 2, TransitionFunction.linear);
        t1.animate.alpha.to(0);
        t1.onComplete = toEndGameTransitionStageOne;
        _juggler.add(t1);
        
        Tween t2 = new Tween(_ecosystem, 2, TransitionFunction.linear);
        t2.animate.alpha.to(0);
        _juggler.add(t2);
        
        for(int i = 0; i < uiObjects.length; i++){
          Tween t3 = new Tween(uiObjects[i], 2, TransitionFunction.linear);
          t3.animate.alpha.to(0);
          _juggler.add(t3);
        }
        
      }
      else{
        
        transition = true;
        phase = BUY_PHASE;
        transition_regrowthToBuySound.play();
        Tween t1 = new Tween (badge, 2, TransitionFunction.linear);
        t1.animate.alpha.to(0);
        t1.onComplete = toBuyPhaseTransitionStageOne;
        _juggler.add(t1);
        
        fadePieTimer(0,2);
        
        Tween t2 = new Tween(_ecosystem, 2, TransitionFunction.linear);
        t2.animate.alpha.to(0);
        _juggler.add(t2);
        
      }

    } else if (phase==BUY_PHASE) {
      transition = true;
      phase = FISHING_PHASE;
      transition_buyToFishingSound.play();
      teamARoundProfit = 0;
      teamBRoundProfit = 0;
      
      _fleet.teamACaught = 0;
      _fleet.teamBCaught = 0;
      
      _offseason.hideCircles();
      Tween t1 = new Tween(_offseason.dock, .5, TransitionFunction.linear);
      t1.animate.alpha.to(0);
      t1.onComplete = toFishingPhaseStageOne;
      _juggler.add(t1);
      fadePieTimer(0,.5);
      
      Tween t2 = new Tween(_offseason.sellIslandTop, .5, TransitionFunction.linear);
      t2.animate.alpha.to(0);
      _juggler.add(t2);
      
      Tween t3 = new Tween(_offseason.sellIslandBottom, .5, TransitionFunction.linear);
      t3.animate.alpha.to(0);
      _juggler.add(t3);
    }
    
    else if(phase == ENDGAME_PHASE){
      phase = FINALSUMMARY_PHASE;
      _endgame.hide();
//      addChild(_finalSummary);
      _finalSummary.show();
      transition_endToSummarySound.play();
      
    }
    
    else if(phase == TITLE_PHASE){
      _title.hide();
      removeChild(_title);
      phase=FISHING_PHASE;
      arrangeTimerUI();
      transition_titleToFishingSound.play();
      
    }
  }
  
  void toBuyPhaseTransitionStageOne(){
//    _fleet.hideDock();
    
    
    if (contains(badge)) removeChild(badge);
    badge.hideBadge();
    
    if (contains(_teamAGraph)) removeChild(_teamAGraph);
    if (contains(_teamBGraph)) removeChild(_teamBGraph);
    
    timerGraphicA.graphics.fillColor(Color.Green);
    timerGraphicA.width = BUY_TIMER_WIDTH;
    timerGraphicA.x = width-BUY_TIMER_WIDTH-50;
    timerTextA.text = "Offseason";
    
    timerGraphicB.graphics.fillColor(Color.Green);
    timerGraphicB.width = BUY_TIMER_WIDTH;
    timerTextB.text = "Offseason";
    
    _removeOffseason();
    _offseason.y = -height;
    addChild(_offseason);
    
    arrangeUILayers();

   animatePieTimer(-width/2+125, height/2-163,.5);
    
    Tween t1 = new Tween(_offseason, 2.5, TransitionFunction.easeInQuartic);
    t1.animate.y.to(0);
    t1.onComplete = toBuyPhaseTransitionStageTwo;
    Tween t2 = new Tween(_ecosystem, 2.5, TransitionFunction.easeInQuartic);
    t2.animate.y.to(height);
    Tween t3 = new Tween(_background, 2.5, TransitionFunction.easeInQuartic);
    t3.animate.y.to(height);
    _juggler.add(t1);
    _juggler.add(t2);
    _juggler.add(t3);
    
  }
  void toBuyPhaseTransitionStageTwo(){
    _offseason.showCircles();
    fadePieTimer(.9,.5);
    Tween t1 = new Tween(teamAMoneyText, .5, TransitionFunction.linear);
    t1.animate.alpha.to(1);
    _juggler.add(t1);
    
    Tween t2 = new Tween(teamBMoneyText, .5, TransitionFunction.linear);
    t2.animate.alpha.to(1);
    _juggler.add(t2);
    
    transition = false;
//    timerActive = false;
    startTimer();
  }
  
  void toFishingPhaseStageOne(){
    


      timerGraphicA.graphics.fillColor(Color.Green);
      timerGraphicA.width = FISHING_TIMER_WIDTH;
      timerTextA.text = "Fishing season";

      timerGraphicB.graphics.fillColor(Color.Green);
      timerGraphicB.width = FISHING_TIMER_WIDTH;
      timerTextB.text = "Fishing season";

      _offseason.sendBoatsToFish();
      animatePieTimer(width/2-125, -height/2+163, .750);
      
      Timer timer = new Timer(const Duration(milliseconds: 750), toFishingPhaseStageTwo);
      
      Tween t1 = new Tween(roundNumber, .5, TransitionFunction.linear);
      t1.animate.alpha.to(0);
      _juggler.add(t1);

  }
  
  void toFishingPhaseStageTwo(){
    
    
    
    Tween t1 = new Tween(_offseason, 2.5, TransitionFunction.easeInQuartic);
    t1.animate.y.to(-height);
    t1.onComplete = _removeOffseason;
    Tween t2 = new Tween(_ecosystem, 2.5, TransitionFunction.easeInQuartic);
    t2.animate.y.to(0);
    t2.onComplete = toFishingPhaseStageThree;
    Tween t3 = new Tween(_background, 2.5, TransitionFunction.easeInQuartic);
    t3.animate.y.to(0);
    
    round++;
    roundNumber.text = "${round+1}/5";
    
//    Tween t4 = new Tween(roundNumber, .5, TransitionFunction.linear);
//    t4.animate.alpha.to(.7);
    
    
    _juggler.add(t1);
    _juggler.add(t2);
    _juggler.add(t3);
//    _juggler.add(t4);

      
  }
  
  void toFishingPhaseStageThree(){
    _fleet.reactivateBoats();
    _fleet.returnBoats();
//    _fleet.showDock();
    _fleet.addBoatsToTouchables();
    Tween t1 = new Tween(_fleet, 1, TransitionFunction.linear);
    t1.animate.alpha.to(1);
    _juggler.add(t1);
    
    fadePieTimer(.7, 1);
    
    Tween t2 = new Tween(_ecosystem, 1, TransitionFunction.linear);
    t2.animate.alpha.to(1);
    _juggler.add(t2);
    transition = false;
//    timerActive = false;
    startTimer();
  }
 
  void toEndGameTransitionStageOne(){
    _endgame.alpha = 1;
    _endgame.showGameOverReason();
  }
  
  
  void _removeOffseason() {
    if (contains(_offseason)) removeChild(_offseason);
          _offseason = new Offseason(_resourceManager, _juggler, this, _fleet);
  }
  
  void _redrawGraph() {
    if (contains(_teamAGraph)) removeChild(_teamAGraph);
    if (contains(_teamBGraph)) removeChild(_teamBGraph);
    _teamAGraph = new Graph(_resourceManager, _juggler, this, _ecosystem, true);
    _teamAGraph.x = width/2 + _teamAGraph.width/2;
    _teamAGraph.y = height/4;
    _teamAGraph.rotation = math.PI;
    _teamBGraph = new Graph(_resourceManager, _juggler, this, _ecosystem, true);
    _teamBGraph.x = width/2 - _teamBGraph.width/2;
    _teamBGraph.y = height*3/4;
    _graphTimer = 0;
    addChild(_teamAGraph);
    addChild(_teamBGraph);
  }
  
  void _timerButtonPressed(var e){
    
    if(!gameStarted || transition || !timerButtonReady) return;
    if (timerButtonBool){
      timerButtonBool = false;
      try{
        timerSoundChannel.stop();
      }
      catch(e){};
      try{
      timerSoundTimer.cancel();
      curTimer.cancel();
      clockUpdateTimer.cancel();
      _ecosystem.timerSkipped();
      }
      catch(e){};
      ui_tapTimerSound.play();
      _nextSeason();
      timerButtonReady = false;
    }
    else{
      timerButtonBool = true;
      new Timer(new Duration(milliseconds:500), toggleTimerBool);
    }
  }
  
  void toggleTimerBool(){
   timerButtonBool = false;
  }
  
  void _loadTextAndShapes() {
    
    //Text Elements for Team Money
    TextFormat format = new TextFormat("Arial", 40, Color.LightYellow, align: "center", bold:true);
    teamAMoneyText = new TextField("\$$teamAMoney", format);
    teamAMoneyText..width = 150
                  ..x = width~/2+teamAMoneyText.width~/2
                  ..y = 60
                  ..rotation = math.PI;
//    addChild(teamAMoneyText);
//    uiObjects.add(teamAMoneyText);
    
    teamBMoneyText = new TextField("\$$teamBMoney", format);
    teamBMoneyText..width = 150
                  ..x = width~/2-teamBMoneyText.width~/2
                  ..y = height-60;
//    addChild(teamBMoneyText);
//    uiObjects.add(teamBMoneyText);
    
    //Text Elements for Team Cummulative Score
    teamAScoreText = new TextField("Score: ${teamAScore}", format);
    teamAScoreText..width = 200
                  ..x = width/2 - teamAMoneyText.width/2+10
                  ..y = 60
                  ..rotation = math.PI;
//    addChild(teamAScoreText);
//    uiObjects.add(teamAScoreText);

    teamBScoreText = new TextField("Score: ${teamAScore}", format);
    teamBScoreText..width = 200
                  ..x = width/2 + teamBMoneyText.width/2+10
                  ..y = height - 60;
//    addChild(teamBScoreText);
//    uiObjects.add(teamBScoreText);
    
    
    
    //Text and Shapes for Bar Timers
    timerGraphicA = new Shape();
    timerGraphicA..graphics.rect(0, 0, FISHING_TIMER_WIDTH, 10)
                 ..x = width-FISHING_TIMER_WIDTH-50
                 ..width = FISHING_TIMER_WIDTH
                 ..y = 20
                 ..graphics.fillColor(Color.LightGreen);
    
    
    format = new TextFormat("Arial", 14, Color.LightYellow, align: "left");
    timerTextA = new TextField("Fishing season", format);
    timerTextA..x = width-50
              ..y = 55
              ..rotation = math.PI
              ..width = 200;
    

    timerGraphicB = new Shape();
    timerGraphicB..graphics.rect(0, 0, FISHING_TIMER_WIDTH, 10)
                 ..x = 50
                 ..y = height-20
                 ..graphics.fillColor(Color.LightGreen);
    
    

    timerTextB = new TextField("Fishing season", format);
    timerTextB.x = 50;
    timerTextB.y = height-45;
    timerTextB.width = 200;
    
    
    
    //Text and Shapes for Pie Timer
    
    timerPie = new Shape();
    timerPie..graphics.beginPath()
            ..x = width - 130
            ..y = 65
            ..graphics.lineTo(0, timerPieRadius)
            ..graphics.lineTo(timerPieRadius, timerPieRadius)
            ..graphics.arc(0, timerPieRadius, timerPieRadius, 0, 2*math.PI, false)
            ..graphics.closePath()
            ..graphics.fillColor(Color.Black)
            ..alpha = .70;
        
    pieTimerBitmap = new Bitmap(_resourceManager.getBitmapData("timer"));
//    pieTimerBitmap.rotation = math.PI/4;
    pieTimerBitmap.alpha = timerPie.alpha+10;
    pieTimerBitmap.x = timerPie.x - pieTimerBitmap.width/2;
    pieTimerBitmap.y = timerPie.y-10;
    
    format = new TextFormat("Arial", 28, Color.White, align: "center", bold:true);
    
    roundTitle = new TextField(" Round:", format);
    roundTitle..x = timerPie.x+ 40
              ..y = timerPie.y+40
              ..alpha = .7
              ..width = 300
              ..pivotX = roundTitle.width/2
              ..rotation = math.PI/4;
    
    format = new TextFormat("Arial", 70, Color.White, align: "center", bold:true);
    roundNumber = new TextField("${round+1}/5", format);
    roundNumber..x = timerPie.x +20
               ..y = timerPie.y + 65
                   ..alpha = .7
               ..alpha = .7
               ..width = 300
               ..pivotX = roundNumber.width/2
               ..rotation = math.PI/4; 
    
    format = new TextFormat("Arial", 65, Color.White, align: "center", bold:true);
    roundNumberDiv = new TextField("", format);
    roundNumberDiv..x = timerPie.x +15
               ..y = timerPie.y + 95
               ..alpha = .7
               ..width = 300
               ..pivotX = roundNumberDiv.width/2
               ..rotation = math.PI/4; 
    
    format = new TextFormat("Arial", 15, Color.White, align: "center", bold:true);
    seasonTitle = new TextField("Double Tap to\nSkip Forward", format);
    seasonTitle..x = timerPie.x - 20 -50
               ..y = timerPie.y + 115 + 50
               ..alpha = .7
               ..width = 300
               ..pivotX = seasonTitle.width/2
               ..rotation = math.PI/4; 
    
    pieTimerBitmapButton = new Bitmap(_resourceManager.getBitmapData("timer"));
    pieTimerBitmapButton.rotation = math.PI/4;
    pieTimerBitmapButton.alpha = 0;
    pieTimerBitmapButton.x = timerPie.x +24;
    pieTimerBitmapButton.y = timerPie.y - 64;
    
//    Bitmap pieTimerBitmapButtonGlow = new Bitmap(_resourceManager.getBitmapData("timerGlow"));
//    pieTimerBitmapButtonGlow.rotation = math.PI/4;
//    pieTimerBitmapButtonGlow.alpha = 1;
//    pieTimerBitmapButtonGlow.x = timerPie.x +22;
//    pieTimerBitmapButtonGlow.y = timerPie.y - 62;
    
    timerButton = new SimpleButton(pieTimerBitmapButton, pieTimerBitmapButton, pieTimerBitmapButton, pieTimerBitmapButton);
    timerButton.addEventListener(MouseEvent.MOUSE_DOWN, _timerButtonPressed);
    timerButton.addEventListener(TouchEvent.TOUCH_TAP, _timerButtonPressed);
    timerButton.addEventListener(TouchEvent.TOUCH_BEGIN, _timerButtonPressed);
        
    if(timerType == BAR_TIMER){
      addChild(timerGraphicA);
      addChild(timerTextA);
      addChild(timerGraphicB);
      addChild(timerTextB);
      
      uiObjects.add(timerGraphicA);
      uiObjects.add(timerTextA);
      uiObjects.add(timerGraphicB);
      uiObjects.add(timerTextB);
    }
    else if(timerType == PIE_TIMER){
      addChild(timerPie);
      addChild(pieTimerBitmap);
      addChild(roundTitle);
      addChild(roundNumber);
      addChild(roundNumberDiv);
      addChild(seasonTitle);
      addChild(timerButton);
      
      uiObjects.add(timerPie);
      uiObjects.add(pieTimerBitmap);
      uiObjects.add(roundTitle);
      uiObjects.add(roundNumber);
      uiObjects.add(roundNumberDiv);
      uiObjects.add(seasonTitle);
      uiObjects.add(timerButton);
    }
    
    
    num sardineMultiplier = sardineBarMult;
    num tunaMultiplier = tunaBarMult;
    num sharkMulitplier = sharkBarMult;
    num barWidth = 45;
    //Text and Shapes for population bar graph
    sardineBar = new Shape();
    sardineBar..graphics.rect(0, 0, barWidth, -_ecosystem._fishCount[SARDINE]*sardineMultiplier)
              ..x  = 20
              ..y = height - 20
              ..alpha = .6
              ..graphics.fillColor(Color.Salmon);
    addChild(sardineBar);
    uiObjects.add(sardineBar);
    
    sardineOutline = new Shape();
    sardineOutline..graphics.rect(0, 0, barWidth, -(Ecosystem.MAX_SARDINE)*sardineMultiplier)
                  ..x = 20
                  ..y = height - 20
                  ..alpha = 1
                  ..graphics.strokeColor(Color.Salmon,3);
    addChild(sardineOutline);
    uiObjects.add(sardineOutline);
    
    sardineIcon = new Bitmap(_resourceManager.getBitmapData("sardineIcon"));
    sardineIcon.x = sardineBar.x+7;
    sardineIcon.y = sardineBar.y - sardineBar.height - sardineIcon.height; 
    addChild(sardineIcon);
    uiObjects.add(sardineIcon);
    
    
    tunaBar = new Shape();
    tunaBar..graphics.rect(0, 0, barWidth, -_ecosystem._fishCount[TUNA]*tunaMultiplier)
              ..x  = 20 + barWidth
              ..y = height - 20
              ..alpha = .6
              ..graphics.fillColor(Color.Orange);
    addChild(tunaBar);
    uiObjects.add(tunaBar);
    
    
    tunaOutline = new Shape();
    tunaOutline..graphics.rect(0, 0, barWidth, -Ecosystem.MAX_TUNA*tunaMultiplier)
                  ..x = 20 + barWidth
                  ..y = height - 20
                  ..alpha = 1
                  ..graphics.strokeColor(Color.Orange,3);
    addChild(tunaOutline);
    uiObjects.add(tunaOutline);
    
    tunaIcon = new Bitmap(_resourceManager.getBitmapData("tunaIcon"));
    tunaIcon.x = tunaBar.x+5;
    tunaIcon.y = tunaBar.y - tunaBar.height - tunaIcon.height; 
    addChild(tunaIcon);
    uiObjects.add(tunaIcon);
    
    sharkBar = new Shape();
    sharkBar..graphics.rect(0, 0, barWidth, -_ecosystem._fishCount[SHARK]*sharkMulitplier)
              ..x  = 20+2*barWidth
              ..y = height - 20
              ..alpha = .6
              ..graphics.fillColor(Color.Yellow);
    addChild(sharkBar);
    uiObjects.add(sharkBar);
    
    sharkOutline = new Shape();
    sharkOutline..graphics.rect(0, 0, barWidth, -Ecosystem.MAX_SHARK*sharkMulitplier)
                  ..x = 20+2*barWidth
                  ..y = height - 20
                  ..alpha = 1
                  ..graphics.strokeColor(Color.Yellow,3);
    addChild(sharkOutline);
    uiObjects.add(sharkOutline);
    
    sharkIcon = new Bitmap(_resourceManager.getBitmapData("sharkIcon"));
    sharkIcon.x = sharkBar.x+2;
    sharkIcon.y = sharkBar.y - sharkBar.height - sharkIcon.height; 
    addChild(sharkIcon);
    uiObjects.add(sharkIcon);
    
    format = new TextFormat("Arial", 10, Color.White, align: "center");
    
    
    gameIDText = new TextField("Game ID: ", format);
    gameIDText..x = 75
              ..y = height -20
              ..alpha = .7
              ..width = 300
              ..pivotX = roundTitle.width/2
              ..rotation = 0;
//    addChild(gameIDText);
//    uiObjects.add(gameIDText);
    
  }
  
  void arrangeUILayers(){
    
    num offseasonIndex = getChildIndex(_offseason);
    num minUIelementIndex = offseasonIndex;
    DisplayObject toSwap = null;
    
    for(int i = 0; i < uiObjects.length;i++){
      if(getChildIndex(uiObjects[i]) < minUIelementIndex){
        minUIelementIndex = getChildIndex(uiObjects[i]);
        toSwap = uiObjects[i];
      }
    }
    
    if(toSwap == null) return;
    else{
      swapChildren(_offseason, toSwap);
    }
    
  }
  void arrangeTimerUI(){
    int min = getChildIndex(timerPie);
    DisplayObject lowest;
    if( min > getChildIndex(pieTimerBitmap)){
      min = getChildIndex(pieTimerBitmap);
      lowest = pieTimerBitmap;
    }
    if(min >  getChildIndex(roundNumber)){
      min = getChildIndex(roundNumber);
      lowest = roundNumber;
    }
    if(min >  getChildIndex(roundNumberDiv)){
      min = getChildIndex(roundNumberDiv);
      lowest = roundNumberDiv;
    }
    if(min > getChildIndex(seasonTitle)){
      min = getChildIndex(seasonTitle);
      lowest = seasonTitle;
    }
    if(min > getChildIndex(roundTitle)){
      min = getChildIndex(roundTitle);
      lowest = roundTitle;
    }
    if(min > getChildIndex(timerButton)){
      min = getChildIndex(timerButton);
      lowest = timerButton;
    }
    if(lowest != null){
      swapChildren(timerPie, lowest);
    }
    
    if(getChildIndex(pieTimerBitmap) != this.numChildren-2){
      swapChildren(pieTimerBitmap, getChildAt(this.numChildren-2));
    }
    if(getChildIndex(timerButton) != this.numChildren-1){
      swapChildren(timerButton, getChildAt(this.numChildren-1));
    }
  }
  
  void logRound(){
//    RoundLogger curRound;
//    if(round == 0) curRound = datalogger.round0;
//    else if(round == 1) curRound = datalogger.round1;
//    else if(round == 2) curRound = datalogger.round2;
//    else if(round == 3) curRound = datalogger.round3;
//    else if(round == 4) curRound = datalogger.round4;
////    else if(round == 5) curRound = datalogger.round5;
//    else return;
//    
//    curRound.roundTime = totalTimeCounter;
//    curRound.starRating = badge.rating;
//    curRound.sardineCount = _ecosystem._fishCount[Ecosystem.SARDINE];
//    curRound.tunaCount = _ecosystem._fishCount[Ecosystem.TUNA];
//    curRound.sharkCount = _ecosystem._fishCount[Ecosystem.SHARK];
//    curRound.sardineStatus = badge.sardineRating;
//    curRound.tunaStatus = badge.tunaRating;
//    curRound.sharkStatus = badge.sharkRating;
//    curRound.teamANetSize = _fleet.teamANetSize;
//    curRound.teamABoatType = _fleet.teamABoatType;
//    curRound.teamASeasonProfit = teamARoundProfit;
//    curRound.teamANumOfFishCaught = _fleet.teamACaught;
//    curRound.teamBNetSize = _fleet.teamBNetSize;
//    curRound.teamBBoatType = _fleet.teamBBoatType;
//    curRound.teamBSeasonProfit = teamBRoundProfit;
//    curRound.teamBNumOfFishCaught = _fleet.teamBCaught;
  }
  
  void logEndGame(){
    
//    if(_ecosystem._fishCount[SARDINE] <= 0){
//      datalogger.reasonLost = 1;
//    }
//    else if(_ecosystem._fishCount[TUNA] <= 0){
//      datalogger.reasonLost = 2;
//    }
//    else if(_ecosystem._fishCount[SHARK] <= 0){
//          datalogger.reasonLost = 3;
//        }
//    else{
//      datalogger.reasonLost = 0;
//    }
//    
//    datalogger.id = gameID;
//    datalogger.totalTime = totalTimeCounter;
//    datalogger.teamAFinalScore = teamAScore;
//    datalogger.teamBFinalScore = teamBScore;
//    datalogger.totalStars = starCount;
//    datalogger.numOfRound = round;
//    
//    datalogger.send();
  }
  
  void  handleMsg(data){
    if(data[0]=="i" && data[1]=="d"){
      var idString = data.substring(4,7);
      num id = int.parse(idString);
      gameID = id;
    }
  }


  void fadePieTimer(val, dt){
    Tween t1 = new Tween(timerPie, dt, TransitionFunction.linear);
    t1.animate.alpha.to(val);
    _juggler.add(t1);
    
    Tween t2 = new Tween(pieTimerBitmap, dt, TransitionFunction.linear);
    if(val != 0){
      t2.animate.alpha.to(1);
    }
    else{
      t2.animate.alpha.to(val);
    }
    _juggler.add(t2);
    
    Tween t3 = new Tween(roundTitle, dt, TransitionFunction.linear);
    t3.animate.alpha.to(val);
    _juggler.add(t3);
    
    Tween t4 = new Tween(roundNumber, dt, TransitionFunction.linear);
    t4.animate.alpha.to(val);
    _juggler.add(t4);
    
    Tween t5 = new Tween(roundNumberDiv, dt, TransitionFunction.linear);
    t5.animate.alpha.to(val);
    _juggler.add(t5);
    
    Tween t6 = new Tween(seasonTitle, dt, TransitionFunction.linear);
    t6.animate.alpha.to(val);
    _juggler.add(t6);
    
  }

  void animatePieTimer(dx, dy, dt){
      Tween t1 = new Tween(timerPie, dt, TransitionFunction.linear);
      t1.animate.x.by(dx);
      t1.animate.y.by(dy);
      _juggler.add(t1);
      
      Tween t2 = new Tween(pieTimerBitmap, dt, TransitionFunction.linear);
      t2.animate.x.by(dx);
      t2.animate.y.by(dy);
      _juggler.add(t2);
      
      Tween t3 = new Tween(roundTitle, dt, TransitionFunction.linear);
      t3.animate.x.by(dx);
      t3.animate.y.by(dy);
      _juggler.add(t3);
      
      Tween t4 = new Tween(roundNumber, dt, TransitionFunction.linear);
      t4.animate.x.by(dx);
      t4.animate.y.by(dy);
      _juggler.add(t4);
      
      Tween t5 = new Tween(roundNumberDiv, dt, TransitionFunction.linear);
      t5.animate.x.by(dx);
      t5.animate.y.by(dy);
      _juggler.add(t5);
      
      Tween t6 = new Tween(seasonTitle, dt, TransitionFunction.linear);
      t6.animate.x.by(dx);
      t6.animate.y.by(dy);
      _juggler.add(t6);
      
      Tween t7 = new Tween(timerButton, dt, TransitionFunction.linear);
      t7.animate.x.by(dx);
      t7.animate.y.by(dy);
      _juggler.add(t7);
      
      arrangeTimerUI();
     
      
  }
}