/***************************************
 *                                     *
 *      INTERACTORS: BANZAI BILL       *
 *                                     *
 ***************************************/


/**
 * The big bullet that comes out of nowhere O_O
 */
class BanzaiBill extends Interactor {

  /**
   * Relatively straight-forward constructor
   */
  BanzaiBill(float mx, float my) {
    super("Banzai Bill", 1, 1);
    setPosition(mx, my);
    setImpulse(-0.5, 0);
    setForces(0, 0);
    setAcceleration(0, 0);
    setupStates();
    // Banzai Bills do not care about boundaries or NPCs!
    setPlayerInteractionOnly(true);
  }

  /**
   * Banzai bill flies with great purpose.
   */
  void setupStates() {
    State flying = new State("flying", "graphics/enemies/Banzai-bill.gif");
    SoundManager.load(flying, "audio/Banzai.mp3");
    addState(flying);
    setCurrentState("flying");
    SoundManager.play(flying);
  }

  /**
   * When we hit an actor, they die.
   */
  void overlapOccurredWith(Actor other, float[] overlap) {
    super.overlapOccurredWith(other, overlap);
    if (other instanceof Mario) {
      ((Mario)other).die();
    }
  }
}
