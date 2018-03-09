import React, { Component } from 'react';
import './App.css';
import Stats from "./Stats";

class App extends Component {
  render() {
    return (
      <div className="app">
        <Stats player={8479339}/>
      </div>
    );
  }
}

export default App;


