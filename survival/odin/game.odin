package survival

Game :: struct {
	year:        int,
	population:  int,
	food_demand: int,
	food_supply: int,
}

game: Game = {
	year        = 0,
	population  = 1000,
	food_supply = 0,
}

game_init :: proc() {
	game.food_demand = game.population
}

game_increment_year :: proc() {
	game.year += 1
	game.population = game.food_supply
	game.food_demand = game.population
}
