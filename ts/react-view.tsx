import * as React from "react";
import {Player} from "./player";

interface Props {
  player: Player;
}

export class CommentBox extends React.Component<Props,{}> {
  enabled = true;

  enable() {
    this.enabled = true;
  }

  disable() {
    this.enabled = false;
  }

  public play() {
    if (!this.enabled) {
      return;
    }
    this.disable();
    this.props.player.play().then(() => this.enable(), () => this.enable());
  }

  public forward() {
    if (!this.enabled) {
      return;
    }
    this.disable();
    this.props.player.forward().then(() => this.enable(), () => this.enable());
  }

  public backward() {
    if (!this.enabled) {
      return;
    }
    this.disable();
    this.props.player.backward().then(() => this.enable(), () => this.enable());
  }

  render() {
    return (
      <div className="commentBox">
        <button className="btn btn-secondary"><i className="fa fa-fast-backward" aria-hidden="true"></i></button>
        <button onClick={e => this.backward()} className="btn btn-secondary"><i className="fa fa-backward" aria-hidden="true"></i></button>
        <button onClick={e => this.play()} className="btn btn-secondary"><i className="fa fa-play" aria-hidden="true"></i></button>
        <button onClick={e => this.forward()} className="btn btn-secondary"><i className="fa fa-forward" aria-hidden="true"></i></button>
        <button className="btn btn-secondary"><i className="fa fa-fast-forward" aria-hidden="true"></i></button>
      </div>
    );
  }
}