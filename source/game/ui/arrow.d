module game.ui.arrow;
import polyplex;
import game.content;
import game.world;
import game.world.room;
import gamemain;

class UIArrow {
    public Room endRoom;
    public World world;
    public Texture2D arrowTex;
    public Rectangle DrawPos;

    this() {
        arrowTex = AssetCache.Get!Texture2D("textures/ui/arrow");
        DrawPos = new Rectangle(0, arrowTex.Height/2, arrowTex.Width, arrowTex.Height);
    }

    public void Draw(SpriteBatch spriteBatch) {
        int dpx = (GameContext.gameWindow().ClientBounds.Width/2)-(arrowTex.Width);
        int dpy = (GameContext.gameWindow().ClientBounds.Height/2)-(arrowTex.Width);

        Vector2 a = world.ThePlayer.Position;
        Vector2 b = endRoom.DrawArea.Center();
        Vector2 norm = (b-a).Normalize;

        DrawPos.X = dpx+cast(int)(norm.X*dpx);
        DrawPos.Y = dpy+cast(int)(norm.Y*dpy);

        float direction = Mathf.ATan2(b.Y - a.Y, b.X - a.X);
        spriteBatch.Draw(arrowTex, DrawPos, arrowTex.Size, direction+Mathf.ToRadians(90f), arrowTex.Size.Center, Color.Red);

    }
}