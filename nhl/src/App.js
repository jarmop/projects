import React, { Component } from 'react';
import './App.css';
import Stats from "./Stats";

class App extends Component {
  render() {
    return (
      <div className="app">
        <div>
          <Stats/>
        </div>
      </div>
    );
  }
}

export default App;