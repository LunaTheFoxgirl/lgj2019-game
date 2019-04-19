/*
    Copyright © 2019 Clipsey

    Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
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