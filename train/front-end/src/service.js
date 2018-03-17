import sections from './data/sections';
import log9172 from './data/9172';

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
  return getLocationMetres(section.ranges[0].startLocation)
};

export const getSectionEndLocation = (section) => {
  return getLocationMetres(section.ranges[0].endLocation)
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
      .replace(/\[TRAIN_NUMBER\]/, trainNumber)

  console.log(url);
};

export const getTrainTrackingData = () => {
  return log9172;
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