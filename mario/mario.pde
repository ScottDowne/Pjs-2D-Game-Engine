/**
 * We must set the screen dimensions to something
 */
final int BLOCK = 16,
          screenWidth = 32*BLOCK,
          screenHeight = 27*BLOCK;

/**
 * Gravity consists of a uniform downforce,
 * and a gravitational acceleration
 */
float DOWN_FORCE = 2;
float ACCELERATION = 1.3;
float DAMPENING = 0.75;


/**
 * initializing means building an "empty"
 * level, which we'll 
 */
void initialize() {
  SoundManager.mute(false);
  frameRate(30);
  reset();
}

void reset() {
  clearLevels();
  addLevel("MainLevel", new MainLevel(4*width, height));  
}




