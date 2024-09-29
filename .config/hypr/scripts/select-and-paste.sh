#!/bin/bash

# select an entry from my copyQ clipboard and type it in with wtype
# my first version but it worked only for printing line by line
# copyq read 0 1 2 3 4 5 6 7 8 9 | wofi --show dmenu | xargs -I{} wtype {}
#

# didn't work
# copyq show; wtype $(copyq read 0)


# checks the type of the item and IF IT IS A TEXT DUPLICATE, THEN REMOVE IT
# should skip over images
clear_duplicates() {
    copyq eval "
    var seen = {};
    for (var i = size() - 1; i >= 0; --i) {

        var mimeType = str(read('?',i));
        if (mimeType.indexOf('image') !== -1) {
            continue;
        }

        var text = str(read(i));
        if (seen[text]) {
            remove(i);
        } else {
            seen[text] = true;
        }
    }
    ";
}

# Check if CopyQ is visible
if copyq visible | rg -q "true"; then
    # If visible, hide it
    copyq hide
else
    clear_duplicates
    # If not visible, show it
    copyq show
fi
