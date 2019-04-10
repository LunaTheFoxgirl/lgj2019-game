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

    Texture2D Build(string texture, uint areaWidth, uint areaHeight) {
        Color[][] texColorBuffer = textures[texture].Pixels;
        uint width = textures[texture].Width;
        uint height = textures[texture].Height;
        uint floorHeight = height/2;

        uint expectedHeight = floorHeight*areaHeight;
        uint expectedWidth = width*areaWidth;

        Color[][] outBuffer = Texture2DEffectors.NewCanvas(expectedWidth, expectedHeight);


        foreach(y; 0..areaHeight) {
            foreach_reverse(x; 0..areaWidth) {
                int fx = (x * width / 2) + (y * width / 2);
                int fy = (y * floorHeight / 2) - (x * floorHeight / 2);

                fastSuperimpose(texColorBuffer, outBuffer, fx, fy);
            }
        }

        import polyplex.core.content.gl.textures : GlTexture2D;
        return new GlTexture2D(outBuffer);
    }
}

private:
Color[][] fastSuperimpose(Color[][] from, ref Color[][] to, int x, int y) {
    int from_height = cast(int)from.length;
    if (from_height == 0) throw new Exception("Invalid height of 0");

    int from_width = cast(int)from[0].length;
    if (from_width == 0) throw new Exception("Invalid width of 0");

    int height = cast(int)to.length;
    if (height == 0) throw new Exception("Invalid height of 0");

    int width = cast(int)to[0].length;
    if (width == 0) throw new Exception("Invalid width of 0");


    for (int py = 0; py < from_height; py++) {

        // Make sure that we don't add pixels not supposed to be there.
        if (y+py < 0) continue;
        if (y+py >= height) continue;

        for (int px = 0; px < from_width; px++) {

            // Make sure that we don't add pixels not supposed to be there.
            if (x+px < 0) continue;
            if (x+px >= width) continue;

            // superimpose the pixels from (start x + current x) and (start y + current y).
            // (reverse cause arrays are reversed like that.)
            to[y+py][x+px] = to[y+py][x+px].PreMultAlphaBlend(from[py][px]);
        }
    }
    return to;
}