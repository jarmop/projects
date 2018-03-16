const axios = require('axios');
const jsonfile = require('jsonfile');

const URL_TRACK_SECTIONS = 'https://rata.digitraffic.fi/api/v1/metadata/track-sections';
const KEHARATA_TRACK_NUMBER = '123';
const KEHARATA_FILENAME = 'keharata.json';

const initializeKeharata = () => {
  axios.get(URL_TRACK_SECTIONS)
      .then(response => response.data.filter(
          section => section.ranges[0].startLocation.track === KEHARATA_TRACK_NUMBER)
      )
      .then(sections => jsonfile.writeFile(KEHARATA_FILENAME, sections, (error) => {
        if (error) {
          Promise.reject(error);
        }
        console.log(KEHARATA_FILENAME + ' saved!');
      }))
      .catch(error => {
        console.log(error);
      });
};

initializeKeharata();


// const geolib = require('geolib');
//
// let train1 = {
//   lat: 60.17171747413841,
//   lon: 24.942053947481092,
//   delta: 17,
//   direction: 0,
//   status: 1,
//   action: 'deleted',
// };
//
// let train2 = {
//   lat: 60.30315743603303,
//   lon: 25.04952444568184,
//   delta: -38,
//   direction: 0,
//   status: 1,
//   action: 'modified',
// };
//
// let distance = geolib.getDistance(
//     {latitude: train1.lat, longitude: train1.lon},
//     {latitude: train2.lat, longitude: train2.lon},
// );
//
// console.log(distance);