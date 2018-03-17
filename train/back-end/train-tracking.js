const jsonfile = require('jsonfile');

const FILENAME_TRACKING_LOG = 'data/[TRAIN_NUMBER].json';
const FILENAME_SECTIONS = 'data/sections.json';
const trainNumbers = {
  'I': [9172, 9173, 9174],
  'P': [8767, 8768, 8769],
};

let sections = [];
let sectionsMap = null;

const addLeadingZero = (value) => {
  return value < 10 ? '0' + value : '' + value;
};

const formatDate = (timestamp) => {
  let date = new Date(timestamp);
  return addLeadingZero(date.getHours())
      + ':'
      + addLeadingZero(date.getMinutes())
      + ':'
      + addLeadingZero(date.getSeconds());
};

const compareTrainLogs = () => {
  let logs = [];
  for (trainNumber of [9172]) {
    logs.push(jsonfile.readFileSync(
        FILENAME_TRACKING_LOG.replace(/\[TRAIN_NUMBER\]/, trainNumber),
    ));
  }

  for (let i = 1; i < 10; i++) {
    for (log of logs) {

      // console.log(datum.length);
      let datum = log[log.length - i - 200];
      // data = log.slice(-10);
      // for (datum of data) {
      let date = new Date(datum.timestamp);
      let formattedDate =
          addLeadingZero(date.getHours())
          + ':'
          + addLeadingZero(date.getMinutes())
          + ':'
          + addLeadingZero(date.getSeconds());
      console.log(
          datum.trainNumber,
          formattedDate,
          datum.previousStation,
          datum.station,
          datum.nextStation,
          datum.trackSection,
      );
      // }
    }
    console.log('------------------');
  }
};

const getSectionLocationMetres = (section) => {
  return section.ranges[0].startLocation.kilometres * 1000 +
      section.ranges[0].startLocation.metres;
};

const getSectionLength = (section) => {
  let {startLocation, endLocation} = section.ranges[0];
  return (endLocation.kilometres * 1000 + endLocation.metres) -
      (startLocation.kilometres * 1000 + startLocation.metres);
};

const getSection = (station, sectionCode) => {
  if (sections.length === 0) {
    sections = jsonfile.readFileSync(FILENAME_SECTIONS);
  }

  return sections[station + '-' + sectionCode];
};

exports.explore = () => {
  let data = jsonfile.readFileSync(
      FILENAME_TRACKING_LOG.replace(/\[TRAIN_NUMBER\]/, 9172),
  );

  // let sections = getSections();
  // console.log(sections.length);

  for (datum of data) {
    let section = getSection(datum.station, datum.trackSection);
    // if (getSectionLength(section) < 0) {
    //   console.log(section.id);
    // }
    console.log(
        // datum.trainNumber,
        formatDate(datum.timestamp),
        // datum.previousStation,
        datum.station,
        // datum.nextStation,
        // datum.trackSection,
        getSectionLocationMetres(section),
        getSectionLength(section),
    );
  }
};