### Basic preperation stuff
import json
from hamen.main import *
from hamen.noodle import *
from hamen.chroma import *
from hamen.vivify import *
from copy import deepcopy

FULL = True

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
infoDat_setEditedVersion()

infoDat_settingsSetter(dict(_advancedHud=True, _noteJumpDurationTypeSettings="Dynamic", _environmentEffectsFilterDefaultPreset = "AllEffects", _environmentEffectsFilterExpertPlusPreset = "AllEffects"), 
                       dict(_noFailOn0Energy = True),
                        dict(_disableChromaEvents = False, _disableEnvironmentEnhancements = False, _disableNoteColoring = False),
                        dict(_mainEnabled = False),
                        nTweaks=dict(_enabled = False),
                        graphics=dict(_maxShockwaveParticles = 0, _screenDisplacementEffectsEnabled = False))


# Add arrays
if not('customData' in exData):
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


# to fix note wobble being too close
def outCubic(x, inv, one):
    e = math.pow(1 - x, 5)
    return (e * inv)


#region ### do post processing here
#setUnityMaterialProperty(0,bundle['materials']['post']['path'],0,'_Fade','Float',0.1)
unityBlit(0,1200, '_ColorStep', 'Float', 5.0, bundle['materials']['post']['path'], order='AfterMainEffect')
unityBlit(104,16, '_Smear', 'Float', 0, bundle['materials']['postanalog']['path'], order='AfterMainEffect') # start post analog
unityBlit(192.75,240, '_Smear', 'Float', 0.01, bundle['materials']['postanalog']['path'], order='AfterMainEffect') # end post analog
#createCamera(0,'GhostCam',texture='_Mask',prop=dict(clearFlags='Nothing', culling={'track':['notesP1','arrowP2','noteMP2','notesP3','waow'], 'whitelist':True}, mainEffect=True, bloomPrePass=False))

# desaturate temporarily
setUnityMaterialProperty(98.5, bundle['materials']['post']['path'], 1.5, '_GrayFact', 'Float', [
    [0,0],
    [0.5,1]
])
setUnityMaterialProperty(100, bundle['materials']['post']['path'], 1, '_GrayFact', 'Float', [
    [0.5,0],
    [0,1,'easeOutExpo']
])

# desaturation but earlier
setUnityMaterialProperty(46, bundle['materials']['post']['path'], 2, '_GrayFact', 'Float', [[0,0],[0.75,1]])
setUnityMaterialProperty(48, bundle['materials']['post']['path'], 0.5, '_GrayFact', 'Float', [[0.75,0],[0,1,'easeOutCirc']])


setUnityMaterialProperty(213, bundle['materials']['post']['path'], 18, '_Intensity', 'Float', [
    [1,0],
    [0,1]
])
setUnityMaterialProperty(213, bundle['materials']['postanalog']['path'], 18, '_Kernel', 'Float', [[0,0],[0.025,1]])
setUnityMaterialProperty(213, bundle['materials']['postanalog']['path'], 18, '_Smear', 'Float', [[0,0],[-1,1]])



# ghosting will need this later :3
ghostTimes = [192.75,196.75,204.5,208.667, 209.667, 195.75, 204]

for i in ghostTimes:
    setUnityMaterialProperty(i, bundle['materials']['postanalog']['path'], 1.5, '_Kernel', 'Float', [[0.03,0],[0,1,'easeOutQuint']])
    setUnityMaterialProperty(i, bundle['materials']['postanalog']['path'], 1.5, '_Smear', 'Float', [[-1,0],[0,1]])




#region ### do environment/vivify scripts here
# remove base environment and add new environment
 

#TODO: add ghosting to notes
envBulkRemove('bigMirror.log')
assignPlayerToTrack(0, 'camera', 'Head') # for later
InstantiatePrefab(4, bundle['prefabs']['roadside'], 'roadside', 'rd')
setUnityGlobalProperty(4, 1, '_FogColor', 'Color', [
    [0.2264/5,0.056/5,0.2043/5,0,0],
])

# environment shit
assignEnvironmentToTrack('BigMirrorEnvironment.[0]Environment.[10]BasicGameHUD.[1]LeftPanel', 'panel1', 'Exact')
assignEnvironmentToTrack('BigMirrorEnvironment.[0]Environment.[10]BasicGameHUD.[2]RightPanel', 'panel2', 'Exact')
posTween(0,'panel1',0,'easeLinear',[0,0,0,0],[-3.2,1000.1,7,1])
posTween(0,'panel2',0,'easeLinear',[0,0,0,0],[3.2,1000.1,7,1])
posTween(2,'waterColorUI',3,'easeOutQuad',[0,1,0,0],[0,0.5,0,1])

InstantiatePrefab(4, bundle['prefabs']['monitor'], 'waterUI', 'waterColorUI')
InstantiatePrefab(4, bundle['prefabs']['monitorcameras'], 'cameraUI')

# saber thing cause i think this is funny 
setUnityMaterialProperty(0, bundle['materials']['bladecore']['path'], 1200, '_SatMix', 'Float', ['baseEnergy'])
setUnityMaterialProperty(0, bundle['materials']['handle']['path'], 1200, '_SatMix', 'Float', ['baseEnergy'])


# make lights react with music 
for i in range(5):
    setUnityMaterialProperty(4+(i*4), bundle['materials']['lights']['path'], 2.5, '_FogOffset', 'Float', [[1.5,0],[-45,1,'easeOutQuad']])

#ayaya
posTween(23,'rd',1,'easeInCubic',[0,0,0,0],[0,-4,0,1])
rotate(23,'rd',1,'easeInCubic',[0,0,0,0],[0,5,0,1])
posTween(23,'waterColorUI',1,'easeOutBack',[0,0.5,0,0],[0,0,0,1])

# fade out
matNames = ['floor', 'lights', 'matte', 'white', 'grass', 'tris']
for i in matNames:
    setUnityMaterialProperty(23, bundle['materials'][i]['path'], 1, '_Fade', 'Float', [[0,0],[1,1]])

setUnityGlobalProperty(23,1,'_Fade','Float',[[0,0],[1,1]],'easeInSine')
destroyObject(24,'roadside')

# insert fly guy here
InstantiatePrefab(24, bundle['prefabs']['flyguyenv'], 'flyguy')
InstantiatePrefab(24, bundle['prefabs']['cloudbgps'], 'flyguySkybox', 'fg')
InstantiatePrefab(24, bundle['prefabs']['standguy'], 'flyguy2', 'guy', rotation=[-100,180,0], position=[0,-2,0], scale=[1.75,1.75,1.75])
InstantiatePrefab(24, bundle['prefabs']['playerplacescared'], 'fgpp', 'fgpp')
InstantiatePrefab(24, bundle['prefabs']['bulleterror'], 'be0', 'be0', scale=[0,0,0])
#InstantiatePrefab(24, bundle['prefabs']['screens'], 'screens','fg')

# do children tracks
childrenTracks(0, 'fuck', ['guy'])
posTween(24,'fg',0.9,'easeOutQuad',[0,-10,0,0],[0,0,0,1])


# fade back in
matNames = ['floor', 'cloud0', 'cloud1', 'flyguy', 'shimmer', 'lights', 'matte', 'white', 'grass', 'tris']
for i in matNames:
    setUnityMaterialProperty(24, bundle['materials'][i]['path'], 1, '_Fade', 'Float', [[1,0],[-0.1,1]])

# scale mere seconds thing
scaleTween(25,'be0', 2, 'easeOutElastic', [1,0,1,0],[1,1,1,1])

# bounce
for i in range(128-25):
    if not(((i+25 > 88) and (i+25 < 95)) or ((i+25) == 99) or ((i+25 > 120) and (i+25 < 128))):
        if not((i+25) == 47):
            #people cried about this in the heck discord server so im doing this
            posTween(24.9+i,'fg',0.1,'easeInQuad',[0,0,0,0],[0,-4,0,1])
            posTween(24.9+i,'fuck',0.1,'easeInQuad',[0,5,10,0],[0,4.5,10,1])


            posTween(25+i,'fg',0.5,'easeOutExpo',[0,-4,0,0],[0,0,0,1])
            posTween(25+i,'fuck',0.5,'easeOutExpo',[0,4.5,10,0],[0,5,10,1])


# i like funny
posTween(0,'fuck',0.5,'easeOutQuad',[0,4.5,10,0],[0,5,10,1])

for i in range(52):
    if (i%2 == 0):
        rotate(24+i*2,'fuck',2,'easeInOutSine',[-20,65,0,0],[20,65,0,1])
    else:
        rotate(24+i*2,'fuck',2,'easeInOutSine',[20,65,0,0],[-20,65,0,1])

# dee dee deeznuts
deeTimes = [32,88,120]

for index in deeTimes:
    scaleTween(index,'guy',0.5,'easeOutExpo',[4,0.1,4,0],[1.75,1.75,1.75,1])
    scaleTween(index+0.75,'guy',0.5,'easeOutExpo',[0.1,4,0.1,0],[1.75,1.75,1.75,1])
    scaleTween(index+1.5,'guy',1,'easeOutElastic',[4,0.1,4,0],[1.75,1.75,1.75,1])
    
# decimation lmao
setUnityGlobalProperty(46,2,'_RVertexStep', 'Float', [[0,0],[0.3,1]])
setUnityGlobalProperty(46,2,'_RVertexAdd', 'Vector', [[0,0,0,0,0],[0,15,0,0,1]], 'easeInQuint')
setUnityGlobalProperty(48,1,'_RVertexAdd', 'Vector', [[0,15,0,0,1],[0,0,0,0,0]],'easeOutBack')
setUnityGlobalProperty(49,1,'_RVertexAdd', 'Vector', [[0,0,0,0,0]],'easeOutBack') #bruh fix this

setUnityGlobalProperty(98.5,2,'_RVertexAdd', 'Vector', [[0,0,0,0,0],[30,0,0,0,1]], 'easeInQuad')
setUnityGlobalProperty(100,1,'_RVertexAdd', 'Vector', [[30,0,0,0,0],[0,0,0,0,1]],'easeOutExpo')
setUnityGlobalProperty(102,1,'_RVertexAdd', 'Vector', [[0,0,0,0,0]])


# show lyrics
InstantiatePrefab(64,bundle['prefabs']['kartnaspeak'], 'lyrics')

# make ui avoid lyric box
posTween(64, 'waterColorUI', 2, 'easeOutElastic', [0,0,0,0],[0,-0.75,0,1])
posTween(95,'waterColorUI',1,'easeInOutBack',[0,-0.75,0,0],[0,0,0,1])

# kill the screens
#destroyObject(67,'screens')



#at the same time do a falsysish
if FULL:
    posTween(98.5, 'camera', 1.5, 'easeOutQuint', [0,0,0,0], [0,0,-1.5,1])
    posTween(100, 'camera', 1, 'easeOutQuad', [0,0,-1.5,0], [0,0,0,1])
    rotate(98.5, 'camera', 1.5, 'easeOutQuad', [0,0,0,0],[0,0,2,1])
    rotate(100, 'camera', 2, 'easeOutElastic', [0,0,2,0],[0,0,0,1])

# show aaa text at times
for i in [104,112]:
    InstantiatePrefab(i, bundle['prefabs']['aaatext'], 'aaa')
    destroyObject(i+4, 'aaa') # garbage collection :^)

    # post stuff should be up there but i dont want to define another loop
    setUnityMaterialProperty(i, bundle['materials']['postanalog']['path'], 4, '_Kernel', 'Float', [[0.04,0],[0,1]])

    # more of this shit
    setUnityGlobalProperty(i,1.5,'_RVertexAdd', 'Vector', [[30,0,-30,0,0],[0,0,0,0,1]], 'easeOutExpo')
    setUnityGlobalProperty(i+4,1,'_RVertexAdd', 'Vector', [[0,0,0,0,0]])


# delete objects
objects = ['flyguy', 'lyrics', 'flyguySkybox', 'flyguy2']
times = [127, 127.25, 127.5, 128]

for index in range(len(times)):
    destroyObject(times[index], objects[index])

# cant do this fuck
destroyObject(127,'be0')

# blue room (vds 800 series moment)
InstantiatePrefab(127.5,bundle['prefabs']['blueroom'], 'br')

# whatever go my corridor
destroyObject(128,'br')
#InstantiatePrefab(128.1,bundle['prefabs']['sccorridor'],'cr')

# fast note jump changes
"""if FULL:
    for index in [30, 94]:
        InstantiatePrefab(index, bundle['prefabs']['bulleterror'], 'be0')
        destroyObject(index+5, 'be0')
"""

# spawn breen
InstantiatePrefab(128, bundle['prefabs']['valley'])
InstantiatePrefab(159.75,bundle['prefabs']['laterspeak'], 'ls')

# for notes but its still a vivify thing
setUnityGlobalProperty(160, 1, '_NoteVertexStep', 'Float', [[0.2,0]])
setUnityGlobalProperty(180, 1, '_NoteVertexStep', 'Float', [[0.25,0]])



##last part
# change fog color to daylight
setUnityGlobalProperty(192, 4, '_FogColor', 'Color', [
    [0.2264/5,0.056/5,0.2043/5,0,0],
    [0.8/5,0.02/5,0.63/5,0,1]
],'easeOutCirc')

# for the other materials
setUnityMaterialProperty(192,bundle['materials']['skybox']['path'],4,'_Color','Color',[
    [0.1509,0.039,0.1357,1,0],
    [0.7,0.1,0.6,1,1]
],'easeOutCirc')
setUnityMaterialProperty(192,bundle['materials']['floor (1)']['path'],4,'_Color','Color',[
    [0.6415,0.2995,0.516,1,0],
    [0.1,0,0.05,1,1]
],'easeOutCirc')
setUnityMaterialProperty(192,bundle['materials']['material']['path'],4,'_Color','Color',[
    [0.4339,0,0.3362,1,0],
    [0.3,0,0.22,1,1]
],'easeOutCirc')


# end vertex add
setUnityGlobalProperty(227,5,'_RVertexStep','Float',[[0,0],[0.5,1]])
setUnityGlobalProperty(227,5,'_RVertexAdd','Vector',[[0,0,0,0,0],[90,0,0,0,1,'easeInExpo']])



#region ### do note scripts here
# fuck you aeroluna
for index in ['arrowP2', 'arrowP22', 'nGhost0', 'nGhost1', 'nGhost2', 'nGhost3', 'nGhost4', 'nGhost5', 'nGhost6', 'arrowP1']:
    assignObjectPrefab(0,'Single', 'colorNotes', {'track':index,'asset':bundle['prefabs']['arrow'], 'anyDirectionAsset':bundle['prefabs']['dot'], 'debrisAsset':bundle['prefabs']['notedebris']})
for index in ['notesP1c1', 'notesP1c2', 'notesP3', 'waow', 'realNotes', 'b0', 'b1', 'b2', 'garfeld2', 'garfeld1','notesP4', 'notesP5c1', 'notesP5c2']:
    assignObjectPrefab(0,'Single', 'colorNotes', {'track':index,'asset':bundle['prefabs']['note'], 'anyDirectionAsset':bundle['prefabs']['notenoarrows'], 'debrisAsset':bundle['prefabs']['notedebris']})
assignObjectPrefab(0,'Single', 'colorNotes', {'track':['noteMP2'],'asset':bundle['prefabs']['notemodel'], 'anyDirectionAsset':bundle['prefabs']['notemodel'], 'debrisAsset':bundle['prefabs']['notedebris']})
assignObjectPrefab(0, 'Single', 'saber', {'type':'Both', 'asset':bundle['prefabs']['waiver9saber'], 'trailAsset':bundle['materials']['trail']['path'], 'trailDuration':0.07})

# part 1
forceNJS(0,24,15)
#thinkFastChucklenuts(4,4.5, beatOffset=1)
curveNock(4,4, fakeNoteTrack='arrowP1', posOffset=20, rotationEasing='easeOutQuad', posEasing='easeInSine')
assignNotesToTrack(0,26,'notesP1c',True)
forceOffset(0,26,1)
#rotationRandC1Knockoff(4,4.5,4,['arrowP2','noteMP2'])
removeGravity(0,26)

# le epic funny
for i in range(2):
    assignPathAnimation(0,f'notesP1c{i+1}',0,pos=[
        [-60*((i%2)-0.5)*2,0,0,0],
        [0,0,0,0.2,'easeOutExpo']
    ],
    scale=[
        [15,1,1,0],
        [1,1,1,0.2,'easeOutExpo']
    ],
    dissolve=[
        [0,0],
        [1,0.15]
    ])

# im also doing it to the fake notes i made cause fuck it
assignPathAnimation(0,'arrowP1',0,pos=[
    [-60*((i%2)-0.5)*2,0,0,0],
    [0,0,0,0.2,'easeOutExpo']
],
scale=[
    [15,1,1,0],
    [1,1,1,0.2,'easeOutExpo']
],
dissolve=[
    [0,0],
    [1,0.15]
])


# part 2
#assigning and offsets
rotationRandC1Knockoff(26.01,64,2,['arrowP2','noteMP2'])
childrenTracks(0,'notesP2Parent',['arrowP2','noteMP2'])
forceNJS(32,32,5,True) 
noteGrid(24, 68, 'arrowP22',4)


for noteIndex in ['arrowP2', 'noteMP2']:    
    #dissolve notes in
    dissolveBoth(18,noteIndex,0,0,0) # stopgap
    dissolveBoth(24,noteIndex,0.5,0,1)

    #animations 25-32
    #posTweenObjekt(24,'notesP2',0.75,'easeOutQuad',[0,0,10,0],[0,0,0,1])

    # ye 1
    localRotatePointDef(24,noteIndex,1,[
        [0,0,0,0],
        [0,0,90,0.25],
        [0,0,180,0.5],
        [0,0,-90,0.75],
        [0,0,0,1]
    ],'easeOutExpo')
    scaleTween(25,noteIndex,0.5,'easeOutExpo',[4,0.25,1,0],[1,1,1,1])

    # ye
    scaleTween(27,noteIndex,0.75,'easeOutExpo',[2,0.5,1,0],[1,1,1,1])
    localRotatePointDef(27.25,noteIndex,1,[
        [0,0,0,0],
        [0,0,-90,0.25],
        [0,0,-180,0.5],
        [0,0,90,0.75],
        [0,0,0,1]
    ],'easeOutExpo')

    # mess with note zPos
    if FULL:"""
        assignPathAnimation(30,noteIndex,1,'easeOutElastic',pos=[[0,0,250,0],[0,0,0,0.45,'easeOutQuad']])
        assignPathAnimation(31,noteIndex,0.2,'easeOutExpo',pos=[[0,0,0,0]])
        posTweenObjekt(31,noteIndex,0.5,'easeOutSine',[0,0,0,0],[0,0,5,1])
        posTweenObjekt(31.5,noteIndex,0.5,'easeInSine',[0,0,5,0],[0,0,0,1])
    """
    # dee
    for i in range(2):
        assignPathAnimation(32+i*0.75,noteIndex,0.75,'easeOutCirc',worldRotation=[[rand.randint(-45,45),rand.randint(-45,45),0,0],[0,0,0,0.3]],localRotation=[[(i-0.5)*361,(i-0.5)*361,0,0],[0,0,0,0.4]])
    
    # return pos
    assignPathAnimation(33.5,noteIndex,2,'easeOutElastic',worldRotation=[[0,0,0,0]],localRotation=[[0,0,0,0]])

    #squish 2
    scaleTween(48,noteIndex,0.5,'easeOutExpo',[4,0.25,1,0],[1,1,1,1])
    #redundancy cause i seriously dont feel like looping this

    localRotatePointDef(48.75,noteIndex,1,[
        [0,0,0,0],
        [0,0,-90,0.25],
        [0,0,-180,0.5],
        [0,0,90,0.75],
        [0,0,0,1]
    ],'easeOutExpo')

    localRotatePointDef(49.5,noteIndex,1,[
        [0,0,0,0],
        [0,0,90,0.25],
        [0,0,180,0.5],
        [0,0,-90,0.75],
        [0,0,0,1]
    ],'easeOutExpo')
    
# dissolve loop for arrow grid
dissolveBoth(0,'arrowP22',0,0,0)

for i in range(19):
    if (i != 4) and (i != 11):
        dissolve((i*2) + 25, 'arrowP22', 2, 0.5, 0, 'easeOutBounce')
        scaleTween((i*2) + 25, 'arrowP22', 1.5, 'easeOutElastic', [3,3,3,0],[1,1,1,1])

# things that need to be seperated from loop
posTweenObjekt(40,'arrowP2',1,'easeOutExpo',[0,0,0,0],[5,0,0,1])
posTweenObjekt(41,'arrowP2',1,'easeOutExpo',[5,0,0,0],[-5,0,0,1])
posTweenObjekt(43,'arrowP2',1,'easeOutExpo',[-5,0,0,0],[0,0,0,1])

staticTrail(48,50,1,shakeSteps=200)

#region ### part 3
# do map offsets
forceOffset(64.01,128,0.5)
removeGravity(64.01,128)
assignNotesToTrack(64.01,128,'notesP3')



# for waow
assignNotesToTrack(71,73,'waow')
assignNotesToTrack(80,82,'waow')

# make real notes fake
spawnFakeNotesWithTrackAt(64.01,128,False,0, disableDebris=True)
invisibleNotes(64.01,128)

# reassigning track so debris still work
assignNotesToTrack(64.01,128,'realNotes')

#waow
waowTimes = [70,78]
for waow in waowTimes:
    assignPathAnimation(waow,'waow',1,'easeOutExpo',[[0,0,0,0.1],[0,2.5,0,0.2,'easeOutQuad'],[0,-0.1,0,0.3,'easeInQuad'],[0,0,0,0.4,'easeOutQuad']])
    assignPathAnimation(waow+1,'waow',1,'easeInExpo',[[0,0,0,0]])


# dissolve out
dissolveBoth(76,['notesP3', 'waow'],2,1,0.5)
dissolveBoth(78,['notesP3', 'waow'],1,0.5,1) # reverse


#flutter paths
#generate
sinFlutterX = []
sinFlutterY = []

for i in range(50):
    sinFlutterX.append([outCubic((i/100), math.sin((i/1.5)), 0),0,0,i/100])
    sinFlutterY.append([0,outCubic((i/100),math.sin(i/1.5) * 0.5,0),0,i/100])

# for shorter flutters in the song
for i in [72,80,104,112]:
    assignPathAnimation(i,['waow','notesP3'],1,'easeOutQuad',pos=sinFlutterX)
    assignPathAnimation(i+3,['waow','notesP3'],1,'easeInQuad',pos=[[0,0,0,0]])

    # for the aaaaaaa sound
    if (i >= 100):
        scalePointDef(i,['waow','notesP3'],0.6,[
            [0.25,4,0.25,0],
            [2,0.5,2,0.25,'easeInOutSine'],
            [0.75,1.5,0.75,0.5,'easeInOutSine'],
            [1.25,0.875,0.875,0.75,'easeInOutSine'],
            [1,1,1,1,'easeInOutSine']
        ])

# for the longer ones :P (edit later)
for i in [101]:
    assignPathAnimation(i,['waow','notesP3'],1,'easeOutSine',pos=sinFlutterY)
    assignPathAnimation(i+2,['waow','notesP3'],1,'easeOutSine',pos=sinFlutterY)

# shovel
localRotatePointDef(79,'notesP3',0,[[0,0,90,1]])
localRotate(82, 'notesP3', 1, 'easeOutExpo', [0,0,90,0],[0,0,0,1])

# sliped on banan peel :^)
localRotatePointDef(87,'notesP3',1,[[0,0,0,0],[90,0,0,0.25],[180,0,0,0.5],[270,0,0,0.75],[360,0,0,1]],'easeOutExpo')

scaleTween(88,'notesP3', 0.75, 'easeOutExpo', [1,1,1,0],[2,1,1,1])
posTweenObjekt(88,'notesP3', 0.75, 'easeOutExpo', [0,0,0,0],[1,0,0,1])
scaleTween(88.75,'notesP3', 0.75, 'easeOutBack', [2,1,1,0],[1,1,1,1])
posTweenObjekt(88.75,'notesP3', 0.75, 'easeOutBack', [1,0,0,0],[0,0,0,1])
posTweenObjekt(89.5,'notesP3',1.5,'easeOutElastic',[0,0,0,0],[0,-1.2,0,1])
scaleTween(89.5,'notesP3',1.5,'easeOutElastic',[1,1,1,0],[1,4,1,1])

posPointDef(91,'notesP3',1,[[0,-1.2,0,0],[0,-0.15,0,0.5,'easeOutQuad'],[0,0,0,1,'easeInQuad']])
scalePointDef(91,'notesP3',1,[[1,4,1,0],[1,0.25,1,0.5,'easeOutQuad'],[1,1,1,1,'easeInQuad']])

# swing back and forth
localRotate(92,['notesP3'],0.5,'easeOutExpo',[0,0,0,0],[0,45,0,1])
localRotate(92.75,['notesP3'],0.75,'easeOutExpo',[0,45,0,0],[0,-65,0,1])
localRotate(93.5,['notesP3'],2,'easeOutElastic',[0,-65,0,0],[0,0,0,1])

# adjust offset
# to make shit easier to hit
forceNJS(96,96,5,True)

if FULL:"""
    assignPathAnimation(95,'notesP3', 1, 'easeOutQuad', pos=[
        [0,0,10,0],
        [0,0,0,0.5,'easeInQuad']
    ])
    assignPathAnimation(96,'notesP3', 1, 'easeOutBack', pos=[
        [0,0,0,0]
    ])"""



# for dissolve
"""
dissolve(89,'arrowP3',0,0,0)

# dissolve in
dissolve(93.5,'notesP3',0.25,1,0)
dissolve(93.5,'arrowP3',0.25,0,1)

# dissolve back out
dissolve(95,'notesP3',0.25,0,1)
dissolve(95,'arrowP3',0.25,1,0)
"""

# rotate loop
# setup
"""
dissolve(89,'noteMP3',0,0,0)

dissolve(96,'noteMP3',0.5,0,1)
dissolve(96,'arrowP3',0.5,0,1)
dissolveBoth(96,'notesP3',1,1,0)

for i in range(8):
    assignPathAnimation(96+(i*4),'noteMP3',2,'easeOutElastic',worldRotation=[[rand.randint(-20,20),rand.randint(-20,20),0,0],[0,0,0,0.4,'easeInOutBack']])
    assignPathAnimation(96+(i+4),'arrowP3',2,'easeOutElastic',worldRotation=[[rand.randint(-20,20),rand.randint(-20,20),0,0],[0,0,0,0.4,'easeInOutBack']])
"""
#region ### third part 3 uegh
scaleTween(96,'notesP3',1,'easeOutQuad',[2,0.25,1,0],[1,1,1,1])

#path wiggle
assignPathAnimation(97,'notesP3',0.5,'easeOutQuint', pos=[
    [-1.5,-0.5,0,0],
    [0.5,0.5,0,0.25,'easeInOutQuad'],
    [0,0,0,0.45,'easeInOutQuad']
])
assignPathAnimation(97.5,'notesP3',1,'easeOutElastic', pos=[
    [1.5,0.5,0,0],
    [-.5,-0.5,0,0.25,'easeInOutQuad'],
    [0,0,0,0.45,'easeInOutQuad']
])
assignPathAnimation(98.5,'notesP3',2,'easeInOutBack',pos=[[0,0,0,0]])

#rotate upwards
localRotatePointDef(102,'notesP3',1,[
    [0,0,0,0],
    [0,90,0,0.25],
    [0,180,0,0.5],
    [0,270,0,0.75],
    [0,360,0,1]
],'easeOutQuart')

zAxisThing = [[0,0,0,0]]
for i in range(19):
    inv = 1-((i+1)/19)
    zAxisThing.append([0,0,(50*inv)*((i%2)-0.5),(i+1)/19,'easeInOutCirc'])

localRotatePointDef(109,'notesP3',5,zAxisThing)
localRotatePointDef(116,'notesP3',5,zAxisThing)


# copy and paste of the thing above
scaleTween(120,'notesP3', 0.75, 'easeOutExpo', [1,1,1,0],[2,1,1,1])
posTweenObjekt(120,'notesP3', 0.75, 'easeOutExpo', [0,0,0,0],[-1,0,0,1])
scaleTween(120.75,'notesP3', 0.75, 'easeOutBack', [2,1,1,0],[1,1,1,1])
posTweenObjekt(120.75,'notesP3', 0.75, 'easeOutBack', [-1,0,0,0],[0,0,0,1])
posTweenObjekt(121.5,'notesP3',1.5,'easeOutElastic',[0,0,0,0],[0,-1.2,0,1])
scaleTween(121.5,'notesP3',1.5,'easeOutElastic',[1,1,1,0],[1,4,1,1])

posPointDef(123,'notesP3',1,[[0,-1.2,0,0],[0,0.15,0,0.5,'easeOutQuad'],[0,0,0,1,'easeInQuad']])
scalePointDef(123,'notesP3',1,[[1,4,1,0],[1,0.25,1,0.5,'easeOutQuad'],[1,1,1,1,'easeInQuad']])

# swing back and forth
localRotate(124,['notesP3'],0.5,'easeOutExpo',[0,0,0,0],[0,-45,0,1])
localRotate(124.75,['notesP3'],0.75,'easeOutExpo',[0,-45,0,0],[0,45,0,1])
localRotate(125.5,['notesP3'],0.75,'easeOutExpo',[0,45,0,0],[0,0,0,1])


#region ### comically long bookmark
# force njs and offset cause long wait times
forceNJS(136,151,0.001)
forceOffset(136,151,8)
removeGravity(136,151)

# zoom prep
posTweenObjekt(100,['b0','b1','b2'],0,'easeLinear',[0,0,100,0],[0,0,100,0])
for i in range(2):
    assignNotesToTrack(136+(i*8),136+(i*8),f'b{i}')
    posTweenObjekt(128+(i*8),f'b{i}',2,'easeOutExpo',[0,0,100,0],[0,0,0,1])

# last one is only 7 beats (sadge)
assignNotesToTrack(151,151,f'b2')
posTweenObjekt(144,f'b2',2,'easeOutExpo',[0,0,100,0],[0,0,0,1])

# path animation
assignPathAnimation(128,['b0','b1','b2'],0,
    pos=[
        [0,0,20,0],
        [0,0,0,0.5,'easeInExpo'],
        [0,0,-20,1,'easeOutQuad']
    ],
    dissolve=[
        [0,0],
        [0.75,0.1]
    ])



# note bulk
forceOffset(152,160,0.6)
assignNotesToTrack(152,160,'garfeld',True)

# reassignage
spawnFakeNotesWithTrackAt(152,160,False,0,disableDebris=True)
wipeCustomNoteData(152,160) # remove custom data from real notes
invisibleNotes(152,160)
assignNotesToTrack(152,160,'realNotes')

#boogie
for i in range(6):
    assignPathAnimation(152+i,'garfeld1',1,'easeOutExpo',pos=[
        [round(rand.randint(-2,2),2),0,round(rand.randint(-4,0),2),0],
        [0,0,0,0.45,'easeInOutExpo']
    ])
    assignPathAnimation(152+i,'garfeld2',1,'easeOutExpo',pos=[
        [round(rand.randint(-2,2),2),0,round(rand.randint(-4,0),2),0],
        [0,0,0,0.45,'easeInOutExpo']
    ])

#region last part before drop
spawnFakeNotesWithTrackAt(160.75,191,False,0,'notesP4',disableDebris=True)
forceOffset(160.75,191,0.5)
invisibleNotes(160.75,191)
assignNotesToTrack(160.75,191,'realNotes')

#woaw2
for index in [166,174]:
    assignPathAnimation(index,'notesP4',1,'easeOutExpo', pos=[
        [0,0,0,0],
        [1.5,0,0,0.1,'easeOutCirc'],
        [0,0,0,0.15,'easeInQuad'],
        [-1.5,0,0,0.2,'easeOutCirc'],
        [0.5,0,0,0.3,'easeInCirc'],
        [0,0,0,0.4,'easeOutQuad']
    ])
    assignPathAnimation(index+1.5,'notesP4',0.5,'easeInExpo',pos=[[0,0,0,0]])

#flutter parts
for index in [168,176]:
    assignPathAnimation(index,'notesP4',2,'easeOutQuad',pos=sinFlutterX)
    assignPathAnimation(index+2,'notesP4',4,'easeLinear',pos=[[0,0,0,0]])

# fuck around with note vertex thingy
setUnityGlobalProperty(166, 1, '_NoteVertexAdd', 'Vector', [[0,0,0,0,0],[-2,0,0,0,1,'easeOutQuint']])
setUnityGlobalProperty(167, 1, '_NoteVertexAdd', 'Vector', [[-2,0,0,0,0],[0,0,0,0,1,'easeInQuint']])
setUnityGlobalProperty(168, 1, '_NoteVertexAdd', 'Vector', [[0,0,0,0,0]]) # shit wont zero out

setUnityGlobalProperty(174, 1, '_NoteVertexAdd', 'Vector', [[0,0,0,0,0],[1,0,0,0,1,'easeOutQuint']])
setUnityGlobalProperty(175, 1, '_NoteVertexAdd', 'Vector', [[1,0,0,0,0],[0,0,0,0,1,'easeInQuint']])
setUnityGlobalProperty(176, 1, '_NoteVertexAdd', 'Vector', [[0,0,0,0,0]]) # shit wont zero out



# final part before drop
#for i in [184,184.75,185.5]:
#    spiralNoteTrail(i,noteOffset=-5,total=16,step=0.01,spiralFlex=-10,scaleStep=0.15)

# stretch vertex again
setUnityGlobalProperty(184, 0.75, '_NoteVertexAdd', 'Vector', [[2,2,0,0,0],[0,0,0,0,1,'easeOutBack']])
setUnityGlobalProperty(184.75, 0.75, '_NoteVertexAdd', 'Vector', [[-2,2,0,0,0],[0,0,0,0,1,'easeOutBack']])
setUnityGlobalProperty(185.5, 0.75, '_NoteVertexAdd', 'Vector', [[0,0,0,0,0]]) # again cause of the fucking bug jesus christ just shoot me with a .44 mm revolver
localRotatePointDef(185.5, 'notesP4', 1.5, [
    [0,0,0,0],
    [0,90,0,0.05,'easeOutQuad'],
    [0,0,0,1,'easeOutElastic']
])
localRotatePointDef(187, 'notesP4', 1, [
    [0,0,0,0],
    [0,-45,0,0.05,'easeOutQuad'],
    [0,0,0,1,'easeOutElastic']
])

# vro
#assignPathAnimation(188, 'notesP4', 0.75, 'easeOutQuint', worldRotation=[[0,30,0,0],[0,0,0,1,'easeOutQuint']])
#assignPathAnimation(188.75, 'notesP4', 0.75, 'easeOutQuint', worldRotation=[[0,-30,0,0],[0,0,0,1,'easeOutQuint']])
#assignPathAnimation(189.5, 'notesP4', 0.75, 'easeOutQuint', worldRotation=[[0,0,0,0]])

scaleTween(188, 'notesP4', 0.75, 'easeOutBack',[1,1,1,0],[1,2,1,1])
posTweenObjekt(188, 'notesP4', 0.75, 'easeOutBack', [0,0,0,0],[0,0.6,0,1])
posTweenObjekt(188.75, 'notesP4', 0.75, 'easeOutExpo', [0,0.6,0,0],[0,-0.6,0,1])
scalePointDef(189.5, 'notesP4', 1, [[1,2,1,0],[1,0.5,1,0.5,'easeOutCubic'],[1,1,1,1,'easeInCubic']])
posPointDef(189.5, 'notesP4', 1, [[0,-0.6,0,0],[0,0.3,0,0.5,'easeOutCubic'],[0,0,0,1,'easeInCubic']])

spiralNoteTrail(191,step=0.02,scaleStep=0,noteOffset=-100)

assignNotesToTrack(192,999,'notesP5c',True)
forceOffset(192,999,1)

# animations
for i in range(len(ghostTimes)):
    timeGhost(ghostTimes[i], 2, f'nGhost{i}')
    
    assignPathAnimation(ghostTimes[i], 'notesP5c1', 1.5, 'easeOutElastic', pos=[[rand.randint(-3,3),0,rand.randint(-3,3),0],
                                                                            [0,0,0,0.35,'easeInOutExpo']],
                                                                            worldRotation=[[0,rand.randint(-5,5),0,0],[0,0,0,0.5,'easeOutExpo']])
    assignPathAnimation(ghostTimes[i], 'notesP5c2', 1.5, 'easeOutElastic', pos=[[rand.randint(-3,3),0,rand.randint(-3,3),0],
                                                                            [0,0,0,0.35,'easeInOutExpo']],
                                                                            worldRotation=[[0,rand.randint(-5,5),0,0],[0,0,0,0.5,'easeOutExpo']])
    
    setUnityGlobalProperty(ghostTimes[i], 0.75, '_NoteVertexAdd', 'Vector', [[-2,2,0,0,0],[0,0,0,0,1,'easeOutBack']])


#region ### Save json to Ex+ file
countUp()

export_infoDat()
export_diff()