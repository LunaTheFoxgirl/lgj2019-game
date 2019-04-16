module game.world.room;
import polyplex;
import isometric.isofloorbuilder;
import game.content;
import game.world;
import game.data.floordata;
import game.world.floor;
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

    void placeWallSegment(Vector2i position, Vector2i gridPosition, string classname) {

        Rectangle pos = new Rectangle();
        Vector2i posx = getWallOffset(position+gridPosition, Vector2i(60, 60));
        pos.X = posx.X;
        pos.Y = posx.Y;//+(floorTexture.Height/2)-60;
        pos.Width = 60;
        pos.Height = 60;
        walls[gridPosition.X][gridPosition.Y] = new Wall(this, pos, classname);
    }

    void drawWallSegLine(Vector2i position, WallDefinition exwall) {
        
        // Vertical line...
        if (exwall.start.x == exwall.end.x) {
            foreach(y; exwall.start.y..exwall.end.y) {
                placeWallSegment(position, Vector2i(exwall.start.x, y), exwall.classname !is null ? exwall.classname : schematic.classname);
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
                placeWallSegment(position, Vector2i(x, y), exwall.classname !is null ? exwall.classname : schematic.classname);
                y++;
                p += 2*dy-2*dx;
            } else {
                placeWallSegment(position, Vector2i(x, y), exwall.classname !is null ? exwall.classname : schematic.classname);
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
    void Generate(Vector2i position) {
        walls = new Wall[][](schematic.width, schematic.height);
        this.position = position;

        Logger.Info("{0} ({1})", position, schematic.name_);

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

                placeWallSegment(position, Vector2i(cast(int)x, cast(int)y), schematic.classname);
            }
        }

        // Apply all that fancy stuff
        DrawArea = new Rectangle(cast(int)isoSize.X, cast(int)isoSize.Y-(this.floorTexture.Height/2)+60, this.floorTexture.Width, this.floorTexture.Height);
        

        // Generate custom walls
        foreach(wall; schematic.walls) {
            drawWallSegLine(position, wall);
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
        int segHeight = ((floorTexture.Height/schematic.height)/2)-4;

        // drawAreaTmp.X = DrawArea.X;
        // drawAreaTmp.Y = DrawArea.Y;
        // drawAreaTmp.Width = DrawArea.Width;
        // drawAreaTmp.Height = DrawArea.Height;
        // foreach_reverse(i; 0..40) {
        //     drawAreaTmp.Y = DrawArea.Y+(i*segHeight)+segHeight;

        //     spriteBatch.Draw(this.floorTexture, drawAreaTmp, this.floorTexture.Size, Color.White);
        // }

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
    string variant;


    Rectangle DrawArea;

    /*
        Cosmetic
    */

    /// The color used for this wall segment
    Color selfColor;

    /// The step the color is at transparency wise
    float colorStep;


    /// The constructor (duh!)
    this(Room parent, Rectangle area, string textureName, string variant = "default") {
        this.texture = AssetCache.Get!Texture2D("textures/world/walls/walls_%s".format(textureName));
        this.variant = variant;
        this.selfColor = Color.White;
        this.colorStep = 1f;
        this.DrawArea = area;
        this.parent = parent;
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
        spriteBatch.Draw(texture, DrawArea, new Rectangle(0, 0, 60, 60), 0, Vector2(0, 0), selfColor, SpriteFlip.None, layer);
    }
}