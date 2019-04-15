module game.world.room;
import polyplex;
import isometric.isofloorbuilder;
import game.content;
import game.world;
import game.data.floordata;


class Room {
private:
    RoomData data;
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
        foreach(wall; data.extraWalls) {
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
        if (data.hasWalls) {
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

            
        foreach(exwall; data.extraWalls) {
            drawWallSegLine(exwall.start.x, exwall.start.y, exwall.end.x, exwall.end.y, exwall);
        }

        // Do all the fancy isometric math
        Vector2 isoSize = getWallOffset(Vector2i(x, y));

        // Apply all that fancy stuff
        DrawArea = new Rectangle(cast(int)isoSize.X, cast(int)isoSize.Y, this.floorTexture.Width, this.floorTexture.Height);
        DrawAreaDownTmp = new Rectangle(cast(int)isoSize.X, cast(int)isoSize.Y, this.floorTexture.Width, this.floorTexture.Height);
        Logger.Success("Room created!");
    }

    void drawWallSegLine(int xx, int xy, int yx, int yy, ExWall exwall) {
        
        // Vertical line...
        if (xx == yx) {
            foreach(y; xy..yy) {
                walls[xx][y] = new WallData(exwall.classname !is null ? exwall.classname : data.classname);
            }
            return;
        }

        // Any other config
        int dx = yx-xx;
        int dy = yy-xy;
        int x = xx;
        int y = xy;
        int p = 2*dy-dx;

        while (x<yx) {
            if (p >= 0) {
                walls[x][y] = new WallData(exwall.classname !is null ? exwall.classname : data.classname);
                y++;
                p += 2*dy-2*dx;
            } else {
                walls[x][y] = new WallData(exwall.classname !is null ? exwall.classname : data.classname);
                p += 2*dy;
            }
            x++;
        }
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

    Vector2i calculatePosition(Vector2i position) {
        Vector2 posx = getWallOffset(position);
        int trelY = floorTexture.Height/2;
        int jrelY = baseTexture.Height;
        return Vector2i(DrawArea.X+cast(int)posx.X, DrawArea.Y+(cast(int)posx.Y+trelY)-jrelY);
    }

    Vector2 getWallOffset(Vector2i pos) {
        import isometric.isomath : setIsometricSize, isoTranslate;
        setIsometricSize(baseTexture.Width, baseTexture.Height/2);
        return isoTranslate(pos);
    }
}

private __gshared FloorBuilder sharedFloorBuilder;