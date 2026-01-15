# How?
This is an explanation file on how a lot of the effects are pulled off

## Notes
The notes seem simplistic at first but are probably the most complex part I wrote in the Unity side for the map. A lot of stuff is borrowed straight from BSPTK like the debris cut logic and dissolve. They also include some special checks to see if bloom isn't enabled (for readability reasons). 

How notes are handled with Vivify are really dumb so separate prefabs for note arrows, cubes, etc. exist. This allowed me create some noodle effects like the C1 note split seen here (i'm very sorry mawntee). Even with this hacky workaround in place, This was mostly the reason why most note effects in the map were simplistic throuought the map.

<img width="214" height="192" alt="image" src="https://github.com/user-attachments/assets/5d35a262-8064-4a22-8ec5-c519ea08e8ef" />

## Vertex Displacement
This works a lot like the note dissolve effect although with some differences. The noise step and vertex push are global shader properties which allow me to edit them inside the map file.

Here's an example with it being applied to the fly scene.

<img width="432" height="251" alt="image" src="https://github.com/user-attachments/assets/e56d07cd-3655-4866-af6f-27d4796fb68c" />

## Post Processing
ScaredThin contains two blit shaders. One for the dithering, and another for the chroma smear. 

### Dithering
The dithering first adds an 8x8 Bayer dither to the camera. Then it limits the colors with flooring.

Unfortunately, since the game has its own dithering effect to prevent color banding, it messes with this effect quite a bit and that I can't do anything about :D

With blue noise dithering

<img width="129" height="116" alt="image" src="https://github.com/user-attachments/assets/a058c386-f60f-4b2e-9462-79e7229d1025" />

Without blue noise

<img width="114" height="70" alt="image" src="https://github.com/user-attachments/assets/8c37db46-3fe0-4fc2-a5ec-45971e83a4be" />

