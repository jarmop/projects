package survival

LandRow :: struct {
	start: int,
	width: int,
}


Land :: struct {
	start_ring:    int,
	start_segment: int,
	width:         int,
	rows:          []LandRow,
}
