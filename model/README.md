# McUsd Test Model

*IMPORTANT:* This McUsd model and the normals test model are now part of the [ASWF USD assets repository](https://github.com/usd-wg/assets). Find the updated version of this model in [here](https://github.com/usd-wg/assets/tree/main/full_assets/McUsd) and the normals test in [here](https://github.com/usd-wg/assets/tree/main/test_assets/NormalsTextureBiasAndScale). I will leave this old version of the model and page available here, but will not update it.

Go to the [main page](https://github.com/erich666/McUsd) for an explanation and renderings of this simple USD test scene.

The files in this directory include:
* McUsd.usda - the main test file
* McUsd_no_exposure.usda - as noted in "Omniverse adjustments" on the [main page](https://github.com/erich666/McUsd), render settings are included for Omniverse that adjust the camera's default exposure. This file boosts all lights by a factor of about 53x and removes these camera exposure settings to give a comparable USD test file.
* McUsd_unscaled_lava.usda - the two emissive lava textures are not scaled up by 1000 in this version. This helps in testing whether the scale is affecting the display of the lava itself.
* McUsd_yflip_normals.usda - in this version, the normal map textures' bias are set to (-1,-1,-1,-1) and scale to (2,2,2,2), the defaults. This is meant as a debug test file and should display _differently_ and _incorrectly_ (normals will look lit from below) if the USD reader being tested reads in the lighting and properly uses the bias and scale values. If the USD reader is ignoring bias and scale, the render should appear the same as McUsd.usda. Visit the [unit_tests/cubes_r_normals subdirectory](/unit_tests/cubes_r_normals) for a more thorough test scene.

To see exact differences, I recommend doing a "diff" of any two USDA files.

---
## License

**[CC-NC-BY-SA](LICENSE)**

Textures from the [JG-RTX resource pack](https://github.com/jasonjgardner/jg-rtx), which has the same license.

---
# Contact
Email [me](http://erichaines.com) at [erich@acm.org](mailto:erich@acm.org).