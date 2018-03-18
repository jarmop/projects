import React, {Component} from 'react';
import './Detail.css';
import {getOccupied} from './service';

class Detail extends Component {
  constructor(props) {
    super(props);

    this.state = {
      occupied: {
        current: null,
        next: null,
        previous: null,
      },
      trainNumber: 9176,
    };
  }

  poll() {
    setTimeout(() => {
      this.updateLocation();

      this.poll();
    }, 10000);
  }

  componentDidMount() {
    this.updateLocation();

    this.poll();
  }

  updateLocation() {
    getOccupied(this.state.trainNumber)
        .then(occupied => {
          this.setState({
            occupied: occupied,
          });
        });
  }

  updateTrain() {
    this.setState({
      trainNumber: this.domObject.value
    }, () => this.updateLocation());
  }

  render() {
    let {occupied, trainNumber} = this.state;
    // console.log(occupied);

    return (
        <div className="detail">
          <div className="detail__train-input">
            <input
                type="text"
                ref={domObject => this.domObject = domObject}
            />
            <button onClick={event => this.updateTrain()}>
              Hae
            </button>
            {trainNumber}
          </div>

          <div className="track">
            <div className="station">
              {occupied.previous}
            </div>
            <div><i className="track__direction fa fa-angle-double-right"></i>
            </div>
            <div className="station station--current">
              {occupied.current}
            </div>
            <div><i className="track__direction fa fa-angle-double-right"></i>
            </div>
            <div className="station">
              {occupied.next}
            </div>
          </div>
        </div>
    );
  }
}

export default Detail;