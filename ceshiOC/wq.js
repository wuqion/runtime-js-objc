class UIView {
	obj_objc(){}
	constructor( obj_objc ){
        this.obj_objc = obj_objc;
    }
	alloc () {
	    this.obj_objc = sendClassFunc(['UIView','alloc']);
	   return this;
	}
	init () {
		this.obj_objc = sendInstenceFunc([this.obj_objc,'init']);
	    return this;
	}
	frame (x,y,width,height) {

		setFrame([this.obj_objc,{x:x,y:y,width:width,height:height}]);
		
	}
	addSubview(view){
		 sendMainFunc([this.obj_objc,'addSubview:',view]);
	}
	backgroundColor(color){
		if (color == "") {
			 sendInstenceFunc([this.obj_objc,'backgroundColor']);
		}else{
			 setIvar([this.obj_objc,'backgroundColor',color]);
		}
	}
};

class UIColor {
	redColor () {
	  return sendClassFunc(['UIColor','redColor']);
	}
};
class UIViewController {
	obj_objc(){}
	constructor( obj_objc ){
        this.obj_objc = obj_objc;
    }
	alloc () {
        this.obj_objc = sendClassFunc(['UIViewController','alloc']);
	   return this;
	}
	init () {
		this.obj_objc = sendInstenceFunc([this.obj_objc,'init']);
	    return this;
	}
	get view () {
		return new UIView(getIvar([this.obj_objc,'view']));
	}
	presentVC(objc,animated){
		sendMainFunc([this.obj_objc,'presentViewController:animated:completion:',objc,animated,null]);
	}
};
function AppDelegate() {
	this.rootViewController = function() {
	   return rootViewController();
	}
};

var rootViewController = new UIViewController(new AppDelegate().rootViewController());

var myobjc = new UIViewController().alloc().init();
rootViewController.presentVC(myobjc.obj_objc,true);

var view = new UIView().alloc().init();
view.frame(2,2,200,200);
var color = new UIColor().redColor();
view.backgroundColor(color);
myobjc.view.addSubview(view.obj_objc);



