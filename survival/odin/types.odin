package survival

LandRow :: struct {
	ring:    int,
	segment: int,
	width:   int,
}

Land :: struct {
	ring:    int,
	segment: int,
	slices:  []LandRow,
}
