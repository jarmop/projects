import React, {Component} from 'react';
import './Map.css';

let Map = ({sections, occupied = ['HKI-118', 'HKI-117']}) => {
  console.log(occupied);
  let columns = {};
  for (let section of sections) {
    if (!columns.hasOwnProperty(section.startLocation)) {
      columns[section.startLocation] = [];
    }
    columns[section.startLocation].push(section);
  }

  let columnIds = Object.keys(columns);
  // let columnIds = Object.keys(columns).sort((a,b) => b - a);

  return (
      <div
          className="map"
          // style={{width: relativeLength}}
      >
        {columnIds.map(columnId =>
            <div key={columnId} className="column">
              <div className="location">{columnId}</div>
              {columns[columnId].map(section =>
                  <div
                      key={section.id}
                      className={'section' + (occupied.includes(section.id) ? ' section--occupied' : '')}
                  >
                    {section.id}
                    </div>,
              )}
            </div>
        )}

      </div>
  );
};

export default Map;