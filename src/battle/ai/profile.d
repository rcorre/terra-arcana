module battle.ai.profile;

/// An AI profile prioritizes certain actions over others
class AIProfile {
  const {
    float claimObelisk;   /// desire to capture neutral obelisks
    float stealObelisk;   /// desire to capture enemy obelisks
    float protectObelisk; /// desire to protect allied obelisks
    float deploy;         /// desire to deploy more units
    float move;           /// desire to move units
    float attack;         /// desire to attack
  }
}
