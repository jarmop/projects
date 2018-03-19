import React, {Component} from 'react';
import * as service from './TrackerService';
import './Tracker.css';

let minLon = 24.80;
let maxLon = 25.10;
let minLat = 60.15;
let maxLat = 60.35;

let ratio = 3000;

let width = (maxLon - minLon) * ratio;
let height = (maxLat - minLat) * ratio;

// console.log(width);
// console.log(height);

let mapLatToMap = (lat) => {
  return Math.floor((lat - minLat) * ratio);
};

let mapLonToMap = (lon) => {
  return Math.floor((lon - minLon) * ratio);
};

class Tracker extends Component {
  constructor(props) {
    super(props);

    this.state = {
      trainNumber: (new URL(window.location.href)).pathname.split('/').slice(-1).pop(),
    };
  }

  poll() {
    setTimeout(() => {
      this.updateLocation();
      this.poll();
    }, 5000);
  }

  updateLocation() {
    service.getLocation(this.state.trainNumber)
        .then(({longitude, latitude, speed}) => {
          this.setState({
            longitude,
            latitude,
            speed,
          });
        })
        .catch(message => {
          console.log(message);
        });
  }

  componentDidMount() {
    service.getStations().then(stations => this.setState({stations}))
    this.updateLocation();
    this.poll();
  }

  render() {
    let {longitude, latitude, speed, stations} = this.state;

    if (!stations) {
      return '';
    }

    let x = mapLonToMap(longitude);
    let y = mapLatToMap(latitude);

    return (
        <div className="tracker">
          <div>
            Coordinates: {longitude + ', ' +latitude}
          </div>
          <div>
            Speed: {speed}
          </div>
          <div className="tracker-map" style={{width: width, height: height}}>
            {stations.map(station =>
                <div
                    className="tracker-map__station"
                    style={{
                      left: mapLonToMap(station.longitude) + 'px',
                      bottom: mapLatToMap(station.latitude) + 'px'
                    }}
                >
                  {station.stationName}
                  </div>
            )}
            <div className="tracker-map__train" style={{left: x + 'px', bottom: y + 'px'}}></div>
          </div>
        </div>
    );
  }
}

export default Tracker;