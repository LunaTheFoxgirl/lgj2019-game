/*
    Copyright © 2019 Clipsey

    Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
module game.world.room;
import polyplex;
import isometric.isofloorbuilder;
import game.content;
import game.world;
import game.data.floordata;
import game.world.floor;
import game.data.texdef;
import std.format;

struct RoomFloorCache {
private:
    Texture2D[string] cachedRooms;

public:
    void PushCache(string name, Texture2D texture) {
        cachedRooms[name] = texture;
    }

    bool Has(string name) {
        return (name in cachedRooms) !is null;
    }

    Texture2D Get(string name) {
        return cachedRooms[name];
    }
}

private __gshared RoomFloorCache ROOM_CACHE;
private __gshared FloorBuilder FLOOR_BUILDER;

class Room {
private:
    Floor parent;
    Texture2D floorTexture;

    void placeWallSegment(Vector2i position, Vector2i gridPosition, string classname, string variant, float offsetHeight) {

        Rectangle pos = new Rectangle();
        Vector2i posx = getWallOffset(position+gridPosition, Vector2i(60, 60));
        pos.X = posx.X;
        pos.Y = cast(int)offsetHeight+posx.Y;//+(floorTexture.Height/2)-60;
        pos.Width = 60;
        pos.Height = 60;
        walls[gridPosition.X][gridPosition.Y] = new Wall(this, pos, classname, variant);
    }

    void drawWallSegLine(Vector2i position, WallDefinition exwall, float offsetHeight) {
        
        // Vertical line...
        if (exwall.start.x == exwall.end.x) {
            foreach(y; exwall.start.y..exwall.end.y) {
                placeWallSegment(position, Vector2i(exwall.start.x, y), exwall.classname !is null ? exwall.classname : schematic.classname, exwall.variant, offsetHeight);
            }
            return;
        }

        // Any other config
        int dx = exwall.end.x-exwall.start.x;
        int dy = exwall.end.y-exwall.start.y;
        int x = exwall.start.x;
        int y = exwall.start.y;
        int p = 2*dy-dx;

        while (x < exwall.end.x) {
            if (p >= 0) {
                placeWallSegment(position, Vector2i(x, y), exwall.classname !is null ? exwall.classname : schematic.classname, exwall.variant, offsetHeight);
                y++;
                p += 2*dy-2*dx;
            } else {
                placeWallSegment(position, Vector2i(x, y), exwall.classname !is null ? exwall.classname : schematic.classname, exwall.variant, offsetHeight);
                p += 2*dy;
            }
            x++;
        }
    }

public:
    Wall[][] walls;
    Rectangle Area;
    Rectangle DrawArea;
    RoomData schematic;
    Vector2i position;

    /// Generate the content of the room
    void Generate(Vector2i position, float offsetHeight) {
        walls = new Wall[][](schematic.width, schematic.height);
        this.position = position;

        if (!ROOM_CACHE.Has(schematic.name_)) {
            if (!FLOOR_BUILDER.HasFloor(schematic.roomTexture)) {
                Texture2D tex = AssetCache.Get!Texture2D("textures/world/floors/%s".format(schematic.roomTexture));
                FLOOR_BUILDER.RegisterFloor(schematic.roomTexture, tex);
            }
            ROOM_CACHE.PushCache(schematic.name_, FLOOR_BUILDER.Build(schematic.roomTexture, schematic.width, schematic.height));
        }

        floorTexture = ROOM_CACHE.Get(schematic.name_);

        // Do all the fancy isometric math
        Vector2i isoSize = getWallOffset(position, Vector2i(60, 60));
        Area = new Rectangle(position.X, position.Y, schematic.width, schematic.height);

        // Generate outer walls
        foreach(x; 0..walls.length) {
            foreach(y; 0..walls[x].length) {
                if (x > 0 && x < walls.length-1 && y > 0 && y < walls[x].length-1) continue;

                placeWallSegment(position, Vector2i(cast(int)x, cast(int)y), schematic.classname, TEXTURE_DEFINITIONS.firstVariant(schematic.classname).id, offsetHeight);
            }
        }

        // Apply all that fancy stuff
        DrawArea = new Rectangle(cast(int)isoSize.X, cast(int)(isoSize.Y-(this.floorTexture.Height/2)+60)+cast(int)offsetHeight, this.floorTexture.Width, this.floorTexture.Height);
        

        // Generate custom walls
        foreach(wall; schematic.walls) {
            switch (wall.mode) {
                case WallDefMode.Line:
                    drawWallSegLine(position, wall, offsetHeight);
                    break;
                case WallDefMode.Single:
                    placeWallSegment(position, Vector2i(wall.start.x, wall.start.y), wall.classname, wall.variant, offsetHeight);
                    break;
                case WallDefMode.Rect:
                    break;
                case WallDefMode.FilledRect:
                    foreach(x; wall.start.x..wall.end.x+1) {
                        foreach(y; wall.start.y..wall.end.y+1) {
                            placeWallSegment(position, Vector2i(x, y), wall.classname, wall.variant, offsetHeight);
                        }
                    }
                    break;
                default: break;
            }
        }
    }

    this(Floor parent, RoomData schematic) {
        this.parent = parent;
        this.schematic = schematic;

        this.Area = new Rectangle(0, 0, schematic.width, schematic.height);

        if (FLOOR_BUILDER is null) FLOOR_BUILDER = new FloorBuilder();
        DrawArea = new Rectangle(0, 0, 0, 0);
        drawAreaTmp = new Rectangle(0, 0, 0, 0);
    }

    void MakeDoor(Vector2i at) {
        // Invalid place to put a door.
        if (at.X < 0 || at.Y < 0) return;
        if (at.Y >= schematic.width || at.Y >= schematic.height) return;

        // Nothing to do, return.
        if (walls[at.X][at.Y] is null) return;

        // Garbage collect the wall, then set it to null
        destroy(walls[at.X][at.Y]);
        walls[at.X][at.Y] = null;
    }

    void Draw(SpriteBatch spriteBatch) {
        foreach(wallsx; walls) {
            foreach_reverse(wall; wallsx) {
                if (wall is null) continue;
                wall.Draw(spriteBatch, parent.referenceHeight, parent.parent.ThePlayer.DrawArea);
            }
        }
    }

    Rectangle drawAreaTmp;
    void DrawFloor(SpriteBatch spriteBatch) {
        int segHeight = 30;

        drawAreaTmp.X = DrawArea.X;
        drawAreaTmp.Y = DrawArea.Y;
        drawAreaTmp.Width = DrawArea.Width;
        drawAreaTmp.Height = DrawArea.Height;
        foreach_reverse(i; 0..40) {
            drawAreaTmp.Y = DrawArea.Y+(i*segHeight)+segHeight;

            spriteBatch.Draw(this.floorTexture, drawAreaTmp, this.floorTexture.Size, Color.White);
        }

        spriteBatch.Draw(this.floorTexture, DrawArea, this.floorTexture.Size, 0f, Vector2(0, 0), Color.White, SpriteFlip.None);
    }
}


import polyplex;
class Wall {
private:
    Room parent;

public:
    /*
        Essential
    */
    /// Name of the texture resource associated with this wall
    Texture2D texture;

    /// The variant of the texture associated with this wall
    Variant* variant;


    Rectangle DrawArea;

    Rectangle FetchArea;

    /*
        Cosmetic
    */

    /// The color used for this wall segment
    Color selfColor;

    /// The step the color is at transparency wise
    float colorStep;


    /// The constructor (duh!)
    this(Room parent, Rectangle area, string classname, string variant = "default") {
        this.texture = AssetCache.Get!Texture2D(TEXTURE_DEFINITIONS.getDefinitionFor(classname).path);
        this.variant = TEXTURE_DEFINITIONS.getVariant(classname, variant);
        if (this.variant is null) {
            this.variant = TEXTURE_DEFINITIONS.firstVariant(classname);
        }
        this.selfColor = Color.White;
        this.colorStep = 1f;
        this.DrawArea = area;
        this.parent = parent;


        this.FetchArea = new Rectangle(this.variant.x, this.variant.y, this.variant.w, this.variant.h);
    }

    void Draw(SpriteBatch spriteBatch, float referenceHeight, Rectangle playerRect) {
        Vector2 wallCenter = DrawArea.Center();
        wallCenter.Y += DrawArea.Height/4;
        float layer = (referenceHeight-wallCenter.Y)/referenceHeight;
        //Logger.Info("layer: {0}, wallcenter={1}, refheight={2}", layer, wallCenter.Y, referenceHeight);
        

        bool shouldMakeTransparent = DrawArea.Intersects(playerRect.Center);
        bool isBehindPlayer = playerRect.Bottom < wallCenter.Y;

        if (isBehindPlayer && shouldMakeTransparent && colorStep > 0f) {
            colorStep -= 0.025f;
        } else if (colorStep < 1f) {
            colorStep += 0.025f;
        }
        selfColor.Alpha = cast(int)Mathf.Cosine(128f, 255f, colorStep);
        spriteBatch.Draw(texture, DrawArea, FetchArea, 0, Vector2(0, 0), selfColor, SpriteFlip.None, layer);
    }
}