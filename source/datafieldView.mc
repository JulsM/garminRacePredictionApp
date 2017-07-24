using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Attention;

class datafieldView extends Ui.DataField {

    hidden var elapsedDist;
    var dataArray;
    var currentPoint; // extremePointDist, nextDist, gradient
    var index = 0;
    var vibeProfile;
    

    function initialize() {
        DataField.initialize();
        elapsedDist = 0;
        var str = Ui.loadResource(Rez.Strings.data);
	    
	    currentPoint = [0, 0, 0];
	    dataArray = split(str, "|", false);
	    str = null;
	    //Sys.println(dataArray[0]);
	    for(var i = 0; i < dataArray.size(); i++) {
	    	dataArray[i] = split(dataArray[i], ",", true);
	    }
	    //Sys.println(dataArray[0]);
	    //Sys.println(dataArray.size());
	    if (Attention has :vibrate) {
		    vibeProfile =
		    [
		        new Attention.VibeProfile(50, 1000), // On for two seconds
		        new Attention.VibeProfile(0, 1000),  // Off for two seconds
		        new Attention.VibeProfile(50, 1000) // On for two seconds
		    ];
		}
        
    }

    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc) {
        
        //View.setLayout(Rez.Layouts.MainLayout(dc));
        
       
        return true;
    }

    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info) {
        // See Activity.Info in the documentation for available information.
        if(info has :elapsedDistance){
            if(info.elapsedDistance != null){
                elapsedDist = info.elapsedDistance;
                //Sys.println(elapsedDist);
                if(elapsedDist >= currentPoint[0]) {
	    			currentPoint = getNextPoint();
	    			//Sys.println(currentPoint);
	    			Attention.vibrate(vibeProfile);
	    		}
            } 
        }
    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc) {
        // Set the background color
        //View.findDrawableById("Background").setColor(getBackgroundColor());

      

        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
        
        var length = currentPoint[1].format("%d"); // distance to next extreme
        var gradient = currentPoint[2]; // gradient
        var state = "EVEN";
        if(gradient > 2.5) {
        	state = "UP";
        } else if(gradient < -2.5) {
        	state = "DOWN";
        }
        gradient = gradient.format("%.2f");
            
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.clear();
        dc.drawText(
            dc.getWidth()/2,
            dc.getHeight()/2,
            dc.FONT_LARGE,
            "Next " + length + " m " + state + "\nGradient: " + gradient,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
    
    function getNextPoint() {
    	var point = false;
    	if(index < dataArray.size()) {
    		point = dataArray[index];
    		dataArray[index] = null;
    		index++;
    	}
    	return point;
    }
    
    function split(s, sep, convert) {
	    var tokens = [];
	
	    var found = s.find(sep);
	    while (found != null) {
	        var token = s.substring(0, found);
	        if(convert) {
	        	tokens.add(token.toFloat());
	        } else {
	        	tokens.add(token);
        	}
	        s = s.substring(found + sep.length(), s.length());
	
	        found = s.find(sep);
	    }
	
	    if(convert) {
        	tokens.add(s.toFloat());
        } else {
        	tokens.add(s);
    	}
	
	    return tokens;
	}

}
