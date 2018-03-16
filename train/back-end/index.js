const {getKeharataTrackSections} = require('./data');

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
  let mapCodeToSection = {};
  for (section of sections) {
    mapCodeToSection[section.trackSectionCode] = section;
  }
  return Object.values(mapCodeToSection);
};

getKeharataTrackSections()
    .then(sections => removeDuplicates(sections))
    .then(sections => sections.filter(section => getSectionLength(section) > 0))
    .then(sections => sections.sort((sectionA, sectionB) => {
      // return sectionA.ranges[0].startLocation.kilometres -
      //     sectionB.ranges[0].startLocation.kilometres;
      return getSectionLocationMetres(sectionA) -
          getSectionLocationMetres(sectionB);
    }))
    .then(sections => {
      console.log(sections.length);
      for (section of sections) {
        console.log(
            section.id,
            section.station,
            section.trackSectionCode,
            getSectionLocationMetres(section),
            getSectionLength(section),
            // section.ranges[0].startLocation.kilometres,
            // section.ranges[0].startLocation.metres,
            // section.ranges[0].endLocation.kilometres,
            // section.ranges[0].endLocation.metres,
        );
      }
    });

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