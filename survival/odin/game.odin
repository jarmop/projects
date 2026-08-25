package survival

Settlement :: struct {
	population:      int,
	demand:          []struct {
		product: string,
		amount:  int,
	},
	food_demand:     int,
	food_production: int,
	food_import:     int,
}

Game :: struct {
	year:        int,
	settlements: []Settlement,
}

game: Game = {
	year        = 0,
	settlements = {
		Settlement{population = 1000, food_demand = 1000, food_production = 1000, food_import = 0},
	},
}

settlement := game.settlements[0]

game_init :: proc() {

	settlement.food_demand = settlement.population
}

game_increment_year :: proc() {
	// settlement := settlement

	game.year += 1
	settlement.population = settlement.food_production + settlement.food_import
	settlement.food_demand = settlement.population
}
