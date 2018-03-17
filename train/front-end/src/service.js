import sections from './data/sections';
// import log from './data/9172';
import log from './data/8767';

// const TRAIN_URL = 'https://junatkartalla-cal-prod.herokuapp.com/trains/1520974201460';
// const TRAIN_URL = 'https://rata.digitraffic.fi/api/v1/trains/latest/[TRAIN_NUMBER]';
const URL_TRAIN_TRACKING = 'https://rata.digitraffic.fi/api/v1/train-tracking/[DATE]/[TRAIN_NUMBER]?version=1000';

let sectionIds = Object.keys(sections);

/**
 * @param value
 * @returns {string}
 */
export const addLeadingZero = (value) => {
  return value < 10 ? '0' + value : '' + value;
};

const formatUrlDate = (date) => {
  return date.getFullYear()
      + '-'
      + addLeadingZero(date.getMonth() + 1)
      + '-'
      + addLeadingZero(date.getDate());
};

const getLocationMetres = (location) => {
  return location.kilometres * 1000 + location.metres;
};

export const getSectionStartLocation = (section) => {
  return getLocationMetres(section.ranges[0].startLocation);
};

export const getSectionEndLocation = (section) => {
  return getLocationMetres(section.ranges[0].endLocation);
};

export const getSectionTrack = (section) => {
  return section.ranges[0].startLocation.track;
};

export const getSectionLength = (section) => {
  let {startLocation, endLocation} = section.ranges[0];
  return (endLocation.kilometres * 1000 + endLocation.metres) -
      (startLocation.kilometres * 1000 + startLocation.metres);
};

export const getTrain = () => {
  let date = new Date();
  let trainNumber = 9174;
  console.log(formatUrlDate(date));

  let url = URL_TRAIN_TRACKING
      .replace(/\[DATE\]/, formatUrlDate(date))
      .replace(/\[TRAIN_NUMBER\]/, trainNumber);

  console.log(url);
};

export const getTrainTrackingData = () => {
  return log;
};

export const getSection = (sectionId) => {
  return sections[sectionId];
};

export const getSectionIds = () => {
  return sectionIds;
};

export const formatSectionId = (station, sectionCode) => {
  return station + '-' + sectionCode;
};

export const getLogStartTime = (log) => {
  return new Date((new Date(log[0].timestamp)).getTime() - 1000);
};

const prkl = (date) => {
  return date.getHours()
      + '-'
      + addLeadingZero(date.getMinutes() + 1)
      + '-'
      + addLeadingZero(date.getSeconds());
};

export const updateOccupied = (log, occupied, previousDate, newDate) => {
  let date = new Date();
  console.log(prkl(previousDate));
  console.log(prkl(newDate));

  let logPart = log
      .filter(entry => {
        let entryTime = (new Date(entry.timestamp)).getTime();
        return entryTime >= previousDate.getTime() && entryTime <=
            newDate.getTime();
      });

  let newOccupied = [...occupied];
  for (let entry of logPart) {
    if (entry.type == "OCCUPY") {
      console.log('occupy', formatSectionId(entry.station, entry.trackSection));
      newOccupied.push(formatSectionId(entry.station, entry.trackSection))
    } else if (entry.type == "RELEASE") {
      console.log('release', formatSectionId(entry.station, entry.trackSection));
      newOccupied = newOccupied.filter(id => {
        return id !== formatSectionId(entry.station, entry.trackSection);
      });
    }
  }

  console.log(newOccupied);

  return newOccupied;
};

export const getInitialOccupied = (log) => {
  // console.log(log.slice(0, 10));
  // return [formatSectionId(log[0].station, log[0].trackSection)];
  return [];
};