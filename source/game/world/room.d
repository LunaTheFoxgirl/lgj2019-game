module game.world.room;
import polyplex;
import isometric.isofloorbuilder;
import game.content;
import vibe.data.serialization : optional;

struct FloorItem {
    /// Position on floor (in tiles)
    int x;

    /// Position on floor (in tiles)
    int y;

    /// classname of item to place (if any)
    /// set to door or DESTROY to add doors.
    @optional
    string classname;

    /// Attributes
    @optional
    string[] attributes;
}

struct Point {
    int x;
    int y;
}

struct ExWall {
    /// Where the wall starts
    Point start;

    /// Where the wall ends
    Point end;

    /// The texture of the wall
    @optional
    string classname;

    /// Which side the ends of the wall peice should face
    int segmentEnd;
}

struct RoomData {
    /// The name of the texture to use for the room
    string roomTexture;

    /// The classname of the walls (what texture they should use)
    string classname;

    /// Width of room (in tiles)
    int width;

    /// Height of room (in tiles)
    int height;

    /// Wether the room has walls
    @optional
    bool hasWalls = true;

    /// The floor plan (what stuff to place where)
    //int[][] floorPlan;
    FloorItem[] floorPlan;

    /// Extra walls
    @optional
    ExWall[] extraWalls;
}

RoomData fromString(string data, string origin = __MODULE__) {
    import sdlang.parser : parseSource;
    import vibe.data.sdl : deserializeSDLang;
    return deserializeSDLang!RoomData(parseSource(data, origin));
}

enum WallOrientation {
    North = 0,
    East = 1,
    NorthEast = 2,

    West = 3,
    South = 4,
    SouthWest = 5,

    NorthWest = 6,
    SouthEast = 7,

    All = 8
}

class Room {
private:
    RoomData data;
    Texture2D floorTexture;
    Rectangle DrawArea;
    
    Rectangle DrawAreaDownTmp;

public:
    this(string room, int x, int y) {

        Logger.Info("Creating room instance of {0}...", room);
        if (sharedFloorBuilder is null) {
            sharedFloorBuilder = new FloorBuilder();
        }


        // TODO: Load rooms in a better manner
        import std.file : readText;
        import std.format;
        data = fromString(readText("content/exdata/%s.sdl".format(room)));

        if (!sharedFloorBuilder.HasFloor(data.roomTexture)) {
            string texture = "textures/world/floors/floor_%s".format(data.roomTexture);
            Logger.Info("Registering texture <{0}>...", texture);
            sharedFloorBuilder.RegisterFloor(data.roomTexture, AssetCache.Get!Texture2D(texture));
        }

        this.floorTexture = sharedFloorBuilder.Build(data.roomTexture, data.width, data.height);

        DrawArea = new Rectangle(x, y, this.floorTexture.Width, this.floorTexture.Height);
        Logger.Success("Room created!");
    }


    void Draw(SpriteBatch spriteBatch) {

        int segHeight = ((floorTexture.Height/data.height)/2)-4;

        DrawAreaDownTmp = DrawArea;
        DrawAreaDownTmp.Y += segHeight;
        foreach_reverse(i; 0..40) {
            DrawAreaDownTmp.Y = (i*segHeight)+segHeight;

            spriteBatch.Draw(this.floorTexture, DrawAreaDownTmp, this.floorTexture.Size, Color.White);
        }

        spriteBatch.Draw(this.floorTexture, DrawArea, this.floorTexture.Size, Color.White);
    }
}

private __gshared FloorBuilder sharedFloorBuilder;