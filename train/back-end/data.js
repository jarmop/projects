const axios = require('axios');
const jsonfile = require('jsonfile');

const URL_TRACK_SECTIONS = 'https://rata.digitraffic.fi/api/v1/metadata/track-sections';
const URL_TRAIN_SCHEDULE = 'https://rata.digitraffic.fi/api/v1/trains/latest/8761';
// const URL_TRAIN = 'https://rata.digitraffic.fi/api/v1/trains/2018-03-16/8761';
const KEHARATA_TRACK_NUMBER = '123';
const KEHARATA_FILENAME = 'keharata.json';

const getSectionLocationMetres = (section) => {
  return section.ranges[0].startLocation.kilometres * 1000 +
      section.ranges[0].startLocation.metres;
};

const getSectionLength = (section) => {
  let {startLocation, endLocation} = section.ranges[0];
  return (endLocation.kilometres * 1000 + endLocation.metres) -
      (startLocation.kilometres * 1000 + startLocation.metres);
};

const removeDuplicates = (sections) => {
  let hashTable = {};
  // let mapLocationToSection = {};
  for (section of sections) {
    hashTable[section.trackSectionCode + getSectionLocationMetres(section)] = section;
    // mapLocationToSection[getSectionLocationMetres(section)] = section;
  }
  return Object.values(hashTable);
  // return Object.values(mapLocationToSection);
};

const filterSections = (sections) => {
  console.log('filterSections');
  filteredSections = sections
      .filter(section => (
          section.ranges[0].startLocation.track === KEHARATA_TRACK_NUMBER
          ||
          section.ranges[0].endLocation.track === KEHARATA_TRACK_NUMBER
          ||
          ['HKI', 'PSL', 'KÄP', 'OLK', 'PMK', 'ML', 'TNA', 'PLA', 'TKL', 'HKH', 'ILA', 'HPL'].includes(section.station)
      ))
      .filter(section => getSectionLength(section) > 0);

  // filteredSections = removeDuplicates(filteredSections);

  console.log(filteredSections.length);

  return filteredSections;

};

const fetchTrackSections = () => {
  return axios.get(URL_TRACK_SECTIONS)
      .then(response => response.data)
      .catch(error => {
        console.log(error);
      });
};

exports.initializeKeharata = () => {
  fetchTrackSections()
      .then(sections => filterSections(sections))
      .then(sections => jsonfile.writeFile(KEHARATA_FILENAME, sections, (error) => {
        if (error) {
          console.log(error);
        }
        console.log(KEHARATA_FILENAME + ' saved!');
      }))
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