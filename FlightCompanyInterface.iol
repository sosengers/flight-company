type FlightRequest: void {
        .flight_id: string
        .date: string
    }

type buyFlightsRequest: void {
    .flight_requests*: FlightRequest
}

type buyFlightsResponse: void {

}

type buyFlightsError: void {
	.description: string
}

type getFlightOffersRequest: void {

}

type getFlightOffersResponse: void {
    .flights?: void {
        ._*: void {
            .flight_id: string
            .departure_airport_code: string
            .arrival_airport_code: string
            .cost: double
            .departure_datetime: string
            .arrival_datetime: string
        }
    }
}

type getFlightOffersError: void {
	.description: string
}

interface FlightCompanyInterface {
RequestResponse:
    /**!
    * Allows to buy those flights available in buyFlightsRequest.flight_requests.
    */
    buyFlights( buyFlightsRequest )( buyFlightsResponse ) throws Fault400( buyFlightsError ) Fault500 ( buyFlightsError ),
    /**!
    * Returns the flights that are made available from the current day forward.
    */
    getFlightOffers( getFlightOffersRequest )( getFlightOffersResponse ) throws Fault400( getFlightOffersError ) Fault500 ( getFlightOffersError )
}
