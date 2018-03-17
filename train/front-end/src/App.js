import React, {Component} from 'react';
import 'font-awesome/css/font-awesome.css';
import './App.css';
import {
  addLeadingZero, getSection, getSectionIds, getSectionLength,
  getSectionStartLocation,
  getSectionEndLocation, getSectionTrack, getTrainTrackingData, formatSectionId,
  getLogStartTime, updateOccupied, getInitialOccupied, updateOccupiedReverse,
} from './service';
import Map from './Map';

const formatDate = (timestamp) => {
  let date = new Date(timestamp);
  return addLeadingZero(date.getHours())
      + ':'
      + addLeadingZero(date.getMinutes())
      + ':'
      + addLeadingZero(date.getSeconds());
};

class App extends Component {
  constructor(props) {
    super(props);

    this.state = {
      sections: [],
      occupied: [],
      log: [],
      timeSpeedMs: 60000,
    };
  }

  componentDidMount() {
    console.log('wrthwrth');
    let sections = getSectionIds()
        .filter(sectionId =>
            ['001', '123'].includes(getSectionTrack(getSection(sectionId)))
            &&
            getSectionStartLocation(getSection(sectionId)) > 0
            &&
            getSectionEndLocation(getSection(sectionId)) < 1000
        )
        .map(sectionId => {
          let section = getSection(sectionId);
          // console.log(section);
          return {
            id: sectionId,
            startLocation: getSectionStartLocation(section),
            endLocation: getSectionEndLocation(section),
            length: getSectionLength(section),
          };
        })
        .sort((sectionA, sectionB) =>
            sectionB.startLocation - sectionA.startLocation
        );

    // console.log(sections);

    let log = getTrainTrackingData().sort((a, b) => a.id - b.id);

    // console.log(log[0]);

    this.setState({
      sections: sections,
      log: log,
      // logPointer: 0,
      date: getLogStartTime(log),
      // date: new Date(0),
      occupied: getInitialOccupied(log),
    });
  }

  goBack() {
    let previousDate = this.state.date;
    let newDate = new Date(previousDate.getTime() - this.state.timeSpeedMs);
    let occupied = updateOccupiedReverse(this.state.log, this.state.occupied, previousDate, newDate);
    this.setState({
      date: newDate,
      occupied: occupied,
    });
  }

  goForward() {
    let previousDate = this.state.date;
    let newDate = new Date(previousDate.getTime() + this.state.timeSpeedMs);
    let occupied = updateOccupied(this.state.log, this.state.occupied, previousDate, newDate);
    this.setState({
      date: newDate,
      occupied: occupied,
    });
  }

  render() {
    let {sections, occupied} = this.state;
    // let track = (
    //     <div className="track">
    //       <div className="train"></div>
    //     </div>
    // );

    return (
        <div className="container">
          <Control
            onUp={() => this.goBack()}
            onDown={() => this.goForward()}
          />
          <Map sections={sections} occupied={occupied}/>
          <Table sections={sections}/>
        </div>
    );
  }
}

export default App;

let Table = ({sections}) => (
    <table border="1" style={{borderCollapse: 'collapse'}}>
      <thead>
      <tr>
        <th>id</th>
        <th>start</th>
        <th>end</th>
        <th>length</th>
      </tr>
      </thead>
      <tbody>
      {sections.map(section =>
          <tr key={section.id}>
            <td>{section.id}</td>
            <td>{section.startLocation}</td>
            <td>{section.endLocation}</td>
            <td>{section.length}</td>
          </tr>
      )}
      </tbody>
    </table>
);

let Control = ({onUp, onDown}) => (
    <div className="control">
      <button className="control__button" onClick={onUp}>
        <i className="fa fa-caret-up"></i>
      </button>
      <button className="control__button" onClick={onDown}>
        <i className="fa fa-caret-down"></i>
      </button>
    </div>
);
