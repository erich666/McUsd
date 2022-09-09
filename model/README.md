# McUsd Test Model
Go to the [main page](https://github.com/erich666/McUsd) for an explanation and renderings of this simple USD test scene.

The files in this directory include:
* McUsd.usda - the main test file
* McUsd.usda - as noted in "Omniverse adjustments" on the [main page](https://github.com/erich666/McUsd), render settings are included for Omniverse that adjust the camera's default exposure. This file boosts all lights by a factor of about 53x and removes these camera exposure settings to give a comparable USD test file.
* McUsd_normal_normals.usda - for all normal maps the bias is set to (-1,-1,-1,-1) and scale to (2,2,2,2). This is meant as a debug test file and should display differently (normals will look lit from below) if the USD reader being tested does not use the bias and scale values. Visit the [unit_tests/cubes_r_normals subdirectory](/unit_tests/cubes_r_normals) for a more thorough test scene.
* McUsd_unscaled_lava.usda - the two emissive lava textures are not scaled up by 1000 in this version. This helps in testing whether the scale is affecting the display of the lava itself.

To see exact differences, I recommend doing a "diff" of any two files.

---
## License

**[CC-NC-BY-SA](LICENSE)**

Textures from the [JG-RTX resource pack](https://github.com/jasonjgardner/jg-rtx), which has the same license.

---
# Contact
Email [me](http://erichaines.com) at [erich@acm.org](mailto:erich@acm.org).