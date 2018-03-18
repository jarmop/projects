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

const parseUsefulSectionData = (section) => {
  return {
    startLocation: getSectionStartLocation(section),
    endLocation: getSectionEndLocation(section),
    length: getSectionLength(section),
  }
};

class App extends Component {
  constructor(props) {
    super(props);

    this.state = {
      sections: [],
      occupied: [],
      log: [],
      timeSpeedMs: 10000,
    };
  }

  componentDidMount() {
    console.log('wrthwrth');
    let sections = getSectionIds()
        .filter(sectionId =>
            ['001', '123'].includes(getSectionTrack(getSection(sectionId)))
            // ['003'].includes(getSectionTrack(getSection(sectionId)))
            // &&
            // getSectionStartLocation(getSection(sectionId)) > 0
            // &&
            // getSectionEndLocation(getSection(sectionId)) < 20000
        )
        .map(sectionId => ({
            id: sectionId,
            ...parseUsefulSectionData(getSection(sectionId)
        )}));
        // .sort((sectionA, sectionB) =>
        //     sectionB.startLocation - sectionA.startLocation
        // );

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

  goBack(speed) {
    let previousDate = this.state.date;
    let newDate = new Date(previousDate.getTime() - this.state.timeSpeedMs * speed);
    let occupied = updateOccupiedReverse(
        this.state.log, this.state.occupied, previousDate, newDate);
    this.setState({
      date: newDate,
      occupied: occupied,
    });
  }

  goForward(speed) {
    let previousDate = this.state.date;
    let newDate = new Date(previousDate.getTime() + this.state.timeSpeedMs * speed);
    let occupied = updateOccupied(
        this.state.log, this.state.occupied, previousDate, newDate);
    this.setState({
      date: newDate,
      occupied: occupied,
    });
  }

  render() {
    let {sections, occupied, date} = this.state;
    // let track = (
    //     <div className="track">
    //       <div className="train"></div>
    //     </div>
    // );

    return (
        <div className="container">
          <Control
              date={date}
              onUp={(speed) => this.goBack(speed)}
              onDown={(speed) => this.goForward(speed)}
          />
          <Map sections={sections} occupied={occupied}/>
          {/*<Table sections={sections}/>*/}
        </div>
    );
  }
}

export default App;

// let Table = ({sections}) => (
//     <table border="1" style={{borderCollapse: 'collapse'}}>
//       <thead>
//       <tr>
//         <th>id</th>
//         <th>start</th>
//         <th>end</th>
//         <th>length</th>
//       </tr>
//       </thead>
//       <tbody>
//       {sections.map(section =>
//           <tr key={section.id}>
//             <td>{section.id}</td>
//             <td>{section.startLocation}</td>
//             <td>{section.endLocation}</td>
//             <td>{section.length}</td>
//           </tr>
//       )}
//       </tbody>
//     </table>
// );

let Control = ({onUp, onDown, date}) => (
    <div className="control">
      <div>{formatDate(date)}</div>
      <button className="control__button" onClick={() => onUp(10)}>
        <i className="fa fa-angle-double-up"></i>
      </button>
      <button className="control__button" onClick={() => onUp(1)}>
        <i className="fa fa-angle-up"></i>
      </button>
      <button className="control__button" onClick={() => onDown(1)}>
        <i className="fa fa-angle-down"></i>
      </button>
      <button className="control__button" onClick={() => onDown(10)}>
        <i className="fa fa-angle-double-down"></i>
      </button>
    </div>
);
