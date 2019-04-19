/*
    Copyright © 2019 Clipsey

    Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
module isometric.isofloorbuilder;
//import polyplex.core.content.textures;
import polyplex;

class FloorBuilder {
private:
    Texture2D[string] textures;

public:
    void RegisterFloor(string name, Texture2D texture) {
        textures[name] = texture;
    }

    bool HasFloor(string name) {
        return (name in textures) !is null;
    }
    
    Texture2D Build(string texture, uint areaWidth, uint areaHeight) {
        Color[][] texColorBuffer = textures[texture].Pixels;

        uint width = textures[texture].Width;
        uint height = textures[texture].Height;
        uint tileHeight = height/2;

        uint expectedWidth = (areaWidth * width / 2) + (areaHeight * width / 2);
        uint expectedHeight = height+(height*areaHeight)*2;


        uint expectedTilesHeight = (tileHeight*areaHeight)*2;

        Logger.Info("{0} {1}", expectedWidth, expectedHeight);
        Color[][] outBuffer = Texture2DEffectors.NewCanvas(expectedWidth, expectedHeight, Color.Transparent);

        foreach(y; 0..areaHeight) {
            foreach_reverse(x; 0..areaWidth) {
                int fx = (x * width / 2) + (y * width / 2);
                int fy = ((y * (height/2) / 2) - (x * (height/2) / 2));
                fastSuperimpose(texColorBuffer, outBuffer, fx, fy+expectedTilesHeight);
            }
        }

        import polyplex.core.content.gl.textures : GlTexture2D;
        return new GlTexture2D(outBuffer);
    }
}
private:

// Slightly faster superimpose function that uses the already declared output (to)
// Saves a little bit of memory allocation
// Could be optimized further
Color[][] fastSuperimpose(Color[][] from, ref Color[][] to, int x, int y) {
    int from_height = cast(int)from.length;
    if (from_height == 0) throw new Exception("Invalid height of 0");

    int from_width = cast(int)from[0].length;
    if (from_width == 0) throw new Exception("Invalid width of 0");

    int width = cast(int)to[0].length;
    if (width == 0) throw new Exception("Invalid width of 0");

    int height = cast(int)to.length;
    if (height == 0) throw new Exception("Invalid height of 0");


    for (int py = 0; py < from_height; py++) {

        // Make sure that we don't add pixels not supposed to be there.
        if (y+py < 0) continue;
        if (y+py >= height) continue;

        for (int px = 0; px < from_width; px++) {

            // Make sure that we don't add pixels not supposed to be there.
            if (x+px < 0) continue;
            if (x+px >= width) continue;

            // Ugly hack to support transparency.
            //if (to[y+py][x+px].Alpha == 0 && from[py][px].Alpha == 0) continue;

            // Less ugly hack to support transparency.
            immutable(uint) preOpAlpha = to[y+py][x+px].Alpha;

            // superimpose the pixels from (start x + current x) and (start y + current y).
            // (reverse cause arrays are reversed like that.)
            to[y+py][x+px] = to[y+py][x+px].PreMultAlphaBlend(from[py][px]);

            // Post-multiply the alpha, it's p bad.
            to[y+py][x+px].Alpha = preOpAlpha + from[py][px].Alpha;
            if (to[y+py][x+px].Alpha > 255) to[y+py][x+px].Alpha = 255;
        }
    }
    return to;
}