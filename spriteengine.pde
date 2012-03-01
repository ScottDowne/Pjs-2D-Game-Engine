// ====== LET'S GET OUR NINTENDO ON! ======

// This value determines how much we "slide" when we walk
float DAMPENING = 0.75;

// This value determines how much 'gravity' we experience
float DOWN_FORCE = 0.7;

// This value determines how strong gravity's hold on us is.
// The higher the value, the more speed we pick up as we fall.
float ACCELERATION = 1.3;

// and this is the level we'll be playing.
Level level;

// boilerplate
void setup() {
  size(512,432);
  frameRate(24);
  // set up the sound manager
  SoundManager.init(this);
  // It is essential that this is called
  // before any sprites are made:
  SpriteMapHandler.setSketch(this);
  reset();
}

// Render mario in glorious canvas definition
void draw() { if(level.finished && level.swappable) { reset(); } else { level.draw(); }}

void reset() { level = new TestLevel(width, height, 4, 1); }

// pass-through keyboard events
void keyPressed() { level.keyPressed(key,keyCode); }
void keyReleased() { level.keyReleased(key, keyCode); }
void mousePressed() { level.mousePressed(mouseX, mouseY); }


// ========== TEST LEVEL CODE ============


/**
 * The test implementaiton of the Level class
 * models the first normal level of Super Mario
 * World, "Yoshi's Island 1". With some liberties
 * taken, because this is a test.
 */
class TestLevel extends Level {
  // local handle for the mario sprite
  Player mario;

  // crucial pickup - it wins us the level.
  Pickup finishline;

  // what we see when we win  
  String wintext = "Goal!";
  int endCount = 0;

  /**
   * Test level implementation
   */
  TestLevel(float w, float h, int x_repeat, int y_repeat)
  {
    super(w*x_repeat, h*y_repeat);
    textFont(createFont("fonts/acmesa.ttf",62));
    setBackground();
    addGround();
    addBushes();
    addCloudPlatforms();
    addBlockPlatforms();
    addCoinBlocks();
    addCoins();
    addDragonCoins();
    addFlyingKoopas();
    addGoal();
    setViewBox(0,0,w,h);   
  }

  // the background is a sprite
  void setBackground() {
    Sprite bgsprite = new Sprite("graphics/backgrounds/sky.gif");
    bgsprite.align(RIGHT, TOP);
    TilingSprite backdrop = new TilingSprite(bgsprite, 0, 0, width, height);
    addStaticSpriteBG(backdrop);
    SoundManager.load(this, "audio/bg/Overworld.mp3");
    SoundManager.play(this);
  }

  // "ground" parts of the level
  void addGround() {
    int width = 512;

    // some random platforms
    addGroundPlatform(928, 432/2, 96, 116);
    addGroundPlatform(920, 432/2+48, 32, 70);
    addGroundPlatform(912, 432/2 + 100, 128, 86);
    addGroundPlatform(912+64, 432/2 + 130, 128, 50);

    addSlant(width/2, height-48);
    addSlant(1300, height-48);
    addSlant(1350, height-48);

    addGroundPlatform(1442, 432/2 + 100, 128, 86);
    addGroundPlatform(1442+64, 432/2 + 130, 128, 50);

    // top of the ground
    Sprite groundsprite = new Sprite("graphics/backgrounds/ground-top.gif");
    TilingSprite groundline = new TilingSprite(groundsprite, 0, height-40, this.width+groundsprite.width, height - 40 + groundsprite.height);
    addStaticSpriteBG(groundline);
    // ground filler
    TilingSprite groundfiller = new TilingSprite(new Sprite("graphics/backgrounds/ground-filler.gif"), 0, height-40 + groundsprite.height, this.width+groundsprite.width, height);
    addStaticSpriteBG(groundfiller);
    // basic boundary
    addBoundary(new Boundary(0,height-48,this.width,height-48));

  }
  
  // the angled bit of sticking-out-ground
  void addSlant(float x, float y) {
    Sprite groundslant = new Sprite("graphics/backgrounds/ground-slant.gif");
    groundslant.align(RIGHT,TOP);
    groundslant.setPosition(x, y - groundslant.height);
    addStaticSpriteBG(groundslant);
    addBoundary(new Boundary(x, y + 48 - groundslant.height, x + 48, y - groundslant.height));
  }

  // add the various ground platforms
  void addGroundPlatform(float x, float y, float w, float h) {
    // top layer
    Sprite lc = new Sprite("graphics/backgrounds/ground-corner-left.gif");
    Sprite tp = new Sprite("graphics/backgrounds/ground-top.gif");
    Sprite rc = new Sprite("graphics/backgrounds/ground-corner-right.gif");
    lc.setPosition(x,y);
    rc.setPosition(x+w-rc.width,y);
    TilingSprite toprow = new TilingSprite(tp, x+lc.width, y, x+(w-rc.width), y+tp.height);

    addStaticSpriteBG(lc);
    addStaticSpriteBG(toprow);
    addStaticSpriteBG(rc);
    addBoundary(new Boundary(x-lc.width/2, y-tp.height/2, x+w-rc.width/2, y-tp.height/2));

    // sides/filler
    Sprite ls = new Sprite("graphics/backgrounds/ground-side-left.gif");
    Sprite rs = new Sprite("graphics/backgrounds/ground-side-right.gif");
    Sprite fl = new Sprite("graphics/backgrounds/ground-filler.gif");

    TilingSprite sideleft  = new TilingSprite(ls, x, y+lc.height, x+ls.width, y+h-lc.height);
    TilingSprite sideright = new TilingSprite(rs, x+w-rc.width, y+rc.height, x+w, y+h-rc.height);
    TilingSprite filler    = new TilingSprite(fl, x+ls.width, y+ls.height, x+(w-fl.width), y+(h-fl.height));

    addStaticSpriteBG(sideleft);
    addStaticSpriteBG(filler);
    addStaticSpriteBG(sideright);
  }

  // add some mario-style bushes
  void addBushes() {
    int width = 512;

    // one bush, composed of four segmetns (sprites 1, 3, 4 and 5)
    int[] bush = {1, 3, 4, 5};
    for(int i=0, xpos=0, end=bush.length; i<end; i++) {
      Sprite sprite = new Sprite("graphics/backgrounds/bush-0"+bush[i]+".gif");
      xpos += sprite.width;
      sprite.align(CENTER,BOTTOM);
      sprite.setPosition(width/4.4 + xpos, height-48);
      addStaticSpriteFG(sprite); }

    // two bush, composed of eight segments
    bush = new int[]{1, 2, 4, 2, 3, 4, 2, 5};
    for(int i=0, xpos=0, end=bush.length; i<end; i++) {
      Sprite sprite = new Sprite("graphics/backgrounds/bush-0"+bush[i]+".gif");
      xpos += sprite.width;
      sprite.align(CENTER,BOTTOM);
      sprite.setPosition(3*width/4 + xpos, height-48);
      addStaticSpriteFG(sprite); }

    // three bush
    bush = new int[]{1, 3, 4, 5};
    for(int i=0, xpos=0, end=bush.length; i<end; i++) {
      Sprite sprite = new Sprite("graphics/backgrounds/bush-0"+bush[i]+".gif");
      xpos += sprite.width;
      sprite.align(CENTER,BOTTOM);
      sprite.setPosition(868 + xpos, height-48);
      addStaticSpriteFG(sprite); }

    // four bush
    bush = new int[]{1, 2, 4, 3, 4, 5};
    for(int i=0, xpos=0, end=bush.length; i<end; i++) {
      Sprite sprite = new Sprite("graphics/backgrounds/bush-0"+bush[i]+".gif");
      xpos += sprite.width;
      sprite.align(CENTER,BOTTOM);
      sprite.setPosition(1344 + xpos, height-48);
      addStaticSpriteFG(sprite); }
  }

  // clouds platforms!
  void addCloudPlatforms() {
    addBoundary(new Boundary(54 +   0, 96 +   0, 105 +   0, 96 +   0));
    addBoundary(new Boundary(54 + 256, 96 + 192, 105 + 256, 96 + 192));
    addBoundary(new Boundary(54 + 336, 96 + 208, 105 + 336, 96 + 208));
    addBoundary(new Boundary(54 + 138, 96 + 144, 105 + 112, 96 + 144));
    addBoundary(new Boundary(54 + 186, 96 + 160, 105 + 160, 96 + 160));
    addBoundary(new Boundary(54 + 330, 96 + 256, 105 + 322, 96 + 256));
  }

  // standard blocks
  void addBlockPlatforms() {
    Sprite block = new Sprite("graphics/assorted/Block.gif");
    TilingSprite blockrow = new TilingSprite(block, 1064, 264, 1064 + 14*block.width, 264+block.height);
    addStaticSpriteBG(blockrow);
    addBoundary(new Boundary(1064-block.width/2, 264 - block.height/2, 1064 + 14*block.width - block.width/2, 264 - block.height/2));
  }
  
  // coin blocks
  void addCoinBlocks() {
    CoinBlock cb = new CoinBlock(338,248);
    addInteractor(cb);
    addBoundary(new Boundary(338-cb.width/2, 248-cb.height/2-1,338+cb.width/2,248-cb.height/2-1));
  }

  // add some coins
  void addCoins() {
    addCoin(80,96);

    int set = 0;
    addCoin(600+48*set++, height-48);
    addCoin(600+48*set++, height-48);
    addCoin(600+48*set++, height-48);
    addCoin(600+48*set++, height-48);
    addCoin(600+48*set++, height-48);
    addCoin(600+48*set++, height-48);
    
    addCoin(1448,316);
    addCoin(1448+84,316);
  }

  // convenient shortcut method for placing three coins at once
  void addCoin(float x, float y) {
    addForPlayerOnly(new Coin(x-16, y - 40));
    addForPlayerOnly(new Coin(   x, y - 40));
    addForPlayerOnly(new Coin(x+16, y - 40));
  }

  // add some mysterious coins
  void addDragonCoins() {
    addForPlayerOnly(new DragonCoin(972, 264));
    addForPlayerOnly(new DragonCoin(1490, 256));
  }

  // add some flying koopas
  void addFlyingKoopas() {
    for(int i=0; i<3; i++) {
      FlyingKoopa fk = new FlyingKoopa(150,175 + i*30);
      fk.active.sprite.setPathOffset(i*40);
      addInteractor(fk);
    }
  }
  
  // the end!
  void addGoal() {
    int xpos = 1850;
    // background post
    Sprite goal_b = new Sprite("graphics/assorted/Goal-back.gif");
    goal_b.align(CENTER,BOTTOM);
    goal_b.setPosition(xpos,height-47);
    addStaticSpriteBG(goal_b);
    // foreground post
    Sprite goal_f = new Sprite("graphics/assorted/Goal-front.gif");
    goal_f.align(CENTER,BOTTOM);
    goal_f.setPosition(xpos+32,height-47);
    addStaticSpriteFG(goal_f);
    // the finish line rope
    finishline = new Rope(xpos+24,height-47-16);
    SoundManager.load(finishline, "audio/bg/Course-clear.mp3");
    addForPlayerOnly(finishline);
  }

  /**
   * End the level.
   */
  void end() {
    super.finish();
    SoundManager.pause(this);
  }

  /**
   * What do we do when the level
   * finishes properly?
   */
  void finish() {
    end();
    SoundManager.play(finishline);
  }

  /**
   * Render mario in glorious canvas definition
   */
  void draw() {
    // Normal level draw
    if(!finished) {
      // make sure we always have a Mario!
      if(players.size()==0) {
        mario = new Mario();
        mario.setPosition(32, 383);
        addPlayer(mario);
      }
  
      // blue background color
      background(0,100,190);
  
      // draw the level content
      super.draw();
  
      // disallow running past the edges
      if(mario.x<mario.width/2) { mario.x=mario.width/2; }
      if(mario.x>width-mario.width/2) { mario.x=width-mario.width/2; }
      // slide viewbox
      if(0 <= viewbox.x && viewbox.x <= this.width - viewbox.w) {
        viewbox.x = (int)(mario.x-432/2);
        viewbox.x = constrain(viewbox.x, 0, this.width - viewbox.w); }
  
      if(javascript!=null) {
        javascript.setCoordinate(mario.x, mario.y); }
    }

    // After mario's won, fade to black with
    // the win text in white. After 4 seconds,
    // signal that this level can be swapped out.
    else {
      endCount++;
      fill(255);
      text(wintext,(512-textWidth(wintext))/2, 192);
      fill(0,8);
      rect(0,0,width,height);
      if(endCount>7.5*frameRate) {
        SoundManager.stop(this);
        SoundManager.stop(finishline);
        setSwappable();
      }
    }
  }

  /**
   * For fun, let's add some koopa troopers
   * every time we click on the screen!
   */
  void mousePressed(int mx, int my) {
    if(mouseButton == LEFT) {
      Koopa koopa = new Koopa(mx + viewbox.x, my + viewbox.y);
      koopa.addForces(-0.2,0);
      addInteractor(koopa); }
    else if(mouseButton == RIGHT) {
      addForPlayerOnly(new Mushroom(mx + viewbox.x, my + viewbox.y));
    }
  }
}


// ========== TEST ACTOR: MARIO ============


/**
 * Mario, that lovable, portly, moustachioed man.
 */
class Mario extends Player {

  // every 'step' has an impulse of 1.3
  float speedStep = 1.3;

  // jumping uses an impulse 19 times that of a step
  float speedHeight = 21;

  /**
   * The Mario constructor
   */
  Mario() {
    super("Mario", DAMPENING, DAMPENING);
    setForces(0, DOWN_FORCE);
    setAcceleration(0, ACCELERATION);
    setupStates();
  }

  /**
   * Set up a number of states for Mario to be in.
   */
  void setupStates() {
    // Load mario from his "small" sprite set, for now.
    String sizeSet = "small";

    // when not moving
    State standing = new State("standing","graphics/mario/"+sizeSet+"/Standing-mario.gif");
    standing.sprite.align(CENTER, BOTTOM);
    addState(standing);

    // when either running right or left
    State running = new State("running","graphics/mario/"+sizeSet+"/Running-mario.gif",1,4);
    running.sprite.align(CENTER, BOTTOM);
    running.sprite.setAnimationSpeed(0.75);
    addState(running);

    // when [down] is pressed
    State crouching = new State("crouching","graphics/mario/"+sizeSet+"/Crouching-mario.gif");
    crouching.sprite.align(CENTER, BOTTOM);
    addState(crouching);

    // when [up] is pressed
    State looking = new State("looking","graphics/mario/"+sizeSet+"/Looking-mario.gif");
    looking.sprite.align(CENTER, BOTTOM);
    addState(looking);

    // when pressing the A (jump) button
    State jumping = new State("jumping","graphics/mario/"+sizeSet+"/Jumping-mario.gif");
    jumping.sprite.align(CENTER, BOTTOM);
    jumping.sprite.addPathLine(0,0,1,1,0,  0,0,1,1,0,  24);
    SoundManager.load(jumping, "audio/Jump.mp3");
    addState(jumping);

    // when pressing the A button while crouching
    State crouchjumping = new State("crouchjumping","graphics/mario/"+sizeSet+"/Crouching-mario.gif");
    crouchjumping.sprite.align(CENTER, BOTTOM);
    crouchjumping.sprite.addPathLine(0,0,1,1,0,  0,0,1,1,0,  24);
    SoundManager.load(crouchjumping, "audio/Jump.mp3");
    addState(crouchjumping);

    // when pressing the B (shoot) button
    State spinning = new State("spinning","graphics/mario/"+sizeSet+"/Spinning-mario.gif",1,4);
    spinning.sprite.align(CENTER, BOTTOM);
    spinning.sprite.addPathLine(0,0,1,1,0,  0,0,1,1,0,  24);
    SoundManager.load(spinning, "audio/Spin jump.mp3");
    addState(spinning);

    // if we mess up, we die =(
    State dead = new State("dead","graphics/mario/"+sizeSet+"/Dead-mario.gif",1,2);
    dead.sprite.align(CENTER, BOTTOM);
    dead.sprite.setAnimationSpeed(0.5);
    dead.sprite.setNoRotation(true);
    dead.sprite.setLooping(false);
    dead.sprite.addPathCurve(0,0,1,1,0,
                             0,-50,
                             0,250,
                             0,1200,1,1,0,  72,1);
    SoundManager.load(dead, "audio/Dead mario.mp3");
    addState(dead);

    // Finally, we make sure to start off in the "standing" state
    setCurrentState("standing");
  }

  /**
   * We need to be able to control Mario, so let's
   * define his behaviour based on user input!
   */
  void handleInput() {

    // When the left or right key is presed, we
    // should run. Unless we're stuck in a state
    // that locks us in our place:
    if (active.name != "crouching" && active.name != "looking") {
      if (keyDown[LEFT]) {
        // when we walk left, we need to flip the sprite
        setHorizontalFlip(true);
        // walking left means we get a negative impulse along the x-axis:
        addImpulse(-speedStep, 0);
      }
      if (keyDown[RIGHT]) {
        // when we walk right, we need to NOT flip the sprite =)
        setHorizontalFlip(false);
        // walking right means we get a positive impulse along the x-axis:
        addImpulse( speedStep, 0);
      }
    }

    // Because some states will not allow use to change,
    // such as jump animations, we check whether we're
    // allowed to change our state before we check keys.
    if(active.mayChange())
    {
      // The jump button is pressed! Should we jump? How do we jump?
      if (keyDown[BUTTON_A] && boundary!=null) {
        if (active.name != "jumping" && active.name != "crouchjumping" && active.name != "spinning") {
          // first off, jumps may not auto-repeat, so we lock the jump button
          ignore(BUTTON_A);
          // make sure we unglue ourselves from the platform we're standing on:
          detach();
          // then generate a massive impulse upward:
          addImpulse(0,speedHeight*-speedStep);
          // now, if we're crouching, we need to crouch-jump.
          // Otherwise, we can jump normally.
          if (active.name == "crouching") { setCurrentState("crouchjumping"); }
          else { setCurrentState("jumping"); }
          SoundManager.play(active);
        }
      }

      // The shoot button is pressed! When we don't have a shooty power-up,
      // this makes Mario spin-jump. But should we? And How?
      else if (keyDown[BUTTON_B] && boundary!=null) {
        if (active.name != "jumping" && active.name != "crouchjumping" && active.name != "spinning") {
          // first off, shooting and spin jumping may not auto-repeat, so we lock the shoot button
          ignore(BUTTON_B);
          // make sure we unglue ourselves from the platform we're standing on:
          detach();
          // then generate a massive impulse upward:
          addImpulse(0,speedHeight*-speedStep);
          // and then make sure we spinjump, rather than jump normally
          setCurrentState("spinning");
          SoundManager.play(active);
        }
      }
      // The down button is pressed: crouch
      else if (keyDown[DOWN]) {
        setCurrentState("crouching");
      }
      // The up button is pressed: look up
      else if (keyDown[UP]) {
        setCurrentState("looking");
      }
      // The left and/or right buttons are pressed: run!
      else if (keyDown[LEFT] || keyDown[RIGHT]) {
        setCurrentState("running");
      }
      // okay, nothing's being pressed. Let's just stand there.
      else { setCurrentState("standing"); }
    }
  }

  /**
   * If Mario loses, remove him from the level.
   */
  void handleStateFinished(State which) {
    if(which.name == "dead") {
      // well, we died.. restart!
      level.end();
      level.setSwappable();
    }
  }

  /**
   * When Mario touches down on a platform,
   * which state should he switch to?
   */
  void attachTo(Boundary boundary) {
    super.attachTo(boundary);
    // After crouch-jumping, Mario should be crouching
    if(active.name=="crouchjump") {
      setCurrentState("crouching");
    }
    // after other jumps, he should be standing.
    else {
      setCurrentState("standing");
    }
  }

  /**
   * What happens when we touch another actor?
   */
  void overlapOccuredWith(Actor other, float[] direction) {
    if(other instanceof Koopa) {
      Koopa koopa = (Koopa) other;
      float angle = direction[2];

      // We bopped a koopa on the head!
      float tolerance = radians(75);
      if(PI/2 - tolerance <= angle && angle <= PI/2 + tolerance) {
        boolean shouldJump = koopa.squish();
        if(shouldJump) {
          setImpulse(0,ACCELERATION*speedHeight*-speedStep);
          if(active.name!="spinning") {
            setCurrentState("jumping");
          }
        }
      }

      // Oh no! We missed and touched a koopa!
      else {
        setInteracting(false);
        setCurrentState("dead");
        SoundManager.pause(level);
        SoundManager.play(active);
      }
    }
  }

  /**
   * What happens when we get pickups?
   */
  void pickedUp(Pickup pickup) {
    if(pickup.name=="Regular coin") {
      // increase our score
    }
    else if(pickup.name=="Dragon coin") {
      // increase our secret dragon score
    }
    else if(pickup.name=="Mushroom") {
      // become big!
      powerUp();
    }
  }

  /**
   * This is where we must schedule an actor replacement
   */
  void powerUp() {
    // ... code goes here...
  }
}


// ========== TEST ACTOR: KOOPA ============


/**
 * A red koopa trooper actor
 */
class Koopa extends Interactor {

  /**
   * The constructor for the koopa trooper
   * is essentially the same as for Mario.
   */
  Koopa(float mx, float my) {
    super("Red koopa", DAMPENING, DAMPENING);
    setPosition(mx, my);
    setForces(0, DOWN_FORCE);
    setAcceleration(0, ACCELERATION);
    setupStates();
  }

  /**
   * So, what can koopa troopers do?
   */
  void setupStates() {
    // when walking around
    State walking = new State("walking","graphics/enemies/Red-koopa-walking.gif",1,2);
    walking.sprite.align(CENTER, BOTTOM);
    walking.sprite.setAnimationSpeed(0.25);
    addState(walking);

    // when just standing, doing nothing
    State standing = new State("standing","graphics/enemies/Red-koopa-standing.gif",1,2);
    standing.sprite.align(CENTER, BOTTOM);
    addState(standing);

    // if we get squished, we first get naked...
    State naked = new State("naked","graphics/enemies/Naked-koopa-walking.gif",1,2);
    naked.sprite.setAnimationSpeed(0.25);
    naked.sprite.align(CENTER, BOTTOM);
    SoundManager.load(naked, "audio/Bonk.mp3");
    addState(naked);

    // if we get squished again, we die!
    State dead = new State("dead","graphics/enemies/Dead-koopa.gif");
    dead.sprite.align(CENTER, BOTTOM);
    dead.sprite.addPathLine(0,0,1,1,0,  0,0,1,1,0,  12);
    dead.sprite.setLooping(false);
    SoundManager.load(dead, "audio/Bonk.mp3");
    addState(dead);

//    // by default, the koopa will be walking
    setCurrentState("walking");
  }

  /**
   * Mario squished us! O_O
   *
   * Should we just lose our shell, or have we
   * been properly squished dead?
   */
  boolean squish() {
    // if we're scheduled for removal,
    // don't do anything.
    if(remove) return false;

    // We're okay, we just lost our shell.
    if(active.name != "naked" && active.name != "dead") {
      setCurrentState("naked");
      SoundManager.play(active);
      // mario should jump after trying to squish us
      return true;
    }

    // Ohnoes! we've been squished properly!
    // make sure we stop moving forward
    setForces(0,0);
    setInteracting(false);
    setCurrentState("dead");
    SoundManager.play(active);
    // mario should not jump after deadifying us
    return true;
  }

  /**
   * While we don't let players control koopa troopers... we could!
   */
  void handleInput() {}

  /**
   * "when state finishes" behaviour: when the
   * "blargh, I am dead!" state is done, we need
   * to remove this koopa from the game.
   */
  void handleStateFinished(State which) {
    if(which.name=="dead") {
      removeActor();
    }
  }
}

/**
 * A flying red koopa trooper actor
 */
class FlyingKoopa extends Koopa {
  // are we flying or not?
  boolean flying = true;

  /**
   * The constructor for the koopa trooper
   * is essentially the same as for Mario.
   */
  FlyingKoopa(float mx, float my) {
    super(mx,my);
    setForces(0,0);
    setAcceleration(0,0);
  }

  /**
   * So, what can koopa troopers do?
   */
  void setupStates() {
    super.setupStates();

    // when walking around
    State flying = new State("flying","graphics/enemies/Red-koopa-flying.gif",1,2);
    flying.sprite.align(CENTER, BOTTOM);
    flying.sprite.setAnimationSpeed(0.2);
    flying.sprite.addPathLine(   0,0,1,1,0,
                              -100,0,1,1,0,
                               100);
    flying.sprite.addPathLine(-100,0,1,1,0,
                              -100,0,-1,1,0,
                               5);
    flying.sprite.addPathLine(-100,0,-1,1,0,
                                 0,0,-1,1,0,
                               100);
    flying.sprite.addPathLine(0,0,-1,1,0,
                              0,0,1,1,0,
                              5);
    SoundManager.load(flying, "audio/Bonk.mp3");
    addState(flying);

    // by default, flying koopas fly
    setCurrentState("flying");
  }

  /**
   * When mario squishes us, we lose our wings.
   */
  boolean squish() {
    if(flying) {
      flying = false;
      setForces(-0.2,DOWN_FORCE);
      setAcceleration(0,ACCELERATION);
      SoundManager.play(active);
      setCurrentState("walking");
      return true;
    }
    return super.squish();
  }
}


/**
 * Perhaps unexpected, coin blocks are also
 * interactors. They get bonked just like
 * enemies, and they do things based on the
 * interaction.
 */
class CoinBlock extends Interactor {

  private int content = 8;
  
  /**
   * Coin blocks just hang somewhere.
   */
  CoinBlock(float x, float y) {
    super("Coin block");
    setPosition(x,y);
    setForces(0,0);
    setAcceleration(0,0);
    setupStates();
  }

  /**
   * A coinblock has a rotating sprite
   */
  void setupStates() {
    State hanging = new State("hanging","graphics/assorted/Coin-block.gif",1,4);
    hanging.sprite.setAnimationSpeed(0.25);
    addState(hanging);

    State boing = new State("boing","graphics/assorted/Coin-block.gif",1,4);
    boing.sprite.setAnimationSpeed(0.25);
    boing.sprite.setNoRotation(true);
    boing.sprite.setLooping(false);
    boing.sprite.addPathLine(0,0,1,1,0,
                             0,-8,1,1,0,
                             1);
    boing.sprite.addPathLine(0,-12,1,1,0,
                             0,0,1,1,0,
                             2);
    SoundManager.load(boing, "audio/Coin.mp3");
    addState(boing);

    State exhausted = new State("exhausted","graphics/assorted/Coin-block-exhausted.gif",1,1);
    addState(exhausted);

    setCurrentState("hanging");
  }
  
  void overlapOccuredWith(Actor other, float[] overlap) {
    // stop actor movement
    other.rewind();
    other.ix=0;
    other.iy=0;
    
    // if we're dead, we're dead
    if(content==0 || active.name=="boing") return;
    
    float minv = 3*PI/2 - radians(45);
    float maxv = 3*PI/2 + radians(45);
    if(minv <=overlap[2] && overlap[2]<=maxv) {
      content--;
      setCurrentState("boing");
      SoundManager.play(active);
      Coin coin = new Coin(x,y-30);
      coin.align(CENTER,BOTTOM);
      coin.setImpulse(random(-3,3), -10);
      coin.setImpulseCoefficients(1,DAMPENING);
      coin.setForces(0,DOWN_FORCE);
      coin.setAcceleration(0, ACCELERATION);
      level.addForPlayerOnly(coin);
    }
  }

  void handleStateFinished(State which) {
    if(which.name=="boing") {
      if(content>0) { setCurrentState("hanging"); }
      else { setCurrentState("exhausted"); }
    }
  }
  void handleInput() {}
}


// ==========================


/**
 * regular coin
 */
class Coin extends Pickup {
  Coin(float x, float y) {
    super("Regular coin", "graphics/assorted/Regular-coin.gif", 1, 4, x, y, true);
    SoundManager.load(this, "audio/Coin.mp3");
  }
  void pickedUp() { SoundManager.play(this); }
}

/**
 * dragon coin!
 */
class DragonCoin extends Pickup {
  DragonCoin(float x, float y) {
    super("Dragon coin", "graphics/assorted/Dragon-coin.gif", 1, 10, x, y, true);
    SoundManager.load(this, "audio/Dragon coin.mp3");
  }
  void pickedUp() { SoundManager.play(this); }
}

/**
 * delicious mushroom
 */
class Mushroom extends Pickup {
  Mushroom(float x, float y) {
    super("Mushroom", "graphics/assorted/Mushroom.gif", 1, 1, x, y, false);
    getState("Mushroom").sprite.align(CENTER,BOTTOM);
    // make mushroom gently slide to the right
    setImpulseCoefficients(0,0);
    setForces(2, DOWN_FORCE);
    setAcceleration(0,ACCELERATION);
    updatePositioningInformation();
    SoundManager.load(this, "audio/Powerup.mp3");
  }
  void pickedUp() { SoundManager.play(this); }
}

/**
 * The finish line
 */
class Rope extends Pickup {
  Rope(float x, float y) {
    super("Finish line", "graphics/assorted/Goal-slider.gif", 1, 1, x, y, true);
    Sprite s = getState("Finish line").sprite;
    s.align(LEFT,CENTER);
    s.setNoRotation(true);
    s.addPathLine(0,0,1,1,0,  0,-116,1,1,0, 50);
    s.addPathLine(0,-116,1,1,0,  0,0,1,1,0, 50);
    //SoundManager.add(this, "audio/Finish.mp3");
  }

  void pickedUp() { 
    //SoundManager.play(this); 
    level.finish();
  }
}
