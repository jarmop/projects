import React, {Component} from 'react';
import './App.css';
import {
  addLeadingZero, getSection, getSectionIds, getSectionLength,
  getSectionStartLocation,
  getSectionEndLocation,
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
    };
  }

  componentDidMount() {
    let sections = getSectionIds()
        .filter(sectionId => ['KAN', 'MLO', 'MYR'].includes(
            getSection(sectionId).station))
        .map(sectionId => {
          let section = getSection(sectionId);
          return {
            id: sectionId,
            startLocation: getSectionStartLocation(section),
            endLocation: getSectionEndLocation(section),
            length: getSectionLength(section),
          };
        })
        .sort((sectionA, sectionB) => sectionA.startLocation -
            sectionB.startLocation);

    this.setState({
      sections: sections,
    });
  }

  render() {
    let {sections} = this.state;
    // let track = (
    //     <div className="track">
    //       <div className="train"></div>
    //     </div>
    // );

    return (
        <div className="container">
          <Map sections={sections}/>
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
