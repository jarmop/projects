package survival

land: Land

slices := []LandRow {
	{ring = 0, segment = 0, width = 2},
	{ring = 0, segment = 3, width = 2},
	{ring = 0, segment = 6, width = 2},
}

land_segments: [globe_land_rings * globe_land_segments]int
