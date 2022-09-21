# A simple Perl program that takes an RGB triplet from a normal map and determines
# whether it is normalized when the Z value maps from 0 to 1, or -1 to 1.
# When checking a normal map, it's best to find a triplet in the image with the
# lowest blue (Z) value that you can, to maximize the difference.
#
# Change the RGB triplet below to whatever you want to test.
#
# Eric Haines, erich@acm.org

$rgb[0] = 246;
$rgb[1] = 127;
$rgb[2] = 175;


for ($j = 0; $j < 2; $j++) {

	for ($i = 0; $i < 3; $i++ ){
		$xyz[$i] = ($rgb[$i] / 255.0) * 2.0 - 1.0;
	}
	if ($j == 1 ) {
		print "\nElse, assuming Z ranges from 0 to 1:\n";
		$xyz[2] = ($rgb[2] / 255.0);
	} else {
		print "Assuming Z ranges from -1 to 1:\n";
	}

	$len = $xyz[0] * $xyz[0] + $xyz[1] * $xyz[1] + $xyz[2] * $xyz[2];
	# test whether normal is around 1.0f in length. Is this a good test?
	if ($len > 1.02 || $len < 0.98) {
		# corrective action, e.g., renormalize
		$len = sqrt($len);
		for ($i = 0; $i < 3; $i++ )
		{
			$xyz_corr[$i] = $xyz[$i] / $len;
			$rgb_corr[$i] = int(255.0 * (($xyz_corr[$i] + 1.0) / 2.0) + 0.5);
		}
		printf "Vector %d %d %d converts to %0.3f, %0.3f, %0.3f\n", $rgb[0],$rgb[1],$rgb[2], $xyz[0],$xyz[1],$xyz[2];
		printf "  length was wrong at %0.3f, corrected to %0.3f, %0.3f, %0.3f -> %d %d %d\n", $len, $xyz_corr[0],$xyz_corr[1],$xyz_corr[2], $rgb_corr[0],$rgb_corr[1],$rgb_corr[2];
	} else {
		printf "Vector %d %d %d converts to %0.3f, %0.3f, %0.3f, length %0.3f\n", $rgb[0],$rgb[1],$rgb[2], $xyz[0],$xyz[1],$xyz[2], $len;
	}
}

