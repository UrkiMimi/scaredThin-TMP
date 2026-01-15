### Basic preperation stuff
import json
from hamenNoodle import *
from hamenChroma import *
from hamenVivify import *
from copy import deepcopy

# load bundles
bundle = loadBundleInfo('bundleinfo.json')

# infodat shit
infoDat_addRequirement([
    "Noodle Extensions",
    "Chroma",
    "Vivify"
])
infoDat_addSuggestion([])

#inject map crcs
infoDat_injectCRCs(bundle)

# Add arrays
exData['customData'] = {}
exData['customData']['fakeColorNotes'] = []
exData['customData']['fakeBombNotes'] = []
exData['customData']['customEvents'] = []
exData['customData']['materials'] = {}
exData['customData']['environment'] = []

# Assigns a bunch of environment ids based on text file
def envBulkRemove(fi):
    f = open(fi, 'r')
    # this is gross
    g = 0
    for line in f:
        # debug print(line.rstrip('\n')) 
        disableObject(line.rstrip('\n'), 'Exact')
        g+=1
    f.close()

#region ### do note scripts here
# remove base environment and add new environment
envBulkRemove('bigMirror.log')
InstantiatePrefab(4, bundle['prefabs']['roadside'], 'roadside', 'rd')


assignNotesToTrack(0,10000,'notes')
assignObjectPrefab(0,'Single','colorNotes',{'track':'notes','asset':bundle['prefabs']['note'], 'anyDirectionAsset':bundle['prefabs']['notenoarrows']})



### Save json to Ex+ file
export_infoDat()
export_diff()