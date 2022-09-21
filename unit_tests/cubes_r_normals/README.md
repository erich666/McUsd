# Cubes R Normals test scene

This test file, cubes_r_normal.usda, is for testing how well a USD display application interprets the bias and scale inputs for normal map textures. Each cube uses a different normal map texture, combined with different bias and scale values applied to that texture, to give what should be an identical result. The USDZ version of the file is included in this directory, also [directly accessible here](https://github.com/erich666/McUsd/raw/main/unit_tests/cubes_r_normals/cubes_r_normals.usdz).

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

### Sketchfab

The rendering of the right view can be fixed in [Sketchfab](https://sketchfab.com/), for example, by selecting the right cube and then changing its material's normal map by checking the "Flip green (-y)" checkbox beneath it. You will get [this result](https://skfb.ly/oyqrM). The middle cube, where the normal map's X is reversed and the Z range is set to 0--1, cannot be fixed by the toggle, so this cube's rendering does not match the other two (look at the stem of the "R" on the right face of each cube and noticed it's reversed in shading; the left edge is dark, not light).

## Omniverse Create

I am not going to go through a thorough testing of as many viewers as I can find, as done with [McUsd](https://github.com/erich666/McUsd).

Omniverse Create looks about as I'd expect it; I won't show it here. I did set one render setting in the test file cubes_r_normals.usda:

    double "rtx:sceneDb:ambientLightIntensity" = 0.0

This turns off the fairly bright ambient light used in Omniverse's RTX real-time renderer, so that the bump effect has more contrast.

## Technical details

Normal map textures use the raw RGB values in an image to generate a local surface normal. I generated the three normal map textures from the same heightfield texture:

![R bump map](/unit_tests/cubes_r_normals/r_bump_map.png "R bump map")

Black is low, white is high.

Using the [NormalMap Online page](https://cpetry.github.io/NormalMap-Online/), I dropped this texture into the leftmost area. (Right now I'm actually using [a fork I made](https://github.com/erich666/NormalMap-Online), which adds the important feature "Z Range". I expect my pull request to be accepted sometime soon.)

I converted this bump map into three normal map textures, used in the three cubes, left to right:
* r_normal_map.png - created by using the "Invert R" setting in the NormalMap Online tool and by checking the box next to "Z Range". This represents USD's default normal map, AKA the "OpenGL" format.
* r_normal_map_reversed_x_0_bias_z.png - created by unchecking all "Invert" settings and unchecking the "Z Range" box. This reverses the X direction for the texture and maps the Z (height) value from 0 to 1. Not commonly seen, but possible.
* r_normal_map_reversed_y.png - created by checking "R" and "G" in the "Invert" settings and by checking the box next to "Z Range". This reverses the Y direction, giving what is sometimes called the "DirectX" format, commonly used in games.

These are the textures applied to the cubes. The left cube has r_normal_map.png applied to all faces, middle has r_normal_map_reversed_x_0_bias_z.png, right has r_normal_map_reversed_y.png. If you look at each texture applied, the "no bump here" color is always (127,127,255), a distinctive light blue that converts (as expected) to the normal (0,0,1), pointing outward from the surface.

Here is the r_normal_map.png:

![r_normal_map.png](/unit_tests/cubes_r_normals/r_normal_map.png "r_normal_map.png")

The default type of normal map texture, i.e., the settings in the USDA file are (incorrectly - see the discussion):

    float4 inputs:bias =  (-1, -1, -1, -1)
    float4 inputs:scale = ( 2,  2,  2,  2)

which are the defaults in [UsdPreviewSurface specification](https://graphics.pixar.com/usd/release/spec_usdpreviewsurface.html). 

Looking at r_normal_map.png's colors, you can identify normals pointing to the right as having a mostly red value, e.g., along the right loop of the "R" (or, easier, along the right edge of the vertical line forming the left of the "R") you will find (246,127,175).

Here's a sample conversion for these bias and scale setting. This triplet turns into a normal by first changing it to a floating point number from 0.0 to 1.0 by dividing by 255, then multiplying by its scale factors, and then adding in the bias. For example, start with:

    (246,127,175); divide that by 255 to get to the range 0.0 to 1.0:
    (0.965, 0.498, 0.686); multiply by scale (2,2,2) - the fourth "2" is not needed:
    (1.929, 0.996, 1.373); add bias (-1,-1,-1):
    (0.929, -0.004, 0.373) is the resulting local normal, which has a length of 1.003

From testing in USDView (it's not specified in the specification), the +X axis of the texture is to the right, +Y up, +Z outward to the viewer. Our surface normal points quite far to the right, X=0.929 and Z=0.373. The +Y is nearly zero (exactly zero would be 127.5 originally, a value we can't represent), meaning the normal doesn't (much) point up or down, relative to the Y axis on the surface.

The colors of the normals in any normal map can tip you off. The rightward pointing normal was mostly red. Upward pointing normals, like along the top of the "R", are mostly green, such as (127,233,142). On the left edge of the "R", pointing to the left, you get a more dark greenish teal, (22,127,142), and bottom-pointing gives a dark bluish purple, (127,83,239).

 For the other two textures, r_normal_map_reversed_x_0_bias_z.png and r_normal_map_reversed_y.png, they (should) render pretty much the same as our left, default-mapping cube. These correctly look the same in the USDView images shown earlier. 
 
 So it's clear, for the r_normal_map_reversed_x_0_bias_z.png normal map:

![r_normal_map_reversed_x_0_bias_z.png](/unit_tests/cubes_r_normals/r_normal_map_reversed_x_0_bias_z.png "r_normal_map_reversed_x_0_bias_z.png")

the bias and scale for the "r_normals_reversed_x" cube, displayed in the middle, are:

    float4 inputs:bias =  ( 1, -1, 0, -1)
    float4 inputs:scale = (-2,  2, 1,  2)

Note how the X (red) component is negated in both bias and scale, and the Z (blue) component is converted to the range 0 to 1. These are not what usdzip expects, for example. If you use usdzip's "-c", check compliance, option you'll get the warning:

    UsdUVTexture prim </Looks/r_normals_reversed_x_0_bias_z/normal_texture> reads an 8 bit Normal Map, but has non-standard
    inputs:scale and inputs:bias values of (-2, 2, 1, 2) and (1, -1, 0, -1) (may violate 'NormalMapTextureChecker')

This reversed X and remapped Z example is not a normal map combination you'll likely ever see anywhere else. It is here purely for testing these two possibilities, each of which I've seen used in some normal maps.

For the r_normal_map_reversed_y.png normal map:

![r_normal_map_reversed_y.png](/unit_tests/cubes_r_normals/r_normal_map_reversed_y.png "r_normal_map_reversed_y.png")

for the "r_normals_reversed_y" cube, displayed on the right:

    float4 inputs:bias =  (-1,  1, -1, -1)
    float4 inputs:scale = ( 2, -2,  2,  2)

Here the green (Y) component is negated in both bias and scale. This type of adjustment is used in the McUsd.usda test file for all normal maps, in fact, testing the feature. This is needed when converting from "DirectX style" Y is down along the surface normal map textures, often seen in games, to USD's "OpenGL style", Y is up standard.

This flip will also be flagged by usdtools with "-c":

    UsdUVTexture prim </Looks/r_normals_reversed_y/normal_texture> reads an 8 bit Normal Map, but has non-standard
    inputs:scale and inputs:bias values of (2, -2, 2, 2) and (-1, 1, -1, -1) (may violate 'NormalMapTextureChecker')

Compare r_normal_map_reversed_x_0_bias_z.png with r_normal_map.png and you'll see the "reddish" and "dark greenish teal" parts of the map are swapped. For r_normal_map_reversed_y.png the "greenish" parts are swapped with the "dark bluish purple" parts.

### Tools

I use [my branch of the Normals Online tool](https://github.com/erich666/NormalMap-Online) - download and open index.html, drop a bump map into the left image, adjust as you wish. I typically check the Invert R and Z Range boxes for the default USD format, then download the resulting image.

It's sometimes tough to tell if a normal map you encounter in the wild uses a Z range of 0 to 1 or -1 to 1. In the "misc" directory at the top of the McUsd tree is a program rgb_to_normal.pl (yes, I'm old, I use Perl). Examine a pixel from the normal map you're examining, the less bluish the better. Edit the $rgb values in rgb_to_normal.pl and run by "perl rgb_to_normal.pl". For our test pixel (246,127,175) you'll see the result:

    Assuming Z ranges from -1 to 1:
    Vector 246 127 175 converts to 0.929, -0.004, 0.373, length 1.003

    Else, assuming Z ranges from 0 to 1:
    Vector 246 127 175 converts to 0.929, -0.004, 0.686
    length was wrong at 1.155, corrected to 0.804, -0.003, 0.594 -> 230 127 203

From this we can tell that the r_normal_map.png this pixel came from uses the Z range -1 to 1.

Tools such as the [NVIDIA Texture Tools Exporter](https://developer.nvidia.com/nvidia-texture-tools-exporter) use the range 0 to 1 by default (this turns out to be a bug that will be fixed). If you use this tool, set the Image Type to "Normal Map : Object Space" and the normals will then be -1 to 1 on all axes.)

If you work with any tools, be careful about resizing normal map images. For example, if you take a 256x256 normal map image and scale it down to 64x64, you are averaging normals together to get the result. Doing so will make the normals stored no longer be normalized, of length 1.0. This can affect some renderers. Better is to scale down the original grayscale heightfield bump map and scale it down before converting to normals.

One last thing worth noting is that some specialized formats use the Z (blue) channel for other data. Since it's given that the normal stored is normalized, when the Z value is always greater than or equal to 0.0 you can then derive Z from X and Y, i.e.,

    Z = sqrt(1 - X*X - Y*Y)

For example, the Z channel is instead used to hold an ambient occlusion percentage in the Minecraft [LabPBR format](https://wiki.shaderlabs.org/wiki/LabPBR_Material_Standard). So, if you see a constant Z value (e.g., all 256) or values that don't seem to give normals of length 1.0, this may be the reason.

## glTF

There are two related (and more elaborate) glTF sample models that may be of interest, the [Normal-Tangent Test](https://github.com/KhronosGroup/glTF-Sample-Models/tree/master/2.0/NormalTangentTest) and the [Normal-Tangent Mirror Test](https://github.com/KhronosGroup/glTF-Sample-Models/tree/master/2.0/NormalTangentMirrorTest). _(Thanks, Eric Chadwick, for the pointers.)_

---
## License

**[CC-NC-BY-SA](LICENSE)**

Textures from the [JG-RTX resource pack](https://github.com/jasonjgardner/jg-rtx), which has the same license.

---
# Contact
Email [me](http://erichaines.com) at [erich@acm.org](mailto:erich@acm.org).