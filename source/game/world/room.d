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
    Vector2i position;
    Floor parent;
    Texture2D floorTexture;
    RoomData schematic;

    void placeWallSegment(Vector2i position, Vector2i gridPosition, string classname) {

        Rectangle pos = new Rectangle();
        Vector2i posx = getWallOffset(position+gridPosition, Vector2i(60, 60));
        pos.X = posx.X;
        pos.Y = posx.Y+(floorTexture.Height/2)-60;
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

    /// Generate the content of the room
    void Generate(Vector2i position) {
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

        // Apply all that fancy stuff
        DrawArea = new Rectangle(cast(int)isoSize.X, cast(int)isoSize.Y, this.floorTexture.Width, this.floorTexture.Height);
        
        // Generate outer walls
        foreach(x; 0..walls.length) {
            foreach(y; 0..walls[x].length) {
                if (x > 0 && x < walls.length-1 && y > 0 && y < walls[x].length-1) continue;

                placeWallSegment(position, Vector2i(cast(int)x, cast(int)y), schematic.classname);
            }
        }

        // TEMP: make doors!
        foreach(door; schematic.connections) {
            MakeDoor(Vector2i(door.x, door.y));
        }

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

    Rectangle DrawArea;
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

/+
class Room {
private:
    /*RoomData data;
    Texture2D floorTexture;
    Texture2D baseTexture;

    World parent;

    Texture2D[string] wallTextures;
    WallData*[][] walls;

    __gshared Color normColor;
    __gshared Color intersectColor;


    Color selfColor;
    float colorStep = 1f;

package:
    Rectangle DrawArea;
    Rectangle DrawAreaDownTmp;
    */
public:
    this(World parent, string room, int x, int y) {

        this.parent = parent;

        if (normColor is null) {
            normColor = Color.White;
            intersectColor = Color.White;
            intersectColor.Alpha = 128;
        }

        Logger.Info("Creating room instance of {0}...", room);
        if (sharedFloorBuilder is null) {
            sharedFloorBuilder = new FloorBuilder();
        }

        // TODO: Load rooms in a better manner
        import std.file : readText;
        import std.format;
        data = fromResource!RoomData("rooms/"~room);//fromString(readText("content/exdata/%s.sdl".format(room)));


        string texture = "textures/world/floors/floor_%s".format(data.roomTexture);
        baseTexture = AssetCache.Get!Texture2D(texture);

        if (!sharedFloorBuilder.HasFloor(data.roomTexture)) {
            Logger.Info("Registering texture <{0}>...", texture);
            sharedFloorBuilder.RegisterFloor(data.roomTexture, baseTexture);
        }

        this.floorTexture = sharedFloorBuilder.Build(data.roomTexture, data.width, data.height);


        // Load wall textures
        string wallRes = "textures/world/walls/walls_%s";
        wallTextures[data.classname] = AssetCache.Get!Texture2D(wallRes.format(data.classname));
        foreach(wall; data.walls) {
            if (wall.classname !in wallTextures) {
                wallTextures[wall.classname] = AssetCache.Get!Texture2D(wallRes.format(wall.classname));
            }
        }
        
        // Prepare walls array
        walls.length = data.width;
        foreach(i; 0..walls.length) {
            walls[i].length = data.height;
        }

        // Generate walls
        if (data.generateWalls) {
            foreach(wx; 1..data.width-1) {
                walls[wx][0] = new WallData(data.classname);

            }

            foreach_reverse(wy; 1..data.height-1) {
                walls[0][wy] = new WallData(data.classname);
            }


            foreach(wx; 1..data.width-1) {
                walls[wx][data.height-1] = new WallData(data.classname);
            }

            foreach_reverse(wy; 1..data.height-1) {
                walls[data.width-1][wy] = new WallData(data.classname);
            }

            walls[0][0] = new WallData(data.classname);
            walls[0][data.height-1] = new WallData(data.classname);
            walls[data.width-1][0] = new WallData(data.classname);
            walls[data.width-1][data.height-1] = new WallData(data.classname);

        }

            
        foreach(exwall; data.walls) {
            drawWallSegLine(exwall.start.x, exwall.start.y, exwall.end.x, exwall.end.y, exwall);
        }

        // Do all the fancy isometric math
        Vector2 isoSize = getWallOffset(Vector2i(x, y));

        // Apply all that fancy stuff
        DrawArea = new Rectangle(cast(int)isoSize.X, cast(int)isoSize.Y, this.floorTexture.Width, this.floorTexture.Height);
        DrawAreaDownTmp = new Rectangle(cast(int)isoSize.X, cast(int)isoSize.Y, this.floorTexture.Width, this.floorTexture.Height);
        Logger.Success("Room created!");*/
    }

    void Draw(SpriteBatch spriteBatch) {

        int segHeight = ((floorTexture.Height/data.height)/2)-4;

        DrawAreaDownTmp.X = DrawArea.X;
        DrawAreaDownTmp.Y = DrawArea.Y;
        DrawAreaDownTmp.Width = DrawArea.Width;
        DrawAreaDownTmp.Height = DrawArea.Height;
        foreach_reverse(i; 0..40) {
            DrawAreaDownTmp.Y = DrawArea.Y+(i*segHeight)+segHeight;

            spriteBatch.Draw(this.floorTexture, DrawAreaDownTmp, this.floorTexture.Size, Color.White);
        }

        spriteBatch.Draw(this.floorTexture, DrawArea, this.floorTexture.Size, 0f, Vector2(0, 0), Color.White, SpriteFlip.None);
    }

    void DrawWalls(SpriteBatch spriteBatch) {
        foreach(y; 0..walls.length) {
            foreach_reverse(x; 0..walls[y].length) {
                if (walls[y][x] is null) continue;
                drawWall(spriteBatch, walls[y][x], Vector2i(cast(int)y, cast(int)x));
            }
        }
    }

    private Rectangle tmpDrawPos = new Rectangle(0, 0, 0, 0);
    private Rectangle tmpDrawFetch = new Rectangle(0, 0, 0, 0);
    void drawWall(SpriteBatch spriteBatch, WallData* wall, Vector2i at) {
        Vector2i pos = calculatePosition(at);
        Rectangle size = wallTextures[wall.textureName].Size();

        /// TODO: remove all the extra fluff from the textures so that this ain't needed.
        Vector2i orpos = Vector2i(0, 0);
        int relX = size.Width/4;
        int relY = size.Height;

        tmpDrawPos.X = pos.X;
        tmpDrawPos.Y = pos.Y;
        tmpDrawPos.Width = relX;
        tmpDrawPos.Height = relY;

        tmpDrawFetch.X = orpos.X*relX;
        tmpDrawFetch.Y = orpos.Y*relY;
        tmpDrawFetch.Width = relX;
        tmpDrawFetch.Height = relY;

        float layer = 0f;
        Vector2 playerCenter = parent.ThePlayer.DrawArea.Center();
        Vector2 wallCenter = tmpDrawPos.Center();
        wallCenter.Y += tmpDrawPos.Height/4;
        layer = wallCenter.Y < playerCenter.Y+15 ? 8f : 3f;

        
        Rectangle playerRect = parent.ThePlayer.DrawArea;


        bool shouldMakeTransparent = layer == 3f && (playerRect.Expand(-(playerRect.Width/4), -(playerRect.Height/4))).Intersects(tmpDrawPos);

        if (shouldMakeTransparent && wall.colorStep > 0f) {
            wall.colorStep -= 0.025f;
        } else if (wall.colorStep < 1f) {
            wall.colorStep += 0.025f;
        }
        wall.selfColor.Alpha = cast(int)Mathf.Cosine(150f, 255f, wall.colorStep);

        spriteBatch.Draw(wallTextures[wall.textureName], tmpDrawPos, tmpDrawFetch, 0, Vector2(0, 0), wall.selfColor, SpriteFlip.None, layer);
        
    }
}

private __gshared FloorBuilder sharedFloorBuilder;
+/