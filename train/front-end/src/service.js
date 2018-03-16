// const TRAIN_URL = 'https://junatkartalla-cal-prod.herokuapp.com/trains/1520974201460';
// const TRAIN_URL = 'https://rata.digitraffic.fi/api/v1/trains/latest/[TRAIN_NUMBER]';
const URL_TRAIN_TRACKING = 'https://rata.digitraffic.fi/api/v1/train-tracking/[DATE]/[TRAIN_NUMBER]?version=1000';

/**
 * @param value
 * @returns {string}
 */
const addLeadingZero = (value) => {
  return value < 10 ? '0' + value : '' + value;
};

const formatDate = (date) => {
  return date.getFullYear()
      + '-'
      + addLeadingZero(date.getMonth() + 1)
      + '-'
      + addLeadingZero(date.getDate());
};

export const getTrain = () => {
  let date = new Date();
  let trainNumber = 9174;
  console.log(formatDate(date));

  let url = URL_TRAIN_TRACKING
      .replace(/\[DATE\]/, formatDate(date))
      .replace(/\[TRAIN_NUMBER\]/, trainNumber)

  console.log(url);
};