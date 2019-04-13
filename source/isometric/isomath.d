module isometric.isomath;
import polyplex;

private __gshared int isoWidth;
private __gshared int isoHeight;

/// Sets the size (in pixels) of the isometric tile
/// The isometric tile might NOT be the actual size of texture
/// but the size of the ground-area of the texture.
void setIsometricSize(int width, int height) {
    isoWidth = width;
    isoHeight = height;
}

/// Translate a tile X and Y to X and Y coordinates
Vector2 isoTranslate(Vector2i tilePos, int width = isoWidth, int height = isoHeight) {
    int fx = (tilePos.X * width / 2) + (tilePos.Y * width / 2);
    int fy = (tilePos.Y * height / 2) - (tilePos.X * height /2);
    return Vector2(fx, fy);
}