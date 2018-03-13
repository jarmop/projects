import geolib from 'geolib';

const TRAIN_URL = 'https://junatkartalla-cal-prod.herokuapp.com/trains/1520974201460';

export const getTrain = () => {
  // fetch(TRAIN_URL)
  //     .then(response => response.json())
  //     .then(json => {
  //       let trains = json.trains;
  //       let trainIds = Object.keys(trains).filter(trainId => trains[trainId].title === 'P');
  //       console.log(trainIds);
  //       // console.log(trains[8768]);
  //       // console.log(trains[8769]);
  //     });

  let train1 = {
    lat: 60.17171747413841,
    lon: 24.942053947481092,
    delta: 17,
    direction: 0,
    status: 1,
    action: 'deleted',
  };

  let train2 = {
    lat: 60.30315743603303,
    lon: 25.04952444568184,
    delta: -38,
    direction: 0,
    status: 1,
    action: 'modified',
  };

  let distance = geolib.getDistance(
      {latitude: train1.lat, longitude: train1.lon},
      {latitude: train2.lat, longitude: train2.lon},
  );

  console.log(distance);
};