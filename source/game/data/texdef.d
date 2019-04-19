module game.data.texdef;
public import game.data;

struct Definition {
    string id;
    string path;
}

struct Variant {
    string id;
    int x;
    int y;
    int w;
    int h;
}

struct TexDef {
    Definition* getDefinitionFor(string name) {
        foreach(i, _; definitions) {
            if (definitions[i].id == name) 
                return &definitions[i];
        }
        return null;
    }
    Definition[] definitions;

    Variant* firstVariant(string name) {
        if (name !in variants) return null;
        return &variants[name][0];
    }

    Variant* getVariant(string classname, string variant) {
        if (classname !in this.variants) return null;
        foreach(i, _; this.variants[classname]) {
            if (this.variants[classname][i].id == variant) 
                return &this.variants[classname][i];
        }
        return null;
    }

    Variant[][string] variants;
}

__gshared TexDef TEXTURE_DEFINITIONS;

void initializeTexdef() {
    TEXTURE_DEFINITIONS = fromResource!TexDef("texdef");
}