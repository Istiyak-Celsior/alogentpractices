$(document).ready(function () {
    $('#header-config').on('click', function () {
        window.location.href = 'changepassword.asp';
    });
});

function mopen(e) {
    var t = document.getElementById("menu"+e);
    var n = document.getElementById("mmenu"+e);
    if (t) {
        mcancelclosetime();
        t.style.visibility = "visible";
        if (currentLayer && currentLayerNum != e)
            currentLayer.style.visibility = "hidden";
        currentLayer = t;
        currentitem = n;
        currentLayerNum = e
    }
    else if (currentLayer) {
        currentLayer.style.visibility = "hidden";
        currentLayerNum = 0;
        currentitem = null;
        currentLayer = null;
    }
}

function mclosetime() {
    closeTimer = window.setTimeout(mclose, TimeOut)
}

function mcancelclosetime() {
    if (closeTimer) { window.clearTimeout(closeTimer); closeTimer = null }
}

function mclose() {
    if (currentLayer && noClose != 1) {
        currentLayer.style.visibility = "hidden"; currentLayerNum = 0; currentLayer = null; currentitem = null
    } else {
        noClose = 0
    }
    currentLayer = null;
    currentitem = null
}

var TimeOut = 300;
var currentLayer = null;
var currentitem = null;
var currentLayerNum = 0;
var noClose = 0;
var closeTimer = null;
document.onclick = mclose;
