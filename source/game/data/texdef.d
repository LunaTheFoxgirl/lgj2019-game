/*
    Copyright © 2019 Clipsey

    Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
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