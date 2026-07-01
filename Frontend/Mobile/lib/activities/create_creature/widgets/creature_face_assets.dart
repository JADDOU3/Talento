const Map<String, String> eyesAssets = {
  'round':   'assets/creature/eyes/round.png',
  'sleepy':  'assets/creature/eyes/sleepy.png',
  'sharp':   'assets/creature/eyes/sharp.png',
  'big':     'assets/creature/eyes/big.png',
  'sparkly': 'assets/creature/eyes/sparkly.png',
};

const Map<String, String> mouthAssets = {
  'smiling': 'assets/creature/mouth/smiling.png',
  'fangs':   'assets/creature/mouth/fangs.png',
  'round':   'assets/creature/mouth/round.png',
  'wide':    'assets/creature/mouth/wide.png',
  'small':   'assets/creature/mouth/small.png',
};

const Map<String, String> feelingAssets = {
  'calm_black':     'assets/creature/feeling/calm_black.png',
  'calm_brown':     'assets/creature/feeling/calm_brown.png',
  'calm_blonde':    'assets/creature/feeling/calm_blonde.png',
  'curious_black':  'assets/creature/feeling/curious_black.png',
  'curious_brown':  'assets/creature/feeling/curious_brown.png',
  'curious_blonde': 'assets/creature/feeling/curious_blonde.png',
  'strong_black':   'assets/creature/feeling/strong_black.png',
  'strong_brown':   'assets/creature/feeling/strong_brown.png',
  'strong_blonde':  'assets/creature/feeling/strong_blonde.png',
  'kind_black':     'assets/creature/feeling/kind_black.png',
  'kind_brown':     'assets/creature/feeling/kind_brown.png',
  'kind_blonde':    'assets/creature/feeling/kind_blonde.png',
};

const Map<String, String> hairAssets = {
  'boy_black':   'assets/creature/hair/boy_black.png',
  'boy_brown':   'assets/creature/hair/boy_brown.png',
  'boy_blonde':  'assets/creature/hair/boy_blonde.png',
  'girl_black':  'assets/creature/hair/girl_black.png',
  'girl_brown':  'assets/creature/hair/girl_brown.png',
  'girl_blonde': 'assets/creature/hair/girl_blonde.png',
};

String? resolveFeelingAsset(String? feeling, String? hairColor) {
  if (feeling == null || hairColor == null) return null;
  return feelingAssets['${feeling}_$hairColor'];
}

String? resolveHairAsset(String? gender, String? hairColor) {
  if (gender == null || hairColor == null) return null;
  return hairAssets['${gender}_$hairColor'];
}