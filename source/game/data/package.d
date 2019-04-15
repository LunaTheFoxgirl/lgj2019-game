module game.data;
import std.format;
import gamemain;
public import vibe.data.serialization : optional, name;

/// Get an instance of T from some SDL data from a file, using the polyplex resource path.
T fromResource(T)(string resourceName, string origin = __MODULE__) {
    import std.path : buildPath, setExtension;
    string filePath = buildPath(contentMgr.ContentRoot, resourceName).setExtension("sdl");
    return fromFile!T(filePath, "%s <as resource> -> ".format(origin));
}

/// Get an instance of T from some SDL data from a file.
T fromFile(T)(string file, string origin = __MODULE__) {
    import std.file : readText;
    return fromString!T(readText(file), "%s (file=%s)".format(origin, file));
}

/// Get an instance of T from some SDL data.
T fromString(T)(string data, string origin = __MODULE__) {
    import sdlang.parser : parseSource;
    import vibe.data.sdl : deserializeSDLang;
    return deserializeSDLang!T(parseSource(data, origin));
}

import polyplex;
void initializeSDLLoader() {
    contentMgr = GameContext.content;
}
private __gshared ContentManager contentMgr;