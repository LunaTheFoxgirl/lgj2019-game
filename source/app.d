module app;
import polyplex.utils.logging;
import game;

void main() {
    LogLevel |= LogType.Info;
    LogLevel |= LogType.Debug;
    
    // Run the game
    MyGame game = new MyGame();
    game.Run();
}