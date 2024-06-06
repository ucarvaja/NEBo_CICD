package main

import (
	"testing"
)

// TestCalculateScore tests the calculateScore function with various inputs.
func TestCalculateScore(t *testing.T) {
	city := City{Name: "TestCity", Latitude: 10.0, Longitude: 20.0}
	searchTerm := "TestCity"
	latitude := "10.00000"
	longitude := "20.00000"

	tests := []struct {
		name          string
		city          City
		searchTerm    string
		latitude      string
		longitude     string
		expectedScore float64
	}{
		{"ExactMatch", city, searchTerm, latitude, longitude, 1.0},
		{"NameMatchLatitudeMatch", city, searchTerm, latitude, "0.00000", 0.9},
		{"NameMatchLongitudeMatch", city, searchTerm, "0.00000", longitude, 0.9},
		{"NameMatch", city, searchTerm, "0.00000-6555656", "0.00000", 0.8},
		{"LatitudeLongitudeMatch", city, "DifferentCity", latitude, longitude, 0.7},
		{"LatitudeMatch", city, "DifferentCity", latitude, "0.00000", 0.6},
		{"LongitudeMatch", city, "DifferentCity", "0.00000", longitude, 0.6},
		{"NoMatch", city, "DifferentCity", "0.00000", "0.00000", 0.5},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			score := calculateScore(test.city, test.searchTerm, test.latitude, test.longitude)
			if score != test.expectedScore {
				t.Errorf("calculateScore(%+v, %s, %s, %s) = %f; want %f", test.city, test.searchTerm, test.latitude, test.longitude, score, test.expectedScore)
			}
		})
	}
}
