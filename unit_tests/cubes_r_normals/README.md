# Cubes R Normals test scene

This test file, cubes_r_normal.usda, is for testing how well a USD display application interprets normal map textures. Each cube uses a different normal map texture, combined with different bias and scale values applied to that texture, to give what should be an identical result. The USDZ version of the file is included in this directory, also [directly accessible here](https://github.com/erich666/McUsd/raw/main/unit_tests/cubes_r_normals/cubes_r_normals.usdz).

The usdview program from the [USD Toolset](https://graphics.pixar.com/usd/release/toolset.html) includes a basic hydra GL rasterizing renderer. It's about as basic a render you can make, but it's also the standard, in that it's the renderer Pixar provides.

It is possible to build [usdview from scratch](https://graphics.pixar.com/usd/release/toolset.html), but in that way lies madness (at least for me). Happily, [NVIDIA's Omniverse Launcher](https://www.nvidia.com/en-us/omniverse/) provides a pre-built USDView that I can simply install and run. I tested with version 0.22.8.

Load procedure: File -> Open and select cubes_r_normals.usda. Press F11 to toggle on the hierarchy view (if not already visible). Open up the "root" by double-clicking on it. Select the "Camera" and right-click, then pick (at the bottom) "Set As Active Camera". Widen the application a bit and you'll see:

![UsdView 0.22.8](/unit_tests/cubes_r_normals/images/crn_usdview.png "UsdView 0.22.8")

The scene has four light sources in it, with just one, the "Angled_Light" coming roughly from the camera's direction, enabled. You can toggle these lights on and on in USDView by clicking on the V (visible) or I (invisible) values to the right of each. For example, here are the settings and where I clicked to make the "Light_from_above" visible and affect the scene:

![UsdView 0.22.8, light toggle](/unit_tests/cubes_r_normals/images/crn_light_toggle.png "UsdView 0.22.8, light toggle")

Toggling the various lights can show whether the three cubes respond to the light in the same way.

If the viewer being checked does not read in and use the camera, simply adjust the view. In order to get a corresponding view, use the "R" orientation on the tops of the cubes to make sure you're looking at the fronts of the three cubes.

If the viewer doesn't import the lights, you are on your own. Whatever light you use, the three cubes should appear about the same. Pay particular attention to whether the left edge and the top of the R is light or dark.

Lit from above:

![UsdView 0.22.8, lit from above](/unit_tests/cubes_r_normals/images/crn_usdview_light_from_above.png "UsdView 0.22.8, lit from above")

Lit from left:

![UsdView 0.22.8, lit from left](/unit_tests/cubes_r_normals/images/crn_usdview_light_from_left.png "UsdView 0.22.8, lit from left")

Lit from right:

![UsdView 0.22.8, lit from right](/unit_tests/cubes_r_normals/images/crn_usdview_light_from_right.png "UsdView 0.22.8, lit from right")

## Use in other packages

The rendering of the right view can be fixed in [Sketchfab](https://sketchfab.com/), for example, by selecting the right cube and then changing its material's normal map by checking the "Flip green (-y)" checkbox beneath it. You will get [this result](https://skfb.ly/oxQtt). The middle cube, where the normal map's X is reversed, cannot be fixed by the toggle, so this cube's rendering does not match the other two (look at the stem of the "R" on the right face of each cube and noticed it's reversed in shading; the left edge is dark, not light). *NOTE*: this Sketchfab model is a bit dated - it does not have the corrected normals yet; see below. *TODO*

Flipping the Y axis of the normal map in this way is sometimes called the DirectX format, vs. the unflipped (Y up) OpenGL format. So, Pixar USD appears to use the OpenGL (Y up) format by default.

## Technical details

Normal map textures use the raw RGB values in an image to generate a local surface normal. I generated the three normal map textures from the same heightfield texture:

![R bump map](/unit_tests/cubes_r_normals/r_bump_map.png "R bump map")

Black is low, white is high.

Using the [NormalMap Online page](https://cpetry.github.io/NormalMap-Online/), I dropped this texture into the leftmost area and then set the "Strength" to 1.5. From experimentation, I found that if I used the default strength of 2.5, normals would be generated that point into the surface, away from the camera. Or so I thought... from experimenting, I found that it was a matter of bias and scale being different for the Z axis than what USD expects. More on that below.

I converted this bump map into three normal map textures:
* r_normal_map.png - created by using the "Invert R" setting in the NormalMap Online tool. USD's default normal map, the "OpenGL" format.
* r_normal_map_reversed_x.png - created by unchecking all "Invert" settings. This reverses the X direction for the texture. Not commonly seen, but possible.
* r_normal_map_reversed_y.png - created by checking "R" and "G" in the "Invert" settings. This reverses the Y direction, giving the "DirectX" format.

These are the textures applied to the cubes. The left cube has r_normal_map.png applied to all faces, middle has r_normal_map_reversed_x.png, right has r_normal_map_reversed_y.png. If you look at each, the "no bump here" color is always (127,127,255), a distinctive light blue that converts (as expected) to (just about - more on that below) the normal (0,0,1), pointing outward from the surface.

Here is the r_normal_map.png:

![r_normal_map.png](/unit_tests/cubes_r_normals/r_normal_map.png "r_normal_map.png")

The default type of normal map texture, i.e., the settings in the USDA file are (incorrectly - see the discussion):

    float4 inputs:bias =  (-1, -1, -1, -1)
    float4 inputs:scale = ( 2,  2,  2,  2)

which are the defaults in [UsdPreviewSurface specification](https://graphics.pixar.com/usd/release/spec_usdpreviewsurface.html). 

Looking at r_normal_map.png's colors, you can identify normals pointing to the right as having a mostly red value, e.g., along the right loop of the "R" (or, easier, along the right edge of the vertical line forming the left of the "R") you will find (233,127,142).

Here's a sample conversion. This triplet turns into a normal by first changing it to the range 0.0 to 1.0 by dividing by 255, then multiplying by its scale factors and then adding in the bias. For example, start with:

    (233,127,142); divide that by 255 to get to the range 0.0 to 1.0:
    (0.914,0.498,0.557); multiply by scale (2,2,2) - the fourth "2" is not used:
    (1.828,0.996,1.114); add bias (-1,-1,-1):
    (0.828,-0.004,0.114) is the resulting local normal

From testing in USDView (it's not specified in the specification), the +X axis of the texture is to the right, +Y up, +Z outward to the viewer. Our surface normal points quite far to the right, X=0.828. The +Z, the direction outward from the surface to the camera, is only 0.114. Note that the +Y is nearly zero (exactly zero would be 127.5 originally, a value we can't represent), meaning the normal doesn't (much) point up or down, relative to the surface.

If you're really on top of it, you'll notice that the length of this normal is actually 0.838 - it should be 1.0, a normalized normal. I'm not sure why this is. My guess is that the tool does not properly normalize the normals. Shortened normals can cause the bumps rendered to dim, unless the renderer normalizes the texture's normal (unlikely, in my experience). TODO: to make this a "real" unit test, normal textures should be renormalized (also good: test for any negative Z values. These should never be 127 or lower).

Update: Aha! The problem is that there are two ways to scale the Z value, (-1 to +1) to keep it similar to X and Y, and (0 to 1), to maximize the Z precision. (Note: Tools such as the [NVIDIA Texture Tools Exporter](https://developer.nvidia.com/nvidia-texture-tools-exporter) use the latter - this turns out to be a bug that will be fixed. If you use this tool, set the Image Type to "Normal Map : Object Space" and the normals will then be -1 to 1 on all axes.)

If you go through the conversion with Z ranging from 0 to 1:

    (233,127,142); divide that by 255 to get to the range 0.0 to 1.0:
    (0.914,0.498,0.557); multiply by scale (2,2,1) - don't scale Z:
    (1.828,0.996,0.557); add bias (-1,-1,0) - don't bias Z:
    (0.828,-0.004,0.557) is the resulting local normal, which has a length of 0.995

So, the takeaway here is that for the normal map used on the left cube, the attributes should actually be:

    float4 inputs:bias =  (-1, -1, 0, -1)
    float4 inputs:scale = ( 2,  2, 1,  2)

with the fourth values being ignored, as usual.

 The colors of the normals in any normal map can tip you off. The rightward pointing normal was mostly red. Upward pointing normals, like along the top of the "R", are mostly green, such as (127,233,142). On the left edge of the "R", pointing to the left, you get a more dark greenish teal, (22,127,142), and bottom-pointing gives a dark bluish purple, (127,83,239).

 For the other two textures, r_normal_map_reversed_x.png and r_normal_map_reversed_y.png, they (should) appear pretty much the same as our left cube. These are properly the same in the USDView images shown earlier. 
 
 So it's clear, for the r_normal_map_reversed_x.png normal map:

![r_normal_map_reversed_x.png](/unit_tests/cubes_r_normals/r_normal_map_reversed_x.png "r_normal_map_reversed_x.png")

the bias and scale for the "r_normals_reversed_x" cube, displayed in the middle, are:

    float4 inputs:bias =  ( 1, -1, 0, -1)
    float4 inputs:scale = (-2,  2, 1,  2)

Note how the X (red) component is negated in both bias and scale. These are not what usdzip expects, for example; you'll get the warning:

    UsdUVTexture prim </Looks/r_normals/normal_texture> reads an 8 bit Normal Map, but has non-standard inputs:scale and inputs:bias values of (2, 2, 1, 2) and (-1, -1, 0, -1) (may violate 'NormalMapTextureChecker')

For the r_normal_map_reversed_y.png normal map:

![r_normal_map_reversed_y.png](/unit_tests/cubes_r_normals/r_normal_map_reversed_y.png "r_normal_map_reversed_y.png")

for the "r_normals_reversed_y" cube, displayed on the right:

    float4 inputs:bias =  (-1,  1, 0, -1)
    float4 inputs:scale = ( 2, -2, 1,  2)

Here the green (Y) component is negated in both bias and scale. This type of adjustment is used in the McUsd.usda test file, in fact, testing the feature.

Compare r_normal_map_reversed_x.png with r_normal_map.png and you'll see the "reddish" and "dark greenish teal" parts of the map are swapped. For r_normal_map_reversed_y.png the "greenish" parts are swapped with the "dark bluish purple" parts.

## Omniverse Create

I am not going to go through a thorough testing of as many viewers as I can find, as done with [McUsd](https://github.com/erich666/McUsd).

Omniverse Create looks about as I'd expect it; I won't show it here. I did set one render setting in the test file cubes_r_normals.usda:

    double "rtx:sceneDb:ambientLightIntensity" = 0.0

This turns off the fairly bright ambient light used in Omniverse's RTX real-time renderer, so that the bump effect has more contrast.

## glTF

There are two related (and more elaborate) glTF sample models that may be of interest, the [Normal-Tangent Test](https://github.com/KhronosGroup/glTF-Sample-Models/tree/master/2.0/NormalTangentTest) and the [Normal-Tangent Mirror Test](https://github.com/KhronosGroup/glTF-Sample-Models/tree/master/2.0/NormalTangentMirrorTest). _(Thanks, Eric Chadwick, for the pointers.)_

---
## License

**[CC-NC-BY-SA](LICENSE)**

Textures from the [JG-RTX resource pack](https://github.com/jasonjgardner/jg-rtx), which has the same license.

---
# Contact
Email [me](http://erichaines.com) at [erich@acm.org](mailto:erich@acm.org).