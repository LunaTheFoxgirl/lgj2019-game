/*
    Copyright © 2019 Clipsey

    Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
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