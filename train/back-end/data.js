const axios = require('axios');
const jsonfile = require('jsonfile');

const URL_TRACK_SECTIONS = 'https://rata.digitraffic.fi/api/v1/metadata/track-sections';
const URL_TRAIN_SCHEDULE = 'https://rata.digitraffic.fi/api/v1/trains/latest/8761';
// const URL_TRAIN = 'https://rata.digitraffic.fi/api/v1/trains/2018-03-16/8761';
const KEHARATA_1_TRACK_NUMBER = '001';
const KEHARATA_1_MAX_LENGTH = 7;
const KEHARATA_3_TRACK_NUMBER = '003';
const KEHARATA_3_MAX_LENGTH = 20;
const KEHARATA_123_TRACK_NUMBER = '123';
const KEHARATA_FILENAME = 'keharata[TRACK_NUMBER].json';
const SECTIONS_FILENAME = 'data/sections.json';

// Only stoppping points here. (Missing "gohst stations".)
const keharataStationsTrack1 = ['HKI', 'PSL', 'ILA', 'HPL'];
const keharataStationsTrack3 = [
  'HKI',
  'PSL',
  'KÄP',
  'OLK',
  'PMK',
  'ML',
  'TNA',
  'PLA',
  'TKL',
  'HKH',
];
const keharataStationsTrack123 = [
  'POH',
  'KAN',
  'MLO',
  'MYR',
  'LOH',
  'MRL',
  'LAV',
  'VKS',
  'VEH',
  'KTÖ',
  'AVP',
  'LEN',
  'ASO',
  'LNÄ',
];

const removeDuplicates = (sections) => {
  console.log('removing duplicates');
  let hashTable = {};
  for (section of sections) {
    let trackAndCode = section.station + '-' + section.trackSectionCode;
    if (hashTable.hasOwnProperty(trackAndCode)) {
      console.log(trackAndCode);
    } else {
      hashTable[trackAndCode] = section;
    }
  }
  return Object.values(hashTable);
};

const formatSectionId = (station, sectionCode) => {
  return station + '-' + sectionCode;
};

const getKeharataSectionIdsFromLogs = () => {
  let trains = [8767, 8768, 8769, 9172, 9173, 9174];
  // let trains = [8767];
  let hashTable = {};
  for (let train of trains) {
    let log = jsonfile.readFileSync('data/' + train + '.json');
    for (entry of log) {
      hashTable[formatSectionId(entry.station, entry.trackSection)] = 1;
    }

    // console.log(Object.keys(hashTable).length);

  }

  return Object.keys(hashTable);
};

const filterKeharataSections = (sections) => {
  let keharataSectionIds = getKeharataSectionIdsFromLogs();

  return sections.filter(section => keharataSectionIds.includes(
      formatSectionId(section.station, section.trackSectionCode)));

  // return sections.filter(section => {
  //   let isPartOfKeharata = false;
  //   for (range of section.ranges) {
  //     if (
  //         (
  //             [range.startLocation.track, range.endLocation.track]
  //                 .includes(KEHARATA_1_TRACK_NUMBER)
  //             &&
  //             range.endLocation.kilometres < KEHARATA_1_MAX_LENGTH
  //         )
  //         ||
  //         (
  //             [range.startLocation.track, range.endLocation.track]
  //                 .includes(KEHARATA_3_TRACK_NUMBER)
  //             &&
  //             range.endLocation.kilometres < KEHARATA_3_MAX_LENGTH
  //         )
  //         ||
  //         (
  //             [range.startLocation.track, range.endLocation.track]
  //                 .includes(KEHARATA_123_TRACK_NUMBER)
  //         )
  //     ) {
  //       isPartOfKeharata = true;
  //       break;
  //     }
  //   }
  //   return isPartOfKeharata;
  // });
};

const addLeadingZero = (value) => {
  return value < 10 ? '0' + value : '' + value;
};


const cleanup = (sections) => {

  console.log('total sections: ' + sections.length);
  filteredSections = filterKeharataSections(sections);

  console.log(filteredSections.length);

  filteredSections = removeDuplicates(filteredSections);

  console.log(filteredSections.length);

  // let uniqueStations = {};
  // for (let section of filteredSections) {
  //   uniqueStations[section.station] = 1;
  // }
  // console.log(Object.keys(uniqueStations).length);

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

const transformIntoMap = (sections) => {
  let map = {};
  for (section of sections) {
    map[section.station + '-' + section.trackSectionCode] = section;
  }
  return map;
};

exports.initializeKeharata = () => {
  fetchTrackSections()
      .then(sections => cleanup(sections))
      .then(sections => transformIntoMap(sections))
      .then(sections => jsonfile.writeFile(SECTIONS_FILENAME, sections,
          (error) => {
            if (error) {
              console.log(error);
            }
            console.log(SECTIONS_FILENAME + ' saved!');
          },
      ));
};

exports.initializeKeharataStoppingSections = () => {
  let trains = [8767, 8768, 8769, 9172, 9173, 9174];
  // let trains = [8767];
  // let trains = [9172];
  let topDurations = {};
  for (let train of trains) {
    let log = jsonfile.readFileSync('data/' + train + '.json');
    let wtf = [];
    let occupyDurations = {};
    for (entry of log) {
      let sectionId = formatSectionId(entry.station, entry.trackSection);
      let occupyDuration = {
        station: entry.station,
      };
      if (occupyDurations.hasOwnProperty(sectionId)) {
        occupyDuration = occupyDurations[sectionId];
      }

      if (entry.type === 'OCCUPY') {
        if (occupyDuration.hasOwnProperty('occupyTime')) {
          wtf.push(entry);
        }
        // occupyTimes[sectionId] = new Date(entry.timestamp).getTime()
        occupyDuration.occupyTime = Math.floor(new Date(entry.timestamp).getTime() / 1000);
      } else if (entry.type === 'RELEASE') {
        if (occupyDuration.hasOwnProperty('releaseTime')) {
          wtf.push(entry);
        }
        occupyDuration.releaseTime = Math.floor(new Date(entry.timestamp).getTime() / 1000);
      }

      occupyDurations[sectionId] = occupyDuration;

    }

    console.log(wtf);
    // console.log(occupyDurations);

    let durations = {};
    for (sectionId of Object.keys(occupyDurations)) {
      let data = occupyDurations[sectionId];
      if (!durations.hasOwnProperty(data.station)) {
        durations[data.station] = [];
      }
      let duration = data.releaseTime - data.occupyTime;
      durations[data.station].push({
        sectionId: sectionId,
        duration: duration,
      });
    }

    for (station of Object.keys(durations)) {
      durations[station] = durations[station].sort((a,b) => b.duration - a.duration);
    }
    // console.log(durations);

    for (station of Object.keys(durations)) {
      let topDuration = durations[station][0].sectionId;
      if (!topDurations.hasOwnProperty(station)) {
        topDurations[station] = [];
      }

      if (!topDurations[station].includes(topDuration)) {
        topDurations[station].push(topDuration);
      }
    }

    // console.log(topDurations);
  }

  console.log(topDurations);

  jsonfile.writeFileSync('data/stopping-sections.json', topDurations);

};