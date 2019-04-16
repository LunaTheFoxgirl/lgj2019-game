module game.world.floor;
import game.world.room;
import game.data.floordata;
import game.data.floorconfig;
import polyplex;
import game.world;
import polyplex.utils.random;

/// Get the offset for a wall segment
Vector2i getWallOffset(Vector2i position, Vector2i size) {
    Vector2 posx = calculatePosition(position, size);
    return Vector2i(cast(int)posx.X, cast(int)posx.Y+(size.Y/2)-size.Y);
}

/// Calculate position of object on the isometric grid
Vector2 calculatePosition(Vector2i pos, Vector2i size) {
    import isometric.isomath : setIsometricSize, isoTranslate;
    setIsometricSize(size.X, size.Y/2);
    return isoTranslate(pos);
}

class FloorManager {
private:
    FloorConfig config;
    Floor currentFloor;
    size_t currentLevel = 0;
    World parent;

    __gshared Random random;

    bool isRoomCorrectSide(ConnectionDirection room, ConnectionDirection against) {
        switch(room) {
            case ConnectionDirection.Left:
                return against == ConnectionDirection.Right;
            case ConnectionDirection.Right:
                return against == ConnectionDirection.Left;
            case ConnectionDirection.Up:
                return against == ConnectionDirection.Down;
            case ConnectionDirection.Down:
                return against == ConnectionDirection.Up;
            default: assert(0);
        }
    }

    bool canRoomConnect(RoomData room, RoomData data) {
        foreach(conn; room.connections) {
            foreach(connA; data.connections) {
                if (isRoomCorrectSide(conn.direction, connA.direction)) return true;
            }
        }
        return false;
    }

    Rectangle calculateRoomPosition(Room from, RoomData to) {
        
    }

    RoomData getRoomData(string nameof) {
        import std.format : format;
        return fromResource!RoomData("rooms/%s".format(nameof));
    }

    void setRoom(RoomData data, Vector2i at) {
        Room room = new Room(currentFloor, data);
        room.Generate(Vector2i(at.X, at.Y));
        Logger.Info("Placed {0} at <{1},{2}> uwu", data.name_, at.X, at.Y);
        currentFloor.rooms ~= room;
    }

    void generateLevelGeometry(FloorData floor) {
        Logger.Info("Generating level geometry...");
        currentFloor = new Floor(parent, floor.size.width, floor.size.height, 60, 60);
        referenceHeight = currentFloor.referenceHeight;

        // Set initial starting room.
        setRoom(getRoomData(floor.rooms.start), Vector2i(0, 0));

        size_t placementAttempts = 0;
        enum placementThreshold = 50;
        size_t maxRoomCount = ((floor.size.width+floor.size.height)/2)/10;

        while (placementAttempts < placementThreshold) {
            // Get a random room from the room pool
            RoomData data = getRoomData(floor.rooms.rooms[random.Next(0, floor.rooms.rooms.length-1)]);
            Room last = currentFloor.rooms[$-1];

            // If it can't connect retry.
            if (!canRoomConnect(last.schematic, data)) {
                placementAttempts++;
                continue;
            }
            break;
        }
        Logger.Info("Geometry generated!");
    }

    void generateLevelCollission(FloorData floor) {

    }

    void generateLevelEntities(FloorData floor) {

    }

    void generateNavMesh(FloorData floor) {

    }
public:
    float referenceHeight;

    this(World parent) {
        config = fromResource!FloorConfig("floorconfig");
        Logger.Debug("{0}", config);
        this.parent = parent;
        if (random is null) random = new Random();
    }

    void Generate(size_t levelId = 0) {
        if (levelId == 0) {
            levelId = currentLevel;
        }

        // repeat last floor forever.
        if (levelId >= config.floors.length) {
            levelId = config.floors.length-1;
        }

        
        generateLevelGeometry(config.floors[levelId]);
        generateLevelCollission(config.floors[levelId]);
        generateLevelEntities(config.floors[levelId]);
        generateNavMesh(config.floors[levelId]);
    }

    void Draw(SpriteBatch spriteBatch) {
        if (currentFloor !is null) currentFloor.Draw(spriteBatch);
    }

    void DrawFloor(SpriteBatch spriteBatch) {
        if (currentFloor !is null) currentFloor.DrawFloor(spriteBatch);
    }

    bool doesFeetCollide(Vector2 feetPosition) {
        return currentFloor.doesFeetCollide(feetPosition);
    }
}

/// A floor (level) of the building
class Floor {
private:
    bool[][] collissionMask;

public:
    /// Reference height used for calculating depth
    float referenceHeight;
    Room[] rooms;
    Vector2 position;

    World parent;

    this(World parent, size_t maxWidth, size_t maxHeight, size_t tileWidth, size_t tileHeight) {
        referenceHeight = maxHeight*tileHeight;
        collissionMask = new bool[][](maxWidth*tileWidth, cast(size_t)referenceHeight);
        this.parent = parent;
    }

    void Draw(SpriteBatch spriteBatch) {
        foreach(room; rooms) {
            room.Draw(spriteBatch);
        }
    }

    void DrawFloor(SpriteBatch spriteBatch) {
        foreach_reverse(room; rooms) {
            room.DrawFloor(spriteBatch);
        }
    }

    bool doesFeetCollide(Vector2 feetPosition) {
        if (feetPosition.X < 0 || feetPosition.X > collissionMask.length) return false;
        if (feetPosition.Y < 0 || feetPosition.Y > collissionMask[0].length) return false;
        return collissionMask[cast(int)feetPosition.X][cast(int)feetPosition.Y];
    }
}