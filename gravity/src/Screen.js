import React, {useEffect} from 'react';

const CANVAS_WIDTH_PX = 400;
const CANVAS_WIDTH = 2;
const CANVAS_HEIGHT = 3;
const PIXELS_PER_METER = CANVAS_WIDTH_PX / CANVAS_WIDTH;
const OBJECT_RADIUS = 0.1;

const metersToPixels = (meters) => meters * PIXELS_PER_METER;

const drawScreen = (canvas, objectHeight, objectRadius) => {
  objectHeight = metersToPixels(objectHeight);
  objectRadius = metersToPixels(objectRadius);
  const c = canvas.getContext('2d');
  c.clearRect(0, 0, canvas.width, canvas.height);
  c.beginPath();
  c.arc(canvas.width / 2, canvas.height - objectHeight - objectRadius, objectRadius, 0, Math.PI * 2);
  c.fill();
};

function Screen({objectHeight}) {
  let canvas = null;
  useEffect(() => {
    drawScreen(canvas, objectHeight, OBJECT_RADIUS);
  });
  return (
      <canvas ref={domObject => canvas = domObject} id="canvas" className="canvas" width={metersToPixels(CANVAS_WIDTH)} height={metersToPixels(CANVAS_HEIGHT)}/>
  );
}

export default Screen;