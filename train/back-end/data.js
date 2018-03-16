const axios = require('axios');
const jsonfile = require('jsonfile');

const URL_TRACK_SECTIONS = 'https://rata.digitraffic.fi/api/v1/metadata/track-sections';
const KEHARATA_TRACK_NUMBER = '123';
const KEHARATA_FILENAME = 'keharata.json';

exports.initializeKeharata = () => {
  axios.get(URL_TRACK_SECTIONS)
      .then(response => response.data.filter(
          section => section.ranges[0].startLocation.track ===
              KEHARATA_TRACK_NUMBER),
      )
      .then(sections => jsonfile.writeFile(KEHARATA_FILENAME, sections,
          (error) => {
            if (error) {
              Promise.reject(error);
            }
            console.log(KEHARATA_FILENAME + ' saved!');
          }))
      .catch(error => {
        console.log(error);
      });
};

exports.getKeharataTrackSections = () => {
  return new Promise((resolve, reject) => {
    jsonfile.readFile(KEHARATA_FILENAME, (error, data) => {
      if (error) {
        reject(error);
      }
      resolve(data);
    })
  });
};