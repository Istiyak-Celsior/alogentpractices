
	    if(document.images) {
	      ccover = new Array(4);
	      ccout = new Array(4);
	      ccover[1]=new Image;
	      ccout[1]=new Image;
	      for(var n=2;n<=4;n++) {
	              ccover[n]=new Image;
	              ccout[n]=new Image;
	      }
	      for(var n=1;n<=4;n++) {
	              ccover[n].src="Content/Images/Nav/"+n+"b.gif";
	              ccout[n].src="Content/Images/Nav/"+n+".gif";
	      }
	    }

	    function ccOn(i) {
	      if(document.images) document.images["cc" + i].src=ccover[i].src;
	    }
	    function ccOff(i) {
	      if(document.images) document.images["cc" + i].src=ccout[i].src;
	    }
