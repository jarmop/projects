import React, {Component} from 'react';
import './Map.css';

let Map = ({sections}) => {
  // let min = null;
  // let max = null;
  // for (let section of sections) {
  //   if (!min || section.startLocation < min) {
  //     min = section.startLocation;
  //   }
  //   if (!max || section.endLocation > max) {
  //     max = section.endLocation;
  //   }
  // }
  // let totalLength = max - min;
  // let ratio = 1/5;
  // let relativeLength = totalLength * ratio;

  let columns = {};
  for (let section of sections) {
    if (!columns.hasOwnProperty(section.startLocation)) {
      columns[section.startLocation] = [];
    }
    columns[section.startLocation].push(section);
  }

  console.log(columns);

  return (
      <div
          className="map"
          // style={{width: relativeLength}}
      >
        {Object.keys(columns).map(columnId =>
            <div key={columnId}>
              {columns[columnId].map(section =>
                  <div key={section.id} className="section">{section.id}</div>,
              )}
            </div>
        )}

      </div>
  );
};

export default Map;