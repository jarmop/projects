import React, {Component} from 'react';
import './App.css';
import {getTrain} from './service';

class App extends Component {
  componentDidMount() {
    getTrain();
  }

  render() {
    return (
        <div className="track">
          <div className="train"></div>
        </div>
    );
  }
}

export default App;
