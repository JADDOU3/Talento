abstract class CoinsState {
  const CoinsState();
}

class CoinsInitial extends CoinsState {
  const CoinsInitial();
}

class CoinsLoading extends CoinsState {
  final int previousCoins;

  const CoinsLoading({
    this.previousCoins = 0,
  });
}

class CoinsLoaded extends CoinsState {
  final int coins;

  const CoinsLoaded({
    required this.coins,
  });

  CoinsLoaded copyWith({
    int? coins,
  }) {
    return CoinsLoaded(
      coins: coins ?? this.coins,
    );
  }
}

class CoinsError extends CoinsState {
  final String message;
  final int previousCoins;

  const CoinsError({
    required this.message,
    this.previousCoins = 0,
  });
}
