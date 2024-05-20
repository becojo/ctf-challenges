// @ts-nocheck

export default function (p) {
  let img;

  let teeth = [
    [55, 219, "Type", ""],
    [62, 182, "Type", ""],
    [79, 144, "Type", ""],
    [92, 113, "Type", ""],
    [111, 87, "Type", ""],
    [129, 62, "Type", ""],
    [166, 47, "Type", ""],
    [208, 36, "Type", ""],
    [267, 37, "Type", ""],
    [309, 47, "Type", ""],
    [344, 63, "Type", ""],
    [363, 88, "Type", ""],
    [381, 113, "Type", ""],
    [396, 145, "Type", ""],
    [410, 184, "Type", ""],
    [416, 221, "Type", ""],
    [409, 268, "Type", ""],
    [406, 307, "Type", ""],
    [392, 347, "Type", ""],
    [375, 383, "Type", ""],
    [349, 405, "Type", ""],
    [323, 427, "Type", ""],
    [290, 437, "Type", ""],
    [257, 439, "Type", ""],
    [219, 439, "Type", ""],
    [185, 436, "Type", ""],
    [153, 427, "Type", ""],
    [126, 407, "Type", ""],
    [100, 383, "Type", ""],
    [82, 349, "Type", ""],
    [70, 307, "Type", ""],
    [66, 268, "Type", ""],
  ];
  let mapSide = 25;

  p.setup = () => {
    p.createCanvas(500, 500, document.getElementById("visualization"));
    p.noStroke();

    // Kaligula, CC BY-SA 3.0 <https://creativecommons.org/licenses/by-sa/3.0>, via Wikimedia Commons
    img = p.loadImage("/app/teeth.svg");

    let data = JSON.parse(document.getElementById("mouth").dataset.mouth);

    for (var i = 0; i < data.teeth.length; i++) {
      let id = data.teeth[i];
      teeth[i][2] = data[`mouths/${data.mouth}/teeth/${id}/type`] || "";
      teeth[i][3] = data[`mouths/${data.mouth}/teeth/${id}/defects`] || "";
    }
  };

  var label = {
    text: "",
    x: 0,
    y: 0,
  };

  p.draw = () => {
    p.background(0x7d, 0x6c, 0x65);
    let x = p.mouseX;
    let y = p.mouseY;
    let width = p.width;
    let height = p.height;
    let frameCount = p.frameCount;
    let mouseIsPressed = p.mouseIsPressed;

    p.fill(255, 255, 255);
    for (let i = 0; i < teeth.length; i++) {
      let [mx, my, t, defects] = teeth[i];

      if (defects.length > 0) {
        p.fill(((i * 1337 + frameCount * 2) % 127) + 127, 0, 0);
        p.ellipse(mx + mapSide / 2, my + mapSide / 2, mapSide, mapSide);
      }

      if (x > mx && x < mx + mapSide && y > my && y < my + mapSide) {
        p.fill(255, 255, 255, 100);
        p.rect(mx, my, mapSide, mapSide);

        if (mouseIsPressed) {
          label.text = `#${i + 1}`;
          label.y = my;
          label.x = mx;

          document.getElementById("number").innerText = `Number: ${i + 1}`;
          document.getElementById("name").innerText = `Type: ${t}`;
          document.getElementById("defects").innerText = `Defects: ${
            defects.length > 0 ? defects : "N/A"
          }`;
          document.getElementById("q").value = `mouths/0/teeth/${i + 1}`;
        }

        // break;
      }
    }

    if (label.text !== "") {
      p.fill(255, 255, 255);
    }

    p.filter(p.BLUR, 10);

    p.image(img, width * 0.05, height * 0.05, width * 0.9, height * 0.9);

    if (label.text !== "") {
      p.textSize(32);
      p.fill(0, 102, 153);
      // text(label.text, 0, 50);

      // circle the 25x25 square around label
      p.noFill();
      p.stroke(255, 0, 0);
      p.strokeWeight(5);
      var s = Math.sin(frameCount * 0.1) * 10;
      p.ellipse(
        label.x + mapSide / 2,
        label.y + mapSide / 2,
        50 + s,
        (50 + s) * 0.8,
      );
    }

    p.stroke(215, 215, 255);
    p.strokeWeight(5);

    p.noStroke();
  };
}
