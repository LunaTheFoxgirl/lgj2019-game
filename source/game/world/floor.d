module game.world.floor;
import game.world.room;
import game.data.floordata;
import game.data.floorconfig;
import polyplex;
import game.world;
import polyplex.utils.random;
import game.content;

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

    size_t[] getMatchingConnections(RoomData room, RoomData data) {
        size_t[] matches;
        foreach(ci, conn; room.connections) {
            foreach(connA; data.connections) {
                if (!conn.connected && isRoomCorrectSide(conn.direction, connA.direction)) matches ~= ci;
            }
        }
        return matches;
    }

    size_t[] getMatchingConnections(Connection conn, RoomData data) {
        size_t[] matches;
        foreach(i, connA; data.connections) {
            if (!connA.connected && isRoomCorrectSide(conn.direction, connA.direction)) matches ~= i;
        }
        return matches;
    }

    RoomData getRoomData(string nameof) {
        import std.format : format;
        return fromResource!RoomData("rooms/%s".format(nameof));
    }

    void setRoom(RoomData data, Vector2i at) {
        Room room = new Room(currentFloor, data);
        room.Generate(Vector2i(at.X, at.Y), currentFloor.referenceHeight/2);
        Logger.Info("Placed {0} at <{1},{2}> uwu", data.name_, at.X, at.Y);
        currentFloor.rooms ~= room;
    }

    bool intersectsRoom(Rectangle pos) {
        foreach(room; currentFloor.rooms) {
            if (pos.Intersects(room.Area)) {
                return true;
            }
        }
        return false;
    }

    bool inbounds(Rectangle room) {
        return currentFloor.Bounds.Intersects(room) && room.X >= 0 && room.Y >= 0;
    }

    bool addRoom(RoomData data, bool isSpecial = false) {

        // If it can't connect retry.
        if (!canRoomConnect(roomRef.schematic, data)) {
            return false;
        }


        size_t[] targets = getMatchingConnections(roomRef.schematic, data);
        if (targets.length == 0) {
            return false;
        }
        size_t selection = random.Next(0, cast(int)targets.length);
        Connection* target = &roomRef.schematic.connections[targets[selection]];

        size_t[] recipients = getMatchingConnections(*target, data);
        if (recipients.length == 0) {
            return false;
        }
        selection = random.Next(0, cast(int)recipients.length);
        Connection* recipient = &data.connections[recipients[selection]];

        Vector2i roomPosition;
        Rectangle area;
        switch(target.direction) {
            case ConnectionDirection.Right:
                roomPosition = Vector2i(roomRef.position.X+(target.x+1), roomRef.position.Y+(target.y-recipient.y));
                break;

            case ConnectionDirection.Left:
                roomPosition = Vector2i(roomRef.position.X-(data.width), roomRef.position.Y+(target.y-recipient.y));
                break;

            case ConnectionDirection.Up:
                roomPosition = Vector2i(roomRef.position.X+(target.x-recipient.x), roomRef.position.Y-(data.height));
                break;

            case ConnectionDirection.Down:
                roomPosition = Vector2i(roomRef.position.X+(target.x-recipient.x), roomRef.position.Y+(target.y+1));
                break;

            // This should never be called, but it needs to be here for D to not complain
            default: assert(0);
        }
        area = new Rectangle(roomPosition.X, roomPosition.Y, data.width, data.height);

        
        if (intersectsRoom(area)) {
            return false;
        }
        if (!isSpecial && !inbounds(area)) {
            return false;
        }
        area = new Rectangle(roomPosition.X, roomPosition.Y, data.width, data.height);
        
        // Mark them as connected (so that we don't try to reuse the connections and get weird room fusions)
        target.connect();
        recipient.connect();

        setRoom(data, roomPosition);

        // make doors between the 2.
        roomRef.MakeDoor(Vector2i(target.x, target.y));

        roomRefId = currentFloor.rooms.length-1;
        roomRef = currentFloor.rooms[roomRefId];
        roomRef.MakeDoor(Vector2i(recipient.x, recipient.y));

        return true;
    }

    size_t roomRefId = 0;
    Room roomRef;
    void generateLevelGeometry(FloorData floor) {
        Logger.Info("Generating level geometry...");
        currentFloor = new Floor(parent, floor.size.width, floor.size.height, 60, 60);
        referenceHeight = currentFloor.referenceHeight;

        // Set initial starting room.
        while(currentFloor.rooms.length <= 2) {
            setRoom(getRoomData(floor.rooms.start), Vector2i(0, 0));
            roomRefId = 0;
            roomRef = currentFloor.rooms[roomRefId];

            // Pretty ugly "hack"
            // Player should be positioned properly via level info.
            parent.ThePlayer.Position = roomRef.DrawArea.Center();

            ptrdiff_t failedOrientation = 0;
            size_t placementAttempts = 0;
            enum placementThreshold = 10;
            size_t maxRoomCount = ((floor.size.width+floor.size.height)/2)/5;

            while (placementAttempts < placementThreshold && currentFloor.rooms.length < maxRoomCount) {
                if (failedOrientation > placementThreshold) {
                    failedOrientation = 0;
                    placementAttempts++;
                    roomRefId--;
                    // Give up if there's just NO WAY to place anything
                    if (roomRefId < 0) break;
                    if (roomRefId >= currentFloor.rooms.length) break;
                    roomRef = currentFloor.rooms[roomRefId];
                    continue;
                }

                if (placementAttempts > placementThreshold) {
                    Clear();
                    continue;
                }

                // Get a random room from the room pool
                RoomData data = getRoomData(floor.rooms.rooms[random.Next(0, cast(int)floor.rooms.rooms.length)]);

                if (!addRoom(data)) {
                    failedOrientation++;
                    continue;
                }

                placementAttempts = 0;
            }

            while(!addRoom(getRoomData(floor.rooms.end), true)) {
                // retry untill it works.
            }

            if (currentFloor.rooms.length <= 1) {
                Clear();
                continue;
            }


        }
        Logger.Info("Geometry generated...");
        Logger.Info("Sorting geometry...");
        //schwartzSort!((a, b) {return a.position.X + a.schematic.width <= b.position.X || a.position.Y + a.schematic.height <= b.position.Y;})();
        //sort!(q{a.position.X+a.position.Y > b.position.X-b.position.Y})(currentFloor.rooms);

        import std.algorithm.sorting : multiSort;
        // This long-ass sorting code makes sure that we draw the floor in the right order
        // If you remove this the game will look stupid.
        multiSort!(q{a.DrawArea.Center.Y > b.DrawArea.Center.Y}, q{a.DrawArea.Center.X > b.DrawArea.Center.X})(currentFloor.rooms);

        Logger.Success("Floor generated successfully!");
    }

    __gshared bool[][] maskSeq;

    void generateLevelCollission(FloorData floor) {
        if (maskSeq is null) {
            Logger.Info("Generating mask info...");
            Texture2D wallMask = AssetCache.Get!Texture2D("textures/world/walls_mask");
            maskSeq = new bool[][](60, 60);
            Color[][] maskSqCol = wallMask.Pixels();
            foreach(y; 0..60) {
                foreach(x; 0..60) {
                    if (maskSqCol[y][x].Alpha > 128) {
                        maskSeq[y][x] = true;
                    }
                }
            }
        }

        Logger.Log("Generating world-collission, this might take a little...");

        foreach(Room room; currentFloor.rooms) {
            foreach(wallx; room.walls) {
                foreach(wall; wallx) {
                    if (wall is null) continue;
                    
                    ptrdiff_t dx = wall.DrawArea.X;
                    ptrdiff_t dy = wall.DrawArea.Y;
                    foreach(y; 0..wall.DrawArea.Height) {
                        foreach(x; 0..wall.DrawArea.Width) {
                            //Logger.Fatal("{0}", maskSeq);
                            if (maskSeq[y][x]) {
                                if (dx+x >= currentFloor.collissionMask.length) continue;
                                if (dy+y >= currentFloor.collissionMask[0].length) continue;
                                currentFloor.collissionMask[dx+x][dy+y] = true;
                            }
                        }
                    }
                }
            }
        }

        Logger.Success("Done!");
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

    void Clear() {
        destroy(currentFloor);
        currentFloor.rooms = new Room[](0);
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
    float referenceWidth;
    float sortPosition;
    Room[] rooms;
    Rectangle Bounds;

    World parent;

    this(World parent, size_t maxWidth, size_t maxHeight, size_t tileWidth, size_t tileHeight) {
        referenceHeight = maxHeight*tileHeight;
        referenceWidth  = maxWidth*tileWidth;
        collissionMask = new bool[][](cast(size_t)referenceWidth+tileWidth, cast(size_t)referenceHeight+tileHeight);

        this.Bounds = new Rectangle(0, 0, cast(int)maxWidth, cast(int)maxHeight);
        this.parent = parent;
    }

    void Draw(SpriteBatch spriteBatch) {
        foreach_reverse(room; rooms) {
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