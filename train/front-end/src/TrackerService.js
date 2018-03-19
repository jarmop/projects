import stoppingSections from './data/stopping-sections';

let keharataStationCodes = Object.keys(stoppingSections);

const URL_LOCATION = 'https://rata.digitraffic.fi/api/v1/train-locations/latest/[TRAIN_NUMBER]';
const URL_STATIONS = 'https://rata.digitraffic.fi/api/v1/metadata/stations';

export const getLocation = (train) => {
  return fetch(URL_LOCATION.replace(/\[TRAIN_NUMBER\]/, train))
      .then(response => response.json())
      .then(json => {
        json = json[0];
        return {
          longitude: json.location.coordinates[0],
          latitude: json.location.coordinates[1],
          speed: json.speed,
        }
      })
      .catch();
};

export const getStations = () => {
  return fetch(URL_STATIONS)
      .then(response => response.json())
      .then(stations => {
        let keharataStations = stations.filter(station => keharataStationCodes.includes(station.stationShortCode));
        console.log(keharataStations);
        return keharataStations;
      })
      .catch();
};