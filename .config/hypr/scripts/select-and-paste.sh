#!/bin/bash

# select an entry from my copyQ clipboard and type it in with wtype
# my first version but it worked only for printing line by line
# copyq read 0 1 2 3 4 5 6 7 8 9 | wofi --show dmenu | xargs -I{} wtype {}
#

# didn't work
# copyq show; wtype $(copyq read 0)

copyq show

