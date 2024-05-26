package main

import (
	"encoding/json"
	"io/ioutil"
	"net/http"
	"net/http/httptest"
	"reflect"
	"testing"
)

// setCitiesData is a test function to replace city data with test data.
func setCitiesData(mockCities []City) {
	cities = mockCities
}

// TestSuggestionsHandler tests the suggestionsHandler function by sending a mock HTTP request.
func TestSuggestionsHandler(t *testing.T) {
	// Create a set of data for testing
	mockCities := []City{
		{
			Name:      "TestCity",
			Latitude:  10.00000,
			Longitude: 20.00000,
		},
	}

	// Write the data for testing
	setCitiesData(mockCities)

	req, err := http.NewRequest("GET", "/suggestions?q=TestCity&latitude=10.00000&longitude=20.00000", nil)
	if err != nil {
		t.Fatalf("could not create HTTP request: %v", err)
	}

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(suggestionsHandler)

	handler.ServeHTTP(rr, req)

	// Check the status code is what we expect.
	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v want %v", status, http.StatusOK)
	}

	// Read the body of the response.
	respBody, err := ioutil.ReadAll(rr.Body)
	if err != nil {
		t.Fatalf("could not read response: %v", err)
	}

	// Unmarshal the JSON response into a map.
	var actualResp map[string][]Suggestion
	if err := json.Unmarshal(respBody, &actualResp); err != nil {
		t.Fatalf("could not unmarshal response: %v", err)
	}

	// Define the expected response based on the mocked data.
	expectedResp := map[string][]Suggestion{
		"suggestions": {
			{
				Name:      "TestCity",
				Latitude:  "10.00000",
				Longitude: "20.00000",
				Score:     1.0, // Asumimos que este es el puntaje esperado. Ajusta según la lógica real de calculateScore.
			},
		},
	}

	// Compare the actual response with the expected response.
	if !reflect.DeepEqual(actualResp, expectedResp) {
		t.Errorf("handler returned unexpected body: got %v want %v",
			actualResp, expectedResp)
	}
}

//test
