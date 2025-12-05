
if(document.images) {
  ccover = new Image;
  ccout = new Image; 
  ccover.src = "Content/Images/Nav/pointer_right1.gif";
  ccout.src = "Content/Images/Nav/pointer_right0.gif";
}

function ccOn(imgName) {
  if(document.images) document.images[imgName].src=ccover.src;
}

function ccOff(imgName) {
  if(document.images) document.images[imgName].src=ccout.src;
}
