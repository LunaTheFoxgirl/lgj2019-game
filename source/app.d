module app;
import polyplex.utils.logging;
import gamemain;

void main() {
    LogLevel |= LogType.Info;
    LogLevel |= LogType.Debug;
    
    // Run the game
    GameMain game = new GameMain();
    game.Run();
}